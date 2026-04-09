import 'package:abyadpos_tab/core/config/api_client.dart';
import 'package:abyadpos_tab/features/orders/presentation/controllers/order_cubit.dart';

import 'package:abyadpos_tab/features/auth/presentation/controllers/user_cubit.dart';
import 'package:abyadpos_tab/features/home/presentation/widgets/service_cart_view.dart';
import 'package:abyadpos_tab/features/home/presentation/widgets/service_category_view.dart';
import 'package:abyadpos_tab/core/widgets/custom_drawer.dart';
import 'package:abyadpos_tab/core/widgets/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:abyadpos_tab/features/orders/presentation/controllers/order_state.dart';
import 'package:abyadpos_tab/features/dashboard/presentation/controllers/drawer_state.dart';
import 'package:abyadpos_tab/features/home/presentation/widgets/custom_appbar.dart';

class HomeScreen extends StatefulWidget {
  final bool reload;

  HomeScreen({Key? key, this.reload = false}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _initConfigUpdater() async {
    final prefs = await SharedPreferences.getInstance();
    final hasRunBefore = prefs.getBool("configUpdaterStarted") ?? false;
    final userViewModel = context.read<UserCubit>();

    if (!hasRunBefore) {
      // Run only ONCE ever
      userViewModel.updateUserConfig(context);
      // Save flag so it never runs again
      await prefs.setBool("configUpdaterStarted", true);
    }
    userViewModel.startConfigUpdater(context);
  }

  @override
  void initState() {
    super.initState();
    _initConfigUpdater();
  }

  @override
  void dispose() {
    UserCubit(ApiClient()).stopConfigUpdater();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xffF9F9F9),
      body: BlocBuilder<OrderCubit, OrderState>(
        builder: (
          context,
          state,
        ) {
          // إزالة Container(width: Get.width) والاعتماد على SafeArea لتمدد طبيعي
          return SafeArea(
            child: Row(
              children: [
                // 1. القائمة الجانبية (CustomSideMenu)
                CustomSideMenu(),

                // 2. المحتوى الرئيسي (المنتجات + السلة)
                Expanded(
                  child: Column(
                    children: [
                      CustomAppBar(
                        title: "home".tr,
                        onSearch: (data) {
                          if (data.isNotEmpty) {
                            final cubit = BlocProvider.of<OrderCubit>(context, listen: false);
                            cubit.setExternalSearch(data);
                            UIHelper().goToMenu(context, SideMenuItem.orders);
                          }
                        },
                      ),

                      // 3. مساحة العمل المتجاوبة
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            // تحديد نقطة كسر (Breakpoint) لمعرفة هل النافذة عريضة أم مضغوطة
                            bool isWideScreen = constraints.maxWidth > 800;

                            if (isWideScreen) {
                              // 🖥️ حالة الشاشة العريضة: عرض المنتجات والسلة جنباً إلى جنب
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 7, // قسم المنتجات يأخذ 70% من المساحة
                                    child: ServiceCategoryView(),
                                  ),
                                  UIHelper.horizontalSpaceSm,
                                  Expanded(
                                    flex: 3, // السلة تأخذ 30% من المساحة وتتجاوب معها
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: ServiceCartView(
                                        reload: widget.reload,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              // 📱 حالة الشاشة المضغوطة: عرض المنتجات فوق والسلة تحت لتجنب الـ Overflow
                              return Column(
                                children: [
                                  Expanded(
                                    flex: 6, // المنتجات تأخذ الجزء العلوي
                                    child: ServiceCategoryView(),
                                  ),
                                  UIHelper.verticalSpaceSm,
                                  Expanded(
                                    flex: 4, // السلة تأخذ الجزء السفلي
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      child: ServiceCartView(
                                        reload: widget.reload,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
