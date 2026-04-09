import 'package:abyadpos_tab/features/dashboard/presentation/controllers/drawer_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide Transition;
import 'package:get/get.dart';
import 'package:abyadpos_tab/core/constants/app_value_constants.dart';
import 'package:abyadpos_tab/core/theme/app_colors.dart';
import 'package:abyadpos_tab/main.dart';
import 'package:abyadpos_tab/features/home/presentation/screens/home_screen.dart';
import 'package:abyadpos_tab/features/home/presentation/widgets/notification_menu.dart';
import 'package:abyadpos_tab/features/orders/presentation/screens/order_screen.dart';
import 'package:abyadpos_tab/features/settings/presentation/screens/settings_screen.dart';
import 'package:abyadpos_tab/core/constants/image_constants.dart';

import 'package:abyadpos_tab/features/dashboard/presentation/controllers/drawer_cubit.dart';

class CustomSideMenu extends StatelessWidget {
  final ValueChanged<SideMenuItem>? onItemSelected;

  const CustomSideMenu({Key? key, this.onItemSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // تحديد ما إذا كانت الشاشة صغيرة لإخفاء القائمة (Responsive)
    double screenWidth = MediaQuery.of(context).size.width;

    // الاستماع لحالة الـ Cubit
    return BlocBuilder<SideMenuCubit, SideMenuState>(
      builder: (context, state) {
        final collapsed = state.isCollapsed;
        final width = collapsed ? 100.0 : 240.0;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: width,
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(2, 0))],
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 24),
                    if (!collapsed)
                      Center(
                        child: Image.asset(
                          ImageConstants.dummy_logo,
                          width: 80,
                          height: 80,
                        ),
                      )
                    else
                      const SizedBox(width: 80, height: 80),
                    const SizedBox(height: 32),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildItem(
                              context,
                              state: state,
                              item: SideMenuItem.home,
                              icon: Icons.grid_view_outlined,
                              label: 'home'.tr,
                            ),
                            _buildItem(
                              context,
                              state: state,
                              item: SideMenuItem.orders,
                              icon: Icons.shopping_bag_outlined,
                              label: 'orders'.tr,
                            ),
                            _buildItem(
                              context,
                              state: state,
                              item: SideMenuItem.invoices,
                              icon: Icons.receipt_long,
                              label: 'invoices'.tr,
                            ),
                            _buildItem(
                              context,
                              state: state,
                              item: SideMenuItem.settings,
                              icon: Icons.settings_outlined,
                              label: 'settings'.tr,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!collapsed)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Directionality(
                          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                          child: Text(
                            StringConstants.copyRight.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          ),
                        ),
                      ),
                  ],
                ),
                Align(
                  alignment: isArabic ? Alignment.centerLeft : Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      // استدعاء دالة الكيوبت مباشرة
                      context.read<SideMenuCubit>().toggleCollapse();
                    },
                    child: Container(
                      width: 33,
                      height: 33,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDC801),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          collapsed ? Icons.chevron_right : Icons.chevron_left,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required SideMenuState state,
    required SideMenuItem item,
    required IconData icon,
    required String label,
  }) {
    final collapsed = state.isCollapsed;
    final isSelected = state.selectedItem == item;
    final baseColor = AppColors.primaryColor;

    return InkWell(
      onTap: () {
        NotificationMenuController.hide();

        if (!isSelected) {
          // استدعاء الكيوبت لتغيير الشاشة
          context.read<SideMenuCubit>().changeMenuItem(item);
          onItemSelected?.call(item);
          _navigateForItem(item);
        }
      },
      child: Row(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: EdgeInsets.all(collapsed ? 8 : 12),
              decoration: isSelected
                  ? BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(8))
                  : null,
              child: Row(
                mainAxisAlignment: collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  Icon(icon, size: 20, color: isSelected ? Colors.white : baseColor),
                  if (!collapsed) ...[
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontSize: 16,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isSelected)
            Container(
              width: 5,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isArabic ? 0 : 5),
                    bottomLeft: Radius.circular(isArabic ? 0 : 5),
                    topRight: Radius.circular(isArabic ? 5 : 0),
                    bottomRight: Radius.circular(isArabic ? 5 : 0)),
                color: const Color(0xFFFDC801),
              ),
            )
          else
            const SizedBox(width: 5),
        ],
      ),
    );
  }

  void _navigateForItem(SideMenuItem item) {
    switch (item) {
      case SideMenuItem.settings:
        Get.offAll(() => const SettingsScreen(), transition: Transition.noTransition);
        break;
      case SideMenuItem.orders:
        Get.offAll(() => OrderScreen(isCurrent: true, key: UniqueKey()),
            transition: Transition.noTransition);
        break;
      case SideMenuItem.invoices:
        Get.offAll(() => OrderScreen(isCurrent: false, key: UniqueKey()),
            transition: Transition.noTransition);
        break;
      case SideMenuItem.home:
      default:
        Get.offAll(() => HomeScreen(reload: false), transition: Transition.noTransition);
        break;
    }
  }
}
