import 'dart:convert';

NotificationModel notificationModelFromJson(String str) =>
    NotificationModel.fromJson(json.decode(str));

String notificationModelToJson(NotificationModel data) => json.encode(data.toJson());

class NotificationModel {
  int id;
  String title;
  String body;
  Data data;
  bool isRead;
  dynamic readAt;
  DateTime createdAt;
  String type;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.data,
    required this.isRead,
    required this.readAt,
    required this.createdAt,
    required this.type,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
        id: json["id"],
        title: json["title"],
        body: json["body"],
        data: Data.fromJson(json["data"]),
        isRead: json["is_read"],
        readAt: json["read_at"],
        createdAt: DateTime.parse(json["created_at"]),
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "body": body,
        "data": data.toJson(),
        "is_read": isRead,
        "read_at": readAt,
        "created_at": createdAt.toIso8601String(),
        "type": type,
      };
}

class Data {
  String orderId;
  String status;

  Data({
    required this.orderId,
    required this.status,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        orderId: json["order_id"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "order_id": orderId,
        "status": status,
      };
}
