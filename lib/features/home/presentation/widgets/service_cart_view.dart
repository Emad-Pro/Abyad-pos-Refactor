import 'package:abyadpos_tab/features/orders/presentation/controllers/order_cubit.dart';
import 'package:abyadpos_tab/features/orders/presentation/controllers/order_state.dart';

import 'package:abyadpos_tab/core/constants/app_value_constants.dart';
import 'package:abyadpos_tab/core/constants/image_constants.dart';
import 'package:abyadpos_tab/features/home/data/models/clothes_model.dart';
import 'package:abyadpos_tab/features/orders/data/models/order_model.dart';
import 'package:abyadpos_tab/core/theme/app_colors.dart';
import 'package:abyadpos_tab/core/theme/font_constants.dart';
import 'package:abyadpos_tab/main.dart';
import 'package:abyadpos_tab/features/auth/presentation/controllers/user_cubit.dart';
import 'package:abyadpos_tab/features/home/presentation/widgets/phone_lookup.dart';
import 'package:abyadpos_tab/features/home/presentation/widgets/service_category_view.dart';
import 'package:abyadpos_tab/core/widgets/loader/loading_cubit.dart';
import 'package:abyadpos_tab/core/utils/nearpay_manager.dart';
import 'package:abyadpos_tab/core/widgets/cached_image_widget.dart';
import 'package:abyadpos_tab/core/widgets/common_text.dart';
import 'package:abyadpos_tab/core/widgets/custom_button.dart';
import 'package:abyadpos_tab/core/widgets/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_terminal_sdk/models/nearpay_user_response.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import 'package:flutter_terminal_sdk/flutter_terminal_sdk.dart';

import 'package:abyadpos_tab/features/home/presentation/widgets/Name_lookup.dart';

final phoneFormatter = MaskTextInputFormatter(
  mask: '#########',
  filter: {"#": RegExp(r'[0-9]')}, // More explicit digit filter
);

class ServiceCartView extends StatefulWidget {
  bool reload;

  ServiceCartView({Key? key, required this.reload}) : super(key: key);

  @override
  _ServiceCartViewState createState() => _ServiceCartViewState();
}

class _ServiceCartViewState extends State<ServiceCartView> //   with WidgetsBindingObserver
{
  // bool _isExpress = false;
  bool _isExpress_dialog = false;
  bool _isPerItemPriceSwitch = false;

  bool _isTestIronOnlySwitch = false;
  bool _addDelivery = false;
  bool _isExpanded = false; // add this at the top of your widget (e.g. in State)
  bool _isCredit = true;
  bool _showEmptySpace = true;
  String terminalUUID = "";
  NearpayUser? user;
  bool isOrder_Details_Enabled = false;

  final _orderDetailsController = TextEditingController();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  final TextEditingController _numberController = TextEditingController();
  final TextEditingController countController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<FormState> formDialogKey = GlobalKey<FormState>();

  final GlobalKey<NameLookupFieldState> _nameFieldKey = GlobalKey<NameLookupFieldState>();
  final GlobalKey<PhoneLookupFieldState> _phoneFieldKey = GlobalKey<PhoneLookupFieldState>();

  // variables for handling SingleChildScrollView to scroll to
  // max up when user open the keyboard (custom auto scroll) and below its functions

  // final ScrollController _scrollController = ScrollController();
  // final FocusNode _nameFocusNode = FocusNode();
  // final FocusNode _phoneFocusNode = FocusNode();
  // double _previousKeyboardHeight = 0;

  Map<String, dynamic>? selectedUser;

  double vatAmount = 0.0;

//   Future<void> initilaizeNearPay() async {
//     final UserViewModel userViewModel =
//     Provider.of<UserViewModel>(context, listen: false);
//     final pref= await SharedPreferences.getInstance();
//
//    // final String uuid=pref.getString("terminalUUID").toString();
//     final uuid = pref.getString("terminalUUID");
//
//     // if(userViewModel.userModel?.data.nearpay_status!=true){
//     //   return;
//     // }
//     if (userViewModel.userModel?.data?.nearpay_status != true) {
//       return;
//     }
//       final FlutterTerminalSdk _terminalSdk = FlutterTerminalSdk();
//     try {
//
//       await _terminalSdk.initialize(
//         environment: Environment.production, // Choose sandbox, production, internal
//         googleCloudProjectNumber: 12345678, // Add your google cloud project number
//         huaweiSafetyDetectApiKey: "your_api_key", // Add your huawei safety detect api key
//         country: Country.sa, // Choose country: sa, tr, usa
//       );
//
//     } catch (e,s) {
//       ScaffoldMessenger.of(context).showSnackBar(
//          SnackBar(content: Text('NearPay Initialization Error:  $e')),
//       );
//       print("Error initializing TerminalSDK: $e");
//       context.read<LoadingProvider>().hideLoading();
//       FirebaseCrashlytics.instance.recordError(e,s);
//
//       return;
//     }
//
//     if (uuid == null || uuid.isEmpty||uuid=="null"){
//   print('its empty uuid:');
//   await  JwtLoginNearPay();
//     }
//     final updatedUuid = pref.getString("terminalUUID");
// if(updatedUuid != null && updatedUuid.isNotEmpty&&updatedUuid!="null"){
//   print('get terminal uuid:');
//
//   getTerminal(context);
// }
//
//
//   }

  // Future<void> InitilaizeHalaPos() async {
  //   await NativeSDK.initialize();
  //
  //   print("🧾 Starting purchase...");
  //   final response = await NativeSDK.createPurchaseRequest("40.00");
  //
  //   if (response == null) {
  //     print("❌ No response received");
  //     return;
  //   }
  //
  //   print("📊 Status: ${response['transactionStatusText']}");
  //   print("💬 Message: ${response['message']}");
  //   print("🪪 Transaction ID: ${response['transactionId']}");
  //
  //   if (response['transactionStatus'] == 0 || response['transactionStatus'] == 1) {
  //     print("✅ Transaction successful!");
  //   } else {
  //     print("⚠️ Transaction failed or cancelled");
  //   }
  // }

  void _handleButtonPress() {
    // Get the input text
    String inputText = _numberController.text;

    // Convert it to a number (int or double)
    int? number = int.tryParse(inputText);

    if (number != null) {
      // Call your function with the number
      _processNumber(number);
    } else {
      // Show an error if input is invalid
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number')),
      );
    }
  }

  Future<void> _processNumber(int number) async {
    // Example function
    print("Number received: $number");
    try {
      final mobile = "+966509649616";
      final code = number.toString();
      user = await FlutterTerminalSdk().verifyMobileOtp(
        mobileNumber: mobile,
        code: code,
      );
    } catch (e) {
      print("Error verifying OTP: $e");
    }
    // You can do anything here with the number
  }

  @override
  void initState() {
    super.initState();

    // Schedule async setup after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 1. ALWAYS check mounted first in a postFrameCallback
      if (!mounted) return;

      try {
        // 2. Use listen: false for one-time reads in initState
        final orderCubit = BlocProvider.of<OrderCubit>(context, listen: false);
        final userCubit = BlocProvider.of<UserCubit>(context, listen: false);
        final loading = BlocProvider.of<LoadingCubit>(context, listen: false);

        if (widget.reload) {
          orderCubit.clearSelectedItems();

          // 3. Double check mounted before calling setState
          if (mounted) {
            setState(() {
              selectedUser = null;
              _nameController.clear();
              _phoneController.clear();
            });
          }

          formKey.currentState?.reset();
          orderCubit.setWalletBalance(null);
          orderCubit.setExpress(false);
          FocusScope.of(context).unfocus();
          loading.hideLoading();
        }
        // Show loading before NearPay init

        if (userCubit.state.userModel?.data.nearpay_status == true) {
          if (!mounted) return;
          UIHelper().showLoading(context);
          // loading.showLoading();

          // Initialize NearPay safely
          final result = await NearPayManager().initializeNearPay(userCubit);

          if (!mounted) return;
          UIHelper().hideLoading(context);

          // Show feedback
          if (result.hasError) {
            UIHelper.showErrorSnackbar(result.error!);
          } else {
            //       UIHelper.showSuccessSnackbar("nearpay_connected_success".tr);
          }
        } else {}
      } catch (e, s) {
// 1. Record the error (Non-Fatal so the app doesn't restart)

        // 2. ONLY update the UI if the user is still on this screen
        if (mounted) {
          // Hide the loader using your Provider
          BlocProvider.of<LoadingCubit>(context, listen: false).hideLoading();

          // Optional: Show a user-friendly message
          UIHelper.showErrorSnackbar("Something went wrong. Please try again.");
        }
      }
    });

    // Optional: VAT setup if enabled
    final cubit = BlocProvider.of<UserCubit>(context, listen: false);
    final bool isVatEnabled = cubit.state.userModel?.data.vat_enabled ?? false;
    if (isVatEnabled) {
      if (!mounted) return;
      setState(() {
        // vatAmount = provider.userModel!.data.vat_number;
      });
    }
  }

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) async {
  //     if(widget.reload){
  //       var provider = Provider.of<OrderCubit>(context, listen: false);
  //
  //       provider.clearSelectedItems();
  //       setState(() {
  //         selectedUser = null;
  //
  //         _nameController.clear();
  //        // subTotal = 0.0;
  //        //  _isExpress = false;
  //         provider.setExpress(false);
  //       });
  //       FocusScope.of(context).unfocus();
  //       formKey.currentState?.reset();
  //       _phoneController.clear();
  //       orderCubit.setWalletBalance(=null;
  //
  //       context.read<LoadingProvider>().hideLoading();
  //     }
  //
  //     UserViewModel provider = Provider.of<UserViewModel>(context, listen: false);
  //
  //       final loading = context.read<LoadingProvider>();
  //       final userVM = context.read<UserViewModel>();
  //
  //       loading.showLoading();
  //
  //       final result = await NearPayManager().initializeNearPay(provider);
  //
  //       loading.hideLoading();
  //
  //       if (result.hasError) {
  //         UIHelper.showErrorSnackbar(result.error!);
  //       } else {
  //         UIHelper.showSuccessSnackbar("NearPay connected successfully");
  //       }
  //
  //
  //   });
  //   UserViewModel provider = Provider.of<UserViewModel>(context, listen: false);
  //
  //   if (provider.userModel!.data.vat_enabled) {
  //     setState(() {
  //       // vatAmount = provider.userModel!.data.vat_number;
  //     });
  //   }
  // }

  // void _scrollAfterKeyboard(bool isPhone) {
  //   if (_nameFocusNode.hasFocus || _phoneFocusNode.hasFocus) {
  //     // Wait for keyboard to open and layout to resize
  //     Future.delayed(const Duration(milliseconds: 300), () {
  //       WidgetsBinding.instance.addPostFrameCallback((_) {
  //         if (_scrollController.hasClients) {
  //
  //           // Scroll to near maxExtent
  //           final offset = isPhone
  //               ? _scrollController.position.maxScrollExtent - 0
  //               : _scrollController.position.maxScrollExtent - 10;
  //
  //           _scrollController.animateTo(
  //             offset,
  //             duration: const Duration(milliseconds: 300),
  //             curve: Curves.easeInOut,
  //           );
  //
  //           // After first scroll, remove the extra space
  //           if (_showEmptySpace) {
  //             setState(() => _showEmptySpace = false);
  //           }
  //         }
  //       });
  //     });
  //   }
  // }

  // @override
  // void dispose() {
  //   WidgetsBinding.instance.removeObserver(this);
  //   _scrollController.dispose();
  //   _nameFocusNode.dispose();
  //   _phoneFocusNode.dispose();
  //   super.dispose();
  // }

  // void didChangeMetrics() {
  //   final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
  //   print("keyboard: $keyboardHeight ::: prevH: $_previousKeyboardHeight");
  //   if (keyboardHeight == 0 && _previousKeyboardHeight > 0) {
  //     // Keyboard closed: scroll back to top
  //     _scrollController.animateTo(
  //       0,
  //       duration: const Duration(milliseconds: 300),
  //       curve: Curves.easeInOut,
  //     );
  //
  //     // Show the empty space again
  //    // setState(() => _showEmptySpace = true);
  //   }
  //   _previousKeyboardHeight = keyboardHeight;
  // }

  @override
  Widget build(BuildContext context) {
    final isExpress = context.read<OrderCubit>().state.isExpress;

    return SizedBox(
      width: double.infinity,
      height: Get.height,
      child: Card(
        color: Colors.white,
        child: BlocConsumer<OrderCubit, OrderState>(
            listener: (context, state) {},
            builder: (
              context,
              state,
            ) {
              final totals = calculateTotals(
                selectedItems: state.selectedItems,
                isExpress: state.isExpress,
              );

              double subTotal = totals['subTotal']!;
              double exAmount = totals['exAmount']!;

              // double subTotal = provider.selectedItems.fold(
              //     0.0,
              //     (intial, e) =>
              //         intial +
              //         (e['clothes_count'] *
              //             (checkprice(Cloth.fromJson(e['cloth']), e['only_ironing'],
              //                 isExpress))));
              // double exAmount = (provider.selectedItems.fold(
              //         0.0,
              //         (intial, e) =>
              //             intial +
              //             (e['clothes_count'] *
              //                 (checkprice(Cloth.fromJson(e['cloth']),
              //                     e['only_ironing'], true))))) -
              //     provider.selectedItems.fold(
              //         0.0,
              //         (intial, e) =>
              //             intial +
              //             (e['clothes_count'] *
              //                 (checkprice(Cloth.fromJson(e['cloth']),
              //                     e['only_ironing'], false))));
              return Container(
                padding: EdgeInsets.all(10.sp),
                child: SingleChildScrollView(
                  // controller: _scrollController,

                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Speed'.tr,
                            style: TextStyle(
                                fontSize: FontConstants.font_18,
                                fontWeight: FontWeightConstants.semiBold)),

                        const SizedBox(height: 8),
                        Row(
                          children: [
                            buildSpeedButton(
                              label: 'Normal'.tr,
                              selected: !isExpress,
                              exAmount: exAmount,
                              showPrice: isExpress,
                              // Show price on Normal only if Express is selected
                              pricePrefix: ' -',
                              cashColor: Color(0xff0077B3),
                              onTap: () {
                                setState(
                                    () => BlocProvider.of<OrderCubit>(context).setExpress(false));
                              },
                            ),
                            const SizedBox(width: 8),
                            buildSpeedButton(
                              label: 'Express'.tr,
                              selected: isExpress,
                              exAmount: exAmount,
                              showPrice: !isExpress,
                              // Show price on Express only if Normal is selected
                              pricePrefix: ' +',
                              cashColor: Color(0xff13AC6B),
                              onTap: () => setState(
                                  () => BlocProvider.of<OrderCubit>(context).setExpress(true)),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        //hide add Delivery text and check box

                        // CheckboxListTile(
                        //     value: _addDelivery,
                        //     contentPadding: EdgeInsets.all(0),
                        //     activeColor: AppColors.primaryColor,
                        //     controlAffinity: ListTileControlAffinity.leading,
                        //     checkboxScaleFactor: 1.3,
                        //     title: CommonText(
                        //       text: "Add Delivery".tr,
                        //       textAlign: TextAlign.start,
                        //       fontSize: FontConstants.font_13,
                        //       fontWeight: FontWeightConstants.medium,
                        //     ),
                        //     onChanged: (v) => setState(() => _addDelivery = v!)),
                        // const SizedBox(height: 8),
                        NameLookupField(
                          key: _nameFieldKey,
                          controller: _nameController,
                          onChanged: (name) async {
                            // if (name.length >= 2) {
                            //   try {
                            //     final viewModel = Provider.of<UserViewModel>(context, listen: false);
                            //     final users = await viewModel.lookupUsers(null, name);
                            //     print("######## users: $users");
                            //
                            //     // if (users != null && users.isNotEmpty) {
                            //     //   var user = users.first;
                            //     //   setState(() {
                            //     //     selectedUser = user;
                            //     //     _phoneController.text =
                            //     //         user['phone']?.toString().replaceAll('+966', '') ?? '';
                            //     //      orderCubit.setWalletBalance( = (user['wallet_balance'] ?? 0).toDouble();
                            //     //   });
                            //     // } else {
                            //     //   setState(() {
                            //     //     selectedUser = null;
                            //     //      orderCubit.setWalletBalance( = null;
                            //     //   });
                            //     // }
                            //   } catch (e) {
                            //     debugPrint("Error in lookupUsers by name: $e");
                            //   }
                            // }
                          },
                          onUserSelected: (name, data) {
                            if (data != null) {
                              setState(() {
                                selectedUser = data;
                                _phoneController.text =
                                    data['phone']?.toString().replaceAll('+966', '') ?? '';
                                context
                                    .read<OrderCubit>()
                                    .setWalletBalance((data['wallet_balance'] ?? 0).toDouble());
                              });
                            }
                          },
                        ),

                        const SizedBox(height: 12),

                        PhoneLookupField(
                          key: _phoneFieldKey,
                          controller: _phoneController,
                          onChanged: (data) async {
                            final orderCubit = BlocProvider.of<OrderCubit>(context, listen: false);
                            if (data.length == 9) {
                              try {
                                final userCubit =
                                    BlocProvider.of<UserCubit>(context, listen: false);

                                final users = await userCubit.lookupUsers(data, null);

                                print("######## users: $users");

                                if (users != null && users.isNotEmpty) {
                                  var user = users.first; // ✅ Use the first match
                                  orderCubit
                                      .setWalletBalance((user['wallet_balance'] ?? 0).toDouble());
                                  _nameController.text = user['name']?.toString() ?? '';
                                } else {
                                  orderCubit.setWalletBalance(null);
                                }
                              } catch (e) {
                                debugPrint("Error in onChanged lookupUser: $e");
                                orderCubit.setWalletBalance(null);
                              }
                            } else {
                              orderCubit.setWalletBalance(null);
                            }
                          },
                          onUserSelected: (controllerText, data) {
                            final orderCubit = BlocProvider.of<OrderCubit>(context, listen: false);
                            if (data != null) {
                              selectedUser = data;
                              _phoneController.text =
                                  data['phone']?.toString().replaceAll('+966', '') ?? "";
                              _nameController.text = data['name'] ?? "";
                              orderCubit.setWalletBalance((data['wallet_balance'] ?? 0).toDouble());
                            } else {
                              selectedUser = null;
                              orderCubit.setWalletBalance(null);
                            }
                          },
                        ),

                        UIHelper.verticalSpaceMd,
// Only show the following widgets if there are items in the cart
                        if (state.selectedItems.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CommonText(
                                text: "Order Details".tr,
                                fontSize: FontConstants.font_18,
                                fontWeight: FontWeightConstants.semiBold,
                              ),
                              IconButton(
                                icon: SvgPicture.asset(
                                  ImageConstants.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  UIHelper.showDialogOk(
                                    context,
                                    title: 'delete_all'.tr,
                                    message: 'confirm_remove_all_items_in_cart'.tr,
                                    onConfirm: () {
                                      BlocProvider.of<OrderCubit>(context, listen: false)
                                          .clearSelectedItems();
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              ),
                            ],
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _isExpanded
                                    ? state.selectedItems.length
                                    : (state.selectedItems.length > 3
                                        ? 3
                                        : state.selectedItems.length),
                                itemBuilder: (context, index) {
                                  final itemobj = state.selectedItems[index];
// Determine state from the saved map
                                  final bool isNotCustomized = itemobj['isCustomized'] == false;
                                  final bool itemOnlyIroning = itemobj['only_ironing'] ?? false;
                                  final bool itemOnlyCleaning = itemobj['only_cleaning'] ?? false;

                                  // // Determine customization state
                                  // final bool isNotCustomized =
                                  //     itemobj['isCustomized'] == false;
                                  final double? customPricePerUnit =
                                      itemobj['custom_price_per_unit'] as double?;
                                  final double? totalCustomPrice =
                                      itemobj['total_custom_price'] as double?;
                                  final bool showPriceView = isNotCustomized ||
                                      (customPricePerUnit != null && customPricePerUnit > 0);

                                  // Avoid repeated parsing
                                  final Cloth item = itemobj['cloth'] is Cloth
                                      ? itemobj['cloth']
                                      : Cloth.fromJson(itemobj['cloth']);

                                  // 👈 Update this call to include itemOnlyCleaning
                                  final double price = checkprice(
                                      item, itemOnlyIroning, itemOnlyCleaning, isExpress);

                                  // Build the ListTile as before
                                  Widget listItem = Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        OrderCubit cubit = BlocProvider.of<OrderCubit>(context);
                                        await UIHelper().openEditItemDialog(
                                          context: context,
                                          index: index,
                                          item: item,
                                          cubit: cubit,
                                          isArabic: isArabic,
                                          isExpress: isExpress,
                                          exAmount: exAmount,
                                        );
                                      },
                                      child: ListTile(
                                        isThreeLine: true,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        tileColor: const Color(0xffF9F9F9),
                                        leading: CachedImageWidget(
                                          imageUrl: item.image,
                                          fit: BoxFit.fill,
                                          borderRadius: 5,
                                          width: 60.0.w,
                                          height: 60.h,
                                        ),
                                        title: Row(
                                          children: [
                                            Expanded(
                                              child: CommonText(
                                                text: !isArabic ? item.nameEn : item.nameAr,
                                                fontSize: FontConstants.font_14,
                                                fontWeight: FontWeightConstants.semiBold,
                                              ),
                                            ),
                                            UIHelper.horizontalSpaceSm5,
                                            const Icon(Icons.edit, color: Colors.grey, size: 20),
                                          ],
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CommonText(
                                                    text: isNotCustomized
                                                        ? (itemobj['only_cleaning'] == true
                                                            ? "Wash Only".tr
                                                            : (itemobj['only_ironing'] == true
                                                                ? "Iron Only".tr
                                                                : "Wash & Iron".tr))
                                                        : getServiceLabelsFromPrices(itemobj, item,
                                                            itemobj['service_type'] == "fast"),
                                                    fontSize: FontConstants.font_11,
                                                    fontWeight: FontWeightConstants.medium,
                                                  ),
                                                  // child: CommonText(
                                                  //   text: isNotCustomized
                                                  //       ? getServiceLabelsFromPrices(
                                                  //           itemobj,
                                                  //           item,
                                                  //           isExpress)
                                                  //       : getServiceLabelsFromPrices(
                                                  //           itemobj,
                                                  //           item,
                                                  //           itemobj['service_type'] ==
                                                  //               "fast",
                                                  //         ),
                                                  //   fontSize: FontConstants.font_11,
                                                  //   fontWeight:
                                                  //       FontWeightConstants.medium,
                                                  // ),
                                                ),
                                                UIHelper.horizontalSpaceSm5,
                                                InkWell(
                                                  onTap: () => BlocProvider.of<OrderCubit>(context)
                                                      .deleteFromCart(index),
                                                  child: SvgPicture.asset(ImageConstants.delete),
                                                ),
                                              ],
                                            ),
                                            Wrap(
                                              alignment: WrapAlignment.start,
                                              crossAxisAlignment: WrapCrossAlignment.center,
                                              spacing: 2, // horizontal space
                                              runSpacing: 4,
                                              children: [
                                                if (showPriceView)
                                                  CommonText(
                                                    text: isNotCustomized
                                                        ? price.toStringAsFixed(1)
                                                        : (customPricePerUnit != null
                                                            ? customPricePerUnit.toStringAsFixed(1)
                                                            : ""),
                                                    color: Colors.black,
                                                    fontSize: FontConstants.font_12,
                                                    fontWeight: FontWeightConstants.semiBold,
                                                  ),
                                                if (showPriceView) UIHelper.horizontalSpaceSm3,
                                                if (showPriceView)
                                                  SvgPicture.asset(
                                                    ImageConstants.riyalsvg,
                                                    width: 12.w,
                                                    color: Colors.black,
                                                  ),
                                                const SizedBox(width: 5),
                                                CommonText(
                                                  text:
                                                      "${UIHelper().formatCountCompact(itemobj['clothes_count'])}X",
                                                  color: Colors.black,
                                                  fontSize: FontConstants.font_13,
                                                  fontWeight: FontWeightConstants.semiBold,
                                                ),
                                                // const Spacer(),
                                                UIHelper.horizontalSpaceSm3,

                                                CommonText(
                                                  text: isNotCustomized
                                                      ? (itemobj['clothes_count'] * price)
                                                          .toStringAsFixed(1)
                                                      : (totalCustomPrice != null &&
                                                              totalCustomPrice > 0
                                                          ? totalCustomPrice.toStringAsFixed(1)
                                                          : ((customPricePerUnit ?? 0) *
                                                                  itemobj['clothes_count'])
                                                              .toStringAsFixed(1)),
                                                  color: Colors.green,
                                                  fontSize: FontConstants.font_13,
                                                  fontWeight: FontWeightConstants.semiBold,
                                                ),
                                                UIHelper.horizontalSpaceSm3,
                                                SvgPicture.asset(
                                                  ImageConstants.riyalsvg,
                                                  width: 13.w,
                                                  color: Colors.green,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );

                                  // Apply fade to last collapsed item
                                  if (!_isExpanded &&
                                      state.selectedItems.length > 3 &&
                                      index == 2) {
                                    listItem = ShaderMask(
                                      shaderCallback: (rect) {
                                        return const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [Colors.white, Colors.transparent],
                                        ).createShader(
                                            Rect.fromLTWH(0, 0, rect.width, rect.height));
                                      },
                                      blendMode: BlendMode.dstIn,
                                      child: listItem,
                                    );
                                  }

                                  return listItem;
                                },
                              ),
                            ],
                          ),

                          // Expand/collapse button
                          if (state.selectedItems.length > 3)
                            Center(
                              child: IconButton(
                                icon: AnimatedRotation(
                                  turns: _isExpanded ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 250),
                                  child: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isExpanded = !_isExpanded;
                                  });
                                },
                              ),
                            ),

                          const SizedBox(height: 8),
                          // --- Pay Now Row ---
                          InkWell(
                            splashColor: Colors.transparent, // Removes the ripple
                            highlightColor:
                                Colors.transparent, // Removes the gray highlight on press
                            onTap: () =>
                                BlocProvider.of<OrderCubit>(context).setPrepaid(!state.isPrepaid),
                            // behavior: HitTestBehavior.opaque, // Ensures the entire area captures the tap
                            borderRadius:
                                BorderRadius.circular(8), // Optional: rounds the ripple effect
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0), // Adds a better touch target
                              child: Row(
                                children: [
                                  Transform.scale(
                                    scale:
                                        1.25, // Makes the actual checkbox graphic larger for tablets
                                    child: SizedBox(
                                      height: 32.h,
                                      width: 32.w,
                                      child: Checkbox(
                                        value: state.isPrepaid,
                                        activeColor: const Color(0xff13AC6B),
                                        side: BorderSide(width: 1.5, color: Colors.grey.shade400),
                                        onChanged: (bool? value) {
                                          BlocProvider.of<OrderCubit>(context)
                                              .setPrepaid(value ?? false);
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'payNow'.tr,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Total card
                          if (state.walletBalance != null && _phoneController.text.isNotEmpty)
                            state.walletBalance! <= 0
                                ? totalCard(subTotal, exAmount)
                                : totalCardUser(
                                    double.tryParse(state.walletBalance.toString()) ?? 0,
                                    subTotal,
                                    exAmount)
                          else
                            totalCard(subTotal, exAmount),

                          const SizedBox(height: 16),

                          // Discount switch
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "note".tr,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
                              ),
                              Switch(
                                value: isOrder_Details_Enabled,
                                onChanged: (val) {
                                  setState(() {
                                    isOrder_Details_Enabled = val;
                                  });
                                },
                              ),
                            ],
                          ),

                          if (isOrder_Details_Enabled) ...[
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 400,
                              child: TextFormField(
                                controller: _orderDetailsController,
                                style: const TextStyle(fontSize: 16),
                                maxLength: 30,
                                keyboardType: TextInputType.text,
                                onTap: () {
                                  if (_orderDetailsController.text.isEmpty) return;

                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    _orderDetailsController.selection = TextSelection(
                                      baseOffset: 0,
                                      extentOffset: _orderDetailsController.text.length,
                                    );
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: "enter_note".tr,
                                  border:
                                      OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding:
                                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 18),

                          // Confirm and Print button
                          CustomButton(
                            () async {
                              final cubit = BlocProvider.of<OrderCubit>(context);
                              if (formKey.currentState!.validate()) {
                                FocusScope.of(context).unfocus();
                                await handleOrderSubmission(
                                    context: context, isFastOrder: false, provider: cubit);
                                setState(() {
                                  selectedUser = null;
                                  subTotal = 0.0;
                                  cubit.setExpress(false);
                                  _nameController.clear();
                                  _phoneController.clear();
                                  _nameFieldKey.currentState?.clearSuggestions();
                                  _phoneFieldKey.currentState?.clearSuggestions();
                                  _orderDetailsController.clear();
                                  cubit.setWalletBalance(null);
                                  UIHelper.hideKeyboard(context);
                                });
                                setState(() {
                                  // ... your other resets
                                  cubit.setPrepaid(false); // Reset the checkbox
                                });
                              }
                            },
                            text: "Confirm and Print".tr,
                          ),
                          const SizedBox(height: 10),

                          // Fast order button
                          !state.isPrepaid
                              ? CustomButton(
                                  () async {
                                    FocusScope.of(context).unfocus();
                                    if (formKey.currentState!.validate()) {
                                      final cubit = BlocProvider.of<OrderCubit>(context);
                                      await handleOrderSubmission(
                                          context: context, isFastOrder: true, provider: cubit);
                                      setState(() {
                                        selectedUser = null;
                                        subTotal = 0.0;
                                        cubit.setExpress(false);
                                        _nameController.clear();
                                        _phoneController.clear();
                                        _nameFieldKey.currentState?.clearSuggestions();
                                        _phoneFieldKey.currentState?.clearSuggestions();
                                        _orderDetailsController.clear();
                                        cubit.setWalletBalance(null);
                                        UIHelper.hideKeyboard(context);
                                      });
                                    }
                                  },
                                  text: "fast_order".tr,
                                )
                              : SizedBox(),
                          const SizedBox(height: 10),
                          UIHelper.verticalSpaceMd,
                        ],
                      ],
                      //if (_showEmptySpace) SizedBox(height: 300),
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }

  Future<void> handleOrderSubmission({
    required bool isFastOrder,
    required BuildContext context,
    required OrderCubit provider,
  }) async {
    final formattedPhone = "+966${_phoneController.text}";
    var payload = {
      "clothes": provider.state.selectedItems.map((e) {
        final Map<String, dynamic> item = {
          "cloth_id": e['cloth_id'],
          "clothes_count": e['clothes_count'],
          "only_ironing": e['only_ironing'],
          "only_cleaning": e['only_cleaning'],

          // "service_type": _isExpress ? "fast" : "normal",
          "isCustomized": e['isCustomized'] ?? false,
          "details": e['details'] ?? "",
          // Use stored service_type if customized, otherwise use current _isExpress
          "service_type": (e['isCustomized'] ?? false)
              ? e['service_type'] ??
                  (context.read<OrderCubit>().state.isExpress ? "fast" : "normal")
              : (context.read<OrderCubit>().state.isExpress ? "fast" : "normal"),
        };

        // Add price_per_unit or total_custom_price if present
        if (e['custom_price_per_unit'] != null && e['custom_price_per_unit'] != 0.0) {
          item['custom_price_per_unit'] = (e['custom_price_per_unit'] as double).toStringAsFixed(2);
        } else if (e['total_custom_price'] != null && e['total_custom_price'] != 0.0) {
          item['total_custom_price'] = (e['total_custom_price'] as double).toStringAsFixed(2);
        }
        print("foiafjfjoi" + item['service_type']);
        return item;
      }).toList(),
      "order_type": _addDelivery ? "walkin-online" : "walkin-walkin",
      "prepaid": provider.state.isPrepaid,
      if (isFastOrder) "is_fast_order": true,
      if (_nameController.text.trim().isNotEmpty) "customer_name": _nameController.text,
      if (_phoneController.text.trim().isNotEmpty) "customer_phone": formattedPhone,
      if (_orderDetailsController.text.trim().isNotEmpty)
        "order_details": _orderDetailsController.text,
    };

    context.read<LoadingCubit>().showLoading();

    await provider.createOrder(context, payload, isFastOrder, provider.state.isPrepaid);
    provider.clearSelectedItems();

    context.read<LoadingCubit>().hideLoading();
  }

  Container totalCard(double subTotal, double exAmount) {
    final cubit = BlocProvider.of<UserCubit>(context, listen: false);
    final bool isVat = cubit.state.userModel?.data.vat_enabled ?? false;

    // Use your method to extract values from the subTotal
    final totalVatValues = UIHelper.calculateVatFromTotal(subTotal);
    final subTotalVat = totalVatValues["subtotal"]!;
    final vat = totalVatValues["vat"]!;
    final total = totalVatValues["total"]!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // If VAT is enabled, we show the extracted subtotal, otherwise the full amount
          buildSummaryRow('Sub Total'.tr, isVat ? subTotalVat : total, StringConstants.riyal),

          if (isVat) ...[
            const SizedBox(height: 4),
            buildSummaryRow('VAT'.tr, vat, StringConstants.riyal),
          ],

          const Divider(height: 20, thickness: 1),

          buildSummaryRow('Total Amount'.tr, total, StringConstants.riyal, isBold: true),
        ],
      ),
    );
  }

  Container totalCardUser(double userWallet, double subTotal, double exAmount) {
    final cubit = BlocProvider.of<UserCubit>(context, listen: false);
    final bool isVat = cubit.state.userModel?.data.vat_enabled ?? false;

    // Extracting values using your method
    final totalVatValues = UIHelper.calculateVatFromTotal(subTotal);
    final subTotalVat = totalVatValues["subtotal"]!;
    final vat = totalVatValues["vat"]!;
    final total = totalVatValues["total"]!;

    // The wallet pays against the 'total' (which is inclusive of VAT if enabled)
    double walletDeduction = userWallet >= total ? total : userWallet;
    double remainingToPay = total - walletDeduction;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          buildSummaryRow('Sub Total'.tr, isVat ? subTotalVat : total, StringConstants.riyal),
          if (isVat) ...[
            const SizedBox(height: 4),
            buildSummaryRow('VAT'.tr, vat, StringConstants.riyal),
          ],
          const SizedBox(height: 4),
          buildSummaryRow('customer_wallet'.tr + " (${userWallet.toStringAsFixed(1)} ${"sar".tr})",
              walletDeduction, StringConstants.riyal,
              isWallet: true),
          const Divider(height: 20, thickness: 1),
          buildSummaryRow('Total Amount'.tr, remainingToPay, StringConstants.riyal, isBold: true),
        ],
      ),
    );
  }

  Widget buildSpeedButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required double exAmount,
    required bool showPrice,
    required String pricePrefix,
    required Color cashColor, // "+" or "-"
  }) {
    final primary = Theme.of(context).primaryColor;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Color(0xffF5FCFF) : Colors.grey[200],
            border: Border.all(
              color: selected ? AppColors.primaryColor : Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? AppColors.primaryColor : Colors.grey[600],
                ),
              ),
              if (showPrice)
                Row(
                  children: [
                    SizedBox(width: 4),
                    SvgPicture.asset(
                      ImageConstants.riyalsvg,
                      width: 10.w,
                      color: cashColor,
                    ),
                    Text(
                      '$pricePrefix${exAmount.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeightConstants.semiBold,
                        color: cashColor,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Future<void>getTerminal(BuildContext context)async {
  //   context.read<LoadingProvider>().showLoading();
  //
  //   final pref= await SharedPreferences.getInstance();
  //
  //   final terminalUUID = await pref.getString("terminalUUID");
  //   // await UserViewModel().getJwtToken(context);
  //   try {
  //     print("cureentUUID: "+terminalUUID.toString());
  //
  //     final fetchedTerminal = await FlutterTerminalSdk().getTerminal(
  //       terminalUUID: terminalUUID.toString(),
  //     );
  //     _connectedTerminal=fetchedTerminal;
  //     context.read<ScanningProvider>().setConnectedTerminal(_connectedTerminal);
  //     NearPayManager().connectedTerminal =fetchedTerminal;
  //     context.read<LoadingProvider>().hideLoading();
  //
  //
  //   }
  //   catch (e,s) {
  //     context.read<LoadingProvider>().hideLoading();
  //     FirebaseCrashlytics.instance.recordError(e,s);
  //
  //     print("Error connecting terminal: $e");
  //     return;
  //   }
  // }

  // Future<void>JwtLoginNearPay()async {
  //   context.read<LoadingProvider>().showLoading();
  //
  //  try {
  //    final pref= await SharedPreferences.getInstance();
  //
  //    final jwt = await pref.getString("jwt_token");
  //    print("jwt used:"+jwt.toString());
  //    // var jwt= UserViewModel().userModel?.data.nearpay_token.toString();
  //    final terminal = await FlutterTerminalSdk().jwtLogin(
  //        jwt: jwt.toString()
  //    );
  //
  //    if(kDebugMode) {
  //      ScaffoldMessenger.of(context).showSnackBar(
  //        SnackBar(
  //          content: Text(' ${terminal.tid}'),
  //          backgroundColor: Colors.green,
  //          duration: Duration(seconds: 3),
  //          behavior: SnackBarBehavior.floating,
  //          // allows custom positioning
  //          margin: EdgeInsets.fromLTRB(
  //              16, 16, 16, 0), // top margin, left, right, bottom
  //        ),
  //      );
  //    }
  //    _connectedTerminal=terminal;
  //    // u can save in pref terminal UUID then use it to get terminal and test
  //    if(terminal.terminalUUID!=null){
  //      final String uuid=terminal.terminalUUID.toString();
  //
  //      pref.setString("terminalUUID", uuid);
  //
  //      print("terminalUUID:${terminal.terminalUUID}");
  //      print("Tid:${terminal.tid}");
  //      print("isReady:${terminal.isTerminalReady()}");
  //      terminalUUID = terminal.terminalUUID.toString() ;
  //    }
  //
  //
  //    context.read<LoadingProvider>().hideLoading();
  //
  //
  //
  //
  //    // Retrieve the UUID of the currently terminal session. This value can be reused later to fetch terminal session details using getTerminal().
  //  } catch (e) {
  //    context.read<LoadingProvider>().hideLoading();
  //    if(kDebugMode) {
  //      ScaffoldMessenger.of(context).showSnackBar(
  //        SnackBar(
  //          content: Text('Unexpected error: $e'),
  //          backgroundColor: Colors.red,
  //          duration: Duration(seconds: 3),
  //          behavior: SnackBarBehavior.floating,
  //          // allows custom positioning
  //          margin: EdgeInsets.fromLTRB(
  //              16, 16, 16, 0), // top margin, left, right, bottom
  //        ),
  //      );
  //    }
  //    print("Error verifying JWT: $e");
  //  }
  //

  // }

  Widget _buildPaymentButton({
    required String icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final primary = AppColors.primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.grey[200],
          border: Border.all(color: selected ? AppColors.primaryColor : Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon(icon, color: selected ? primary : Colors.grey[600]),
            SvgPicture.asset(icon, color: selected ? primary : Colors.grey[600]),
            UIHelper.horizontalSpaceSm5,
            // const SizedBox(width: 8),
            // Text(
            //   label,
            //   style: TextStyle(
            //     fontSize: 14,
            //     fontWeight: FontWeight.w600,
            //     color: selected ? primary : Colors.grey[600],
            //   ),
            // ),
            CommonText(
              text: label,
              color: selected ? primary : Colors.grey[600],
              fontSize: FontConstants.font_12,
              textAlign: TextAlign.center,
              fontWeight: FontWeightConstants.semiBold,
            )
          ],
        ),
      ),
    );
  }
}

String getServiceLabelsFromPrices(Map<String, dynamic> itemobj, Cloth item, bool isExpress) {
  final bool onlyIroning = itemobj['only_ironing'] ?? false;
  final bool onlyCleaning = itemobj['only_cleaning'] ?? false; // 👈 Add this check

  if (onlyIroning) {
    return "Iron Only".tr;
  } else if (onlyCleaning) {
    return "Wash Only".tr; // 👈 Return the new label
  } else {
    return "Wash & Iron".tr;
  }
}
// String getServiceLabelsFromPrices(
//     Map<String, dynamic> itemobj, Cloth cloth, bool isExpress) {
//   print("balreijo: " + itemobj['service_type']);
//   print("value ofisExpress: " + isExpress.toString());
//   String prefixlabel = "";
//   String label = isExpress ? "Express".tr : "Normal".tr;
//
//   prefixlabel = itemobj['only_ironing'] ? "IronOnly".tr : "Wash&Iron".tr;
//   if (cloth.prices.priceFastCleaning != null ||
//       cloth.prices.priceFastCleaningAndIroning != null ||
//       cloth.prices.priceFastIroning != null) {
//     //  label = "Express";
//   }
//   return prefixlabel + " - " + label;
// }

Widget buildSummaryRow(String title, double value, String currency,
    {bool isWallet = false, bool isBold = false}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title,
          style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.w600 : FontWeight.normal)),
      Spacer(),
      Directionality(
        textDirection: TextDirection.rtl,
        child: Text(
          isWallet ? ' ${value.toStringAsFixed(2)}-' : ' ${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? Colors.black : Colors.black87,
          ),
        ),
      ),
      UIHelper.horizontalSpaceSm3,
      SvgPicture.asset(
        ImageConstants.riyalsvg,
        width: 14.0,
      ),
    ],
  );
}
