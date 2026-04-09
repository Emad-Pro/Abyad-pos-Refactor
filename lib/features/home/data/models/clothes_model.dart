// To parse this JSON data, do
//
//     final clothsModel = clothsModelFromJson(jsonString);

import 'dart:convert';


ClothsModel clothsModelFromJson(String str) =>
    ClothsModel.fromJson(json.decode(str));

String clothsModelToJson(ClothsModel data) => json.encode(data.toJson());

class ClothsModel {
  bool success;
  Data data;
  String message;

  ClothsModel({
    required this.success,
    required this.data,
    required this.message,
  });

  factory ClothsModel.fromJson(Map<String, dynamic> json) => ClothsModel(
        success: json["status"],
        data: Data.fromJson(json["data"]),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": success,
        "data": data.toJson(),
        "message": message,
      };
}

class Data {
  List<Cloth> clothes;
 // Pagination pagination;

  Data({
    required this.clothes,
  //  required this.pagination,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        clothes:
            List<Cloth>.from(json["clothes"].map((x) => Cloth.fromJson(x))),
     //   pagination: Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
        "clothes": List<dynamic>.from(clothes.map((x) => x.toJson())),
      //  "pagination": pagination.toJson(),
      };
}

class Cloth {
  int id;
  String nameEn;
  String nameAr;
  String image;
  bool supportIroning;
  bool is_active;
  Prices prices;
  int? sort_order;
  int? clothCountes;
  int? clothCountesOnly;
  int? fclothCountes;
  int? fclothCountesOnly;
  bool? isSetOnlyIroning;
  bool? isCustomized;
  String? details;
  double? custom_price_per_unit;
  double? total_custom_price;
  String? serviceType;
  Cloth(
      {required this.id,
      required this.nameEn,
      required this.nameAr,
      required this.image,
      required this.supportIroning,
        required this.is_active,
      required this.prices,
        required this.sort_order,

      this.clothCountes,
      this.clothCountesOnly,
      this.fclothCountes,
      this.fclothCountesOnly,
        this.isCustomized,
        this.details,
        this.custom_price_per_unit,
        this.total_custom_price,
        this.serviceType,}) {
    this.clothCountes = 0;
    this.clothCountesOnly = 0;
    this.fclothCountes = 0;
    this.fclothCountesOnly = 0;
    this.isSetOnlyIroning = false;

    isCustomized ??= false;
    details ??= "";
    custom_price_per_unit ??= 0.0;
    total_custom_price ??= 0.0;
    this.serviceType;
  }


  factory Cloth.fromJson(Map<String, dynamic> json) => Cloth(
        id: json["id"],
        nameEn: json["name_en"],
        nameAr: json["name_ar"],
        image: json["image"],
        supportIroning: json["support_ironing"],
    is_active: json["is_active"],
    sort_order:json["sort_order"],
    serviceType: json["service_type"],
    prices: Prices.fromJson(json["prices"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name_en": nameEn,
        "name_ar": nameAr,
        "image": image,
        "support_ironing": supportIroning,
        "is_active":is_active,
        "sort_order":sort_order,
        "prices": prices.toJson(),
    "service_type": serviceType,
      };

  @override
  String toString() {
    return '''
Cloth(
  id: $id,
  nameEn: $nameEn,
  nameAr: $nameAr,
  image: $image,
  supportIroning: $supportIroning,
  is_active: $is_active,
  sort_order: $sort_order,
  clothCountes: $clothCountes,
  clothCountesOnly: $clothCountesOnly,
  fclothCountes: $fclothCountes,
  fclothCountesOnly: $fclothCountesOnly,
  isSetOnlyIroning: $isSetOnlyIroning,
  isCustomized: $isCustomized,
  details: $details,
  custom_price_per_unit: $custom_price_per_unit,
  total_custom_price: $total_custom_price,
   serviceType: $serviceType
)
''';
  }
}

class Prices {
  String? priceIroning;
  String? priceCleaningAndIroning;
  String? priceFastIroning;
  String? priceFastCleaningAndIroning;
  String? priceCleaning;
  String? priceFastCleaning;

  Prices({
    this.priceIroning,
    this.priceCleaningAndIroning,
    this.priceFastIroning,
    this.priceFastCleaningAndIroning,
    this.priceCleaning,
    this.priceFastCleaning,
  });

  factory Prices.fromJson(Map<String, dynamic> json) => Prices(
        priceIroning: json["price_ironing"],
        priceCleaningAndIroning: json["price_cleaning_and_ironing"],
        priceFastIroning: json["price_fast_ironing"],
        priceFastCleaningAndIroning: json["price_fast_cleaning_and_ironing"],
        priceCleaning: json["price_cleaning"],
        priceFastCleaning: json["price_fast_cleaning"],
      );

  Map<String, dynamic> toJson() => {
        "price_ironing": priceIroning,
        "price_cleaning_and_ironing": priceCleaningAndIroning,
        "price_fast_ironing": priceFastIroning,
        "price_fast_cleaning_and_ironing": priceFastCleaningAndIroning,
        "price_cleaning": priceCleaning,
        "price_fast_cleaning": priceFastCleaning,
      };
}

class Pagination {
  dynamic nextPageUrl;
  dynamic prevPageUrl;
  int pagesCount;
  int totalClothes;

  Pagination({
    required this.nextPageUrl,
    required this.prevPageUrl,
    required this.pagesCount,
    required this.totalClothes,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        nextPageUrl: json["next_page_url"],
        prevPageUrl: json["prev_page_url"],
        pagesCount: json["pages_count"],
        totalClothes: json["total_clothes"],
      );

  Map<String, dynamic> toJson() => {
        "next_page_url": nextPageUrl,
        "prev_page_url": prevPageUrl,
        "pages_count": pagesCount,
        "total_clothes": totalClothes,
      };
}
