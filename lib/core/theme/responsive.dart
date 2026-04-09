import 'package:flutter/material.dart';

class MyResponsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const MyResponsive({
    Key? key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  }) : super(key: key);

  // Adjusted breakpoints for Sunmi devices
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width <
      720; // For Sunmi handheld devices like V2 Pro

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 720 &&
      MediaQuery.of(context).size.width <
          1280; // For Sunmi tablets like T2 Mini

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >=
      1280; // For large Sunmi POS displays like T2

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    // If our width is more than 1280, we consider it a desktop
    if (screenSize.width >= 1280) {
      return desktop;
    }
    // If width is between 720 and 1280, we consider it a tablet
    else if (screenSize.width >= 720 && tablet != null) {
      return tablet!;
    }
    // Otherwise, it's a mobile layout
    else {
      return mobile;
    }
  }
}
