import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class OrderUtils {
  static String determineSearchType(String input) {
    final s = input.trim();
    final orderIdPrefix = RegExp(r'^ord-\d+$', caseSensitive: false);
    if (orderIdPrefix.hasMatch(s)) return 'order_id';

    final phoneRE = RegExp(r'^(?:\+9665|05)\d{8}$');
    if (phoneRE.hasMatch(s)) return 'customer_phone';

    final numericRE = RegExp(r'^\d+$');
    if (numericRE.hasMatch(s)) return 'order_id';

    return 'customer_name';
  }

  static String rtl(String text) {
    return '\u202B$text\u202C';
  }

  static Map<String, double> calculateVatFromTotal(double total, {double rate = 0.15}) {
    double rawSubtotal = total / (1 + rate);
    double subtotal = (rawSubtotal * 100).floor() / 100;
    double vat = double.parse((total - subtotal).toStringAsFixed(2));
    return {
      "subtotal": subtotal,
      "vat": vat,
      "total": total,
    };
  }

  static String fixAmPmPosition(String formattedTime) {
    List<String> parts = formattedTime.split(" ");
    if (parts.length < 2) return formattedTime;
    String period = parts[0];
    String time = parts.sublist(1).join(" ");
    return "$time $period";
  }

  static Future<String> generateQRCodeString(String data, double size) async {
    final qrPainter = QrPainter(
      data: data,
      version: QrVersions.auto,
      gapless: false,
      color: Colors.black,
      emptyColor: Colors.white,
    );
    final picData = await qrPainter.toImageData((size * 100).toInt() as double);
    final bytes = picData!.buffer.asUint8List();
    return base64Encode(bytes);
  }

  static List<String> splitByLength(String text, int maxLength) {
    List<String> chunks = [];
    List<String> words = text.split(' ');
    String currentChunk = "";

    for (String word in words) {
      if ((currentChunk.length + word.length + 1) <= maxLength) {
        currentChunk += (currentChunk.isEmpty ? "" : " ") + word;
      } else {
        if (currentChunk.isEmpty) {
          chunks.add(word);
        } else {
          chunks.add(currentChunk);
          currentChunk = word;
        }
      }
    }
    if (currentChunk.isNotEmpty) {
      chunks.add(currentChunk);
    }
    return chunks;
  }

  Future<String> getDeviceHardwareName() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.product.startsWith('V3')) {
        return "V";
      } else {
        return "D";
      }
    } else if (Platform.isWindows) {
      // جلب معلومات الويندوز إذا لزم الأمر
      WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;
      return "W"; // أرسل الحرف أو الكود المخصص للويندوز للباك اند
    }

    return "D";
  }
}
