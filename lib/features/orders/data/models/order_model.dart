// To parse this JSON data, do
//
//     final orderModel = orderModelFromJson(jsonString);

//     {"status":true,"data":{"orders":[{"id":"ORD-816130","created_at":"2025-10-06T08:36:18.000000Z","updated_at":"2025-10-06T08:36:18.000000Z",
// "clothes":[{"cloth_id":38,"cloth_name":"Thoub","cloth_name_ar":"\u062b\u0648\u0628","cloth_count":2,"cloth_price":"5.00","cloth_total_price":"10.00",
// "service_type":"normal","only_ironing":1,"cloth_image":"https:\/\/dev.abyad.sa\/uploads\/clothes\/67e1e50997d90.jpeg"}],"user":{"user_id":null,
// "user_name":null,"mobile":null},"status":{"id":2,"key":"in-progress","name_en":"In Progress","name_ar":"\u0642\u064a\u062f \u0627\u0644\u062a\u0646\u0641\u064a\u0630"}
// ,"order_type":"walkin-walkin","total_item_count":2,"address":null,"lat":null,"lng":null,"sub_total":"10.00","vat_amount":"0.00","total_price":"10.00"
// ,"payment_details":{"payment_type":null,"wallet_transactions":[]},"activity_log":[{"status_key":"in-progress","name_en":"In Progress"
// ,"name_ar":"\u0642\u064a\u062f \u0627\u0644\u062a\u0646\u0641\u064a\u0630","date":"06\/10\/2025","time":"11:36 AM"}]},{"id":"ORD-825407","create
import 'dart:convert';

import 'package:get/get.dart';

OrderModel orderModelFromJson(String str) => OrderModel.fromJson(json.decode(str));

String orderModelToJson(OrderModel data) => json.encode(data.toJson());

class OrderModel {
  bool status;
  OrderData data;
  String message;

  OrderModel({
    required this.status,
    required this.data,
    required this.message,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        status: json["status"],
        data: OrderData.fromJson(json["data"]),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data.toJson(),
        "message": message,
      };
}

class OrderData {
  List<Order> orders;
  Pagination pagination;

  OrderData({
    required this.orders,
    required this.pagination,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) => OrderData(
        orders: List<Order>.from(json["orders"].map((x) => Order.fromJson(x))),
        pagination: Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
        "orders": List<dynamic>.from(orders.map((x) => x.toJson())),
        "pagination": pagination.toJson(),
      };
}

class Order {
  String id;
  String invoice_url;
  DateTime createdAt;
  DateTime updatedAt;
  List<Clothe> clothes;
  User user;
  Status status;
  String orderType;
  int totalItemCount;
  dynamic address;
  dynamic lat;
  dynamic lng;
  String subTotal;
  String vat_amount;
  String order_details;
  bool prepaid;
  bool is_fast_order;
  bool invoice_sent;
  String? invoice_sent_at;
  bool order_is_paid;
  String totalPrice;
  String finalTotalPrice;
  PaymentDetails? paymentDetails;
  List<ActivityLog>? activityLog;
  Order({
    required this.id,
    required this.invoice_url,
    required this.createdAt,
    required this.updatedAt,
    required this.clothes,
    required this.user,
    required this.status,
    required this.orderType,
    required this.totalItemCount,
    required this.address,
    required this.lat,
    required this.lng,
    required this.subTotal,
    required this.vat_amount,
    required this.order_details,
    required this.prepaid,
    required this.is_fast_order,
    required this.invoice_sent,
    this.invoice_sent_at,
    required this.order_is_paid,
    required this.totalPrice,
    required this.finalTotalPrice,
    required this.paymentDetails,
    required this.activityLog,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json["id"],
        invoice_url: json["invoice_url"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        clothes: List<Clothe>.from(json["clothes"].map((x) => Clothe.fromJson(x))),
        user: User.fromJson(json.containsKey('user') ? json["user"] : json['customer']),
        status: Status.fromJson(json["status"]),
        orderType: json["order_type"],
        totalItemCount: json["total_item_count"] != null ? json["total_item_count"] : 0,
        address: json["address"],
        lat: json["lat"],
        lng: json["lng"],
        subTotal: json["sub_total"]?.toString() ?? "0.0",
        vat_amount: json["vat_amount"]?.toString() ?? "0.0",
        order_details: json["order_details"]?.toString() ?? "",
        totalPrice: json["total_price"]?.toString() ?? "0.0",
        finalTotalPrice:
            json["final_total_price"]?.toString() ?? json["total_price"]?.toString() ?? "0.0",
        paymentDetails: json["payment_details"] != null
            ? PaymentDetails.fromJson(json["payment_details"])
            : null,
        prepaid: toBool(json["prepaid"]),
        is_fast_order: toBool(json["is_fast_order"]),
        invoice_sent: toBool(json["invoice_sent"]),
        invoice_sent_at: json["invoice_sent_at"] != null ? json["invoice_sent_at"] : "",
        order_is_paid: toBool(json["order_is_paid"]),
        activityLog: (json["activity_log"] != null && json["activity_log"] is List)
            ? List<ActivityLog>.from(
                json["activity_log"].map((x) => ActivityLog.fromJson(x)),
              )
            : [],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "invoice_url": invoice_url,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "clothes": List<dynamic>.from(clothes.map((x) => x.toJson())),
        "user": user.toJson(),
        "status": status.toJson(),
        "order_type": orderType,
        "total_item_count": totalItemCount,
        "address": address,
        "lat": lat,
        "lng": lng,
        "sub_total": subTotal,
        "vat_amount": vat_amount,
        "order_details": order_details,
        "prepaid": prepaid,
        "is_fast_order": is_fast_order,
        "invoice_sent": invoice_sent,
        "invoice_sent_at": invoice_sent_at,
        "order_is_paid": order_is_paid,
        "total_price": totalPrice,
        "final_total_price": finalTotalPrice,
        "payment_details": paymentDetails!.toJson(),
      };
}

class Clothe {
  int clothId;
  String clothName;
  String clothNameAr;
  int clothCount;
  String clothPrice;
  String clothTotalPrice;
  ServiceType serviceType;
  bool onlyIroning;
  bool only_cleaning;

  String clothImage;
  bool support_ironing;
  // New fields
  bool isCustomized;
  String? details;
  String? custom_price_per_unit;
  String? totalCustomPrice;
  Clothe({
    required this.clothId,
    required this.clothName,
    required this.clothNameAr,
    required this.clothCount,
    required this.clothPrice,
    required this.clothTotalPrice,
    required this.serviceType,
    required this.onlyIroning,
    required this.only_cleaning,
    required this.clothImage,
    this.support_ironing = true,
    this.isCustomized = false, // default false
    this.details,
    this.custom_price_per_unit,
    this.totalCustomPrice,
  });

  factory Clothe.fromJson(Map<String, dynamic> json) => Clothe(
        clothId: json["cloth_id"],
        clothName: json["cloth_name"] ?? "",
        clothNameAr: json["cloth_name_ar"] ?? "",
        clothCount: json["cloth_count"] ?? 0,
        clothPrice: json["cloth_price"]?.toString() ?? "0.0",
        clothTotalPrice: json["cloth_total_price"]?.toString() ?? "0.0",
        serviceType: serviceTypeValues.map[json["service_type"]] ?? ServiceType.NORMAL,
        onlyIroning: toBool(json["only_ironing"], defaultValue: false),
        only_cleaning: toBool(json["only_cleaning"], defaultValue: false),
        clothImage: json["cloth_image"] ?? "",
// 🛡️ These fields are often missing in search results
//     isCustomized: json["is_customized"] == 1 || json["is_customized"] == true,
        isCustomized: toBool(json["is_customized"], defaultValue: false),
        support_ironing: toBool(json["support_ironing"], defaultValue: true),
        details: json["details"],
        custom_price_per_unit: json["custom_price_per_unit"]?.toString(),
        totalCustomPrice: json["total_custom_price"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "cloth_id": clothId,
        "cloth_name": clothName,
        "cloth_name_ar": clothNameAr,
        "cloth_count": clothCount,
        "cloth_price": clothPrice,
        "cloth_total_price": clothTotalPrice,
        "service_type": serviceTypeValues.reverse[serviceType],
        "only_ironing": onlyIroning,
        "only_cleaning": only_cleaning,
        "cloth_image": clothImage,
        "is_customized": isCustomized,
        "support_ironing": support_ironing,
        "details": details,
        "custom_price_per_unit": custom_price_per_unit,
        "total_custom_price": totalCustomPrice,
      };
}

bool toBool(dynamic value, {bool defaultValue = false}) {
  if (value == null) return defaultValue; // Now you can choose the default
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) {
    final cleanValue = value.trim().toLowerCase();
    return cleanValue == 'true' || cleanValue == '1';
  }
  return defaultValue;
}

enum ServiceType { FAST, NORMAL }

final serviceTypeValues = EnumValues({
  "fast": ServiceType.FAST,
  "normal": ServiceType.NORMAL,
});

extension ServiceTypeExtension on ServiceType {
  String get labelAr {
    switch (this) {
      case ServiceType.FAST:
        return "مستعجل";
      case ServiceType.NORMAL:
        return "عادي";
    }
  }

  String get labelEn {
    switch (this) {
      case ServiceType.FAST:
        return "Fast";
      case ServiceType.NORMAL:
        return "Normal";
    }
  }

  /// Automatically returns the correct label based on locale
  String get label {
    final isArabic = Get.locale?.languageCode == "ar";
    return isArabic ? labelAr : labelEn;
  }
}

class Status {
  int id;
  String key;
  String nameEn;
  String nameAr;

  Status({
    required this.id,
    required this.key,
    required this.nameEn,
    required this.nameAr,
  });

  factory Status.fromJson(Map<String, dynamic> json) => Status(
        id: json["id"],
        key: json["key"],
        nameEn: json["name_en"],
        nameAr: json["name_ar"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "key": key,
        "name_en": nameEn,
        "name_ar": nameAr,
      };
}

class User {
  int? userId;
  String? userName;
  double? wallet_balance;
  dynamic mobile;

  User({
    required this.userId,
    required this.userName,
    required this.wallet_balance,
    required this.mobile,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        userId: json.containsKey('customer_id')
            ? json["customer_id"]
            : json["user_id"] != null
                ? json["user_id"]
                : null,
        userName: json.containsKey('customer_name')
            ? json["customer_name"] ?? ""
            : json["user_name"] ?? "",
        wallet_balance: (json["wallet_balance"] as num? ?? 0.0).toDouble(),
        mobile: json["mobile"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "user_name": userName,
        "wallet_balance": wallet_balance,
        "mobile": mobile,
      };
}

class Pagination {
  dynamic nextPageUrl;
  dynamic prevPageUrl;
  int pagesCount;
  int totalOrders;

  Pagination({
    required this.nextPageUrl,
    required this.prevPageUrl,
    required this.pagesCount,
    required this.totalOrders,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        nextPageUrl: json["next_page_url"],
        prevPageUrl: json["prev_page_url"],
        pagesCount: json["pages_count"],
        totalOrders: json["total_orders"],
      );

  Map<String, dynamic> toJson() => {
        "next_page_url": nextPageUrl,
        "prev_page_url": prevPageUrl,
        "pages_count": pagesCount,
        "total_orders": totalOrders,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}

class PaymentDetails {
  String? paymentType;
  String? paymentTypeAr;
  bool is_split;
  String? split_payment_type;
  String? split_payment_type_ar;
  String? split_amount;
  double? first_amount;
  String? nearpay_card_type;
  double? customer_total_loan;
  List<WalletTransaction>? walletTransaction;

  PaymentDetails({
    this.paymentType,
    this.paymentTypeAr,
    this.is_split = false, // Default value for safety
    this.split_payment_type,
    this.split_payment_type_ar,
    this.split_amount,
    this.first_amount,
    this.nearpay_card_type,
    this.customer_total_loan,
    this.walletTransaction,
  });

  factory PaymentDetails.fromJson(Map<String, dynamic> json) => PaymentDetails(
        paymentType: json["payment_type"],
        paymentTypeAr: json["payment_type_ar"],
        is_split: json["is_split"] ?? false,
        split_payment_type: json["split_payment_type"],
        split_payment_type_ar: json["split_payment_type_ar"],
        // Safe conversion to double
        split_amount: json["split_amount"],
        first_amount: json["first_amount"]?.toDouble(),
        nearpay_card_type: json["nearpay_card_type"],
        customer_total_loan: json["customer_total_loan"]?.toDouble(),
        // Improved List mapping

        // Safety check for List: ensures it's actually a list before mapping
        walletTransaction: (json["wallet_transactions"] is List)
            ? List<WalletTransaction>.from(
                json["wallet_transactions"].map(
                  (x) => WalletTransaction.fromJson(x),
                ),
              )
            : null,
      );

  Map<String, dynamic> toJson() => {
        "payment_type": paymentType,
        "payment_type_ar": paymentTypeAr,
        "is_split": is_split,
        "split_payment_type": split_payment_type,
        "split_payment_type_ar": split_payment_type_ar,
        "split_amount": split_amount,
        "first_amount": first_amount,
        "nearpay_card_type": nearpay_card_type,
        "customer_total_loan": customer_total_loan,
        "wallet_transactions": walletTransaction == null
            ? null
            : List<dynamic>.from(walletTransaction!.map((x) => x.toJson())),
      };
}

class WalletTransaction {
  int id;
  String transactionType;
  String payment_method;
  String amount;
  String description;
  String paymentStatus;
  DateTime createdAt;

  WalletTransaction({
    required this.id,
    required this.transactionType,
    required this.payment_method,
    required this.amount,
    required this.description,
    required this.paymentStatus,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) => WalletTransaction(
        id: json["id"],
        transactionType: json["transaction_type"],
        payment_method: json["payment_method"],
        amount: json["amount"],
        description: json["description"],
        paymentStatus: json["payment_status"],
        createdAt: DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "transaction_type": transactionType,
        "payment_method": payment_method,
        "amount": amount,
        "description": description,
        "payment_status": paymentStatus,
        "created_at": createdAt.toIso8601String(),
      };
}

class ActivityLog {
  String statusKey;
  String nameAr;
  String nameEn;
  String date;
  String time;

  ActivityLog(
      {required this.statusKey,
      required this.nameEn,
      required this.nameAr,
      required this.date,
      required this.time});

  factory ActivityLog.fromJson(Map<String, dynamic> json) => ActivityLog(
        statusKey: json['status_key'],
        nameEn: json['name_en'],
        nameAr: json['name_ar'],
        date: json['date'],
        time: json['time'],
      );

//
// ActivityLog copyWith({ String statusKey,
// String nameEn,
// String nameAr,
// String date,
// String time,
// }) => ActivityLog( statusKey: statusKey ?? statusKey,
// nameEn: nameEn ?? nameEn,
// nameAr: nameAr ?? nameAr,
// date: date ?? date,
// time: time ?? time,
// );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status_key'] = statusKey;
    map['name_en'] = nameEn;
    map['name_ar'] = nameAr;
    map['date'] = date;
    map['time'] = time;
    return map;
  }
}
