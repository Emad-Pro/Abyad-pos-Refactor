import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ExitAppWrapper extends StatefulWidget {
  final Widget child;
  const ExitAppWrapper({super.key, required this.child});

  @override
  State<ExitAppWrapper> createState() => _ExitAppWrapperState();
}

class _ExitAppWrapperState extends State<ExitAppWrapper> {
  DateTime? lastBackPressTime;

  Future<bool> _onWillPop() async {
    DateTime now = DateTime.now();
    if (lastBackPressTime == null ||
        now.difference(lastBackPressTime!) > const Duration(seconds: 2)) {
      lastBackPressTime = now;

      // Show snackbar
      Get.snackbar(
        'Exit'.tr,
        'Press again to exit'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xDD000000),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );

      return false; // Don't exit yet
    }

    // Exit the app
    await SystemNavigator.pop();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: widget.child,
    );
  }
}
