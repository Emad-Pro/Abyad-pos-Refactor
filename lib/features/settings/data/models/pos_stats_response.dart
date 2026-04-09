class PosStatsResponse {
  final bool status;
  final PosStatsData? data;
  final String? message;

  PosStatsResponse({
    required this.status,
    this.data,
    this.message,
  });

  factory PosStatsResponse.fromJson(Map<String, dynamic> json) =>
      PosStatsResponse(
        status: json['status'] ?? false,
        data: json['data'] != null ? PosStatsData.fromJson(json['data']) : null,
        message: json['message'],
      );
}

class PosStatsData {
  final Summary? summary;
  final PaymentBreakdown? paymentBreakdown;
  final StatusStats? statusStats;
  final List<TopCustomer> topCustomers;
  final List<TopProduct> topProducts;
  final Sales? sales;
  final Settlement? settlement; // New Field

  PosStatsData({
    this.summary,
    this.paymentBreakdown,
    this.statusStats,
    required this.topCustomers,
    required this.topProducts,
    this.sales,
    this.settlement,
  });

  factory PosStatsData.fromJson(Map<String, dynamic> json) => PosStatsData(
    summary: json['summary'] != null ? Summary.fromJson(json['summary']) : null,
    paymentBreakdown: json['payment_breakdown'] != null
        ? PaymentBreakdown.fromJson(json['payment_breakdown'])
        : null,
    statusStats: json['status_stats'] != null
        ? StatusStats.fromJson(json['status_stats'])
        : null,
    topCustomers: json['top_customers'] != null
        ? List<TopCustomer>.from(json['top_customers'].map((x) => TopCustomer.fromJson(x)))
        : [],
    topProducts: json['top_products'] != null
        ? List<TopProduct>.from(json['top_products'].map((x) => TopProduct.fromJson(x)))
        : [],
    sales: json['sales'] != null ? Sales.fromJson(json['sales']) : null,
    settlement: json['settlement'] != null ? Settlement.fromJson(json['settlement']) : null,
  );
}

class Summary {
  final int? ordersCount;
  final double? totalOrdersPrice;
  final double? totalOrdersPriceNearpay;
  final double? totalOrdersPriceCash;
  final double? totalOrdersPriceCreditCard;
  final double? totalOrdersPriceLoan;
  final double? totalOrdersPriceWallet;
  final double? totalOrdersPriceUnpaid;
  final int? ordersInProgressCount;
  final double? ordersInProgressAmount;
  final int? ordersReadyForPickupCount;
  final double? ordersReadyForPickupAmount;
  final int? ordersPickedUpCount;
  final double? ordersPickedUpAmount;
  final DateRange? dateRange;

  Summary({
    this.ordersCount,
    this.totalOrdersPrice,
    this.totalOrdersPriceNearpay,
    this.totalOrdersPriceCash,
    this.totalOrdersPriceCreditCard,
    this.totalOrdersPriceLoan,
    this.totalOrdersPriceWallet,
    this.totalOrdersPriceUnpaid,
    this.ordersInProgressCount,
    this.ordersInProgressAmount,
    this.ordersReadyForPickupCount,
    this.ordersReadyForPickupAmount,
    this.ordersPickedUpCount,
    this.ordersPickedUpAmount,
    this.dateRange,
  });

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
    ordersCount: json['orders_count'],
    totalOrdersPrice: parseDouble(json['total_orders_price']),
    totalOrdersPriceNearpay: parseDouble(json['total_orders_price_nearpay']),
    totalOrdersPriceCash: parseDouble(json['total_orders_price_cash']),
    totalOrdersPriceCreditCard: parseDouble(json['total_orders_price_credit_card']),
    totalOrdersPriceLoan: parseDouble(json['total_orders_price_loan']),
    totalOrdersPriceWallet: parseDouble(json['total_orders_price_wallet']),
    totalOrdersPriceUnpaid: parseDouble(json['total_orders_price_unpaid']),
    ordersInProgressCount: json['orders_in_progress_count'],
    ordersInProgressAmount: parseDouble(json['orders_in_progress_amount']),
    ordersReadyForPickupCount: json['orders_ready_for_pickup_count'],
    ordersReadyForPickupAmount: parseDouble(json['orders_ready_for_pickup_amount']),
    ordersPickedUpCount: json['orders_picked_up_count'],
    ordersPickedUpAmount: parseDouble(json['orders_picked_up_amount']),
    dateRange: json['date_range'] != null ? DateRange.fromJson(json['date_range']) : null,
  );
}

class DateRange {
  final String? fromDate;
  final String? toDate;

  DateRange({this.fromDate, this.toDate});

  factory DateRange.fromJson(Map<String, dynamic> json) => DateRange(
    fromDate: json['from_date'],
    toDate: json['to_date'],
  );
}
double parseDouble(dynamic value) {
  return double.tryParse(value?.toString() ?? '0') ?? 0.0;
}
class PaymentBreakdown {
  final double? totalCashAmount;
  final double? totalCreditAmount;
  final double? totalLoanAmount;
  final double? totalWalletAmount;
  final double? totalNearpayAmount;
  final double? totalNotPickedUp;

  PaymentBreakdown({
    this.totalCashAmount,
    this.totalCreditAmount,
    this.totalLoanAmount,
    this.totalWalletAmount,
    this.totalNearpayAmount,
    this.totalNotPickedUp,
  });

  factory PaymentBreakdown.fromJson(Map<String, dynamic> json) => PaymentBreakdown(
    totalCashAmount: parseDouble(json['total_cash_amount']),
    totalCreditAmount: parseDouble(json['total_credit_amount']),
    totalLoanAmount: parseDouble(json['total_loan_amount']),
    totalWalletAmount: parseDouble(json['total_wallet_amount']),
    totalNearpayAmount: parseDouble(json['total_nearpay_amount']),
    totalNotPickedUp: parseDouble(json['total_not_picked_up']),
  );
}

class StatusStats {
  final StatusItem? inProgress;
  final StatusItem? readyForPickup;
  final StatusItem? pickedUp;

  StatusStats({this.inProgress, this.readyForPickup, this.pickedUp});

  factory StatusStats.fromJson(Map<String, dynamic> json) => StatusStats(
    inProgress: json['in_progress'] != null ? StatusItem.fromJson(json['in_progress']) : null,
    readyForPickup: json['ready_for_pickup'] != null ? StatusItem.fromJson(json['ready_for_pickup']) : null,
    pickedUp: json['picked_up'] != null ? StatusItem.fromJson(json['picked_up']) : null,
  );
}

class StatusItem {
  final int count;
  final double amount;
  final PaymentBreakdown paymentBreakdown;

  StatusItem(
      {required this.count, required this.amount, required this.paymentBreakdown});

  factory StatusItem.fromJson(Map<String, dynamic> json) =>
      StatusItem(
        count: json['count'] ?? 0,
        amount: parseDouble(json['amount']),
        paymentBreakdown: PaymentBreakdown.fromJson(
            json['payment_breakdown'] ?? {}),
      );
}


class TopCustomer {
  final String? name;
  final String? mobileNumber;
  final int? totalOrderCount;
  final double? totalOrderValue;
  final double? totalPaidCash;
  final double? totalPaidCredit;
  final double? totalLoan;

  TopCustomer({
    this.name,
    this.mobileNumber,
    this.totalOrderCount,
    this.totalOrderValue,
    this.totalPaidCash,
    this.totalPaidCredit,
    this.totalLoan,
  });

  factory TopCustomer.fromJson(Map<String, dynamic> json) => TopCustomer(
    name: json['name'],
    mobileNumber: json['mobile_number'],
    totalOrderCount: json['total_order_count'],
    totalOrderValue: parseDouble( json['total_order_value']),
    totalPaidCash:  parseDouble(json['total_paid_cash']),
    totalPaidCredit:  parseDouble(json['total_paid_credit']),
    totalLoan: parseDouble( json['total_loan']),
  );
}
class Settlement {
  final SettlementRequest? lastRequest;
  final int? pendingRequestsCount;
  final double? pendingSettlementAmount;
  final double? unrequestedAmount;
  final int? unrequestedOrdersCount;
  final double? totalSettled;
  final NearpayBreakdown? nearpayBreakdown; // New Field

  Settlement({
    this.lastRequest,
    this.pendingRequestsCount,
    this.pendingSettlementAmount,
    this.unrequestedAmount,
    this.unrequestedOrdersCount,
    this.totalSettled,
    this.nearpayBreakdown,
  });

  factory Settlement.fromJson(Map<String, dynamic> json) => Settlement(
    lastRequest: json['last_request'] != null ? SettlementRequest.fromJson(json['last_request']) : null,
    pendingRequestsCount: json['pending_requests_count'],
    pendingSettlementAmount: parseDouble(json['pending_settlement_amount']),
    unrequestedAmount: parseDouble(json['unrequested_amount']),
    unrequestedOrdersCount: json['unrequested_orders_count'],
    totalSettled: parseDouble(json['total_settled']),
    nearpayBreakdown: json['nearpay_breakdown'] != null
        ? NearpayBreakdown.fromJson(json['nearpay_breakdown'])
        : null,
  );
}

class NearpayBreakdown {
  final NearpayStat? total;
  final ByCardType? byCardType;

  NearpayBreakdown({this.total, this.byCardType});

  factory NearpayBreakdown.fromJson(Map<String, dynamic> json) => NearpayBreakdown(
    total: json['total'] != null ? NearpayStat.fromJson(json['total']) : null,
    byCardType: json['by_card_type'] != null ? ByCardType.fromJson(json['by_card_type']) : null,
  );
}

class ByCardType {
  final NearpayStat? mada;
  final NearpayStat? visa;
  final NearpayStat? mastercard;
  final NearpayStat? amex;
  final NearpayStat? unknown;

  ByCardType({this.mada, this.visa, this.mastercard, this.amex, this.unknown});

  factory ByCardType.fromJson(Map<String, dynamic> json) => ByCardType(
    mada: json['mada'] != null ? NearpayStat.fromJson(json['mada']) : null,
    visa: json['visa'] != null ? NearpayStat.fromJson(json['visa']) : null,
    mastercard: json['mastercard'] != null ? NearpayStat.fromJson(json['mastercard']) : null,
    amex: json['amex'] != null ? NearpayStat.fromJson(json['amex']) : null,
    unknown: json['unknown'] != null ? NearpayStat.fromJson(json['unknown']) : null,
  );
}

class NearpayStat {
  final int count;
  final double amount;

  NearpayStat({required this.count, required this.amount});

  factory NearpayStat.fromJson(Map<String, dynamic> json) => NearpayStat(
    count: json['count'] ?? 0,
    amount: parseDouble(json['amount']),
  );
}
class SettlementRequest {
  final int? id;
  final double? amount;
  final String? status;
  final String? requestedAt;

  SettlementRequest({this.id, this.amount, this.status, this.requestedAt});

  factory SettlementRequest.fromJson(Map<String, dynamic> json) => SettlementRequest(
    id: json['id'],
    amount: parseDouble(json['amount']),
    status: json['status'],
    requestedAt: json['requested_at'],
  );
}

class TopProduct {
  final int? clothId;
   String clothNameEn;
   String clothNameAr;
  final String? cloth_image;
  final int? totalQuantity;
  final double?total_revenue;

  TopProduct({
    this.clothId,
    required this.clothNameEn,
    required this.clothNameAr,
    this.cloth_image,
    this.totalQuantity,
    this.total_revenue,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) => TopProduct(
    clothId: json['cloth_id'],
    clothNameEn: json['cloth_name_en'],
    clothNameAr: json['cloth_name_ar'],
    totalQuantity: json['total_quantity'],
    total_revenue: parseDouble( json['total_revenue']),
    cloth_image:json['cloth_image'],
  );
}

class Sales {
  final String? grouping;
  final List<SalesData>? data;

  Sales({this.grouping, this.data});

  factory Sales.fromJson(Map<String, dynamic> json) => Sales(
    grouping: json['grouping'],
    data: json['data'] != null
        ? List<SalesData>.from(
        json['data'].map((x) => SalesData.fromJson(x)))
        : [],
  );
}

class SalesData {
  final String? label;
  final String? fullDate; // Updated from dateRange to match full_date
  final double? totalSales;
  final int? ordersCount;

  SalesData({this.label, this.fullDate, this.totalSales, this.ordersCount});

  factory SalesData.fromJson(Map<String, dynamic> json) => SalesData(
    label: json['label'],
    fullDate: json['full_date'],
    totalSales: parseDouble(json['total_sales']),
    ordersCount: json['orders_count'],
  );
}