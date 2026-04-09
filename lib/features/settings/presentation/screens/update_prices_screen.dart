import 'dart:math'; // 💡 ضرورية لاستخدام دالة max لضبط العرض

import 'package:abyadpos_tab/features/orders/presentation/controllers/order_cubit.dart';
import 'package:abyadpos_tab/features/home/data/models/clothes_model.dart';
import 'package:abyadpos_tab/core/theme/app_colors.dart';
import 'package:abyadpos_tab/features/home/presentation/screens/home_screen.dart';
import 'package:abyadpos_tab/features/home/presentation/widgets/custom_appbar.dart';
import 'package:abyadpos_tab/core/widgets/loader/loading_cubit.dart';
import 'package:abyadpos_tab/core/widgets/custom_button.dart';
import 'package:abyadpos_tab/core/widgets/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:abyadpos_tab/features/orders/presentation/controllers/order_state.dart';
import 'package:abyadpos_tab/core/widgets/custom_drawer.dart';
import 'package:abyadpos_tab/features/auth/presentation/controllers/user_cubit.dart';
import 'package:abyadpos_tab/features/dashboard/presentation/controllers/drawer_cubit.dart';
import 'package:abyadpos_tab/features/dashboard/presentation/controllers/drawer_state.dart';
import 'package:abyadpos_tab/features/home/presentation/widgets/notification_menu.dart';
import 'package:abyadpos_tab/features/settings/presentation/widgets/cloth_row_widget.dart';

class UpdatePricesScreen extends StatefulWidget {
  const UpdatePricesScreen({Key? key}) : super(key: key);

  @override
  _UpdatePricesScreenState createState() => _UpdatePricesScreenState();
}

class _UpdatePricesScreenState extends State<UpdatePricesScreen> {
  final Map<int, List<TextEditingController>> _priceControllersMap = {};
  bool _hasUnsavedChanges = false;

  // ── Controller Management ─────────────────────────────────────────────────

  List<TextEditingController> _getPriceControllers(Cloth cloth) {
    if (!_priceControllersMap.containsKey(cloth.id)) {
      final prices = cloth.prices;
      final controllers = <TextEditingController>[];

      if (cloth.supportIroning) {
        controllers
          ..add(TextEditingController(text: prices.priceIroning ?? ""))
          ..add(TextEditingController(text: prices.priceFastIroning ?? ""))
          ..add(TextEditingController(text: prices.priceCleaningAndIroning ?? ""))
          ..add(TextEditingController(text: prices.priceFastCleaningAndIroning ?? ""))
          ..add(TextEditingController(text: prices.priceCleaning ?? ""))
          ..add(TextEditingController(text: prices.priceFastCleaning ?? ""));
      } else {
        controllers
          ..add(TextEditingController(text: prices.priceCleaning ?? ""))
          ..add(TextEditingController(text: prices.priceFastCleaning ?? ""));
      }

      _priceControllersMap[cloth.id] = controllers;
    }
    return _priceControllersMap[cloth.id]!;
  }

  @override
  void initState() {
    super.initState();
    final provider = BlocProvider.of<OrderCubit>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _callApi(provider);
    });
  }

  @override
  void dispose() {
    for (final controllers in _priceControllersMap.values) {
      for (final c in controllers) c.dispose();
    }
    super.dispose();
  }

  // ── API Calls ─────────────────────────────────────────────────────────────

  Future<void> _callApi(OrderCubit provider) async {
    _priceControllersMap.clear();
    if (mounted) {
      setState(() => _hasUnsavedChanges = false);
    }
    await provider.getAllClothesActiveAndInactive(context);
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _saveData(OrderCubit cubit, {bool shouldNavigate = true}) async {
    final clothes = cubit.state.allClothsModelUpdatePrices?.data.clothes;
    if (clothes == null) {
      UIHelper.showBottomFlash(context, title: "Error", message: "No data to save", isError: true);
      return;
    }

    final loadingCubit = context.read<LoadingCubit>();
    loadingCubit.showLoading();

    try {
      await cubit.updateClothes(clothes, context);
      await cubit.getAllClothes(context);
      if (mounted) setState(() => _hasUnsavedChanges = false);
    } catch (e) {
      debugPrint("Error saving prices: $e");
    } finally {
      loadingCubit.hideLoading();
    }

    if (shouldNavigate && mounted) {
      final needsSetup = cubit.state.userModel?.data.products_need_setup ?? false;
      if (!needsSetup) {
        Get.offAll(() => HomeScreen(reload: true));

        // --- التعديل هنا للعمل مع الكيوبت ---
        NotificationMenuController.hide(); // لإخفاء أي قوائم منبثقة أو بحث
        context.read<SideMenuCubit>().changeMenuItem(SideMenuItem.home);
      }
    }
  }
  // ── Exit Handling ─────────────────────────────────────────────────────────

  Future<void> _handleExit(OrderCubit cubit) async {
    if (cubit.state.userModel?.data.products_need_setup == true) {
      UIHelper.showBottomFlash(context,
          title: "set_active_msg".tr, message: "set_active_msg".tr, isError: true);
      return;
    }

    if (_hasUnsavedChanges) {
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text('unsaved_changes_title'.tr),
          content: Text('unsaved_changes_message'.tr),
          actions: [
            TextButton(
              onPressed: () async {
                UIHelper().showLoading(context);
                await _callApi(cubit);
                UIHelper().hideLoading(context);
                Navigator.of(ctx).pop(false);
              },
              child: Text('discard'.tr, style: const TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                UIHelper.hideKeyboard(context);
                Navigator.of(ctx).pop(true);
              },
              child: Text('Save'.tr),
            ),
          ],
        ),
      );

      if (shouldSave == true) {
        await _saveData(cubit, shouldNavigate: true);
      } else if (shouldSave == false) {
        _navigateBack();
      }
    } else {
      _navigateBack();
    }
  }

  void _navigateBack() {
    // 1. إخفاء أي قوائم منبثقة أو بحث (بديل isSearching: false)
    NotificationMenuController.hide();

    // 2. تحديث حالة القائمة الجانبية لتشير إلى "الإعدادات"
    context.read<SideMenuCubit>().changeMenuItem(SideMenuItem.settings);

    Navigator.pop(context);
  }

  void _markAsChanged() {
    if (!_hasUnsavedChanges) setState(() => _hasUnsavedChanges = true);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<OrderCubit>(context, listen: true);
    final userCubit = context.read<UserCubit>();
    cubit.setUserModel(userCubit.state.userModel);

    return PopScope(
      canPop: !(cubit.state.userModel?.data.products_need_setup ?? false) && !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleExit(cubit);
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF3F4F6),
        body: BlocBuilder<OrderCubit, OrderState>(
          builder: (
            context,
            state,
          ) {
            final model = state.allClothsModelUpdatePrices;

            return SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        CustomAppBar(
                          title: "update_prices".tr,
                          isSearchable: false,
                          onSearch: (_) {},
                        ),
                        Expanded(
                          child: model == null
                              ? _buildEmptyState(cubit)
                              : _buildContent(context, cubit, model),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(OrderCubit cubit) {
    if (cubit.state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(
      child: CustomButton(
        width: 300,
        () async => _callApi(cubit),
        text: 'Retry'.tr,
      ),
    );
  }

  Widget _buildContent(BuildContext context, OrderCubit cubit, dynamic model) {
    return Column(
      children: [
        // ── Top Action Bar ─────────────────────────────────
        _TopActionBar(
          hasUnsavedChanges: _hasUnsavedChanges,
          vatEnabled: cubit.state.userModel?.data.vat_enabled ?? false,
          onBack: () => _handleExit(cubit),
          onSave: () => _saveData(cubit),
        ),

        const SizedBox(height: 8),

        // 💡 استخدام LayoutBuilder لجعل الجدول متجاوباً
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // تحديد حد أدنى لعرض الجدول (مثلاً 1000 بكسل) لمنع انكماش الحقول
              final double tableWidth = max(1000.0, constraints.maxWidth);

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal, // 💡 تفعيل السكرول الأفقي لو الشاشة صغرت
                child: SizedBox(
                  width: tableWidth, // إجبار الجدول على أخذ العرض المريح
                  child: Column(
                    children: [
                      // ── Table Header ───────────────────────────────────
                      _TableHeader(),

                      // ── List ───────────────────────────────────────────
                      Expanded(
                        child: ReorderableListView.builder(
                          padding: const EdgeInsets.fromLTRB(10, 4, 10, 16),
                          itemCount: model.data.clothes.length,
                          onReorder: (oldIndex, newIndex) {
                            if (newIndex > oldIndex) newIndex -= 1;
                            final item = model.data.clothes.removeAt(oldIndex);
                            model.data.clothes.insert(newIndex, item);
                            for (int i = 0; i < model.data.clothes.length; i++) {
                              model.data.clothes[i].sort_order = i + 1;
                            }
                            _markAsChanged();
                          },
                          proxyDecorator: (child, index, animation) {
                            return AnimatedBuilder(
                              animation: animation,
                              builder: (_, ch) => Material(
                                elevation: 8,
                                borderRadius: BorderRadius.circular(10),
                                child: ch,
                              ),
                              child: child,
                            );
                          },
                          itemBuilder: (context, index) {
                            final item = model.data.clothes[index];
                            return ClothRowWidget(
                              key: ValueKey(item.id),
                              cloth: item,
                              controllers: _getPriceControllers(item),
                              onChanged: _markAsChanged,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Top Action Bar ──────────────────────────────────────────────────────────

class _TopActionBar extends StatelessWidget {
  final bool hasUnsavedChanges;
  final bool vatEnabled;
  final VoidCallback onBack;
  final VoidCallback onSave;

  const _TopActionBar({
    required this.hasUnsavedChanges,
    required this.vatEnabled,
    required this.onBack,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      // 💡 استخدمنا Wrap بدلاً من Row لمنع الـ Overflow لو الشاشة ديقت
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 10, // لو نزلوا سطر جديد يسيبوا مسافة
        children: [
          // ── الجانب الأيسر (الرجوع والتنبيه) ──
          Wrap(
            spacing: 12,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // 💡 يمنع التمدد المبالغ فيه
                    children: [
                      const Icon(Icons.arrow_back_ios_new, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        "settings".tr,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              if (hasUnsavedChanges)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_note, size: 14, color: Colors.amber.shade700),
                      const SizedBox(width: 4),
                      Text(
                        'unsaved_changes_title'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // ── الجانب الأيمن (الضريبة وزر الحفظ) ──
          Wrap(
            spacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (vatEnabled)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      "all_prices_include_tax".tr,
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey.shade600), // 💡 صغرت الخط ليكون متناسق
                    ),
                  ],
                ),
              ElevatedButton.icon(
                onPressed: onSave,
                icon: const Icon(Icons.check, size: 16),
                label: Text("update_prices".tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Table Header ────────────────────────────────────────────────────────────

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEEEFF2),
      padding: const EdgeInsetsDirectional.only(top: 10, bottom: 10, start: 52, end: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _HeaderLabel('cloth_name'.tr),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 8),
              child: _HeaderLabel('image'.tr),
            ),
          ),
          Expanded(
            flex: 4,
            child: _HeaderLabel('prices'.tr),
          ),
          Expanded(
            flex: 3,
            child: Center(child: _HeaderLabel('support_ironing'.tr)),
          ),
          Expanded(
            flex: 2,
            child: _HeaderLabel('active'.tr),
          ),
          Expanded(
            flex: 2,
            child: Center(child: _HeaderLabel('sort'.tr)),
          ),
        ],
      ),
    );
  }
}

class _HeaderLabel extends StatelessWidget {
  final String text;
  const _HeaderLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade600,
        letterSpacing: 0.5,
      ),
    );
  }
}
