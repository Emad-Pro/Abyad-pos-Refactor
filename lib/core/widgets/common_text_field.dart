import 'package:abyadpos_tab/core/theme/app_colors.dart';
import 'package:abyadpos_tab/core/theme/font_constants.dart';
import 'package:abyadpos_tab/core/theme/ui_constants.dart';
import 'package:abyadpos_tab/core/widgets/common_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:abyadpos_tab/core/widgets/common_text.dart';

class CommonTextField extends StatelessWidget {
  final bool allowAnimation;
  final AutovalidateMode? autoValidateMode;
  final bool autofocus;
  final bool expands;
  final bool readOnly;
  final bool enabled;
  final bool filled;
  final Color? filledColor;
  final TextEditingController? textEditingController;
  final Color textColor;
  final TextAlign textAlign;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool obscureText;
  EdgeInsets? contentPadding;

  final double? letterSpacing;
  final double? wordSpacing;
  final double? inputFontSize;
  final FontWeight inputFontWeight;
  final double? headerFontSize;
  final FontWeight? headerFontWeight;
  final String fontFamily;
  final String? headerText;
  final String? counterText;
  final String? lableText;
  final String? hintText;
  final bool? showLabelText;
  final Color hintColor;
  final Color? labelColor;
  final Color? floatLabelColor;
  final double? hintFontSize;
  final double? labelFontSize;
  final FontWeight? hintFontWeight;
  final FontWeight? labelWeight;
  final Color? borderColor;
  final Color enabledBorderColor;
  final double borderRadius;
  final Function? onEditingComplete;
  final Function? onFieldSubmitted;
  final Function(String)? onChanged;
  final Function? onTap;

  /// validation
  final bool allowValidation;
  final String? errorMessage;
  final String? validationMessage;
  final String? validationRegex;
  final int? value;
  final int? length;
  final String? prefixText;
  final String? lengthMessage;
  final FocusNode? focusNode;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter> inputFormat;
  final TextInputType textInputType;

  final TextInputAction textInputAction;
  final FocusNode? nextFocusNode;
  final TextCapitalization textCapitalization;
  var validator;

  CommonTextField({
    super.key,
    this.allowAnimation = false,
    this.autoValidateMode,
    this.autofocus = false,
    this.expands = false,
    this.readOnly = false,
    this.enabled = true,
    this.filled = false,
    this.enabledBorderColor = AppColors.transparentColor,
    this.filledColor,
    this.textEditingController,
    this.textColor = AppColors.primaryColor,
    this.labelColor,
    this.floatLabelColor,
    this.textAlign = TextAlign.start,
    this.suffixIcon,
    this.prefixIcon,
    this.obscureText = false,
    this.contentPadding,
    this.letterSpacing,
    this.wordSpacing,
    this.inputFontSize,
    this.inputFontWeight = FontWeightConstants.medium,
    this.headerFontSize,
    this.headerFontWeight,
    this.fontFamily = FontFamilyConstants.epilogue,
    this.headerText,
    this.counterText,
    this.lableText,
    this.hintText,
    this.showLabelText = false,
    this.hintColor = AppColors.greenBlue,
    this.hintFontSize,
    this.labelFontSize,
    this.hintFontWeight,
    this.labelWeight,
    this.borderColor = AppColors.infoLightGreyColor,
    this.borderRadius = UIConstants.kTextFieldBorderRadius,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.onChanged,
    this.onTap,
    this.allowValidation = true,
    this.errorMessage,
    this.validationMessage,
    this.validationRegex,
    this.validator,
    this.value,
    this.length,
    this.prefixText,
    this.lengthMessage,
    this.focusNode,
    this.minLines,
    this.maxLines,
    this.maxLength,
    this.inputFormat = const [],
    this.textInputType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.nextFocusNode,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showLabelText!) ...[
              CommonText(
                text: hintText!,
                fontSize: hintFontSize ?? FontConstants.font_13,
                fontWeight: FontWeight.w400,
                fontFamily: FontFamilyConstants.epilogue,
                textAlign: TextAlign.center,
                color: labelColor ?? AppColors.labelColor,
              ).marginOnly(
                bottom: 5,
              ),
            ],
            TextFormField(
              autovalidateMode: autoValidateMode,

              magnifierConfiguration: TextMagnifierConfiguration.disabled,
              validator: validator ??
                  (text) {
                    if (textEditingController!.text.trim().isEmpty &&
                        allowValidation) {
                      return errorMessage ?? "Invalid errorMessage";
                    } else if (value != null &&
                        (int.parse(textEditingController!.text.trim().trim()) >
                            value!)) {
                      return validationMessage ?? "Invalid value";
                    } else if (length != null && lengthMessage != null) {
                      if (textEditingController!.text.trim().length < length! ||
                          textEditingController!.text.trim().length > length!) {
                        return lengthMessage;
                      }
                    } else if (validationRegex != null) {
                      if (!RegExp(validationRegex!).hasMatch(text!.trim())) {
                        return validationMessage ??
                            "Invalid Validation Message";
                      }
                    }
                    return null;
                  },
              textAlign: textAlign,
              controller: textEditingController,
              enabled: enabled,
              readOnly: readOnly,
              expands: expands,
              obscureText: obscureText,
              obscuringCharacter: "*",
              autofocus: autofocus,
              focusNode: focusNode,
              maxLength: maxLength,
              minLines: minLines,
              maxLines: maxLines,
              keyboardType: textInputType,
              textInputAction: textInputAction,
              textCapitalization: textCapitalization,
              inputFormatters: inputFormat.isEmpty ? null : inputFormat,
              decoration: InputDecoration(
                contentPadding: contentPadding ??
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.r),
                alignLabelWithHint: true,
                focusColor: AppColors.transparentColor,
                floatingLabelStyle: TextStyle(
                    color: floatLabelColor ?? labelColor,
                    fontSize: labelFontSize ?? FontConstants.font_24,
                    fontWeight: labelWeight ?? inputFontWeight,
                    fontFamily: fontFamily),
                labelText: lableText,
                labelStyle: TextStyle(
                    color: labelColor,
                    fontSize: labelFontSize ?? FontConstants.font_20,
                    fontWeight: labelWeight ?? inputFontWeight,
                    fontFamily: fontFamily),
                counterStyle: const TextStyle(color: AppColors.greyColor),
                counterText: counterText,
                fillColor: filledColor ?? AppColors.whiteColor,
                filled: filled,
                hintText: showLabelText! ? "" : hintText,
                hintStyle: TextStyle(
                  color: hintColor.withOpacity(0.24),
                  fontSize: hintFontSize ?? FontConstants.font_12,
                  fontWeight: hintFontWeight ?? inputFontWeight,
                  letterSpacing: letterSpacing,
                  fontFamily: fontFamily,
                  wordSpacing: wordSpacing,
                ),
                errorStyle: const TextStyle(
                  color: AppColors.redColor,
                ),
                errorMaxLines: 3,
                prefixIcon: prefixIcon == null
                    ? null
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: prefixIcon,
                      ),
                suffixIcon: suffixIcon == null
                    ? null
                    : SizedBox(
                        height: 10,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: suffixIcon,
                        ),
                      ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide:
                      BorderSide(color: borderColor ?? AppColors.whiteColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide(
                    color: enabledBorderColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide(
                    color: borderColor ?? AppColors.transparentColor,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: const BorderSide(
                    color: AppColors.redColor,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: const BorderSide(
                    color: AppColors.redColor,
                  ),
                ),
              ),
              cursorColor: AppColors.hintColor,
              // cursorHeight: 16,
              style: TextStyle(
                fontSize: inputFontSize ?? FontConstants.font_16,
                color:
                    enabled == false ? textColor.withOpacity(0.3) : textColor,
                fontWeight: inputFontWeight,
                fontFamily: fontFamily,
                letterSpacing: letterSpacing,
                wordSpacing: wordSpacing,
              ),

              onChanged: (value) {
                onChanged?.call(value);
              },
              onTap: () {
                onTap?.call();
              },
              onEditingComplete: () {
                onEditingComplete?.call();
              },
              onFieldSubmitted: (value) {
                onFieldSubmitted?.call(value);
                if (textInputAction == TextInputAction.done) {
                  CommonMethods.hideKeyboard(context);
                } else if (textInputAction == TextInputAction.next) {
                  FocusScope.of(context).requestFocus(
                    nextFocusNode,
                  );
                }
              },
              onTapOutside: (event) => CommonMethods.hideKeyboard(context),
            ),
          ],
        );
      },
    );
  }
}
