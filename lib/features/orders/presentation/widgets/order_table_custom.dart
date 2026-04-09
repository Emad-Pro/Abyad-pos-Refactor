import 'package:abyadpos_tab/features/orders/data/models/order_model.dart';
import 'package:abyadpos_tab/main.dart';
import 'package:abyadpos_tab/core/widgets/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class OrderTableCustom extends StatelessWidget {
  final Order order;
  double vat;
  OrderTableCustom({Key? key, required this.order, required this.vat})
      : super(key: key);

  // Builds header or item rows
  Widget _buildRow({
    required List<Widget> cells,
    Color? background,
    Border? border,
    EdgeInsets? padding,
  }) {
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: background,
        border: border,
      ),
      child: Row(children: cells),
    );
  }

  // Footer rows (Sub Total, VAT, Total)
  Widget _buildFooterRow(String label, double amount, {bool bold = false}) {
    final style = TextStyle(
      fontSize: bold ? 16.sp : 14,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    );
    return Container(
      color: Colors.grey.shade200,
      child: _buildRow(
        // two empty columns, then label & amount
        cells: [
          UIHelper.horizontalSpaceMd,
          Expanded(flex: 1, child: SizedBox()),
          Expanded(flex: 4, child: SizedBox()),
          Expanded(
            flex: 2,
            child: Text(label, textAlign: TextAlign.center, style: style),
          ),
          Expanded(
            flex: 2,
            child: Text(amount.toStringAsFixed(2),
                textAlign: TextAlign.center, style: style),
          ),
        ],
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define header style
    final headerStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- Header ---
        _buildRow(
          background: Colors.grey.shade200,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          cells: [
            UIHelper.horizontalSpaceMd,
            Expanded(flex: 1, child: Text('#', style: headerStyle)),
            Expanded(flex: 4, child: Text('Item'.tr, style: headerStyle)),
            Expanded(
                flex: 2,
                child: Text(
                  'Qty.'.tr,
                  style: headerStyle,
                  textAlign: TextAlign.center,
                )),
            Expanded(
                flex: 2,
                child: Text(
                  'Price (SAR)'.tr,
                  style: headerStyle,
                  textAlign: TextAlign.center,
                )),
          ],
        ),

        // --- Data rows ---
        ...List.generate(order.clothes.length, (i) {
          final item = order.clothes[i];
          return _buildRow(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            cells: [
              Expanded(flex: 1, child: Text('${i + 1}')),
              Expanded(
                  flex: 4,
                  child: Text(isArabic ? item.clothNameAr : item.clothName)),
              Expanded(
                  flex: 1,
                  child: Text(
                    '${item.clothCount.toString()}',
                    textAlign: TextAlign.center,
                  )),
              Expanded(
                  flex: 2,
                  child:
                      Text(item.clothTotalPrice, textAlign: TextAlign.center)),
            ],
          );
        }),

        // SizedBox(height: 16),

        // --- Footer ---
        _buildFooterRow(
            'Sub Total'.tr, double.tryParse(order.subTotal) ?? 0.0),
        // _buildFooterRow('VAT'.tr, vat),
        Divider(thickness: 1.5),
        _buildFooterRow(
            'Total Amount'.tr, (double.tryParse(order.finalTotalPrice) ?? 0.0) + vat,
            bold: true),
      ],
    );
  }
}
