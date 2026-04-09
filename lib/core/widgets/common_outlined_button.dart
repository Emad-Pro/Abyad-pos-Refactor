import 'package:abyadpos_tab/core/theme/app_colors.dart';
import 'package:abyadpos_tab/core/theme/font_constants.dart';
import 'package:abyadpos_tab/core/theme/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:abyadpos_tab/core/utils/extensions.dart';
import 'package:abyadpos_tab/core/widgets/common_text.dart';

class CommonOutlinedButton extends StatelessWidget {
  final bool allowAnimation;
  final void Function()? onPressed;
  final String buttonText;
  final String? buttonIcon;
  final String? fontFamily;
  final Color? buttonColor;
  final Color buttonTextColor;
  final double? fontSize;
  final FontWeight fontWeight;
  final double? buttonWidth;
  final double? buttonHeight;
  final Color? borderColor;
  final double borderRadius;

  const CommonOutlinedButton({
    super.key,
    this.allowAnimation = false,
    required this.onPressed,
    required this.buttonText,
    this.buttonIcon,
    this.fontFamily,
    this.buttonTextColor = AppColors.blackColor,
    this.buttonColor,
    this.fontSize,
    this.fontWeight = FontWeightConstants.medium,
    this.buttonWidth,
    this.buttonHeight,
    this.borderColor,
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    Color btnColor = buttonColor ?? AppColors.fieldBorderColor;

    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () => onPressed?.call(),
      child: Container(
        width: buttonWidth ?? double.infinity,
        height: buttonHeight ?? UIConstants.kButtonHeight,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: borderColor ?? btnColor,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          color: btnColor,
        ),
        child: buttonIcon != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      child:
                          SvgPicture.asset(buttonIcon!).marginOnly(right: 16)),
                  CommonText(
                    text: buttonText,
                    color: buttonTextColor,
                    fontFamily: fontFamily ?? FontFamilyConstants.epilogue,
                    fontSize: fontSize ?? FontConstants.font_18,
                    fontWeight: fontWeight,
                  ),
                ],
              )
            : Center(
                child: CommonText(
                  text: buttonText,
                  color: buttonTextColor,
                  fontFamily: fontFamily ?? FontFamilyConstants.epilogue,
                  fontSize: fontSize ?? FontConstants.font_18,
                  fontWeight: fontWeight,
                ),
              ),
      ),
    );
  }
}
