import 'dart:ui';

import 'package:abyadpos_tab/core/constants/image_constants.dart';
import 'package:abyadpos_tab/core/theme/app_colors.dart';
import 'package:abyadpos_tab/core/theme/font_constants.dart';
import 'package:abyadpos_tab/core/widgets/common_filled_button.dart';
import 'package:abyadpos_tab/core/widgets/common_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'package:skeletonizer/skeletonizer.dart';

class CommonWidgets {
  static showSnackBar(String message, {bool success = true}) {
    // todo: snackbar
  }

  /// circular border
  static BorderRadius circularBorder({
    double radius = 15,
  }) {
    return BorderRadius.circular(radius);
  }

  static noInternetDialog({
    required BuildContext context,
  }) {
    Widget title = CommonText(
      text: "noInternet".tr,
      fontSize: FontConstants.font_16,
      fontWeight: FontWeightConstants.semiBold,
      color: AppColors.blackColor.withOpacity(0.7),
    );
    Widget content = CommonText(
      text: "noInternetMsg".tr,
      fontSize: FontConstants.font_14,
      fontWeight: FontWeightConstants.medium,
      color: AppColors.blackColor.withOpacity(0.6),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) {
        return Theme.of(context).platform == TargetPlatform.iOS
            ? PopScope(
                canPop: false,
                child: CupertinoAlertDialog(
                  title: title,
                  content: content,
                ),
              )
            : PopScope(
                canPop: false,
                child: Theme(
                  data: ThemeData(useMaterial3: false),
                  child: AlertDialog(
                    title: title,
                    content: content,
                  ),
                ),
              );
      },
    );
  }

  static showCustomDialog(context, String titleName, String titleContent,
      String leftButtonText, String rightButtonText, Function(int) callback) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28.0)), //this right here
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 16,
                  ),
                  CommonText(
                      textAlign: TextAlign.left,
                      text: titleName,
                      fontFamily: FontFamilyConstants.epilogue,
                      fontWeight: FontWeightConstants.bold,
                      fontSize: FontConstants.font_18,
                      color: AppColors.blackColor),
                  const SizedBox(
                    height: 24,
                  ),
                  CommonText(
                    textAlign: TextAlign.center,
                    text: titleContent,
                    fontFamily: FontFamilyConstants.epilogue,
                    fontWeight: FontWeightConstants.semiBold,
                    fontSize: FontConstants.font_16,
                    color: AppColors.blackColor,
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: CommonFilledButton(
                            onPressed: () {
                              Navigator.pop(context);
                              callback(0);
                            },
                            buttonColor: AppColors.whiteColor,
                            // borderColor: AppColors.blackColor.withOpacity(0.3),
                            buttonTextColor:
                                AppColors.blackColor.withOpacity(0.5),
                            fontSize: FontConstants.font_14,
                            fontWeight: FontWeightConstants.medium,
                            buttonText: leftButtonText,
                          ),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        Expanded(
                          child: CommonFilledButton(
                            onPressed: () {
                              Navigator.pop(context);
                              callback(1);
                            },
                            buttonColor: AppColors.blackColor,
                            fontSize: FontConstants.font_14,
                            fontWeight: FontWeightConstants.medium,
                            buttonText: rightButtonText,
                            buttonTextColor: AppColors.whiteColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget shimmerPlaceHolder({
    double? height,
    double? width,
    double borderRadius = 0,
    BoxShape shape = BoxShape.rectangle,
    Color color = AppColors.whiteColor,
    Widget? child,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: shape != BoxShape.circle
            ? BorderRadius.circular(borderRadius)
            : null,
        color: color,
      ),
      child: child,
    );
  }

  /// load network image
  static Widget loadNetworkImage(
    String url, {
    Color? color = Colors.white,
    double? borderRadius,
    double? width,
    double? height,
    BoxFit fit = BoxFit.fill,
    bool isProfile = false,
    String placeholderString = "",
    BlendMode? backgroundBlendMode,
  }) {
    bool isValidUrl = Uri.tryParse(url)?.isAbsolute == true && url != "";
    return Container(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      decoration: BoxDecoration(
        backgroundBlendMode: backgroundBlendMode,
        color: color,
        // border: Border.all(color: AppColors.fieldBorderColor.withOpacity(0.2), width: 2),
        borderRadius: BorderRadius.circular(borderRadius ?? 0),
        boxShadow: isProfile
            ? [
                BoxShadow(
                  color: Colors.grey.shade200,
                  offset: const Offset(0.0, 0.0),
                  blurRadius: 8,
                ),
              ]
            : [],
      ),
      child: isValidUrl
          ? ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius ?? 0),
              child: !url.endsWith('svg')
                  ? CachedNetworkImage(
                      imageUrl: url,
                      fit: fit,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) {
                        return Skeletonizer.zone(
                          child: Bone(
                            height: height,
                            width: width,
                            borderRadius:
                                BorderRadius.circular(borderRadius ?? 0),
                          ),
                        );
                      },
                      errorWidget: (context, url, error) {
                        return Image.network(
                          url,
                          errorBuilder: (context, error, stackTrace) =>
                              buildPlaceHolderImage(
                                  borderRadius, height, width),
                          fit: BoxFit.fill,
                        );
                      },
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(borderRadius ?? 0),
                      child: SvgPicture.network(
                        url,
                        placeholderBuilder: (context) => Skeletonizer.zone(
                          child: Bone(
                            height: height,
                            width: width,
                            borderRadius:
                                BorderRadius.circular(borderRadius ?? 0),
                          ),
                        ),
                        fit: fit,
                      ),
                    ))
          : placeholderString != ""
              ? _buildPlaceHolderProfile(
                  borderRadius,
                  height,
                  width,
                )
              : buildPlaceHolderImage(borderRadius, height, width),
    );
  }

  static Widget loadNetworkPhoto(
    String url, {
    Color? color = Colors.white,
    double? borderRadius,
    double? width,
    double? height,
    BoxFit fit = BoxFit.fill,
    bool isProfile = false,
    String placeholderString = "",
    BlendMode? backgroundBlendMode,
  }) {
    bool isValidUrl = Uri.tryParse(url)?.isAbsolute == true && url != "";
    return Container(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      decoration: BoxDecoration(
        backgroundBlendMode: backgroundBlendMode,
        color: color,
        // border: Border.all(color: AppColors.fieldBorderColor.withOpacity(0.2), width: 2),
        borderRadius: BorderRadius.circular(borderRadius ?? 0),
        boxShadow: isProfile
            ? [
                BoxShadow(
                  color: Colors.grey.shade200,
                  offset: const Offset(0.0, 0.0),
                  blurRadius: 8,
                ),
              ]
            : [],
      ),
      child: isValidUrl
          ? ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius ?? 0),
              child: !url.endsWith('svg')
                  ? CachedNetworkImage(
                      imageUrl: url,
                      fit: fit,
                      filterQuality: FilterQuality.medium,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) {
                        return buildPlaceHolderImage(
                            borderRadius, height, width);
                      },
                      errorWidget: (context, url, error) {
                        return Image.network(
                          url,
                          errorBuilder: (context, error, stackTrace) =>
                              buildPlaceHolderImage(
                                  borderRadius, height, width),
                          fit: BoxFit.fill,
                        );
                      },
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(borderRadius ?? 0),
                      child: SvgPicture.network(
                        url,
                        placeholderBuilder: (context) =>
                            buildPlaceHolderImage(borderRadius, height, width),
                        fit: fit,
                      ),
                    ))
          : placeholderString != ""
              ? _buildPlaceHolderProfile(
                  borderRadius,
                  height,
                  width,
                )
              : buildPlaceHolderImage(borderRadius, height, width),
    );
  }

  /// placeholder image
  static Widget buildPlaceHolderImage(
      double? borderRadius, double? height, double? width) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 0),
      child: Center(
        child: Image.asset(
          ImageConstants.profile,
          width: width ?? double.infinity,
          height: height ?? double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  /// placeholder profile
  /// placeholder profile
  static Widget _buildPlaceHolderProfile(
      double? borderRadius, double? height, double? width) {
    return Center(
      child: Image.asset(
        ImageConstants.profile,
        fit: BoxFit.cover,
        width: width ?? double.infinity,
        height: height ?? double.infinity,
      ),
    );
  }

  static Widget noDataView({
    String title = "",
    String subText = "",
    double? logoHeight = 100,
    double? logoWidth = 100,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          ImageConstants.noDataJson,
          height: 170,
        ),
        CommonText(
          text: title,
          fontWeight: FontWeightConstants.extraBold,
          fontSize: 18,
          color: AppColors.greenBlue,
        ),
        const SizedBox(
          height: 4,
        ),
        CommonText(
          text: subText,
          fontWeight: FontWeightConstants.medium,
          fontSize: 14,
          textAlign: TextAlign.center,
          color: AppColors.inactiveColor,
        ),
      ],
    );
  }

  static Future pickImageBottomSheet(
      {String titleName = "",
      Function(int)? callback,
      required BuildContext context}) async {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width - 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    CommonText(
                      //"Select upload option"
                      text: titleName,
                      fontFamily: FontFamilyConstants.epilogue,
                      color: AppColors.blackColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ).paddingOnly(top: 20, bottom: 40),
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        Get.back();
                        callback!(0);
                      },
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            ImageConstants.camera,
                            height: 20,
                            width: 22,
                            color: AppColors.blackColor,
                          ).paddingOnly(right: 10),
                          CommonText(
                            text: "takePhoto".tr,
                            fontFamily: FontFamilyConstants.epilogue,
                            color: AppColors.blackColor.withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ],
                      ).paddingOnly(left: 15, bottom: 10),
                    ),
                    Divider(
                      thickness: 0.5,
                      color: Colors.grey.withOpacity(0.8),
                    ).paddingOnly(right: 20, left: 20),
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        Get.back();
                        callback!(1);
                      },
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            ImageConstants.gallery,
                            height: 20,
                            width: 22,
                            color: AppColors.blackColor,
                          ).paddingOnly(right: 10),
                          CommonText(
                            text: "choseGallery".tr,
                            fontFamily: FontFamilyConstants.epilogue,
                            color: AppColors.blackColor.withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ],
                      ).paddingOnly(left: 20, bottom: 40),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.white),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                  ),
                  child: CommonText(
                    text: "cancel".tr,
                    fontFamily: FontFamilyConstants.epilogue,
                    color: AppColors.redColor.withOpacity(0.8),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
