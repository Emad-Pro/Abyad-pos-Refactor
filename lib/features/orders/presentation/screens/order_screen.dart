import 'package:abyadpos_tab/features/orders/presentation/controllers/order_cubit.dart';
import 'package:abyadpos_tab/features/orders/data/models/order_model.dart';
import 'package:abyadpos_tab/features/home/presentation/widgets/custom_appbar.dart';
import 'package:abyadpos_tab/features/orders/presentation/widgets/paginated_table.dart';
import 'package:abyadpos_tab/core/widgets/common_widgets.dart';
import 'package:abyadpos_tab/core/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:skeletonizer/skeletonizer.dart';

import 'package:abyadpos_tab/features/orders/presentation/controllers/order_state.dart';

class OrderScreen extends StatefulWidget {
  bool isCurrent;
  bool? isSearching;

  OrderScreen({Key? key, required this.isCurrent, this.isSearching}) : super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  ScrollController scrollController = new ScrollController();
  TextEditingController searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FocusNode _focusNode = FocusNode();
  OrderCubit? orderCubit;
  // @override
  // void initState() {
  //   super.initState();
  //
  //   // Use this to prevent the "setState() called during build" error
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (!mounted) return;
  //
  //     OrderViewModel provider = Provider.of<OrderViewModel>(context, listen: false);
  //
  //     // 1. Check for search query from external screen
  //     if (provider.externalSearchQuery != null && widget.isCurrent) {
  //       setState(() {
  //         searchController.text = provider.externalSearchQuery!;
  //       });
  //       provider.clearExternalSearch();
  //     }
  //     // 2. Handle normal loading for Invoices or Orders
  //     else {
  //       callApi(provider, context);
  //     }
  //   });
  //
  //   // Scroll listener doesn't need to be in the callback

  // }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      OrderCubit orderCubit = BlocProvider.of<OrderCubit>(context, listen: false);
      // providerA=Provider.of<OrderViewModel>(context, listen: false);
      // ALWAYS clear previous search results when entering the screen fresh
      orderCubit.clearSearch(isCurrentView: widget.isCurrent);

      if (orderCubit.state.externalSearchQuery != null && widget.isCurrent) {
        setState(() {
          searchController.text = orderCubit.state.externalSearchQuery!;
        });
        // This will trigger the search based on the external query
        orderCubit.getOrdersBySearch(orderCubit.state.externalSearchQuery!, isComplete: false);
        orderCubit.clearExternalSearch();
      } else {
        callApi(orderCubit, context);
      }
    });
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        OrderCubit provider = BlocProvider.of<OrderCubit>(context, listen: false);
        callApi(provider, context);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This runs while the context is perfectly valid.
    // We update our local reference whenever the dependencies change.
    orderCubit = BlocProvider.of<OrderCubit>(context, listen: false);
  }

  @override
  void dispose() {
    final viewModel = orderCubit;
    final wasCurrent = widget.isCurrent; // Capture the bool value now
    // 1. Use the SAVED reference, NOT the context
    if (viewModel != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.clearSearch(isCurrentView: wasCurrent);
      });
    }

    // 2. Clean up local controllers
    _focusNode.dispose();
    searchController.dispose();
    scrollController.dispose();

    super.dispose();
  }

  // @override
  // void dispose() {
  //   // 1. Capture the provider reference IMMEDIATELY before the context is lost
  //   // We set 'listen: false' because we are just calling a function
  //   final provider = Provider.of<OrderViewModel>(context, listen: false);
  //
  //   // 2. Perform the cleanup
  //   // Since we aren't using 'context' inside the callback, just the 'provider' variable,
  //   // this won't throw the "unmounted" error.
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     provider.clearSearch(isCurrentView: widget.isCurrent);
  //   });
  //
  //   // 3. Clean up local controllers
  //   _focusNode.dispose();
  //   searchController.dispose();
  //   scrollController.dispose(); // Don't forget to dispose your scroll controller too!
  //
  //   super.dispose();
  // }
  // void callApi(OrderViewModel provider, BuildContext context, {isRefresh}) {
  //   if (isRefresh != null) {
  //     if (widget.isCurrent) {
  //       provider.allAdsModel = null;
  //     } else {
  //       provider.allHistoryModel = null;
  //     }
  //   }
  //   if (widget.isCurrent) {
  //     provider.getOrders(context);
  //   } else {
  //     provider.getHistoryOrders(context);
  //   }
  // }
  void callApi(OrderCubit provider, BuildContext context, {bool isRefresh = false}) {
    if (isRefresh) {
      provider.refreshOrders(context, isCurrent: widget.isCurrent);
    } else {
      // Ensure these methods set isLoading = true internally before the await
      if (widget.isCurrent) {
        provider.getOrders(context);
      } else {
        provider.getHistoryOrders(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      body: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          return SizedBox(
            // Changed from Container for better performance
            width: Get.width,
            height: Get.height,
            child: Row(
              children: [
                CustomSideMenu(),
                Expanded(
                  child: Column(
                    children: [
                      CustomAppBar(
                        initialValue: searchController.text,
                        focusNode: widget.isSearching != null ? _focusNode : null,
                        title: widget.isCurrent ? "orders".tr : "invoices".tr,
                        // onSearch: (text) {
                        //   setState(() {
                        //     searchController.text = text;
                        //   });
                        //   provider.getOrdersBySearch(text);
                        // },
                        onSearch: (text) {
                          setState(() {
                            searchController.text = text;
                          });

                          if (text.isEmpty) {
                            // 1. Reset models and page numbers in Provider
                            context.read<OrderCubit>().clearSearch(isCurrentView: widget.isCurrent);

                            // 2. Optionally refresh the original list to ensure data is fresh
                            context
                                .read<OrderCubit>()
                                .refreshOrders(context, isCurrent: widget.isCurrent);
                          } else {
                            // 3. Perform the actual search
                            if (widget.isCurrent) {
                              context.read<OrderCubit>().getOrdersBySearch(text, isComplete: false);
                            } else {
                              context.read<OrderCubit>().getOrdersBySearch(text, isComplete: true);
                            }
                          }
                        },
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            callApi(BlocProvider.of<OrderCubit>(context), context, isRefresh: true);
                            setState(() {
                              searchController.clear();
                            });
                          },
                          // Fix: Using a Column instead of ListView to prevent "MISSING SIZE" error
                          child: Column(
                            children: [
                              Expanded(
                                child: Builder(builder: (context) {
                                  OrderModel? model = searchController.text.isNotEmpty
                                      ? state.filterAdsModel
                                      : (widget.isCurrent
                                          ? state.allAdsModel
                                          : state.allHistoryModel);

                                  // 1. Loading State (Full Shimmer/Placeholder)
                                  if (state.isLoading && model == null) {
                                    return Skeletonizer(
                                      enabled: true,
                                      // This allows the text and icons inside to be visible
                                      // rather than turned into gray boxes
                                      containersColor: Colors.transparent,
                                      child: Skeleton.keep(
                                        child: CommonWidgets.noDataView(
                                          title: "loading".tr,
                                          subText: "".tr,
                                        ),
                                      ),
                                    );
                                    // return Skeletonizer(
                                    //   enabled: true,
                                    //   child: CommonWidgets.noDataView(
                                    //     title: "loading".tr,
                                    //     subText: "".tr,
                                    //   ),
                                    // );
                                  }

                                  // 2. No Data State
                                  if (model == null || model.data.orders.isEmpty) {
                                    // We use SingleChildScrollView here so RefreshIndicator works on empty screens
                                    return SingleChildScrollView(
                                      physics: const AlwaysScrollableScrollPhysics(),
                                      child: SizedBox(
                                        height: Get.height * 0.7,
                                        child: CommonWidgets.noDataView(
                                          title: "noOrdersFound".tr,
                                          subText: "".tr,
                                        ),
                                      ),
                                    );
                                  }

                                  // 3. Data Loaded State - Show the table
                                  return Skeletonizer(
                                    enabled: state.isLoading || state.isPaginating,
                                    child: OrdersTable1(
                                      orders: model.data.orders,
                                      cubit: orderCubit ?? BlocProvider.of<OrderCubit>(context),
                                      isCurrent: widget.isCurrent,
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
