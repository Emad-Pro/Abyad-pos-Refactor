import 'package:abyadpos_tab/core/theme/app_colors.dart';
import 'package:abyadpos_tab/core/theme/font_constants.dart';
import 'package:abyadpos_tab/core/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class CustomButton extends StatelessWidget {
  double? width;
  var color;
  var child;
  var text;
  var textcolor;
  var weight;
  var fsize;
  var onTap;
  var buttonBorderColor;
  var icon;
  var circleRadius;
  bool? isDisable;
  bool? isGradient;
  var height;
  var elevation;
  CustomButton(this.onTap,
      {this.child,
      this.color,
      this.fsize,
      this.text,
      this.textcolor,
      this.buttonBorderColor,
      this.weight,
      this.isDisable,
      this.icon,
      this.circleRadius,
      this.elevation,
      this.isGradient,
      this.height,
      this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: isGradient != null
          ? BoxDecoration(
              // border: Border.all(color: buttonBorderColor ?? Colors.white),
              borderRadius: BorderRadius.circular(circleRadius ?? 8.0),
              // color: bgColor?? AppColors.mainColor,
              gradient: myCustomGrident())
          : BoxDecoration(),
      child: MaterialButton(
        onPressed: onTap,
        elevation: elevation ?? 3,
        disabledColor: AppColors.inactiveColor,
        height: height ?? 50,
        // highlightColor: primaryColor.withOpacity(0.3),
        // hoverColor: primaryColor,
        // focusColor: Colors.lightGreen,
        shape: RoundedRectangleBorder(
            side: isGradient != null
                ? BorderSide.none
                : BorderSide(
                    width: isGradient != null ? 0 : 1,
                    color: buttonBorderColor ?? AppColors.primaryColor),
            borderRadius: BorderRadius.circular(circleRadius ?? 8)),
        minWidth: width != null ? width : MediaQuery.of(context).size.width,
        //= height: 45,
        color: color ??
            (isGradient != null ? Colors.transparent : AppColors.primaryColor),
        child: child ??
            (text == "loading".tr
                ? CircularProgressIndicator(
                    color: Colors.white,
                  )
                : CommonText(
                    text: text,
                    textAlign: TextAlign.center,
                    color: textcolor ?? AppColors.whiteColor,
                    fontWeight: FontWeightConstants.semiBold,
                    fontSize: fsize ?? FontConstants.font_14,
                  )),
      ),
    );
  }
}

LinearGradient myCustomGrident() {
  return LinearGradient(
      begin: Alignment(0.9775090217590332, 0.022490976378321648),
      end: Alignment(-0.022490976378321648, 0.022490976378321648),
      colors: [AppColors.primaryColor, AppColors.primaryColor]);
}
