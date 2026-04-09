import 'dart:ui';

import 'package:abyadpos_tab/core/constants/image_constants.dart';
import 'package:abyadpos_tab/core/enums/animation_type.dart';
import 'package:abyadpos_tab/core/theme/app_colors.dart';
import 'package:abyadpos_tab/core/theme/font_constants.dart';
import 'package:abyadpos_tab/core/widgets/common_outlined_button.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import 'package:abyadpos_tab/core/utils/animation_util/custom_slide_animation.dart';

import 'package:abyadpos_tab/core/widgets/common_text.dart';
import 'package:abyadpos_tab/core/widgets/common_text_field.dart';

class CustomDialog {
  /// common dialog with two button
  static showCommonDialog(
      {required BuildContext screenContext,
      bool isDismissible = false,
      String titleName = "",
      String positiveButtonText = "",
      Widget? content,
      String negativeButtonText = "",
      bool showReason = false,
      bool isMobile = false,
      bool showAction = false,
      bool backgroundBlur = true,
      AnimationType? animationType,
      TextEditingController? controller,
      required Function(int) callback}) {
    showDialog(
      barrierDismissible: isDismissible,
      context: screenContext,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: CustomSlideTransition(
            animationType: animationType ?? AnimationType.bottomToTop,
            child: PopScope(
              canPop: isDismissible,
              onPopInvoked: (value) {
                callback(0);
              },
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 5,
                  sigmaY: 5,
                ),
                child: Dialog(
                  surfaceTintColor: AppColors.transparentColor,
                  backgroundColor: AppColors.transparentColor,
                  insetPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 24,
                  ),
                  //this right here
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(45.r),
                      //  border: const GradientBoxBorder(
                      // gradient: LinearGradient(
                      //   colors: [Colors.white, Colors.transparent],
                      //   begin: Alignment.topCenter,
                      //   end: Alignment.bottomCenter,
                      // ),
                      // width: 2,
                      // ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.r),
                          color: AppColors.whiteColor),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Form(
                          //  key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              if (titleName.isNotEmpty) ...[
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      ImageConstants.BG,
                                      height: 100.h,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: CommonText(
                                        text: titleName,
                                        fontSize: FontConstants.font_28,
                                        color: AppColors.greenBlue,
                                        fontWeight: FontWeightConstants.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                SvgPicture.asset(
                                  ImageConstants.line,
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                              ],
                              if (content != null) ...[
                                content
                              ] else ...[
                                isMobile
                                    ? Container(
                                        padding: const EdgeInsets.all(8.0),
                                        margin: const EdgeInsets.all(8.0),
                                        child: CommonTextField(
                                          filled: true,
                                          prefixIcon: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SvgPicture.asset(
                                                ImageConstants.mobile,
                                                height: 50.h,
                                                width: 50.w,
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              CommonText(
                                                text: '966',
                                                fontSize: FontConstants.font_36,
                                                fontWeight:
                                                    FontWeightConstants.bold,
                                                color: AppColors.greenBlue,
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              SizedBox(
                                                  height: 34.h,
                                                  child: const VerticalDivider(
                                                    thickness: 1,
                                                    color: AppColors.greenBlue,
                                                  )),
                                            ],
                                          ).marginOnly(left: 10),
                                          filledColor: AppColors.filledTextColor,
                                          borderRadius: 30.r,
                                          inputFormat: [mobileFormat],
                                          borderColor: Colors.transparent,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 15),
                                          hintText: '55-123-4545',
                                          hintFontSize: FontConstants.font_36,
                                          textEditingController: controller,
                                          inputFontSize: FontConstants.font_36,
                                          inputFontWeight:
                                              FontWeightConstants.bold,
                                          textColor: AppColors.greenBlue,
                                          textInputType: TextInputType.number,
                                          autofocus: true,
                                          maxLines: 1,
                                          hintFontWeight:
                                              FontWeightConstants.bold,
                                          hintColor: AppColors.greenBlue
                                              .withOpacity(0.2),
                                          onFieldSubmitted: (value) {
                                            Get.back();
                                          },
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CommonTextField(
                                          filled: true,
                                          borderRadius: 30.r,
                                          maxLines: 1,
                                          // Removed input formatters related to numbers
                                          borderColor: Colors.transparent,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 15),
                                          hintText: '',
                                          hintFontSize: FontConstants.font_48,
                                          textEditingController: controller,
                                          // Ensure this is a TextEditingController
                                          inputFontSize: FontConstants.font_48,
                                          inputFontWeight:
                                              FontWeightConstants.bold,
                                          textColor: AppColors.greenBlue,
                                          textInputType: TextInputType.text,
                                          // Changed to text input
                                          autofocus: true,
                                          textAlign: TextAlign.center,
                                          hintFontWeight:
                                              FontWeightConstants.bold,
                                          hintColor: AppColors.greenBlue
                                              .withOpacity(0.2),
                                          onFieldSubmitted: (value) {
                                            Get.back();
                                          },
                                        ),
                                      )
          
                                // Padding(
                                //         padding: const EdgeInsets.all(8.0),
                                //         child: CommonTextField(
                                //           filled: true,
                                //           // suffixIcon: Row(
                                //           //   mainAxisSize: MainAxisSize.min,
                                //           //   children: [
                                //           //     SizedBox(
                                //           //         height: 80.h,
                                //           //         child: const VerticalDivider(
                                //           //           thickness: 1,
                                //           //           color: AppColors.greenBlue,
                                //           //         )),
                                //           //     const SizedBox(
                                //           //       width: 10,
                                //           //     ),
                                //           //     CommonText(
                                //           //       text: 'SAR',
                                //           //       fontSize: FontConstants.font_48,
                                //           //       fontWeight:
                                //           //           FontWeightConstants.semiBold,
                                //           //       color: AppColors.greenBlue,
                                //           //     ),
                                //           //     const SizedBox(
                                //           //       width: 5,
                                //           //     ),
                                //           //   ],
                                //           // ).marginOnly(left: 10),
                                //           borderRadius: 30.r,
                                //           maxLines: 1,
                                //           // inputFormat: [
                                //           //   FilteringTextInputFormatter.allow(
                                //           //       RegExp(r'\d')),
                                //           //   FilteringTextInputFormatter.deny(" "),
                                //           //   NumberTextFormatter()
                                //           // ],
                                //           borderColor: Colors.transparent,
                                //           contentPadding:
                                //               const EdgeInsets.symmetric(
                                //                   vertical: 15),
                                //           hintText: '',
                                //           hintFontSize: FontConstants.font_48,
                                //           textEditingController: controller,
                                //           // onChanged: (text) {
                                //           //   screenContext
                                //           //       .read<CartBloc>()
                                //           //       .add(const CartEvent.total());
                                //           // },
                                //           inputFontSize: FontConstants.font_48,
                                //           inputFontWeight:
                                //               FontWeightConstants.bold,
                                //           textColor: AppColors.greenBlue,
                                //           textInputType: TextInputType.text,
                                //           autofocus: true,
                                //           textAlign: TextAlign.center,
                                //           hintFontWeight:
                                //               FontWeightConstants.bold,
                                //           hintColor: AppColors.greenBlue
                                //               .withOpacity(0.2),
                                //           onFieldSubmitted: (value) {
                                //             context.pop(value);
                                //           },
                                //         ),
                                //       )
                              ],
                              showAction
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 16.0, bottom: 10),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: CommonOutlinedButton(
                                              allowAnimation: false,
                                              buttonTextColor:
                                                  AppColors.greenBlue,
                                              buttonText: negativeButtonText,
                                              fontWeight:
                                                  FontWeightConstants.bold,
                                              fontSize: FontConstants.font_24,
                                              buttonColor: AppColors.whiteColor,
                                              buttonHeight: 45,
                                              borderColor: AppColors.greenBlue,
                                              onPressed: () {
                                                Navigator.pop(context);
                                                callback(1);
                                              },
                                            ).paddingAll(15),
                                          ),
                                          Expanded(
                                            child: CommonOutlinedButton(
                                              allowAnimation: false,
                                              buttonTextColor:
                                                  AppColors.whiteColor,
                                              buttonText: positiveButtonText,
                                              fontWeight:
                                                  FontWeightConstants.bold,
                                              fontSize: FontConstants.font_24,
                                              buttonColor: AppColors.greenBlue,
                                              buttonHeight: 45,
                                              onPressed: () {
                                                Navigator.pop(context);
                                                callback(2);
                                              },
                                            ).paddingAll(15),
                                          ),
                                        ],
                                      ),
                                    )
                                  : const SizedBox(),
                              const SizedBox(
                                width: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

var mobileFormat = MaskTextInputFormatter(
  mask: '########',
  filter: {"#": RegExp(r'\d')},
  type: MaskAutoCompletionType.lazy,
);
var mobileFormat2 = MaskTextInputFormatter(
  mask: '05########',
  filter: {"#": RegExp(r'[0-9]')}, // Only allow digits
  type: MaskAutoCompletionType.lazy,
);
var amountFormat = MaskTextInputFormatter(
  mask: '-#####',
  filter: {"#": RegExp(r'\d')},
  type: MaskAutoCompletionType.lazy,
);
