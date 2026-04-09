// To parse this JSON data, do
//
//     final profileModel = profileModelFromJson(jsonString);

import 'dart:convert';

ProfileModel profileModelFromJson(String str) =>
    ProfileModel.fromJson(json.decode(str));

String profileModelToJson(ProfileModel data) => json.encode(data.toJson());

class ProfileModel {
  bool status;
  Data data;
  String message;

  ProfileModel({
    required this.status,
    required this.data,
    required this.message,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
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
  String name;
  String? description;
  String? additionalInfo;
  String? location;
  String latitude;
  String longitude;
  String? phone;
  OperatingHours operatingHours;
  String? logo;

  Data({
    required this.name,
    required this.description,
    required this.additionalInfo,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.operatingHours,
    required this.logo,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        name: json["name"],
        description: json["description"],
        additionalInfo: json["additional_info"] ?? "",
        location: json["location"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        phone:json["phone"],
        operatingHours: OperatingHours.fromJson(json["operating_hours"]),
        logo: json["logo"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "description": description,
        "additional_info": additionalInfo,
        "location": location,
        "latitude": latitude,
        "longitude": longitude,
        "phone":phone,
        "operating_hours": operatingHours.toJson(),
        "logo": logo,
      };
}

class OperatingHours {
  String startAt;
  String endAt;

  OperatingHours({
    required this.startAt,
    required this.endAt,
  });

  factory OperatingHours.fromJson(Map<String, dynamic> json) => OperatingHours(
        startAt: json["start_at"],
        endAt: json["end_at"],
      );

  Map<String, dynamic> toJson() => {
        "start_at": startAt,
        "end_at": endAt,
      };
}
