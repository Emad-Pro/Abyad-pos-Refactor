import 'package:abyadpos_tab/core/theme/app_colors.dart';
import 'package:abyadpos_tab/core/theme/font_constants.dart';
import 'package:abyadpos_tab/core/theme/ui_constants.dart';
import 'package:abyadpos_tab/core/widgets/common_methods.dart';
import 'package:flutter/material.dart';

import 'package:abyadpos_tab/core/widgets/common_text.dart';

class CommonFilledButton extends StatelessWidget {
  final bool allowAnimation;
  final void Function()? onPressed;
  final String buttonText;
  final Color? buttonColor;
  final Color buttonTextColor;
  final double? fontSize;
  final FontWeight fontWeight;
  final double? buttonWidth;
  final double? buttonHeight;

  const CommonFilledButton({
    super.key,
    this.allowAnimation = true,
    required this.onPressed,
    required this.buttonText,
    this.buttonTextColor = AppColors.whiteColor,
    this.buttonColor,
    this.fontSize,
    this.fontWeight = FontWeightConstants.medium,
    this.buttonWidth,
    this.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () {
        CommonMethods.hideKeyboard(context);
        onPressed?.call();
      },
      style: FilledButton.styleFrom(
        backgroundColor: buttonColor ?? AppColors.primaryColor,
        minimumSize: Size(
          buttonWidth ?? double.infinity,
          buttonHeight ?? UIConstants.kButtonHeight,
        ),
      ),
      child: CommonText(
        text: buttonText,
        textAlign: TextAlign.center,
        color: buttonTextColor,
        fontSize: fontSize ?? FontConstants.font_18,
        fontWeight: fontWeight,
      ),
    );
  }
}
