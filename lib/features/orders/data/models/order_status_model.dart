// To parse this JSON data, do
//
//     final orderStatusModel = orderStatusModelFromJson(jsonString);

import 'dart:convert';

import 'package:abyadpos_tab/features/orders/data/models/order_model.dart';

OrderStatusModel orderStatusModelFromJson(String str) =>
    OrderStatusModel.fromJson(json.decode(str));

String orderStatusModelToJson(OrderStatusModel data) =>
    json.encode(data.toJson());

class OrderStatusModel {
  bool status;
  Data data;
  String message;

  OrderStatusModel({
    required this.status,
    required this.data,
    required this.message,
  });

  factory OrderStatusModel.fromJson(Map<String, dynamic> json) =>
      OrderStatusModel(
        status: json["status"],
        data: Data.fromJson(json["data"]),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data.toJson(),
        "message": message,
      };
}

class Data {
  String orderId;
  String orderType;
  Status currentStatus;
  List<Status> availableStatuses;

  Data({
    required this.orderId,
    required this.orderType,
    required this.currentStatus,
    required this.availableStatuses,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        orderId: json["order_id"] ?? "",
        orderType: json["order_type"],
        currentStatus: Status.fromJson(json["current_status"]),
        availableStatuses: List<Status>.from(
            json["available_statuses"].map((x) => Status.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "order_id": orderId,
        "order_type": orderType,
        "current_status": currentStatus.toJson(),
        "available_statuses":
            List<dynamic>.from(availableStatuses.map((x) => x.toJson())),
      };
}
