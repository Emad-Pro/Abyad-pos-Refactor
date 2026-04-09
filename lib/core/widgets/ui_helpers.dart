import 'dart:io';
import 'dart:math';

import 'package:abyadpos_tab/features/orders/presentation/controllers/order_cubit.dart';
import 'package:abyadpos_tab/core/theme/app_colors.dart';
import 'package:abyadpos_tab/core/theme/font_constants.dart';
import 'package:abyadpos_tab/main.dart';
import 'package:abyadpos_tab/core/widgets/common_text.dart';
import 'package:abyadpos_tab/core/widgets/custom_button.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide Transition;
// import 'package:flash/flash.dart';
import 'dart:ui' as ui;
import 'package:toastification/toastification.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:abyadpos_tab/core/constants/image_constants.dart';
import 'package:abyadpos_tab/features/home/data/models/clothes_model.dart';
import 'package:abyadpos_tab/features/dashboard/presentation/controllers/drawer_cubit.dart';
import 'package:abyadpos_tab/features/dashboard/presentation/controllers/drawer_state.dart';
import 'package:abyadpos_tab/features/home/presentation/screens/home_screen.dart';
import 'package:abyadpos_tab/features/home/presentation/widgets/notification_menu.dart';
import 'package:abyadpos_tab/features/orders/presentation/screens/order_screen.dart';
import 'package:abyadpos_tab/features/settings/presentation/screens/settings_screen.dart';
import 'package:abyadpos_tab/core/utils/updater_service.dart';
import 'package:abyadpos_tab/core/widgets/common_widgets.dart';
import 'package:abyadpos_tab/core/widgets/custom_drawer.dart';
import 'package:abyadpos_tab/core/widgets/loader/logo_animated_loading.dart';
// import 'package:webview_flutter/webview_flutter.dart';

/// Contains useful consts to reduce boilerplate and duplicate code
class UIHelper {
  // Vertical spacing constants. Adjust to your liking.
  static const double _VerticalSpaceSm = 10.0;
  static const double _VerticalSpaceSm1 = 5.0;

  static const double _VerticalSpaceMd = 20.0;
  static const double _VerticalSpace30 = 30.0;
  static const double _VerticalSpaceL = 42.0;
  static const double _VerticalSpaceXL = 92.0;

  // Vertical spacing constants. Adjust to your liking.
  static const double _HorizontalSpaceSm = 10.0;
  static const double _HorizontalSpaceMd = 20.0;
  static const double _HorizontalSpaceL = 60.0;
  static OverlayEntry? _overlayEntry;
  static const Widget verticalSpaceSm = SizedBox(height: _VerticalSpaceSm);
  static const Widget verticalSpaceSm1 = SizedBox(height: _VerticalSpaceSm1);

  static const Widget verticalSpaceMd = SizedBox(height: _VerticalSpaceMd);
  static const Widget verticalSpace30 = SizedBox(height: _VerticalSpace30);
  static const Widget verticalSpaceL = SizedBox(height: _VerticalSpaceL);
  static const Widget verticalSpaceXL = SizedBox(height: _VerticalSpaceXL);

  static const Widget horizontalSpaceSm = SizedBox(width: _HorizontalSpaceSm);
  static const Widget horizontalSpaceSm5 = SizedBox(width: 5.0);
  static const Widget horizontalSpaceSm3 = SizedBox(width: 3.0);

  static const Widget horizontalSpaceMd = SizedBox(width: _HorizontalSpaceMd);
  static const Widget horizontalSpaceL = SizedBox(width: _HorizontalSpaceL);
  static final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showMySnak({var title, var message, bool? isError}) {
    if (isError!) {
      Get.snackbar(title, message, backgroundColor: Colors.red, colorText: Colors.white);
    } else {
      Get.snackbar(title, message, backgroundColor: Colors.green, colorText: Colors.white);
    }
  }

  // static FlashController? ccontroller;

  static void hideKeyboard(BuildContext context) {
    print("hideKeyboard oifjfjca");
    FocusScope.of(context).unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  static String getCurrencyFormate(text) {
    final oCcy = new NumberFormat("#,##0.00", "en_US");
    return oCcy.format(int.parse(text));
  }

  static void showErrorSnackbar(String message) {
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 20),
      ),
    );
  }

  static void showSuccessSnackbar(String message) {
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void showLoading(BuildContext context, {String? feedback}) {
    showDialog(
      context: context,
      barrierDismissible: false, // cannot dismiss by tapping outside
      builder: (_) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const LogoAnimatedLoading(
                color: AppColors.primaryColor,
              ),
              if (feedback != null) ...[
                const SizedBox(height: 8),
                Text(
                  feedback,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void hideLoading(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  void goToMenu(BuildContext context, SideMenuItem item) {
    // 1. الوصول للكيوبت
    final cubit = context.read<SideMenuCubit>();

    // 2. التحقق إذا كان العنصر المختار هو نفس العنصر الحالي لمنع إعادة التوجيه
    if (cubit.state.selectedItem == item) return;

    // 3. تحديث الحالة في الكيوبت
    cubit.changeMenuItem(item);

    // 4. التنقل للشاشة المطلوبة (يفضل استخدام noTransition للقوائم الجانبية)
    switch (item) {
      case SideMenuItem.home:
        Get.offAll(() => HomeScreen(reload: false), transition: Transition.noTransition);
        break;
      case SideMenuItem.orders:
        Get.offAll(() => OrderScreen(isCurrent: true, key: UniqueKey()),
            transition: Transition.noTransition);
        break;
      case SideMenuItem.invoices:
        Get.offAll(() => OrderScreen(isCurrent: false, key: UniqueKey()),
            transition: Transition.noTransition);
        break;
      case SideMenuItem.settings:
        Get.offAll(() => const SettingsScreen(), transition: Transition.noTransition);
        break;
    }
  }

  static String formatNumberText(double number) {
    if (number >= 1000000) {
      double result = number / 1000000.0;
      return '${result.toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      double result = number / 1000.0;
      return '${result.toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  static void showBottomFlash(
    BuildContext context, {
    required String title,
    required String message,
    required bool isError,
    bool persistent = true,
    EdgeInsets margin = EdgeInsets.zero,
  }) {
    // Use the global context if the local one is null or unmounted
    final targetContext = context.mounted ? context : navigatorKey.currentContext;

    if (targetContext == null) return;

    final width = MediaQuery.of(targetContext).size.width;
    // Mimic your 30% margin logic for tablets/large screens
    //  final horizontalMargin = width > 600 ? width * 0.3 : 16.0;

    toastification.show(
      context: targetContext,
      type: isError ? ToastificationType.error : ToastificationType.success,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 3),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: FontFamilyConstants.epilogue,
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      description: Text(
        message,
        style: TextStyle(fontFamily: FontFamilyConstants.epilogue),
      ),
      alignment: Alignment.topCenter, // This puts it at Top/Center
      direction: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      animationDuration: const Duration(milliseconds: 300),
      // margin: EdgeInsets.symmetric(
      //   horizontal: horizontalMargin,
      //   vertical: 8,
      // ),
      // Replicating your indicator color
      primaryColor: isError ? Colors.red : AppColors.primaryColor,
      backgroundColor: Colors.white,
      foregroundColor: AppColors.blackColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      showProgressBar: false,
      closeButtonShowType: CloseButtonShowType.always,
      closeOnClick: true,
      pauseOnHover: true,
      dragToClose: true,
    );
  }

  static launchInBrowser1(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }

  static Widget buildPlaceHolderImage(double? borderRadius, double? height, double? width) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 0),
      child: Center(
        child: Image.asset(
          ImageConstants.profile,
          width: width ?? double.infinity,
          height: height ?? double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  static showDialogOk(context, {required title, required message, onOk, onConfirm, onOkAction}) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            child: Container(
              width: isMobile ? Get.width : Get.width * 0.5,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                // gradient: LinearGradient(
                //   begin: Alignment(-0.71, 0.94),
                //   end: Alignment(0.8, -0.82),
                //   colors: [
                //     const Color(0xFFFFFFFF),
                //     const Color(0xFF000000),
                //     const Color(0xFFFFFFFF),
                //   ],
                //   stops: [0.0, 0.03, 1.0],
                // ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CommonText(
                    text: title,
                    fontSize: 22.0,
                  ),
                  UIHelper.verticalSpaceSm,
                  CommonText(
                    text: message,
                    fontSize: 16.0,
                  ),
                  UIHelper.verticalSpaceMd,
                  onOk != null
                      ? Container(
                          width: 150,
                          child: CustomButton(
                            onOk ??
                                () {
                                  Get.back();
                                },
                            text: "Ok",
                            textcolor: Colors.white,
                            buttonBorderColor: Colors.transparent,
                            circleRadius: 25.0,
                          ),
                        )
                      : Container(),
                  onConfirm != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 120,
                              child: CustomButton(
                                () {
                                  Get.back();
                                },
                                text: "Cancel".tr,
                                textcolor: Colors.white,
                                buttonBorderColor: Colors.transparent,
                                circleRadius: 25.0,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            UIHelper.horizontalSpaceMd,
                            Container(
                              width: 120,
                              child: CustomButton(
                                onConfirm,
                                text: "Confirm".tr,
                                textcolor: Colors.white,
                                buttonBorderColor: Colors.transparent,
                                circleRadius: 25.0,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ],
                        )
                      : Container()
                ],
              ),
            ),
          );
        });
  }

  Future<void> showUpdateDialog(BuildContext context, String url,
      {required bool force, required String message, required String version}) async {
    final updater = UpdaterService();

    // SAFETY CHECK: If already downloading this version, just show the UI widget and don't open a second dialog
    if (updater.isUpdating) {
      UIHelper.showFloatingDownloadWidget(updater, url, version: version);
      return;
    }

    return showDialog(
      context: context,
      // If it's a forced update, the user CANNOT dismiss by tapping outside
      barrierDismissible: !force,
      builder: (ctx) {
        return WillPopScope(
          // Prevents the back button from closing the dialog if it's a forced update
          onWillPop: () async => !force,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Icon(Icons.system_update, color: Colors.blue),
                const SizedBox(width: 10),
                Text("update_available".tr,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Text("${"version".tr}: $version",
                    style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!force)
                      TextButton(
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20)),
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text("later".tr, style: const TextStyle(color: Colors.grey)),
                      ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 130,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () async {
                          // Close dialog immediately to prevent double-clicks
                          Navigator.of(ctx).pop();

                          // 1. Check disk first (DATA SAVER)
                          String? localPath = await updater.getReadyApkPath(version);

                          if (localPath != null) {
                            // File is 100% ready on disk. No data used.
                            updater.installUpdate(localPath);
                          } else {
                            // Not on disk. Start smart resumable download.
                            updater.downloadAndInstall(url, version);
                          }

                          // 2. Always show the floating widget so user sees status
                          UIHelper.showFloatingDownloadWidget(updater, url, version: version);
                        },
                        child: Text("update".tr, style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> showPrintAnotherBillDialog(
    BuildContext context, {
    required VoidCallback onYes,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: true, // user can tap outside to dismiss
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            "print_bill".tr,
            style: const TextStyle(fontSize: 22),
          ),
          content: Text(
            "print_another_bill_question".tr,
            style: const TextStyle(fontSize: 18),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  width: 100,
                  () {
                    Navigator.of(ctx).pop(); // just close the dialog
                  },
                  text: "no".tr,
                ),
                const SizedBox(width: 20),
                CustomButton(
                  width: 100,
                  () {
                    Navigator.of(ctx).pop(); // close the dialog
                    onYes(); // call the passed function
                  },
                  text: "yes".tr,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> openInChrome(String urlString) async {
    if (!Platform.isAndroid) return;

    final Uri intentUri =
        Uri.parse('intent://$urlString#Intent;scheme=https;package=com.android.chrome;end');

    try {
      if (await canLaunchUrl(intentUri)) {
        await launchUrl(intentUri, mode: LaunchMode.externalApplication);
      } else {
        // fallback to default browser
        final Uri url = Uri.parse(urlString);
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          throw 'Could not launch $urlString';
        }
      }
    } catch (e) {
      print('Error opening Chrome: $e');
    }
  }

  static const mapKey = "AIzaSyDVX6dMqw5wbVC1t47hNg3xOEuseEwmA_c";

//todo modify the theme
/* static ThemeData darkTheme = ThemeData(
    primaryColor: Colors.black,
    backgroundColor: Colors.grey[700],
    brightness: Brightness.dark,
  );
  static ThemeData lightTheme = ThemeData(
    primaryColor: Colors.red,
    accentColor: Colors.red[400],
    backgroundColor: Colors.grey[200],
    brightness: Brightness.light,
  );*/

  String formatCountCompact(int count) {
    if (count >= 1000000) {
      double value = count / 1000000;
      if (value >= 10) return '${value.toInt()}m'; // 10M, 12M
      return value.toStringAsFixed(1).replaceAll('.0', '') + 'm'; // 1M - 9.9M
    } else if (count >= 1000) {
      double value = count / 1000;
      if (value >= 100) return '${value.toInt()}k'; // 100K - 999K
      if (value >= 10) return value.toInt().toString() + 'k'; // 10K - 99K
      return value.toStringAsFixed(1).replaceAll('.0', '') + 'k'; // 1K - 9.9K
    } else {
      return count.toString();
    }
  }

  static void showFloatingDownloadWidget(UpdaterService updater, String url,
      {required String version}) {
    final ctx = navigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) return;

    _overlayEntry?.remove();
    _overlayEntry = OverlayEntry(
      builder: (context) {
        final screenSize = MediaQuery.of(context).size;
        return Positioned(
          bottom: 16,
          left: isArabic ? null : 16,
          right: isArabic ? 16 : null,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: screenSize.width * 0.30,
              constraints: const BoxConstraints(maxHeight: 220, minWidth: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: StreamBuilder<DownloadProgress>(
                stream: updater.progressStream,
                builder: (context, snapshot) {
                  // 1. Error
                  if (updater.hasError || snapshot.hasError) {
                    return _buildErrorState(updater, url, version);
                  }

                  // 2. Ready to Install (The Stream Finished)
                  if (snapshot.connectionState == ConnectionState.done) {
                    return _buildReadyState(updater, version);
                  }

                  // 3. Downloading
                  if (snapshot.hasData && updater.isUpdating) {
                    return _buildDownloadState(snapshot.data!);
                  }

                  // 4. Fallback / Preparing
                  return FutureBuilder<String?>(
                    future: updater.getReadyApkPath(version),
                    builder: (context, fileSnap) {
                      if (fileSnap.hasData && fileSnap.data != null) {
                        return _buildReadyState(updater, version);
                      }
                      return Center(child: Text("preparing_download".tr));
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
    navigatorKey.currentState?.overlay?.insert(_overlayEntry!);
  }

  /// --- RESTORED ORIGINAL UI COMPONENTS ---

  static Widget _buildDownloadState(DownloadProgress data) {
    // 🛡️ Safety: Prevents the progress bar from freezing/crashing on D3 Mini
    final double safePercent =
        (data.percent.isNaN || data.percent.isInfinite) ? 0.0 : data.percent.clamp(0.0, 1.0);

    final progress = (safePercent * 100).toStringAsFixed(1);
    final downloadedMB = (data.received / (1024 * 1024)).toStringAsFixed(1);
    final totalMB = (data.total / (1024 * 1024)).toStringAsFixed(1);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("downloading_update".tr,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const Icon(Icons.cloud_download, color: Colors.blue, size: 20),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: safePercent,
          minHeight: 8,
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
        const SizedBox(height: 8),
        Text(
          "$progress% ($downloadedMB / $totalMB MB)",
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ],
    );
  }

  int versionToNumber(String version) {
    try {
      // 1. Remove any non-numeric characters like 'v' (e.g., "v1.2.0" -> "1.2.0")
      String cleanVersion = version.toLowerCase().replaceAll('v', '').trim();

      // 2. Split by dots
      List<String> parts = cleanVersion.split('.');

      int major = 0;
      int minor = 0;
      int patch = 0;

      // 3. Assign parts if they exist
      if (parts.length > 0) major = int.tryParse(parts[0]) ?? 0;
      if (parts.length > 1) minor = int.tryParse(parts[1]) ?? 0;
      if (parts.length > 2) patch = int.tryParse(parts[2]) ?? 0;

      // 4. Calculate a unique weight
      // Major gets the highest weight, Patch the lowest.
      // Result for "1.2.14" becomes: (1 * 1,000,000) + (2 * 1,000) + 14 = 1,002,014
      return (major * 1000000) + (minor * 1000) + patch;
    } catch (e) {
      return 0;
    }
  }

  static Widget _buildErrorState(UpdaterService updater, String url, String version) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.signal_wifi_off, color: Colors.red, size: 28),
        const SizedBox(height: 8),
        Text("download_failed_please_retry".tr,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          // IMPORTANT: Retrying uses the RESUME logic automatically in downloadAndInstall
          onPressed: () => updater.downloadAndInstall(url, version),
          icon: const Icon(
            Icons.refresh,
            size: 18,
            color: Colors.white,
          ),
          label: Text(
            "re_download".tr,
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        ),
      ],
    );
  }

  static Widget _buildReadyState(UpdaterService updater, String version) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 28),
        const SizedBox(height: 8),
        Text("download_completed".tr, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              String? path = await updater.getReadyApkPath(version);
              if (path != null) {
                updater.installUpdate(path);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text("install_now".tr, style: const TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Future<String?> getSunmiSerial() async {
    if (!Platform.isAndroid) return null;

    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    // Android 10+ (API 29+) cannot get real serial, fallback to androidId
    if (androidInfo.version.sdkInt >= 29) {
      return androidInfo.id; // unique 64-bit hex string
    } else {
      // Android < 10, need READ_PHONE_STATE permission for real serial
      PermissionStatus status = await Permission.phone.status;
      if (!status.isGranted) {
        status = await Permission.phone.request();
        if (!status.isGranted) {
          print("⚠️ READ_PHONE_STATE permission denied");
          return null;
        }
      }
      print("device serial number:");
      return androidInfo.serialNumber; // may require READ_PHONE_STATE
    }
  }

  static void hideFloatingDownloadWidget() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  static Map<String, double> calculateVatFromTotal(double total, {double rate = 0.15}) {
    // حساب المبلغ قبل الضريبة
    double rawSubtotal = total / (1 + rate);

    // تقريب هابط إلى هللتين (Floor)
    double subtotal = (rawSubtotal * 100).floor() / 100;

    // الضريبة = الفرق (مضمونة تكون صحيحة 100%)
    double vat = double.parse((total - subtotal).toStringAsFixed(2));

    return {
      "subtotal": subtotal,
      "vat": vat,
      "total": total,
    };
  }

  static Future<String> getCleanVersionExact() async {
    final info = await PackageInfo.fromPlatform();
    return info.version.replaceAll('.', '');
  }

  static String getShortName({required String string, required int limitTo}) {
    var buffer = StringBuffer();

    // 1. Trim whitespace and split by one or more spaces
    var split = string.trim().split(RegExp(r'\s+'));

    // 2. Filter out any empty strings that might have resulted from the split
    var validParts = split.where((part) => part.isNotEmpty).toList();

    // 3. Loop based on your logic: up to 'limitTo' or available parts
    for (var i = 0; i < validParts.length && i < limitTo; i++) {
      // This is now safe because we verified 'part.isNotEmpty'
      buffer.write(validParts[i][0].toUpperCase());
    }

    // 4. Fallback if the result is still empty
    return buffer.isEmpty ? "?" : buffer.toString();
  }

  static bool isEmailValid(email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  static void updateValue(
    int newValue,
    BuildContext context,
    Cloth item, {
    bool express = false,
    bool onlyIroning = false,
    bool onlyCleaning = false,
    bool isCustomized = false,
    String? details,
    double? custom_price_per_unit,
    double? totalItemsPrice,
    String? serviceType,
    required void Function(VoidCallback fn) setStateCallback, // pass setState here
  }) {
    setStateCallback(() {
      if (express) {
        if (onlyIroning && item.supportIroning) {
          item.fclothCountesOnly = newValue;
          item.isSetOnlyIroning = true;
        } else {
          item.fclothCountes = newValue;
          item.isSetOnlyIroning = false;
        }
      } else {
        if (onlyIroning && item.supportIroning) {
          item.clothCountesOnly = newValue;
          item.isSetOnlyIroning = true;
        } else {
          item.clothCountes = newValue;
          item.isSetOnlyIroning = false;
        }
      }
    });

    final int updatedCount = express
        ? (item.isSetOnlyIroning == true
            ? (item.fclothCountesOnly ?? 0)
            : (item.fclothCountes ?? 0))
        : (item.isSetOnlyIroning == true ? (item.clothCountesOnly ?? 0) : (item.clothCountes ?? 0));

    final bool onlyIroningFlag = item.isSetOnlyIroning == true && item.supportIroning;

    context.read<OrderCubit>().updateSelection(
          cloth: item,
          count: updatedCount,
          onlyIroning: onlyIroning, // 👈 Pass the flag directly
          onlyCleaning: onlyCleaning,
          isCustomized: isCustomized,
          details: details,
          custom_price_per_unit: custom_price_per_unit,
          totalItemsPrice: totalItemsPrice,
          serviceType: isCustomized ? serviceType : (express ? "fast" : "normal"),
        );
  }

  Future<void> openEditItemDialog({
    required BuildContext context,
    required int index,
    required Cloth item,
    required OrderCubit cubit,
    required bool isArabic,
    required bool isExpress,
    required double exAmount,
  }) async {
    final formDialogKey = GlobalKey<FormState>();

    final TextEditingController countController = TextEditingController();
    final TextEditingController detailsController = TextEditingController();
    final TextEditingController priceController = TextEditingController();

    // -------------------- INITIALIZATION LOGIC --------------------
    final selected = cubit.state.selectedItems[index];

    // 1. DETAILS
    detailsController.text = selected['details']?.toString() ?? "";

    // 2. COUNT
    countController.text = selected['clothes_count'].toString();
// 2. FLAGS (Add onlyCleaning here)

    if (cubit.state.selectedItems[index]['details'] != null) {
      detailsController.text = cubit.state.selectedItems[index]['details'].toString();
    } else {
      detailsController.clear();
    }
    // Initial states
    // bool isExpress = item.fclothCountes != null && item.fclothCountes! > 0;
    bool isOnlyIroning = cubit.state.selectedItems[index]['only_ironing'];
    bool isOnlyCleaning = selected['only_cleaning'] ?? false;
    print("current item:" + item.toString());
    countController.text = cubit.state.selectedItems[index]['clothes_count'].toString();

    if (cubit.state.selectedItems[index]['custom_price_per_unit'] != null &&
        cubit.state.selectedItems[index]['custom_price_per_unit'] != 0.0) {
      print("custom_price_per_unit:" +
          cubit.state.selectedItems[index]['custom_price_per_unit'].toString());
      priceController.text = cubit.state.selectedItems[index]['custom_price_per_unit'].toString();
    } else if (cubit.state.selectedItems[index]['total_custom_price'] != null &&
        cubit.state.selectedItems[index]['total_custom_price'] != 0.0) {
      print("total_custom_price:" +
          cubit.state.selectedItems[index]['total_custom_price'].toString());
      priceController.text = cubit.state.selectedItems[index]['total_custom_price'].toString();
    } else {
      //you mean here?
      final prices = cubit.state.selectedItems[index]['cloth']['prices'];
      if (isOnlyCleaning) {
        priceController.text =
            (isExpress ? prices['price_fast_cleaning'] : prices['price_cleaning']).toString();
      } else if (isOnlyIroning == false) {
        if (isExpress) {
          priceController.text =
              (prices['price_fast_cleaning_and_ironing'] ?? prices['price_fast_cleaning'])
                  .toString();
        } else {
          priceController.text =
              (prices['price_cleaning_and_ironing'] ?? prices['price_cleaning']).toString();
        }
      } else {
        priceController.text =
            (isExpress ? prices['price_fast_ironing'] : prices['price_ironing']).toString();
      }

      // if (provider.selectedItems[index]['only_ironing'] == false) {
      //   if (isExpress) {
      //     if (provider.selectedItems[index]['cloth']['prices']
      //             ['price_fast_cleaning_and_ironing'] !=
      //         null)
      //       priceController.text = provider.selectedItems[index]['cloth']
      //               ['prices']['price_fast_cleaning_and_ironing']
      //           .toString();
      //     else
      //       priceController.text = provider.selectedItems[index]['cloth']
      //               ['prices']['price_fast_cleaning']
      //           .toString();
      //   } else {
      //     if (provider.selectedItems[index]['cloth']['prices']
      //             ['price_cleaning_and_ironing'] !=
      //         null)
      //       priceController.text = provider.selectedItems[index]['cloth']
      //               ['prices']['price_cleaning_and_ironing']
      //           .toString();
      //     else
      //       priceController.text = provider.selectedItems[index]['cloth']
      //               ['prices']['price_cleaning']
      //           .toString();
      //   }
      // } else {
      //   if (isExpress) {
      //     priceController.text = provider.selectedItems[index]['cloth']
      //             ['prices']['price_fast_ironing']
      //         .toString();
      //   } else
      //     priceController.text = provider.selectedItems[index]['cloth']
      //             ['prices']['price_ironing']
      //         .toString();
      // }
    }

    if (cubit.state.selectedItems[index]['service_type'] == null ||
        cubit.state.selectedItems[index]['service_type'] == "") {
      if (isExpress)
        cubit.state.selectedItems[index]['service_type'] = "fast";
      else
        cubit.state.selectedItems[index]['service_type'] = "normal";
    }

    // // 3. PRICE
    // if (selected['price_per_unit'] != null && selected['price_per_unit'] != 0.0) {
    //   priceController.text = selected['price_per_unit'].toString();
    // } else {
    //   // fallback logic depending on express + ironing
    //   priceController.text = _getDefaultPrice(
    //     item: item,
    //     selected: selected,
    //     isExpress: isExpress,
    //   );
    // }

    // 4. SERVICE TYPE DEFAULT
    selected['service_type'] ??= isExpress ? "fast" : "normal";

    // ----------------------- SHOW DIALOG -----------------------
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Container(
              padding: const EdgeInsetsDirectional.only(start: 33, end: 33, top: 16, bottom: 16),
              width: 500,
              child: Form(
                key: formDialogKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          // Reset icon at the start
                          IconButton(
                            icon: Icon(
                              Icons.refresh,
                              size: 30,
                            ),
                            tooltip: "reset".tr,
                            onPressed: () {
                              showDialogOk(context,
                                  title: "reset_item".tr,
                                  message: "are_you_sure_you_want_to_reset".tr, onConfirm: () {
                                NotificationMenuController.hide();
                                context
                                    .read<SideMenuCubit>()
                                    .changeMenuItem(SideMenuItem.home); // لتحديث القائمة الجانبية

                                setStateDialog(() {
                                  cubit.state.selectedItems[index]['isCustomized'] = false;

                                  // reset details
                                  detailsController.clear();

                                  // reset service type
                                  if (isExpress) {
                                    cubit.state.selectedItems[index]['service_type'] = 'fast';
                                  } else {
                                    cubit.state.selectedItems[index]['service_type'] = 'normal';
                                  }

                                  // ------------------------------------------------------------------
                                  // 1. YOUR NEW RESET PRICE LOGIC (REPLACING THE OLD IF/ELSE)
                                  // ------------------------------------------------------------------
                                  final itemData = cubit.state.selectedItems[index];
                                  final prices = itemData['cloth']['prices'];
                                  final bool isOnlyCleaning = itemData['only_cleaning'] ??
                                      false; // 👈 Get the Wash Only flag
                                  final bool isOnlyIroning = itemData['only_ironing'] ?? false;

                                  if (isOnlyCleaning) {
                                    // 🧼 WASH ONLY CASE
                                    priceController.text = (isExpress
                                            ? prices['price_fast_cleaning']
                                            : prices['price_cleaning'])
                                        .toString();
                                  } else if (isOnlyIroning == false) {
                                    // 🧼➕💨 WASH & IRON CASE
                                    if (isExpress) {
                                      priceController.text =
                                          (prices['price_fast_cleaning_and_ironing'] ??
                                                  prices['price_fast_cleaning'])
                                              .toString();
                                    } else {
                                      priceController.text =
                                          (prices['price_cleaning_and_ironing'] ??
                                                  prices['price_cleaning'])
                                              .toString();
                                    }
                                  } else {
                                    // 💨 IRON ONLY CASE
                                    priceController.text = (isExpress
                                            ? prices['price_fast_ironing']
                                            : prices['price_ironing'])
                                        .toString();
                                  }

                                  final int value = int.parse(countController.text.trim());

                                  // ------------------------------------------------------------------
                                  // 2. UPDATED UIHelper CALL (PASSING onlyCleaning)
                                  // ------------------------------------------------------------------
                                  UIHelper.updateValue(
                                    value,
                                    context,
                                    item,
                                    express: isExpress,
                                    onlyIroning: isOnlyIroning,
                                    onlyCleaning:
                                        isOnlyCleaning, // 👈 CRITICAL: Pass the Wash Only flag here
                                    isCustomized: false,
                                    details: "",
                                    custom_price_per_unit: null,
                                    totalItemsPrice: null,
                                    serviceType: cubit.state.selectedItems[index]['service_type'],
                                    setStateCallback: setStateDialog,
                                  );
                                });

                                Navigator.pop(context);
                              });

                              //reset speed

                              // reset logic
                            },
                          ),

                          // Centered text
                          Expanded(
                            child: Center(
                              child: Text(
                                isArabic ? item.nameAr : item.nameEn,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600, // semiBold
                                ),
                              ),
                            ),
                          ),

                          // Empty space to balance the row (so text stays centered)
                          SizedBox(width: 48),
                          // same width as IconButton
                        ],
                      ),

                      const SizedBox(height: 17),
                      Container(
                        height: 120,
                        width: 120,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CommonWidgets.loadNetworkPhoto(
                            item.image,
                            fit: BoxFit.contain,
                            borderRadius: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 17),
                      // ... other widgets
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.only(start: 20),
                            child: Text(
                              "quantity".tr,
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.only(end: 20),
                            child: SizedBox(
                              width: 220,
                              child: TextFormField(
                                controller: countController,
                                // controller NOT recreated
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: "enter_count".tr,
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly, // only digits allowed
                                ],
                                onTap: () {
                                  // Select all text when the field is tapped
                                  countController.selection = TextSelection(
                                    baseOffset: 0,
                                    extentOffset: countController.text.length,
                                  );
                                },
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'please_enter_a_number'.tr;
                                  }
                                  final intValue = int.tryParse(value.trim());
                                  if (intValue == null || intValue <= 0) {
                                    return 'enter_a_valid_number_greater_than_0'.tr;
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 17),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.only(start: 20),
                            child: SizedBox(
                              width: 160,
                              child: Row(
                                children: [
                                  UIHelper.buildSpeedButton(
                                    label: "single_item_price".tr,
                                    selected: !(cubit.state.selectedItems[index]
                                            ['total_custom_price'] !=
                                        null),
                                    exAmount: exAmount,
                                    showPrice: false,
                                    // Show price on Normal only if Express is selected
                                    pricePrefix: ' -',
                                    cashColor: Color(0xff0077B3),
                                    onTap: () {
                                      setStateDialog(() => (cubit.state.selectedItems[index]
                                          ['total_custom_price'] = null));
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  UIHelper.buildSpeedButton(
                                    label: "total".tr,
                                    selected: cubit.state.selectedItems[index]
                                            ['total_custom_price'] !=
                                        null,
                                    exAmount: exAmount,
                                    showPrice: false,
                                    // Show price on Express only if Normal is selected
                                    pricePrefix: ' +',
                                    cashColor: Color(0xff13AC6B),
                                    onTap: () {
                                      setStateDialog(() {
                                        cubit.state.selectedItems[index]['total_custom_price'] =
                                            0.0;
                                        cubit.state.selectedItems[index]['custom_price_per_unit'] =
                                            null;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(width: 10),

                          // Integer-only input field
                          Padding(
                            padding: EdgeInsetsDirectional.only(end: 20),
                            child: SizedBox(
                              width: 220,
                              child: TextFormField(
                                controller: priceController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d{0,8}(\.\d{0,2})?$'), // <-- decimals, max 2 digits
                                  ),
                                ],
                                onTap: () {
                                  // Select all text when the field is tapped
                                  priceController.selection = TextSelection(
                                    baseOffset: 0,
                                    extentOffset: priceController.text.length,
                                  );
                                },
                                decoration: InputDecoration(
                                  hintText: "enter_price".tr,
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                ),
                                validator: (value) {
                                  print("current val: $value");
                                  if (value == null || value.trim().isEmpty) {
                                    return 'please_enter_a_number'.tr;
                                  }
                                  final doubleValue = double.tryParse(value.trim());
                                  if (doubleValue == null || doubleValue <= 0) {
                                    return 'enter_a_valid_number_greater_than_0'.tr;
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 17),
                      Text('Speed'.tr,
                          style: TextStyle(
                              fontSize: FontConstants.font_18,
                              fontWeight: FontWeightConstants.semiBold)),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 400,
                        child: Row(
                          children: [
                            UIHelper.buildSpeedButton(
                              label: 'Normal'.tr,
                              selected:
                                  !(cubit.state.selectedItems[index]['service_type'] == "fast"),
                              exAmount: exAmount,
                              showPrice: false,
                              // Show price on Normal only if Express is selected
                              pricePrefix: ' -',
                              cashColor: Color(0xff0077B3),
                              onTap: () {
                                //   setStateDialog(() => _isExpress_dialog = false);
                                print("vojaij current: normal");
                                setStateDialog(() {
                                  cubit.state.selectedItems[index]['service_type'] = "normal";
                                  final prices =
                                      cubit.state.selectedItems[index]['cloth']['prices'];

                                  if (isOnlyCleaning) {
                                    priceController.text = prices['price_cleaning'].toString();
                                  } else if (isOnlyIroning == false) {
                                    priceController.text = (prices['price_cleaning_and_ironing'] ??
                                            prices['price_cleaning'])
                                        .toString();
                                  } else {
                                    priceController.text = prices['price_ironing'].toString();
                                  }
                                });
                                // setStateDialog(() {
                                //   provider.selectedItems[index]['service_type'] = "normal";
                                //   if (provider.selectedItems[index]
                                //           ['only_ironing'] ==
                                //       false) {
                                //     if (provider.selectedItems[index]['cloth']
                                //                 ['prices']
                                //             ['price_cleaning_and_ironing'] !=
                                //         null)
                                //       priceController.text = provider
                                //           .selectedItems[index]['cloth']
                                //               ['prices']
                                //               ['price_cleaning_and_ironing']
                                //           .toString();
                                //     else
                                //       priceController.text = provider
                                //           .selectedItems[index]['cloth']
                                //               ['prices']['price_cleaning']
                                //           .toString();
                                //   } else {
                                //     priceController.text = provider
                                //         .selectedItems[index]['cloth']['prices']
                                //             ['price_ironing']
                                //         .toString();
                                //   }
                                // });
                              },
                            ),
                            const SizedBox(width: 8),
                            UIHelper.buildSpeedButton(
                                label: 'Express'.tr,
                                selected:
                                    cubit.state.selectedItems[index]['service_type'] == "fast",
                                exAmount: exAmount,
                                showPrice: false,
                                // Show price on Express only if Normal is selected
                                pricePrefix: ' +',
                                cashColor: Color(0xff13AC6B),
                                onTap: () {
                                  setStateDialog(() {
                                    cubit.state.selectedItems[index]['service_type'] = "fast";
                                    final prices =
                                        cubit.state.selectedItems[index]['cloth']['prices'];

                                    if (isOnlyCleaning) {
                                      priceController.text =
                                          prices['price_fast_cleaning'].toString();
                                    } else if (isOnlyIroning == false) {
                                      priceController.text =
                                          (prices['price_fast_cleaning_and_ironing'] ??
                                                  prices['price_fast_cleaning'])
                                              .toString();
                                    } else {
                                      priceController.text =
                                          prices['price_fast_ironing'].toString();
                                    }
                                  });
                                  //    setStateDialog(() => _isExpress_dialog = true);
                                  // setStateDialog(() {
                                  //   provider.selectedItems[index]
                                  //       ['service_type'] = "fast";
                                  //   print("vojaij current: fast");
                                  //   if (provider.selectedItems[index]
                                  //           ['only_ironing'] ==
                                  //       false) {
                                  //     if (provider.selectedItems[index]['cloth']
                                  //                 ['prices'][
                                  //             'price_fast_cleaning_and_ironing'] !=
                                  //         null)
                                  //       priceController.text = provider
                                  //           .selectedItems[index]['cloth']
                                  //               ['prices'][
                                  //               'price_fast_cleaning_and_ironing']
                                  //           .toString();
                                  //     else
                                  //       priceController.text = provider
                                  //           .selectedItems[index]['cloth']
                                  //               ['prices']
                                  //               ['price_fast_cleaning']
                                  //           .toString();
                                  //   } else {
                                  //     priceController.text = provider
                                  //         .selectedItems[index]['cloth']
                                  //             ['prices']['price_fast_ironing']
                                  //         .toString();
                                  //   }
                                  // });
                                }),
                          ],
                        ),
                      ),
                      // if(item.supportIroning)...[
                      // const SizedBox(height: 17),
                      // Text("cleaning_type".tr,
                      //     style: TextStyle(
                      //         fontSize: FontConstants.font_18, fontWeight: FontWeightConstants.semiBold)),
                      // const SizedBox(height: 8),
                      //
                      //
                      // SizedBox(
                      //   width: 400,
                      //   child: Row(
                      //     children: [
                      //       buildSpeedButton(
                      //         label: "Wash & Iron".tr,
                      //         selected: !provider.selectedItems[index]['only_ironing']==true,
                      //         exAmount: exAmount,
                      //         showPrice:false, // Show price on Normal only if Express is selected
                      //         pricePrefix: ' -',
                      //         cashColor: Color(0xff0077B3),
                      //         onTap: () {
                      //           setStateDialog(() => provider.selectedItems[index]['only_ironing']=false);
                      //         },
                      //       ),
                      //       const SizedBox(width: 8),
                      //       buildSpeedButton(
                      //         label: "IronOnly".tr,
                      //         selected: provider.selectedItems[index]['only_ironing']==true,
                      //         exAmount: exAmount,
                      //         showPrice:false, // Show price on Express only if Normal is selected
                      //         pricePrefix: ' +',
                      //         cashColor:Color(0xff13AC6B),
                      //         onTap: () {
                      //           setStateDialog(() => provider.selectedItems[index]['only_ironing']=true);
                      //           }
                      //
                      //           ,
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // ],
                      const SizedBox(height: 17),

                      // Details
                      SizedBox(
                        child: TextFormField(
                          controller: detailsController,
                          style: const TextStyle(fontSize: 16),
                          maxLines: 3,
                          maxLength: 80,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          inputFormatters: [
                            // Prevent more than 3 lines
                            FilteringTextInputFormatter.allow(RegExp(r'.')),
                            MaxLinesInputFormatter(3),
                          ],
                          decoration: InputDecoration(
                            hintText: "enter_details".tr,
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                          onTap: () {
                            // Select all text when the field is tapped
                            detailsController.selection = TextSelection(
                              baseOffset: 0,
                              extentOffset: detailsController.text.length,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 17),

                      // Save button
                      CustomButton(
                        width: 400,
                        () {
                          if (formDialogKey.currentState!.validate()) {
                            final int value = int.parse(countController.text.trim());

                            // Update cloth values
                            // if (isExpress) {
                            //   item.fclothCountes = isOnlyIroning ? 0 : value;
                            //   item.fclothCountesOnly = isOnlyIroning ? value : 0;
                            // } else {
                            //   item.clothCountes = isOnlyIroning ? 0 : value;
                            //   item.clothCountesOnly = isOnlyIroning ? value : 0;
                            // }
                            //
                            // item.isSetOnlyIroning = isOnlyIroning;
                            double? total = null;
                            double? price = null;

                            if (cubit.state.selectedItems[index]['total_custom_price'] != null) {
                              total = double.tryParse(priceController.text.trim());
                              if (total != null) {
                                print("gjoidgjoia not null total");
                                cubit.state.selectedItems[index]['total_custom_price'] = total;
                                total = double.parse(total.toStringAsFixed(2));
                              }
                            } else {
                              price = double.tryParse(priceController.text.trim());

                              if (price != null) {
                                cubit.state.selectedItems[index]['custom_price_per_unit'] = price;
                                price = double.parse(price.toStringAsFixed(2));
                              }
                            }

                            UIHelper.updateValue(
                              value,
                              context,
                              item,
                              express: isExpress,
                              onlyIroning: isOnlyIroning,
                              onlyCleaning: isOnlyCleaning,
                              isCustomized: true,
                              details: detailsController.text,
                              custom_price_per_unit: price,
                              totalItemsPrice: total,
                              serviceType: cubit.state.selectedItems[index]['service_type'],
                              setStateCallback: setStateDialog, // pass StatefulBuilder's setState
                            );

                            // updateValue(
                            //   value,
                            //   item,
                            //   express: isExpress,
                            //   onlyIroning: isOnlyIroning,
                            //   isCustomized: true,
                            //   details: detailsController.text.toString(),
                            //   pricePerUnit:price,
                            //   totalItemsPrice:total,
                            //   serviceType: provider.selectedItems[index]['service_type'],
                            //
                            // );

                            countController.clear();
                            detailsController.clear();
                            priceController.clear();
                            Navigator.of(context).pop();
                            print("sent type: " + cubit.state.selectedItems[index]['service_type']);
                            print("ironVal:" + isOnlyIroning.toString());
                          }
                        },
                        text: "save".tr,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void protectedAction({
    required BuildContext context,
    required String? backendPassword,
    required VoidCallback onAuthorized,
  }) {
    final TextEditingController passwordController = TextEditingController();
    final GlobalKey<FormState> formDialogKey = GlobalKey<FormState>();

    // Determine the correct password to compare against
    final bool isBackendPassValid =
        backendPassword != null && backendPassword.isNotEmpty && backendPassword != "null";
    final String targetPassword = isBackendPassValid ? backendPassword : "0000";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Container(
              padding: const EdgeInsetsDirectional.only(start: 33, end: 33, top: 16, bottom: 16),
              width: 500, // Matches your UI reference
              child: Form(
                key: formDialogKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Row
                      Row(
                        children: [
                          const SizedBox(width: 48), // Balance for centering
                          Expanded(
                            child: Center(
                              child: Text(
                                "security_check".tr,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 17),

                      // Lock Icon Illustration
                      const Icon(Icons.lock_person_outlined, size: 80, color: Color(0xff0077B3)),
                      const SizedBox(height: 17),

                      Text(
                        "please_enter_password_to_continue".tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 17),

                      // Password Field
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        autofocus: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20, letterSpacing: 8),
                        decoration: InputDecoration(
                          hintText: "password".tr,
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        ),
                        onFieldSubmitted: (value) {
                          if (formDialogKey.currentState!.validate()) {
                            Navigator.pop(context);
                            onAuthorized();
                          } else {
                            passwordController.clear();
                          }
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'please_enter_password'.tr;
                          }
                          if (value != targetPassword) {
                            return 'wrong_password'.tr;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 25),

                      // Confirm Button (Using your CustomButton style)
                      CustomButton(
                        width: 400,
                        () {
                          if (formDialogKey.currentState!.validate()) {
                            Navigator.pop(context); // Close dialog
                            onAuthorized(); // Execute logic
                          } else {
                            // If validation fails (Wrong Password), clear the text field
                            passwordController.clear();
                          }
                        },
                        text: "confirm".tr,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static Widget buildSpeedButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required double exAmount,
    required bool showPrice,
    required String pricePrefix,
    required Color cashColor, // "+" or "-"
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Color(0xffF5FCFF) : Colors.grey[200],
            border: Border.all(
              color: selected ? AppColors.primaryColor : Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? AppColors.primaryColor : Colors.grey[600],
                ),
              ),
              if (showPrice)
                Row(
                  children: [
                    SizedBox(width: 4),
                    SvgPicture.asset(
                      ImageConstants.riyalsvg,
                      width: 10.w,
                      color: cashColor,
                    ),
                    Text(
                      '$pricePrefix${exAmount.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeightConstants.semiBold,
                        color: cashColor,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  String removeOrdPrefix(String input) {
    return input.replaceAll("ORD-", "");
  }

  String cleanId(String id) {
    return id.contains('-') ? id.split('-').last : id;
  }
}

extension DoubleTruncate on double {
  String toFixedDown(int decimals) {
    final factor = pow(10, decimals);
    return ((this * factor) / factor).toStringAsFixed(decimals);
  }
}

class MaxLinesInputFormatter extends TextInputFormatter {
  final int maxLines;

  MaxLinesInputFormatter(this.maxLines);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final newLineCount = '\n'.allMatches(newValue.text).length + 1;

    if (newLineCount > maxLines) {
      return oldValue; // reject input
    }

    return newValue;
  }
}

// class WebViewDialogDemo extends StatefulWidget {
//   var url;
//   var isRestrictAd;
//   var title;
//   WebViewDialogDemo(this.url, {this.isRestrictAd, this.title});
//
//   @override
//   State<WebViewDialogDemo> createState() => _WebViewDialogDemoState();
// }
//
// class _WebViewDialogDemoState extends State<WebViewDialogDemo> {
//   WebViewController controller = WebViewController();
//
//   @override
//   void dispose() {
//     super.dispose();
//     EasyLoading.dismiss();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//
//     controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       // ..setBackgroundColor(const Color(0x00000000))
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onProgress: (int progress) {
//             // Update loading bar.
//             //  EasyLoading.show();
//           },
//           onPageStarted: (String url) {},
//           onPageFinished: (String url) {},
//           onWebResourceError: (WebResourceError error) {
//             print("++++" + error.description.toString());
//           },
//         ),
//       )
//       ..loadRequest(Uri.parse(widget.url));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       //  appBar: customAppBar(context: context),
//       body: Container(
//         width: Get.width,
//         height: Get.height,
//         padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
//         child: Column(
//           children: [
//             Container(
//               //     height: 50,
//
//               child: AppBar(
//                 // backgroundColor: Colors.black,
//                 centerTitle: true,
//                 title: Text(widget.title),
//                 leading: BackButton(),
//               ),
//             ),
//             Expanded(
//               child: WebViewWidget(controller: controller),
//             ),
//           ],
//         ),
//
//         //  WebviewScaffold(
//         //   url: url,
//         //   withZoom: true,
//         //   withJavascript: true,
//         //   withLocalStorage: true,
//         //   // withZoom: true,
//         //   appCacheEnabled: true,
//         //   clearCookies: true,
//         //   clearCache: true,
//         //   allowFileURLs: true,
//
//         //   appBar: MyAppbar(),
//         //   initialChild: Container(
//         //     color: Colors.black54,
//         //     child: const Center(
//         //       child: Text("Loading...."),
//         //     ),
//         //   ),
//         // )),
//       ),
//     );
//   }
// }

//H4y1t3nL.h4q2918z4NXEXxXXGUSDVJM5dPfZsvCU
