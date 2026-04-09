// import 'package:flutter/services.dart';
//
// class NativeSDK {
//   static const _channel = MethodChannel('com.example/native_sdk');
//
//   static Future<void> initialize() async {
//     await _channel.invokeMethod('initializeSDK');
//   }
//
//   /// Creates a purchase request and waits for the final response.
//   static Future<Map<String, dynamic>?> createPurchaseRequest(String amount) async {
//     final result = await _channel.invokeMethod('createPurchaseRequest', {
//       'amount': amount,
//     });
//     if (result == null) return null;
//
//     final map = Map<String, dynamic>.from(result);
//     final statusCode = map['transactionStatus'] as int?;
//     map['transactionStatusText'] = _mapTransactionStatus(statusCode);
//     return map;
//   }
//
//   static String _mapTransactionStatus(int? code) {
//     switch (code) {
//       case 0:
//         return "Approved";
//       case 1:
//         return "Offline Approved";
//       case -1:
//         return "Declined";
//       case -2:
//         return "Timeout";
//       case -3:
//         return "Cancelled";
//       case -4:
//         return "EMV Rejected";
//       case -5:
//         return "Manual Entry Cancelled";
//       case -6:
//         return "Application Error";
//       default:
//         return "Unknown";
//     }
//   }
// }