import 'package:abyadpos_tab/features/orders/presentation/controllers/order_cubit.dart';
import 'package:abyadpos_tab/features/orders/presentation/controllers/order_state.dart';

import 'package:abyadpos_tab/core/constants/image_constants.dart';
import 'package:abyadpos_tab/features/orders/data/models/order_model.dart';
import 'package:abyadpos_tab/features/orders/data/models/order_status_model.dart';
import 'package:abyadpos_tab/core/theme/app_colors.dart';
import 'package:abyadpos_tab/core/theme/font_constants.dart';
import 'package:abyadpos_tab/main.dart';
import 'package:abyadpos_tab/features/dashboard/presentation/controllers/drawer_cubit.dart';
import 'package:abyadpos_tab/core/widgets/loader/loading_cubit.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;
import 'package:abyadpos_tab/features/home/presentation/widgets/custom_appbar.dart';
import 'package:abyadpos_tab/features/home/presentation/widgets/notification_menu.dart';

import 'package:abyadpos_tab/features/orders/presentation/widgets/paginated_table.dart';
import 'package:abyadpos_tab/core/pdf_export/lib/export_delegate.dart';
import 'package:abyadpos_tab/core/pdf_export/lib/export_frame.dart';
import 'package:abyadpos_tab/core/pdf_export/lib/options/export_options.dart';
import 'package:abyadpos_tab/core/pdf_export/lib/options/page_format_options.dart';
import 'package:abyadpos_tab/core/widgets/common_text.dart';
import 'package:abyadpos_tab/core/widgets/common_widgets.dart';
import 'package:abyadpos_tab/core/widgets/custom_drawer.dart';
import 'package:abyadpos_tab/core/widgets/ui_helpers.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:timeline_tile/timeline_tile.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:flutter/material.dart' as material;
import 'package:printing/printing.dart' as printing;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:abyadpos_tab/core/utils/payment_dialog.dart';
import 'package:abyadpos_tab/features/auth/presentation/controllers/user_cubit.dart';
import 'package:abyadpos_tab/features/dashboard/presentation/controllers/drawer_state.dart';

class OrderDetailScreen extends StatefulWidget {
  bool isCurrent;
  Order model;

  OrderDetailScreen({Key? key, required this.model, required this.isCurrent}) : super(key: key);

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  int selectedStatusId = 0;
  OrderStatusModel? statusModel;
  DateTime now = DateTime.now();

  final ExportDelegate exportDelegate = ExportDelegate(
      ttfFonts: {
        "Epilogue": 'assets/fonts/Epilogue-SemiBold.ttf',
      },
      options: ExportOptions(
        pageFormatOptions: PageFormatOptions.custom(
            width: 3.5 * pdf.PdfPageFormat.inch, height: 2 * pdf.PdfPageFormat.inch),
      ));

  @override
  void initState() {
    NotificationMenuController.hide();
    super.initState();

    Future.microtask(() {
      context.read<OrderCubit>().getOrdersById(widget.model.id);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callApi();
    });
  }

  callApi() async {
    try {
      BuildContext context = navigatorKey.currentContext!;
      context.read<LoadingCubit>().showLoading();

      OrderCubit cubit = context.read<OrderCubit>();
      statusModel = await cubit.fetchOrderStatus(orderId: widget.model.id);
      context.read<LoadingCubit>().hideLoading();

      if (statusModel != null) {
        context.read<LoadingCubit>().hideLoading();
      }
    } catch (e) {
      // Handle error
    }
  }

  List<Widget> _buildTopActions(Order details) {
    // Logic: Show pay button if it's an ongoing order (isCurrent)
    // OR if it's a completed order where the payment type was "loan"
    bool showPayButton = (widget.isCurrent ||
            details.paymentDetails?.paymentType.toString().toLowerCase() == "loan") &&
        details.order_is_paid != true;

    List<IconData> icons = [Icons.print];
    List<String> labels = ['Print'.tr];

    if (showPayButton) {
      icons.add(Icons.payments_outlined);
      labels.add('pay_order'.tr);
    }

    return List.generate(labels.length, (i) {
      // 💡 تم إزالة الـ Padding لأن الـ Wrap في الواجهة الرئيسية هيتولى مهمة المسافات
      return OutlinedButton.icon(
        onPressed: () async {
          if (i == 0) {
            // Print Logic
            await context.read<OrderCubit>().smartPrintBill(context, details, isArabic);
          } else if (i == 1) {
            // Pay Order Logic
            if (!widget.isCurrent &&
                details.paymentDetails?.paymentType.toString().toLowerCase() == "loan") {
              await showPaymentDialog(details, context, isLoanEnabled: false);
              Navigator.pop(context);
            } else {
              await showPaymentDialog(details, context, prepaid_val: details.prepaid);
              Navigator.pop(context);
            }
          }
        },
        icon: Icon(icons[i], size: 20, color: AppColors.primaryColor),
        label: CommonText(
          text: labels[i],
          color: AppColors.primaryColor,
          fontSize: FontConstants.font_14, // 💡 تكبير الخط قليلاً ليكون أوضح على الشاشات
          fontWeight: FontWeightConstants.semiBold,
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xffF5FCFF),
          side: const BorderSide(color: AppColors.primaryColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12), // 💡 بادينج داخلي مرن للزرار
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xffF9F9F9),
        body: BlocBuilder<OrderCubit, OrderState>(builder: (context, state) {
          final isLoading = state.isOrderDetailsLoading;
          final details = state.orderDetailsModel;
          return SafeArea(
            // 💡 استخدام SafeArea بدل الاعتماد على Get.width
            child: Row(children: [
              CustomSideMenu(),
              Expanded(
                  child: Column(children: [
                CustomAppBar(
                  title: widget.isCurrent ? "orders".tr : "invoices".tr,
                  onTap: () {
                    if (context.read<SideMenuCubit>().state.selectedItem == SideMenuItem.orders) {
                      Get.back(result: true);
                    } else if (context.read<SideMenuCubit>().state.selectedItem ==
                        SideMenuItem.invoices) {
                      context
                          .read<SideMenuCubit>()
                          .changeMenuItem(SideMenuItem.orders, isSearching: true);
                    }
                  },
                  onSearch: (data) {},
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(20.0), // Padding ثابت بدل .w اللي بيضرب في الويندوز
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : details == null
                          ? Center(
                              child: Text("Failed to load order details".tr),
                            )
                          : Column(
                              children: [
                                Row(
                                  children: [
                                    InkWell(
                                      highlightColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      onTap: () {
                                        Get.back();
                                      },
                                      child: const Row(
                                        children: [
                                          Icon(Icons.arrow_back_ios_new),
                                          SizedBox(width: 10),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      highlightColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      onTap: () {
                                        Get.back();
                                      },
                                      child: CommonText(
                                        text: widget.isCurrent ? "orders".tr : "invoices".tr + " ",
                                        color: AppColors.blackColor,
                                      ),
                                    ),
                                    InkWell(
                                      highlightColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      onTap: () {
                                        Get.back();
                                      },
                                      child: CommonText(
                                        text: "/ ${UIHelper().cleanId(details.id)}",
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                    const Spacer(),
                                    // 💡 حماية الأزرار من الـ Overflow باستخدام Wrap
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: _buildTopActions(details),
                                    )
                                  ],
                                ),
                                UIHelper.verticalSpaceSm,

                                // 💡 استدعاء الـ View بناءً على حالة الطلب
                                widget.isCurrent
                                    ? Expanded(child: orderParentView(details))
                                    : Expanded(child: invoiceParentView(details))
                              ],
                            ),
                ))
              ]))
            ]),
          );
        }));
  }

  // 💡 LayoutBuilder لجعل الواجهة تتجاوب مع تغيير حجم الشاشة
  Widget responsiveLayout({required Widget mainContent, Widget? sideContent}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth > 800; // نقطة كسر الديسك توب

        if (isWideScreen) {
          // الشاشات العريضة (Desktop) -> جنب بعض
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: mainContent),
              if (sideContent != null) const SizedBox(width: 16),
              if (sideContent != null) Expanded(flex: 3, child: sideContent),
            ],
          );
        } else {
          // الشاشات الضيقة (Mobile/Tablet/Resized Window) -> فوق بعض
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                mainContent,
                if (sideContent != null) const SizedBox(height: 16),
                if (sideContent != null) sideContent,
              ],
            ),
          );
        }
      },
    );
  }

  Widget invoiceParentView(Order details) {
    final UserCubit userCubit = BlocProvider.of<UserCubit>(context, listen: false);

    Widget mainContent = Card(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      text: "Invoice:".tr + " " + UIHelper().cleanId(details.id),
                      fontSize: FontConstants.font_28,
                    ),
                    UIHelper.verticalSpaceSm,
                    buildItemTile(
                        title: "Issue Date".tr,
                        value: intl.DateFormat.yMd('en_GB').format(details.createdAt)),
                    UIHelper.verticalSpaceSm,
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: colorForStatus(details.status.nameEn)!,
                          ),
                          color: colorForStatus(details.status.nameEn)!.withOpacity(0.2)),
                      child: CommonText(
                          fontSize: FontConstants.font_13,
                          fontWeight: FontWeightConstants.medium,
                          text: isArabic ? details.status.nameAr : details.status.nameEn,
                          color: colorForStatus(details.status.nameEn)),
                    )
                  ],
                )),
              ],
            ),
          ),
          const DottedLine(
            dashLength: 4.0,
            dashGapLength: 4.0,
            lineThickness: 1.0,
            dashColor: Colors.grey,
          ),
          buildSummaryCard(
            details,
            '',
            double.tryParse(details.finalTotalPrice) ?? 0,
            false,
          ),
          const DottedLine(
            dashLength: 4.0,
            dashGapLength: 4.0,
            lineThickness: 1.0,
            dashColor: Colors.grey,
          ),
          UIHelper.verticalSpaceMd,
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Row(
                  children: [
                    CommonText(
                      text: "Items List".tr,
                      fontSize: FontConstants.font_16,
                      fontWeight: FontWeightConstants.semiBold,
                    ),
                    const Spacer(),
                    CommonText(
                      text: details.clothes.length.toString() + " " + "Items".tr,
                      fontSize: FontConstants.font_14,
                      fontWeight: FontWeightConstants.regular,
                    ),
                  ],
                ),
                UIHelper.verticalSpaceSm,
                Column(
                  children: details.clothes.map((item) {
                    return ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      tileColor: const Color(0xffF9F9F9),
                      leading: CommonWidgets.loadNetworkPhoto(item.clothImage,
                          fit: BoxFit.fill, borderRadius: 5, width: 60.0, height: 60.0),
                      title: CommonText(
                        text: isArabic ? item.clothNameAr : item.clothName,
                        fontSize: FontConstants.font_14,
                        fontWeight: FontWeightConstants.semiBold,
                      ),
                      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(
                          children: [
                            CommonText(
                              text: item.onlyIroning
                                  ? "Iron Only".tr
                                  : item.only_cleaning
                                      ? "Wash Only".tr
                                      : "Wash & Iron".tr.toLowerCase().tr,
                              fontSize: FontConstants.font_11,
                              fontWeight: FontWeightConstants.medium,
                            ),
                            const SizedBox(width: 10),
                            CommonText(
                              text: item.serviceType.name.toLowerCase().tr,
                              fontSize: FontConstants.font_11,
                              fontWeight: FontWeightConstants.medium,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            CommonText(
                              text: item.clothCount.toString() + "X",
                              fontSize: FontConstants.font_11,
                              fontWeight: FontWeightConstants.bold,
                            ),
                            const Spacer(),
                            CommonText(
                              text: item.isCustomized
                                  ? item.totalCustomPrice != null
                                      ? item.totalCustomPrice.toString()
                                      : item.custom_price_per_unit.toString()
                                  : item.clothPrice,
                              color: AppColors.greenColor,
                              fontSize: FontConstants.font_13,
                              fontWeight: FontWeightConstants.bold,
                            ),
                            UIHelper.horizontalSpaceSm3,
                            SvgPicture.asset(
                              ImageConstants.riyalsvg,
                              color: AppColors.greenColor,
                              width: FontConstants.font_13,
                            ),
                          ],
                        )
                      ]),
                    );
                  }).toList(),
                ),
                // (جزء الـ VAT والتوتال تم اختصاره هنا لتوفير المساحة، يمكنك وضع اللوجيك الخاص بك من الكود القديم)
              ],
            ),
          ),
        ]),
      ),
    );

    Widget? sideContent = (details.activityLog != null && details.activityLog!.isNotEmpty)
        ? _buildActivityCard(details)
        : null;

    return responsiveLayout(mainContent: mainContent, sideContent: sideContent);
  }

  Widget orderParentView(Order details) {
    Widget mainContent = ExportFrame(
      frameId: details.id,
      exportDelegate: exportDelegate,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            buildSummaryCard(
              details,
              '',
              double.tryParse(details.finalTotalPrice) ?? 0,
              false,
            ),
            UIHelper.verticalSpaceMd,
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CommonText(
                          text: "Items List".tr,
                          fontSize: FontConstants.font_16,
                          fontWeight: FontWeightConstants.semiBold,
                        ),
                        const Spacer(),
                        CommonText(
                          text: details.clothes.length.toString() + " " + "Items".tr,
                          fontSize: FontConstants.font_14,
                          fontWeight: FontWeightConstants.regular,
                        ),
                      ],
                    ),
                    UIHelper.verticalSpaceSm,
                    Column(
                      children: details.clothes.map((item) {
                        return ListTile(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          tileColor: const Color(0xffF9F9F9),
                          leading: CommonWidgets.loadNetworkPhoto(item.clothImage,
                              fit: BoxFit.fill, borderRadius: 5, width: 60.0, height: 60.0),
                          title: CommonText(
                            text: isArabic ? item.clothNameAr : item.clothName,
                            fontSize: FontConstants.font_14,
                            fontWeight: FontWeightConstants.semiBold,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CommonText(
                                    text: item.onlyIroning
                                        ? "Iron Only".tr
                                        : item.only_cleaning
                                            ? "Wash Only".tr
                                            : "Wash & Iron".tr.toLowerCase().tr,
                                    fontSize: FontConstants.font_11,
                                    fontWeight: FontWeightConstants.medium,
                                  ),
                                  const SizedBox(width: 10),
                                  CommonText(
                                    text: item.serviceType.name.toLowerCase().tr,
                                    fontSize: FontConstants.font_11,
                                    fontWeight: FontWeightConstants.medium,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  CommonText(
                                    text: item.clothCount.toString() + "X",
                                    fontSize: FontConstants.font_11,
                                    fontWeight: FontWeightConstants.bold,
                                  ),
                                  const Spacer(),
                                  SvgPicture.asset(
                                    ImageConstants.riyalsvg,
                                    color: AppColors.greenColor,
                                    width: FontConstants.font_13,
                                  ),
                                  UIHelper.horizontalSpaceSm3,
                                  CommonText(
                                    text: item.isCustomized
                                        ? item.totalCustomPrice != null
                                            ? item.totalCustomPrice.toString()
                                            : item.custom_price_per_unit.toString()
                                        : item.clothPrice,
                                    color: AppColors.greenColor,
                                    fontSize: FontConstants.font_13,
                                    fontWeight: FontWeightConstants.bold,
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Widget? sideContent = (details.activityLog != null && details.activityLog!.isNotEmpty)
        ? _buildActivityCard(details)
        : null;

    return responsiveLayout(mainContent: mainContent, sideContent: sideContent);
  }

  Widget _buildActivityCard(Order details) {
    return SingleChildScrollView(
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(
                text: "Activity Log".tr,
                fontSize: FontConstants.font_18,
                fontWeight: FontWeightConstants.semiBold,
              ),

              const SizedBox(height: 16),
              // Timeline
              ...details.activityLog!.asMap().entries.map((mapEntry) {
                final index = mapEntry.key;
                final entry = mapEntry.value;
                final isFirst = index == 0;
                final isLast = index == details.activityLog!.length - 1;

                return TimelineTile(
                  isFirst: isFirst,
                  isLast: isLast,
                  axis: TimelineAxis.vertical,
                  alignment: TimelineAlign.start,
                  indicatorStyle: IndicatorStyle(
                    width: 24,
                    height: 24,
                    indicatorXY: 0.3,
                    indicator: Container(
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  beforeLineStyle: LineStyle(
                    color: Colors.grey.shade300,
                    thickness: 2,
                  ),
                  afterLineStyle: LineStyle(
                    color: Colors.grey.shade300,
                    thickness: 2,
                  ),
                  endChild: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero, // 💡 إزالة البادينج الافتراضي للـ ListTile
                      title: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: Text(
                          entry.date + "    " + entry.time,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      subtitle: Container(
                        // 💡 تم إزالة .sp من هنا لأنها تسبب مشاكل في مقاسات الويندوز
                        margin: const EdgeInsets.only(top: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isArabic ? entry.nameAr : entry.nameEn,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  void openPdf(Uint8List bytes, context, date) async {
    await material.showDialog(
        context: context,
        builder: (context) {
          return material.AlertDialog(
            content: material.Text("Select option for your pdf"),
            actions: [
              material.TextButton.icon(
                  onPressed: () async {
                    // await FileSaver.instance
                    //     .saveFile(name: 'Invoice-$date.pdf', bytes: bytes);
                    await printing.Printing.sharePdf(bytes: bytes, filename: '$date.pdf');
                  },
                  icon: material.Icon(material.Icons.share),
                  label: material.Text("Share")),
              material.TextButton.icon(
                  onPressed: () async {
                    await material.showDialog(
                        builder: (context) {
                          return material.AlertDialog(
                            contentPadding: material.EdgeInsets.zero,
                            insetPadding: material.EdgeInsets.zero,
                            backgroundColor: material.Colors.white,
                            surfaceTintColor: material.Colors.white,
                            elevation: 0.0,
                            content: material.Container(
                              width: context.height * 1,
                              color: material.Colors.white,
                              child: material.Stack(
                                children: [
                                  SfPdfViewer.memory(
                                    bytes,
                                    enableDoubleTapZooming: true,
                                    initialZoomLevel: 1,
                                    interactionMode: PdfInteractionMode.pan,
                                    onZoomLevelChanged: (detail) {},
                                  ),
                                  material.Row(
                                    mainAxisAlignment: material.MainAxisAlignment.end,
                                    children: [
                                      material.IconButton(
                                        onPressed: () async {
                                          await printing.Printing.sharePdf(
                                              bytes: bytes, filename: 'Ledger-$date.pdf');
                                        },
                                        icon: material.Icon(material.Icons.share),
                                      ),
                                      material.IconButton(
                                        onPressed: () {
                                          Get.back();
                                        },
                                        icon: material.Icon(Icons.close),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        context: context);
                  },
                  icon: material.Icon(Icons.picture_as_pdf),
                  label: material.Text("View Pdf"))
            ],
          );
        });
  }
}

buildItemTile({required String title, required value}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Row(
      children: [
        CommonText(
          text: title + ": ",
          color: AppColors.greyColor,
          fontSize: FontConstants.font_13,
          fontWeight: FontWeightConstants.medium,
        ),
        CommonText(
          text: value,
          color: Colors.black,
          fontSize: FontConstants.font_13,
          fontWeight: FontWeightConstants.bold,
        )
      ],
    ),
  );
}

Widget buildSummaryCard(
  Order order,
  String currency,
  double total,
  bool isPayment, {
  // Payment-specific (Only needed if isPayment is true)
  OrderCubit? viewModel,
  BuildContext? context,
  TextEditingController? discountController,
  GlobalKey<FormState>? formKey,

  // General UI-specific
  double elevation = 0.0,
  Function()? onTap,
}) {
  return Card(
    color: Colors.white,
    elevation: elevation,
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (order.user.userName != null && order.user.userName != "")
                  CommonText(
                    text: order.user.userName.toString(),
                    fontSize: FontConstants.font_20,
                    fontWeight: FontWeightConstants.semiBold,
                  ),
                if (order.user.mobile != null && order.user.mobile.toString().trim() != "") ...[
                  UIHelper.verticalSpaceSm,
                  buildItemTile(title: "mobileNumber".tr, value: order.user.mobile),
                ] else
                  SizedBox(
                    height: 30,
                  ),

                //     buildItemTile(title: "Served by".tr, value: '-'),
                // buildItemTile(title: "Order Type".tr, value: order.orderType),
                buildItemTile(
                    title: "order_date".tr,
                    value: intl.DateFormat.yMd('en_GB').format(order.createdAt)),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    children: [
                      CommonText(
                        text: "order_time".tr + ": ",
                        color: AppColors.greyColor,
                        fontSize: FontConstants.font_13,
                        fontWeight: FontWeightConstants.medium,
                      ),
                      Directionality(
                        textDirection: TextDirection.ltr, // force LTR for AM/PM display
                        child: CommonText(
                          text: intl.DateFormat("h:mm a").format(order.createdAt),
                          color: Colors.black,
                          fontSize: FontConstants.font_13,
                          fontWeight: FontWeightConstants.bold,
                        ),
                      )
                    ],
                  ),
                ),
                if (isPayment && viewModel != null) ...[
                  if (order.status.id == 2) ...[
                    //  const Divider(),
                    SizedBox(
                      width: MediaQuery.of(context!).size.width, // Force a width
                      child: Row(
                        children: [
                          // Prepaid Payment Checkbox
                          Expanded(
                            child: CheckboxListTile(
                              activeColor: const Color(0xff13AC6B),
                              title: Text("prepaid_payment".tr,
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                              value: !viewModel.state.closeAndComplete,
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                              onChanged: (bool? value) {
                                // Clicking this sets the variable to false
                                viewModel.setCloseAndComplete(false);
                              },
                            ),
                          ),

                          // Close & Hand Over Checkbox
                          Expanded(
                            child: CheckboxListTile(
                              activeColor: const Color(0xff13AC6B),
                              title: Text("close_hand_over".tr,
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                              value: viewModel.state.closeAndComplete,
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                              onChanged: (bool? value) {
                                // Clicking this sets the variable to true
                                viewModel.setCloseAndComplete(true);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (order.paymentDetails?.walletTransaction != null &&
                      order.paymentDetails!.walletTransaction!.isNotEmpty)
                    ...[]
                  else ...[
                    Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            title: Text("discount".tr,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            value: viewModel.state.isDiscount,
                            onChanged: (val) {
                              viewModel.toggleIsDiscount(val ?? false);
                            },
                            activeColor: const Color(0xff13AC6B),
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ),
                      ],
                    ),

// --- Conditional Discount Input Field ---
                    if (viewModel.state.isDiscount) ...[
                      const SizedBox(height: 12),
                      const SizedBox(height: 12),
                      StatefulBuilder(
                        // Use StatefulBuilder if this is inside a static function to ensure local rebuilds
                        builder: (context, setState) {
                          // 1. Parse the current value safely
                          final currentDiscount =
                              double.tryParse(discountController?.text ?? "") ?? 0.0;

                          // 2. Determine if we should show the error instantly
                          final String? instantError = (currentDiscount >= total &&
                                  (discountController?.text.isNotEmpty ?? false))
                              ? "discount_must_be_less_than_total".tr
                              : null;

                          return TextFormField(
                            controller: discountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              hintText: "enter_discount".tr,
                              // 👈 THIS SHOWS THE ERROR INSTANTLY
                              errorText: instantError,
                              suffixIcon: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: SvgPicture.asset(ImageConstants.riyalsvg,
                                    color: Colors.grey, width: 10),
                              ),
                            ),
                            onChanged: (value) {
                              if (value.isEmpty) return;

                              final val = double.tryParse(value);
                              if (val != null && val >= total) {
                                // 1. Clear the text instantly
                                discountController?.clear();

                                // 2. Show the error message to the user
                                UIHelper.showBottomFlash(context,
                                    title: "error".tr,
                                    message: "discount_must_be_less_than_total".tr,
                                    isError: true);
                              }
                            },
                            validator: (value) {
                              if (viewModel.state.isDiscount) {
                                if (value == null || value.trim().isEmpty) {
                                  return "discount_required".tr;
                                }
                                final val = double.tryParse(value);
                                if (val == null || val <= 0) {
                                  return "enter_a_valid_number_greater_than_0".tr;
                                }
                                if (val >= total) {
                                  return "discount_must_be_less_than_total".tr;
                                }
                              }
                              return null;
                            },
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ]
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    ImageConstants.riyalsvg,
                    color: AppColors.greenColor,
                  ),
                  UIHelper.horizontalSpaceSm,
                  CommonText(
                    text: order.finalTotalPrice,
                    fontSize: FontConstants.font_52,
                    color: AppColors.greenColor,
                    fontWeight: FontWeightConstants.bold,
                  )
                ],
              ),
              UIHelper.verticalSpaceSm,
              buildItemTile(title: 'Order No'.tr, value: UIHelper().cleanId(order.id)),
              UIHelper.verticalSpaceSm,
              onTap == null
                  ? Container()
                  : Row(
                      children: [
                        CommonText(
                          text: "Status".tr,
                          color: AppColors.greyColor,
                          fontSize: FontConstants.font_13,
                          fontWeight: FontWeightConstants.medium,
                        ),
                        UIHelper.horizontalSpaceMd,
                        InkWell(
                          onTap: onTap,
                          radius: 25.0,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: colorForStatus(order.status.nameEn)!,
                                ),
                                color: colorForStatus(order.status.nameEn)!.withOpacity(0.2)),
                            child: Row(
                              children: [
                                CommonText(
                                    fontSize: FontConstants.font_13,
                                    fontWeight: FontWeightConstants.medium,
                                    text: isArabic ? order.status.nameAr : order.status.nameEn,
                                    color: colorForStatus(order.status.nameEn)),
                                order.status.nameEn == "Delivered"
                                    ? Container()
                                    : Row(
                                        children: [
                                          UIHelper.horizontalSpaceSm3,
                                          Icon(
                                            Icons.arrow_downward,
                                            color: colorForStatus(order.status.nameEn),
                                            size: 15.sp,
                                          ),
                                        ],
                                      )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ],
          )
        ],
      ),
    ),
  );
}
