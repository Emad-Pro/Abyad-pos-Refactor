import 'dart:math';

import 'package:abyadpos_tab/features/orders/presentation/controllers/order_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:syncfusion_flutter_datagrid/datagrid.dart';

// Your Order model (adjust imports / fields as needed)
import 'package:abyadpos_tab/features/orders/data/models/order_model.dart';

/// Global page-size (you can make this configurable)
const int _rowsPerPage = 10;

/// The widget you drop into your screen:
class OrdersTable extends StatefulWidget {
  List<Order> listOrders;
  OrdersTable({Key? key, required this.listOrders}) : super(key: key);

  @override
  _OrdersTableState createState() => _OrdersTableState();
}

class _OrdersTableState extends State<OrdersTable> {
  late OrderDataSource _dataSource;
  late int _pageCount;

  @override
  void initState() {
    super.initState();
    // fetch from your provider
    final orders = widget.listOrders;
    _dataSource = OrderDataSource(orders: orders, context: context);
    _pageCount = (orders.length / _rowsPerPage).ceil();
  }

  void _onPageChanged(int newPageIndex) {
    final orders = widget.listOrders;
    final start = newPageIndex * _rowsPerPage;
    final end = min(start + _rowsPerPage, orders.length);
    _dataSource.updateRows(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final orders = widget.listOrders;
    // recalc pageCount if dynamic
    _pageCount = (orders.length / _rowsPerPage).ceil();

    return Column(
      children: [
        // Table
        Expanded(
          child: SfDataGrid(
            source: _dataSource,
            allowSorting: true,
            allowFiltering: true,
            columnWidthMode: ColumnWidthMode.fill,
            rowHeight: 48,
            headerRowHeight: 56,
            columns: <GridColumn>[
              _buildColumn('OrderId', 'Order Id', allowSorting: true),
              _buildColumn('Client', 'Client’s Name', allowSorting: true),
              _buildColumn('Mobile', 'Mobile No.', allowSorting: true),
              // _buildColumn('Type', 'Order Type', allowSorting: true),
              _buildColumn('Total', 'Total (SAR)', numeric: true),
              _buildColumn('Qty', 'Qty.', numeric: true),
              _buildColumn('Date', 'Date', allowSorting: true),
              GridColumn(
                columnName: 'Status',
                label: _header('Status'),
                allowSorting: true,
              ),
              GridColumn(
                columnName: 'Action',
                width: 80,
                label: _header('Action'),
                // widget: (ctx, rowIndex) {
                //   final order = _dataSource.ordersForRow(rowIndex);
                //   return IconButton(
                //     icon: const Icon(Icons.settings),
                //     onPressed: () {
                //       // your action
                //     },
                //   );
                // },
              ),
            ],
          ),
        ),

        // Pager
        SizedBox(
          height: 56,
          child: SfDataPager(
            pageCount: max(1, _pageCount).toDouble(),
            // onPageItemChanged: _onPageChanged,
            direction: Axis.horizontal,
            delegate: _dataSource,
          ),
        ),
      ],
    );
  }

  GridColumn _buildColumn(
    String name,
    String title, {
    bool allowSorting = false,
    bool numeric = false,
  }) {
    return GridColumn(
      columnName: name,
      allowSorting: allowSorting,
      columnWidthMode: numeric ? ColumnWidthMode.auto : ColumnWidthMode.fill,
      label: _header(title),
    );
  }

  Widget _header(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      child: Text(text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          )),
      color: Theme.of(context).primaryColor,
    );
  }
}

/// The DataGridSource that drives the grid
class OrderDataSource extends DataGridSource {
  final List<Order> _allOrders;
  final BuildContext context;
  List<DataGridRow> _rows = [];

  OrderDataSource({
    required List<Order> orders,
    required this.context,
  }) : _allOrders = orders {
    // init first page
    updateRows(0, min(_allOrders.length, _rowsPerPage));
  }

  /// expose the order for a given grid row
  Order ordersForRow(int rowIndex) => _rows[rowIndex].getCells().last.value as Order;

  /// repopulate `_rows` for the given slice
  void updateRows(int startIndex, int endIndex) {
    _rows = _allOrders
        .getRange(startIndex, endIndex)
        .map((o) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'OrderId', value: o.id.toString()),
              DataGridCell<String>(columnName: 'Client', value: o.user.userName),
              DataGridCell<String>(columnName: 'Mobile', value: o.user.mobile),
              DataGridCell<String>(columnName: 'Type', value: o.orderType.replaceAll('-', ' → ')),
              DataGridCell<double>(columnName: 'Total', value: double.parse(o.finalTotalPrice)),
              DataGridCell<int>(columnName: 'Qty', value: o.totalItemCount),
              DataGridCell<DateTime>(columnName: 'Date', value: o.createdAt),
              DataGridCell<String>(columnName: 'Status', value: o.status.nameEn),
              // store the full order in the last cell for action column
              DataGridCell<Order>(columnName: 'Action', value: o),
            ]))
        .toList();
    notifyListeners();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    // color stripe every other row
    final idx = _rows.indexOf(row);
    final bg =
        (idx % 2 == 0) ? Theme.of(context).primaryColor.withOpacity(0.05) : Colors.transparent;

    return DataGridRowAdapter(
      color: bg,
      cells: row.getCells().map<Widget>((cell) {
        switch (cell.columnName) {
          case 'Date':
            return Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(DateFormat.yMd().format(cell.value), overflow: TextOverflow.ellipsis),
            );
          case 'Status':
            final status = cell.value as String;
            final color = _statusColor(status);
            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
              child: Text(status, style: TextStyle(color: color)),
            );
          case 'Action':
            final order = cell.value as Order;
            return IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // action
              },
            );
          default:
            return Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(cell.value.toString(), overflow: TextOverflow.ellipsis),
            );
        }
      }).toList(),
    );
  }

  @override
  Future<void> handleRefresh() async {
    // optional: re-fetch from your provider
    await context.read<OrderCubit>().getOrders(context);
    updateRows(0, min(_allOrders.length, _rowsPerPage));
  }

  T _getField<T>(Order o, String col) {
    switch (col) {
      case 'OrderId':
        return o.id as T;
      case 'Client':
        return o.user.userName as T;
      case 'Mobile':
        return o.user.mobile as T;
      case 'Type':
        return o.orderType as T;
      case 'Total':
        return double.parse(o.finalTotalPrice) as T;
      case 'Qty':
        return o.totalItemCount as T;
      case 'Date':
        return o.createdAt as T;
      case 'Status':
        return o.status.nameEn as T;
      default:
        throw Exception('Invalid column $col');
    }
  }

  static Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'in progress':
        return Colors.orange;
      case 'cancel':
      case 'canceled':
        return Colors.red;
      case 'lost':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }
}
