import 'package:abyadpos_tab/core/constants/image_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class AppValueConstants {
  static GlobalKey<NavigatorState> globalKey = GlobalKey<NavigatorState>();
}

class StringConstants {
  static String appVersion = 'V1.0.1';
  static String appName = 'Abyad PoS';
  static String user = 'Fouad';
  static String randomNumber = '031123';
  static String phoneNumber = '966 | 55 -123- 4567';
  static String amount = '5000';
  static String ironing = 'Ironing';
  static String cleaningIroning = 'Cleaning & Ironing';
  static String sar = 'SAR';
  static String number = '55-123-4545';
  static String code = '966';
  static String abyadPhone = '966 - 55 45 66 78';
  static String abyadEmail = 'Abyad@gmail.com';
  static String dateOfBirthDateServerFormat = "MMMM dd , yyyy";
  static String mapKey = "AIzaSyB6ctTm6VdVTQb7-KB4BaZY1oC6qjNkbFY";
  static String riyal = '\uFDFC'; // Unicode “﷼” sign

  static const String profileUrl =
      'https://images.unsplash.com/photo-1457449940276-e8deed18bfff?q=80&w=3540&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
  static const String termsAndCondistion = "https://abyad.sa/terms";
  static const String privicyPolicy = "https://abyad.sa/privacy-policy";
  static var copyRight = '© 2025 Abyad. All rights reserved.'.tr;

  static List<String> paths = [
    ImageConstants.received,
    ImageConstants.proccessing,
    ImageConstants.readyForDelivery,
    ImageConstants.pickedUpDelivery,
    ImageConstants.outForDelivery,
    ImageConstants.deliveredDelivery,
    ImageConstants.delivered,
    ImageConstants.nonDeliverable,
    ImageConstants.completed,
    ImageConstants.cancelled,
  ];
}
