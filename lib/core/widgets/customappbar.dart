import 'package:abyadpos_tab/core/theme/app_colors.dart';
import 'package:abyadpos_tab/core/theme/font_constants.dart';
import 'package:abyadpos_tab/main.dart';
import 'package:abyadpos_tab/features/auth/presentation/controllers/user_cubit.dart';
import 'package:abyadpos_tab/features/auth/presentation/controllers/user_state.dart';
import 'package:abyadpos_tab/core/widgets/common_text.dart';
import 'package:abyadpos_tab/core/widgets/ui_helpers.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

AppBar customAppBar(
    {required context, title, actions, addWidget, leadingIcon, backColor, onLeadingTap}) {
  return AppBar(
    centerTitle: false,
    toolbarHeight: 80,
    backgroundColor: backColor ?? Colors.transparent,
    surfaceTintColor: backColor ?? Colors.transparent,
    leadingWidth: isMobile ? Get.width * 0.8 : Get.width * 0.7,
    leading: leadingIcon ??
        Padding(
          padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 5),
          // child: leadingIcon ??
          //     Container(
          //       width: 0.0,
          //     ),
          child: BlocBuilder<UserCubit, UserState>(builder: (context, provider) {
            return Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: GestureDetector(
                    onTap: onLeadingTap,
                    child: CircularProfileAvatar(
                      provider.profileModel != null
                          ? provider.profileModel!.data.logo != null
                              ? provider.profileModel!.data.logo!
                              : "https://abyad.sa/uploads/laundry-logos/674f720147ae0.png"
                          : "https://abyad.sa/uploads/laundry-logos/674f720147ae0.png",
                      radius: 25.w,
                      backgroundColor: AppColors.primaryColor,
                    ),
                  ),
                ),
                UIHelper.horizontalSpaceSm,
                CommonText(
                  text: "hello".tr +
                      " " +
                      (provider.profileModel == null ? '-' : provider.profileModel!.data.name),
                  fontSize: isMobile ? FontConstants.font_15 : FontConstants.font_15,
                  fontWeight: FontWeightConstants.semiBold,
                  textAlign: TextAlign.start,
                )
              ],
            );
          }),
        ),
    actions: actions ??
        [
          addWidget ?? Container(),
        ],
  );
}
