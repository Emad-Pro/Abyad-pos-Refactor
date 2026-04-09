import 'package:abyadpos_tab/core/constants/image_constants.dart';
import 'package:abyadpos_tab/core/theme/app_colors.dart';
import 'package:abyadpos_tab/core/theme/font_constants.dart';
import 'package:abyadpos_tab/main.dart';
import 'package:abyadpos_tab/features/auth/presentation/controllers/user_cubit.dart';
import 'package:abyadpos_tab/features/auth/presentation/controllers/user_state.dart';
import 'package:abyadpos_tab/core/widgets/loader/loading_cubit.dart';
import 'package:abyadpos_tab/core/widgets/back_button.dart';
import 'package:abyadpos_tab/core/widgets/common_outlined_button.dart';
import 'package:abyadpos_tab/core/widgets/common_text.dart';
import 'package:abyadpos_tab/core/widgets/common_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController old = TextEditingController();
  final TextEditingController newPass = TextEditingController();
  final TextEditingController confirmPass = TextEditingController();

  final FocusNode fold = FocusNode();
  final FocusNode fnewPass = FocusNode();
  final FocusNode fconfirmPass = FocusNode();
  bool oldPassObs = true;
  bool newPassObs = true;
  bool confirmPassObs = true;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
          color: AppColors.whiteColor,
          image: DecorationImage(
            image: AssetImage(
              ImageConstants.loginBack,
            ),
            fit: BoxFit.cover,
          )),
      child: BlocConsumer<UserCubit, UserState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.transparentColor,
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BackIcon(
                      background: true,
                    ).paddingSymmetric(vertical: 10),
                    bodyContent(
                      context.read<UserCubit>(),
                      context,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget bodyContent(
    UserCubit state,
    BuildContext context,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              ImageConstants.dummy_logo,
              height: 100,
            ).paddingSymmetric(vertical: 20.h),

            // SvgPicture.asset(
            //   ImageConstants.logo,
            //   height: 100.h,
            //   // width: 216.w,
            // ).paddingSymmetric(vertical: 20.h),
            Expanded(
              flex: 2,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  primary: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: CommonText(
                          text: "changePass".tr,
                          color: AppColors.greenBlue,
                          fontSize: FontConstants.font_22,
                          fontWeight: FontWeightConstants.extraBold,
                        ),
                      ),
                      CommonText(
                        text: "changePassLabel".tr,
                        color: AppColors.greenBlue.withOpacity(0.6),
                        fontSize: FontConstants.font_16,
                        fontWeight: FontWeightConstants.medium,
                      ),
                      SizedBox(
                        height: 30.h,
                      ),
                      inputField(
                        context,
                        obsecure: oldPassObs,
                        labelTaext: "oldPassword".tr,
                        controller: old,
                        nextFocus: fnewPass,
                        focus: fold,
                        onObsecureChange: () {
                          setState(() {
                            oldPassObs = !oldPassObs;
                          });
                        },
                      ),
                      inputField(
                        context,
                        obsecure: newPassObs,
                        labelTaext: "newPassword".tr,
                        controller: newPass,
                        nextFocus: fconfirmPass,
                        focus: fnewPass,
                        onObsecureChange: () {
                          setState(() {
                            newPassObs = !newPassObs;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "New password is required.".tr;
                          }
                          if (value.length < 8) {
                            return "Password must be at least 8 characters.".tr;
                          }

                          return null;
                        },
                      ),
                      inputField(
                        context,
                        obsecure: confirmPassObs,
                        labelTaext: "confirmPass".tr,
                        controller: confirmPass,
                        focus: fconfirmPass,
                        onObsecureChange: () {
                          setState(() {
                            confirmPassObs = !confirmPassObs;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Confirm password is required.".tr;
                          }
                          if (value.length < 8) {
                            return "Password must be at least 8 characters.".tr;
                          }
                          if (newPass.text != confirmPass.text) {
                            return "Password does not match.".tr;
                          }

                          return null;
                        },
                      ),
                      SizedBox(
                        height: 40.sp,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            CommonOutlinedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  var body = {"old_password": old.text, "new_password": newPass.text};
                  context.read<LoadingCubit>().showLoading();
                  await context.read<UserCubit>().changePassword(context, body);
                  context.read<LoadingCubit>().hideLoading();
                }
              },
              buttonHeight: isMobile ? 50.h : 60.h,
              buttonText: "save".tr,
              buttonColor: AppColors.primaryColor,
              buttonTextColor: Colors.white,
              borderRadius: 30.r,
              fontSize: FontConstants.font_20,
              fontWeight: FontWeightConstants.semiBold,
            ),
          ],
        ),
      ),
    );
  }

  Widget inputField(BuildContext context,
      {required labelTaext,
      focus,
      required controller,
      required obsecure,
      nextFocus,
      validationRegex,
      validMessage,
      errorMessage,
      isReadOnly,
      validator,
      onObsecureChange}) {
    return CommonTextField(
      lableText: labelTaext,
      focusNode: focus,
      obscureText: obsecure,
      autoValidateMode: AutovalidateMode.onUserInteraction,
      maxLines: 1,
      floatLabelColor: AppColors.greenBlue,
      suffixIcon: GestureDetector(
        onTap: onObsecureChange,
        child: Transform.scale(
          scale: 0.7,
          child: SvgPicture.asset(
            oldPassObs ? ImageConstants.eye : ImageConstants.eyeSlash,
            // height: 20.h,
          ),
        ),
      ),
      // validationRegex: CommonMethods.passRegExp,
      nextFocusNode: nextFocus,
      textEditingController: controller,
      labelColor: AppColors.greenBlue.withOpacity(0.24),
      borderColor: AppColors.primaryColor,
      validationMessage: "validText".tr + "password".tr.toLowerCase(),
      errorMessage: "emptyText".tr + "password".tr.toLowerCase(),
      textInputType: TextInputType.visiblePassword,
      filledColor: AppColors.filledTextColor,
      filled: true,
      textInputAction: TextInputAction.next,
      borderRadius: 30.sp,

      validator: validator,
      labelFontSize: FontConstants.font_14,
      // hintFontSize: FontConstants.font_14,
    ).paddingSymmetric(vertical: 8);
  }
}
