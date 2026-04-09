import 'package:abyadpos_tab/features/settings/data/models/Items_bill_model.dart';
import 'package:abyadpos_tab/features/settings/data/models/collection_bill_model.dart';
import 'package:abyadpos_tab/features/home/data/models/clothes_model.dart';
import 'package:abyadpos_tab/features/orders/data/models/order_model.dart';
import 'package:abyadpos_tab/features/settings/data/models/pos_stats_response.dart';
import 'package:abyadpos_tab/features/auth/data/models/user_model.dart';
import 'package:abyadpos_tab/features/settings/data/models/loan_model.dart';
import 'package:abyadpos_tab/features/orders/data/models/payment_request.dart';

class OrderState {
  // --- Pagination & Search ---
  final String? externalSearchQuery;
  final int pageSize;
  final int pageSizeCloth;
  final int pageNumberCloth;
  final int pageNumber;
  final int pageNumberHistory;
  final String lastSearchQuery;

  // --- Flags & UI States ---
  final bool isPrepaid;
  final bool closeAndComplete;
  final bool isDiscount;
  final double discountValue;
  final bool isLoading;
  final bool isPaginating;
  final bool isStatsLoading;
  final bool isOrderDetailsLoading;
  final bool isExpress;
  final bool tabOnlyIroning;
  final bool tabOnlyWashing;
  final bool showDebtorsOnly;

  // --- Models ---
  final LoanModel? allLoansModel;
  final OrderModel? allAdsModel;
  final OrderModel? allHistoryModel;
  final OrderModel? filterAdsModel;
  final UserModel? userModel;
  final Order? orderDetailsModel;
  final ClothsModel? allClothsModel;
  final ClothsModel? allClothsModelUpdatePrices;
  final PosStatsData? posStatsModel;
  final PaymentRequest? lastPaymentRequest;

  // --- Lists ---
  final List<Cloth> listSelectedCarts;
  final List<Map<String, dynamic>> selectedItems;
  final List<Map<String, dynamic>> loanCustomers;

  // --- Balancing State ---
  final bool isBalancingDisabled;
  final String remainingTimeText;
  final String balancingText;
  final DateTime? lastBalancingTime;
  final double? walletBalance;

  OrderState({
    this.externalSearchQuery,
    this.pageSize = 20,
    this.pageSizeCloth = 100,
    this.pageNumberCloth = 1,
    this.pageNumber = 1,
    this.pageNumberHistory = 1,
    this.lastSearchQuery = "",
    this.isPrepaid = false,
    this.closeAndComplete = false,
    this.isDiscount = false,
    this.discountValue = 0.0,
    this.isLoading = false,
    this.isPaginating = false,
    this.isStatsLoading = false,
    this.isOrderDetailsLoading = false,
    this.isExpress = false,
    this.tabOnlyIroning = false,
    this.tabOnlyWashing = false,
    this.showDebtorsOnly = false,
    this.allLoansModel,
    this.allAdsModel,
    this.allHistoryModel,
    this.filterAdsModel,
    this.userModel,
    this.orderDetailsModel,
    this.allClothsModel,
    this.allClothsModelUpdatePrices,
    this.posStatsModel,
    this.lastPaymentRequest,
    this.listSelectedCarts = const [],
    this.selectedItems = const [],
    this.loanCustomers = const [],
    this.isBalancingDisabled = false,
    this.remainingTimeText = "",
    this.balancingText = "طلب تسوية", // Default or use "balancing_request".tr in UI
    this.lastBalancingTime,
    this.walletBalance,
  });

  OrderState copyWith({
    String? externalSearchQuery,
    int? pageSize,
    int? pageSizeCloth,
    int? pageNumberCloth,
    int? pageNumber,
    int? pageNumberHistory,
    String? lastSearchQuery,
    bool? isPrepaid,
    bool? closeAndComplete,
    bool? isDiscount,
    double? discountValue,
    bool? isLoading,
    bool? isPaginating,
    bool? isStatsLoading,
    bool? isOrderDetailsLoading,
    bool? isExpress,
    bool? tabOnlyIroning,
    bool? tabOnlyWashing,
    bool? showDebtorsOnly,
    LoanModel? allLoansModel,
    OrderModel? allAdsModel,
    OrderModel? allHistoryModel,
    OrderModel? filterAdsModel,
    UserModel? userModel,
    Order? orderDetailsModel,
    ClothsModel? allClothsModel,
    ClothsModel? allClothsModelUpdatePrices,
    PosStatsData? posStatsModel,
    PaymentRequest? lastPaymentRequest,
    List<Cloth>? listSelectedCarts,
    List<Map<String, dynamic>>? selectedItems,
    List<Map<String, dynamic>>? loanCustomers,
    bool? isBalancingDisabled,
    String? remainingTimeText,
    String? balancingText,
    DateTime? lastBalancingTime,
    double? walletBalance,
    bool clearFilterAdsModel = false, // لحذف الموديل عند إلغاء البحث
  }) {
    return OrderState(
      externalSearchQuery: externalSearchQuery ?? this.externalSearchQuery,
      pageSize: pageSize ?? this.pageSize,
      pageSizeCloth: pageSizeCloth ?? this.pageSizeCloth,
      pageNumberCloth: pageNumberCloth ?? this.pageNumberCloth,
      pageNumber: pageNumber ?? this.pageNumber,
      pageNumberHistory: pageNumberHistory ?? this.pageNumberHistory,
      lastSearchQuery: lastSearchQuery ?? this.lastSearchQuery,
      isPrepaid: isPrepaid ?? this.isPrepaid,
      closeAndComplete: closeAndComplete ?? this.closeAndComplete,
      isDiscount: isDiscount ?? this.isDiscount,
      discountValue: discountValue ?? this.discountValue,
      isLoading: isLoading ?? this.isLoading,
      isPaginating: isPaginating ?? this.isPaginating,
      isStatsLoading: isStatsLoading ?? this.isStatsLoading,
      isOrderDetailsLoading: isOrderDetailsLoading ?? this.isOrderDetailsLoading,
      isExpress: isExpress ?? this.isExpress,
      tabOnlyIroning: tabOnlyIroning ?? this.tabOnlyIroning,
      tabOnlyWashing: tabOnlyWashing ?? this.tabOnlyWashing,
      showDebtorsOnly: showDebtorsOnly ?? this.showDebtorsOnly,
      allLoansModel: allLoansModel ?? this.allLoansModel,
      allAdsModel: allAdsModel ?? this.allAdsModel,
      allHistoryModel: allHistoryModel ?? this.allHistoryModel,
      filterAdsModel: clearFilterAdsModel ? null : (filterAdsModel ?? this.filterAdsModel),
      userModel: userModel ?? this.userModel,
      orderDetailsModel: orderDetailsModel ?? this.orderDetailsModel,
      allClothsModel: allClothsModel ?? this.allClothsModel,
      allClothsModelUpdatePrices: allClothsModelUpdatePrices ?? this.allClothsModelUpdatePrices,
      posStatsModel: posStatsModel ?? this.posStatsModel,
      lastPaymentRequest: lastPaymentRequest ?? this.lastPaymentRequest,
      listSelectedCarts: listSelectedCarts ?? this.listSelectedCarts,
      selectedItems: selectedItems ?? this.selectedItems,
      loanCustomers: loanCustomers ?? this.loanCustomers,
      isBalancingDisabled: isBalancingDisabled ?? this.isBalancingDisabled,
      remainingTimeText: remainingTimeText ?? this.remainingTimeText,
      balancingText: balancingText ?? this.balancingText,
      lastBalancingTime: lastBalancingTime ?? this.lastBalancingTime,
      walletBalance: walletBalance ?? this.walletBalance,
    );
  }

  OrderState copyWithBullWalletBalance({
    double? walletBalance,
    String? externalSearchQuery,
    int? pageSize,
    int? pageSizeCloth,
    int? pageNumberCloth,
    int? pageNumber,
    int? pageNumberHistory,
    String? lastSearchQuery,
    bool? isPrepaid,
    bool? closeAndComplete,
    bool? isDiscount,
    double? discountValue,
    bool? isLoading,
    bool? isPaginating,
    bool? isStatsLoading,
    bool? isOrderDetailsLoading,
    bool? isExpress,
    bool? tabOnlyIroning,
    bool? tabOnlyWashing,
    bool? showDebtorsOnly,
    LoanModel? allLoansModel,
    OrderModel? allAdsModel,
    OrderModel? allHistoryModel,
    OrderModel? filterAdsModel,
    UserModel? userModel,
    Order? orderDetailsModel,
    ClothsModel? allClothsModel,
    ClothsModel? allClothsModelUpdatePrices,
    PosStatsData? posStatsModel,
    PaymentRequest? lastPaymentRequest,
    List<Cloth>? listSelectedCarts,
    List<Map<String, dynamic>>? selectedItems,
    List<Map<String, dynamic>>? loanCustomers,
    bool? isBalancingDisabled,
    String? remainingTimeText,
    String? balancingText,
    DateTime? lastBalancingTime,
    bool clearFilterAdsModel = false,
  }) {
    return OrderState(
      walletBalance: walletBalance,
      externalSearchQuery: externalSearchQuery ?? this.externalSearchQuery,
      pageSize: pageSize ?? this.pageSize,
      pageSizeCloth: pageSizeCloth ?? this.pageSizeCloth,
      pageNumberCloth: pageNumberCloth ?? this.pageNumberCloth,
      pageNumber: pageNumber ?? this.pageNumber,
      pageNumberHistory: pageNumberHistory ?? this.pageNumberHistory,
      lastSearchQuery: lastSearchQuery ?? this.lastSearchQuery,
      isPrepaid: isPrepaid ?? this.isPrepaid,
      closeAndComplete: closeAndComplete ?? this.closeAndComplete,
      isDiscount: isDiscount ?? this.isDiscount,
      discountValue: discountValue ?? this.discountValue,
      isLoading: isLoading ?? this.isLoading,
      isPaginating: isPaginating ?? this.isPaginating,
      isStatsLoading: isStatsLoading ?? this.isStatsLoading,
      isOrderDetailsLoading: isOrderDetailsLoading ?? this.isOrderDetailsLoading,
      isExpress: isExpress ?? this.isExpress,
      tabOnlyIroning: tabOnlyIroning ?? this.tabOnlyIroning,
      tabOnlyWashing: tabOnlyWashing ?? this.tabOnlyWashing,
      showDebtorsOnly: showDebtorsOnly ?? this.showDebtorsOnly,
      allLoansModel: allLoansModel ?? this.allLoansModel,
      allAdsModel: allAdsModel ?? this.allAdsModel,
      allHistoryModel: allHistoryModel ?? this.allHistoryModel,
      filterAdsModel: clearFilterAdsModel ? null : (filterAdsModel ?? this.filterAdsModel),
      userModel: userModel ?? this.userModel,
      orderDetailsModel: orderDetailsModel ?? this.orderDetailsModel,
      allClothsModel: allClothsModel ?? this.allClothsModel,
      allClothsModelUpdatePrices: allClothsModelUpdatePrices ?? this.allClothsModelUpdatePrices,
      posStatsModel: posStatsModel ?? this.posStatsModel,
      lastPaymentRequest: lastPaymentRequest ?? this.lastPaymentRequest,
      listSelectedCarts: listSelectedCarts ?? this.listSelectedCarts,
      selectedItems: selectedItems ?? this.selectedItems,
      loanCustomers: loanCustomers ?? this.loanCustomers,
      isBalancingDisabled: isBalancingDisabled ?? this.isBalancingDisabled,
      remainingTimeText: remainingTimeText ?? this.remainingTimeText,
      balancingText: balancingText ?? this.balancingText,
      lastBalancingTime: lastBalancingTime ?? this.lastBalancingTime,
    );
  }

  // --- Getters اللي كانت موجودة في الـ Provider ---
  bool get isSearching => filterAdsModel != null;

  bool get hasMorePages {
    if (allLoansModel == null) return false;
    final p = allLoansModel!.data.pagination;
    return p.currentPage < p.lastPage;
  }

  OrderModel? getActiveModel(bool isCurrentView) {
    if (filterAdsModel != null) return filterAdsModel;
    if (isLoading && lastSearchQuery.isNotEmpty) return null;
    return isCurrentView ? allAdsModel : allHistoryModel;
  }

  int get totalPageCount {
    final model = getActiveModel(true);
    return model?.data.pagination.pagesCount ?? 1;
  }
}
