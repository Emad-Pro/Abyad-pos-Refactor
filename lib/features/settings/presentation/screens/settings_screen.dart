import 'dart:io';

import 'package:abyadpos_tab/features/orders/presentation/controllers/order_cubit.dart';
import 'package:abyadpos_tab/core/constants/image_constants.dart';
import 'package:abyadpos_tab/features/auth/presentation/controllers/user_cubit.dart';
import 'package:abyadpos_tab/features/auth/presentation/controllers/user_state.dart';
import 'package:abyadpos_tab/features/home/presentation/widgets/custom_appbar.dart';
import 'package:abyadpos_tab/features/settings/presentation/screens/loans_screen.dart';
import 'package:abyadpos_tab/features/settings/presentation/screens/statistics_screen.dart';
import 'package:abyadpos_tab/features/settings/presentation/screens/update_prices_screen.dart';
import 'package:abyadpos_tab/features/settings/presentation/widgets/build_label_filed.dart';
import 'package:abyadpos_tab/features/settings/presentation/widgets/build_payment_button.dart';
import 'package:abyadpos_tab/features/settings/presentation/widgets/profile_dialog.dart';
import 'package:abyadpos_tab/features/settings/presentation/widgets/setting_card.dart';
import 'package:abyadpos_tab/core/widgets/loader/loading_cubit.dart';
import 'package:abyadpos_tab/core/widgets/custom_button.dart';
import 'package:abyadpos_tab/core/widgets/custom_drawer.dart';
import 'package:abyadpos_tab/core/widgets/ui_helpers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_terminal_sdk/models/card_reader_callbacks.dart';
import 'package:flutter_terminal_sdk/models/data/purchase_response.dart';
import 'package:flutter_terminal_sdk/models/purchase_callbacks.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:place_picker_v2/uuid.dart';

import 'package:place_picker_v2/place_picker.dart';

import 'package:abyadpos_tab/core/config/api_client.dart';
import 'package:abyadpos_tab/core/config/api_endpoints.dart';

import 'package:abyadpos_tab/core/utils/location_helper.dart';
import 'package:abyadpos_tab/core/utils/nearpay_manager.dart';
import 'package:abyadpos_tab/core/utils/nfc_helper.dart';
import 'package:abyadpos_tab/core/utils/updater_service.dart';
import 'package:abyadpos_tab/features/dashboard/presentation/controllers/drawer_state.dart';
import 'package:abyadpos_tab/features/home/presentation/widgets/phone_lookup.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ApiClient apiClient = ApiClient();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _phoneController_wallet = TextEditingController();

  final _laundryController = TextEditingController();
  final _addressController = TextEditingController();
  final descriptionController = TextEditingController();
  final _walletFormKey = GlobalKey<FormState>();

  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final TextEditingController additionalController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> laundaryformKey = GlobalKey<FormState>();
  final GlobalKey<FormState> infoformKey = GlobalKey<FormState>();

  final TextEditingController openingAt = TextEditingController();
  final TextEditingController clossingAt = TextEditingController();
  TextEditingController searchController = TextEditingController();

  LatLng? _currentLocation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _version = "";
  DateTime birthDate = DateTime.now();

  final _phoneFormatter = MaskTextInputFormatter(
    mask: '05#########',
    filter: {'#': RegExp(r'\d')},
  );
  @override
  void initState() {
    super.initState();
    UserCubit userCubit = context.read<UserCubit>();
    if (userCubit.state.userModel != null) {
      _phoneController.text = userCubit.state.userModel!.data.phone.toString() != "null"
          ? userCubit.state.userModel!.data.phone.toString()
          : "";
      _laundryController.text = userCubit.state.userModel!.data.name;
      _emailController.text = userCubit.state.userModel!.data.email;

      descriptionController.text = userCubit.state.userModel!.data.description.toString() != "null"
          ? userCubit.state.userModel!.data.description.toString()
          : "";
      _addressController.text = userCubit.state.userModel!.data.location.toString() != "null"
          ? userCubit.state.userModel!.data.location!
          : "";

      additionalController.text =
          userCubit.state.userModel!.data.additionalInfo.toString() != "null"
              ? userCubit.state.userModel!.data.additionalInfo.toString()
              : "";

      openingAt.text = userCubit.state.userModel!.data.operatingHours.startAt.toString() != "null"
          ? userCubit.state.userModel!.data.operatingHours.startAt
          : "start_at".tr;
      clossingAt.text = userCubit.state.userModel!.data.operatingHours.endAt.toString() != "null"
          ? userCubit.state.userModel!.data.operatingHours.endAt
          : "close_at".tr;

      _addressController.text = userCubit.state.userModel!.data.location.toString() != "null"
          ? userCubit.state.userModel!.data.location.toString()
          : "";
      final latStr = userCubit.state.userModel?.data.lat;
      final lngStr = userCubit.state.userModel?.data.lng;
      _currentLocation = LatLng(
        double.tryParse(latStr ?? "32.5444") ?? 32.5444,
        double.tryParse(lngStr ?? "64.0000") ?? 64.0000,
      );

      setState(() {});
    }
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = formatVersion(packageInfo.version);
    final info = await PackageInfo.fromPlatform();
    String displayVersion = info.version.replaceAll('.', '').substring(1, 3);
    print("displayVersion : $displayVersion" + " appv: ${info.version} ");
    setState(() {
      _version = currentVersion;
    });
  }

  String formatVersion(String version) {
    final parts = version.split('.');
    if (parts.isEmpty) return version;
    final major = parts[0];
    final minor = parts.length > 1 ? parts[1] : '0';
    final patch = parts.length > 2 ? parts[2] : '0';
    final minorPatch = (minor + patch).padLeft(2, '0');
    return '$major.$minorPatch';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      body: BlocBuilder<UserCubit, UserState>(builder: (
        context,
        provider,
      ) {
        final items = buildSettingItems(context, provider);

        // 💡 1. استبدال المقاسات الثابتة بـ SafeArea و Row طبيعي
        return SafeArea(
          child: Row(
            children: [
              CustomSideMenu(),
              // 💡 2. المحتوى يأخذ المساحة المتبقية بمرونة
              Expanded(
                child: Column(
                  children: [
                    CustomAppBar(
                      title: "settings".tr,
                      onSearch: (data) {
                        if (data.isNotEmpty) {
                          final cubit = BlocProvider.of<OrderCubit>(context, listen: false);
                          cubit.setExternalSearch(data);
                          UIHelper().goToMenu(context, SideMenuItem.orders);
                        }
                      },
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0), // مسافة محترمة من الأطراف
                        // 💡 3. LayoutBuilder لضبط عدد الكروت في الصف حسب الشاشة
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            // حساب ديناميكي لعدد الأعمدة
                            int crossAxisCount = 2; // للهواتف
                            if (constraints.maxWidth > 600) crossAxisCount = 3; // تابلت صغير
                            if (constraints.maxWidth > 900) crossAxisCount = 4; // شاشات عادية
                            if (constraints.maxWidth > 1200) crossAxisCount = 5; // شاشات عريضة

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: GridView.builder(
                                    itemCount: items.length,
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: 25,
                                      mainAxisSpacing: 25, // قللت المسافة لتكون متناسقة
                                      childAspectRatio: 1.1, // شبه مربع ليتناسب مع كل الشاشات
                                    ),
                                    itemBuilder: (context, index) {
                                      return SettingCard(item: items[index]);
                                    },
                                  ),
                                ),
                                // رقم الإصدار في الأسفل بشكل نظيف
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 16.0, right: 16.0, left: 16.0),
                                  child: Text(
                                    "app_v".tr + " $_version",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blueGrey.withOpacity(0.6),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  void _showCustomerWalletDialog(BuildContext context) {
    final _phoneControllerWallet = TextEditingController();
    final _nameController = TextEditingController();
    final _amountController = TextEditingController();
    Map<String, dynamic>? selectedUser;
    double? walletBalance;

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

          return StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                // 💡 4. استخدام ConstrainedBox لتحديد عرض أقصى مرن للدايالوج
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "customer_wallet".tr,
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
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "customer_mobile:".tr,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          PhoneLookupField(
                            controller: _phoneControllerWallet,
                            onChanged: (data) async {
                              if (data.length == 9) {
                                try {
                                  final viewModel =
                                      BlocProvider.of<UserCubit>(context, listen: false);
                                  final users = await viewModel.lookupUsers(data, null);

                                  if (users != null && users.isNotEmpty) {
                                    final user = users.first;
                                    setState(() {
                                      walletBalance = (user['wallet_balance'] ?? 0).toDouble();
                                    });
                                  } else {
                                    setState(() {
                                      walletBalance = null;
                                    });
                                  }
                                } catch (e) {
                                  debugPrint("Error in lookupUser: $e");
                                  setState(() {
                                    walletBalance = null;
                                  });
                                }
                              } else {
                                setState(() {
                                  walletBalance = null;
                                });
                              }
                            },
                            onUserSelected: (controllerText, data) {
                              if (data != null) {
                                setState(() {
                                  selectedUser = data;
                                  _phoneControllerWallet.text =
                                      data['phone']?.toString().replaceAll('+966', '') ?? "";
                                  _nameController.text = data['name'] ?? "";
                                  walletBalance = (data['wallet_balance'] ?? 0).toDouble();
                                });
                              } else {
                                setState(() {
                                  selectedUser = null;
                                  walletBalance = null;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          if (walletBalance != null) ...[
                            Text(
                              "wallet_balance:".tr + " $walletBalance",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: walletBalance! < 0 ? Colors.redAccent : Colors.green,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Form(
                              key: _walletFormKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "add_balance:".tr,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _amountController,
                                    keyboardType: const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      hintText: "enter_amount".tr,
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+\.?\d{0,2}'),
                                      ),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return "amount_is_required".tr;
                                      }
                                      if (double.tryParse(value) == null) {
                                        return "amount_is_required".tr;
                                      }
                                      if (double.tryParse(value)! <= 1.0) {
                                        return "The amount field must be at least 1.".tr;
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
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

                                            if (_walletFormKey.currentState!.validate()) {
                                              var phone =
                                                  _phoneControllerWallet.text.trim().toString();
                                              final text = _amountController.text.trim();
                                              final double? amount = double.tryParse(text);

                                              if (amount == null) {
                                                UIHelper.showBottomFlash(
                                                  context,
                                                  title: "invalid_amount".tr,
                                                  message: "invalid_amount_msg".tr,
                                                  isError: true,
                                                );
                                                return;
                                              }

                                              if (!isNearpayEnabled) {
                                                await topUpWallet(
                                                    customerPhone: phone,
                                                    amount: amount,
                                                    paymentMethod: "credit_card",
                                                    context: context);
                                                Navigator.of(context).pop();
                                              } else if (isNearpayEnabled) {
                                                // --- NEARPAY FLOW ---
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
                                                          context
                                                              .read<LoadingCubit>()
                                                              .hideLoading();
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

                                                if (manager.connectedTerminal?.terminalUUID ==
                                                    null) {
                                                  context.read<LoadingCubit>().hideLoading();
                                                  showError("state_error", "invalid_session");
                                                  return;
                                                }

                                                try {
                                                  final version =
                                                      await UIHelper.getCleanVersionExact();
                                                  final transactionUuid = Uuid().generateV4();
                                                  final customerReferenceNumber =
                                                      "TopUp:" + phone + "-" + version;
                                                  double totalPrice = double.tryParse(text) ?? 0;
                                                  int nearpayAmount = (totalPrice * 100).round();
                                                  final amount = nearpayAmount;

                                                  await NearPayManager()
                                                      .connectedTerminal!
                                                      .purchase(
                                                        amount: amount,
                                                        scheme: null,
                                                        customerReferenceNumber:
                                                            customerReferenceNumber,
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
                                                              context
                                                                  .read<LoadingCubit>()
                                                                  .hideLoading();
                                                              showError("network_failure",
                                                                  "${"transaction_failed".tr} $message");
                                                            }
                                                          },
                                                          onTransactionPurchaseCompleted:
                                                              (PurchaseResponse
                                                                  purchaseResponse) async {
                                                            if (context.mounted)
                                                              context
                                                                  .read<LoadingCubit>()
                                                                  .hideLoading();

                                                            if (purchaseResponse
                                                                .getLastReceipt()!
                                                                .getMadaReceipt()
                                                                .isApproved) {
                                                              await topUpWallet(
                                                                  customerPhone: phone,
                                                                  amount: totalPrice,
                                                                  paymentMethod: "nearpay",
                                                                  context: context);
                                                              if (dialogCtx.mounted)
                                                                Navigator.of(dialogCtx).pop();
                                                            }
                                                          },
                                                        ),
                                                      );
                                                } catch (e) {
                                                  if (context.mounted) {
                                                    context.read<LoadingCubit>().hideLoading();
                                                  }
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text("Error: $e"),
                                                      backgroundColor: Colors.redAccent,
                                                      duration: const Duration(seconds: 5),
                                                    ),
                                                  );
                                                }
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: buildPaymentButton(
                                          icon: ImageConstants.cashSvg,
                                          label: 'Cash'.tr,
                                          selected: true,
                                          onTap: () async {
                                            if (_walletFormKey.currentState!.validate()) {
                                              var phone =
                                                  _phoneControllerWallet.text.trim().toString();
                                              final text = _amountController.text.trim();
                                              final double? amount = double.tryParse(text);

                                              if (amount == null) {
                                                UIHelper.showBottomFlash(
                                                  context,
                                                  title: "invalid_amount".tr,
                                                  message: "invalid_amount_msg".tr,
                                                  isError: true,
                                                );
                                                return;
                                              }

                                              await topUpWallet(
                                                  customerPhone: phone,
                                                  amount: amount,
                                                  paymentMethod: "cash",
                                                  context: context);
                                              Navigator.of(context).pop();
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
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

  Future<void> topUpWallet({
    required String customerPhone,
    required double amount,
    required String paymentMethod,
    BuildContext? context,
  }) async {
    if (context != null) {
      context.read<LoadingCubit>().showLoading();
    }

    try {
      final response = await apiClient.request(
        url: ApiEndPoints.walletTopUp,
        method: 'POST',
        body: {
          "customer_phone": "+966" + customerPhone,
          "topup_type": "custom",
          "amount": amount,
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
      print("Error topping up wallet: $e");
      if (context != null) {
        UIHelper.showBottomFlash(
          context,
          title: "An error occurred during wallet top-up.",
          message: e.toString(),
          isError: true,
        );
      }
    }
  }

  List<SettingItemData> buildSettingItems(BuildContext context, UserState state) {
    bool statsLock = state.userModel?.data.stats_locked ?? false;
    String? statsPassword = state.userModel?.data.stats_password.toString();

    bool statsEnabled = state.userModel?.data.stats_enabled ?? false;
    bool walletEnabled = state.userModel?.data.enable_top_up_wallet ?? false;
    bool loanEnabled = state.userModel?.data.loan_active ?? false;
    return [
      SettingItemData(
        icon: Icons.person,
        title: "edit_profile".tr,
        onTap: () {
          if (state.userModel != null) {
            String rawPhone = (state.userModel?.data.phone ?? "").toString();
            if (rawPhone.startsWith('0')) {
              rawPhone = rawPhone.substring(1);
            }
            _phoneController.text = rawPhone;
          }

          showDialog(
            context: context,
            builder: (_) => ProfileDialog(
              infoFormKey: infoformKey,
              emailController: _emailController,
              phoneController: _phoneController,
              version: _version,
              buildLabeledField: buildLabeledField,
              inputDecoration: _inputDecoration,
              onSave: () async {
                if (infoformKey.currentState!.validate()) {
                  var payload = {
                    "phone": "0${_phoneController.text}",
                  };

                  context.read<LoadingCubit>().showLoading();
                  await context.read<UserCubit>().updateProfile(
                        body: payload,
                        context: context,
                      );
                  context.read<LoadingCubit>().hideLoading();
                  Navigator.pop(context);
                }
              },
            ),
          );
        },
      ),
      SettingItemData(
        icon: Icons.attach_money,
        title: "update_prices".tr,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UpdatePricesScreen()),
        ),
      ),
      if (statsEnabled)
        SettingItemData(
          icon: Icons.query_stats,
          title: "statistics".tr,
          onTap: () {
            if (statsLock) {
              UIHelper().protectedAction(
                context: context,
                backendPassword: statsPassword,
                onAuthorized: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => StatisticsScreen()),
                ),
              );
            } else {
              Navigator.push(context, MaterialPageRoute(builder: (_) => StatisticsScreen()));
            }
          },
        ),
      if (walletEnabled)
        SettingItemData(
            icon: Icons.wallet,
            title: "customer_wallet".tr,
            onTap: () {
              _showCustomerWalletDialog(context);
            }),
      SettingItemData(
        icon: Icons.attach_money,
        title: "customers_page".tr,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LoansScreen()),
          );
        },
      ),
      SettingItemData(
        icon: Icons.reset_tv_outlined,
        title: "reset_data".tr,
        onTap: () {
          UIHelper.showDialogOk(
            context,
            title: "reset_data".tr,
            message: "are_you_sure_reset_data".tr,
            onConfirm: () async {
              if (!mounted) return;
              UIHelper().showLoading(context);
              await context.read<UserCubit>().requestUserData(context);
              if (mounted && Get.currentRoute == '/SettingsScreen') {
                UIHelper().hideLoading(context);
              }
            },
          );
        },
      ),
      SettingItemData(
        icon: Icons.system_update,
        title: "app_update".tr,
        onTap: () async {
          final updater = UpdaterService();
          final packageInfo = await PackageInfo.fromPlatform();
          final appVersionData = state.userModel?.appVersion;

          if (appVersionData == null || appVersionData.url == null) {
            UIHelper.showBottomFlash(context,
                title: "up_to_date".tr,
                message: "the_current_version_is_up_to_date".tr,
                isError: false);
            return;
          }

          if (updater.isUpdating) {
            UIHelper.showBottomFlash(context,
                title: "ongoing_update".tr, message: "update_in_progress_msg".tr, isError: false);
            UIHelper.showFloatingDownloadWidget(updater, appVersionData.url!,
                version: appVersionData.latest.toString());
            return;
          }

          final String latestVersion = appVersionData.latest.toString();
          final String currentVersion =
              context.read<UserCubit>().formatVersion(packageInfo.version);
          final String url = appVersionData.url!;

          int latestNum = UIHelper().versionToNumber(latestVersion);
          int currentNum = UIHelper().versionToNumber(currentVersion);

          if (latestNum > currentNum) {
            await updater.cleanOldVersions(currentVersion, targetVersion: latestVersion);
            String? savedApkPath = await updater.getReadyApkPath(latestVersion);

            if (appVersionData.force == true) {
              if (savedApkPath != null) {
                updater.installUpdate(savedApkPath);
              } else {
                updater.downloadAndInstall(url, latestVersion);
              }
              UIHelper.showFloatingDownloadWidget(updater, url, version: latestVersion);
            } else {
              UIHelper().showUpdateDialog(
                context,
                url,
                message: "soft_update_msg".tr,
                force: false,
                version: latestVersion,
              );
            }
          } else {
            await updater.cleanOldVersions(currentVersion);
            UIHelper.showBottomFlash(context,
                title: "up_to_date".tr,
                message: "the_current_version_is_up_to_date".tr,
                isError: false);
          }
        },
      ),
    ];
  }
}

Widget _buildSaveButton({onSave}) {
  return Container(
    // 💡 5. استخدام أقصى عرض متاح بدل العرض الثابت
    width: double.infinity,
    constraints: const BoxConstraints(maxWidth: 300),
    margin: EdgeInsets.symmetric(vertical: 10.h),
    child: CustomButton(
      onSave,
      text: "Save".tr,
    ),
  );
}

InputDecoration _inputDecoration(String hint, {String? prefixText}) {
  return InputDecoration(
    hintText: hint,
    prefixText: prefixText,
    hintStyle: TextStyle(color: Colors.grey[500]),
    filled: true,
    fillColor: Colors.grey[50],
    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
  );
}
