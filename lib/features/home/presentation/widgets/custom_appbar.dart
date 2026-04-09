import 'package:abyadpos_tab/core/storage/sharedpref.dart';
import 'package:abyadpos_tab/core/theme/app_colors.dart';
import 'package:abyadpos_tab/core/theme/font_constants.dart';
import 'package:abyadpos_tab/main.dart';
import 'package:abyadpos_tab/features/auth/presentation/controllers/user_cubit.dart';
import 'package:abyadpos_tab/features/auth/presentation/controllers/user_state.dart';
import 'package:abyadpos_tab/core/widgets/loader/loading_cubit.dart';
import 'package:abyadpos_tab/features/scanner/presentation/controllers/scanning_cubit.dart';
import 'package:abyadpos_tab/core/widgets/common_text.dart';
import 'package:abyadpos_tab/core/widgets/ui_helpers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatefulWidget {
  final String title;
  final ValueChanged<String> onSearch;
  final String? initialValue;
  Function()? onTap;
  var focusNode;
  var isSearchable;

  final ValueChanged<String>? onMenuSelected;

  CustomAppBar(
      {Key? key,
      required this.title,
      required this.onSearch,
      this.initialValue,
      this.isSearchable = true,
      this.onMenuSelected,
      this.onTap,
      this.focusNode})
      : super(key: key);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  late TextEditingController controller;

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  void initState() {
    super.initState();
    // Initialize the controller with the initialValue if it exists
    controller = TextEditingController(text: widget.initialValue ?? "");
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 💡 1. استخدام MediaQuery لمعرفة عرض الشاشة الحالي
    double screenWidth = MediaQuery.of(context).size.width;
    bool isSmallScreen = screenWidth < 700; // نقطة الكسر (Breakpoint)

    return BlocBuilder<UserCubit, UserState>(builder: (
      context,
      state,
    ) {
      return Container(
        height: preferredSize.height,
        padding: const EdgeInsets.only(left: 16, right: 15, top: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title
            CommonText(
              text: widget.title,
              fontSize: FontConstants.font_18,
              fontWeight: FontWeight.bold,
            ),

            const Spacer(),

            // Search field (💡 2. أصبح مرناً بدلاً من عرض ثابت 250)
            if (widget.isSearchable) ...[
              Flexible(
                flex: 2,
                child: ConstrainedBox(
                  // الحقل هيتمدد لحد 300 بكسل كحد أقصى، ولو الشاشة صغرت هيصغر معاها
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                    child: TextField(
                      onSubmitted: widget.onSearch,
                      controller: controller,
                      focusNode: widget.focusNode,
                      onTap: widget.onTap,
                      onChanged: (va) {},
                      decoration: InputDecoration(
                          hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: FontConstants.font_14, color: AppColors.hintColor),
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          hintText: 'search'.tr,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          border: InputBorder.none,
                          suffixIcon: controller.text.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () {
                                    setState(() {
                                      controller.clear();
                                    });
                                    widget.onSearch("");
                                  },
                                  icon: const Icon(Icons.clear))),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],

            Visibility(
              visible: false,
              child: IconButton(
                  onPressed: () async {
                    scanQR();
                  },
                  icon: const Icon(Icons.qr_code_scanner)),
            ),

            const VerticalDivider(
              indent: 15.0,
              endIndent: 15.0,
            ),
            UIHelper.horizontalSpaceSm5,

            // User menu
            PopupMenuButton<String>(
              onSelected: widget.onMenuSelected,
              offset: const Offset(0, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'logout',
                  child: CommonText(text: "logout".tr),
                  onTap: () {
                    UIHelper().protectedAction(
                      context: context,
                      backendPassword: "0000",
                      onAuthorized: () {
                        UIHelper.showDialogOk(
                          context,
                          title: "Logout".tr,
                          message: "Are you sure want to logout".tr,
                          onConfirm: () {
                            Navigator.pop(context);
                            context.read<LoadingCubit>().showLoading();
                            context.read<UserCubit>().logout(context);
                            context.read<LoadingCubit>().hideLoading();
                          },
                        );
                      },
                    );
                  },
                ),
              ],
              child: Row(
                mainAxisSize: MainAxisSize.min, // 💡 يمنع التمدد غير المبرر
                children: [
                  buildAvatar(),
                  // 💡 3. إخفاء الاسم وإظهار السهم والصورة فقط لو الشاشة صغيرة جداً
                  if (!isSmallScreen) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        state.userModel != null ? state.userModel!.data.name : "",
                        style: const TextStyle(fontSize: 16, color: Color(0xFF0D1F3C)),
                        maxLines: 1, // 💡 منع النزول لسطر جديد
                        overflow: TextOverflow.ellipsis, // 💡 وضع ... لو الاسم طويل
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  ]
                ],
              ),
            ),

            const VerticalDivider(
              indent: 15.0,
              endIndent: 15.0,
            ),

            const SizedBox(width: 8),

            // Language switcher
            GestureDetector(
              onTap: () {
                if (isArabic) {
                  Get.updateLocale(const Locale('en', 'US'));
                  SharedPref().setString('language', 'en');
                  isArabic = false;
                } else {
                  Get.updateLocale(const Locale('ar', 'SA'));
                  SharedPref().setString('language', 'ar');
                  isArabic = true;
                }
              },
              child: Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.language, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(isArabic ? "En" : "Ar", style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget buildAvatar() {
    return BlocBuilder<UserCubit, UserState>(builder: (
      builder,
      state,
    ) {
      final name = state.userModel?.data.name ?? "";
      final logo = state.userModel?.data.logo;
      print("This Name =$name");
      if (logo == null ||
          logo.isEmpty ||
          logo == "https://abyad.sa/uploads" ||
          logo == "https://dev.abyad.sa/uploads") {
        return CircleAvatar(
          backgroundColor: Colors.blue[50],
          child: Text(
            name.isNotEmpty
                ? UIHelper.getShortName(string: state.userModel?.data.name ?? "", limitTo: 1)
                : "?", // fallback if name is empty
            style: const TextStyle(color: Colors.blue),
          ),
        );
      } else {
        return CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(logo),
        );
      }
    });
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.QR,
      );

      ScanningCubit scanningCubit = context.read<ScanningCubit>();
      scanningCubit.processScannedOrder(barcodeScanRes, context);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;
  }
}
