import 'package:abyadpos_tab/core/config/api_client.dart';
import 'package:abyadpos_tab/core/constants/image_constants.dart';
import 'package:abyadpos_tab/core/theme/responsive.dart';
import 'package:abyadpos_tab/core/storage/sharedpref.dart';
import 'package:abyadpos_tab/core/theme/app_colors.dart';
import 'package:abyadpos_tab/core/theme/font_constants.dart';
import 'package:abyadpos_tab/main.dart';
import 'package:abyadpos_tab/features/auth/data/repositories/login_repo.dart';
import 'package:abyadpos_tab/features/auth/presentation/controllers/user_cubit.dart';
import 'package:abyadpos_tab/features/home/presentation/screens/home_screen.dart';
import 'package:abyadpos_tab/core/widgets/loader/loading_cubit.dart';
import 'package:abyadpos_tab/core/widgets/common_methods.dart';
import 'package:abyadpos_tab/core/widgets/common_outlined_button.dart';
import 'package:abyadpos_tab/core/widgets/common_text.dart';
import 'package:abyadpos_tab/core/widgets/common_text_field.dart';
import 'package:abyadpos_tab/core/widgets/ui_helpers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide Transition;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:responsive_ui/responsive_ui.dart';

import 'package:abyadpos_tab/core/widgets/custom_drawer.dart';
import 'package:abyadpos_tab/features/dashboard/presentation/controllers/drawer_cubit.dart';
import 'package:abyadpos_tab/features/dashboard/presentation/controllers/drawer_state.dart';
import 'package:abyadpos_tab/features/settings/presentation/screens/settings_screen.dart';
import 'package:abyadpos_tab/features/settings/presentation/screens/update_prices_screen.dart';
import 'package:abyadpos_tab/features/auth/presentation/controllers/login_bloc.dart';
import 'package:abyadpos_tab/features/auth/presentation/controllers/login_event.dart';
import 'package:abyadpos_tab/features/auth/presentation/controllers/login_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          LoginBloc(loginRepo: LoginRepo(apiClient: ApiClient(), sharedPref: SharedPref()))
            ..add(LoadAppVersionEvent()),
      child: const _LoginScreenView(),
    );
  }
}

class _LoginScreenView extends StatefulWidget {
  const _LoginScreenView();

  @override
  State<_LoginScreenView> createState() => _LoginScreenViewState();
}

class _LoginScreenViewState extends State<_LoginScreenView> {
  late final TextEditingController userNameController;
  late final TextEditingController passWordController;
  late final FocusNode userNameFocusNode;
  late final FocusNode passWordFocusNode;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    userNameController = TextEditingController();
    passWordController = TextEditingController();
    userNameFocusNode = FocusNode();
    passWordFocusNode = FocusNode();

    if (kDebugMode) {
      userNameController.text = 'Abyad@abyad.com';
      passWordController.text = 'Abyad@2025';
    }
  }

  @override
  void dispose() {
    userNameController.dispose();
    passWordController.dispose();
    userNameFocusNode.dispose();
    passWordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status == LoginStatus.loading) {
          context.read<LoadingCubit>().showLoading();
        } else {
          context.read<LoadingCubit>().hideLoading();

          if (state.status == LoginStatus.success) {
            final provider = context.read<UserCubit>();
            provider.fetchProfile(context: context);
            provider.loadPref(context);
            provider.callApi(context);
            Get.off(() => HomeScreen(reload: true));
          } else if (state.status == LoginStatus.needsSetup) {
            // 1. نقرأ الكيوبت
            final cubit = context.read<SideMenuCubit>();

// 2. نتحقق إذا كانت القائمة مش على "الإعدادات" (علشان نحدد changed بـ true ولا false)
            bool changed = cubit.state.selectedItem != SideMenuItem.settings;

            if (changed) {
              // 3. نحدث حالة القائمة الجانبية للإعدادات
              cubit.changeMenuItem(SideMenuItem.settings);

              // 4. نروح لشاشة الإعدادات ونمسح اللي قبلها
              Get.offAll(() => const SettingsScreen(), transition: Transition.noTransition);
            }

// 5. نفتح شاشة تحديث الأسعار
            Get.off(() => const UpdatePricesScreen());
          } else if (state.status == LoginStatus.failure && state.errorMessage != null) {
            UIHelper.showBottomFlash(
              context,
              title: "Login Failed",
              message: state.errorMessage!,
              isError: true,
            );
          }
        }
      },
      builder: (context, state) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.whiteColor,
          ),
          child:
              MyResponsive.isMobile(context) ? mobileUi(context, state) : tabletUi(context, state),
        );
      },
    );
  }

  Scaffold tabletUi(BuildContext context, LoginState state) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.whiteColor,
          image: DecorationImage(
            image: AssetImage(ImageConstants.loginBack),
            fit: BoxFit.cover,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: _buildLoginForm(context, state),
            ),
            Expanded(
              flex: 5,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/images/png/banner.jpg'),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Image.asset(
                        ImageConstants.dummy_logo,
                        height: 100.h,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Scaffold mobileUi(BuildContext context, LoginState state) {
    return Scaffold(
      backgroundColor: AppColors.transparentColor,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar:
          isMobile ? signInButton(context, state).marginAll(10) : Container(height: 0.0),
      body: SafeArea(
        child: Stack(
          children: [
            bodyContent(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context, LoginState state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          state.isForgotPassword
              ? TextButton.icon(
                  onPressed: () {
                    context.read<LoginBloc>().add(ToggleForgotPasswordEvent());
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.primaryColor,
                  ),
                  label: CommonText(
                    text: "Back".tr,
                    color: AppColors.primaryColor,
                    fontSize: FontConstants.font_13,
                    fontWeight: FontWeightConstants.semiBold,
                  ),
                )
              : Container(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 20.h),
            margin: EdgeInsets.all(40.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20,
                  offset: Offset(5, 5),
                )
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(
                      ImageConstants.dummy_logo,
                      height: 100.h,
                      width: 100.w,
                    ),
                  ),
                  UIHelper.verticalSpaceSm,
                  Text(
                    state.isForgotPassword ? "forGotPassword".tr : "signIn".tr,
                    style: TextStyle(
                      fontSize: 19.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greenBlue,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  SizedBox(height: 30.h),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        userIdField(context, state),
                        SizedBox(height: 30.h),
                        state.isForgotPassword ? Container() : passwordField(context, state),
                        state.isForgotPassword ? Container() : SizedBox(height: 20.h),
                        signInButton(context, state),
                        SizedBox(height: 10.h),
                        state.isForgotPassword
                            ? UIHelper.verticalSpaceMd
                            : Center(
                                child: MaterialButton(
                                  onPressed: () {
                                    context.read<LoginBloc>().add(ToggleForgotPasswordEvent());
                                  },
                                  child: CommonText(
                                    text: "forGotPassword".tr,
                                    color: AppColors.primaryColor,
                                    fontSize: FontConstants.font_13,
                                    fontWeight: FontWeightConstants.medium,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: GestureDetector(
              onTap: () async {
                context.read<LoadingCubit>().showLoading();
                await UserCubit(ApiClient()).checkAppVersionV2(context);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.appVersion,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.system_update,
                    color: Colors.blue,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          UIHelper.verticalSpaceSm,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: Row(
              children: [
                Text(
                  "© 2025 Abyad. All rights reserved.".tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.greenBlue.withOpacity(0.6),
                  ),
                ),
                const Spacer(),
                MaterialButton(
                  onPressed: () {
                    if (isArabic) {
                      Get.updateLocale(const Locale('en', 'US'));
                      SharedPref().setString('language', 'en');
                      isArabic = false;
                    } else {
                      Get.updateLocale(const Locale('ar', 'SA'));
                      SharedPref().setString('language', 'ar');
                      isArabic = true;
                    }
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        ImageConstants.languagesvg,
                        width: 21.sp,
                      ),
                      UIHelper.horizontalSpaceSm5,
                      CommonText(
                        text: isArabic ? "EN" : "AR",
                        color: AppColors.primaryColor,
                        fontSize: FontConstants.font_13,
                        fontWeight: FontWeightConstants.semiBold,
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget bodyContent(BuildContext context, LoginState state) {
    return SizedBox(
      width: Get.width,
      height: Get.height,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Responsive(
          alignment: WrapAlignment.spaceEvenly,
          children: [
            Div(
              divison: const Division(colXL: 4, colL: 4, colM: 12, colS: 12, colXS: 12),
              child: SizedBox(
                height: isMobile ? Get.height * 0.2 : Get.height,
                child: Center(
                  child: Image.asset(ImageConstants.dummy_logo),
                ),
              ),
            ),
            Div(
              divison: const Division(colXL: 6, colL: 6, colM: 12, colS: 12, colXS: 12),
              child: SingleChildScrollView(
                child: SizedBox(
                  height: isMobile ? Get.height * 0.7 : Get.height,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: CommonText(
                                text: "signIn".tr,
                                color: AppColors.greenBlue,
                                fontSize: isMobile ? FontConstants.font_22 : FontConstants.font_28,
                                fontWeight: FontWeightConstants.extraBold,
                              ),
                            ),
                            CommonText(
                              text: "loginLabel".tr,
                              color: AppColors.greenBlue.withOpacity(0.6),
                              fontSize: FontConstants.font_14,
                              fontWeight: FontWeightConstants.medium,
                            ),
                            SizedBox(height: 50.h),
                            userIdField(context, state),
                            SizedBox(height: 30.h),
                            passwordField(context, state),
                            SizedBox(height: 20.h),
                            forgotPasswordWidget(context),
                            SizedBox(height: 40.h),
                            isMobile ? Container() : signInButton(context, state),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget signInButton(BuildContext context, LoginState state) {
    return CommonOutlinedButton(
      onPressed: () async {
        if (formKey.currentState!.validate()) {
          if (!state.isForgotPassword) {
            context.read<LoadingCubit>().showLoading();

            context.read<LoadingCubit>().hideLoading();

            context.read<LoginBloc>().add(
                  SubmitFormEvent(
                    email: userNameController.text,
                    password: passWordController.text,
                  ),
                );
          } else {}
        }
      },
      buttonText: state.isForgotPassword ? "Send".tr : "signIn".tr,
      buttonColor: AppColors.primaryColor,
      buttonTextColor: Colors.white,
      borderRadius: isMobile ? 30.r : 0.0,
      fontSize: FontConstants.font_18,
      fontWeight: FontWeightConstants.semiBold,
      buttonHeight: isMobile ? null : 45.h,
    );
  }

  Widget userIdField(BuildContext context, LoginState state) {
    return CommonTextField(
      lableText: "email".tr,
      suffixIcon: Transform.scale(
        scale: 0.7,
        child: SvgPicture.asset(
          ImageConstants.person,
        ),
      ),
      focusNode: userNameFocusNode,
      validationRegex: CommonMethods.emailRegExp,
      nextFocusNode: passWordFocusNode,
      autoValidateMode: AutovalidateMode.onUserInteraction,
      floatLabelColor: AppColors.greenBlue,
      errorMessage: "${"emptyText".tr}${"email".tr.toLowerCase()}",
      validationMessage: "${"validText".tr}${"email".tr.toLowerCase()}",
      textEditingController: userNameController,
      labelColor: AppColors.greenBlue.withOpacity(0.24),
      borderColor: AppColors.primaryColor,
      textInputType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      filledColor: AppColors.filledTextColor,
      filled: true,
      borderRadius: isMobile ? 30.sp : 0.0,
      labelFontSize: FontConstants.font_13,
      inputFontSize: isMobile ? null : FontConstants.font_14,
      contentPadding: isMobile ? null : EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.r),
    );
  }

  Widget forgotPasswordWidget(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<LoginBloc>().add(ToggleForgotPasswordEvent());
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5),
        child: Align(
          alignment: Alignment.topRight,
          child: CommonText(
            text: "forGotPassword".tr,
            color: AppColors.primaryColor,
            fontSize: FontConstants.font_16,
            fontWeight: FontWeightConstants.medium,
          ),
        ),
      ),
    );
  }

  Widget passwordField(BuildContext context, LoginState state) {
    return CommonTextField(
      lableText: "enterPassword".tr,
      focusNode: passWordFocusNode,
      obscureText: state.isObscure,
      maxLines: 1,
      floatLabelColor: AppColors.greenBlue,
      suffixIcon: GestureDetector(
        onTap: () {
          context.read<LoginBloc>().add(TogglePasswordVisibilityEvent());
        },
        child: Transform.scale(
          scale: 0.7,
          child: SvgPicture.asset(
            state.isObscure ? ImageConstants.eye : ImageConstants.eyeSlash,
            height: isMobile ? 20.h : 30.w,
          ),
        ),
      ),
      textEditingController: passWordController,
      autoValidateMode: AutovalidateMode.onUserInteraction,
      labelColor: AppColors.greenBlue.withOpacity(0.24),
      borderColor: AppColors.primaryColor,
      validationMessage: "${"validText".tr}${"password".tr.toLowerCase()}",
      errorMessage: "${"emptyText".tr}${"password".tr.toLowerCase()}",
      textInputType: TextInputType.visiblePassword,
      filledColor: AppColors.filledTextColor,
      filled: true,
      borderRadius: isMobile ? 30.sp : 0.0,
      labelFontSize: FontConstants.font_13,
      inputFontSize: isMobile ? null : FontConstants.font_14,
      contentPadding: isMobile ? null : EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.r),
    );
  }
}
