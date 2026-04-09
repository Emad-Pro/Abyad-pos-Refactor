import 'package:abyadpos_tab/features/orders/presentation/controllers/order_cubit.dart';
import 'package:abyadpos_tab/features/orders/data/models/order_status_model.dart';
import 'package:abyadpos_tab/core/widgets/loader/loading_cubit.dart';
import 'package:abyadpos_tab/core/widgets/custom_button.dart';
import 'package:abyadpos_tab/core/widgets/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:abyadpos_tab/core/widgets/common_text.dart';
import 'package:abyadpos_tab/core/theme/font_constants.dart';

import 'package:abyadpos_tab/features/orders/data/models/order_model.dart';

void changeOrderStatus(
  BuildContext context,
  OrderStatusModel statusModel,
  Order order, {
  required void Function(bool success) callBack,
}) {
  final commentController = TextEditingController();
  int selectedStatusId = statusModel.data.availableStatuses.first.id;

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      // Use StatefulBuilder so we can react to keyboard changes
      return StatefulBuilder(
        builder: (context, setState) {
          // Check if keyboard is open
          bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.35,
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- Title ---
                    Row(
                      children: [
                        Expanded(
                          child: CommonText(
                            text: 'changeStatus'.tr,
                            fontSize: FontConstants.font_16,
                            fontWeight: FontWeightConstants.black,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, size: 24),
                        ),
                      ],
                    ),
                    UIHelper.verticalSpaceMd,

                    // --- The Dropdown (Disabled when keyboard is open) ---
                    IgnorePointer(
                      ignoring: isKeyboardOpen, // Blocks all clicks if keyboard is up
                      child: Opacity(
                        opacity: isKeyboardOpen ? 0.5 : 1.0, // Visual feedback
                        child: DropdownButtonFormField<int>(
                          initialValue: selectedStatusId,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            // Show a hint that you need to close keyboard
                            hintText: isKeyboardOpen ? 'Close keyboard to select' : null,
                          ),
                          onChanged: (val) {
                            if (val != null) selectedStatusId = val;
                          },
                          items: statusModel.data.availableStatuses
                              .map((s) => DropdownMenuItem<int>(
                                    value: s.id,
                                    child: CommonText(
                                      text: !Get.locale!.languageCode.startsWith('ar')
                                          ? s.nameEn
                                          : s.nameAr,
                                      fontSize: FontConstants.font_14,
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),

                    UIHelper.verticalSpaceSm,

                    // --- Comment Field ---
                    TextFormField(
                      controller: commentController,
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: 'note'.tr,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      // This ensures the UI updates when the keyboard opens/closes
                      onTap: () => setState(() {}),
                    ),

                    UIHelper.verticalSpaceMd,
                    CustomButton(() async {
                      final loading = context.read<LoadingCubit>();
                      final orderVM = context.read<OrderCubit>();

                      loading.showLoading();

                      await orderVM.callUpdateStatus(order.id.toString(), false, context, body: {
                        'order_id': order.id.toString(),
                        'status_id': selectedStatusId.toString(),
                        'comment': commentController.text,
                      });

                      if (!context.mounted) return; // Guard check

                      loading.hideLoading();
                      Navigator.pop(context); // ✅ Close the dialog ONLY after completion
                      callBack(true);
                    }, text: 'Confirm'.tr),

                    // CustomButton(() async {
                    //   final loading = context.read<LoadingProvider>();
                    //   final orderVM = context.read<OrderViewModel>();
                    //
                    //   Navigator.pop(context);
                    //
                    //   loading.showLoading();
                    //   await orderVM.callUpdateStatus(order.id.toString(), false, context, body: {
                    //     'order_id': order.id.toString(),
                    //     'status_id': selectedStatusId.toString(),
                    //     'comment': commentController.text,
                    //   });
                    //   loading.hideLoading();
                    //   callBack(true);
                    // }, text: 'Confirm'.tr),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
