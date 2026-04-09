import 'dart:io';

import 'package:abyadpos_tab/features/orders/presentation/controllers/order_cubit.dart';
import 'package:abyadpos_tab/features/auth/presentation/controllers/user_cubit.dart';
import 'package:abyadpos_tab/features/auth/presentation/controllers/user_state.dart';
import 'package:abyadpos_tab/core/widgets/loader/loading_cubit.dart';
import 'package:abyadpos_tab/core/utils/nearpay_manager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_terminal_sdk/models/card_reader_callbacks.dart';
import 'package:flutter_terminal_sdk/models/data/purchase_response.dart';
import 'package:flutter_terminal_sdk/models/purchase_callbacks.dart';
import 'package:flutter_terminal_sdk/models/terminal_response.dart';
import 'package:get/get.dart';
import 'package:place_picker_v2/uuid.dart';

import 'package:abyadpos_tab/core/config/api_client.dart';
import 'package:abyadpos_tab/core/config/api_endpoints.dart';

import 'package:abyadpos_tab/core/constants/app_value_constants.dart';
import 'package:abyadpos_tab/core/constants/image_constants.dart';
import 'package:abyadpos_tab/features/orders/data/models/order_model.dart';
import 'package:abyadpos_tab/features/auth/data/models/user_model.dart';
import 'package:abyadpos_tab/core/storage/sharedpref.dart';
import 'package:abyadpos_tab/core/theme/app_colors.dart';
import 'package:abyadpos_tab/core/theme/font_constants.dart';
import 'package:abyadpos_tab/main.dart';
import 'package:abyadpos_tab/features/home/presentation/widgets/service_cart_view.dart';
import 'package:abyadpos_tab/features/orders/presentation/screens/order_detail_screen.dart';
import 'package:abyadpos_tab/core/widgets/common_text.dart';
import 'package:abyadpos_tab/core/widgets/common_widgets.dart';
import 'package:abyadpos_tab/core/widgets/custom_button.dart';
import 'package:abyadpos_tab/core/widgets/ui_helpers.dart';
import 'package:flutter/material.dart';

import 'package:abyadpos_tab/core/utils/location_helper.dart';
import 'package:abyadpos_tab/core/utils/nfc_helper.dart';

TerminalModel? _connectedTerminal;

void setConnectedTerminal(TerminalModel? connectedTerminal) {
  _connectedTerminal = connectedTerminal;
}

void triggerOrderRefresh(BuildContext context, {bool isCurrent = true}) {
  if (!context.mounted) return;
  context.read<OrderCubit>().refreshOrders(context, isCurrent: isCurrent);
}

Future<void> showPaymentDialog(Order orderDetails, BuildContext context,
    {bool isLoanEnabled = true,
    bool prepaid_val = false, // Default value set here
    bool is_fast_order = false}) async {
  final String orderId = orderDetails.id;
  final String totalPrice = orderDetails.totalPrice;

  final String finalTotalPrice = orderDetails.finalTotalPrice;
  final discountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final int result_amount = (double.parse(finalTotalPrice) * 100).toInt();

  final String customerName = orderDetails.user.userName.toString();
  final String customerPhone = orderDetails.user.mobile;
  final String serviceType = orderDetails.status.nameEn;
  final String cleaningType = orderDetails.orderType;
  final List<Clothe> clothesListRaw = orderDetails.clothes;
  final List<Map<String, dynamic>> clothesList = clothesListRaw.cast<Map<String, dynamic>>();
  // final dynamic totalPrice = orderDetails.subTotal;
  final dynamic vat = orderDetails.vat_amount.toString();
  final dynamic total = orderDetails.finalTotalPrice;
  final UserCubit userCubit = BlocProvider.of<UserCubit>(context, listen: false);

  await showDialog(
    context: context,
    barrierDismissible: false, // <-- makes it undismissable
    builder: (dialogCtx) {
      return BlocConsumer<UserCubit, UserState>(
          listener: (context, state) {},
          builder: (
            context,
            state,
          ) {
            final userData = state.userModel?.data;
            final bool isLoanActive = userData?.loan_active ?? false;
            final bool isNearpayEnabled = userData?.nearpay_status ?? false;
            final String? loanLimit = userData?.loan_limit;

            return AlertDialog(
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  CommonText(text: "payment_order".tr + " " + "$orderId"),
                  Spacer(),
                  // IconButton(
                  //   onPressed: () {
                  //     Get.back();
                  //   },
                  //   icon: Icon(Icons.close),
                  // ),
                ],
              ),
              content: SizedBox(
                width: Get.width * 0.5,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildSummaryCard(
                        orderDetails,
                        '',
                        double.tryParse(orderDetails.finalTotalPrice) ?? 0,
                        true,
                        viewModel: context.watch<OrderCubit>(),
                        context: context,
                        discountController: discountController,
                        formKey: _formKey,
                        elevation: 1.0,
                      ),
                      UIHelper.verticalSpaceMd,
                      Card(
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all(15.0.w),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CommonText(
                                    text: "Items List".tr,
                                    fontSize: FontConstants.font_16,
                                    fontWeight: FontWeightConstants.semiBold,
                                  ),
                                  Spacer(),
                                  CommonText(
                                    text: orderDetails.clothes.length.toString() + " " + "Items".tr,
                                    fontSize: FontConstants.font_14,
                                    fontWeight: FontWeightConstants.regular,
                                  ),
                                ],
                              ),
                              UIHelper.verticalSpaceSm,
                              Column(
                                children: orderDetails.clothes.map((item) {
                                  return ListTile(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    tileColor: Color(0xffF9F9F9),
                                    leading: CommonWidgets.loadNetworkPhoto(
                                      item.clothImage,
                                      fit: BoxFit.fill,
                                      borderRadius: 5,
                                      width: 60.0.w,
                                      height: 60.h,
                                    ),
                                    title: CommonText(
                                      text: isArabic ? item.clothNameAr : item.clothName,
                                      fontSize: FontConstants.font_14,
                                      fontWeight: FontWeightConstants.semiBold,
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CommonText(
                                          text: item.serviceType.name.toLowerCase().tr,
                                          fontSize: FontConstants.font_11,
                                          fontWeight: FontWeightConstants.medium,
                                        ),
                                        Row(
                                          children: [
                                            CommonText(
                                              text: item.clothCount.toString() + "X",
                                              fontSize: FontConstants.font_11,
                                              fontWeight: FontWeightConstants.bold,
                                            ),
                                            Spacer(),
                                            SvgPicture.asset(
                                              ImageConstants.riyalsvg,
                                              color: AppColors.greenColor,
                                              width: FontConstants.font_13,
                                            ),
                                            UIHelper.horizontalSpaceSm3,
                                            CommonText(
                                              text: item.isCustomized
                                                  ? item.totalCustomPrice != null
                                                      ? item.totalCustomPrice.toString()
                                                      : item.custom_price_per_unit.toString()
                                                  : item.clothPrice,
                                              color: AppColors.greenColor,
                                              fontSize: FontConstants.font_13,
                                              fontWeight: FontWeightConstants.bold,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Column(
                                    children: [
                                      // --- Start Logic Scope ---
                                      ...(() {
                                        // 1. Parse base values from orderDetails
                                        final double finalTotal =
                                            double.tryParse(orderDetails.finalTotalPrice) ?? 0.0;
                                        final bool isVatEnabled = userData?.vat_enabled ?? false;

                                        // 2. Run your calculation method (from UIHelper)
                                        final totalVatValues =
                                            UIHelper.calculateVatFromTotal(finalTotal);

                                        // 3. Determine display values based on VAT status
                                        // If VAT is enabled, use your calculation. If not, use backend subTotal.
                                        final double displaySubTotal = isVatEnabled
                                            ? (totalVatValues["subtotal"] ?? 0.0)
                                            : (double.tryParse(orderDetails.subTotal) ??
                                                finalTotal);

                                        final double displayVat = totalVatValues["vat"] ?? 0.0;

                                        return [
                                          // --- Sub Total ---
                                          buildSummaryRow(
                                            'Sub Total'.tr,
                                            displaySubTotal,
                                            StringConstants.riyal,
                                          ),

                                          // --- VAT (Calculated using your method) ---
                                          if (isVatEnabled) ...[
                                            const SizedBox(height: 4),
                                            buildSummaryRow(
                                              'VAT'.tr,
                                              displayVat,
                                              StringConstants.riyal,
                                            ),
                                          ],

                                          // --- Customer Wallet ---
                                          if (orderDetails.paymentDetails?.walletTransaction !=
                                                  null &&
                                              orderDetails.paymentDetails!.walletTransaction!
                                                  .isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            buildSummaryRow(
                                              'customer_wallet'.tr,
                                              double.tryParse(orderDetails.paymentDetails!
                                                      .walletTransaction![0].amount) ??
                                                  0.0,
                                              StringConstants.riyal,
                                              isWallet: true,
                                            ),
                                          ],

                                          const Divider(height: 20, thickness: 1),

                                          // --- Final Total Amount ---
                                          buildSummaryRow(
                                            'Total Amount'.tr,
                                            finalTotal,
                                            StringConstants.riyal,
                                            isBold: true,
                                          ),
                                        ];
                                      }()),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                // buildPaymentButton(
                //   label: 'Credit Card'.tr,
                //   icon: ImageConstants.cardSvg,
                //   selected: true,
                //   onTap: () {
                //     Navigator.of(dialogCtx).pop();
                //     _confirmPaymentType(orderId, "credit_card", context);
                //   },
                // ),
                // buildPaymentButton(
                //   icon: ImageConstants.cashSvg,
                //   label: 'Cash'.tr,
                //   selected: true,
                //   onTap: () {
                //     Navigator.of(dialogCtx).pop();
                //     _confirmPaymentType(orderId, "cash", context);
                //   },
                // ),

                Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // distribute space
                    children: [
                      if (double.tryParse(orderDetails.finalTotalPrice) != 0) ...[
                        isNearpayEnabled
                            ? Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                                  child: buildPaymentButton(
                                    label: 'abyad_pay'.tr,
                                    icon: ImageConstants.cardSvg,
                                    selected: true,
                                    onTap: () async {
                                      // Helper to show the specific snackbar you requested
                                      void showError(String title, String message) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text("${title.tr}: ${message.tr}",
                                                style: const TextStyle(color: Colors.white)),
                                            backgroundColor: Colors.red,
                                            duration: const Duration(seconds: 50),
                                          ),
                                        );
                                      }

                                      // if (!isNearpayEnabled) {
                                      //  var is_close= context.read<OrderViewModel>().close_and_complete;
                                      //  var discount_val=discountController.text.toString();
                                      //   await _confirmPaymentType(orderId, "credit_card", context,prepaid_val,discount_val,close_and_complete:is_close );
                                      //   triggerOrderRefresh(context, isCurrent: true);
                                      //   triggerOrderRefresh(context, isCurrent: false);
                                      //  // 4. RESET THE UI STATE
                                      //  context.read<OrderViewModel>().resetPaymentFields();
                                      //  discountController.clear(); // Clear the text field as well
                                      //   Navigator.of(dialogCtx).pop();
                                      // }
                                      // else {
                                      // --- 0. PRE-FLIGHT NETWORK CHECKS ---
                                      final connectivity = await Connectivity().checkConnectivity();
                                      if (connectivity == ConnectivityResult.none) {
                                        showError("connection_error", "no_internet");
                                        return;
                                      }

                                      try {
                                        await InternetAddress.lookup('google.com')
                                            .timeout(const Duration(seconds: 5));
                                        final nearpayLookup =
                                            await InternetAddress.lookup('api.nearpay.io')
                                                .timeout(const Duration(seconds: 5));

                                        if (nearpayLookup.isEmpty ||
                                            nearpayLookup[0].rawAddress.isEmpty) {
                                          showError("server_unreachable", "nearpay_blocked");
                                          return;
                                        }
                                      } catch (_) {
                                        showError("network_error", "gateway_unreachable");
                                        return;
                                      }

                                      // --- 1. HARDWARE & GPS CHECKS ---
                                      bool isNfcEnabled = await NfcHelper().checkNfcStatus(context);
                                      if (!isNfcEnabled) return;

                                      context.read<LoadingCubit>().showLoading();

                                      bool isGpsOk = await LocationHelper.ensureLocationIsReady();
                                      if (!isGpsOk) {
                                        context.read<LoadingCubit>().hideLoading();
                                        return;
                                      }

                                      final manager = NearPayManager();
                                      final userVM =
                                          BlocProvider.of<UserCubit>(context, listen: false);

                                      // --- 2. MANAGER & INITIALIZATION ---
                                      if (manager.connectedTerminal == null) {
                                        try {
                                          var result =
                                              await manager.initializeNearPay(userVM).timeout(
                                                    const Duration(seconds: 25),
                                                    onTimeout: () => throw "handshake_timeout".tr,
                                                  );

                                          if (result.hasError) {
                                            await manager.logout();
                                            result = await manager
                                                .initializeNearPay(userVM)
                                                .timeout(const Duration(seconds: 20));

                                            if (result.hasError) {
                                              if (context.mounted) {
                                                context.read<LoadingCubit>().hideLoading();
                                                showError(
                                                    "auth_failed", result.error ?? "link_failed");
                                              }
                                              return;
                                            }
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            context.read<LoadingCubit>().hideLoading();
                                            showError("init_error", e.toString());
                                          }
                                          return;
                                        }
                                      }

                                      // --- 3. TERMINAL VALIDATION ---
                                      if (manager.connectedTerminal?.terminalUUID == null) {
                                        context.read<LoadingCubit>().hideLoading();
                                        showError("state_error", "invalid_session");
                                        return;
                                      }

                                      // --- 4. THE PURCHASE ---
                                      try {
                                        final version = await UIHelper.getCleanVersionExact();
                                        final transactionUuid = Uuid().generateV4();
                                        final customerReferenceNumber =
                                            "${orderDetails.id}-$version";
                                        double price =
                                            double.tryParse(orderDetails.finalTotalPrice) ?? 0;
                                        int amountInHalalas = (price * 100).round();

                                        await manager.connectedTerminal!
                                            .purchase(
                                          amount: amountInHalalas,
                                          scheme: null,
                                          customerReferenceNumber: customerReferenceNumber,
                                          intentUUID: transactionUuid,
                                          callbacks: PurchaseCallbacks(
                                            cardReaderCallbacks: CardReaderCallbacks(
                                              onReaderDisplayed: () {
                                                if (context.mounted)
                                                  context.read<LoadingCubit>().hideLoading();
                                              },
                                              onReaderClosed: () {
                                                if (context.mounted)
                                                  context.read<LoadingCubit>().hideLoading();
                                              },
                                              onReaderError: (message) {
                                                if (context.mounted) {
                                                  context.read<LoadingCubit>().hideLoading();
                                                  showError("reader_error", message);
                                                }
                                              },
                                              onCardReadFailure: (message) {
                                                if (context.mounted) {
                                                  context.read<LoadingCubit>().hideLoading();
                                                  showError("card_error", message);
                                                }
                                              },
                                            ),
                                            onSendTransactionFailure: (message) {
                                              if (context.mounted) {
                                                context.read<LoadingCubit>().hideLoading();
                                                showError("network_failure",
                                                    "${"transaction_failed".tr} $message");
                                              }
                                            },
                                            onTransactionPurchaseCompleted:
                                                (PurchaseResponse purchaseResponse) async {
                                              if (context.mounted)
                                                context.read<LoadingCubit>().hideLoading();

                                              final receipt = purchaseResponse
                                                  .getLastReceipt()
                                                  ?.getMadaReceipt();
                                              if (receipt != null && receipt.isApproved) {
                                                //  String? cardScheme=receipt.cardScheme.name!.english.toString();
                                                // showError(cardScheme, cardScheme);
                                                var is_close = context
                                                    .read<OrderCubit>()
                                                    .state
                                                    .closeAndComplete;
                                                var discount_val =
                                                    discountController.text.toString();

                                                await _confirmPaymentType(orderId, "abyadpay",
                                                    context, prepaid_val, discount_val,
                                                    close_and_complete: is_close,
                                                    is_fast_order: is_fast_order);
                                                triggerOrderRefresh(context, isCurrent: true);
                                                triggerOrderRefresh(context, isCurrent: false);
                                                // 4. RESET THE UI STATE
                                                context.read<OrderCubit>().resetPaymentFields();
                                                discountController
                                                    .clear(); // Clear the text field as well
                                                if (dialogCtx.mounted)
                                                  Navigator.of(dialogCtx).pop();
                                              } else {
                                                showError("declined", "payment_not_approved");
                                              }
                                            },
                                          ),
                                        )
                                            .catchError((err) {
                                          if (context.mounted) {
                                            context.read<LoadingCubit>().hideLoading();
                                            showError("sdk_trigger_error", err.toString());
                                          }
                                        });
                                      } catch (e) {
                                        if (context.mounted) {
                                          context.read<LoadingCubit>().hideLoading();
                                          showError("purchase_block_error", e.toString());
                                        }
                                      }
                                      //     }
                                    },
//                           onTap: () async {
//                             if(!isNearpayEnabled){
//                              await _confirmPaymentType(orderId, "credit_card", context);
//                               triggerOrderRefresh(context, isCurrent: true);
//                              triggerOrderRefresh(context, isCurrent: false);
//
//                              Navigator.of(dialogCtx).pop();
//
//
//                               // context.read<OrderCubit>().getOrders(context);
//                               // context.read<OrderCubit>().getHistoryOrders(context);
//                             }
//
//                             else if(isNearpayEnabled){
//
//
//                               // 2. NFC Check
//                               bool isNfcEnabled = await NfcHelper().checkNfcStatus(context);
//                               if (!isNfcEnabled) return;
//
//                               // --- ADD THIS: Location Refresh ---
//                               context.read<LoadingCubit>().showLoading();
//
//                               bool isGpsOk = await LocationHelper.ensureLocationIsReady();
//
//                               if (!isGpsOk) {
//                                 context.read<LoadingCubit>().hideLoading();
//                                 return; // Helper already showed the specific snackbar error
//                               }
//
//                               final manager = NearPayManager();
//                               final userVM = Provider.of<UserViewModel>(context, listen: false);
//
// // 1. Check if terminal is null and try to initialize
//                               if (manager.connectedTerminal == null) {
//
//                                 // First attempt (This now includes your internal 'client_uuid' logic)
//                                 var result = await manager.initializeNearPay(userVM);
//
//                                 // 2. If it fails, we perform a "Hard Reset"
//                                 if (result.hasError) {
//                                   print("Initial NearPay Auth failed, attempting hard reset...");
//
//                                   // Clear everything: local prefs, SDK ghost session, and memory
//                                   await manager.logout();
//
//                                   // 3. Final attempt to initialize with a clean state
//                                   result = await manager.initializeNearPay(userVM);
//
//                                   if (result.hasError) {
//                                     if (context.mounted) {
//                                       context.read<LoadingCubit>().hideLoading();
//                                       // Use the error from the second attempt for the snackbar
//                                       UIHelper.showErrorSnackbar("NearPay Connection Failed: ${result.error}");
//                                     }
//                                     return; // Stop execution if even the reset failed
//                                   }
//                                 }
//                               }
//
//                            //   Navigator.of(dialogCtx).pop();
//
//                               //nearPay Production
//                          //   context.read<LoadingCubit>().showLoading();
//                              final version= await UIHelper.getCleanVersionExact();
//
//
//                               try {
//
//                                 final transactionUuid =  Uuid().generateV4(); // the transaction UUID should be unique for each transaction and managed by the developer to communicate with the SDK
//                                 final customerReferenceNumber = orderDetails.id+"-"+version;//[optional] any number you want to add as a refrence
//                                 double totalPrice = double.tryParse(orderDetails.finalTotalPrice) ?? 0; // convert to minor units (halalas)
//                                 int nearpayAmount = (totalPrice * 100).round(); // 123.45 -> 12345
//                                 final amount = nearpayAmount;
//                                 // final amount = result_amount ;
//
//
//                                 await NearPayManager().connectedTerminal!.purchase(
//                                   amount: amount,
//                                   scheme: null,   // eg.PaymentScheme.VISA, specifying this as null will allow all schemes to be accepted
//                                   customerReferenceNumber: customerReferenceNumber,
//                                   intentUUID: transactionUuid,
//                                   callbacks: PurchaseCallbacks(
//                                     cardReaderCallbacks: CardReaderCallbacks(
//                                       onReadingStarted: () {
//                                         print("Reading started...");
//
//                                       },
//                                       onReaderDisplayed: () {
//                                         print("Reader Displayed");
//                                       },
//                                       onReaderClosed: () {
//                                         print("Reading Closed");
//                                         if (context.mounted) {
//                                           context.read<LoadingCubit>().hideLoading();
//                                         }
//                                       },
//                                       onReaderWaiting: () {
//                                         print("Reader waiting...");
//                                       },
//                                       onReaderReading: () {
//                                         print("Reader reading...");
//                                       },
//                                       onReaderRetry: () {
//                                         print("Reader retrying...");
//                                       },
//                                       onPinEntering: () {
//                                         print("Entering PIN...");
//                                       },
//                                       onReaderFinished: () {
//
//                                         print("Reader finished.");
//                                       },
//                                       onReaderError: (message) {
//                                         ScaffoldMessenger.of(context).showSnackBar(
//                                           SnackBar(
//                                             content: Text("Error: $message"),
//                                             backgroundColor: Colors.redAccent,
//                                             duration:Duration(minutes: 1),
//                                           ),
//                                         );
//                                         if (context.mounted)
//                                         context
//                                             .read<
//                                             LoadingCubit>()
//                                             .hideLoading();
//                                       },
//                                       onCardReadSuccess: ()  {
//                                         print("Card readSuccess:");
//
//                                       },
//                                       onCardReadFailure: (message) {
//                                         if (context.mounted)
//                                         context.read<LoadingCubit>().hideLoading();
//                                         ScaffoldMessenger.of(context).showSnackBar(
//                                           SnackBar(
//                                             content: Text("Error: $message"),
//                                             backgroundColor: Colors.redAccent,
//                                             duration:Duration(minutes: 1),
//                                           ),
//                                         );
//                                         print("Card read failure: $message");
//                                       },
//                                     ),
//                                     onSendTransactionFailure: (message) {
//                                       if (context.mounted)
//                                      context.read<LoadingCubit>().hideLoading();
//                                      ScaffoldMessenger.of(context).showSnackBar(
//                                        SnackBar(
//                                          content: Text("Error: $message"),
//                                          backgroundColor: Colors.redAccent,
//                                          duration: Duration(minutes: 1),
//                                        ),
//                                      );
//
//                                       print("Transaction failed: $message");
//                                     },
//                                     onTransactionPurchaseCompleted: (PurchaseResponse purchaseResponse) async {
//                                       if (context.mounted)
//                                      context.read<LoadingCubit>().hideLoading();
//
//                                       print("status payment: "+purchaseResponse.status.toString());
//
//
//                                      if(purchaseResponse.getLastReceipt()!=null){
//
//                                        if( purchaseResponse.getLastReceipt()!.getMadaReceipt().isApproved){
//
//                                          await  _confirmPaymentType(orderId, "nearpay", context);
//                                          triggerOrderRefresh(context, isCurrent: true);
//                                          triggerOrderRefresh(context, isCurrent: false);
//
//                                          if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
//                                          if (kDebugMode) {
//                                          ScaffoldMessenger.of(context).showSnackBar(
//                                             SnackBar(
//                                              content: Text("✅ isApproved called here:"+purchaseResponse.getLastReceipt()!.getMadaReceipt().toString()),
//                                              backgroundColor: Colors.green,
//                                              duration: Duration(seconds: 60),
//                                            ),
//                                          );
//                                          }
//                                        }
//                                        else{
//                                          if (kDebugMode) {
//                                            ScaffoldMessenger.of(context).showSnackBar(
//                                              SnackBar(
//                                                content: Text(" failed not Approved:" + purchaseResponse
//                                                    .getLastReceipt()!.getMadaReceipt().toString()),
//                                                backgroundColor: Colors.red,
//                                                duration: Duration(seconds: 60),
//                                              ),
//                                            );
//                                          }
//
//                                        }
//
//                                      }
//                                      else{
//                                       if (kDebugMode) {
//                                         ScaffoldMessenger.of(context)
//                                             .showSnackBar(
//                                           SnackBar(
//                                             content: Text("null: }"),
//                                             backgroundColor: Colors.red,
//                                             duration: Duration(seconds: 60),
//                                           ),
//                                         );
//                                       }
//
//                                      }
//
//                                       // Handle completed transaction
//
//                                       //PurchaseResponse will return all transaction with same intent id "transactionUuid"
//                                       //purchaseResponse.status will return the status of last transaction of the same intent id
//                                       //   purchaseResponse.getLastReceipt();
//                                       //    purchaseResponse.getLastReceipt();
//                                       print("Transaction completed: ${purchaseResponse}");
//                                       // To get the approved receipt based on the country you can got it like :
//                                       // purchaseResponse.transactions?.last.events?.first.receipt?.getMadaReceipt(); for Saudi Arabia
//                                       // purchaseResponse.transactions?.last.events?.first.receipt?.getEPXReceipt(); for USA
//                                       // purchaseResponse.transactions?.last.events?.first.receipt?.getBKMReceipt(); for Turkey
//
//                                     },
//                                   ),
//                                 );
//
//                               } catch (e) {
//                                 if (context.mounted)
//                                 context.read<LoadingCubit>().hideLoading();
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(
//                                       content: Text(' ${e}'),
//                                       backgroundColor: Colors.red,
//                                       duration: Duration(seconds: 60),
//                                     ),
//                                   );
//
//
//                                 print("Error purchasing: $e");
//                               }
//                             // context.read<LoadingCubit>().hideLoading();
//
//                             }
//
//
//
//                           },
                                  ),
                                ),
                              )
                            : SizedBox(),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                            child: buildPaymentButton(
                              label: 'Credit Card'.tr,
                              icon: ImageConstants.externalPosSvg,
                              selected: true,
                              onTap: () async {
                                var is_close = context.read<OrderCubit>().state.closeAndComplete;
                                var discount_val = discountController.text.toString();
                                await _confirmPaymentType(
                                    orderId, "credit_card", context, prepaid_val, discount_val,
                                    close_and_complete: is_close, is_fast_order: is_fast_order);
                                triggerOrderRefresh(context, isCurrent: true);
                                triggerOrderRefresh(context, isCurrent: false);
                                // 4. RESET THE UI STATE
                                context.read<OrderCubit>().resetPaymentFields();
                                discountController.clear(); // Clear the text field as well
                                Navigator.of(dialogCtx).pop();
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: buildPaymentButton(
                              icon: ImageConstants.cashSvg,
                              label: 'Cash'.tr,
                              selected: true,
                              onTap: () async {
                                var is_close = context.read<OrderCubit>().state.closeAndComplete;
                                var discount_val = discountController.text.toString();

                                await _confirmPaymentType(
                                    orderId, "cash", context, prepaid_val, discount_val,
                                    close_and_complete: is_close, is_fast_order: is_fast_order);
                                triggerOrderRefresh(context, isCurrent: true);
                                triggerOrderRefresh(context, isCurrent: false);
                                // 4. RESET THE UI STATE
                                context.read<OrderCubit>().resetPaymentFields();
                                discountController.clear(); // Clear the text field as well
                                Navigator.of(dialogCtx).pop();
                              },
                            ),
                          ),
                        ),
                        if (isLoanActive &&
                            (orderDetails.user.mobile != null && orderDetails.user.mobile != "") &&
                            isLoanEnabled)
                          // if(isLoanActive &&orderDetails.user.mobile!=null)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: buildPaymentButton(
                                icon: ImageConstants.loanSvg,
                                label: 'loan'.tr,
                                selected: true,
                                onTap: () async {
                                  var is_close = context.read<OrderCubit>().state.closeAndComplete;
                                  var discount_val = discountController.text.toString();

                                  await _confirmPaymentType(
                                      orderId, "loan", context, prepaid_val, discount_val,
                                      close_and_complete: is_close, is_fast_order: is_fast_order);
                                  triggerOrderRefresh(context, isCurrent: true);
                                  triggerOrderRefresh(context, isCurrent: false);
// 4. RESET THE UI STATE
                                  context.read<OrderCubit>().resetPaymentFields();
                                  discountController.clear(); // Clear the text field as well
                                  Navigator.of(dialogCtx).pop();
                                },
                              ),
                            ),
                          ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: buildPaymentButton(
                              label: 'split_payment'.tr,
                              icon: ImageConstants.split_paymentSvg, // Or a custom SVG
                              selected: true,
                              onTap: () {
                                // Get dynamic values from your existing logic
                                double discount = context.read<OrderCubit>().state.isDiscount
                                    ? (double.tryParse(discountController.text) ?? 0.0)
                                    : 0.0;
                                double total = double.tryParse(orderDetails.finalTotalPrice) ?? 0.0;

                                var is_close = context.read<OrderCubit>().state.closeAndComplete;
                                if (orderDetails.is_fast_order == true) {
                                  is_close = true;
                                }

                                print("val of prepaid_val: " + prepaid_val.toString());
                                showSplitPaymentDialog(
                                    order: orderDetails,
                                    loan_limit: loanLimit,
                                    order_id: orderId,
                                    context: context,
                                    originalTotal: total,
                                    discountAmount: discount,
                                    isLoanActive: isLoanActive &&
                                        (orderDetails.user.mobile != null &&
                                            orderDetails.user.mobile != ""),
                                    isNearpayEnabled: isNearpayEnabled,
                                    isPrepiad: prepaid_val,
                                    isFastOrder: is_fast_order,
                                    isClose: is_close,
                                    onConfirm: (m1, a1, m2, a2) {
                                      print("Confirming split: $m1 ($a1) & $m2 ($a2)");
                                      // Here you will call your _confirmSplitPayment API
                                    });
                              },
                            ),
                          ),
                        ),
                      ] else
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: buildPaymentButton(
                              icon: ImageConstants.doneSvg,
                              label: 'complete_order'.tr,
                              selected: true,
                              onTap: () async {
                                var discount_val = discountController.text.toString();
                                await _confirmPaymentType(
                                    orderId, "wallet", context, prepaid_val, discount_val,
                                    is_fast_order: is_fast_order);
                                triggerOrderRefresh(context, isCurrent: true);
                                triggerOrderRefresh(context, isCurrent: false);
                                // 4. RESET THE UI STATE
                                context.read<OrderCubit>().resetPaymentFields();
                                discountController.clear(); // Clear the text field as well
                                Navigator.of(dialogCtx).pop();
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              ],
            );
          });
    },
  );
}

Widget buildPaymentButton(
    {required String icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
    z}) {
  final primary = AppColors.primaryColor;
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 50,
      decoration: BoxDecoration(
          // border: Border.all(color: buttonBorderColor ?? Colors.white),
          borderRadius: BorderRadius.circular(8.0),
          // color: bgColor?? AppColors.mainColor,
          gradient: myCustomGrident()),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon(icon, color: selected ? primary : Colors.grey[600]),
          SvgPicture.asset(icon, color: Colors.white),
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
            textAlign: TextAlign.center,
            color: AppColors.whiteColor,
            fontWeight: FontWeightConstants.semiBold,
            fontSize: FontConstants.font_14,
          )
        ],
      ),
    ),
  );
}

LinearGradient myCustomGrident() {
  return LinearGradient(
      begin: Alignment(0.9775090217590332, 0.022490976378321648),
      end: Alignment(-0.022490976378321648, 0.022490976378321648),
      colors: [AppColors.primaryColor, AppColors.primaryColor]);
}

// Widget buildPaymentButton({
//   required String icon,
//   required String label,
//   required bool selected,
//   required VoidCallback onTap,
// }) {
//   final primary = AppColors.primaryColor;
//   return GestureDetector(
//     onTap: onTap,
//     child: Container(
//       height: 48,
//       decoration: BoxDecoration(
//         color: selected ? Colors.white : Colors.grey[200],
//         border: Border.all(
//           color: selected ? AppColors.primaryColor : Colors.grey[300]!,
//         ),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           SvgPicture.asset(
//             icon,
//             color: selected ? primary : Colors.grey[600],
//           ),
//           UIHelper.horizontalSpaceSm5,
//           CommonText(
//             text: label,
//             color: selected ? primary : Colors.grey[600],
//             fontSize: FontConstants.font_12,
//             textAlign: TextAlign.center,
//             fontWeight: FontWeightConstants.semiBold,
//           ),
//         ],
//       ),
//     ),
//   );
// }
//
// void showSplitPaymentDialog({
//   required Order order,
//   required BuildContext context,
//   required String order_id,
//   required String? loan_limit,
//   required double originalTotal,
//   required double discountAmount,
//   required bool isLoanActive,
//   required bool isNearpayEnabled,
//   required bool isPrepiad,
//   required bool isClose,
//   required Function(String method1, double amount1, String method2, double amount2) onConfirm,
// }) {
//   // --- LOAN CALCULATIONS ---
//   double limit = double.tryParse(loan_limit ?? "0") ?? 0.0;
//   double currentLoans = order.paymentDetails?.customer_total_loan ?? 0.0;
//   // This is how much more the customer can borrow
//   double remainingLoanBalance = limit - currentLoans;
//
//   final double finalTotal = originalTotal - discountAmount;
//   final double halfTotal = finalTotal / 2;
//
//   final TextEditingController _amount1Controller = TextEditingController(text: halfTotal.toStringAsFixed(2));
//   final TextEditingController _amount2Controller = TextEditingController(text: halfTotal.toStringAsFixed(2));
//
//   String? selectedMethod1 = "cash";
//   String? selectedMethod2;
//
//   List<String> getAvailableMethods(String? excludedMethod) {
//     List<String> methods = ["cash"];
//     if (isLoanActive) methods.add("loan");
//     if (isNearpayEnabled) {
//       methods.add("abyad_pay");
//     } else {
//       methods.add("credit_card");
//     }
//     if (excludedMethod != null) methods.remove(excludedMethod);
//     return methods;
//   }
//
//   showDialog(
//     context: context,
//       builder: (dialogCtx) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//
//             void resetToDefaultAmounts() {
//               _amount1Controller.text = halfTotal.toStringAsFixed(2);
//               _amount2Controller.text = halfTotal.toStringAsFixed(2);
//             }
//
//             // Logic to auto-adjust when loan is selected
//             void adjustForLoanSelection(String method, bool isFirstField) {
//               if (method == "loan" && limit > 0) {
//                 if (halfTotal > remainingLoanBalance) {
//                   // If half is too much, set loan to max available and other to remainder
//                   double maxLoan = remainingLoanBalance;
//                   double otherAmount = finalTotal - maxLoan;
//
//                   if (isFirstField) {
//                     _amount1Controller.text = maxLoan.toStringAsFixed(2);
//                     _amount2Controller.text = otherAmount.toStringAsFixed(2);
//                   } else {
//                     _amount2Controller.text = maxLoan.toStringAsFixed(2);
//                     _amount1Controller.text = otherAmount.toStringAsFixed(2);
//                   }
//                 }
//               }
//             }
//
//             bool isLoanAmountValid(String method, double amount) {
//               if (method == "loan" && limit > 0) {
//                 if (amount > remainingLoanBalance) {
//                   UIHelper.showErrorSnackbar(
//                       "${"loan_limit_exceeded".tr}: ${remainingLoanBalance.toStringAsFixed(2)} SAR"
//                   );
//                   return false;
//                 }
//               }
//               return true;
//             }
//
//             return AlertDialog(
//               title: Text("split_payment".tr),
//               content: SizedBox(
//                 width: MediaQuery.of(context).size.width * 0.5,
//                 child: SingleChildScrollView(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       // --- SUMMARY SECTION ---
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         color: Colors.grey[100],
//                         child: Column(
//                           children: [
//                             buildSummaryRow("total".tr, finalTotal, "SAR", isBold: true),
//                             if (limit > 0&&isLoanActive) ...[
//                               const SizedBox(height: 8),
//                               buildSummaryRow("available_loan_balance".tr, remainingLoanBalance, "SAR", isBold: true),
//
//                               Text("${"available_loan".tr}: ${remainingLoanBalance.toStringAsFixed(2)} SAR",
//                                   style: TextStyle(color: Colors.blueGrey[700], fontSize: 13, fontWeight: FontWeight.w500)),
//                             ]
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//
//                       // --- DROPDOWNS ---
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text("first_method".tr),
//                                 DropdownButton<String>(
//                                   isExpanded: true,
//                                   value: selectedMethod1,
//                                   items: getAvailableMethods(selectedMethod2).map((m) => DropdownMenuItem(value: m, child: Text(m.tr))).toList(),
//                                   onChanged: (val) {
//                                     setDialogState(() {
//                                       selectedMethod1 = val;
//                                       adjustForLoanSelection(val!, true);
//                                     });
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(width: 20),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text("second_method".tr),
//                                 DropdownButton<String>(
//                                   isExpanded: true,
//                                   value: selectedMethod2,
//                                   items: getAvailableMethods(selectedMethod1).map((m) => DropdownMenuItem(value: m, child: Text(m.tr))).toList(),
//                                   onChanged: (val) {
//                                     setDialogState(() {
//                                       selectedMethod2 = val;
//                                       adjustForLoanSelection(val!, false);
//                                     });
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 20),
//
//                       // --- AMOUNT FIELDS ---
//                       Row(
//                         children: [
//                           Expanded(
//                             child: TextFormField(
//                               controller: _amount1Controller,
//                               keyboardType: TextInputType.number,
//                               onTap: () => _amount1Controller.selection = TextSelection(baseOffset: 0, extentOffset: _amount1Controller.text.length),
//                               onChanged: (value) {
//                                 double val1 = double.tryParse(value) ?? 0;
//                                 if (val1 >= finalTotal || val1 <= 0 || !isLoanAmountValid(selectedMethod1 ?? "", val1)) {
//                                   setDialogState(() => resetToDefaultAmounts());
//                                 } else {
//                                   setDialogState(() => _amount2Controller.text = (finalTotal - val1).toStringAsFixed(2));
//                                 }
//                               },
//                             ),
//                           ),
//                           const SizedBox(width: 20),
//                           Expanded(
//                             child: TextFormField(
//                               controller: _amount2Controller,
//                               keyboardType: TextInputType.number,
//                               onTap: () => _amount2Controller.selection = TextSelection(baseOffset: 0, extentOffset: _amount2Controller.text.length),
//                               onChanged: (value) {
//                                 double val2 = double.tryParse(value) ?? 0;
//                                 if (val2 >= finalTotal || val2 <= 0 || !isLoanAmountValid(selectedMethod2 ?? "", val2)) {
//                                   setDialogState(() => resetToDefaultAmounts());
//                                 } else {
//                                   setDialogState(() => _amount1Controller.text = (finalTotal - val2).toStringAsFixed(2));
//                                 }
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 30),
//
//                       // --- CONFIRM BUTTON ---
//                       CustomButton(
//                             () async {
//                           double amt1 = double.tryParse(_amount1Controller.text) ?? 0;
//                           double amt2 = double.tryParse(_amount2Controller.text) ?? 0;
//
//                           if (selectedMethod1 == null || selectedMethod2 == null) {
//                             UIHelper.showErrorSnackbar("please_select_both_methods".tr);
//                             return;
//                           }
//
//                           if (!isLoanAmountValid(selectedMethod1!, amt1) || !isLoanAmountValid(selectedMethod2!, amt2)) return;
//
//                           // ... (rest of your existing NearPay / splitPayment logic)
//                         },
//                         text: "confirm_split".tr,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       }
//   );
// }
void showSplitPaymentDialog({
  required Order order,
  required BuildContext context,
  required String order_id,
  required String? loan_limit,
  required double originalTotal,
  required double discountAmount,
  required bool isLoanActive,
  required bool isNearpayEnabled,
  required bool isPrepiad,
  required bool isFastOrder,
  required bool isClose,
  required Function(String method1, double amount1, String method2, double amount2) onConfirm,
}) {
  // --- INITIAL DATA CALCULATIONS ---
  final double finalTotal = originalTotal - discountAmount;
  final double halfTotal = finalTotal / 2;

  // Loan Limit Logic
  double limit = double.tryParse(loan_limit ?? "0") ?? 0.0;
  double currentLoans = order.paymentDetails?.customer_total_loan ?? 0.0;
  double remainingLoanBalance = limit - currentLoans;

  // Controllers initialized with half total
  final TextEditingController _amount1Controller =
      TextEditingController(text: halfTotal.toStringAsFixed(2));
  final TextEditingController _amount2Controller =
      TextEditingController(text: halfTotal.toStringAsFixed(2));

  String? selectedMethod1 = "cash"; // Default first method
  String? selectedMethod2;

  // Define available methods
  List<String> getAvailableMethods(String? excludedMethod) {
    List<String> methods = ["cash"]; // "wallet" is commented out
    if (isLoanActive) methods.add("loan");
    if (isNearpayEnabled) {
      methods.add("abyad_pay");
      methods.add("credit_card");
    } else {
      methods.add("credit_card");
    }
    if (excludedMethod != null) methods.remove(excludedMethod);
    return methods;
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          // --- HELPER FUNCTIONS ---

          void resetToDefaultAmounts() {
            _amount1Controller.text = halfTotal.toStringAsFixed(2);
            _amount2Controller.text = halfTotal.toStringAsFixed(2);
          }

          // Validates if the amount exceeds loan credit
          bool isLoanAmountValid(String method, double amount) {
            if (method == "loan" && limit > 0) {
              if (amount > remainingLoanBalance) {
                UIHelper.showErrorSnackbar(
                    "${"loan_limit_exceeded".tr}: ${remainingLoanBalance.toStringAsFixed(2)} SAR");
                return false;
              }
            }
            return true;
          }

          // Proactively adjusts amounts if half-split exceeds loan credit
          void adjustForLoanSelection(String method, bool isFirstField) {
            if (method == "loan" && limit > 0) {
              if (halfTotal > remainingLoanBalance) {
                double maxLoan = remainingLoanBalance;
                double otherAmount = finalTotal - maxLoan;
                if (isFirstField) {
                  _amount1Controller.text = maxLoan.toStringAsFixed(2);
                  _amount2Controller.text = otherAmount.toStringAsFixed(2);
                } else {
                  _amount2Controller.text = maxLoan.toStringAsFixed(2);
                  _amount1Controller.text = otherAmount.toStringAsFixed(2);
                }
              }
            }
          }

          return AlertDialog(
            title: Text("split_payment".tr),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: SingleChildScrollView(
                // Fix 1: Scrollable to prevent overflow
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Summary Section
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        children: [
                          buildSummaryRow("Sub Total".tr, originalTotal, "SAR"),
                          if (discountAmount > 0)
                            buildSummaryRow("discount".tr, discountAmount, "SAR", isBold: false),
                          const Divider(),
                          buildSummaryRow("total".tr, finalTotal, "SAR", isBold: true),
                          if (limit > 0 && isLoanActive) ...[
                            const SizedBox(height: 4),
                            Align(
                              // alignment: Alignment.centerRight, // Aligns with the currency side
                              child: Text(
                                "${"available_loan_balance".tr}: ${remainingLoanBalance.toStringAsFixed(2)} SAR",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.normal, // Not bold
                                  color: Colors.grey[700], // Subtle color
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Dropdowns Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("first_method".tr,
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              DropdownButton<String>(
                                isExpanded: true,
                                value: selectedMethod1,
                                items: getAvailableMethods(selectedMethod2)
                                    .map((m) => DropdownMenuItem(value: m, child: Text(m.tr)))
                                    .toList(),
                                onChanged: (val) {
                                  setDialogState(() {
                                    selectedMethod1 = val;
                                    adjustForLoanSelection(val!, true);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("second_method".tr,
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              DropdownButton<String>(
                                isExpanded: true,
                                value: selectedMethod2,
                                hint: Text("select_method".tr),
                                items: getAvailableMethods(selectedMethod1)
                                    .map((m) => DropdownMenuItem(value: m, child: Text(m.tr)))
                                    .toList(),
                                onChanged: (val) {
                                  setDialogState(() {
                                    selectedMethod2 = val;
                                    adjustForLoanSelection(val!, false);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Amounts Row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _amount1Controller,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                labelText: "amount_one".tr, border: const OutlineInputBorder()),
                            onTap: () => _amount1Controller.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset: _amount1Controller.text.length), // Auto-Highlight
                            onChanged: (value) {
                              double val1 = double.tryParse(value) ?? 0;
                              if (val1 >= finalTotal ||
                                  val1 <= 0 ||
                                  !isLoanAmountValid(selectedMethod1 ?? "", val1)) {
                                setDialogState(() => resetToDefaultAmounts());
                              } else {
                                double val2 = finalTotal - val1;
                                setDialogState(
                                    () => _amount2Controller.text = val2.toStringAsFixed(2));
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: TextFormField(
                            controller: _amount2Controller,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                labelText: "amount_two".tr, border: const OutlineInputBorder()),
                            onTap: () => _amount2Controller.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset: _amount2Controller.text.length), // Auto-Highlight
                            onChanged: (value) {
                              double val2 = double.tryParse(value) ?? 0;
                              if (val2 >= finalTotal ||
                                  val2 <= 0 ||
                                  !isLoanAmountValid(selectedMethod2 ?? "", val2)) {
                                setDialogState(() => resetToDefaultAmounts());
                              } else {
                                double val1 = finalTotal - val2;
                                setDialogState(
                                    () => _amount1Controller.text = val1.toStringAsFixed(2));
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Confirm Button
                    CustomButton(
                      () async {
                        if (selectedMethod1 == null || selectedMethod2 == null) {
                          UIHelper.showErrorSnackbar("please_select_both_methods".tr);
                          return;
                        }

                        double amt1 = double.tryParse(_amount1Controller.text) ?? 0;
                        double amt2 = double.tryParse(_amount2Controller.text) ?? 0;

                        if (amt1 <= 0 || amt2 <= 0) {
                          UIHelper.showErrorSnackbar("please_enter_valid_amounts".tr);
                          return;
                        }

                        if ((amt1 + amt2).toStringAsFixed(2) != finalTotal.toStringAsFixed(2)) {
                          UIHelper.showErrorSnackbar("amounts_must_equal_total".tr);
                          return;
                        }

                        // Final Loan check
                        if (!isLoanAmountValid(selectedMethod1!, amt1) ||
                            !isLoanAmountValid(selectedMethod2!, amt2)) return;

                        // NearPay / AbyadPay Logic
                        if (selectedMethod1 == "abyad_pay") {
                          _handleNearPaySplit(
                              context: dialogCtx,
                              splitAmount: amt1,
                              orderId: order_id,
                              method1: selectedMethod1!,
                              amount1: amt1,
                              method2: selectedMethod2!,
                              amount2: amt2,
                              isPrepaid: isPrepiad,
                              isFastOrder: isFastOrder,
                              isClose: isClose,
                              discountAmount: discountAmount);
                        } else if (selectedMethod2 == "abyad_pay") {
                          _handleNearPaySplit(
                              context: dialogCtx,
                              splitAmount: amt2,
                              orderId: order_id,
                              method1: selectedMethod1!,
                              amount1: amt1,
                              method2: selectedMethod2!,
                              amount2: amt2,
                              isPrepaid: isPrepiad,
                              isFastOrder: isFastOrder,
                              isClose: isClose,
                              discountAmount: discountAmount);
                        } else {
                          await splitPayment(
                              orderId: order_id,
                              paymentType: selectedMethod1!,
                              firstAmount: amt1,
                              secondPaymentType: selectedMethod2!,
                              discount: discountAmount.toString(),
                              closeAndHandover: isClose,
                              context: context,
                              prepaidVal: isPrepiad,
                              isFastOrder: isFastOrder);
                          triggerOrderRefresh(context, isCurrent: true);
                          triggerOrderRefresh(context, isCurrent: false);
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        }
                        onConfirm(selectedMethod1!, amt1, selectedMethod2!, amt2);
                      },
                      text: "confirm_split".tr,
                    ),
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

Future<void> _handleNearPaySplit({
  required BuildContext context,
  required double splitAmount,
  required String orderId,
  required String method1,
  required double amount1,
  required String method2,
  required double amount2,
  required bool isPrepaid,
  required bool isFastOrder,
  required bool isClose,
  required double discountAmount,
}) async {
  // Helper for error snackbars
  void showError(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${title.tr}: ${message.tr}", style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  // --- 0. PRE-FLIGHT NETWORK CHECKS ---
  final connectivity = await Connectivity().checkConnectivity();
  if (connectivity == ConnectivityResult.none) {
    showError("connection_error", "no_internet");
    return;
  }

  try {
    await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 5));
    final nearpayLookup =
        await InternetAddress.lookup('api.nearpay.io').timeout(const Duration(seconds: 5));
    if (nearpayLookup.isEmpty || nearpayLookup[0].rawAddress.isEmpty) {
      showError("server_unreachable", "abyadpay_blocked");
      return;
    }
  } catch (_) {
    showError("network_error", "gateway_unreachable");
    return;
  }

  // --- 1. HARDWARE & GPS CHECKS ---
  bool isNfcEnabled = await NfcHelper().checkNfcStatus(context);
  if (!isNfcEnabled) return;

  context.read<LoadingCubit>().showLoading();

  bool isGpsOk = await LocationHelper.ensureLocationIsReady();
  if (!isGpsOk) {
    context.read<LoadingCubit>().hideLoading();
    return;
  }

  final manager = NearPayManager();
  final userVM = BlocProvider.of<UserCubit>(context, listen: false);

  // --- 2. MANAGER & INITIALIZATION ---
  if (manager.connectedTerminal == null) {
    try {
      var result = await manager.initializeNearPay(userVM).timeout(
            const Duration(seconds: 25),
            onTimeout: () => throw "handshake_timeout".tr,
          );

      if (result.hasError) {
        await manager.logout();
        result = await manager.initializeNearPay(userVM).timeout(const Duration(seconds: 20));
        if (result.hasError) {
          if (context.mounted) {
            context.read<LoadingCubit>().hideLoading();
            showError("auth_failed", result.error ?? "link_failed");
          }
          return;
        }
      }
    } catch (e) {
      if (context.mounted) {
        context.read<LoadingCubit>().hideLoading();
        showError("init_error", e.toString());
      }
      return;
    }
  }

  // --- 3. TERMINAL VALIDATION ---
  if (manager.connectedTerminal?.terminalUUID == null) {
    context.read<LoadingCubit>().hideLoading();
    showError("state_error", "invalid_session");
    return;
  }

  // --- 4. THE PURCHASE ---
  try {
    final version = await UIHelper.getCleanVersionExact();
    final transactionUuid = Uuid().generateV4();
    // Reference includes "Split" to distinguish in NearPay dashboard
    final customerReferenceNumber = "Split-$orderId-$version";

    // Use the specific split amount passed to this function
    int amountInHalalas = (splitAmount * 100).round();

    await manager.connectedTerminal!
        .purchase(
      amount: amountInHalalas,
      scheme: null,
      customerReferenceNumber: customerReferenceNumber,
      intentUUID: transactionUuid,
      callbacks: PurchaseCallbacks(
        cardReaderCallbacks: CardReaderCallbacks(
          onReaderDisplayed: () {
            if (context.mounted) context.read<LoadingCubit>().hideLoading();
          },
          onReaderClosed: () {
            if (context.mounted) context.read<LoadingCubit>().hideLoading();
          },
          onReaderError: (message) {
            if (context.mounted) {
              context.read<LoadingCubit>().hideLoading();
              showError("reader_error", message);
            }
          },
          onCardReadFailure: (message) {
            if (context.mounted) {
              context.read<LoadingCubit>().hideLoading();
              showError("card_error", message);
            }
          },
        ),
        onSendTransactionFailure: (message) {
          if (context.mounted) {
            context.read<LoadingCubit>().hideLoading();
            showError("network_failure", "${"transaction_failed".tr} $message");
          }
        },
        onTransactionPurchaseCompleted: (PurchaseResponse purchaseResponse) async {
          if (context.mounted) context.read<LoadingCubit>().hideLoading();

          final receipt = purchaseResponse.getLastReceipt()?.getMadaReceipt();
          if (receipt != null && receipt.isApproved) {
            // --- SUCCESS FLOW ---

            await splitPayment(
                orderId: orderId,
                paymentType: method1,
                firstAmount: amount1,
                secondPaymentType: method2,
                discount: discountAmount.toString(),
                closeAndHandover: isClose,
                context: context,
                prepaidVal: isPrepaid,
                isFastOrder: isFastOrder);

// Refreshing UI
            triggerOrderRefresh(context, isCurrent: true);
            triggerOrderRefresh(context, isCurrent: false);
            Navigator.of(context).pop(); // Close split dialog
            Navigator.of(context).pop(); // Close main payment dialog

            // After successful API response:
            // triggerOrderRefresh(context, isCurrent: true);
            // triggerOrderRefresh(context, isCurrent: false);
            // context.read<OrderViewModel>().resetPaymentFields();
          } else {
            showError("declined", "payment_not_approved");
          }
        },
      ),
    )
        .catchError((err) {
      if (context.mounted) {
        context.read<LoadingCubit>().hideLoading();
        showError("sdk_trigger_error", err.toString());
      }
    });
  } catch (e) {
    if (context.mounted) {
      context.read<LoadingCubit>().hideLoading();
      showError("purchase_block_error", e.toString());
    }
  }
}

Future<void> _confirmPaymentType(
    String orderId, String paymentType, BuildContext context, bool prepaid_val, String discount,
    {bool close_and_complete = true, bool is_fast_order = false}) async {
  final ApiClient apiClient = ApiClient();
  context.read<LoadingCubit>().showLoading();

  try {
    UserModel? userModel;

    final response = await apiClient.request(
      url: ApiEndPoints.paymentType,
      method: 'POST',
      body: {
        "payment_type": paymentType,
        "order_id": orderId,
        "close_and_handover": close_and_complete,
        "discount": discount
      },
    );

    if (response['status'] == true) {
      if (prepaid_val || (prepaid_val == false && close_and_complete == false)) {
        Order? order = await context.read<OrderCubit>().getOrdersById(orderId);
        context.read<OrderCubit>().setCloseAndComplete(false);
        context.read<OrderCubit>().toggleIsDiscount(false);
        if (order != null && is_fast_order == false) {
          context.read<LoadingCubit>().hideLoading();

          // await   context.read<OrderViewModel>().smartPrintBill(context, order, isArabic);
          SharedPref pref = SharedPref();
          var doc = await pref.readObject('user') ?? null;
          if (doc != null) {
            userModel = UserModel.fromJson(doc);
          }
          if (userModel?.data.second_bill_enabled == true) {
            UIHelper.showPrintAnotherBillDialog(
              context,
              onYes: () {
                Future.delayed(Duration(seconds: 1)).then((value) {
                  //  printBill(context, order, isArabic);
                  context.read<OrderCubit>().smartPrintBill(context, order, isArabic);
                });
                print("Printing another bill...");
              },
            );
          }
        } else {
          context.read<LoadingCubit>().hideLoading();
        }
      }

      UIHelper.showBottomFlash(
        context,
        title: "${response['message'].toString()}",
        message: "${response['message'].toString()}",
        isError: false,
      );
      // if (paymentType == "credit") {
      //   UIHelper.showBottomFlash(
      //     context,
      //     title: "Redirecting to Geidea integration...",
      //     message: "Redirecting to Geidea integration...",
      //     isError: false,
      //   );
      //   // Navigator.of(context).pushNamed(
      //   //   "/geidea_integration",
      //   //   arguments: {"orderId": orderId},
      //   // );
      // } else {
      //
      //
      // }
    } else {
      context.read<LoadingCubit>().hideLoading();
      UIHelper.showBottomFlash(
        context,
        title: "${response['message'].toString()}",
        message: "${response['message'].toString()}",
        isError: true,
      );
    }
  } catch (e) {
    context.read<LoadingCubit>().hideLoading();

    print("Error updating payment type: $e");
    UIHelper.showBottomFlash(
      context,
      title: "An error occurred while updating payment type.",
      message: e.toString(),
      isError: true,
    );
  }
}

Future<void> splitPayment({
  required String orderId,
  required String paymentType, // First method
  required double firstAmount,
  required String secondPaymentType,
  required String discount,
  required bool closeAndHandover,
  required BuildContext context,
  bool prepaidVal = false,
  bool isFastOrder = false,
}) async {
  final ApiClient apiClient = ApiClient();
  context.read<LoadingCubit>().showLoading();

  try {
    UserModel? userModel;

    // Construct the Split Payment Payload
    final Map<String, dynamic> body = {
      "order_id": orderId,
      "payment_type": paymentType,
      "first_amount": firstAmount,
      "second_payment_type": secondPaymentType,
      "close_and_handover": closeAndHandover,
      "discount": discount,
      "prepaid": prepaidVal,
    };

    final response = await apiClient.request(
      url: ApiEndPoints.splitPayment, // Using the same endpoint as per your logic
      method: 'POST',
      body: body,
    );

    if (response['status'] == true) {
      // 1. Reset Global UI States
      context.read<OrderCubit>().setCloseAndComplete(false);
      context.read<OrderCubit>().toggleIsDiscount(false);
      context.read<OrderCubit>().resetPaymentFields();

      // 2. Printing Logic (Only if it's a receipt scenario)
      if (prepaidVal || (prepaidVal == false && closeAndHandover == false)) {
        Order? order = await context.read<OrderCubit>().getOrdersById(orderId);

        if (order != null && isFastOrder != true) {
          context.read<LoadingCubit>().hideLoading();

          // Print the first bill
          await context.read<OrderCubit>().smartPrintBill(context, order, isArabic);

          // Check for Second Bill configuration
          SharedPref pref = SharedPref();
          var doc = await pref.readObject('user');
          if (doc != null) {
            userModel = UserModel.fromJson(doc);
          }

          if (userModel?.data.second_bill_enabled == true) {
            UIHelper.showPrintAnotherBillDialog(
              context,
              onYes: () {
                Future.delayed(const Duration(seconds: 1)).then((value) {
                  context.read<OrderCubit>().smartPrintBill(context, order, isArabic);
                });
              },
            );
          }
        } else {
          context.read<LoadingCubit>().hideLoading();
        }
      } else {
        context.read<LoadingCubit>().hideLoading();
      }

      UIHelper.showBottomFlash(
        context,
        title: "success".tr,
        message: "${response['message']}",
        isError: false,
      );
    } else {
      context.read<LoadingCubit>().hideLoading();
      UIHelper.showBottomFlash(
        context,
        title: "error".tr,
        message: "${response['message']}",
        isError: true,
      );
    }
  } catch (e) {
    context.read<LoadingCubit>().hideLoading();
    print("Error in split payment: $e");
    UIHelper.showBottomFlash(
      context,
      title: "error_occurred".tr,
      message: e.toString(),
      isError: true,
    );
  }
}
