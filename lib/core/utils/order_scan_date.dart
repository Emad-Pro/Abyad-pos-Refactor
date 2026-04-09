import 'package:flutter/material.dart';


class OrderScanDate {
  final String orderId;
  final DateTime scanDate;

  OrderScanDate({required this.orderId, required this.scanDate});
}

class OrderManager {
  final List<OrderScanDate> _orders = [];

  // bool addOrder(BuildContext context, String orderId) {
  //   final now = DateTime.now();
  //   //
  //   // // Find if this order already exists
  //   // final existing = _orders.where((o) => o.orderId == orderId).toList();
  //   //
  //   // if (existing.isNotEmpty) {
  //   //   final lastScan = existing.first.scanDate;
  //   //   final diff = now.difference(lastScan);
  //   //
  //   //   if (diff.inSeconds < 30) {
  //   //     final remaining = Duration(seconds: 30 - diff.inSeconds);
  //   //
  //   //     UIHelper.showBottomFlash(
  //   //       context,
  //   //       message: "please_wait".tr,
  //   //       title: "scan_again".tr+" ${remaining.inSeconds} "+"second".tr,
  //   //       isError: true,
  //   //     );
  //   //     return false; // stop here
  //   //   } else {
  //   //     _orders.removeWhere((o) => o.orderId == orderId);
  //   //
  //   //     return true;
  //   //     // More than 30 sec, update the scan date
  //   //   }
  //   // }
  //
  //   // Add fresh scan
  //   _orders.add(OrderScanDate(orderId: orderId, scanDate: now));
  //   return true;
  // }
  bool addOrder(BuildContext context, String orderId) {
    final now = DateTime.now();

    // 1. Remove the old entry if it exists (prevents duplicates in the list)
    _orders.removeWhere((o) => o.orderId == orderId);

    // 2. Add the fresh scan date
    _orders.add(OrderScanDate(orderId: orderId, scanDate: now));

    // 3. Always allow the order to proceed
    return true;
  }
}
