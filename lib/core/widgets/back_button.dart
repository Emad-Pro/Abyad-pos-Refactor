import 'package:abyadpos_tab/core/constants/image_constants.dart';
import 'package:abyadpos_tab/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:abyadpos_tab/core/widgets/inverted_icon.dart';

class BackIcon extends StatelessWidget {
  final bool background;

  const BackIcon({super.key, required this.background});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.back();
      },
      child: InvertIcon(
        child: background
            ? Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.r),
                  color: AppColors.whiteColor,
                ),
                child: SvgPicture.asset(
                  ImageConstants.undo,
                  height: 36.h,
                  width: 36.w,
                ),
              )
            : SvgPicture.asset(
                ImageConstants.undo,
                height: 26.h,
                width: 26.w,
              ),
      ),
    );
  }
}
