import 'package:abyadpos_tab/features/orders/presentation/controllers/order_cubit.dart';
import 'package:abyadpos_tab/features/home/data/models/clothes_model.dart';
import 'package:abyadpos_tab/core/theme/app_colors.dart';
import 'package:abyadpos_tab/core/theme/font_constants.dart';
import 'package:abyadpos_tab/core/widgets/custom_button.dart';
import 'package:abyadpos_tab/core/widgets/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:abyadpos_tab/core/widgets/cached_image_widget.dart';
// Ensure Get is imported for .tr extension

class ProductCard extends StatefulWidget {
  final Cloth model;
  final double price;
  final bool isSupportIroning;

  const ProductCard({
    Key? key,
    required this.model,
    required this.price,
    required this.isSupportIroning,
  }) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  void _updateValue(int newValue, OrderCubit cubit) {
    // Determine states based on current provider tabs
    final bool isOnlyIroning = cubit.state.tabOnlyIroning;
    final bool isOnlyWashing = cubit.state.tabOnlyWashing;

    setState(() {
      if (isOnlyIroning) {
        widget.model.clothCountesOnly = newValue;
        widget.model.isSetOnlyIroning = true;
      } else {
        widget.model.clothCountes = newValue;
        widget.model.isSetOnlyIroning = false;
      }
      // Note: If you have a specific field in your model for Wash Only count,
      // you can set it here similarly to clothCountesOnly.
    });

    // Update Provider with the new onlyCleaning parameter
    cubit.updateSelection(
      cloth: widget.model,
      count: newValue,
      onlyIroning: isOnlyIroning,
      onlyCleaning: isOnlyWashing, // 👈 THIS IS THE FIX
    );
  }

  // void _updateValue(int newValue, OrderViewModel provider) {
  //   // Optimistic update for UI speed
  //   setState(() {
  //     if (widget.isSupportIroning) {
  //       widget.model.clothCountesOnly = newValue;
  //       widget.model.isSetOnlyIroning = true;
  //     } else {
  //       widget.model.clothCountes = newValue;
  //       widget.model.isSetOnlyIroning = false;
  //     }
  //   });
  //
  //   // Update Provider
  //   provider.updateSelection(
  //     cloth: widget.model,
  //     count: widget.isSupportIroning
  //         ? widget.model.clothCountesOnly!
  //         : widget.model.clothCountes!,
  //     onlyIroning: widget.isSupportIroning,
  //   );
  // }

  @override
  @override
  Widget build(BuildContext context) {
    // ⚡ PERFORMANCE FIX: context.select
    final count = context.select<OrderCubit, int>((cubit) {
      final index = cubit.state.selectedItems.indexWhere((e) =>
          widget.model.id.toString() == e['cloth_id'].toString() &&
          cubit.state.tabOnlyIroning == (e['only_ironing'] ?? false) &&
          cubit.state.tabOnlyWashing == (e['only_cleaning'] ?? false));
      return index > -1 ? cubit.state.selectedItems[index]['clothes_count'] : 0;
    });

    final cubit = context.read<OrderCubit>();

    return GestureDetector(
      onTap: () {
        final selectedItemIndex = cubit.state.selectedItems.indexWhere((e) =>
            e['cloth_id'].toString() == widget.model.id.toString() &&
            (e['only_ironing'] ?? false) == cubit.tabOnlyIroning &&
            (e['only_cleaning'] ?? false) == cubit.tabOnlyWashing &&
            (e['isCustomized'] ?? false) == true);

        if (selectedItemIndex != -1) {
          UIHelper().openEditItemDialog(
            context: context,
            index: selectedItemIndex,
            item: widget.model,
            cubit: cubit,
            isArabic: Get.locale?.languageCode == 'ar',
            isExpress: cubit.state.isExpress,
            exAmount: 0.0,
          );
        } else {
          _updateValue(count + 1, cubit);
        }
      },
      onLongPress: () => _handleLongPress(context, cubit),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            // 💡 أزلنا mainAxisSize: MainAxisSize.min لأن الـ Grid يفرض مقاساً ثابتاً
            crossAxisAlignment: CrossAxisAlignment.stretch, // لتمدد العناصر بعرض الكارت
            children: [
              // 💡 استخدمنا Expanded بدلاً من Container(height: 120) ليتجاوب مع أي شاشة
              Expanded(
                child: Stack(
                  fit: StackFit.expand, // 💡 يجبر الصورة على ملء المساحة المتاحة في الـ Stack
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CachedImageWidget(
                        imageUrl: widget.model.image,
                        fit: BoxFit.contain, // contain تضمن عدم قص الصورة
                        memCacheHeight: 200,
                        memCacheWidth: 200,
                      ),
                    ),

                    // Minus Button (Bottom Right)
                    Positioned(
                      bottom: 0,
                      right: 0, // تم التعديل لتجنب خروج الزر عن الحواف
                      child: count > 0
                          ? GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () => _handleDecrement(context, cubit, count),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: _CounterButton(
                                  icon: Icons.remove,
                                  isAdd: false,
                                  onTap: () => _handleDecrement(context, cubit, count),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    // Plus/Count Button (Bottom Left)
                    Positioned(
                      bottom: 0,
                      left: 0, // تم التعديل لتجنب خروج الزر عن الحواف
                      child: count > 0
                          ? GestureDetector(
                              onTap: () => _handleIncrement(context, cubit, count),
                              child: Container(
                                width: 32,
                                height: 32,
                                margin: const EdgeInsets.all(4.0), // إبعاد الزر عن الحافة قليلاً
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  UIHelper().formatCountCompact(count),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              // Keeping your design spacing
              const SizedBox(height: 4),
              // Name and Price would go here
              // 💡 (تأكد مستقبلاً عند إضافة الاسم والسعر استخدام TextOverflow لمنع تجاوز النص للمساحة)
            ],
          ),
        ),
      ),
    );
  }

  void _handleDecrement(BuildContext context, OrderCubit provider, int currentCount) {
    final idx = provider.state.selectedItems.indexWhere((e) =>
        e['cloth_id'].toString() == widget.model.id.toString() &&
        (e['only_ironing'] ?? false) == provider.tabOnlyIroning &&
        (e['only_cleaning'] ?? false) == provider.tabOnlyWashing && // 👈 Add this
        (e['isCustomized'] ?? false) == true);
    // final idx = provider.selectedItems.indexWhere((e) =>
    // e['cloth_id'].toString() == widget.model.id.toString() &&
    //     (e['only_ironing'] ?? false) == provider.tabOnlyIroning &&
    //     (e['isCustomized'] ?? false) == true);

    if (idx != -1) {
      UIHelper().openEditItemDialog(
          context: context,
          index: idx,
          item: widget.model,
          cubit: provider,
          isArabic: Get.locale?.languageCode == 'ar',
          isExpress: provider.state.isExpress,
          exAmount: 0.0);
    } else {
      if (currentCount > 0) _updateValue(currentCount - 1, provider);
    }
  }

  void _handleIncrement(BuildContext context, OrderCubit cubit, int currentCount) {
    // final idx = provider.selectedItems.indexWhere((e) =>
    // e['cloth_id'].toString() == widget.model.id.toString() &&
    //     (e['only_ironing'] ?? false) == provider.tabOnlyIroning &&
    //     (e['isCustomized'] ?? false) == true);
    final idx = cubit.state.selectedItems.indexWhere((e) =>
        e['cloth_id'].toString() == widget.model.id.toString() &&
        (e['only_ironing'] ?? false) == cubit.state.tabOnlyIroning &&
        (e['only_cleaning'] ?? false) == cubit.state.tabOnlyWashing && // 👈 Add this
        (e['isCustomized'] ?? false) == true);

    if (idx != -1) {
      UIHelper().openEditItemDialog(
          context: context,
          index: idx,
          item: widget.model,
          cubit: cubit,
          isArabic: Get.locale?.languageCode == 'ar',
          isExpress: cubit.state.isExpress,
          exAmount: 0.0);
    } else {
      _updateValue(currentCount + 1, cubit);
    }
  }

  void _handleLongPress(BuildContext context, OrderCubit provider) async {
    // Reusing your dialog logic exactly
    final selectedItemIndex = provider.state.selectedItems.indexWhere((e) =>
        e['cloth_id'].toString() == widget.model.id.toString() &&
        (e['only_ironing'] ?? false) == provider.tabOnlyIroning &&
        (e['only_cleaning'] ?? false) == provider.tabOnlyWashing && // 👈 Add this line
        (e['isCustomized'] ?? false) == true);

    if (selectedItemIndex != -1) {
      UIHelper().openEditItemDialog(
          context: context,
          index: selectedItemIndex,
          item: widget.model,
          cubit: provider,
          isArabic: Get.locale?.languageCode == 'ar',
          isExpress: provider.state.isExpress,
          exAmount: 0.0);
    } else {
      final TextEditingController controller = TextEditingController();
      final formKey = GlobalKey<FormState>();

      await showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Container(
            padding: const EdgeInsets.all(16),
            width: 270,
            height: 230,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(Get.locale?.languageCode == 'ar' ? widget.model.nameAr : widget.model.nameEn,
                      style: TextStyle(
                          fontSize: FontConstants.font_18,
                          fontWeight: FontWeightConstants.semiBold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 180,
                    child: TextFormField(
                      controller: controller,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                          hintText: "enter_count".tr, border: const OutlineInputBorder()),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'please_enter_a_number'.tr : null,
                      onFieldSubmitted: (v) {
                        if (formKey.currentState!.validate()) {
                          _updateValue(int.parse(controller.text.trim()), provider);
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(() {
                    if (formKey.currentState!.validate()) {
                      _updateValue(int.parse(controller.text.trim()), provider);
                      Navigator.of(context).pop();
                    }
                  }, text: "save".tr, width: 180),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final bool isAdd;
  final VoidCallback onTap;

  const _CounterButton({required this.icon, required this.isAdd, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isAdd ? AppColors.primaryColor : Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Icon(icon, color: isAdd ? Colors.white : Colors.black, size: 20),
    );
  }
}
