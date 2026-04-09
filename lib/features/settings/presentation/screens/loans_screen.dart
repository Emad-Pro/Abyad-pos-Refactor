import 'package:abyadpos_tab/features/orders/presentation/controllers/order_cubit.dart';
import 'package:abyadpos_tab/features/orders/data/models/order_model.dart';
import 'package:abyadpos_tab/features/settings/presentation/widgets/add_customer_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:abyadpos_tab/core/widgets/common_widgets.dart';
import 'package:abyadpos_tab/features/home/presentation/widgets/custom_appbar.dart';
import 'package:abyadpos_tab/features/orders/presentation/controllers/order_state.dart';
import 'package:abyadpos_tab/core/theme/font_constants.dart';
import 'package:abyadpos_tab/core/widgets/custom_drawer.dart';
import 'package:abyadpos_tab/core/theme/app_colors.dart';
import 'package:abyadpos_tab/core/widgets/custom_button.dart'; // Ensure CustomButton is imported if it's external

import 'package:abyadpos_tab/features/settings/presentation/widgets/paginated_loans_table.dart';

class LoansScreen extends StatefulWidget {
  const LoansScreen({Key? key}) : super(key: key);

  @override
  _LoansScreenState createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey<PaginatedDataTableState> _tableKey = GlobalKey<PaginatedDataTableState>();
  // 1. New State Variable for the Filter

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 2. Initial load uses the new private method
      _loadData(context);
    });
  }

  // 3. Centralized data loading function
  Future<void> _loadData(BuildContext context, {String? search, bool isRefresh = false}) async {
    final cubit = BlocProvider.of<OrderCubit>(context, listen: false);

    // Clear search if toggling filters, unless this is a refresh
    if (!isRefresh && search == null) {
      searchController.clear();
    }

    await cubit.getLoans(
      pageNumber: 1,
      // FIX: Use provider.showDebtorsOnly (the central state) directly.
      only_with_loan: cubit.state.showDebtorsOnly,
      search: search ?? searchController.text,
    );
    _focusNode.unfocus();
  }

  // 4. Function to handle filter button taps

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      body: Row(
        children: [
          const CustomSideMenu(),
          Expanded(
            child: BlocBuilder<OrderCubit, OrderState>(
              builder: (context, state) {
                final bool isDebtorsFilterActive = state.showDebtorsOnly;
                final bool isLoanActive = state.userModel?.data.loan_active == true;
                return Column(
                  children: [
                    /// ---------------------- Custom App Bar ----------------------
                    CustomAppBar(
                      title: "customers_page".tr,
                      focusNode: _focusNode,
                      onSearch: (text) {
                        // Search function updates the text and calls loadData with search parameter
                        searchController.text = text;
                        _loadData(context, search: text);
                      },
                    ),
                    const SizedBox(height: 20),

                    // Back button (kept for consistency)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Row(
                            children: [
                              const SizedBox(width: 10),
                              const Icon(Icons.arrow_back_ios_new),
                              const SizedBox(width: 5),
                              Text(
                                "settings".tr,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontFamily: FontFamilyConstants.epilogue,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),
                        // const SizedBox(width: 20), // Added space for the filter

                        /// ---------------------- FILTER UI (NEW) ----------------------
                        // if(isLoanActive)

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min, // Keep the row compact
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _buildFilterButton(
                                label: "customers".tr, // Label for all customers
                                isSelected: !isDebtorsFilterActive,
                                onTap: () => _onFilterToggled(false),
                              ),
                              const SizedBox(width: 10),
                              _buildFilterButton(
                                label: "debtors".tr, // Label for debtors only
                                isSelected: isDebtorsFilterActive,
                                onTap: () => _onFilterToggled(true),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),
                        SizedBox(
                          width: 90,
                        ),
                        CustomButton(width: 120, text: "add_customer".tr, () {
                          showAddCustomerDialog(context);
                        }),

                        SizedBox(
                          width: 30,
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    /// ---------------------- BODY ----------------------
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () =>
                            _loadData(context, isRefresh: true), // Use new method for refresh

                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            if (state.allLoansModel == null) {
                              return Skeletonizer(
                                enabled: state.isLoading,
                                child: CommonWidgets.noDataView(
                                  title: "loading".tr,
                                  subText: "",
                                ),
                              );
                            }

                            final customers = state.allLoansModel!.data.customers;

                            // 5. Dynamic "No Data" Message
                            if (customers.isEmpty) {
                              String title;
                              if (isDebtorsFilterActive) {
                                title = "no_debtors_found".tr;
                                // If the user searched while on debtors view
                                if (searchController.text.isNotEmpty) {
                                  title = "no_debtors_match_search".tr;
                                }
                              } else {
                                title = "no_customers_found".tr;
                                if (searchController.text.isNotEmpty) {
                                  title = "no_customers_match_search".tr;
                                }
                              }

                              return CommonWidgets.noDataView(
                                title: title,
                                subText: "",
                              );
                            }

                            return SizedBox(
                              width: constraints.maxWidth,
                              child: LoansTable(
                                customers: customers,
                                cubit: context.read<OrderCubit>(),
                                onSearch: (value) {
                                  // Search from table also calls the unified loader
                                  searchController.text = value;
                                  _loadData(
                                    context,
                                    search: value,
                                  );
                                },
                                tableKey: _tableKey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onFilterToggled(bool isDebtors) {
    // 1. Reset the UI to Page 1 (index 0)
    // This fixes the bug where it shows no data if you were on page 13
    _tableKey.currentState?.pageTo(0);

    // 2. Clear the search bar UI
    searchController.clear();

    // 3. Call the provider to fetch new data
    context.read<OrderCubit>().setFilter(isDebtors);
  }

// REPLACED CUSTOM BUTTON with standard Flutter InkWell and Container
  Widget _buildFilterButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final Color? buttonColor = isSelected ? Color(0xffF5FCFF) : Colors.grey[200];
    final Color? textColor = isSelected ? AppColors.primaryColor : Colors.grey[600];

    final Border? border = isSelected ? null : Border.all(color: AppColors.primaryColor);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8), // Standard border radius for a button look
      child: Container(
        width: 160,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? Color(0xffF5FCFF) : Colors.grey[200],
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: FontConstants.font_14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,

            fontFamily: FontFamilyConstants.epilogue, // Assuming you use this font family
          ),
        ),
      ),
    );
  }
}
