class UserModel {
  bool status;
  Data data;
  String message;
  AppVersion? appVersion; // ✅ optional app version

  UserModel({
    required this.status,
    required this.data,
    required this.message,
    this.appVersion,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    status: json["status"],
    data: Data.fromJson(json["data"]),
    message: json["message"],
    appVersion: json["app_version"] != null
        ? AppVersion.fromJson(json["app_version"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data.toJson(),
    "message": message,
    if (appVersion != null) "app_version": appVersion!.toJson(),
  };

  @override
  String toString() {
    return 'UserModel(status: $status, data: $data, message: $message, appVersion: $appVersion)';
  }
}

class Data {
  String token;
  String name;
  String? phone;
  String laundryName;
  String? laundryNameAr;
  String? description;
  String? additionalInfo;
  String? bill_footer_en;
  String? bill_footer_ar;
  String?loan_limit;

  String? address;

  String? location;
  String lat;
  String lng;
  OperatingHours operatingHours;
  String? logo;
  bool vat_enabled;
  bool products_need_setup;
  bool loan_active;
  bool stats_enabled;
  bool stats_locked;
  bool enable_top_up_wallet;
  bool second_bill_enabled;
  bool bill_en_ar;
  bool is_long_bill;
  bool nearpay_status;
  String? vat_number;
  String?stats_password;
  String? laundry_account_establish_date;
  String? nearpay_token;


  dynamic email;

  Data(
      {required this.token,
        required this.name,
        required this.phone,
        required this.laundryName,
        required this.laundryNameAr,
        required this.description,
        required this.address,
        required this.additionalInfo,
        required this.bill_footer_en,
        required this.bill_footer_ar,
        required this.loan_limit,
        required this.location,
        required this.lat,
        required this.lng,
        required this.operatingHours,
        required this.logo,
        required this.vat_enabled,
        required this.products_need_setup,
        required this.loan_active,
        required this.vat_number,
        required this.stats_enabled,
        required this.stats_locked,
        required this.stats_password,
        required this.enable_top_up_wallet,
        required this.second_bill_enabled,
        required this.is_long_bill,
        required this.bill_en_ar,
        required this.laundry_account_establish_date,
        required this.nearpay_status,
        required this.nearpay_token,

        this.email});
  static bool toBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return false;
  }
  factory Data.fromJson(Map<String, dynamic> json) => Data(
    token: json["token"],
    name: json["name"],
    phone: json["phone"] != null ? json["phone"] : "",
    laundryName: json["laundry_name"],
    laundryNameAr:
    json["laundry_name_ar"] != null ? json["laundry_name_ar"] : "",
    description: json["description"] != null ? json["description"] : "",
    address: json["address"] != null ? json["address"] : null,
    additionalInfo:
    json["additional_info"] != null ? json["additional_info"] : "",
    bill_footer_ar:  json["bill_footer_ar"] != null ? json["bill_footer_ar"] : null,
    loan_limit: json["loan_limit"] != null ? json["loan_limit"] : null,
    bill_footer_en:  json["bill_footer_en"] != null ? json["bill_footer_en"] : null,

    email: json['email'] ?? "",
    location: json["location"] != null ? json["location"] : "",
    lat: json["lat"],
    lng: json["lng"],
    operatingHours: OperatingHours.fromJson(json["operating_hours"]),
    logo: json["logo"],
    vat_enabled:toBool(json['vat_enabled']),
    products_need_setup:toBool(json['products_need_setup']),
    loan_active: toBool(json['loan_active']),
    vat_number: json["vat_number"] != null ? json["vat_number"] : "",
    nearpay_status:  toBool(json['nearpay_status']),
    laundry_account_establish_date: json["laundry_account_establish_date"] ,
    second_bill_enabled: toBool(json['second_bill_enabled']),
      is_long_bill: toBool(json['is_long_bill']),
    bill_en_ar:  toBool(json['bill_en_ar']),

    stats_enabled:   toBool(json['stats_enabled']),
    stats_locked:  toBool(json['stats_locked']),
    stats_password: json["stats_password"] != null ? json["stats_password"] : "",

    enable_top_up_wallet:  toBool(json['enable_top_up_wallet']),

    nearpay_token: json["nearpay_token"] != null ? json["nearpay_token"] : "",
  );

  Map<String, dynamic> toJson() => {
    "token": token,
    "name": name,
    "email": email,
    "phone": phone,
    "laundry_name": laundryName,
    "laundry_name_ar": laundryNameAr,
    "description": description,
    "address":address,
    "additional_info": additionalInfo,
    "bill_footer_en":bill_footer_en,
    "bill_footer_ar":bill_footer_ar,
    "loan_limit":loan_limit,
    "location": location,
    "lat": lat,
    "lng": lng,
    "products_need_setup": products_need_setup ? 1 : 0,
    "loan_active": loan_active ? 1 : 0,
    "vat_enabled": vat_enabled ? 1 : 0,
    "vat_number": vat_number,
    "stats_enabled": stats_enabled ? 1 : 0,
    "stats_locked": stats_locked ? 1 : 0,
    "stats_password": stats_password,
    "enable_top_up_wallet":enable_top_up_wallet?1:0,
    "second_bill_enabled":second_bill_enabled?1:0,
    "is_long_bill":is_long_bill?1:0,
    "bill_en_ar":bill_en_ar?1:0,
    "nearpay_status": nearpay_status ? 1 : 0,
    "operating_hours": operatingHours.toJson(),
    "logo": logo,
    "nearpay_token": nearpay_token,
  };

  @override
  String toString() {
    return 'Data(token: $token, name: $name, phone: $phone, laundryName: $laundryName, laundryNameAr: $laundryNameAr, description: $description,address:$address, additionalInfo: $additionalInfo,bill_footer_en:$bill_footer_en,bill_footer_ar:$bill_footer_ar,loan_limit:$loan_limit, location: $location, lat: $lat, lng: $lng, operatingHours: $operatingHours, logo: $logo, vat_enabled: $vat_enabled, products_need_setup: $products_need_setup, loan_active: $loan_active, vat_number: $vat_number, stats_enabled: $stats_enabled,stats_locked:$stats_locked,stats_password:$stats_password, enable_top_up_wallet:$enable_top_up_wallet, second_bill_enabled:$second_bill_enabled,is_long_bill:$is_long_bill,bill_en_ar:$bill_en_ar, laundry_account_establish_date: $laundry_account_establish_date, nearpay_status: $nearpay_status, nearpay_token: $nearpay_token, email: $email)';
  }
}

extension DataCopyWith on Data {
  Data copyWith({
    String? token,
    String? name,
    String? phone,
    String? laundryName,
    String? laundryNameAr,
    String? description,
    String? address,
    String? additionalInfo,
    String? bill_footer_ar,
    String?loan_limit,
    String? bill_footer_en,
    String? location,
    String? lat,
    String? lng,
    OperatingHours? operatingHours,
    String? logo,
    bool? vat_enabled,
    bool? products_need_setup,
    bool? loan_active,
    String? vat_number,
    bool? stats_enabled,
    bool? stats_locked,
    String?stats_password,
    bool?enable_top_up_wallet,
    bool?second_bill_enabled,
    bool?is_long_bill,
    bool?bill_en_ar,
    String? laundry_account_establish_date,
    bool? nearpay_status,
    String? nearpay_token,
    dynamic email,
  }) {
    return Data(
      token: token ?? this.token,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      laundryName: laundryName ?? this.laundryName,
      laundryNameAr: laundryNameAr ?? this.laundryNameAr,
      description: description ?? this.description,
      address:address??this.address,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      bill_footer_ar:bill_footer_ar?? this.bill_footer_ar,
      loan_limit:loan_limit??this.loan_limit,
      bill_footer_en:bill_footer_en?? this.bill_footer_en,
      location: location ?? this.location,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      operatingHours: operatingHours ?? this.operatingHours,
      logo: logo ?? this.logo,
      vat_enabled: vat_enabled ?? this.vat_enabled,
      products_need_setup: products_need_setup ?? this.products_need_setup,
      loan_active: loan_active ?? this.loan_active,
      vat_number:  vat_number ?? this.vat_number,
      stats_enabled: stats_enabled ?? this.stats_enabled,
      stats_locked: stats_locked ?? this.stats_locked,
      stats_password: stats_password ?? this.stats_password,
      enable_top_up_wallet:enable_top_up_wallet??this.enable_top_up_wallet,
      second_bill_enabled:second_bill_enabled??this.second_bill_enabled,
      is_long_bill:is_long_bill??this.is_long_bill,
      bill_en_ar:bill_en_ar??this.bill_en_ar,
      laundry_account_establish_date: laundry_account_establish_date ?? this.laundry_account_establish_date,
      nearpay_status: nearpay_status ?? this.nearpay_status,
      nearpay_token: nearpay_token ?? this.nearpay_token,
      email: email ?? this.email,
    );
  }
}
extension UserModelCopyWith on UserModel {
  UserModel copyWith({
    bool? status,
    Data? data,
    String? message,
    AppVersion? appVersion,
  }) {
    return UserModel(
      status: status ?? this.status,
      data: data ?? this.data,
      message: message ?? this.message,
      appVersion: appVersion ?? this.appVersion,
    );
  }
}
class AppVersion {
  final String? minSupportedVersion;
  final String? latest;
  final bool? force;
  final String? url;

  AppVersion({
    this.minSupportedVersion,
    this.latest,
    this.force,
    this.url,
  });

  factory AppVersion.fromJson(Map<String, dynamic> json) => AppVersion(
    minSupportedVersion: json['min_supported_version'],
    latest: json['latest'],
    force: json['force'],
    url: json['url'],
  );

  Map<String, dynamic> toJson() => {
    'min_supported_version': minSupportedVersion,
    'latest': latest,
    'force': force,
    'url': url,
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

  @override
  String toString() {
    return 'OperatingHours(startAt: $startAt, endAt: $endAt)';
  }
}
