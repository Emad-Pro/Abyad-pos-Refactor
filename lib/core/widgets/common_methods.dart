import 'dart:io';

import 'package:abyadpos_tab/core/constants/app_value_constants.dart';
import 'package:abyadpos_tab/core/theme/app_colors.dart';
import 'package:abyadpos_tab/core/utils/logger_util.dart';
import 'package:abyadpos_tab/core/widgets/snackbar_widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:url_launcher/url_launcher.dart';

class CommonMethods {
  static String emailRegExp =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  static String nameRegExp = r'^.{2,70}$';
  static String passRegExp =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_])[\S ]{8,}$';

  /// Method for Hiding Keyboard from any where
  static hideKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  ///  Method for date picker
  static Future<void> selectDateOfBirth(BuildContext context, DateTime? initial,
      String lang, Function(DateTime?) onChange) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
            ), dialogTheme: DialogThemeData(backgroundColor: Colors.blue[900]),
          ),
          child: child!,
        );
      },
      locale: Locale(lang),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    onChange(selectedDate);
  }

  /// Method for Monitor network state
  static Future<bool> checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    } else {
      return true;
    }
  }

  ///  Method for getting App version
  static Future<String> getPlatformVersion() async {
    String version = "1.0.0";
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = Platform.isAndroid ? packageInfo.version : packageInfo.version;
    return version;
  }

  ///  Method for getting Device Info
  static Future<String> getDeviceInfo() async {
    String appDevice = "";
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidDeviceInfo =
          await DeviceInfoPlugin().androidInfo;
      appDevice = androidDeviceInfo.model;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await DeviceInfoPlugin().iosInfo;
      appDevice = iosDeviceInfo.name;
    }

    return appDevice;
  }

  ///  Method for getting Android versions
  static Future<int> getAndroidVersion() async {
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidDeviceInfo =
          await DeviceInfoPlugin().androidInfo;
      logger.log(
        "androidDeviceInfo.version.sdkInt: ${androidDeviceInfo.version.sdkInt}",
      );
      return androidDeviceInfo.version.sdkInt;
    } else {
      return 0;
    }
  }

  ///  Method for requesting permission for gallery in android and ios
  static Future<Permission?> getGalleryPermission() async {
    if (Platform.isAndroid && await CommonMethods.getAndroidVersion() < 33) {
      return Permission.storage;
    } else {
      return Permission.photos;
    }
  }

  ///  Method for getting picked image size
  static Future<bool> imageSize(XFile file) async {
    final bytes = (await file.readAsBytes()).lengthInBytes;
    final kb = bytes / 1024;
    final mb = kb / 1024;

    logger.e("IMAGE SIZE ----$mb");

    if (mb <= 15) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> askPermission({
    Permission? permission,
    String? whichPermission,
  }) async {
    bool isPermissionGranted = await permission!.isGranted;
    var shouldShowRequestRationale =
        await permission.shouldShowRequestRationale;

    if (isPermissionGranted) {
      return true;
    } else {
      if (!shouldShowRequestRationale) {
        var permissionStatus = await permission.request();
        logger.e("STATUS == $permissionStatus");
        if (permissionStatus.isPermanentlyDenied) {
          // todo: show dialog of open setting
          return false;
        }
        if (permissionStatus.isGranted || permissionStatus.isLimited) {
          return true;
        } else {
          return false;
        }
      } else {
        var permissionStatus = await permission.request();
        if (permissionStatus.isGranted || permissionStatus.isLimited) {
          return true;
        } else {
          return false;
        }
      }
    }
  }

  static Future<void> openLink({
    String urlPath = "",
    String urlScheme = "",
  }) async {
    Uri url;
    if (urlScheme != "") {
      url = Uri(scheme: urlScheme, path: urlPath);
    } else {
      if (urlPath.startsWith("http")) {
        url = Uri.parse(urlPath);
      } else {
        url = Uri.https(urlPath);
      }
    }

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        showTopSnackbar(
            AppValueConstants.globalKey.currentContext!, "launchError".tr);
      }
    } catch (e) {
      logger.e("ERROR open link: $e");
    }
  }
}
