import 'dart:async';
import 'package:abyadpos_tab/core/widgets/loader/loading_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:abyadpos_tab/core/config/api_client.dart';
import 'package:abyadpos_tab/core/config/api_endpoints.dart';
import 'package:abyadpos_tab/features/orders/data/repositories/order_repo.dart';
import 'package:abyadpos_tab/features/settings/data/models/Items_bill_model.dart';
import 'package:abyadpos_tab/features/settings/data/models/collection_bill_model.dart';
import 'package:abyadpos_tab/features/home/data/models/clothes_model.dart';
import 'package:abyadpos_tab/features/orders/data/models/order_model.dart';
import 'package:abyadpos_tab/features/orders/data/models/order_status_model.dart';
import 'package:abyadpos_tab/features/settings/data/models/pos_stats_response.dart';
import 'package:abyadpos_tab/features/auth/data/models/user_model.dart';
import 'package:abyadpos_tab/features/settings/data/models/loan_model.dart';
import 'package:abyadpos_tab/core/widgets/ui_helpers.dart';
import 'package:abyadpos_tab/core/utils/payment_dialog.dart';

import 'package:abyadpos_tab/features/auth/presentation/controllers/user_cubit.dart';
import 'package:abyadpos_tab/core/storage/sharedpref.dart';
import 'package:abyadpos_tab/features/orders/domain/services/printer_service.dart';
import 'package:abyadpos_tab/features/orders/presentation/controllers/order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderRepository _repository = OrderRepository(apiClient: ApiClient());
  final PrinterService _printerService = PrinterService();
  Timer? _balancingCountdownTimer;

  final String kBalancingPrefsKey = "balancing_timestamps";
  final String kBalancingTimestampKey = "last_balancing_timestamp";

  OrderCubit() : super(OrderState()) {
    _initialize();
  }

  @override
  Future<void> close() {
    _balancingCountdownTimer?.cancel();
    return super.close();
  }

  Future<void> _initialize() async {
    SharedPref pref = SharedPref();
    var doc = await pref.readObject('user');
    if (doc != null) {
      if (!isClosed) emit(state.copyWith(userModel: UserModel.fromJson(doc)));
    }
    await loadCooldownIfExists();
  }

  void setPrepaid(bool value) => emit(state.copyWith(isPrepaid: value));

  void toggleIsDiscount(bool value) {
    emit(state.copyWith(
      isDiscount: value,
      discountValue: value ? state.discountValue : 0.0,
    ));
  }

  void setCloseAndComplete(bool value) => emit(state.copyWith(closeAndComplete: value));

  void clearOrderData() => emit(state.copyWith(isPrepaid: false));

  void setWalletBalance(double? value) =>
      emit(state.copyWithBullWalletBalance(walletBalance: value));

  Future<void> getLoans({int pageNumber = 1, String? search, bool only_with_loan = false}) async {
    emit(state.copyWith(isPaginating: true));

    if (state.allLoansModel == null || pageNumber == 1) {
      emit(state.copyWith(isLoading: true));
    }

    try {
      final response = await _repository.fetchLoans(
        pageNumber: pageNumber,
        onlyWithLoan: only_with_loan,
        search: search,
      );

      if (response['status'] == true) {
        LoanModel model = LoanModel.fromJson(response);

        if (pageNumber == 1) {
          emit(state.copyWith(allLoansModel: model));
        } else {
          final updatedCustomers = List<Customer>.from(state.allLoansModel!.data.customers)
            ..addAll(model.data.customers);

          final updatedModel = LoanModel(
            message: state.allLoansModel!.message,
            data: LoanData(
              customers: updatedCustomers,
              pagination: model.data.pagination,
            ),
          );

          emit(state.copyWith(allLoansModel: updatedModel));
        }
      }
    } catch (e) {
      debugPrint("Error fetching loans: $e");
    } finally {
      if (!isClosed) emit(state.copyWith(isLoading: false, isPaginating: false));
    }
  }

  Future<void> updateClothes(List<Cloth> clothes, BuildContext context) async {
    try {
      final response = await _repository.updateClothes(clothes);

      if (response['status'] == true && response['data']?['success'] == true) {
        UIHelper.showBottomFlash(context,
            title: response['message'], message: response['message'], isError: false);

        final updatedClothes = response['data']?['updated_clothes'] as List<dynamic>?;

        if (updatedClothes != null && updatedClothes.any((c) => c['is_active'] == 1)) {
          context.read<UserCubit>().setProductsNeedSetup(false);
          debugPrint("✅ Clothes updated and setup complete.");
        } else {
          debugPrint("⚠️ Update succeeded but no active items, setup remains true.");
        }
      } else {
        UIHelper.showBottomFlash(context,
            title: response['message'], message: response['message'], isError: true);
      }
    } catch (e) {
      UIHelper.showBottomFlash(context,
          title: "Request Error", message: "Request Error", isError: true);
      debugPrint("Error updating clothes: $e");
    }
  }

  Future<void> getAllClothes(BuildContext context) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await _repository.fetchClothes();
      if (response['status'] == true) {
        emit(state.copyWith(allClothsModel: ClothsModel.fromJson(response)));
      } else {
        debugPrint('cloth Failed: ${response['message']}');
      }
    } catch (error) {
      debugPrint('Error during clothing: $error');
    } finally {
      if (!isClosed) emit(state.copyWith(isLoading: false));
    }
  }

// --- UI State Setters ---
  void setPageNumber(int val) {
    if (state.pageNumber != val) {
      emit(state.copyWith(pageNumber: val));
    }
  }

  void setPageNumberHistory(int val) {
    if (state.pageNumberHistory != val) {
      emit(state.copyWith(pageNumberHistory: val));
    }
  }

  void setTabOnlyWashing(bool value) {
    if (state.tabOnlyWashing != value) {
      emit(state.copyWith(tabOnlyWashing: value));
    }
  }

  void setTabOnlyIroning(bool value) {
    if (state.tabOnlyIroning != value) {
      emit(state.copyWith(tabOnlyIroning: value));
    }
  }

  Future<void> getAllClothesActiveAndInactive(BuildContext context) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await _repository.fetchAllClothesActiveAndInactive();
      if (response['status'] == true) {
        emit(state.copyWith(allClothsModelUpdatePrices: ClothsModel.fromJson(response)));
      }
    } catch (error) {
      debugPrint('Error during clothing: $error');
    } finally {
      if (!isClosed) emit(state.copyWith(isLoading: false));
    }
  }

  void setExternalSearch(String query) {
    emit(state.copyWith(externalSearchQuery: query));
    getOrdersBySearch(query);
  }

  void clearExternalSearch() {
    emit(state.copyWith(externalSearchQuery: null));
  }

  void clearSearch({required bool isCurrentView}) {
    emit(state.copyWith(
      clearFilterAdsModel: true,
      lastSearchQuery: "",
      pageNumber: isCurrentView ? 1 : state.pageNumber,
      pageNumberHistory: isCurrentView ? state.pageNumberHistory : 1,
    ));
  }

  Future<void> getOrdersBySearch(
    String query, {
    String? nextPageUrl,
    bool isNewSearch = true,
    int? targetPage,
    bool isComplete = false,
  }) async {
    String? templateUri = state.filterAdsModel?.data.pagination.nextPageUrl ??
        state.filterAdsModel?.data.pagination.prevPageUrl;
    bool isJumping = targetPage != null;

    int newPageNumber = state.pageNumber;
    int newPageHistory = state.pageNumberHistory;

    if (isNewSearch || isJumping) {
      if (isComplete) {
        newPageHistory = isNewSearch ? 1 : targetPage!;
      } else {
        newPageNumber = isNewSearch ? 1 : targetPage!;
      }
      emit(state.copyWith(
        isLoading: true,
        clearFilterAdsModel: true,
        pageNumber: newPageNumber,
        pageNumberHistory: newPageHistory,
      ));
    } else {
      emit(state.copyWith(isPaginating: true));
    }

    String urlString;
    if (isJumping) {
      if (templateUri != null) {
        final uri = Uri.parse(templateUri);
        urlString = uri.replace(queryParameters: {
          ...uri.queryParameters,
          'page': (isComplete ? newPageHistory : newPageNumber).toString(),
        }).toString();
      } else {
        urlString =
            "${ApiEndPoints.BASE_URL}search-orders?search_text=$query&is_complete=$isComplete&page=${isComplete ? newPageHistory : newPageNumber}&page_size=${state.pageSize}";
      }
    } else if (nextPageUrl != null) {
      urlString = nextPageUrl;
    } else {
      urlString =
          "${ApiEndPoints.BASE_URL}search-orders?search_text=$query&is_complete=$isComplete&page=1&page_size=${state.pageSize}";
    }

    try {
      final response = await _repository.searchOrders(urlString: urlString);
      if (response['status'] == true) {
        emit(state.copyWith(filterAdsModel: OrderModel.fromJson(response)));
      }
    } catch (error) {
      debugPrint('Search Error: $error');
    } finally {
      if (!isClosed) emit(state.copyWith(isLoading: false, isPaginating: false));
    }
  }

  void setExpress(bool value) {
    if (state.isExpress != value) emit(state.copyWith(isExpress: value));
  }

  void tabOnlyIroning(bool value) {
    if (state.tabOnlyIroning != value) emit(state.copyWith(tabOnlyIroning: value));
  }

  void tabOnlyWashing(bool value) {
    if (state.tabOnlyWashing != value) emit(state.copyWith(tabOnlyWashing: value));
  }

  void deleteFromCart(int index) {
    if (index >= 0 && index < state.selectedItems.length) {
      final newSelectedItems = List<Map<String, dynamic>>.from(state.selectedItems);
      newSelectedItems.removeAt(index);
      emit(state.copyWith(selectedItems: newSelectedItems));
    }
  }

  void resetPaymentFields() {
    emit(state.copyWith(
      closeAndComplete: false,
      isDiscount: false,
      discountValue: 0.0,
    ));
  }

  void setFilter(bool isDebtors) {
    if (state.showDebtorsOnly != isDebtors) {
      emit(state.copyWith(showDebtorsOnly: isDebtors));
      getLoans(pageNumber: 1, only_with_loan: isDebtors, search: null);
    }
  }

  void toggleDiscount(int customerId, bool value) {
    final index = state.loanCustomers.indexWhere((c) => c['id'] == customerId);
    if (index != -1) {
      final newCustomers = List<Map<String, dynamic>>.from(state.loanCustomers);
      newCustomers[index]['discountEnabled'] = value;
      emit(state.copyWith(loanCustomers: newCustomers));
    }
  }

  void updateSelection({
    required Cloth cloth,
    required bool onlyIroning,
    required bool onlyCleaning,
    required int count,
    bool isCustomized = false,
    String? details,
    double? custom_price_per_unit,
    double? totalItemsPrice,
    String? serviceType,
  }) {
    final newSelectedItems = List<Map<String, dynamic>>.from(state.selectedItems);
    final index = newSelectedItems.indexWhere((item) =>
        item['cloth_id'] == cloth.id.toString() &&
        item['only_ironing'] == onlyIroning &&
        item['only_cleaning'] == onlyCleaning);

    if (count > 0) {
      final entry = {
        'cloth_id': cloth.id.toString(),
        'cloth': cloth.toJson(),
        'clothes_count': count,
        'only_ironing': onlyIroning,
        'only_cleaning': onlyCleaning,
        'isCustomized': isCustomized,
        'details': details,
        'custom_price_per_unit': custom_price_per_unit,
        'total_custom_price': totalItemsPrice,
        'service_type': isCustomized == true ? serviceType : "",
      };

      if (index == -1) {
        newSelectedItems.add(entry);
      } else {
        newSelectedItems[index] = entry;
      }
    } else {
      if (index != -1) newSelectedItems.removeAt(index);
    }
    emit(state.copyWith(selectedItems: newSelectedItems));
  }

  void clearSelectedItems() {
    emit(state.copyWith(isPrepaid: false, selectedItems: []));
  }

  Future<void> getOrders(BuildContext context, {int? targetPage}) async {
    bool isJumping = targetPage != null;

    if (isJumping) {
      emit(state.copyWith(pageNumber: targetPage, isLoading: true, allAdsModel: null));
    } else {
      if (state.isLoading || state.isPaginating) return;
      if (state.allAdsModel != null && state.allAdsModel!.data.pagination.nextPageUrl == null)
        return;
      emit(state.copyWith(isPaginating: true));
    }

    try {
      final response = await _repository.fetchOrders(
          pageSize: state.pageSize, pageNumber: state.pageNumber, status: 'current');

      if (response['status'] == true) {
        OrderModel newModel = OrderModel.fromJson(response);
        if (state.allAdsModel == null || isJumping) {
          emit(state.copyWith(allAdsModel: newModel));
        } else {
          final updatedOrders = List<Order>.from(state.allAdsModel!.data.orders)
            ..addAll(newModel.data.orders);
          final updatedModel = OrderModel(
            status: state.allAdsModel!.status,
            message: state.allAdsModel!.message,
            data: OrderData(orders: updatedOrders, pagination: newModel.data.pagination),
          );
          emit(state.copyWith(allAdsModel: updatedModel));
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      if (!isClosed) emit(state.copyWith(isLoading: false, isPaginating: false));
    }
  }

  Future<void> getHistoryOrders(BuildContext context, {int? targetPage}) async {
    if (state.isLoading) return;

    int newPageNumberHistory = state.pageNumberHistory;
    OrderModel? currentHistory = state.allHistoryModel;

    if (targetPage != null) {
      newPageNumberHistory = targetPage;
      currentHistory = null;
    }

    emit(state.copyWith(
        isLoading: true, pageNumberHistory: newPageNumberHistory, allHistoryModel: currentHistory));

    try {
      final response = await _repository.fetchOrders(
          pageSize: state.pageSize, pageNumber: state.pageNumberHistory, status: 'history');

      if (response['status'] == true) {
        OrderModel newModel = OrderModel.fromJson(response);
        if (state.allHistoryModel == null) {
          emit(state.copyWith(allHistoryModel: newModel));
        } else {
          final updatedOrders = List<Order>.from(state.allHistoryModel!.data.orders)
            ..addAll(newModel.data.orders);
          final updatedModel = OrderModel(
            status: state.allHistoryModel!.status,
            message: state.allHistoryModel!.message,
            data: OrderData(orders: updatedOrders, pagination: newModel.data.pagination),
          );
          emit(state.copyWith(allHistoryModel: updatedModel));
        }
      }
    } catch (e) {
      debugPrint('History Error: $e');
    } finally {
      if (!isClosed) emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> createOrder(
      BuildContext context, dynamic body, bool isFastOrder, bool prepaid) async {
    try {
      final response = await _repository.createOrder(body);
      if (response['status'] == true) {
        Order? order = await getOrdersById(response['data']['id'].toString());
        if (order != null) {
          if (state.allAdsModel != null) {
            final updatedOrders = List<Order>.from(state.allAdsModel!.data.orders)
              ..insert(0, order);
            final updatedModel = OrderModel(
              status: state.allAdsModel!.status,
              message: state.allAdsModel!.message,
              data:
                  OrderData(orders: updatedOrders, pagination: state.allAdsModel!.data.pagination),
            );
            emit(state.copyWith(allAdsModel: updatedModel));
          }

          clearSelectedItems();

          if (prepaid) {
            context.read<LoadingCubit>().hideLoading();
            await showPaymentDialog(order, context, prepaid_val: prepaid);
          } else {
            await _printerService.smartPrintBill(
                context, order, true, state.userModel, state.allClothsModel);

            if (state.userModel?.data.second_bill_enabled == true) {
              UIHelper.showPrintAnotherBillDialog(context, onYes: () {
                Future.delayed(const Duration(seconds: 1)).then((value) {
                  _printerService.smartPrintBill(
                      context, order, true, state.userModel, state.allClothsModel);
                });
              });
            }
            if (isFastOrder) {
              context.read<LoadingCubit>().hideLoading();
              await showPaymentDialog(order, context, is_fast_order: true);
            }
          }
        } else {
          getOrders(context);
        }
        UIHelper.showBottomFlash(context,
            title: response['message'], message: response['message'], isError: false);
      } else {
        UIHelper.showBottomFlash(context,
            title: response['message'], message: response['message'], isError: true);
      }
    } catch (error) {
      context.read<LoadingCubit>().hideLoading();
      print('Error during creating order: $error');
    }
  }

// دالة مخصصة لتحديث أو تعيين موديل المستخدم بالكامل
  void setUserModel(UserModel? newUserModel) {
    if (!isClosed) emit(state.copyWith(userModel: newUserModel));
  }

  Future<Order?> getOrdersById(String id) async {
    emit(state.copyWith(isOrderDetailsLoading: true));
    try {
      final response = await _repository.fetchOrderById(id);
      if (response['status'] == true) {
        Order order = Order.fromJson(response['data']['order']);
        emit(state.copyWith(orderDetailsModel: order, isOrderDetailsLoading: false));
        return order;
      }
    } catch (error) {
      print('Error during get order by id: $error');
    }
    if (!isClosed) emit(state.copyWith(isOrderDetailsLoading: false));
    return null;
  }

  Future<void> callUpdateStatus(String orderId, bool is_complete, BuildContext context,
      {required dynamic body}) async {
    try {
      final response = await _repository.updateOrderStatus(body);
      final bool isPaymentStep = (response['message'].toString()).contains("Payment is pending");

      if (response['status'] == true) {
        int index =
            state.allAdsModel?.data.orders.indexWhere((e) => e.id.toString() == orderId) ?? -1;

        if (index != -1 && state.allAdsModel != null) {
          Status status = Status.fromJson(response['data']['updated_status']);
          final updatedOrders = List<Order>.from(state.allAdsModel!.data.orders);

          if (status.key == "picked-up" || status.key == "cancelled") {
            updatedOrders.removeAt(index);
            getHistoryOrders(context);
          } else {
            updatedOrders[index].status = status;
          }

          final updatedModel = OrderModel(
            status: state.allAdsModel!.status,
            message: state.allAdsModel!.message,
            data: OrderData(orders: updatedOrders, pagination: state.allAdsModel!.data.pagination),
          );
          emit(state.copyWith(allAdsModel: updatedModel));
        }

        getOrders(context);

        if (!isPaymentStep) {
          UIHelper.showBottomFlash(
            context,
            title: "order_update_msg".tr,
            message: "order_update_msg".tr,
            isError: false,
          );
        }
      } else if (response['status'] == false && isPaymentStep) {
        final Order? orderDetails = await getOrdersById(orderId);
        getHistoryOrders(context);

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
        UIHelper.showBottomFlash(
          context,
          title: "failure".tr,
          message: "order_status_not_updated".tr,
          isError: true,
        );
      }
    } catch (e) {
      context.read<LoadingCubit>().hideLoading();
      String error = "$e".replaceFirst("Exception: ", "");
      UIHelper.showBottomFlash(
        context,
        title: error,
        message: "An error occurred while updating order status.",
        isError: true,
      );
    }
  }

  Future<OrderStatusModel?> fetchOrderStatus({required dynamic orderId}) async {
    try {
      final response = await _repository.fetchOrderStatus(orderId.toString());
      if (response['status'] == true) {
        return OrderStatusModel.fromJson(response);
      } else {
        debugPrint('Fetch Status Failed: ${response['message']}');
        return null;
      }
    } catch (error) {
      debugPrint('Error fetching order status: $error');
      return null;
    }
  }

  Future<void> triggerBalancing(BuildContext context) async {
    final settlementSnapshot = state.posStatsModel?.settlement;
    final double totalPendingValue = settlementSnapshot?.unrequestedAmount ?? 0.0;

    if (state.isBalancingDisabled) return;

    if (totalPendingValue <= 0) {
      UIHelper.showBottomFlash(context,
          title: "no_pending_settlement_title".tr,
          message: "no_pending_settlement_msg".tr,
          isError: false);
      return;
    }

    final loadingCubit = BlocProvider.of<LoadingCubit>(context, listen: false);
    loadingCubit.showLoading();

    try {
      final response = await _repository.requestBalancing();
      loadingCubit.hideLoading();

      if (response['status'] == true) {
        UIHelper.showBottomFlash(context,
            title: "settlement_requested_24h".tr,
            message: "settlement_requested_24h".tr,
            isError: false);

        await _printerService.smartSettlementPrint(
            context, settlementSnapshot, state.userModel, true);
        await getPosStats();

        final now = DateTime.now();
        emit(state.copyWith(lastBalancingTime: now));
        _startCooldownTimer();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(kBalancingTimestampKey, now.millisecondsSinceEpoch);
      } else {
        UIHelper.showBottomFlash(context,
            title: response['message'], message: response['message'], isError: true);
      }
    } catch (e) {
      loadingCubit.hideLoading();
      debugPrint("Balancing Error: $e");
    }
  }

  void _startCooldownTimer() {
    _balancingCountdownTimer?.cancel();
    _balancingCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      if (state.lastBalancingTime != null && now.day != state.lastBalancingTime!.day) {
        emit(state.copyWith(isBalancingDisabled: false, remainingTimeText: ""));
        timer.cancel();
      } else {
        emit(state.copyWith(
            isBalancingDisabled: true, remainingTimeText: _calculateRemainingTime()));
      }
    });
  }

  String _calculateRemainingTime() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final duration = tomorrow.difference(now);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  Future<void> loadCooldownIfExists() async {
    final prefs = await SharedPreferences.getInstance();
    final int? timestamp = prefs.getInt(kBalancingTimestampKey);
    if (timestamp != null) {
      final storedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      bool isSameDay =
          storedTime.year == now.year && storedTime.month == now.month && storedTime.day == now.day;
      if (isSameDay) {
        emit(state.copyWith(lastBalancingTime: storedTime));
        _startCooldownTimer();
      } else {
        emit(state.copyWith(isBalancingDisabled: false));
      }
    }
  }

  Future<void> getPosStats({String? fromDate, String? toDate}) async {
    emit(state.copyWith(isStatsLoading: true));
    try {
      String urlString = ApiEndPoints.BASE_URL + "stats";
      if (fromDate != null) urlString += "?from_date=$fromDate";
      if (toDate != null) urlString += "&to_date=$toDate";

      final response = await _repository.fetchPosStats(urlString);
      if (response['status'] == true) {
        emit(state.copyWith(posStatsModel: PosStatsData.fromJson(response['data'])));
      } else {
        emit(state.copyWith(posStatsModel: null));
      }
    } catch (e) {
    } finally {
      if (!isClosed) emit(state.copyWith(isStatsLoading: false));
    }
  }

  Future<void> refreshOrders(BuildContext context, {required bool isCurrent}) async {
    if (isCurrent) {
      emit(state.copyWith(isLoading: true));
      await getOrders(context);
    } else {
      emit(state.copyWith(isLoading: true));
      await getHistoryOrders(context);
    }
  }

  Future<void> refreshAllOrders(BuildContext context) async {
    emit(state.copyWith(isLoading: true));
    try {
      await Future.wait([
        getOrders(context),
        getHistoryOrders(context),
      ]);
    } catch (e) {
      debugPrint('Error refreshing all orders: $e');
    } finally {
      if (!isClosed) emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> smartPrintBill(BuildContext context, Order order, bool isArabic) async {
    await _printerService.smartPrintBill(
        context, order, isArabic, state.userModel, state.allClothsModel);
  }

  Future<void> addCustomer(BuildContext context, String name, String phone) async {
    final loadingCubit = context.read<LoadingCubit>();
    try {
      loadingCubit.showLoading();
      final response = await _repository.addCustomer(name, phone);
      if (response['status'] == true) {
        bool isNew = response['data']['customer']['is_new'] ?? false;
        String messageKey = isNew ? 'customer_added_successfully' : 'customer_already_registered';
        UIHelper.showBottomFlash(context,
            title: messageKey.tr, message: messageKey.tr, isError: false);
      } else {
        UIHelper.showBottomFlash(context,
            title: 'error'.tr,
            message: response['message'] ?? 'something_went_wrong'.tr,
            isError: true);
      }
    } catch (error) {
      UIHelper.showBottomFlash(context,
          title: 'error'.tr, message: 'connection_error'.tr, isError: true);
    } finally {
      loadingCubit.hideLoading();
    }
  }

  Future<void> handleSubmitPaymentCollectionInvoices({
    required BuildContext context,
    required String fromDate,
    required String toDate,
    required String type,
    required String phone,
  }) async {
    final loadingCubit = context.read<LoadingCubit>();
    try {
      loadingCubit.showLoading();
      final Map<String, dynamic> body = {
        "phone": phone,
        "type": type,
        "start_date": fromDate,
        "end_date": toDate,
      };
      final response = await _repository.fetchCollectionInvoices(ApiEndPoints.paymentBill, body);
      if (response['status'] == true) {
        CollectionBillModel bill = CollectionBillModel.fromMap(response);
        if (bill.data != null && bill.data!.orders.isNotEmpty) {
          await _printerService.smartPrintBillsCollectionPayments(context, bill, true);
        } else {
          UIHelper.showBottomFlash(context,
              title: 'error'.tr, message: "لم يتم العثور على اي طلبات", isError: true);
        }
      } else {
        UIHelper.showBottomFlash(context,
            title: 'error'.tr, message: response['message'], isError: true);
      }
    } catch (e) {
      UIHelper.showBottomFlash(context,
          title: 'error'.tr, message: 'connection_error'.tr, isError: true);
    } finally {
      loadingCubit.hideLoading();
    }
  }

  Future<void> handleSubmitItemsCollectionInvoices({
    required BuildContext context,
    required String fromDate,
    required String toDate,
    required String type,
    required String phone,
  }) async {
    final loadingProvider = context.read<LoadingCubit>();
    try {
      loadingProvider.showLoading();
      final Map<String, dynamic> body = {
        "phone": phone,
        "type": type,
        "start_date": fromDate,
        "end_date": toDate,
      };
      final response = await _repository.fetchCollectionInvoices(ApiEndPoints.itemsBill, body);
      if (response['status'] == true) {
        ItemsBillModel bill = ItemsBillModel.fromJson(response);
        if (bill.data != null && (bill.data!.items.isNotEmpty)) {
          await _printerService.smartPrintBillsCollectionItems(context, bill, true);
        } else {
          UIHelper.showBottomFlash(context,
              title: 'error'.tr, message: "لم يتم العثور على اي طلبات", isError: true);
        }
      } else {
        UIHelper.showBottomFlash(context,
            title: 'error'.tr, message: response['message'] ?? 'Error', isError: true);
      }
    } catch (e) {
      UIHelper.showBottomFlash(context,
          title: 'error'.tr, message: 'connection_error'.tr, isError: true);
    } finally {
      loadingProvider.hideLoading();
    }
  }
}
