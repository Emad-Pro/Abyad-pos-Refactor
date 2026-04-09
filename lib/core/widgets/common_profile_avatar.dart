import 'dart:io';

import 'package:abyadpos_tab/core/theme/app_colors.dart';
import 'package:abyadpos_tab/core/widgets/common_widgets.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonProfileAvatar {
  /// profile image avatar
  static Widget commonProfileAvatar({
    double? sizedBoxHeight,
    void Function()? onTapProfile,
    double profileRadius = 40,
    String imageUrl = "",
    String placeholderString = "",
    Color dottedBorderColor = AppColors.blackColor,
    Widget? stackedIcon,
    double bottomPositionIcon = 0.7,
  }) {
    return InkWell(
      highlightColor: AppColors.transparentColor,
      splashColor: AppColors.transparentColor,
      onTap: () => onTapProfile?.call(),
      child: SizedBox(
        height: sizedBoxHeight ?? 110,
        child: Stack(
          alignment: Alignment.center,
          children: [
            DottedBorder(
              color: dottedBorderColor,
              dashPattern: const [5, 3],
              padding: const EdgeInsets.all(5),
              strokeWidth: 1.5,
              borderType: BorderType.Circle,
              child: imageUrl != "" && !imageUrl.startsWith("http")
                  ? SizedBox(
                      height: profileRadius * 2,
                      width: profileRadius * 2,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: FileImage(
                              File(imageUrl),
                            ),
                          ),
                        ),
                      ),
                    )
                  : CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: profileRadius,
                      child: CommonWidgets.loadNetworkImage(
                        imageUrl,
                        borderRadius: 60,
                        isProfile: true,
                      ),
                    ),
            ).paddingSymmetric(horizontal: 16),
            Positioned(
              bottom: bottomPositionIcon,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.blackColor,
                  border: Border.all(
                    color: AppColors.whiteColor,
                    width: 2,
                  ),
                ),
                child: stackedIcon,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
