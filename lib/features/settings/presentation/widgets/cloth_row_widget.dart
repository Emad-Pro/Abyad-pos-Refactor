import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import 'package:abyadpos_tab/features/home/data/models/clothes_model.dart';
import 'package:abyadpos_tab/core/theme/app_colors.dart';
import 'package:abyadpos_tab/core/widgets/cached_image_widget.dart';

/// A price chip showing label + value, tappable to open the edit panel.
class _PriceChip extends StatelessWidget {
  final String label;
  final String value;

  const _PriceChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isEmpty = value.isEmpty || value == '0' || value == '0.0' || value == '0.00';
    return Container(
      // 💡 تم إزالة width: 130 الثابت عشان الـ Chip ياخد مساحته براحته بناءً على الكلمة
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isEmpty ? const Color(0xFFF5F5F5) : AppColors.primaryColor.withOpacity(0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isEmpty ? Colors.grey.shade300 : AppColors.primaryColor.withOpacity(0.35),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isEmpty ? Colors.grey.shade500 : AppColors.primaryColor.withOpacity(0.8),
              letterSpacing: 0.3,
            ),
            maxLines: 1, // 💡 حماية من النزول لسطر جديد لو الكلمة طويلة
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            isEmpty ? '—' : value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isEmpty ? Colors.grey.shade400 : Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Optimized row widget. Rebuilds only when [cloth] reference changes.
/// Uses RepaintBoundary to isolate painting from neighbors.
class ClothRowWidget extends StatelessWidget {
  final Cloth cloth;
  final List<TextEditingController> controllers;
  final VoidCallback? onChanged;

  const ClothRowWidget({
    super.key,
    required this.cloth,
    required this.controllers,
    this.onChanged,
  });

  String _getLabel(int i) {
    if (cloth.supportIroning) {
      switch (i) {
        case 0:
          return "ironing".tr;
        case 1:
          return "fast_iron".tr;
        case 2:
          return "cleaning_ironing".tr;
        case 3:
          return "fast_cleaning_ironing".tr;
        case 4:
          return "cleaning".tr;
        case 5:
          return "fast_cleaning".tr;
        default:
          return "price".tr;
      }
    } else {
      switch (i) {
        case 0:
          return "cleaning".tr;
        case 1:
          return "fast_cleaning".tr;
        default:
          return "price".tr;
      }
    }
  }

  void _openEditPanel(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Edit prices',
      barrierColor: Colors.black26,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (ctx, animation, _, __) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curved),
          child: Align(
            alignment: AlignmentDirectional.centerEnd, // 💡 تعديل ليتوافق مع الـ RTL/LTR
            child: _EditPricePanel(
              cloth: cloth,
              controllers: controllers,
              onDone: () {
                if (onChanged != null) onChanged!();
                Navigator.of(ctx).pop();
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Get.locale?.languageCode == "ar";

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          children: [
            // ── Cloth Name ───────────────────────────────
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                    start: 16), // 💡 تقليل البادينج عشان لو الشاشة صغيرة
                child: Text(
                  isArabic ? cloth.nameAr : cloth.nameEn,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  maxLines: 2, // السماح بسطرين لو الاسم طويل
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // ── Image ────────────────────────────────────
            Expanded(
              flex: 2,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedImageWidget(
                    imageUrl: cloth.image,
                    memCacheWidth: 120,
                    memCacheHeight: 120,
                    width: 50, // 💡 تصغير الصورة قليلاً لتوفير مساحة في الشاشات الصغيرة
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // ── Prices (tappable, live-updating) ──────────
            Expanded(
              flex: 4, // 💡 تعديل النسبة عشان تكون متوازنة أكثر
              child: InkWell(
                onTap: () => _openEditPanel(context),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ListenableBuilder(
                    listenable: Listenable.merge(controllers),
                    builder: (context, _) {
                      // 💡 استخدام Wrap بدلاً من Column + Row عشان الـ Chips تترص بشكل ديناميكي
                      // وتنزل سطر جديد لوحدها لو الشاشة صغرت
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(controllers.length, (index) {
                          return _PriceChip(
                            label: _getLabel(index),
                            value: controllers[index].text,
                          );
                        }),
                      );
                    },
                  ),
                ),
              ),
            ),

            // ── Support Ironing badge ─────────────────────
            Expanded(
              flex: 2,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: cloth.supportIroning ? Colors.green.shade50 : Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          cloth.supportIroning ? Colors.green.shade300 : Colors.blueGrey.shade200,
                    ),
                  ),
                  child: FittedBox(
                    // 💡 حماية الكلمة من إنها تكسر الشاشة لو كبرت
                    fit: BoxFit.scaleDown,
                    child: Text(
                      cloth.supportIroning ? 'yes'.tr : 'no'.tr,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            cloth.supportIroning ? Colors.green.shade700 : Colors.blueGrey.shade600,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Active Toggle (isolated state) ────────────
            Expanded(
              flex: 2,
              child: _ActiveToggle(cloth: cloth, onChanged: onChanged),
            ),

            // ── Sort Order ────────────────────────────────
            Expanded(
              flex: 2,
              child: Center(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${cloth.sort_order}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Isolated active toggle — uses ValueNotifier to avoid rebuilding the whole row.
class _ActiveToggle extends StatefulWidget {
  final Cloth cloth;
  final VoidCallback? onChanged;

  const _ActiveToggle({required this.cloth, this.onChanged});

  @override
  State<_ActiveToggle> createState() => _ActiveToggleState();
}

class _ActiveToggleState extends State<_ActiveToggle> {
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _isActive = widget.cloth.is_active;
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _isActive,
      activeThumbColor: AppColors.primaryColor,
      onChanged: (val) {
        setState(() => _isActive = val);
        widget.cloth.is_active = val;
        if (widget.onChanged != null) widget.onChanged!();
      },
    );
  }
}

/// Slide-in edit panel. Manages its own text field state —
/// no rebuilds propagate upward until the user taps "Done".
class _EditPricePanel extends StatefulWidget {
  final Cloth cloth;
  final List<TextEditingController> controllers;
  final VoidCallback onDone;

  const _EditPricePanel({
    required this.cloth,
    required this.controllers,
    required this.onDone,
  });

  @override
  State<_EditPricePanel> createState() => _EditPricePanelState();
}

class _EditPricePanelState extends State<_EditPricePanel> {
  late final List<TextEditingController> _localControllers;
  bool _anyChange = false;

  @override
  void initState() {
    super.initState();
    // Mirror values into local controllers so parent list doesn't rebuild while typing.
    _localControllers = widget.controllers.map((c) => TextEditingController(text: c.text)).toList();
  }

  @override
  void dispose() {
    for (final c in _localControllers) c.dispose();
    super.dispose();
  }

  String _getLabel(int i) {
    if (widget.cloth.supportIroning) {
      switch (i) {
        case 0:
          return "ironing".tr;
        case 1:
          return "fast_iron".tr;
        case 2:
          return "cleaning_ironing".tr;
        case 3:
          return "fast_cleaning_ironing".tr;
        case 4:
          return "cleaning".tr;
        case 5:
          return "fast_cleaning".tr;
        default:
          return "price".tr;
      }
    } else {
      switch (i) {
        case 0:
          return "cleaning".tr;
        case 1:
          return "fast_cleaning".tr;
        default:
          return "price".tr;
      }
    }
  }

  void _updateModel(int i, String value) {
    _anyChange = true;
    // Sync back to parent controller immediately
    widget.controllers[i].text = value;

    // Sync to model
    if (widget.cloth.supportIroning) {
      switch (i) {
        case 0:
          widget.cloth.prices.priceIroning = value;
          break;
        case 1:
          widget.cloth.prices.priceFastIroning = value;
          break;
        case 2:
          widget.cloth.prices.priceCleaningAndIroning = value;
          break;
        case 3:
          widget.cloth.prices.priceFastCleaningAndIroning = value;
          break;
        case 4:
          widget.cloth.prices.priceCleaning = value;
          break;
        case 5:
          widget.cloth.prices.priceFastCleaning = value;
          break;
      }
    } else {
      switch (i) {
        case 0:
          widget.cloth.prices.priceCleaning = value;
          break;
        case 1:
          widget.cloth.prices.priceFastCleaning = value;
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Get.locale?.languageCode == "ar";
    final cloth = widget.cloth;
    final screenWidth = MediaQuery.of(context).size.width; // 💡 لمعرفة عرض الشاشة الفعلي

    return Material(
      color: Colors.transparent,
      child: Container(
        // 💡 تعديل مهم: العرض هيكون 420، بس لو الشاشة أصغر من كدة هياخد عرض الشاشة بالكامل بدل ما يضرب
        width: screenWidth > 420 ? 420 : screenWidth,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x28000000),
              blurRadius: 24,
              offset: Offset(-4, 0),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedImageWidget(
                        imageUrl: cloth.image,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? cloth.nameAr : cloth.nameEn,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'edit_prices'.tr,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),

              // ── Price Fields ────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: List.generate(
                      (_localControllers.length / 2).ceil(),
                      (row) {
                        final leftIndex = row * 2;
                        final rightIndex = leftIndex + 1;
                        final hasRight = rightIndex < _localControllers.length;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _PriceField(
                                  label: _getLabel(leftIndex),
                                  controller: _localControllers[leftIndex],
                                  onChanged: (v) => _updateModel(leftIndex, v),
                                ),
                              ),
                              if (hasRight) ...[
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _PriceField(
                                    label: _getLabel(rightIndex),
                                    controller: _localControllers[rightIndex],
                                    onChanged: (v) => _updateModel(rightIndex, v),
                                  ),
                                ),
                              ] else
                                const Expanded(child: SizedBox()),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // ── Done Button ───────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_anyChange)
                        widget.onDone();
                      else
                        Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'done'.tr,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single labeled price input field.
class _PriceField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _PriceField({
    required this.label,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
            letterSpacing: 0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          onTap: () {
            if (controller.text.isEmpty) return;
            Future.microtask(() {
              controller.selection = TextSelection(
                baseOffset: 0,
                extentOffset: controller.text.length,
              );
            });
          },
          onChanged: onChanged,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixText: 'SAR ',
            prefixStyle: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }
}
