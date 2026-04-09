import 'package:abyadpos_tab/features/orders/presentation/controllers/order_cubit.dart';

import 'package:abyadpos_tab/features/home/data/models/clothes_model.dart';
import 'package:abyadpos_tab/core/theme/app_colors.dart';
import 'package:abyadpos_tab/core/theme/font_constants.dart';
import 'package:abyadpos_tab/features/home/presentation/widgets/product_card.dart';
import 'package:abyadpos_tab/core/widgets/common_widgets.dart';
import 'package:abyadpos_tab/core/widgets/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:skeletonizer/skeletonizer.dart';

class ServiceCategoryView extends StatefulWidget {
  const ServiceCategoryView({Key? key}) : super(key: key);

  @override
  _ServiceCategoryViewState createState() => _ServiceCategoryViewState();
}

class _ServiceCategoryViewState extends State<ServiceCategoryView>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final List<String> listServices = ['Wash & Iron', 'Iron Only', 'Wash Only'];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<OrderCubit>();

    int initialTabIndex = 0;
    if (cubit.state.tabOnlyIroning) {
      initialTabIndex = 1;
    } else if (cubit.state.tabOnlyWashing) {
      initialTabIndex = 2;
    }

    _tabController = TabController(
      length: listServices.length,
      vsync: this,
      initialIndex: initialTabIndex,
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        cubit.setTabOnlyIroning(_tabController.index == 1);
        cubit.setTabOnlyWashing(_tabController.index == 2);
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final cubit = context.watch<OrderCubit>();

    int targetIndex = cubit.state.tabOnlyIroning ? 1 : (cubit.state.tabOnlyWashing ? 2 : 0);

    if (_tabController.index != targetIndex && !_tabController.indexIsChanging) {
      _tabController.animateTo(targetIndex);
    }

    final List<Cloth> allClothes = cubit.state.allClothsModel?.data.clothes ?? [];
    List<Cloth> filteredClothes;

    if (cubit.state.tabOnlyWashing) {
      filteredClothes = allClothes;
    } else {
      filteredClothes = allClothes.where((e) => e.supportIroning).toList();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<OrderCubit>().getAllClothes(context);
      },
      // 💡 1. إضافة LayoutBuilder لمعرفة العرض المتاح بدقة
      child: LayoutBuilder(builder: (context, constraints) {
        // 💡 2. حساب عدد الأعمدة بناءً على عرض النافذة
        int getCrossAxisCount(double width) {
          if (width < 400) return 2; // موبايل أو نافذة مضغوطة جداً
          if (width < 650) return 3; // تابلت صغير أو نافذة متوسطة
          if (width < 1000) return 4; // شاشة لابتوب أو نافذة عريضة
          if (width < 1400) return 5; // شاشة عريضة جداً
          return 6; // شاشات الـ 4K أو الـ Ultrawide
        }

        int dynamicCrossAxisCount = getCrossAxisCount(constraints.maxWidth);

        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Card(
                color: Colors.white,
                elevation: 2,
                margin: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Container(
                      height: 44,
                      color: Colors.white,
                      child: TabBar(
                        controller: _tabController,
                        tabs: listServices.map((s) => Tab(child: Text(s.tr))).toList(),
                        indicatorColor: AppColors.primaryColor,
                        indicatorWeight: 3,
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: AppColors.primaryColor,
                        unselectedLabelColor: Colors.grey,
                        labelStyle: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: FontConstants.font_18,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: FontConstants.font_16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    UIHelper.verticalSpaceMd,
                  ],
                ),
              ),
            ),
            Skeletonizer.sliver(
              enabled: cubit.state.isLoading,
              child: filteredClothes.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: CommonWidgets.noDataView(
                          title: "No Clothes Found".tr,
                          subText: "".tr,
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.all(5.0),
                      sliver: SliverGrid(
                        // 💡 3. تمرير الرقم المتغير بدلاً من الرقم الثابت (4)
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: dynamicCrossAxisCount,
                          childAspectRatio: 1.1,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final cloth = filteredClothes[index];

                            final bool isIroningTab = cubit.state.tabOnlyIroning;
                            final bool isWashingTab = cubit.state.tabOnlyWashing;

                            return ProductCard(
                              key: ValueKey(cloth.id),
                              model: cloth,
                              isSupportIroning: isIroningTab,
                              price: checkprice(cloth, isIroningTab, isWashingTab, false),
                            );
                          },
                          childCount: filteredClothes.length,
                        ),
                      ),
                    ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 50)),
          ],
        );
      }),
    );
  }
}

// الدوال المساعدة بقيت كما هي دون تغيير
double checkprice(Cloth cloth, bool only_ironing, bool only_cleaning, bool isFast) {
  if (only_cleaning) {
    return isFast
        ? (double.tryParse(cloth.prices.priceFastCleaning!) ?? 0.0)
        : (double.tryParse(cloth.prices.priceCleaning!) ?? 0.0);
  }

  if (only_ironing) {
    return isFast
        ? (double.tryParse(cloth.prices.priceFastIroning!) ?? 0.0)
        : (double.tryParse(cloth.prices.priceIroning!) ?? 0.0);
  }

  return isFast
      ? (double.tryParse(cloth.prices.priceFastCleaningAndIroning!) ?? 0.0)
      : (double.tryParse(cloth.prices.priceCleaningAndIroning!) ?? 0.0);
}

Map<String, double> calculateTotals({
  required List<Map<String, dynamic>> selectedItems,
  required bool isExpress,
}) {
  double subTotal = 0.0;
  double exAmount = 0.0;

  for (var e in selectedItems) {
    final count = e['clothes_count'] ?? 0;
    final isCustomized = e['isCustomized'] ?? false;

    if (isCustomized) {
      double itemSubtotal = 0.0;
      if (e['total_custom_price'] != null && (e['total_custom_price'] as double) > 0.0) {
        itemSubtotal = e['total_custom_price'] as double;
      } else if (e['custom_price_per_unit'] != null &&
          (e['custom_price_per_unit'] as double) > 0.0) {
        itemSubtotal = (e['custom_price_per_unit'] as double) * count;
      }
      subTotal += itemSubtotal;
      exAmount += 0.0;
    } else {
      final cloth = Cloth.fromJson(e['cloth']);
      final bool itemOnlyIroning = e['only_ironing'] ?? false;
      final bool itemOnlyCleaning = e['only_cleaning'] ?? false;

      final normalPrice = checkprice(cloth, itemOnlyIroning, itemOnlyCleaning, false);
      final expressPrice = checkprice(cloth, itemOnlyIroning, itemOnlyCleaning, true);

      subTotal += (isExpress ? expressPrice : normalPrice) * count;
      exAmount += (expressPrice - normalPrice) * count;
    }
  }

  return {
    'subTotal': subTotal,
    'exAmount': exAmount,
  };
}
