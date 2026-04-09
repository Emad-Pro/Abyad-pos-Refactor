import 'package:abyadpos_tab/features/orders/data/models/order_model.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 2) Create a widget that takes an Order and draws the table + footer:

class OrderTable extends StatelessWidget {
  final Order order;
  double vat;

  OrderTable({Key? key, required this.order, this.vat = 0.0}) : super(key: key);

  Widget _buildFooterRow(String label, double amount, {bool isBold = false}) {
    final style = TextStyle(
      fontSize: isBold ? 16.sp : 14.sp,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(label, style: style),
          SizedBox(width: 24),
          Text(amount.toStringAsFixed(2), style: style),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ————— The data table —————
        SizedBox(
          height: (order.clothes.length * 50) + 50,
          child: DataTable2(
            // minWidth: Get.width * 0.5,
            headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),

            columns: [
              DataColumn2(size: ColumnSize.S, label: Text('#')),
              DataColumn2(
                size: ColumnSize.L,
                label: Text('Item'),
              ),
              DataColumn2(size: ColumnSize.S, label: Text('Qty.')),
              DataColumn2(size: ColumnSize.M, label: Text('Price (SAR)')),
            ],
            rows: List.generate(order.clothes.length, (i) {
              final item = order.clothes[i];
              return DataRow(cells: [
                DataCell(Text('${i + 1}')),
                DataCell(Text("Thobe")),
                DataCell(Text('${item.clothCount.toString()}')),
                DataCell(Text(item.clothTotalPrice)),
              ]);
            }),
          ),
        ),

        SizedBox(height: 24),

        // ————— The footer totals —————
        _buildFooterRow('Sub Total', double.tryParse(order.subTotal) ?? 0.0),
        _buildFooterRow('VAT (TAX)', vat),
        Divider(thickness: 1.5),
        _buildFooterRow(
            'Total', (double.tryParse(order.finalTotalPrice) ?? 0.0) + vat,
            isBold: true),
      ],
    );
  }
}
