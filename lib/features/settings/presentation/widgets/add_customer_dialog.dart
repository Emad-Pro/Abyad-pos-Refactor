import 'package:abyadpos_tab/features/orders/presentation/controllers/order_cubit.dart';
import 'package:abyadpos_tab/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:get/get.dart';

void showAddCustomerDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const AddCustomerDialog();
    },
  );
}

class AddCustomerDialog extends StatefulWidget {
  const AddCustomerDialog({super.key});

  @override
  State<AddCustomerDialog> createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends State<AddCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  void _submitData() async {
    if (_formKey.currentState!.validate()) {
      await context
          .read<OrderCubit>()
          .addCustomer(context, _nameController.text, _mobileController.text);

      _nameController.clear();
      _mobileController.clear();

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1565C0);
    double screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        // Constrained width for tablet to look clean
        width: screenWidth > 1200 ? 500 : screenWidth * 0.5,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "add_new_customer".tr,
                  style: const TextStyle(
                      color: primaryBlue, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // --- Name Field (Reduced size) ---
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    labelText: 'name'.tr,
                    labelStyle: const TextStyle(fontSize: 16),
                    isDense: true, // Reduces overall height
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onTap: () {
                    if (_nameController.text.isNotEmpty) {
                      _nameController.selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: _nameController.text.length,
                      );
                    }
                  },
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'name_required'.tr : null,
                ),
                const SizedBox(height: 16),

                // --- Mobile Field (Strict LTR Lock) ---
                // --- Mobile Field (Total LTR Lock) ---
                Directionality(
                  textDirection:
                      TextDirection.ltr, // Keeps Label, Prefix, and Text locked to the left
                  child: TextFormField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 18, letterSpacing: 1.5),
                    onTap: () {
                      if (_mobileController.text.isNotEmpty) {
                        _mobileController.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: _mobileController.text.length,
                        );
                      }
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(9),
                    ],
                    decoration: InputDecoration(
                      hintText: '5********',
                      floatingLabelAlignment: FloatingLabelAlignment.start,
                      isDense: true,
                      // Using prefixIcon ensures +966 is ALWAYS visible
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 12, right: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "+966",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                            SizedBox(width: 4),
                            // Optional: a small vertical line to separate the code from the input
                            Text("|", style: TextStyle(color: Colors.grey, fontSize: 18)),
                          ],
                        ),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'phone_required'.tr;
                      if (value.length != 9) return 'phone_length_error'.tr;
                      if (!value.startsWith('5')) return 'phone_start_error'.tr;
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 32),

                // --- Buttons (Reduced size) ---
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.greyColor, // Gray background
                          foregroundColor: Colors.white, // Dark text for contrast
                          elevation: 0, // Flat professional look
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text("cancel".tr, style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submitData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text("submit".tr,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
