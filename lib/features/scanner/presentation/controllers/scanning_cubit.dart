import 'package:abyadpos_tab/core/config/api_client.dart';
import 'package:abyadpos_tab/core/config/api_endpoints.dart';
import 'package:abyadpos_tab/features/orders/presentation/controllers/order_cubit.dart';
import 'package:abyadpos_tab/features/orders/data/models/order_model.dart';
import 'package:abyadpos_tab/core/theme/app_colors.dart';
import 'package:abyadpos_tab/core/theme/font_constants.dart';
import 'package:abyadpos_tab/core/widgets/loader/loading_cubit.dart';
import 'package:abyadpos_tab/features/scanner/presentation/controllers/scanning_state.dart';
import 'package:abyadpos_tab/core/utils/order_scan_date.dart';
import 'package:abyadpos_tab/core/utils/payment_dialog.dart';
import 'package:abyadpos_tab/core/widgets/common_text.dart';
import 'package:abyadpos_tab/core/widgets/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_terminal_sdk/flutter_terminal_sdk.dart';
import 'package:flutter_terminal_sdk/models/terminal_response.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanningCubit extends Cubit<ScanningState> {
  final ApiClient apiClient = ApiClient();
  final FlutterTerminalSdk _terminalSdk = FlutterTerminalSdk();
  final orderManager = OrderManager();

  ScanningCubit() : super(ScanningState());

  void setConnectedTerminal(TerminalModel? connectedTerminal) {
    emit(state.copyWith(connectedTerminal: connectedTerminal));
  }

  // شلنا الـ BuildContext من الباراميترز لأنه مش مستخدم جوه الدالة
  Future<void> getTerminal() async {
    final pref = await SharedPreferences.getInstance();
    final terminalUUID = pref.getString("terminalUUID");

    try {
      final fetchedTerminal = await _terminalSdk.getTerminal(
        terminalUUID: terminalUUID.toString(),
      );
      emit(state.copyWith(connectedTerminal: fetchedTerminal));
    } catch (e) {
      print("Error connecting terminal: $e");
    }
  }

  Future<void> processScannedOrder(String rawOrderId, BuildContext context) async {
    final String orderIdScanned = rawOrderId.trim();
    if (orderIdScanned.isEmpty) return;

    if (state.isProcessing) return;

    bool timerEnded = orderManager.addOrder(context, orderIdScanned);
    print(timerEnded);
    if (!timerEnded) {
      return;
    }

    emit(state.copyWith(isProcessing: true));
    context.read<LoadingCubit>().showLoading();

    await _callUpdateStatus(orderIdScanned, context);

    if (!isClosed) emit(state.copyWith(isProcessing: false));
    context.read<LoadingCubit>().hideLoading();
  }

  Future<void> setLastRequestTime(DateTime time) async {
    emit(state.copyWith(lastRequestTime: time));
  }

  Future<void> _callUpdateStatus(String orderId, BuildContext context) async {
    try {
      final response = await apiClient.requestMultiRequest(
        url: ApiEndPoints.updateOrderStatus,
        method: 'POST',
        body: {"order_id": orderId},
      );
      print(response.toString() + "########");
      final bool isPaymentStep = (response['message'].toString()).contains("Payment is pending");
      print("fjdisjoaijgoai");
      print(response['message']);
      print(isPaymentStep);

      if (response['status'] == true) {
        emit(state.copyWith(lastRequestTime: DateTime.now()));

        triggerOrderRefresh(context, isCurrent: true);
        if (!isPaymentStep) {
          UIHelper.showBottomFlash(
            context,
            title: "order_update_msg".tr,
            message: "order_update_msg".tr,
            isError: false,
          );
        } else {}
      } else if (response['status'] == false && isPaymentStep) {
        final Order? orderDetails = await context.read<OrderCubit>().getOrdersById(orderId);
        context.read<OrderCubit>().getHistoryOrders(context);

        if (orderDetails != null) {
          context.read<LoadingCubit>().hideLoading();
          await showPaymentDialog(orderDetails, context);
        } else {
          context.read<LoadingCubit>().hideLoading();
          UIHelper.showBottomFlash(
            context,
            title: "order_detail_error_msg".tr,
            message: "order_status_not_updated".tr,
            isError: true,
          );
        }
      } else {
        print(response.toString() + ">>>>");
        UIHelper.showBottomFlash(
          context,
          title: "failure".tr,
          message: "order_status_not_updated".tr,
          isError: true,
        );
      }
    } catch (e) {
      print("Error updating order status: $e");
      context.read<LoadingCubit>().hideLoading();
      String error = "$e".replaceFirst("Exception: ", "");
      UIHelper.showBottomFlash(
        context,
        title: error,
        message: "An error occurred while updating order status.$e",
        isError: true,
      );
    }
  }

  // ==========================================
  // دوال الـ UI (يفضل نقلها لشاشات العرض لاحقاً)
  // ==========================================

  Widget buildPaymentButton({
    required String icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
    dynamic z,
  }) {
    // استخدمنا AppColors بدلاً من المتغير المحلي لو كان primaryColor غير مستخدم
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(8.0), gradient: myCustomGrident()),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(icon, color: Colors.white),
            UIHelper.horizontalSpaceSm5,
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
    return const LinearGradient(
      begin: Alignment(0.9775090217590332, 0.022490976378321648),
      end: Alignment(-0.022490976378321648, 0.022490976378321648),
      colors: [AppColors.primaryColor, AppColors.primaryColor],
    );
  }
}
