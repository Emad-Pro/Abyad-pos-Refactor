import 'dart:io';

import 'package:abyadpos_tab/features/orders/presentation/controllers/order_cubit.dart';
import 'package:abyadpos_tab/features/auth/presentation/controllers/user_cubit.dart';
import 'package:abyadpos_tab/features/auth/presentation/controllers/user_state.dart';
import 'package:abyadpos_tab/features/dashboard/presentation/controllers/drawer_cubit.dart';
import 'package:abyadpos_tab/core/widgets/loader/loading_cubit.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_terminal_sdk/models/card_reader_callbacks.dart';
import 'package:flutter_terminal_sdk/models/data/purchase_response.dart';
import 'package:flutter_terminal_sdk/models/purchase_callbacks.dart';
import 'package:get/get.dart';
import 'package:place_picker_v2/uuid.dart';

import 'package:abyadpos_tab/features/settings/data/models/loan_model.dart';
import 'package:abyadpos_tab/core/widgets/common_text.dart';
import 'package:abyadpos_tab/core/widgets/common_widgets.dart';
import 'package:abyadpos_tab/core/config/api_client.dart';
import 'package:abyadpos_tab/core/config/api_endpoints.dart';

import 'package:abyadpos_tab/core/constants/image_constants.dart';
import 'package:abyadpos_tab/core/theme/app_colors.dart';
import 'package:abyadpos_tab/core/theme/font_constants.dart';
import 'package:abyadpos_tab/core/utils/location_helper.dart';
import 'package:abyadpos_tab/core/utils/nearpay_manager.dart';
import 'package:abyadpos_tab/core/utils/nfc_helper.dart';
import 'package:abyadpos_tab/core/utils/payment_dialog.dart';

import 'package:abyadpos_tab/core/widgets/ui_helpers.dart';
import 'package:abyadpos_tab/features/settings/presentation/widgets/collection_invoices.dart';

/// DataSource for LoansTable
class LoansDataSource extends DataTableSource {
  final List<Customer> _customers;
  final BuildContext context;
  final OrderCubit cubit;
  final ApiClient apiClient = ApiClient();

  LoansDataSource(this._customers, this.context, this.cubit);

  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  void sort<T>(Comparable<T> Function(Customer d) getField, bool ascending) {
    _customers.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    // --- STEP 1: PREVENT THE RANGE ERROR ---
    // If the table asks for an index we haven't received from the API yet,
    // show a loading row instead of crashing.
    if (index >= _customers.length) {
      return DataRow.byIndex(
        index: index,
        cells: List<DataCell>.generate(
          6, // Total number of columns
          (colIndex) => DataCell(
            colIndex == 0
                ? const SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('...', style: TextStyle(color: Colors.grey)),
          ),
        ),
      );
    }

    // --- STEP 2: RENDER ACTUAL DATA ---
    // This part only runs if the index exists in the list
    final c = _customers[index];
    final double loan = double.tryParse(c.loanAmount ?? "") ?? 0.0;

    return DataRow.byIndex(
      index: index,
      color: index % 2 == 0
          ? WidgetStateProperty.all(Colors.white)
          : WidgetStateProperty.all(Colors.grey[100]),
      onSelectChanged: (selected) {
        if (selected != null && selected) {
          _openCollectionDialog(context, c.phone ?? "");
        }
      },
      cells: [
        DataCell(Text(c.name)),
        DataCell(Directionality(textDirection: TextDirection.ltr, child: Text(c.phone))),
        DataCell(
          Text(
            int.tryParse((c.totalOrders ?? "0").replaceAll(",", ""))?.toString() ?? "0",
          ),
        ),
        DataCell(Text(formatNumber(c.totalAmountSpent ?? "0"))),
        DataCell(Text(formatNumber(c.loanAmount ?? "0"))),
        DataCell(
          loan > 0
              ? InkWell(
                  onTap: () {
                    showUserOweDialog(
                        context: context,
                        amountOwed: double.tryParse(c.loanAmount ?? "0") ?? 0.0,
                        mobileNumber: c.phone ?? "",
                        customer_id: c.id);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: SvgPicture.asset(
                      ImageConstants.Settings,
                      width: 24.0,
                      color: AppColors.primaryColor,
                    ),
                  ),
                )
              : const SizedBox(),
        ),
      ],
    );
  }

  void _openCollectionDialog(BuildContext context, String phone) {
    final userCubit = context.read<UserCubit>();

    // Get phone and establishment date safely;
    final String? establishDateStr = userCubit.state.userModel?.data.laundry_account_establish_date;

    final DateTime establishmentDate = (establishDateStr != null && establishDateStr.isNotEmpty)
        ? DateTime.tryParse(establishDateStr) ?? DateTime(2025, 5, 6)
        : DateTime(2025, 5, 6);

    showDialog(
      context: context,
      builder: (context) => CollectionInvoicesDialog(
        establishmentDate: establishmentDate,
        phone: phone, // Passing phone to the dialog
      ),
    );
  }

  // @override
  // DataRow getRow(int index) {
  //   final c = _customers[index];
  //   final double loan = double.tryParse(c.loanAmount ?? "") ?? 0.0;
  //   return DataRow.byIndex(
  //     index: index,
  //     color: index % 2 == 0
  //         ? MaterialStateProperty.all(Colors.white)
  //         : MaterialStateProperty.all(Colors.grey[100]),
  //     cells: [
  //       DataCell(Text(c.name)),
  //       DataCell(Directionality(textDirection:TextDirection.ltr,child: Text(c.phone))),
  //       DataCell(
  //         Text(
  //           int.tryParse((c.totalOrders ?? "0").replaceAll(",", ""))
  //                   ?.toString() ??
  //               "0",
  //         ),
  //       ),
  //       DataCell(Text(formatNumber(c.totalAmountSpent ?? "0"))),
  //       DataCell(Text(formatNumber(c.loanAmount ?? "0"))),
  //       DataCell(
  //         loan > 0
  //             ? InkWell(
  //                 onTap: () {
  //                   showUserOweDialog(
  //                       context: context,
  //                       amountOwed: double.tryParse(c.loanAmount ?? "0") ?? 0.0,
  //                       mobileNumber: c.phone ?? "",
  //                       customer_id: c.id);
  //
  //                   // Navigator.push(
  //                   //   context,
  //                   //   MaterialPageRoute(
  //                   //     builder: (_) => LoanDetailsScreen(customer: c),
  //                   //   ),
  //                   // );
  //                 },
  //                 child: Container(
  //                   padding: const EdgeInsets.all(10),
  //                   child: SvgPicture.asset(
  //                     ImageConstants.Settings,
  //                     width: 24.0,
  //                     color: AppColors.primaryColor,
  //                   ),
  //                 ),
  //               )
  //             : SizedBox(),
  //       ),
  //     ],
  //   );
  // }

  String formatNumber(String value) {
    if (value.isEmpty) return "0.00";

    value = value.replaceAll(",", "");

    final number = double.tryParse(value);
    if (number == null) return "0.00";

    return number.toStringAsFixed(2);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount {
    // Use the total from the backend (455), not the current list length (50)
    if (cubit.state.allLoansModel != null) {
      return cubit.state.allLoansModel!.data.pagination.total;
    }
    return _customers.length;
  }

  @override
  int get selectedRowCount => 0;

  void showUserOweDialog({
    required BuildContext context,
    required double amountOwed,
    required String mobileNumber,
    required int customer_id,
  }) {
    final _amountController = TextEditingController();
    final _discountController = TextEditingController();
    bool isDiscountEnabled = false;

    final _formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return BlocBuilder<UserCubit, UserState>(builder: (
          context,
          state,
        ) {
          final userData = state.userModel?.data;
          final bool isNearpayEnabled = userData?.nearpay_status ?? false;
          ;

          return StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(30.0), // Updated padding
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45, // Slightly bigger width
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "customer_debt_payment".tr,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 26),

                          // Mobile row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(
                                      "mobile".tr,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Directionality(
                                      textDirection: TextDirection.ltr,
                                      child: Text(
                                        mobileNumber,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(
                                      "customer_loan_amount".tr,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black),
                                    ),

                                    SizedBox(
                                      width: 10,
                                    ),
                                    //
                                    // Expanded(
                                    //   child:
                                    Text(
                                      amountOwed.toStringAsFixed(2),
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green),
                                    ),

                                    //),
                                    SvgPicture.asset(
                                      ImageConstants.riyalsvg,
                                      color: AppColors.greenColor,
                                      width: FontConstants.font_13,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 26),

                          // Customer Loan Amount row
                          // Row(
                          //   children: [
                          //
                          //   ],
                          // ),
                          // const SizedBox(height: 16),

                          // Amount input row
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "amount".tr,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _amountController,
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                  ],
                                  onTap: () {
                                    if (_amountController.text.isEmpty) return;

                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      _amountController.selection = TextSelection(
                                        baseOffset: 0,
                                        extentOffset: _amountController.text.length,
                                      );
                                    });
                                  },
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: "enter_amount".tr,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "amount_is_required".tr;
                                    }
                                    final val = double.tryParse(value);
                                    if (val == null || val <= 0) {
                                      return "enter_a_valid_number_greater_than_0".tr;
                                    }
                                    // // Must be exactly 2 decimals
                                    // final regex = RegExp(r'^\d+(\.\d{2})$');
                                    // if (!regex.hasMatch(value)) {
                                    //   return "enter_number_with_two_decimals".tr;
                                    // }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Discount switch row

                                Row(
                                  children: [
                                    Text(
                                      "discount".tr,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black),
                                    ),
                                    SizedBox(
                                      width: 30,
                                    ),
                                    Switch(
                                      value: isDiscountEnabled,
                                      onChanged: (val) {
                                        setState(() {
                                          isDiscountEnabled = val;
                                        });
                                      },
                                    ),
                                  ],
                                ),

                                // Discount text field (conditionally shown)
                                if (isDiscountEnabled) ...[
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _discountController,
                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                    ],
                                    onTap: () {
                                      if (_discountController.text.isEmpty) return;

                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        _discountController.selection = TextSelection(
                                          baseOffset: 0,
                                          extentOffset: _discountController.text.length,
                                        );
                                      });
                                    },
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: "enter_discount".tr,
                                    ),
                                    validator: (value) {
                                      if (isDiscountEnabled) {
                                        if (value == null || value.trim().isEmpty) {
                                          return "discount_required".tr;
                                        }
                                        final val = double.tryParse(value);
                                        if (val == null || val <= 0) {
                                          return "enter_a_valid_number_greater_than_0".tr;
                                        }
                                        if (val > amountOwed) {
                                          return "discount_must_be_less_or_equal".tr;
                                        }
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                                const SizedBox(height: 20),

                                // Payment buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: buildPaymentButton(
                                          label: 'Credit Card'.tr,
                                          icon: ImageConstants.cardSvg,
                                          selected: true,
                                          onTap: () async {
                                            void showError(String title, String message) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text("${title.tr}: ${message.tr}",
                                                      style: const TextStyle(color: Colors.white)),
                                                  backgroundColor: Colors.red,
                                                  duration: const Duration(seconds: 5),
                                                ),
                                              );
                                            }

                                            if (!_formKey.currentState!.validate()) return;

                                            // 1. Parse inputs once and safely
                                            final double enteredAmount =
                                                double.tryParse(_amountController.text.trim()) ??
                                                    0.0;
                                            final double discountAmount = isDiscountEnabled
                                                ? (double.tryParse(
                                                        _discountController.text.trim()) ??
                                                    0.0)
                                                : 0.0;

                                            // 2. Guard Clause
                                            if (enteredAmount <= 0) {
                                              UIHelper.showErrorSnackbar(
                                                  "please_enter_valid_amount".tr);
                                              return;
                                            }

                                            print(
                                                "Payment: $enteredAmount for $mobileNumber, discount: $discountAmount");

                                            if (!isNearpayEnabled) {
                                              // --- MANUAL CREDIT CARD FLOW ---
                                              context.read<LoadingCubit>().showLoading();

                                              await payCustomerLoan(
                                                  customerId: customer_id,
                                                  amount: enteredAmount,
                                                  discount: discountAmount,
                                                  paymentMethod: "credit_card",
                                                  context: context);

                                              await cubit.getLoans(
                                                pageNumber: 1,
                                                only_with_loan: cubit.state.showDebtorsOnly,
                                              );

                                              context.read<LoadingCubit>().hideLoading();
                                              Navigator.of(context).pop();
                                            } else {
                                              // --- NEARPAY FLOW ---

                                              // --- 0. PRE-FLIGHT NETWORK CHECKS ---
                                              final connectivity =
                                                  await Connectivity().checkConnectivity();
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
                                                  showError(
                                                      "server_unreachable", "nearpay_blocked");
                                                  return;
                                                }
                                              } catch (_) {
                                                showError("network_error", "gateway_unreachable");
                                                return;
                                              }

                                              // --- 1. HARDWARE & GPS CHECKS ---
                                              bool isNfcEnabled =
                                                  await NfcHelper().checkNfcStatus(context);
                                              if (!isNfcEnabled) return;

                                              context.read<LoadingCubit>().showLoading();

                                              bool isGpsOk =
                                                  await LocationHelper.ensureLocationIsReady();
                                              if (!isGpsOk) {
                                                context.read<LoadingCubit>().hideLoading();
                                                return;
                                              }

                                              final manager = NearPayManager();
                                              final userVM = BlocProvider.of<UserCubit>(context,
                                                  listen: false);

                                              // --- 2. MANAGER & INITIALIZATION ---
                                              if (manager.connectedTerminal == null) {
                                                try {
                                                  var result = await manager
                                                      .initializeNearPay(userVM)
                                                      .timeout(
                                                        const Duration(seconds: 25),
                                                        onTimeout: () =>
                                                            throw "handshake_timeout".tr,
                                                      );

                                                  if (result.hasError) {
                                                    await manager.logout();
                                                    result = await manager
                                                        .initializeNearPay(userVM)
                                                        .timeout(const Duration(seconds: 20));

                                                    if (result.hasError) {
                                                      if (context.mounted) {
                                                        context.read<LoadingCubit>().hideLoading();
                                                        showError("auth_failed",
                                                            result.error ?? "link_failed");
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
                                                final version =
                                                    await UIHelper.getCleanVersionExact();
                                                final transactionUuid = Uuid().generateV4();
                                                final customerReferenceNumber =
                                                    "Loan:$mobileNumber-$version";

                                                // Convert to Halalas
                                                int nearpayAmount = (enteredAmount * 100).round();

                                                await manager.connectedTerminal!.purchase(
                                                  amount: nearpayAmount,
                                                  scheme: null,
                                                  customerReferenceNumber: customerReferenceNumber,
                                                  intentUUID: transactionUuid,
                                                  callbacks: PurchaseCallbacks(
                                                    cardReaderCallbacks: CardReaderCallbacks(
                                                      onReaderDisplayed: () {
                                                        if (context.mounted)
                                                          context
                                                              .read<LoadingCubit>()
                                                              .hideLoading();
                                                      },
                                                      onReaderClosed: () {
                                                        if (context.mounted)
                                                          context
                                                              .read<LoadingCubit>()
                                                              .hideLoading();
                                                      },
                                                      onReaderError: (message) {
                                                        if (context.mounted) {
                                                          context
                                                              .read<LoadingCubit>()
                                                              .hideLoading();
                                                          showError("reader_error", message);
                                                        }
                                                      },
                                                      onCardReadFailure: (message) {
                                                        if (context.mounted) {
                                                          context
                                                              .read<LoadingCubit>()
                                                              .hideLoading();
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
                                                      // Check for Approval
                                                      bool isApproved = purchaseResponse
                                                              .getLastReceipt()
                                                              ?.getMadaReceipt()
                                                              .isApproved ??
                                                          false;

                                                      if (isApproved) {
                                                        // 1. Update Backend
                                                        await payCustomerLoan(
                                                            customerId: customer_id,
                                                            amount: enteredAmount,
                                                            discount: discountAmount,
                                                            paymentMethod: "nearpay",
                                                            context: context);

                                                        // 2. Refresh List
                                                        await cubit.getLoans(
                                                          pageNumber: 1,
                                                          only_with_loan:
                                                              cubit.state.showDebtorsOnly,
                                                        );

                                                        // 3. Close Dialog and Hide Loading
                                                        if (context.mounted) {
                                                          context
                                                              .read<LoadingCubit>()
                                                              .hideLoading();
                                                          Navigator.of(dialogCtx).pop();
                                                        }
                                                      } else {
                                                        if (context.mounted)
                                                          context
                                                              .read<LoadingCubit>()
                                                              .hideLoading();
                                                        UIHelper.showErrorSnackbar(
                                                            "Transaction Declined");
                                                      }
                                                    },
                                                  ),
                                                );
                                              } catch (e) {
                                                if (context.mounted)
                                                  context.read<LoadingCubit>().hideLoading();
                                                UIHelper.showErrorSnackbar("Error: $e");
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: buildPaymentButton(
                                          label: 'Cash'.tr,
                                          icon: ImageConstants.cashSvg,
                                          selected: true,
                                          onTap: () async {
                                            if (_formKey.currentState!.validate()) {
                                              final double amount =
                                                  double.tryParse(_amountController.text.trim()) ??
                                                      0.0;
                                              final double discount = isDiscountEnabled
                                                  ? double.tryParse(
                                                          _discountController.text.trim()) ??
                                                      0.0
                                                  : 0.0;
                                              print(
                                                  "Cash payment: $amount for $mobileNumber, discount: $discount");

                                              double enteredAmount = double.tryParse(
                                                  _amountController.text.toString())!;
                                              double discountAmount = 0.0;
                                              if (isDiscountEnabled)
                                                discountAmount = double.tryParse(
                                                    _discountController.text.toString())!;

                                              context.read<LoadingCubit>().showLoading();

                                              await payCustomerLoan(
                                                  customerId: customer_id,
                                                  amount: enteredAmount,
                                                  discount: discountAmount,
                                                  paymentMethod: "cash",
                                                  context: context);

                                              await cubit.getLoans(
                                                pageNumber: 1,
                                                only_with_loan: cubit.state.showDebtorsOnly,
                                              );
                                              context.read<LoadingCubit>().hideLoading();

                                              if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
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

  Future<void> payCustomerLoan({
    required int customerId,
    required double amount,
    required double discount,
    required String paymentMethod, // "cash" or "credit_card"
    BuildContext? context,
  }) async {
    if (context != null) {
      context.read<LoadingCubit>().showLoading();
    }

    try {
      final response = await apiClient.request(
        url: ApiEndPoints.BASE_URL + ApiEndPoints.payLoan,
        // <-- Make sure this is defined (loans/pay)
        method: 'POST',
        body: {
          "customer_id": customerId,
          "amount": amount,
          "discount": discount,
          "payment_method": paymentMethod,
        },
      );

      if (context != null) context.read<LoadingCubit>().hideLoading();

      if (response['status'] == true) {
        if (context != null) {
          UIHelper.showBottomFlash(
            context,
            title: response['message'],
            message: response['message'],
            isError: false,
          );
        }
      } else {
        if (context != null) {
          UIHelper.showBottomFlash(
            context,
            title: response['message'].toString(),
            message: response['message'].toString(),
            isError: true,
          );
        }
      }
    } catch (e) {
      if (context != null) context.read<LoadingCubit>().hideLoading();
      print("Error paying loan: $e");
      if (context != null) {
        UIHelper.showBottomFlash(
          context,
          title: "$e",
          message: e.toString(),
          isError: true,
        );
      }
    }
  }
}

/// Loans Table Widget
class LoansTable extends StatefulWidget {
  final GlobalKey<PaginatedDataTableState>? tableKey; // Add this  late LoansDataSource _dataSource;
  final List<Customer> customers;
  final OrderCubit cubit;
  final ValueChanged<String> onSearch;

  const LoansTable({
    Key? key,
    required this.customers,
    required this.cubit,
    required this.onSearch,
    this.tableKey,
  }) : super(key: key);

  @override
  _LoansTableState createState() => _LoansTableState();
}

class _LoansTableState extends State<LoansTable> {
  late LoansDataSource _dataSource;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final dataSource = LoansDataSource(widget.customers, context, widget.cubit);
    final int customerCount = widget.customers.length;
    // 🎯 FIX 1: Calculate the number of rows to display.
    // If the count is 5, we show 5 rows. If it's 20, we use a default of 10 for pagination.
    const int defaultRowsPerPage = 10;
    final int effectiveRowsPerPage = customerCount > 0 && customerCount < defaultRowsPerPage
        ? customerCount
        : defaultRowsPerPage;

    _dataSource = LoansDataSource(widget.customers, context, widget.cubit);
    final sliderCubit = context.watch<SideMenuCubit>();
    final orderCubit = context.watch<OrderCubit>();
    var screenWidth = sliderCubit.state.isCollapsed ? Get.width - 75 : Get.width - 230;
    //  final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // horizontal scroll for wide table
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: screenWidth),
        child: SizedBox(
          width: screenWidth,
          child: SingleChildScrollView(
            // vertical scroll for table rows
            child: orderCubit.state.isLoading
                ? Center(
                    child: CommonWidgets.noDataView(
                      title: "loading".tr,
                      subText: "".tr,
                    ),
                  )
                : PaginatedDataTable(
                    key: widget.tableKey, // <--- Add this
                    // rowsPerPage: widget.provider.pageSize ?? 10,
                    rowsPerPage: 10,
                    // 2. KEEP THIS: This allows the user to still see 50 per page if they want
                    availableRowsPerPage: const [10, 25, 50],
                    showEmptyRows: false,
                    // dataRowHeight: rowHeight,
                    // headingRowHeight: headerHeight,
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    showCheckboxColumn: false,
                    columnSpacing: 16,
                    headingRowColor: WidgetStateProperty.all(
                      const Color(0xffDDE1E4),
                    ),
                    columns: [
                      DataColumn(
                          label: Text("name".tr),
                          onSort: (i, asc) => _sort<String>((c) => c.name, i, asc)),
                      DataColumn(
                          label: Text("mobile".tr),
                          onSort: (i, asc) => _sort<String>((c) => c.phone, i, asc)),
                      DataColumn(
                          label: Text(
                            'order_count'.tr,
                          ),
                          numeric: true,
                          onSort: (i, asc) => _sort<num>(
                              (d) =>
                                  double.tryParse(d.totalAmountSpent?.replaceAll(",", "") ?? "0") ??
                                  0.0,
                              i,
                              asc)),
                      DataColumn(
                          label: Text("total_orders".tr),
                          numeric: true,
                          onSort: (i, asc) => _sort<num>(
                              (d) =>
                                  double.tryParse(d.loanAmount?.replaceAll(",", "") ?? "0") ?? 0.0,
                              i,
                              asc)),
                      DataColumn(
                          label: Text("loan_amount".tr),
                          numeric: true,
                          onSort: (i, asc) => _sort<num>(
                              (d) => int.tryParse(d.totalOrders?.replaceAll(",", "") ?? "0") ?? 0,
                              i,
                              asc)),
                      DataColumn(label: Text("Action_loan".tr)),
                    ],
                    source: LoansDataSource(
                        orderCubit.state.allLoansModel!.data.customers, context, orderCubit),
                    onPageChanged: (int firstRowIndex) {
                      // firstRowIndex moves in steps of 50 (0, 50, 100...)
                      // Page 1 = 0/50 + 1, Page 2 = 50/50 + 1, etc.
                      int targetPage = (firstRowIndex / 50).floor() + 1;

                      // Only fetch if we haven't loaded this data yet
                      if (orderCubit.state.allLoansModel!.data.customers.length <= firstRowIndex) {
                        orderCubit.getLoans(
                          pageNumber: targetPage,
                          only_with_loan: orderCubit.state.showDebtorsOnly,
                          search: searchController.text,
                        );
                      }
                    },
                  ),
          ),
        ),
      ),
    );
  }

  void _sort<T>(Comparable<T> Function(Customer d) getField, int columnIndex, bool ascending) {
    _dataSource.sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }
}
