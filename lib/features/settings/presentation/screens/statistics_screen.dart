import 'package:abyadpos_tab/features/orders/presentation/controllers/order_cubit.dart';
import 'package:abyadpos_tab/features/auth/presentation/controllers/user_cubit.dart';
import 'package:abyadpos_tab/features/settings/presentation/widgets/statistics_card.dart';
import 'package:abyadpos_tab/features/settings/presentation/widgets/top_lists_widget.dart';
import 'package:abyadpos_tab/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import 'package:abyadpos_tab/features/orders/presentation/controllers/order_state.dart';
import 'package:abyadpos_tab/core/widgets/custom_drawer.dart';
import 'package:abyadpos_tab/features/home/presentation/widgets/custom_appbar.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _loading = true;
  bool _error = false;

  DateTime? _fromDate;
  DateTime? _toDate;

  final DateFormat _displayFormat = DateFormat('dd-MM-yyyy');
  final DateFormat _apiFormat = DateFormat('yyyy-MM-dd');

  int _tappedPaymentIndex = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchStats());
    DateTime _fromDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
    DateTime _toDate = DateTime.now();
  }

  Future<void> _fetchStats() async {
    setState(() {
      _loading = true;
      _error = false;
    });

    final cubit = BlocProvider.of<OrderCubit>(context, listen: false);
    try {
      await cubit.getPosStats(
        fromDate: _fromDate != null ? _apiFormat.format(_fromDate!) : null,
        toDate: _toDate != null ? _apiFormat.format(_toDate!) : null,
      );
      setState(() {
        _loading = false;
        _error = false;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F9FC),
      body: BlocBuilder<OrderCubit, OrderState>(
        builder: (
          context,
          state,
        ) {
          if (_loading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            );
          }

          if (_error || context.read<OrderCubit>().state.posStatsModel == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 10),
                  Text("Failed to retrieve data".tr,
                      style: TextStyle(fontSize: 18, color: Colors.red)),
                  const SizedBox(height: 16),
                  CustomButton(width: 200, () => _fetchStats(), text: "Retry".tr),
                ],
              ),
            );
          }
          final UserCubit cubit = BlocProvider.of<UserCubit>(context, listen: false);
          var userData = cubit.state.userModel?.data;
          bool isNearPayEnabled = userData?.nearpay_status ?? false;
          ;

          final stats = context.read<OrderCubit>().state.posStatsModel!;
          final cash = stats.paymentBreakdown?.totalCashAmount ?? 0;
          final credit = stats.paymentBreakdown?.totalCreditAmount ?? 0;
          final loan = stats.paymentBreakdown?.totalLoanAmount ?? 0;
          final pendingPayments = stats.paymentBreakdown?.totalNotPickedUp ?? 0;
          final totalPayment = cash + credit + loan + pendingPayments;

          final sales = stats.sales;
          final weeklySales = sales?.data ?? [];
          final maxSales = weeklySales.isNotEmpty
              ? weeklySales.map((e) => e.totalSales ?? 0).reduce((a, b) => a > b ? a : b)
              : 0;

          return Row(
            children: [
              const CustomSideMenu(),
              Expanded(
                child: Column(
                  children: [
                    CustomAppBar(
                      title: "statistics".tr,
                      isSearchable: false,
                      onSearch: (_) {},
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// 🔹 Header Bar with Filter
                            Card(
                              elevation: 3,
                              color: Colors.white,
                              // shadowColor: Colors.black12,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Back
                                    GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.arrow_back_ios,
                                              size: 18, color: Colors.blueAccent),
                                          const SizedBox(width: 6),
                                          Text("settings".tr,
                                              style: const TextStyle(
                                                  fontSize: 16, fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                                    ),

                                    // Date picker
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 300,
                                          child: GestureDetector(
                                            onTap: _selectDateRange,
                                            child: AbsorbPointer(
                                              child: TextFormField(
                                                decoration: InputDecoration(
                                                  labelText: "date_range".tr,
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  suffixIcon: const Icon(
                                                    Icons.calendar_today,
                                                    color: Colors.blueAccent,
                                                  ),
                                                ),
                                                controller:
                                                    TextEditingController(text: _formatDateRange()),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        // CustomButton(
                                        //         width: 100,
                                        //         () async {
                                        //   if (_fromDate == null) {
                                        //     ScaffoldMessenger.of(context)
                                        //         .showSnackBar( SnackBar(
                                        //       content: Text("please_select_at_least_a_start_date".tr),
                                        //     ));
                                        //     return;
                                        //   }
                                        //   final from = _apiFormat.format(_fromDate!);
                                        //   final to = _toDate != null ? _apiFormat.format(_toDate!) : null;
                                        //   await Provider.of<OrderViewModel>(context, listen: false)
                                        //       .getPosStats(fromDate: from, toDate: to);
                                        // }, text: "search".tr),
                                        // if(isArabic)

                                        if (isNearPayEnabled) ...[
                                          const SizedBox(width: 180),
                                          CustomButton(
                                            width: 160,
                                            context.read<OrderCubit>().state.isBalancingDisabled
                                                ? null
                                                : () async {
                                                    await context
                                                        .read<OrderCubit>()
                                                        .triggerBalancing(context);
                                                  },
                                            isDisable: context
                                                .read<OrderCubit>()
                                                .state
                                                .isBalancingDisabled,
                                            // Show "Requested (00:00:00)" when disabled, otherwise show "Request Balancing"
                                            text: context
                                                    .read<OrderCubit>()
                                                    .state
                                                    .isBalancingDisabled
                                                ? "${"balancing_requested".tr} (${context.read<OrderCubit>().state.remainingTimeText})"
                                                : "balancing_request".tr,
                                          )
                                        ] else ...[
                                          const SizedBox(width: 280),
                                        ],

                                        // if(!isArabic)
                                        //   const SizedBox(width: 150),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),
                            StatisticsCards(
                              // Summary data
                              ordersCount: stats.summary?.ordersCount ?? 0,
                              ordersInProgressCount: stats.summary?.ordersInProgressCount ?? 0,
                              ordersReadyForPickupCount:
                                  stats.summary?.ordersReadyForPickupCount ?? 0,
                              ordersPickedUpCount: stats.summary?.ordersPickedUpCount ?? 0,
                              totalOrdersPrice: stats.summary?.totalOrdersPrice ?? 0.0,
                              totalOrdersPriceNearpay:
                                  stats.summary?.totalOrdersPriceNearpay ?? 0.0,
                              totalOrdersPriceCash: stats.summary?.totalOrdersPriceCash ?? 0.0,
                              totalOrdersPriceCreditCard:
                                  stats.summary?.totalOrdersPriceCreditCard ?? 0.0,
                              totalOrdersPriceLoan: stats.summary?.totalOrdersPriceLoan ?? 0.0,
                              totalOrdersPriceWallet: stats.summary?.totalOrdersPriceWallet ?? 0.0,
                              totalOrdersPriceUnpaid: stats.summary?.totalOrdersPriceUnpaid ?? 0.0,
                              ordersInProgressAmount: stats.summary?.ordersInProgressAmount ?? 0.0,
                              ordersReadyForPickupAmount:
                                  stats.summary?.ordersReadyForPickupAmount ?? 0.0,
                              ordersPickedUpAmount: stats.summary?.ordersPickedUpAmount ?? 0.0,
                              // Settlement data
                              pendingSettlementAmount:
                                  stats.settlement?.pendingSettlementAmount ?? 0.0,
                              unrequestedAmount: stats.settlement?.unrequestedAmount ?? 0.0,
                              unrequestedOrdersCount: stats.settlement?.unrequestedOrdersCount ?? 0,
                              totalSettled: stats.settlement?.totalSettled ?? 0.0,
                            ),
                            // /// 🔹 Charts Section
                            //                   Row(
                            //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            //                     crossAxisAlignment: CrossAxisAlignment.start,
                            //                     children: [
                            //
                            //                       //
                            //                       // Line Chart
                            //                       Expanded(
                            //                         flex: 2,
                            //                         child: Container(
                            //                           height: 300, // fixed same as Pie chart
                            //                           padding: const EdgeInsets.all(12),
                            //                           decoration: BoxDecoration(
                            //                             color: Colors.white,
                            //                             borderRadius: BorderRadius.circular(16),
                            //                             boxShadow: [
                            //                               BoxShadow(
                            //                                 color: Colors.black.withOpacity(0.05),
                            //                                 blurRadius: 8,
                            //                                 offset: const Offset(0, 4),
                            //                               ),
                            //                             ],
                            //                           ),
                            //                           child: (weeklySales.isEmpty || maxSales == 0)
                            //                               ?
                            //                           _buildEmptyState()
                            //                           // Container(
                            //                           //   decoration: BoxDecoration(
                            //                           //     color: Colors.black.withOpacity(0.05),
                            //                           //     borderRadius: BorderRadius.circular(12),
                            //                           //   ),
                            //                           //   alignment: Alignment.center,
                            //                           //   child: const Text(
                            //                           //     "No Data Available",
                            //                           //     style: TextStyle(color: Colors.black54),
                            //                           //   ),
                            //                           // )
                            //
                            //                               : LineChart(
                            //                             LineChartData(
                            //                               gridData: FlGridData(show: true),
                            //                               titlesData: FlTitlesData(
                            //                                 leftTitles: AxisTitles(
                            //                                   sideTitles: SideTitles(
                            //                                     showTitles: true,
                            //                                     reservedSize: 40,
                            //                                     interval:
                            //                                     (maxSales / 4).ceilToDouble().clamp(1, double.infinity),
                            //                                     getTitlesWidget: (value, _) => Text(
                            //                                       value.toInt().toString(),
                            //                                       style: const TextStyle(fontSize: 10),
                            //                                     ),
                            //                                   ),
                            //                                 ),
                            //                                 bottomTitles: AxisTitles(
                            //                                   sideTitles: SideTitles(
                            //                                     showTitles: true,
                            //                                     interval: 1,
                            //                                     getTitlesWidget: (value, _) {
                            //                                       final index = value.toInt();
                            //                                       if (index < 0 || index >= weeklySales.length) return const SizedBox.shrink();
                            //                                       return Padding(
                            //                                         padding: const EdgeInsets.only(top: 4),
                            //                                         child: Text(
                            //                                           weeklySales[index].label ?? '',
                            //                                           style: const TextStyle(fontSize: 10),
                            //                                         ),
                            //                                       );
                            //                                     },
                            //                                   ),
                            //                                 ),
                            //                                 topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            //                                 rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            //                               ),
                            //                               lineBarsData: [
                            //                                 LineChartBarData(
                            //                                   spots: List.generate(
                            //                                     weeklySales.length,
                            //                                         (i) => FlSpot(
                            //                                       i.toDouble(),
                            //                                       (weeklySales[i].totalSales ?? 0).toDouble(),
                            //                                     ),
                            //                                   ),
                            //                                   isCurved: true,
                            //                                   color: Colors.blueAccent,
                            //                                   barWidth: 3,
                            //                                   dotData: FlDotData(show: true),
                            //                                   belowBarData: BarAreaData(
                            //                                     show: true,
                            //                                     color: Colors.blueAccent.withOpacity(0.1),
                            //                                   ),
                            //                                 ),
                            //                               ],
                            //                               minY: 0,
                            //                               maxY: (maxSales * 1.2).clamp(1, double.infinity),
                            //                             ),
                            //                           ),
                            //                         ),
                            //                       ),
                            //                       const SizedBox(width: 30),
                            //
                            //                       // Pie Chart
                            //                       // Pie Chart
                            //                       Expanded(
                            //                         flex: 1,
                            //                         child: Container(
                            //                           height: 300, // same as LineChart
                            //                           padding: const EdgeInsets.all(12),
                            //                           decoration: BoxDecoration(
                            //                             color: Colors.white,
                            //                             borderRadius: BorderRadius.circular(16),
                            //                             boxShadow: [
                            //                               BoxShadow(
                            //                                 color: Colors.black.withOpacity(0.05),
                            //                                 blurRadius: 8,
                            //                                 offset: const Offset(0, 4),
                            //                               ),
                            //                             ],
                            //                           ),
                            //                           child:
                            // // totalPayment == 0
                            // //                               ?
                            // //                               _buildEmptyState()
                            // //                           Container(
                            // //                             alignment: Alignment.center,
                            // //                             decoration: BoxDecoration(
                            // //                               color: Colors.black.withOpacity(0.05),
                            // //                               borderRadius: BorderRadius.circular(12),
                            // //                             ),
                            // //                             child: const Text(
                            // //                               "No Data Available",
                            // //                               style: TextStyle(color: Colors.black54),
                            // //                             ),
                            // //                           )
                            // //                               :
                            //                           Column(
                            //                             children: [
                            //                               SizedBox(
                            //                                 width: 220,
                            //                                 height: 220,
                            //                                 child: Stack(
                            //                                   alignment: Alignment.center,
                            //                                   children: [
                            //                                     PieChart(
                            //                                       PieChartData(
                            //                                         sections: [
                            //                                           PieChartSectionData(
                            //                                             value: cash.toDouble(),
                            //                                             title: totalPayment > 0 ? '${((cash / totalPayment) * 100).toStringAsFixed(1)}%' : '',
                            //                                             color: Colors.green,
                            //                                             radius: _tappedPaymentIndex == 0 ? 70 : 60,
                            //                                             titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            //                                           ),
                            //                                           PieChartSectionData(
                            //                                             value: credit.toDouble(),
                            //                                             title: totalPayment > 0 ? '${((credit / totalPayment) * 100).toStringAsFixed(1)}%' : '',
                            //                                             color: Colors.blue,
                            //                                             radius: _tappedPaymentIndex == 1 ? 70 : 60,
                            //                                             titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            //                                           ),
                            //                                           PieChartSectionData(
                            //                                             value: loan.toDouble(),
                            //                                             title: totalPayment > 0 ? '${((loan / totalPayment) * 100).toStringAsFixed(1)}%' : '',
                            //                                             color: Colors.red,
                            //                                             radius: _tappedPaymentIndex == 2 ? 70 : 60,
                            //                                             titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            //                                           ),
                            //                                           PieChartSectionData(
                            //                                             value: pendingPayments.toDouble(),
                            //                                             title: totalPayment > 0 ? '${((pendingPayments / totalPayment) * 100).toStringAsFixed(1)}%' : '',
                            //                                             color: Colors.orange,
                            //                                             radius: _tappedPaymentIndex == 3 ? 70 : 60,
                            //                                             titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            //                                           ),
                            //                                         ],
                            //                                         sectionsSpace: 4,
                            //                                         centerSpaceRadius: 50,
                            //                                         pieTouchData: PieTouchData(
                            //                                           touchCallback: (event, pieTouchResponse) {
                            //                                             setState(() {
                            //                                               _tappedPaymentIndex = pieTouchResponse?.touchedSection?.touchedSectionIndex ?? -1;
                            //                                             });
                            //                                           },
                            //                                         ),
                            //                                       ),
                            //                                     ),
                            //                                     Text(
                            //                                       "total".tr+"\n${totalPayment.toStringAsFixed(2)}"+ "sar".tr,
                            //                                       textAlign: TextAlign.center,
                            //                                       style: const TextStyle(
                            //                                         fontWeight: FontWeight.bold,
                            //                                         color: Colors.black87,
                            //                                       ),
                            //                                     ),
                            //                                   ],
                            //                                 ),
                            //                               ),
                            //                               const SizedBox(height: 10),
                            //                               // Legend
                            //                               Row(
                            //                                 mainAxisAlignment: MainAxisAlignment.center,
                            //                                 children: [
                            //
                            //                                   Legend(color:Colors.redAccent,text:  "loan".tr),
                            //                                   SizedBox(width: 20,),
                            //                                   Legend(color:Colors.orangeAccent,text:"pending_payment".tr),
                            //
                            //                                 ],
                            //                               ),
                            //                               Row(
                            //                                 mainAxisAlignment: MainAxisAlignment.center,
                            //                                 children: [
                            //
                            //                                   Legend(color: Colors.greenAccent,text:"Cash".tr),
                            //                                   SizedBox(width: 20,),
                            //                                   Legend(color:Colors.blueAccent,text:"Credit Card".tr),
                            //                                   SizedBox(width: 25,),
                            //
                            //                                 ],
                            //                               ),
                            //
                            //                             ],
                            //                           ),
                            //                         ),
                            //                       ),
                            //                     ],
                            //                   ),

                            const SizedBox(height: 24),
                            TopListsWidget(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _selectDateRange() async {
    UserCubit cubit = context.read<UserCubit>();
    final String? establishDateStr = cubit.state.userModel?.data.laundry_account_establish_date;
    final DateTime _establishmentDate = (establishDateStr != null && establishDateStr.isNotEmpty)
        ? DateTime.tryParse(establishDateStr) ?? DateTime(2025, 5, 6)
        : DateTime(2025, 5, 6);
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: 400,
              height: 420,
              child: Column(
                children: [
                  Text(
                    "select_date_range".tr,
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SfDateRangePicker(
                      view: DateRangePickerView.month,
                      selectionMode: DateRangePickerSelectionMode.range,
                      minDate: _establishmentDate,
                      maxDate: DateTime.now(),
                      showActionButtons: true,
                      confirmText: "save".tr,
                      cancelText: "cancel".tr,
                      onSubmit: (value) async {
                        if (value is PickerDateRange) {
                          setState(() {
                            _fromDate = value.startDate;
                            _toDate = value.endDate;
                          });
                        }

                        // Safety check: ensure at least a start date exists
                        if (_fromDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("please_select_at_least_a_start_date".tr),
                          ));
                          return;
                        }

                        // Formatting for API
                        final from = _apiFormat.format(_fromDate!);

                        // LOGIC CHANGE: If _toDate is null, use _fromDate as the end date
                        final to = _apiFormat.format(_toDate ?? _fromDate!);

                        await BlocProvider.of<OrderCubit>(context, listen: false)
                            .getPosStats(fromDate: from, toDate: to);

                        Navigator.pop(context);
                      },
                      onCancel: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDateRange() {
    // if (_fromDate == null) return "select_date_range".tr;
    if (_fromDate == null) {
      // Defaulting to current month range if null
      _fromDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
      _toDate = DateTime.now();
    }
    if (_toDate == null) return _displayFormat.format(_fromDate!);
    return "${_displayFormat.format(_fromDate!)} / ${_displayFormat.format(_toDate!)}";
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 60.h, horizontal: 24.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 64,
            color: Colors.black.withOpacity(0.15),
          ),
          SizedBox(height: 16.h),
          Text(
            "no_data_available".tr,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              // fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            textAlign: TextAlign.center,
            "start_adding_orders_to_see_your_statistics".tr,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class Legend extends StatelessWidget {
  final Color color;
  final String text;

  const Legend({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 5),
        Text(text),
      ],
    );
  }
}
