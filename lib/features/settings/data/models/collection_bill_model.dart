class CollectionBillModel {
  final bool status;
  final String message;
  final BillData? data;

  CollectionBillModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory CollectionBillModel.fromMap(Map<String, dynamic>? map) {
    // If the entire map is null, return a default "failed" model
    if (map == null) {
      return CollectionBillModel(status: false, message: "No data received");
    }
    return CollectionBillModel(
      status: map['status'] ?? false,
      message: map['message'] ?? '',
      data: map['data'] != null ? BillData.fromMap(map['data']) : null,
    );
  }
}

class BillData {
  final String customerName;
  final String customerPhone;
  final String type;
  final int totalOrders;
  final double totalSum;
  final String startDate;
  final String endDate;
  final List<BillOrder> orders;

  BillData({
    required this.customerName,
    required this.customerPhone,
    required this.type,
    required this.totalOrders,
    required this.totalSum,
    required this.startDate,
    required this.endDate,
    required this.orders,
  });

  factory BillData.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      // Return "Empty" object instead of null to prevent UI crashes
      return BillData(
        customerName: "N/A",
        customerPhone: "N/A",
        type: "",
        totalOrders: 0,
        totalSum: 0.0,
        startDate: "",
        endDate: "",
        orders: [],
      );
    }
    return BillData(
      customerName: map['customer_name']?.toString() ?? '',
      customerPhone: map['customer_phone']?.toString() ?? '',
      type: map['type']?.toString() ?? '',
      totalOrders: int.tryParse(map['total_orders']?.toString() ?? '0') ?? 0,
      totalSum: double.tryParse(map['total_sum']?.toString() ?? '0.0') ?? 0.0,
      startDate: map['start_date']?.toString() ?? '',
      endDate: map['end_date']?.toString() ?? '',
      orders: (map['orders'] as List?)
          ?.map((x) => BillOrder.fromMap(x))
          .toList() ?? [],
    );
  }
}

class BillOrder {
  final String orderNumber;
  final double totalPrice;
  final String order_notes;
  final String orderDate;
  final String orderTime;

  BillOrder({
    required this.orderNumber,
    required this.totalPrice,
    required this.orderDate,
    required this.orderTime,
    required this.order_notes,
  });

  factory BillOrder.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return BillOrder(orderNumber: '', totalPrice: 0.0, orderDate: '', orderTime: '',order_notes: "");
    }
    return BillOrder(
      orderNumber: map['order_number']?.toString() ?? '',
      // Use tryParse to handle cases where API might send a string instead of a number
      totalPrice: double.tryParse(map['total_price']?.toString() ?? '0.0') ?? 0.0,
      orderDate: map['order_date']?.toString() ?? '',
      order_notes: map['order_notes']?.toString() ?? '',
      orderTime: map['order_time']?.toString() ?? '',
    );
  }
}