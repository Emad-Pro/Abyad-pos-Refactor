import 'package:abyadpos_tab/core/constants/image_constants.dart';
import 'package:abyadpos_tab/core/theme/app_colors.dart';
import 'package:abyadpos_tab/core/widgets/common_text.dart';
import 'package:abyadpos_tab/core/widgets/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({Key? key}) : super(key: key);

  @override
  _DashBoardScreenState createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  PersistentTabController navController =
      new PersistentTabController(initialIndex: 0);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkInternet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }

  PersistentBottomNavBarItem itemNAV(BuildContext context, title, int index) {
    bool isSelected = index == navController.index;

    return PersistentBottomNavBarItem(
      // title: title,
      icon: Container(
          child: Column(
        children: [
          UIHelper.verticalSpaceSm1,
          Expanded(
            child: isSelected
                ? ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      isSelected
                          ? AppColors.whiteColor
                          : AppColors.whiteColor, // Des// ired color
                      BlendMode.srcIn,
                    ),
                    child: Lottie.asset(
                      index == 0
                          ? ImageConstants.homeJson
                          : index == 1
                              ? ImageConstants.cardJson
                              : ImageConstants.assignmentJson,
                      // height: 60.h,
                      animate: isSelected,
                    ),
                  )
                : SvgPicture.asset(
                    index == 0
                        ? ImageConstants.homeDis
                        : index == 1
                            ? ImageConstants.orderDis
                            : ImageConstants.ivOrdersDis,
                    // height: 60.h,
                    color: Colors.white70,
                  ),
          ),
          CommonText(
            text: title,
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: isSelected ? 14.0 : 12.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          )
        ],
      )),

      // icon: Padding(
      //   padding: const EdgeInsets.only(top: 15),
      //   child: CommonText(
      //     text: title,
      //     color: isSelected ? Colors.white : Colors.white,
      //     fontSize: isSelected ? 15.0 : 13.5,
      //     fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      //   ),
      // ),
      // title: ("Home"),
      activeColorPrimary: AppColors.whiteColor,
      inactiveColorPrimary: Colors.white,
      activeColorSecondary: Colors.white,
      opacity: 1,
      //  contentPadding: 10

      // label: '',
    );
  }

  void navigationTapped(int page) {}

  void checkInternet() async {}
}
