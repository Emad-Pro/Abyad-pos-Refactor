import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class StatisticsCards extends StatelessWidget {
  // Summary data
  final int ordersCount;
  final int ordersInProgressCount;
  final int ordersReadyForPickupCount;
  final int ordersPickedUpCount;
  final double totalOrdersPrice;
  final double totalOrdersPriceNearpay;
  final double totalOrdersPriceCash;
  final double totalOrdersPriceCreditCard;
  final double totalOrdersPriceLoan;
  final double totalOrdersPriceWallet;
  final double totalOrdersPriceUnpaid;
  final double ordersInProgressAmount;
  final double ordersReadyForPickupAmount;
  final double ordersPickedUpAmount;

  // Settlement data
  final double pendingSettlementAmount;
  final double unrequestedAmount;
  final int unrequestedOrdersCount;
  final double totalSettled;

  const StatisticsCards({
    Key? key,
    required this.ordersCount,
    required this.ordersInProgressCount,
    required this.ordersReadyForPickupCount,
    required this.ordersPickedUpCount,
    required this.totalOrdersPrice,
    required this.totalOrdersPriceNearpay,
    required this.totalOrdersPriceCash,
    required this.totalOrdersPriceCreditCard,
    required this.totalOrdersPriceLoan,
    required this.totalOrdersPriceWallet,
    required this.totalOrdersPriceUnpaid,
    required this.ordersInProgressAmount,
    required this.ordersReadyForPickupAmount,
    required this.ordersPickedUpAmount,
    required this.pendingSettlementAmount,
    required this.unrequestedAmount,
    required this.unrequestedOrdersCount,
    required this.totalSettled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [


        // Section 1: Settlement Information
        Text(
          "settlement_information".tr,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            // Pending Settlement (only shown if > 0)
            if (pendingSettlementAmount > 0) ...[
              Expanded(
                child: _buildPendingSettlementCard(
                  title: "pending_settlement_amount".tr,
                  value: "${pendingSettlementAmount.toStringAsFixed(2)} ${"sar".tr}",
                ),
              ),
              SizedBox(width: 16.w),
            ],
            Expanded(
              child: _buildStatCard(
                title: "unrequested_amount".tr,
                value: "${unrequestedAmount.toStringAsFixed(2)} ${"sar".tr}",
                subtitle: "$unrequestedOrdersCount ${"orders".tr}",
                icon: Icons.sync_rounded,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildStatCard(
                title: "total_settled".tr,
                value: "${totalSettled.toStringAsFixed(2)} ${"sar".tr}",
                icon: Icons.check_circle_outline_rounded,
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        // Section 2: Orders Overview
        Text(
          "orders_overview".tr,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: "total_orders".tr,
                value: ordersCount.toString(),
                subtitle: "${totalOrdersPrice.toStringAsFixed(2)} ${"sar".tr}",
                icon: Icons.receipt_long_rounded,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildStatCard(
                title: "orders_in_progress".tr,
                value: ordersInProgressCount.toString(),
                subtitle: "${ordersInProgressAmount.toStringAsFixed(2)} ${"sar".tr}",
                icon: Icons.hourglass_empty_rounded,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildStatCard(
                title: "orders_ready_for_pickup".tr,
                value: ordersReadyForPickupCount.toString(),
                subtitle: "${ordersReadyForPickupAmount.toStringAsFixed(2)} ${"sar".tr}",
                icon: Icons.done_all_rounded,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildStatCard(
                title: "delivered_orders".tr,
                value: ordersPickedUpCount.toString(),
                subtitle: "${ordersPickedUpAmount.toStringAsFixed(2)} ${"sar".tr}",
                icon: Icons.check_circle_rounded,
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),

        // Section 3: Financial Overview
        Text(
          "financial_overview".tr,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: "total_value_of_all_orders".tr,
                value: "${totalOrdersPrice.toStringAsFixed(2)} ${"sar".tr}",
                icon: Icons.account_balance_wallet_rounded,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildStatCard(
                title: "abyad_pay_orders_value".tr,
                value: "${totalOrdersPriceNearpay.toStringAsFixed(2)} ${"sar".tr}",
                icon: Icons.contactless_rounded,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildStatCard(
                title: "credit_card_orders_value".tr,
                value: "${totalOrdersPriceCreditCard.toStringAsFixed(2)} ${"sar".tr}",
                icon: Icons.credit_card_rounded,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildStatCard(
                title: "cash_orders_value".tr,
                value: "${totalOrdersPriceCash.toStringAsFixed(2)} ${"sar".tr}",
                icon: Icons.payments_rounded,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: "wallet_orders_value".tr,
                value: "${totalOrdersPriceWallet.toStringAsFixed(2)} ${"sar".tr}",
                icon: Icons.account_balance_wallet_outlined,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildStatCard(
                title: "outstanding_debt_amount".tr,
                value: "${totalOrdersPriceLoan.toStringAsFixed(2)} ${"sar".tr}",
                icon: Icons.warning_amber_rounded,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildStatCard(
                title: "unpaid_orders_value".tr,
                value: "${totalOrdersPriceUnpaid.toStringAsFixed(2)} ${"sar".tr}",
                icon: Icons.pending_actions_rounded,
              ),
            ),
          ],
        ),

      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
  }) {
    return Container(
      height: 150.h,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFF2196F3).withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2196F3).withOpacity(0.1),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Color(0xFF2196F3),
                  size: 24,
                ),
              ),
            ],
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: Color(0xFF1565C0),
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 6.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingSettlementCard({
    required String title,
    required String value,
  }) {
    return Container(
      height: 150.h,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[400]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.schedule_rounded,
                  color: Colors.grey[600],
                  size: 24,
                ),
              ),
            ],
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}