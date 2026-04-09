import 'package:abyadpos_tab/core/constants/app_value_constants.dart';
import 'package:abyadpos_tab/core/constants/image_constants.dart';
import 'package:abyadpos_tab/features/auth/data/models/profile_model.dart';
import 'package:abyadpos_tab/core/enums/language_code.dart';
import 'package:abyadpos_tab/core/enums/pick_image_type.dart';
import 'package:abyadpos_tab/core/theme/app_colors.dart';
import 'package:abyadpos_tab/core/theme/font_constants.dart';
import 'package:abyadpos_tab/main.dart';
import 'package:abyadpos_tab/features/auth/presentation/controllers/user_cubit.dart';
import 'package:abyadpos_tab/features/auth/presentation/controllers/user_state.dart';
import 'package:abyadpos_tab/core/widgets/loader/loading_cubit.dart';
import 'package:abyadpos_tab/core/widgets/back_button.dart';
import 'package:abyadpos_tab/core/widgets/common_methods.dart';
import 'package:abyadpos_tab/core/widgets/common_outlined_button.dart';
import 'package:abyadpos_tab/core/widgets/common_profile_avatar.dart';
import 'package:abyadpos_tab/core/widgets/common_text.dart';
import 'package:abyadpos_tab/core/widgets/common_text_field.dart';
import 'package:abyadpos_tab/core/widgets/common_widgets.dart';
import 'package:abyadpos_tab/core/widgets/inverted_icon.dart';
import 'package:abyadpos_tab/core/widgets/snackbar_widget.dart';
import 'package:abyadpos_tab/core/widgets/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:place_picker_v2/place_picker.dart';

import 'package:responsive_ui/responsive_ui.dart';

import 'package:skeletonizer/skeletonizer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  XFile? placeholder;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController additionalController = TextEditingController();
  final TextEditingController openingAt = TextEditingController();
  final TextEditingController clossingAt = TextEditingController();

  final FocusNode emailFocus = FocusNode();
  final FocusNode userNameFocus = FocusNode();
  final FocusNode addressFocus = FocusNode();
  final FocusNode descriptionFocus = FocusNode();

  final FocusNode additionalFocus = FocusNode();

  final FocusNode openingFocuse = FocusNode();
  final FocusNode closingFocuse = FocusNode();

  LatLng? _currentLocation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  DateTime birthDate = DateTime.now();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //d<UserViewModel>().fetchProfile();
    setData();
  }

  Future setData() async {
    ProfileModel? user = context.read<UserCubit>().state.profileModel;
    if (user != null) {
      setState(() {
        emailController.text = ""; //backend se param he nahi arha
        userNameController.text = user.data.name;
        descriptionController.text = user.data.description != null ? user.data.description! : "";
        additionalController.text =
            user.data.additionalInfo != null ? user.data.additionalInfo! : "";

        openingAt.text = user.data.operatingHours.startAt;
        clossingAt.text = user.data.operatingHours.endAt;

        addressController.text = user.data.location != null ? user.data.location! : "";
        _currentLocation = LatLng(double.tryParse(user.data.latitude) ?? 32.5444,
            double.tryParse(user.data.latitude) ?? 64.000);
        print(user.data.logo);

        //  dateController.text = user.data.name;
      });
    } else {
      context.read<LoadingCubit>().showLoading();

      await context.read<UserCubit>().fetchProfile();
      context.read<LoadingCubit>().hideLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        return DecoratedBox(
            decoration: const BoxDecoration(
                color: AppColors.whiteColor,
                image: DecorationImage(
                  image: AssetImage(
                    ImageConstants.dashBoard,
                  ),
                  fit: BoxFit.cover,
                )),
            child: Scaffold(
                key: _scaffoldKey,
                backgroundColor: AppColors.transparentColor,
                body: SafeArea(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      setData();
                    },
                    child: ListView(
                      // mainAxisSize: MainAxisSize.min,
                      // crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        header(context, state),
                        state.profileModel == null
                            ? Container()
                            : bodyContent(
                                context,
                                state,
                              )
                      ],
                    ),
                  ),
                )));
      },
    );
  }

  Widget header(BuildContext context, UserState pr) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const BackIcon(background: false),
          Row(
            children: [
              CommonText(
                text: pr.appversion,
                fontSize: FontConstants.font_16,
                color: AppColors.primaryColor,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeightConstants.bold,
              ),
              const SizedBox(
                width: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget bodyContent(BuildContext context, UserState state) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: CommonText(
                  text: "myProfile".tr,
                  fontSize: FontConstants.font_22,
                  color: AppColors.greenBlue,
                  fontWeight: FontWeightConstants.bold,
                ),
              ),
              Visibility(
                visible: false,
                child: Align(
                  alignment: Alignment.center,
                  child: CommonProfileAvatar.commonProfileAvatar(
                      sizedBoxHeight: 150,
                      placeholderString: placeholder != null ? placeholder!.path : "",
                      onTapProfile: () {
                        CommonWidgets.pickImageBottomSheet(
                          titleName: "pickerTitle".tr,
                          context: context,
                          callback: (imageSource) {
                            pickImage(
                                pickImageType: imageSource == 0
                                    ? PickImageType.camera
                                    : PickImageType.gallery);
                          },
                        );
                      },
                      stackedIcon: SvgPicture.asset(
                        ImageConstants.camBack,
                        width: 35,
                        height: 35,
                      ),
                      dottedBorderColor: AppColors.primaryColor,
                      profileRadius: 60,
                      bottomPositionIcon: 1,
                      imageUrl: placeholder != null
                          ? placeholder!.path
                          : state.profileModel!.data.logo != null
                              ? state.profileModel!.data.logo!
                              : ""),
                ),
              ),
              SizedBox(
                height: 30.h,
              ),
              Stack(
                alignment: Get.locale!.languageCode != LanguageCode.ar.name
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                children: [
                  InvertIcon(
                    child: SvgPicture.asset(
                      ImageConstants.label,
                      height: 50.h,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: CommonText(
                      text: "personalInfo".tr,
                      fontSize: FontConstants.font_18,
                      color: AppColors.greenBlue,
                      fontWeight: FontWeightConstants.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20.h,
              ),
              Skeletonizer(
                enabled: state.isFetchingProfile,
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Responsive(runSpacing: 5.h, children: [
                        Div(
                          divison: Division(colXL: 4, colL: 4, colM: 12, colS: 12, colXS: 12),
                          child: inputField(context,
                                  labelTaext: "username".tr,
                                  focus: userNameFocus,
                                  controller: userNameController,
                                  nextFocus: descriptionFocus,
                                  validationRegex: CommonMethods.nameRegExp,
                                  validMessage: "validText".tr + "username".tr.toLowerCase(),
                                  errorMessage: "emptyText".tr + "username".tr.toLowerCase())
                              .paddingSymmetric(horizontal: 10, vertical: 10.h),
                        ),
                        Div(
                          divison: Division(colXL: 8, colL: 8, colM: 12, colS: 12, colXS: 12),
                          child: inputField(
                            context,
                            labelTaext: "description".tr,
                            focus: descriptionFocus,
                            controller: descriptionController,
                            nextFocus: additionalFocus,
                          ).paddingSymmetric(horizontal: 10, vertical: 10),
                        )
                      ]),
                      SizedBox(
                        height: isMobile ? 5.h : 20.h,
                      ),
                      Responsive(runSpacing: 5.h, children: [
                        Div(
                          divison: Division(colXL: 6, colL: 6, colM: 12, colS: 12, colXS: 12),
                          child: inputField(
                            context,
                            labelTaext: "Additional Info".tr,
                            focus: additionalFocus,
                            controller: additionalController,
                            nextFocus: addressFocus,
                          ).paddingSymmetric(horizontal: 10, vertical: 10),
                        ),
                        Div(
                          divison: Division(colXL: 6, colL: 6, colM: 12, colS: 12, colXS: 12),
                          child: addressField(context, state)
                              .paddingSymmetric(horizontal: 10, vertical: 10),
                        )
                      ]),
                      UIHelper.verticalSpaceMd,
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          InvertIcon(
                            child: SvgPicture.asset(
                              ImageConstants.label,
                              height: 50.h,
                              width: 100.w,
                            ),
                          ),
                          CommonText(
                            text: "operating_hours".tr,
                            fontSize: FontConstants.font_16,
                            color: AppColors.greenBlue,
                            fontWeight: FontWeightConstants.bold,
                          ),
                        ],
                      ),
                      UIHelper.verticalSpaceSm,
                      Row(
                        children: [
                          Expanded(
                              child: inputField(context,
                                  labelTaext: "Start At".tr,
                                  controller: openingAt,
                                  isReadOnly: true, ontap: () async {
                            TimeOfDay? selectrd = await showTimePicker(
                                context: context, initialTime: TimeOfDay(hour: 09, minute: 0));
                            if (selectrd != null) {
                              openingAt.text = selectrd.format(context);
                            }
                          })),
                          UIHelper.horizontalSpaceSm,
                          Expanded(
                              child: inputField(context,
                                  labelTaext: "Additional Info".tr,
                                  controller: clossingAt,
                                  isReadOnly: true, ontap: () async {
                            TimeOfDay? selectrd = await showTimePicker(
                                context: context, initialTime: TimeOfDay(hour: 18, minute: 0));
                            if (selectrd != null) {
                              clossingAt.text = selectrd.format(context);
                              setState(() {});
                            }
                          }))
                        ],
                      ).paddingSymmetric(horizontal: 10, vertical: 10),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: isMobile ? 5.h : 30.h,
              ),
              // action(context, langState, 1),
              // action(context, langState, 2),
              CommonOutlinedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    if (_currentLocation == null) {
                      UIHelper.showBottomFlash(context,
                          title: "address".tr,
                          message: "Address Field is required".tr,
                          isError: true);

                      return;
                    }
                    Map<String, String> paylaod = {
                      'name': userNameController.text,
                      'description': descriptionController.text,
                      'additional_info': additionalController.text,
                      'location': addressController.text,
                      'latitude': _currentLocation!.latitude.toString(),
                      'longitude': _currentLocation!.longitude.toString(),
                      'operating_hours[start_at]': openingAt.text,
                      'operating_hours[end_at]': clossingAt.text,
                    };
                    print(paylaod.toString());
                    context.read<LoadingCubit>().showLoading();
                    await context.read<UserCubit>().updateProfile(body: paylaod, context: context);
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
              ).marginSymmetric(vertical: 20).paddingSymmetric(horizontal: 15)
            ],
          )
        ],
      ),
    );
  }

  Future pickImage({required PickImageType pickImageType}) async {
    bool isEnable = await CommonMethods.askPermission(
      permission: pickImageType == PickImageType.camera
          ? Permission.camera
          : await CommonMethods.getGalleryPermission(),
      whichPermission: pickImageType.name.toUpperCase(),
    );

    if (isEnable) {
      // pick image
      final XFile? imageFile = await ImagePicker().pickImage(
        source: pickImageType == PickImageType.camera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 65,
      );

      // image validation
      if (imageFile != null) {
        if (imageFile.path.toLowerCase().endsWith("jpg") ||
            imageFile.path.toLowerCase().endsWith("png") ||
            imageFile.path.toLowerCase().endsWith("jpeg") ||
            imageFile.path.toLowerCase().endsWith("heic")) {
          bool isValidImage = await CommonMethods.imageSize(imageFile);

          if (isValidImage) {
            setState(() {
              placeholder = imageFile;
            });
            context.read<LoadingCubit>().showLoading();
            await context
                .read<UserCubit>()
                .updateProfile(filtPATH: imageFile.path, context: context);
            // updateProfile
            context.read<LoadingCubit>().hideLoading();
          } else {
            showTopSnackbar(
              AppValueConstants.globalKey.currentContext!,
              "maximumImageSizeError".tr,
              success: false,
            );
          }
        } else {
          showTopSnackbar(
            AppValueConstants.globalKey.currentContext!,
            "uploadImageError".tr,
            success: false,
          );
        }
      }
    }
  }

  Widget inputField(BuildContext context,
      {required labelTaext,
      focus,
      required controller,
      nextFocus,
      validationRegex,
      validMessage,
      errorMessage,
      isReadOnly,
      ontap}) {
    return CommonTextField(
      lableText: labelTaext,
      focusNode: focus,

      allowValidation: validationRegex == null ? false : true,
      floatLabelColor: AppColors.greenBlue,
      // contentPadding: EdgeInsets.all(10.r),
      textInputAction: TextInputAction.next,
      textEditingController: controller,
      nextFocusNode: nextFocus,
      labelColor: AppColors.greenBlue.withOpacity(0.24),
      borderColor: AppColors.greenBlue,
      autoValidateMode: validationRegex == null ? null : AutovalidateMode.onUserInteraction,
      validationRegex: validationRegex == null ? null : validationRegex,
      validationMessage: validationRegex == null ? null : validMessage,
      errorMessage: validationRegex == null ? null : errorMessage,
      textInputType: TextInputType.name,
      filledColor: AppColors.filledTextColor,

      filled: true,
      // inputFormat: <TextInputFormatter>[
      //   FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z ]")),
      // ],
      borderRadius: 30.sp,
      readOnly: isReadOnly ?? false,
      onTap: ontap,
      labelFontSize: FontConstants.font_20,

      // suffixIcon: Transform.translate(
      //   offset: Get.locale!.countryCode != LanguageCode.en.name
      //       ? const Offset(10, 0)
      //       : const Offset(0, 0),
      //   child: Transform.scale(
      //     scale: 0.7,
      //     child: SvgPicture.asset(
      //       ImageConstants.edit,
      //       height: 20.h,
      //       width: 20.w,
      //     ),
      //   ),
      // ),
    );
  }

  Widget addressField(BuildContext context, UserState state) {
    return CommonTextField(
      lableText: "address".tr,
      focusNode: addressFocus,
      floatLabelColor: AppColors.greenBlue,
      contentPadding: const EdgeInsets.all(15),
      //  maxLines: 1,
      autoValidateMode: AutovalidateMode.onUserInteraction,
      textEditingController: addressController,
      textInputAction: TextInputAction.done,
      labelColor: AppColors.greenBlue.withOpacity(0.24),
      borderColor: AppColors.greenBlue,
      validationMessage: "validText".tr + "address".tr.toLowerCase(),
      errorMessage: "emptyText".tr + "address".tr.toLowerCase(),
      suffixIcon: Transform.translate(
        offset: Get.locale!.languageCode != LanguageCode.en.name
            ? const Offset(10, 0)
            : const Offset(0, 0),
        child: Transform.scale(
          scale: 0.7,
          child: SvgPicture.asset(
            ImageConstants.edit,
          ),
        ),
      ),
      textInputType: TextInputType.streetAddress,
      filledColor: AppColors.filledTextColor,
      filled: true,
      borderRadius: 30.sp,
      readOnly: true,
      labelFontSize: FontConstants.font_20,

      onTap: () async {
        try {
          LocationResult? result = await Get.to(PlacePicker(
            StringConstants.mapKey,
            defaultLocation: _currentLocation != null ? _currentLocation : LatLng(32.5444, 64.000),

            //displayLocation: latlng,
          ));

          if (result != null) {
            setState(() {
              addressController.text = result.formattedAddress ?? "";
              _currentLocation = result.latLng;
              print("here.....");
              print(result.latLng.toString());
            });
          } else {}
        } on Exception {
          // TODO
        }
      },
    );
  }
}
