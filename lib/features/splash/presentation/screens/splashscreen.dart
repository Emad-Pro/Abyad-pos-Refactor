import 'package:abyadpos_tab/core/constants/image_constants.dart';
import 'package:abyadpos_tab/core/storage/sharedpref.dart';
import 'package:abyadpos_tab/core/enums/language_code.dart';
import 'package:abyadpos_tab/main.dart';
import 'package:abyadpos_tab/features/auth/presentation/screens/login_screen.dart';
import 'package:abyadpos_tab/features/auth/presentation/controllers/user_cubit.dart';
import 'package:abyadpos_tab/features/home/presentation/screens/home_screen.dart';
import 'package:abyadpos_tab/features/settings/presentation/screens/update_prices_screen.dart';
import 'package:abyadpos_tab/core/widgets/ui_helpers.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import 'dart:async';
import 'package:app_settings/app_settings.dart'; // S
import 'package:abyadpos_tab/core/theme/app_colors.dart';
import 'package:abyadpos_tab/core/widgets/custom_drawer.dart';
import 'package:ntp/ntp.dart';

import 'package:abyadpos_tab/features/dashboard/presentation/controllers/drawer_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

// class _SplashScreenState extends State<SplashScreen> {
//  // late VideoPlayerController _videoPlayerController;
//   late Timer _timer;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//     });
//     EasyLoading.instance..dismissOnTap = true;
//
//  //   initializeVideoPlayer();
//     startSplashTimer();
//   }
//
//   void initializeVideoPlayer() {
//     // _videoPlayerController =
//     //     VideoPlayerController.asset(ImageConstants.splashJson)
//     //       ..initialize().then((_) {
//     //         setState(() {}); // Refresh the state to display the video
//     //       })
//     //       ..setLooping(false) // Play only once
//     //       ..play();
//   }
//
//   void startSplashTimer() async {
//     String language = await SharedPref().getString('language');
//     print("***+" + language);
//     if (language == "ar") {
//       isArabic = true;
//       Get.updateLocale(Locale('ar', 'SA'));
//     } else {
//       Get.updateLocale(Locale('en', 'US'));
//     }
//     setState(() {
//       isArabic = Get.locale!.languageCode == LanguageCode.ar.name;
//     });
//
//     UserViewModel userViewModel =
//         Provider.of<UserViewModel>(context, listen: false);
//    await userViewModel.loadPref(context);
//     // bool isLoggedIn = userViewModel.userModel != null;
//     // if(isLoggedIn)
//
//     _timer = Timer(const Duration(seconds: 4), () {
//       navigateToNextScreen(userViewModel);
//     });
//   }
//
//   Future<void> navigateToNextScreen(UserViewModel userViewModel) async {
//
//  //  await UserViewModel().checkAppVersion(context); the backend request is disabled
//    bool isLoggedIn = userViewModel.userModel != null;
//    ApiClient apiClient = ApiClient();
//    if (isLoggedIn) {
//       // Navigate to the main screen
//
//
//      //for testing 0 active items
// //    userViewModel.userModel?.data.products_need_setup=true;
//
//      if(userViewModel.userModel?.data.products_need_setup==true){
//        // context.read<SideMenuProvider>().selectItem(SideMenuItem.settings);
//        UIHelper().goToMenu(context, SideMenuItem.settings);
//        Get.off(()=>UpdatePricesScreen());
//      }
//      else
//       Get.off(()=>HomeScreen(reload: false,));
//       logger.log("home.....");
//     } else {
//       Get.off(()=>LoginScreen());
//       logger.log("login.....");
//     }
//   }
//
//   @override
//   void dispose() {
//     // _videoPlayerController.dispose();
//     _timer.cancel(); // Cancel the timer when the widget is disposed
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     return Scaffold(
//       body: Center(
//         child: SizedBox(
//           // width: size.width*0.30,
//           // height: size.height*0.30,
//           child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Image.asset(
//             ImageConstants.dummy_logo,
//             width:MediaQuery.of(context).size.width*0.30,
//             height: MediaQuery.of(context).size.height*0.30,
//             fit: BoxFit.contain, // or BoxFit.scaleDown depending on image ratio
//             filterQuality: FilterQuality.high, // Improve rendering quality
//           ),
//           const SizedBox(height: 15), // spacing
//            Text(
//             "laundry_management".tr,
//             style: TextStyle(
//               fontSize: 30,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           ],),
//           // _videoPlayerController.value.isInitialized
//           //     ? AspectRatio(
//           //         aspectRatio: _videoPlayerController.value.aspectRatio,
//           //         child: VideoPlayer(_videoPlayerController))
//           //
//
//            //   : Center(child: CircularProgressIndicator()),
//         ),
//       ),
//     );
//   }
// }

// ... (your other imports)
class _SplashScreenState extends State<SplashScreen> {
  late Timer _timer;
  bool _isCheckingTime = false;

  @override
  void initState() {
    super.initState();
    EasyLoading.instance..dismissOnTap = true;
    startSplashTimer();
  }

  // --- THE CORE LOGIC CHANGE ---
  Future<void> _checkTimeAndProceed(UserCubit userCubit) async {
    if (_isCheckingTime) return;
    setState(() => _isCheckingTime = true);

    bool isTimeCorrect = true;

    try {
      // جلب الوقت الحقيقي من سيرفرات جوجل (أو أي سيرفر NTP)
      DateTime ntpTime = await NTP.now().timeout(const Duration(seconds: 5));
      DateTime deviceTime = DateTime.now();

      // فحص الفرق بين وقت الجهاز ووقت الإنترنت (مثلاً مسموح بـ 5 دقائق فرق)
      int offset = ntpTime.difference(deviceTime).inMinutes.abs();

      if (offset > 5) {
        isTimeCorrect = false; // الوقت يدوي وغير دقيق
      }
    } catch (e) {
      // في حالة فشل الاتصال بالإنترنت، يمكنك اختيار تمرير المستخدم
      // أو إظهار رسالة تتطلب اتصال بالإنترنت للفحص لأول مرة.
      print("خطأ في فحص وقت الإنترنت: $e");
      // isTimeCorrect = false; // فك التعليق إذا كنت تريد إجبار المستخدم على الإنترنت
    }

    if (!isTimeCorrect) {
      if (mounted) {
        setState(() => _isCheckingTime = false);
        _showTimeErrorDialog(userCubit);
      }
    } else {
      // إذا كان الوقت صحيحاً، انتقل للشاشة التالية
      _timer = Timer(const Duration(seconds: 2), () {
        navigateToNextScreen(userCubit);
      });
    }
  }

  void _showTimeErrorDialog(UserCubit userCubit) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents clicking outside to close
      builder: (context) => PopScope(
        canPop: false, // --- THIS BLOCKS THE ANDROID BACK BUTTON ---
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          // You can add a toast here saying "Please fix time to continue" if you like
        },
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.40,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "system_time_error".tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D1F3C),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 26),
                  Text(
                    "please_enable_automatic_time".tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: AppColors.primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context); // Manually close to retry
                            _checkTimeAndProceed(userCubit);
                          },
                          child: Text(
                            "retry".tr,
                            style: TextStyle(color: AppColors.primaryColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            AppSettings.openAppSettings(type: AppSettingsType.date);
                          },
                          child: Text(
                            "open_settings".tr,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void startSplashTimer() async {
    // 1. Language Setup
    String language = await SharedPref().getString('language');
    if (language == "ar") {
      isArabic = true;
      Get.updateLocale(const Locale('ar', 'SA'));
    } else {
      Get.updateLocale(const Locale('en', 'US'));
    }
    setState(() {
      isArabic = Get.locale!.languageCode == LanguageCode.ar.name;
    });

    // 2. Load User Data
    UserCubit userViewModel = BlocProvider.of<UserCubit>(context, listen: false);
    await userViewModel.loadPref(context);

    // 3. Perform the blocking check for Settings
    _checkTimeAndProceed(userViewModel);
  }

  Future<void> navigateToNextScreen(UserCubit usercubit) async {
    bool isLoggedIn = usercubit.state.userModel != null;
    if (isLoggedIn) {
      if (usercubit.state.userModel?.data.products_need_setup == true) {
        UIHelper().goToMenu(context, SideMenuItem.settings);
        Get.off(() => UpdatePricesScreen());
      } else {
        Get.off(() => HomeScreen(reload: false));
      }
    } else {
      Get.off(() => LoginScreen());
    }
  }

  @override
  void dispose() {
    if (_timer.isActive) _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              ImageConstants.dummy_logo,
              width: MediaQuery.of(context).size.width * 0.30,
              height: MediaQuery.of(context).size.height * 0.30,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
            const SizedBox(height: 15),
            Text(
              "laundry_management".tr,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            if (_isCheckingTime) ...[
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
            ]
          ],
        ),
      ),
    );
  }
}
