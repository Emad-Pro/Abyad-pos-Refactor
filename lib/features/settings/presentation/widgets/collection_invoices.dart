import 'package:abyadpos_tab/features/orders/presentation/controllers/order_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart' as intl; // Add 'as intl'import 'package:flutter/material.dart';

import 'package:abyadpos_tab/core/widgets/ui_helpers.dart';

class CollectionInvoicesDialog extends StatefulWidget {
  final DateTime establishmentDate;
  final String phone; // Added phone field

  const CollectionInvoicesDialog({
    super.key,
    required this.establishmentDate,
    required this.phone,
  });

  @override
  State<CollectionInvoicesDialog> createState() => _CollectionInvoicesDialogState();
}

class _CollectionInvoicesDialogState extends State<CollectionInvoicesDialog> {
  final DateRangePickerController _datePickerController = DateRangePickerController();

  bool isItemsInvoice = true;
  bool isLoan = true;
  DateTime? _fromDate;
  DateTime? _toDate;
  final intl.DateFormat _apiFormat = intl.DateFormat('yyyy-MM-dd');

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    if (args.value is PickerDateRange) {
      final DateTime? start = args.value.startDate;
      final DateTime? end = args.value.endDate;

      if (start != null && end != null) {
        final int daysDifference = end.difference(start).inDays;

        if (daysDifference > 60) {
          // 1. Show error
          UIHelper.showBottomFlash(context,
              title: 'error'.tr, message: "range_exceed_60_days".tr, isError: true);

          // 2. Clear values immediately
          _fromDate = null;
          _toDate = null;

          // 3. Force UI Reset in the next microtask
          Future.delayed(Duration.zero, () {
            if (!mounted) return;
            setState(() {
              // This now works because the controller is linked in build()
              _datePickerController.selectedRange = null;
              _datePickerController.displayDate = DateTime.now();
            });
          });
          return;
        }
      }
      // Update state if within range
      _fromDate = start;
      _toDate = end;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 450,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "select_collection_type".tr,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
              const SizedBox(height: 20),

              // 1. Main Toggle: Items vs Payments
              _buildToggleRow(
                leftLabel: "items_invoices_collection".tr,
                rightLabel: "payments_invoices_collection".tr,
                isSelected: isItemsInvoice,
                onTap: (val) => setState(() => isItemsInvoice = val),
              ),

              const SizedBox(height: 15),

              // 2. Sub-Toggle: Loan vs Wallet (Now always shown for both)
              _buildToggleRow(
                leftLabel: "loan".tr,
                rightLabel: "wallet".tr,
                isSelected: isLoan,
                onTap: (val) => setState(() => isLoan = val),
                isSubToggle: true,
              ),

              const Divider(height: 30),

              // 3. Date Range Picker with 60-day constraint logic
              SizedBox(
                height: 300,
                child: Directionality(
                  textDirection: TextDirection.ltr, // Use lowercase 'ltr'
                  child: SfDateRangePicker(
                    view: DateRangePickerView.month,
                    controller: _datePickerController, // <--- YOU WERE MISSING THIS LINE
                    selectionMode: DateRangePickerSelectionMode.range,
                    minDate: widget.establishmentDate,
                    maxDate: DateTime.now(),
                    onSelectionChanged: _onSelectionChanged,
                    headerStyle: const DateRangePickerHeaderStyle(
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _handlePrint,
                  child: Text("print".tr, style: const TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handlePrint() async {
    if (_fromDate == null) {
      UIHelper.showBottomFlash(context,
          title: 'error'.tr, message: "please_select_at_least_a_start_date".tr, isError: true);
      return;
    }

    // Determine type string for both functions
    String paymentSubSelection = isLoan ? "loan" : "wallet";

    final from = _apiFormat.format(_fromDate!);
    final to = _apiFormat.format(_toDate ?? _fromDate!);

    // Ensure the range is valid before calling API
    if (_toDate != null && _toDate!.difference(_fromDate!).inDays > 60) {
      UIHelper.showBottomFlash(context,
          title: 'error'.tr, message: "range_exceed_60_days".tr, isError: true);
      return;
    }

    final orderVM = BlocProvider.of<OrderCubit>(context, listen: false);

    if (isItemsInvoice) {
      // --- CALL ITEMS INVOICES FUNCTION ---
      debugPrint("Calling Items Invoices ($paymentSubSelection): $from to $to");
      await orderVM.handleSubmitItemsCollectionInvoices(
          fromDate: from,
          toDate: to,
          type: paymentSubSelection,
          context: context,
          phone: widget.phone);
    } else {
      // --- CALL PAYMENTS INVOICES FUNCTION ---
      debugPrint("Calling Payments Function ($paymentSubSelection): $from to $to");
      await orderVM.handleSubmitPaymentCollectionInvoices(
          fromDate: from,
          toDate: to,
          type: paymentSubSelection,
          context: context,
          phone: widget.phone);
    }

    Navigator.pop(context);
  }

  // Helper widget for toggles remains the same...
  Widget _buildToggleRow(
      {required String leftLabel,
      required String rightLabel,
      required bool isSelected,
      required Function(bool) onTap,
      bool isSubToggle = false}) {
    return Row(
      children: [
        Expanded(child: _toggleButton(leftLabel, isSelected, () => onTap(true), isSubToggle)),
        const SizedBox(width: 8),
        Expanded(child: _toggleButton(rightLabel, !isSelected, () => onTap(false), isSubToggle)),
      ],
    );
  }

  Widget _toggleButton(String text, bool active, VoidCallback onTap, bool isSubToggle) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: active ? (isSubToggle ? Colors.blueAccent : Colors.blueAccent) : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: active ? Colors.white : Colors.black54,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
