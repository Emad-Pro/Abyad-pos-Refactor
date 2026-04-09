// // To parse this JSON data, do
// //
// //     final orderModel = orderModelFromJson(jsonString);

// import 'dart:convert';

// OrderModel orderModelFromJson(String str) =>
//     OrderModel.fromJson(json.decode(str));

// String orderModelToJson(OrderModel data) => json.encode(data.toJson());

// class OrderModel {
//   bool status;
//   Data data;
//   String message;

//   OrderModel({
//     required this.status,
//     required this.data,
//     required this.message,
//   });

//   factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
//         status: json["status"],
//         data: Data.fromJson(json["data"]),
//         message: json["message"],
//       );

//   Map<String, dynamic> toJson() => {
//         "status": status,
//         "data": data.toJson(),
//         "message": message,
//       };
// }

// class Data {
//   List<Order> orders;
//   Pagination pagination;

//   Data({
//     required this.orders,
//     required this.pagination,
//   });

//   factory Data.fromJson(Map<String, dynamic> json) => Data(
//         orders: List<Order>.from(json["orders"].map((x) => Order.fromJson(x))),
//         pagination: Pagination.fromJson(json["pagination"]),
//       );

//   Map<String, dynamic> toJson() => {
//         "orders": List<dynamic>.from(orders.map((x) => x.toJson())),
//         "pagination": pagination.toJson(),
//       };
// }

// class Order {
//   String id;
//   DateTime createdAt;
//   DateTime updatedAt;
//   List<Clothe> clothes;
//   User user;
//   Status status;
//   String orderType;
//   int totalItemCount;
//   dynamic address;
//   dynamic lat;
//   dynamic lng;
//   String totalPrice;

//   Order({
//     required this.id,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.clothes,
//     required this.user,
//     required this.status,
//     required this.orderType,
//     required this.totalItemCount,
//     required this.address,
//     required this.lat,
//     required this.lng,
//     required this.totalPrice,
//   });

//   factory Order.fromJson(Map<String, dynamic> json) => Order(
//         id: json["id"].toString(),
//         createdAt: DateTime.parse(json["created_at"]),
//         updatedAt: DateTime.parse(json["updated_at"]),
//         clothes:
//             List<Clothe>.from(json["clothes"].map((x) => Clothe.fromJson(x))),
//         user: User.fromJson(
//             json.containsKey('user') ? json["user"] : json['customer']),
//         status: Status.fromJson(json["status"]),
//         orderType: json["order_type"],
//         totalItemCount: json["total_item_count"],
//         address: json["address"],
//         lat: json["lat"],
//         lng: json["lng"],
//         totalPrice: json["total_price"] ?? "0",
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "created_at": createdAt.toIso8601String(),
//         "updated_at": updatedAt.toIso8601String(),
//         "clothes": List<dynamic>.from(clothes.map((x) => x.toJson())),
//         "user": user.toJson(),
//         "status": status.toJson(),
//         "order_type": orderType,
//         "total_item_count": totalItemCount,
//         "address": address,
//         "lat": lat,
//         "lng": lng,
//         "total_price": totalPrice,
//       };
// }

// class Clothe {
//   int clothId;
//   int clothCount;
//   String clothPrice;
//   String clothTotalPrice;
//   String serviceType;
//   int onlyIroning;
//   String clothImage;

//   Clothe({
//     required this.clothId,
//     required this.clothCount,
//     required this.clothPrice,
//     required this.clothTotalPrice,
//     required this.serviceType,
//     required this.onlyIroning,
//     required this.clothImage,
//   });

//   factory Clothe.fromJson(Map<String, dynamic> json) => Clothe(
//         clothId: json["cloth_id"],
//         clothCount: json["cloth_count"],
//         clothPrice: json["cloth_price"],
//         clothTotalPrice: json["cloth_total_price"],
//         serviceType: json["service_type"] ?? "normal",
//         onlyIroning: json["only_ironing"],
//         clothImage: json["cloth_image"],
//       );

//   Map<String, dynamic> toJson() => {
//         "cloth_id": clothId,
//         "cloth_count": clothCount,
//         "cloth_price": clothPrice,
//         "cloth_total_price": clothTotalPrice,
//         "service_type": serviceType,
//         "only_ironing": onlyIroning,
//         "cloth_image": clothImage,
//       };
// }

// enum ServiceType { FAST, NORMAL }

// final serviceTypeValues =
//     EnumValues({"fast": ServiceType.FAST, "normal": ServiceType.NORMAL});

// class Status {
//   int id;
//   String key;
//   String nameEn;
//   String nameAr;

//   Status({
//     required this.id,
//     required this.key,
//     required this.nameEn,
//     required this.nameAr,
//   });

//   factory Status.fromJson(Map<String, dynamic> json) => Status(
//         id: json["id"],
//         key: json["key"],
//         nameEn: json["name_en"],
//         nameAr: json["name_ar"],
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "key": key,
//         "name_en": nameEn,
//         "name_ar": nameAr,
//       };
// }

// class User {
//   int userId;
//   String userName;
//   dynamic mobile;

//   User({
//     required this.userId,
//     required this.userName,
//     required this.mobile,
//   });

//   factory User.fromJson(Map<String, dynamic> json) => User(
//         userId: json.containsKey('customer_id')
//             ? json["customer_id"]
//             : json["user_id"],
//         userName: json.containsKey('customer_name')
//             ? json["customer_name"] ?? ""
//             : json["user_name"] ?? "",
//         mobile: json["mobile"],
//       );

//   Map<String, dynamic> toJson() => {
//         "user_id": userId,
//         "user_name": userName,
//         "mobile": mobile,
//       };
// }

// class Pagination {
//   dynamic nextPageUrl;
//   dynamic prevPageUrl;
//   int pagesCount;
//   int totalOrders;

//   Pagination({
//     required this.nextPageUrl,
//     required this.prevPageUrl,
//     required this.pagesCount,
//     required this.totalOrders,
//   });

//   factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
//         nextPageUrl: json["next_page_url"],
//         prevPageUrl: json["prev_page_url"],
//         pagesCount: json["pages_count"],
//         totalOrders: json["total_orders"],
//       );

//   Map<String, dynamic> toJson() => {
//         "next_page_url": nextPageUrl,
//         "prev_page_url": prevPageUrl,
//         "pages_count": pagesCount,
//         "total_orders": totalOrders,
//       };
// }

// class EnumValues<T> {
//   Map<String, T> map;
//   late Map<T, String> reverseMap;

//   EnumValues(this.map);

//   Map<T, String> get reverse {
//     reverseMap = map.map((k, v) => MapEntry(v, k));
//     return reverseMap;
//   }
// }
