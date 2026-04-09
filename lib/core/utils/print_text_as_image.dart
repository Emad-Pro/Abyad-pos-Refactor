import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:image/image.dart' as img;
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:sunmi_printerx/printer.dart';

class PrintableCell {
  final String text;
  final int flex; // مثل Bootstrap: مجموعها 12 مثلًا
  final TextAlign align;
  PrintableCell(this.text, {this.flex = 4, this.align = TextAlign.right});
}
CapabilityProfile? _cachedProfile;

/// يرسم Row كصورة PNG بعرض الطابعة (576px لمعظم سنمي 80مم، و384px لورق 58مم)
Future<Uint8List> renderRowAsPng(
    List<PrintableCell> cells, {
      int widthPx = 384,
      double fontSize = 24,
      EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      bool rtl = true,
      forceBlack = true,
      bool drawDividers = false, // لو تبغى خطوط فاصلة عمودية
    }) async {
  final totalFlex = cells.fold<int>(0, (s, c) => s + c.flex);
  final textPaint = Paint();
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  // خلفية بيضاء
  final bg = Paint()..color = const Color(0xFFFFFFFF);
  canvas.drawRect(Rect.fromLTWH(0, 0, widthPx.toDouble(), 2000), bg);

  final contentWidth = widthPx - padding.left - padding.right;

  // نبني الفقرات أولًا لنعرف أقصى ارتفاع
  final paragraphs = <ui.Paragraph>[];
  final colWidths = <double>[];
  for (final cell in cells) {
    final colW = contentWidth * (cell.flex / totalFlex);
    colWidths.add(colW);

    final pb = ui.ParagraphBuilder(ui.ParagraphStyle(
      fontSize: fontSize,
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      textAlign: cell.align,
      maxLines: 2, // عدّلها حسب حاجتك
    ))
      ..pushStyle(ui.TextStyle(
        color: const Color(0xFF000000),
        fontWeight: FontWeight.bold,
       // fontFamily: ['Roboto', 'Arial', 'Helvetica', 'sans-serif'],
      ))
      ..addText(cell.text);

    final paragraph = pb.build();
    paragraph.layout(ui.ParagraphConstraints(width: colW));
    paragraphs.add(paragraph);
  }

  final maxHeight = paragraphs
      .map((p) => p.height)
      .fold<double>(0, (m, h) => h > m ? h : m);
  final heightPx =
  (padding.top + maxHeight + padding.bottom).ceil().clamp(40, 2000);

  // إعادة رسم الخلفية بارتفاع مضبوط
  canvas.drawRect(Rect.fromLTWH(0, 0, widthPx.toDouble(), heightPx.toDouble()), bg);

  // رسم النصوص داخل الأعمدة
  double x = padding.left;
  for (var i = 0; i < cells.length; i++) {
    final colW = colWidths[i];
    final paragraph = paragraphs[i];

    // موضع النص داخل العمود
    final textOffset = Offset(x, padding.top + (maxHeight - paragraph.height) / 2);
    canvas.drawParagraph(paragraph, textOffset);

    // فاصل عمودي اختياري
    if (drawDividers && i < cells.length - 1) {
      final divider = Paint()..color = const Color(0xFFE0E0E0)..strokeWidth = 1;
      canvas.drawLine(Offset(x + colW, 6), Offset(x + colW, heightPx - 6), divider);
    }

    x += colW;
  }

  // حدود خارجية خفيفة (اختياري)
  // final border = Paint()
  //   ..color = const Color(0xFFDDDDDD)
  //   ..style = PaintingStyle.stroke
  //   ..strokeWidth = 1;
  // canvas.drawRect(Rect.fromLTWH(0.5, 0.5, widthPx - 1.0, heightPx - 1.0), border);

  final picture = recorder.endRecording();
  final img = await picture.toImage(widthPx, heightPx);
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

/// اطبع صف كصورة
Future<void> printRowAsImage(List<PrintableCell> cells,double size, bool is_big) async {
  try {
    // ربط الطابعة
    // await SunmiPrinter.bindingPrinter();
    // await SunmiPrinter.initPrinter();
    // await SunmiPrinter.startTransactionPrint(true);

    // لو الطابعة 58مم غيّر العرض لـ 384
    final bytes = await renderRowAsPng(
      cells,
      widthPx:is_big?576 :384, // 576 لمعظم 80مم | 384 لـ 58مم
      // fontSize: 24, // جرّب 22-26 حسب كثافة الطابعة
        fontSize: size,
        rtl: true,
      drawDividers: true
    );

    await SunmiPrinter.printImage(bytes);
    //required specially for size 80mm (removing the lineWrap(1) will result on only printing on item from the loop only)
    // await SunmiPrinter.lineWrap(1);
    await SunmiPrinter.printText(" ",style: SunmiTextStyle(fontSize: 3));
    // await SunmiPrinter.exitTransactionPrint(true);
  } catch (e) {
    // في حال فشل، حاول إعادة الربط
    try {
      // await SunmiPrinter.bindingPrinter();
      await SunmiPrinter.printText('خطأ طباعة: $e');
    } catch (_) {}
  }
}

Future<void> printRowAsImageExternal(
    Printer printer,
    List<PrintableCell> cells,
    double size,
    bool is_big
    ) async {
  try {
    // 1. Generate the PNG bytes
    final Uint8List pngBytes = await renderRowAsPng(
        cells,
        widthPx: is_big ? 576 : 384,
        fontSize: size,
        rtl: true,
        drawDividers: false
    );

    final img.Image? decodedImage = img.decodeImage(pngBytes);
    if (decodedImage == null) return;

    // 2. Optimized Profile Loading (THE FIX)
    _cachedProfile ??= await CapabilityProfile.load();

    // 3. Prepare Generator using the cached profile
    final generator = Generator(PaperSize.mm80 , _cachedProfile!);

    // 4. Convert Image to Raster Bit Image
    List<int> escPosBytes = generator.image(decodedImage);

    // 5. Send to External Printer
    await printer.printEscPosCommands(Uint8List.fromList(escPosBytes));

  } catch (e) {
    print("❌ External Print Error: $e");
  }
}
