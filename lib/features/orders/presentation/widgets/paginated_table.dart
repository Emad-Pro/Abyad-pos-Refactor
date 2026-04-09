import 'package:abyadpos_tab/features/orders/presentation/controllers/order_cubit.dart';

import 'package:abyadpos_tab/core/constants/image_constants.dart';
import 'package:abyadpos_tab/features/orders/data/models/order_model.dart';
import 'package:abyadpos_tab/features/orders/data/models/order_status_model.dart';
import 'package:abyadpos_tab/core/theme/app_colors.dart';
import 'package:abyadpos_tab/core/theme/font_constants.dart';
import 'package:abyadpos_tab/main.dart';
import 'package:abyadpos_tab/features/dashboard/presentation/controllers/drawer_cubit.dart';
import 'package:abyadpos_tab/features/orders/presentation/screens/order_detail_screen.dart';
import 'package:abyadpos_tab/features/orders/presentation/widgets/change_order_status_dialog.dart';
import 'package:abyadpos_tab/features/orders/presentation/widgets/custom_paginationbar.dart';
import 'package:abyadpos_tab/core/widgets/loader/loading_cubit.dart';
import 'package:abyadpos_tab/core/widgets/common_text.dart';
import 'package:abyadpos_tab/core/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:data_table_2/data_table_2.dart';

import 'package:abyadpos_tab/core/widgets/custom_drawer.dart';
import 'package:abyadpos_tab/core/widgets/ui_helpers.dart';

/// DataSource for PaginatedDataTable
class OrdersDataSource extends DataTableSource {
  final List<Order> _orders;
  int _selectedCount = 0;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  BuildContext context;
  bool isCurrent;

  OrdersDataSource(this._orders, this.context, this.isCurrent);

  void sort<T>(Comparable<T> Function(Order d) getField, bool asc) {
    _orders.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return asc ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  @override
  DataRow getRow(int index) {
    // assert(index >= 0);
    // if (index >= _orders.length) return const DataRow(cells: []);
    // final o = _orders[index];
    // return DataRow2.byIndex(
    //   color: index % 2 == 0
    //       ? WidgetStatePropertyAll(Colors.white)
    //       : WidgetStatePropertyAll(Colors.white54),
    //   index: index,
    final o = _orders[index];
    print(o.toJson());
    return DataRow2.byIndex(
      index: index,
      color: index % 2 == 0
          ? WidgetStatePropertyAll(Colors.white)
          : WidgetStatePropertyAll(Colors.white54),
      //  This makes the entire row tappable
      onSelectChanged: (_) {
        // onRowTap(o);
        print(o.id);
        var result = Get.to(OrderDetailScreen(model: o, isCurrent: isCurrent));
        if (result != null) {
          result.then((value) {
            print("hello java..." + value.toString());
            if (value != null && value == true) {}
          });
        }
      },
      cells: [
        DataCell(Text(UIHelper().cleanId(o.id.toString()))),
        DataCell(Text(o.user.userName?.toString() ?? "N/A")),
        // DataCell(Text(o.user.mobile)),
        // DataCell(Text(o.orderType.replaceAll('-', ' → '))),
        DataCell(Text(o.totalPrice.toString())),
        DataCell(Text(o.totalItemCount.toString())),
        DataCell(Text(intl.DateFormat.yMd('en_GB').format(o.createdAt))),
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(
              color: colorForStatus(o.status.key ?? "") ?? Colors.grey,
            ),
            color: (colorForStatus(o.status.key ?? "") ?? Colors.grey).withOpacity(0.2),
            borderRadius: BorderRadius.circular(5),
          ),
          child: CommonText(
            text: isArabic ? (o.status.nameAr ?? "") : o.status.nameEn ?? "",
            fontSize: FontConstants.font_12,
            fontWeight: FontWeightConstants.medium,
            color: colorForStatus(o.status.key),
          ),
        )),
        if (isCurrent)
          DataCell(!isCurrent
              ? Container()
              : InkWell(
                  onTap: () async {
                    context.read<LoadingCubit>().showLoading();
                    OrderCubit provider = context.read<OrderCubit>();
                    OrderStatusModel? orderStatusModel =
                        await provider.fetchOrderStatus(orderId: o.id.toString());
                    context.read<LoadingCubit>().hideLoading();

                    if (orderStatusModel != null) {
                      print("here.....");
                      changeOrderStatus(context, orderStatusModel, o, callBack: (data) async {});
                    }
                  },
                  borderRadius: BorderRadius.circular(25),
                  radius: 20,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: SvgPicture.asset(
                      ImageConstants.Settings,
                      width: 24.0,
                      color: AppColors.primaryColor,
                    ),
                  ),
                )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => _orders.length;
  @override
  int get selectedRowCount => _selectedCount;
}

Color? colorForStatus(String s) {
  switch (s.toLowerCase()) {
    // case 'delivered':
    //   return Colors.green;
    case 'in progress':
    case 'in-progress':
      return Color.fromRGBO(76, 199, 253, 1);
    case 'ready-for-pickup':
    case 'ready for pickup':
      return Color.fromRGBO(44, 225, 120, 1.0);
    case 'cancel':
    case 'cancelled':
      // return Colors.redAccent;
      return Color.fromRGBO(255, 116, 116, 1);

    // return Colors.black;
    case 'lost':
      return Color.fromRGBO(255, 116, 116, 1);
    default:
      return Colors.grey;
  }
}

class OrdersTable1 extends StatefulWidget {
  final List<Order> orders;
  OrderCubit cubit;
  bool isCurrent;
  // final ValueChanged<String> onSearch;

  OrdersTable1({
    Key? key,
    required this.orders,
    required this.cubit,
    required this.isCurrent,
    // required this.onSearch
  }) : super(key: key);

  @override
  _OrdersTable1State createState() => _OrdersTable1State();
}

class _OrdersTable1State extends State<OrdersTable1> {
  late OrdersDataSource _dataSource;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  var textcontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      _rowsPerPage = widget.cubit.state.pageSize;
    });
  }

  void _sort<T>(Comparable<T> Function(Order d) getField, int columnIndex, bool asc) {
    _dataSource.sort<T>(getField, asc);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = asc;
    });
  }

  @override
  Widget build(BuildContext context) {
    _dataSource = OrdersDataSource(widget.orders, context, widget.isCurrent);
    final provider = context.watch<SideMenuCubit>();
    final activeModel = widget.cubit.state.getActiveModel(widget.isCurrent);
    return Theme(
      data: Theme.of(context).copyWith(
        iconTheme: const IconThemeData(size: 0),

        // make the PaginatedDataTable’s Card white
        cardColor: Colors.white,
        cardTheme: CardThemeData(
            elevation: 0.0,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            surfaceTintColor: Colors.white),

        // optionally tweak the divider between rows
        dividerColor: Colors.grey[300],
      ),
      child: Column(
        children: [
          Expanded(
            // height: Get.height * 0.8,
            child: Localizations.override(
              context: context,
              delegates: const [
                // 1st is ours, blanking out the row‐info:
                _BlankPageInfoDelegate(),
                // then fall back to the built‐ins:
                // GlobalMaterialLocalizations.delegate,
                // GlobalWidgetsLocalizations.delegate,
                // GlobalCupertinoLocalizations.delegate,
              ],
              child: Directionality(
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                child: PaginatedDataTable2(
                  headingRowHeight: 45.sp,

                  minWidth: provider.state.isCollapsed ? Get.width - 75 : Get.width - 230,
                  columnSpacing: 0,
                  horizontalMargin: 16,
                  fixedLeftColumns: 1,
                  showCheckboxColumn: false,

                  headingRowColor: WidgetStatePropertyAll(Color(0xffDDE1E4)),
                  header: Container(
                    //   color: Colors.white,
                    child: Row(
                      children: [
                        if (activeModel != null)
                          CommonText(
                            text: (widget.cubit.state.isSearching
                                    ? "search_results".tr
                                    : widget.isCurrent
                                        ? "orders".tr
                                        : "invoices".tr) +
                                ": ${activeModel.data.pagination.totalOrders ?? 0}",
                            fontSize: FontConstants.font_18,
                            fontWeight: FontWeightConstants.semiBold,
                          ),
                        // if (widget.provider.isSearching)
                        //   IconButton(
                        //     icon: const Icon(Icons.cancel, color: Colors.red),
                        //     onPressed: () => widget.provider.clearSearch(),
                        //   ),
                        const Spacer(),
                        // if (widget.isCurrent && widget.provider.allAdsModel != null)...[
                        //   CommonText(
                        //     text: (widget.isCurrent
                        //         ? "Total Orders: ".tr +
                        //         '${widget.provider.allAdsModel!.data.pagination.totalOrders.toString()}'
                        //         : "Total Invoices ".tr +
                        //         '${widget.provider.allHistoryModel!.data.pagination.totalOrders.toString()}'),
                        //     fontSize: FontConstants.font_18,
                        //     fontWeight: FontWeightConstants.semiBold,
                        //   ),
                        // ]
                        // else if (!widget.isCurrent && widget.provider.allHistoryModel != null)...[
                        //   CommonText(
                        //     text: "Total Invoices ".tr +
                        //         '${widget.provider.allHistoryModel!.data.pagination.totalOrders}',
                        //     fontSize: FontConstants.font_18,
                        //     fontWeight: FontWeightConstants.semiBold,
                        //   )
                        // ]
                        //   else
                        //   const SizedBox.shrink(),
                        //
                        //
                        //     Spacer(),
                        // Container(
                        //   width: 250,
                        //   height: 36,
                        //   decoration: BoxDecoration(
                        //     color: Colors.white,
                        //     borderRadius: BorderRadius.circular(10),
                        //     boxShadow: [
                        //       BoxShadow(
                        //         color: Colors.grey.withOpacity(0.3),
                        //         blurRadius: 8,
                        //         spreadRadius: 0.5,
                        //       ),
                        //     ],
                        //   ),
                        //   child: TextField(
                        //     onSubmitted: widget.onSearch,
                        //     controller: textcontroller,
                        //     decoration: InputDecoration(
                        //       hintStyle: Theme.of(context)
                        //           .textTheme
                        //           .titleMedium
                        //           ?.copyWith(
                        //               fontSize: FontConstants.font_14,
                        //               color: AppColors.hintColor),
                        //       prefixIcon:
                        //           Icon(Icons.search, color: Colors.grey),
                        //       hintText: 'search'.tr,
                        //       contentPadding:
                        //           const EdgeInsets.symmetric(vertical: 0),
                        //       border: InputBorder.none,
                        //       suffixIcon: textcontroller.text == ""
                        //           ? null
                        //           : IconButton(
                        //               onPressed: () {
                        //                 textcontroller.clear();
                        //                 widget.onSearch("");
                        //               },
                        //               icon: Icon(Icons.clear)),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  source: _dataSource,
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  rowsPerPage: widget.cubit.state.pageSize,
                  availableRowsPerPage: const <int>[], // hide built-in dropdown
                  onRowsPerPageChanged: null,
                  renderEmptyRowsInTheEnd: false,
                  empty: CommonWidgets.noDataView(
                    title: widget.orders.isEmpty ? "noOrdersFound".tr : "".tr,
                    subText: "",
                  ),

                  //  arrowHeadColor: Colors.red,

                  columns: [
                    customDataColumn(
                        index: 0,
                        text: "Order Id".tr,
                        width: 130.0,
                        onSort: (i, asc) =>
                            _sort<String>((d) => UIHelper().cleanId(d.id.toString()), i, asc)),
                    customDataColumn(
                      index: 1,
                      width: 175.0,
                      text: "Client’s Name".tr,
                      onSort: (i, asc) =>
                          _sort<String>((d) => d.user.userName?.toString() ?? "", i, asc),
                    ),

                    // customDataColumn(
                    //     index: 2,
                    //     text: "Mobile No.".tr,
                    //     width: 170.0,
                    //     onSort: (i, asc) =>
                    //         _sort<String>((d) => d.user.mobile, i, asc)),
                    // customDataColumn(
                    //     width: 170.0,
                    //     index: 3,
                    //     text: "Order Type".tr,
                    //     onSort: null),
                    customDataColumn(
                      index: 4,
                      width: 170.0,
                      text: "Total (SAR)".tr,
                      onSort: (i, asc) =>
                          _sort<num>((d) => double.tryParse(d.totalPrice ?? "0") ?? 0.0, i, asc),
                    ),
                    customDataColumn(
                      index: 5,
                      width: 120.0,
                      text: "Qty.".tr,
                      onSort: (i, asc) => _sort<num>((d) => d.totalItemCount, i, asc),
                    ),
                    customDataColumn(
                      index: 6,
                      text: "Date".tr,
                      onSort: (i, asc) => _sort<DateTime>((d) => d.createdAt, i, asc),
                    ),
                    customDataColumn(
                      index: 7,
                      text: "Status".tr,
                      onSort: (i, asc) => _sort<String>((d) => d.status.nameEn ?? "", i, asc),
                    ),
                    if (widget.isCurrent)
                      DataColumn(
                        label: Text('Action'.tr),
                      ),
                  ],
                  // source: _dataSource,
                ),
              ),
            ),
          ),

          CustomPagination(
            // Use the provider's variables directly so they are reactive
            currentPage: widget.isCurrent
                ? widget.cubit.state.pageNumber
                : widget.cubit.state.pageNumberHistory,

            // Use activeModel for total pages
            totalPages:
                widget.cubit.state.getActiveModel(widget.isCurrent)?.data.pagination.pagesCount ??
                    1,

            rowsPerPage: widget.cubit.state.pageSize,
            onPageChanged: (page) {
              if (widget.cubit.state.isSearching) {
                // We update the local pageNumber
                widget.cubit.setPageNumber(page);

                widget.cubit.getOrdersBySearch(
                  widget.cubit.state.lastSearchQuery,
                  isNewSearch: false,
                  targetPage: page, // <--- PASS THE JUMP TARGET HERE
                  isComplete: !widget.isCurrent,
                );
              } else if (widget.isCurrent) {
                widget.cubit.setPageNumber(page);
                widget.cubit.getOrders(context, targetPage: page);
              } else {
                widget.cubit.setPageNumberHistory(page);
                widget.cubit.getHistoryOrders(context, targetPage: page);
              }
            },
            onRowsPerPageChanged: (newSize) {
              widget.cubit.setPageNumber(newSize);
              // Reset to page 1 when changing size
              widget.isCurrent
                  ? widget.cubit.setPageNumber(1)
                  : widget.cubit.setPageNumberHistory(1);
              widget.cubit.refreshOrders(context, isCurrent: widget.isCurrent);
            },
          )
          // CustomPagination(
          //   currentPage: widget.isCurrent
          //       ? widget.provider.pageNumber
          //       : widget.provider.pageNumberHistory,
          //   totalPages: activeModel?.data.pagination.pagesCount ?? 1,
          //   // totalPages: widget.isCurrent
          //   //     ? (widget.provider.allAdsModel?.data.pagination.pagesCount ?? 1)
          //   //     : (widget.provider.allHistoryModel?.data.pagination.pagesCount ?? 1),
          //   rowsPerPage: widget.provider.pageSize,
          //   // onPageChanged: (page) {
          //   //   if (widget.isCurrent) {
          //   //     widget.provider.pageNumber = page;
          //   //     print("page>>>>>" + widget.provider.pageNumber.toString());
          //   //     widget.provider.allAdsModel = null;
          //   //
          //   //     widget.provider.getOrders(context);
          //   //   } else {
          //   //     widget.provider.pageNumberHistory = page;
          //   //
          //   //     widget.provider.getHistoryOrders(context);
          //   //   }
          //   // },
          //   // onPageChanged: (page) {
          //   //   if (widget.isCurrent) {
          //   //     // Pass the integer 'page' as the targetPage parameter
          //   //     widget.provider.getOrders(context, targetPage: page);
          //   //   } else {
          //   //     widget.provider.getHistoryOrders(context, targetPage: page);
          //   //   }
          //   // },
          //   onPageChanged: (page) {
          //     if (widget.provider.isSearching) {
          //       // Fetch next page of search
          //       String? nextUrl = widget.provider.filterAdsModel?.data.pagination.nextPageUrl;
          //       widget.provider.getOrdersBySearch(
          //           widget.provider.lastSearchQuery,
          //           nextPageUrl: nextUrl,
          //           isNewSearch: false
          //       );
          //     } else if (widget.isCurrent) {
          //       widget.provider.getOrders(context, targetPage: page);
          //     } else {
          //       widget.provider.getHistoryOrders(context, targetPage: page);
          //     }
          //   },
          //   onRowsPerPageChanged: (newSize) {
          //     widget.provider.pageSize = newSize;
          //     if (widget.isCurrent) {
          //       //widget.provider.pageNumber = 1;
          //       widget.provider.allAdsModel = null;
          //       widget.provider.getOrders(context);
          //     } else {
          //       // widget.provider.pageNumber = 1;
          //
          //       widget.provider.allHistoryModel = null;
          //       widget.provider.getHistoryOrders(context);
          //     }
          //   },
          // )
        ],
      ),
    );
  }

  DataColumn2 customDataColumn({required text, required index, onSort, width}) {
    return DataColumn2(
      // size: ColumnSize.L,
      //size: ColumnSize.auto,
      //fixedWidth: width ?? 180,
      // columnWidth: TableColumnWidth,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CommonText(
            text: text,
            fontSize: FontConstants.font_12,
            fontWeight: FontWeightConstants.semiBold,
          ),
          SizedBox(width: 4),
          _sortColumnIndex == index
              ? Container()
              : onSort == null
                  ? Container()
                  : SvgPicture.asset(ImageConstants.filter1),
        ],
      ),
      onSort: onSort,
    );
  }
}

// 1) Subclass and blank out the pageRowsInfoTitle:
class _BlankPageInfoLocalizations extends DefaultMaterialLocalizations {
  @override
  String pageRowsInfoTitle(int firstRow, int lastRow, int rowCount, bool rowCountIsApproximate) {
    return '';
  }
}

// 2) Create a delegate that returns your subclass:
class _BlankPageInfoDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const _BlankPageInfoDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    // load the default, then wrap it:
    await GlobalMaterialLocalizations.delegate.load(locale);
    return _BlankPageInfoLocalizations();
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<MaterialLocalizations> old) => false;
}
