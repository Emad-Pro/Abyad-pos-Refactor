// lib/helpers/service_labels.dart

import 'package:abyadpos_tab/features/home/data/models/clothes_model.dart';

/// What kinds of services we offer
enum ServiceType {
  washAndIron,
  ironOnly,
  dryCleaning,
}

/// How fast the service is
enum SpeedType {
  normal,
  express,
}

/// Human-readable labels for ServiceType
extension ServiceTypeLabel on ServiceType {
  String get label {
    switch (this) {
      case ServiceType.washAndIron:
        return 'Wash & Iron';
      case ServiceType.ironOnly:
        return 'Iron Only';
      case ServiceType.dryCleaning:
        return 'Dry Cleaning';
    }
  }
}

/// Human-readable labels for SpeedType
extension SpeedTypeLabel on SpeedType {
  String get label {
    switch (this) {
      case SpeedType.normal:
        return 'Normal';
      case SpeedType.express:
        return 'Express';
    }
  }
}

/// Extension on your Cloth model to generate the service labels
extension ClothServiceLabels on Cloth {
  /// Returns a list of strings like:
  ///  - "Wash & Iron - Normal"
  ///  - "Wash & Iron - Express"
  ///  - "Iron Only - Normal"
  ///  - "Iron Only - Express"
  /// or, if ironing is not supported:
  ///  - "Dry Cleaning - Normal"
  ///  - "Dry Cleaning - Express"
  List<String> get serviceLabels {
    // Determine which base services apply
    final types = supportIroning
        ? [ServiceType.washAndIron, ServiceType.ironOnly]
        : [ServiceType.dryCleaning];

    // Pair each service with both speeds
    return types
        .expand((svc) =>
            SpeedType.values.map((spd) => '${svc.label} - ${spd.label}'))
        .toList();
  }
}
