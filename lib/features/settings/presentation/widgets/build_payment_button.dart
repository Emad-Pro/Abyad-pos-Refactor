import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:abyadpos_tab/core/theme/app_colors.dart';
import 'package:abyadpos_tab/core/theme/font_constants.dart';
import 'package:abyadpos_tab/core/widgets/common_text.dart';
import 'package:abyadpos_tab/core/widgets/ui_helpers.dart';
Widget buildPaymentButton({
  required String icon,
  required String label,
  required bool selected,
  required VoidCallback onTap,z
}) {
  final primary = AppColors.primaryColor;
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 50,
      decoration: BoxDecoration(
        // border: Border.all(color: buttonBorderColor ?? Colors.white),
          borderRadius: BorderRadius.circular( 8.0),
          // color: bgColor?? AppColors.mainColor,
          gradient: myCustomGrident()),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon(icon, color: selected ? primary : Colors.grey[600]),
          SvgPicture.asset(icon,
              color: Colors.white),
          UIHelper.horizontalSpaceSm5,
          // const SizedBox(width: 8),
          // Text(
          //   label,
          //   style: TextStyle(
          //     fontSize: 14,
          //     fontWeight: FontWeight.w600,
          //     color: selected ? primary : Colors.grey[600],
          //   ),
          // ),
          CommonText(
            text: label,
            textAlign: TextAlign.center,
            color:  AppColors.whiteColor,
            fontWeight: FontWeightConstants.semiBold,
            fontSize:FontConstants.font_14,
          )
        ],
      ),
    ),
  );
}
LinearGradient myCustomGrident() {
  return LinearGradient(
      begin: Alignment(0.9775090217590332, 0.022490976378321648),
      end: Alignment(-0.022490976378321648, 0.022490976378321648),
      colors: [AppColors.primaryColor, AppColors.primaryColor]);
}