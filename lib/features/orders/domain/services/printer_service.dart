import 'dart:convert';
import 'dart:ui' as ui; // 🟢 استيراد مكتبة الرسم
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter_pos_printer_platform_image_3_sdt/flutter_pos_printer_platform_image_3_sdt.dart';
import 'dart:ui' as ui;
import 'package:abyadpos_tab/features/orders/domain/services/order_utils.dart';
import 'package:abyadpos_tab/features/settings/data/models/Items_bill_model.dart';
import 'package:abyadpos_tab/features/settings/data/models/collection_bill_model.dart';
import 'package:abyadpos_tab/core/storage/sharedpref.dart';
import 'package:abyadpos_tab/core/constants/image_constants.dart';
import 'package:abyadpos_tab/features/home/data/models/clothes_model.dart';
import 'package:abyadpos_tab/features/orders/data/models/order_model.dart';
import 'package:abyadpos_tab/features/settings/data/models/pos_stats_response.dart';
import 'package:abyadpos_tab/features/auth/data/models/user_model.dart';
import 'package:abyadpos_tab/core/utils/print_text_as_image.dart';
import 'package:abyadpos_tab/core/widgets/ui_helpers.dart';

class PrinterService {
  final String printerName = "TA-900U";

  Future<String?> _sendToWindowsPrinter(List<int> bytes) async {
    var printerManager = PrinterManager.instance;

    try {
      bool isConnected = await printerManager.connect(
        type: PrinterType.usb,
        model: UsbPrinterInput(name: printerName),
      );

      if (isConnected) {
        printerManager.send(type: PrinterType.usb, bytes: bytes);
        await Future.delayed(const Duration(seconds: 1));
        await printerManager.disconnect(type: PrinterType.usb);
        return null;
      } else {
        return "لم يتم العثور على الطابعة: '$printerName'. تأكد من الاسم والتوصيل.";
      }
    } catch (e) {
      await printerManager.disconnect(type: PrinterType.usb);
      return "Exception: ${e.toString()}";
    }
  }

  Future<Uint8List?> getNetworkImageBytes(String? url) async {
    if (url == null || url.isEmpty) return null;
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (e) {
      debugPrint("Error downloading logo: $e");
    }
    return null;
  }

  Future<String> getLogoImageBase64() async {
    final ByteData data = await rootBundle.load(ImageConstants.dummy_logo_small);
    final Uint8List bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    return base64Encode(bytes);
  }

  // =========================================================================
  // 🟢 دوال سحرية لتحويل النصوص والصفوف العربية إلى صور (Raster Images)
  // =========================================================================

  // 1. نص سطر واحد (عناوين، ملاحظات، إلخ)
  Future<List<int>> _arabicTextToBytes(Generator generator, String text,
      {double fontSize = 24, TextAlign align = TextAlign.center, bool isBold = false}) async {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
          color: Colors.black,
          fontSize: fontSize,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontFamily: 'Cairo'),
    );

    final textPainter =
        TextPainter(text: textSpan, textDirection: ui.TextDirection.rtl, textAlign: align);
    textPainter.layout(minWidth: 576, maxWidth: 576); // 576 هو العرض القياسي لطابعات 80mm

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    canvas.drawRect(
        Rect.fromLTWH(0, 0, 576, textPainter.height + 10), Paint()..color = Colors.white);
    textPainter.paint(canvas, const Offset(0, 5));

    final picture = pictureRecorder.endRecording();
    final uiImage = await picture.toImage(576, (textPainter.height + 10).toInt());
    final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
    final img.Image? decodedImage = img.decodeImage(byteData!.buffer.asUint8List());

    return generator.imageRaster(decodedImage!, align: PosAlign.center);
  }

  // 2. صف بـ 3 أعمدة (السعر | الكمية | الصنف)
  Future<List<int>> _arabicRowToBytes(Generator generator, String price, String qty, String name,
      {bool isBold = false}) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    const double width = 576;
    const double height = 40;

    canvas.drawRect(const Rect.fromLTWH(0, 0, width, height), Paint()..color = Colors.white);
    final TextStyle textStyle = TextStyle(
        color: Colors.black,
        fontSize: 24,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        fontFamily: 'Cairo');

    // الصنف يمين
    final namePainter = TextPainter(
        text: TextSpan(text: name, style: textStyle), textDirection: ui.TextDirection.rtl)
      ..layout(maxWidth: 300);
    namePainter.paint(canvas, Offset(width - namePainter.width - 10, 5));

    // الكمية وسط
    final qtyPainter = TextPainter(
        text: TextSpan(text: qty, style: textStyle), textDirection: ui.TextDirection.rtl)
      ..layout();
    qtyPainter.paint(canvas, Offset((width - qtyPainter.width) / 2, 5));

    // السعر يسار
    final pricePainter = TextPainter(
        text: TextSpan(text: price, style: textStyle), textDirection: ui.TextDirection.ltr)
      ..layout();
    pricePainter.paint(canvas, const Offset(10, 5));

    final picture = pictureRecorder.endRecording();
    final uiImage = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
    final img.Image? decodedImage = img.decodeImage(byteData!.buffer.asUint8List());

    return generator.imageRaster(decodedImage!, align: PosAlign.center);
  }

  // 3. صف بعمودين (القيمة | العنوان) مثل (المجموع | 100)
  Future<List<int>> _arabicTwoColumnsToBytes(Generator generator, String value, String label,
      {bool isBold = false}) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    const double width = 576;
    const double height = 40;

    canvas.drawRect(const Rect.fromLTWH(0, 0, width, height), Paint()..color = Colors.white);
    final TextStyle textStyle = TextStyle(
        color: Colors.black,
        fontSize: 24,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        fontFamily: 'Cairo');

    // العنوان يمين
    final labelPainter = TextPainter(
        text: TextSpan(text: label, style: textStyle), textDirection: ui.TextDirection.rtl)
      ..layout();
    labelPainter.paint(canvas, Offset(width - labelPainter.width - 10, 5));

    // القيمة يسار
    final valuePainter = TextPainter(
        text: TextSpan(text: value, style: textStyle), textDirection: ui.TextDirection.ltr)
      ..layout();
    valuePainter.paint(canvas, const Offset(10, 5));

    final picture = pictureRecorder.endRecording();
    final uiImage = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
    final img.Image? decodedImage = img.decodeImage(byteData!.buffer.asUint8List());

    return generator.imageRaster(decodedImage!, align: PosAlign.center);
  }

  // =========================================================================
  // 🟢 دوال الطباعة الرئيسية
  // =========================================================================

  Future<void> printBill(BuildContext context, Order model, bool isArabic, UserModel? userModel,
      ClothsModel? allClothsModel) async {
    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      List<int> bytes = [];

      var isVat = userModel?.data.vat_enabled ?? false;
      final isLoan = model.paymentDetails?.paymentTypeAr == "دين";

      var img_src = userModel?.data.logo;
      if (img_src != null) {
        Uint8List? logoBytes = await getNetworkImageBytes(img_src);
        if (logoBytes != null) {
          final img.Image? decodedLogo = img.decodeImage(logoBytes);
          if (decodedLogo != null) {
            img.Image whiteBackground =
                img.Image(width: decodedLogo.width, height: decodedLogo.height)
                  ..clear(img.ColorRgba8(255, 255, 255, 255));
            img.compositeImage(whiteBackground, decodedLogo);
            img.Image resizedLogo = img.copyResize(whiteBackground,
                width: 280, interpolation: img.Interpolation.average);
            img.Image grayscaleLogo = img.grayscale(resizedLogo);
            bytes += generator.imageRaster(grayscaleLogo, align: PosAlign.center);
            bytes += generator.emptyLines(1);
          }
        }
      }

      if (model.prepaid) {
        bytes += await _arabicTextToBytes(generator, 'مدفوعة', isBold: true, fontSize: 32);
        String pType = model.paymentDetails?.paymentTypeAr ?? "غير محدد";
        bytes += await _arabicTextToBytes(generator, 'طريقة الدفع: $pType', isBold: true);
        bytes += generator.emptyLines(1);
      }

      bytes += await _arabicTextToBytes(generator, 'رقم الفاتورة: ${UIHelper().cleanId(model.id)}',
          isBold: true, fontSize: 28);
      bytes += await _arabicTextToBytes(generator, 'مغسلة ${userModel?.data.laundryNameAr ?? ""}',
          isBold: true);

      if (userModel?.data.address != null) {
        bytes += await _arabicTextToBytes(generator, '${userModel?.data.address}');
      }
      if (userModel?.data.phone != null && userModel?.data.phone != "") {
        bytes += await _arabicTextToBytes(generator, '${userModel?.data.phone}');
      }

      bytes += generator.emptyLines(1);
      bytes += await _arabicTextToBytes(generator,
          'التاريخ: ${DateFormat("yyyy-MM-dd hh:mm a").format(DateTime.parse(model.createdAt.toString()))}');

      if (isVat) {
        bytes +=
            await _arabicTextToBytes(generator, 'الرقم الضريبي: ${userModel!.data.vat_number}');
      }

      if (model.user != null) {
        bytes += generator.emptyLines(1);
        if (model.user.userName != "")
          bytes += await _arabicTextToBytes(generator, 'العميل: ${model.user.userName}',
              align: TextAlign.right);
        if (model.user.mobile != "")
          bytes += await _arabicTextToBytes(generator, 'الجوال: ${model.user.mobile}',
              align: TextAlign.right, isBold: true);
        if (model.order_details != "" && model.order_details.isNotEmpty) {
          bytes += await _arabicTextToBytes(generator, 'ملاحظات: ${model.order_details}',
              align: TextAlign.right);
        }
      }

      bytes += generator.hr();

      bytes += await _arabicRowToBytes(generator, isVat ? 'السعر شامل' : 'السعر', 'الكمية', 'الصنف',
          isBold: true);
      bytes += generator.hr();

      for (Clothe item in model.clothes) {
        Cloth? cloth = allClothsModel?.data.clothes
            .firstWhere((e) => e.id == item.clothId, orElse: () => throw Exception('Not found'));
        if (cloth != null) {
          double price = double.tryParse(item.clothPrice) ?? 0.0;
          if (!item.isCustomized!) {
            price = price * item.clothCount;
          } else if (item.custom_price_per_unit != null) {
            price = (double.tryParse(item.custom_price_per_unit ?? "0") ?? 0.0) * item.clothCount;
          } else {
            price = double.tryParse(item.totalCustomPrice ?? "0") ?? 0.0;
          }

          bytes += await _arabicRowToBytes(generator, price.toStringAsFixed(2),
              item.clothCount.toString(), cloth.nameAr.toString());

          String service_name = item.onlyIroning == true
              ? "كوي فقط"
              : (item.only_cleaning == true ? "غسيل فقط" : "غسيل وكوي");
          bytes += await _arabicTextToBytes(
              generator, '($service_name - ${item.serviceType.labelAr})',
              align: TextAlign.right, fontSize: 20);

          if (item.details != null && item.details != "" && item.details != "null") {
            bytes += await _arabicTextToBytes(generator, '- ${item.details}',
                align: TextAlign.right, fontSize: 20);
          }
        }
      }

      bytes += generator.hr();

      bytes += await _arabicTwoColumnsToBytes(generator, '${model.totalItemCount}', 'عدد العناصر:',
          isBold: true);

      if (isVat) {
        var total_f =
            double.tryParse(model.finalTotalPrice) ?? double.tryParse(model.totalPrice) ?? 0.0;
        double rawSubtotal = total_f / 1.15;
        double subtotal = (rawSubtotal * 100).floor() / 100;
        double vat = double.parse((total_f - subtotal).toStringAsFixed(2));

        bytes +=
            await _arabicTwoColumnsToBytes(generator, '${subtotal.toStringAsFixed(2)}', 'المجموع:');
        bytes += await _arabicTwoColumnsToBytes(
            generator, '${vat.toStringAsFixed(2)}', 'الضريبة (15%):');
      }

      if (model.paymentDetails?.walletTransaction != null &&
          model.paymentDetails!.walletTransaction!.isNotEmpty) {
        bytes += await _arabicTwoColumnsToBytes(generator,
            '${model.paymentDetails!.walletTransaction![0].amount}-', 'المخصوم من المحفظة:');
      }

      bytes += generator.emptyLines(1);
      bytes += await _arabicTwoColumnsToBytes(
          generator, '${model.finalTotalPrice} SAR', 'الإجمالي:',
          isBold: true);

      if (isLoan && model.paymentDetails != null) {
        bytes += await _arabicTwoColumnsToBytes(
            generator, '${model.paymentDetails?.customer_total_loan} SAR', 'ديون العميل:',
            isBold: true);
      }

      if (model.invoice_url != null && model.invoice_url.isNotEmpty) {
        bytes += generator.emptyLines(1);
        bytes += generator.qrcode(model.invoice_url, size: QRSize.size6, cor: QRCorrection.H);
      }

      bytes += generator.emptyLines(2);
      if (userModel?.data.bill_footer_ar != null && userModel?.data.bill_footer_ar != "") {
        bytes += await _arabicTextToBytes(generator, '${userModel!.data.bill_footer_ar}');
      }
      bytes += await _arabicTextToBytes(generator, 'الفاتورة صادرة من نظام أبيض');
      bytes += generator.emptyLines(3);

      bytes += generator.drawer();
      bytes += generator.cut();

      String? errorMessage = await _sendToWindowsPrinter(bytes);

      if (context.mounted) {
        if (errorMessage == null) {
          UIHelper.showBottomFlash(context,
              title: "Printed", message: "تمت الطباعة بنجاح", isError: false);
        } else {
          UIHelper.showBottomFlash(context,
              title: "Printer Error", message: errorMessage, isError: true);
        }
      }
    } catch (e) {
      if (context.mounted) {
        UIHelper.showBottomFlash(context,
            title: "Data Error", message: "خطأ في معالجة الفاتورة: ${e.toString()}", isError: true);
      }
    }
  }

  Future<void> smartPrintBillsCollectionPayments(
      BuildContext context, CollectionBillModel model, bool isArabic) async {
    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      List<int> bytes = [];

      bytes += await _arabicTextToBytes(generator, 'سند قبض', isBold: true, fontSize: 32);
      bytes += generator.hr();

      if (model.data != null) {
        bytes += await _arabicTwoColumnsToBytes(generator, '${model.data!.customerName}', 'العميل:',
            isBold: true);
        bytes += await _arabicTwoColumnsToBytes(
            generator, '${model.data!.customerPhone}', 'الجوال:',
            isBold: true);

        bytes += generator.emptyLines(1);

        bytes += await _arabicTwoColumnsToBytes(
            generator, '${model.data!.totalSum} SAR', 'المبلغ المدفوع:',
            isBold: true);
        bytes += await _arabicTwoColumnsToBytes(generator, '${model.data!.type}', 'طريقة الدفع:');
        bytes += await _arabicTwoColumnsToBytes(
            generator, '${DateFormat("yyyy-MM-dd HH:mm").format(DateTime.now())}', 'التاريخ:');
      }

      bytes += generator.hr();
      bytes += await _arabicTextToBytes(generator, 'الفاتورة صادرة من نظام أبيض');
      bytes += generator.emptyLines(3);

      bytes += generator.drawer();
      bytes += generator.cut();

      String? errorMessage = await _sendToWindowsPrinter(bytes);

      if (context.mounted) {
        if (errorMessage == null) {
          UIHelper.showBottomFlash(context,
              title: "Success", message: "تم طباعة السند بنجاح", isError: false);
        } else {
          UIHelper.showBottomFlash(context,
              title: "Printer Error", message: errorMessage, isError: true);
        }
      }
    } catch (e) {
      if (context.mounted) {
        UIHelper.showBottomFlash(context,
            title: "Data Error", message: e.toString(), isError: true);
      }
    }
  }

  Future<void> onBalancingSuccessPrint(
      Settlement? settlementSnapshot, UserModel? userModel, bool isArabic,
      {BuildContext? context}) async {
    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      List<int> bytes = [];

      DateTime now = DateTime.now();
      String formattedDate = DateFormat("dd-MM-yyyy hh:mm a").format(now);

      bytes += await _arabicTextToBytes(generator, 'تقرير التسوية', isBold: true, fontSize: 32);
      bytes += await _arabicTextToBytes(generator, 'مغسلة ${userModel?.data.laundryNameAr ?? ""}',
          isBold: true);
      bytes += await _arabicTextToBytes(generator, formattedDate);
      bytes += generator.hr();

      final breakdown = settlementSnapshot?.nearpayBreakdown?.byCardType;
      double madaAmount = (breakdown?.mada?.amount ?? 0.0) + (breakdown?.unknown?.amount ?? 0.0);
      double visaAmount = breakdown?.visa?.amount ?? 0.0;
      double masterAmount = breakdown?.mastercard?.amount ?? 0.0;
      double amexAmount = breakdown?.amex?.amount ?? 0.0;
      double totalPendingValue = settlementSnapshot?.unrequestedAmount ?? 0.0;

      if (madaAmount > 0)
        bytes += await _arabicTwoColumnsToBytes(generator, madaAmount.toStringAsFixed(2), 'مدى:');
      if (visaAmount > 0)
        bytes += await _arabicTwoColumnsToBytes(generator, visaAmount.toStringAsFixed(2), 'فيزا:');
      if (masterAmount > 0)
        bytes += await _arabicTwoColumnsToBytes(
            generator, masterAmount.toStringAsFixed(2), 'ماستركارد:');
      if (amexAmount > 0)
        bytes += await _arabicTwoColumnsToBytes(
            generator, amexAmount.toStringAsFixed(2), 'أمريكان إكسبريس:');

      bytes += generator.hr();
      bytes += await _arabicTwoColumnsToBytes(
          generator, totalPendingValue.toStringAsFixed(2), 'الإجمالي:',
          isBold: true);

      bytes += generator.emptyLines(2);
      bytes += await _arabicTextToBytes(generator, 'الفاتورة صادرة من نظام أبيض');
      bytes += generator.emptyLines(3);
      bytes += generator.cut();

      String? errorMessage = await _sendToWindowsPrinter(bytes);

      if (context != null && context.mounted && errorMessage != null) {
        UIHelper.showBottomFlash(context,
            title: "Settlement Print Error", message: errorMessage, isError: true);
      } else if (errorMessage != null) {
        debugPrint("Settlement Print Error: $errorMessage");
      }
    } catch (e) {
      debugPrint("Settlement Logic Error: $e");
    }
  }

  Future<void> printBillsItemsCollection(
      BuildContext context, ItemsBillModel model, bool isArabic) async {
    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      List<int> bytes = [];

      bytes += await _arabicTextToBytes(generator, 'فاتورة مجمعة', isBold: true, fontSize: 32);
      bytes += generator.hr();

      var total_orders = model.data?.totalOrders ?? 0;
      var total_amount = model.data?.totalAmount ?? 0.0;

      bytes += await _arabicTwoColumnsToBytes(generator, '$total_orders', 'إجمالي الطلبات:');
      bytes += await _arabicTwoColumnsToBytes(generator, '$total_amount SAR', 'المبلغ الإجمالي:',
          isBold: true);

      bytes += generator.emptyLines(3);
      bytes += await _arabicTextToBytes(generator, 'الفاتورة صادرة من نظام أبيض');
      bytes += generator.emptyLines(3);
      bytes += generator.cut();

      String? errorMessage = await _sendToWindowsPrinter(bytes);

      if (context.mounted) {
        if (errorMessage != null) {
          UIHelper.showBottomFlash(context,
              title: "Printer Error", message: errorMessage, isError: true);
        }
      }
    } catch (e) {
      if (context.mounted) {
        UIHelper.showBottomFlash(context, title: "Error", message: e.toString(), isError: true);
      }
    }
  }

  Future<void> smartPrintBill(BuildContext context, Order order, bool isArabic,
      UserModel? userModel, ClothsModel? cloths) async {
    await printBill(context, order, isArabic, userModel, cloths);
  }

  Future<void> smartSettlementPrint(BuildContext context, Settlement? settlementSnapshot,
      UserModel? userModel, bool isArabic) async {
    await onBalancingSuccessPrint(settlementSnapshot, userModel, isArabic, context: context);
  }

  Future<void> smartPrintBillsCollectionItems(
      BuildContext context, ItemsBillModel itemsBill, bool isArabic) async {
    await printBillsItemsCollection(context, itemsBill, isArabic);
  }
}
