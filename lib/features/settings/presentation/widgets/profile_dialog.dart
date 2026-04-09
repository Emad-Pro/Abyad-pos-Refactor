import 'package:abyadpos_tab/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:abyadpos_tab/core/widgets/common_text.dart';

class ProfileDialog extends StatelessWidget {
  final GlobalKey<FormState> infoFormKey;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final VoidCallback onSave;
  final String version;
  final Widget Function(String, Widget) buildLabeledField;
  final InputDecoration Function(String, {String? prefixText}) inputDecoration;

  const ProfileDialog({
    super.key,
    required this.infoFormKey,
    required this.emailController,
    required this.phoneController,
    required this.onSave,
    required this.version,
    required this.buildLabeledField,
    required this.inputDecoration,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.35, // ⬅️ Half of screen width
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
                  key: infoFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title Row with Close Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 50),
                            child: Text(
                              "Edit Profile".tr,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      SizedBox(height: 20,),
                      // Email (disabled)
                      buildLabeledField(
                        'eMail'.tr,
                        TextFormField(
                          controller: emailController,
                          decoration:
                          InputDecoration(
                            prefixIconConstraints:
                            const BoxConstraints(minWidth: 0, minHeight: 0),
                            prefixStyle: const TextStyle(fontSize: 14),
                            hintText: 'example@company.com',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),

                          enabled: false,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Phone
                      buildLabeledField(
                        'Mobile No.'.tr,
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: TextFormField(
                            controller: phoneController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(
                                  left:  8, ),
                                child: Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: CommonText(text: '+966 ')),
                              ),
                              prefixIconConstraints:
                              const BoxConstraints(minWidth: 0, minHeight: 0),
                              prefixStyle: const TextStyle(fontSize: 14),
                              hintText: 'XXXXXXXXX',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "mobile_num_required".tr;
                              }
                              if (value.length < 9) {
                                return "mobile_9_digits".tr;
                              }
                              if (value.startsWith("0")) {
                                return "mobile_cannot_start_with_zero".tr;
                              }
                              return null;
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Save button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                           (){
                             onSave();
                           },
                            text: "Save".tr,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Text(
                      //   "app_v".tr + " $version",
                      //   style: TextStyle(
                      //     fontSize: 14,
                      //     color: Colors.blueGrey.withOpacity(0.6),
                      //   ),
                      // ),
                      // Update Prices + Version
                      // Container(
                      //   padding: const EdgeInsets.all(16),
                      //   decoration: BoxDecoration(
                      //     color: Colors.white,
                      //     borderRadius: BorderRadius.circular(5),
                      //     boxShadow: const [
                      //       BoxShadow(
                      //           color: Colors.black12,
                      //           blurRadius: 8,
                      //           offset: Offset(0, 2)),
                      //     ],
                      //   ),
                      //   child: Column(
                      //     children: [
                      //       // ElevatedButton(
                      //       //   onPressed: () {
                      //       //     Get.to(
                      //       //           () => const UpdatePricesScreen(),
                      //       //       transition: Transition.noTransition,
                      //       //     );
                      //       //   },
                      //       //   child: Text("update_products_prices".tr),
                      //       // ),
                      //  //     const SizedBox(height: 15),
                      //       Text(
                      //         "app_v".tr + " $version",
                      //         style: TextStyle(
                      //           fontSize: 14,
                      //           color: Colors.blueGrey.withOpacity(0.6),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
      ),
    );

  }
}
