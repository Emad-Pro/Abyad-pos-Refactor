import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InvertIcon extends StatelessWidget {
  final Widget child;

  const InvertIcon({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: Get.locale!.languageCode == "en" ? -1 : 1,
      child: child,
    );
  }
}
