class ItemsBillModel {
  final bool status;
  final CollectionBillData? data;
  final String message;

  ItemsBillModel({
    required this.status,
    this.data,
    required this.message,
  });

  factory ItemsBillModel.fromJson(Map<String, dynamic> json) {
    return ItemsBillModel(
      status: json['status'] ?? false,
      data: json['data'] != null ? CollectionBillData.fromJson(json['data']) : null,
      message: json['message'] ?? "",
    );
  }
}

class CollectionBillData {
  final String customerName;
  final String customerPhone;
  final String type;
  final int totalOrders;
  final double totalAmount;
  final String startDate;
  final String endDate;
  final List<BillItems> items;

  CollectionBillData({
    required this.customerName,
    required this.customerPhone,
    required this.type,
    required this.totalOrders,
    required this.totalAmount,
    required this.startDate,
    required this.endDate,
    required this.items,
  });

  factory CollectionBillData.fromJson(Map<String, dynamic> json) {
    return CollectionBillData(
      customerName: json['customer_name'] ?? "Unknown",
      customerPhone: json['customer_phone'] ?? "",
      type: json['type'] ?? "loan",
      totalOrders: json['total_orders'] ?? 0,
      // .toDouble() handles cases where the API sends an int (e.g. 100 instead of 100.0)
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      startDate: json['start_date'] ?? "",
      endDate: json['end_date'] ?? "",
      items: (json['items'] as List?)
          ?.map((v) => BillItems.fromJson(v))
          .toList() ?? [],
    );
  }
}

class BillItems {
  final String nameEn;
  final String nameAr;
  final int totalCount;
  final double totalPrice;

  BillItems({
    required this.nameEn,
    required this.nameAr,
    required this.totalCount,
    required this.totalPrice,
  });

  factory BillItems.fromJson(Map<String, dynamic> json) {
    return BillItems(
      nameEn: json['name_en'] ?? "",
      nameAr: json['name_ar'] ?? "",
      totalCount: json['total_count'] ?? 0,
      totalPrice: (json['total_price'] ?? 0).toDouble(),
    );
  }
}