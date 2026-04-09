import 'dart:async';

import 'package:abyadpos_tab/core/config/api_client.dart';

import 'package:abyadpos_tab/features/orders/presentation/controllers/order_cubit.dart';

import 'package:abyadpos_tab/core/constants/app_value_constants.dart';
import 'package:abyadpos_tab/core/localization/locale_controller.dart';
import 'package:abyadpos_tab/core/theme/responsive.dart';
import 'package:abyadpos_tab/core/theme/font_constants.dart';
import 'package:abyadpos_tab/features/auth/presentation/controllers/user_cubit.dart';
import 'package:abyadpos_tab/features/dashboard/presentation/controllers/drawer_cubit.dart';

import 'package:abyadpos_tab/features/home/presentation/widgets/notification_menu.dart';
import 'package:abyadpos_tab/features/home/presentation/controllers/notification_cubit.dart';
import 'package:abyadpos_tab/core/widgets/loader/loading_cubit.dart';
import 'package:abyadpos_tab/core/widgets/loader/loading_state.dart';
import 'package:abyadpos_tab/features/splash/presentation/screens/splashscreen.dart';
import 'package:abyadpos_tab/features/scanner/presentation/controllers/scanning_cubit.dart';
import 'package:abyadpos_tab/core/utils/exit_app_wrapper.dart';
import 'package:abyadpos_tab/core/utils/restart_widget.dart';
import 'package:abyadpos_tab/core/widgets/common_text.dart';
import 'package:abyadpos_tab/core/widgets/loader/loading_dialog.dart';
import 'package:abyadpos_tab/core/widgets/ui_helpers.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_terminal_sdk/models/terminal_response.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'package:intl/date_symbol_data_local.dart';

import 'package:toastification/toastification.dart';

import 'package:abyadpos_tab/firebase_options.dart';
import 'package:abyadpos_tab/core/widgets/custom_drawer.dart';

bool isArabic = false;
bool isMobile = true;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    ConnectivityWrapper.instance.addresses = [
      AddressCheckOptions(
        hostname: 'abyad.sa',
        port: 443,
      ),
    ];

    await initializeDateFormatting('en_GB', null);
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    FlutterError.onError = (details) {
      FlutterError.presentError(details);

      final bool isNetworkError = details.exception.toString().contains('Connection closed') ||
          details.exception.toString().contains('ClientException');

      if (isNetworkError) {
      } else {}
    };

    runApp(
      BlocProvider(
        create: (_) => SideMenuCubit(),
        child: RestartWidget(
          child: const ExitAppWrapper(child: MyApp()),
        ),
      ),
    );
  }, (error, stack) {});
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FocusNode _scannerFocusNode = FocusNode(canRequestFocus: true, skipTraversal: true);
  String _barcodeBuffer = '';
  DateTime _lastKeyPressTime = DateTime.now();

  String barcode = '';
  bool shiftPressed = false;
  TerminalModel? _connectedTerminal;

  @override
  void initState() {
    super.initState();

    _scannerFocusNode.addListener(() {
      if (_scannerFocusNode.hasFocus) {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      } else {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (FocusManager.instance.primaryFocus == null ||
              FocusManager.instance.primaryFocus is! FocusNode) {
            _scannerFocusNode.requestFocus();
          }
        });
      }
    });
  }

  void _handleScannedCode(String code) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      String finalId = _extractOrderId(code);
      print("🔍 Processed ID: $finalId");
      context.read<ScanningCubit>().processScannedOrder(finalId, context);
    }
  }

  String _extractOrderId(String input) {
    try {
      String cleanedInput = input.trim().toUpperCase();

      if (cleanedInput.contains('ORDERID=')) {
        String idPart = cleanedInput.split('ORDERID=').last;

        if (idPart.contains('/')) {
          idPart = idPart.split('/').first;
        }

        return idPart.trim();
      }

      return cleanedInput;
    } catch (e) {
      print("❌ Error parsing: $e");
      return input.trim();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    isMobile = MyResponsive.isMobile(context);
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
      isMobile
          ? [DeviceOrientation.landscapeLeft]
          : [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
    );

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
      ),
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SideMenuCubit(),
        ),
        BlocProvider(
          create: (context) => LoadingCubit(),
        ),
        BlocProvider(
          create: (context) => NotificationCubit(),
        ),
        BlocProvider(
          create: (context) => UserCubit(ApiClient()),
        ),
        BlocProvider(
          create: (context) => OrderCubit(),
        ),
        BlocProvider(
          create: (context) => ScanningCubit(),
        )
      ],
      child: KeyboardListener(
        focusNode: _scannerFocusNode,
        autofocus: true,
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent) {
            final now = DateTime.now();
            final diff = now.difference(_lastKeyPressTime).inMilliseconds;
            _lastKeyPressTime = now;

            if (diff < 50 && _barcodeBuffer.length > 1) {
              if (_scannerFocusNode.canRequestFocus) {
                _scannerFocusNode.requestFocus();
              }
            }

            if (diff > 50) {
              _barcodeBuffer = '';
            }

            final key = event.physicalKey;

            if (key == PhysicalKeyboardKey.enter || key == PhysicalKeyboardKey.numpadEnter) {
              if (_barcodeBuffer.isNotEmpty) {
                _handleScannedCode(_barcodeBuffer);
                _barcodeBuffer = '';
              }
            } else {
              String? char;

              if (key == PhysicalKeyboardKey.keyA)
                char = 'A';
              else if (key == PhysicalKeyboardKey.keyB)
                char = 'B';
              else if (key == PhysicalKeyboardKey.keyC)
                char = 'C';
              else if (key == PhysicalKeyboardKey.keyD)
                char = 'D';
              else if (key == PhysicalKeyboardKey.keyE)
                char = 'E';
              else if (key == PhysicalKeyboardKey.keyF)
                char = 'F';
              else if (key == PhysicalKeyboardKey.keyG)
                char = 'G';
              else if (key == PhysicalKeyboardKey.keyH)
                char = 'H';
              else if (key == PhysicalKeyboardKey.keyI)
                char = 'I';
              else if (key == PhysicalKeyboardKey.keyJ)
                char = 'J';
              else if (key == PhysicalKeyboardKey.keyK)
                char = 'K';
              else if (key == PhysicalKeyboardKey.keyL)
                char = 'L';
              else if (key == PhysicalKeyboardKey.keyM)
                char = 'M';
              else if (key == PhysicalKeyboardKey.keyN)
                char = 'N';
              else if (key == PhysicalKeyboardKey.keyO)
                char = 'O';
              else if (key == PhysicalKeyboardKey.keyP)
                char = 'P';
              else if (key == PhysicalKeyboardKey.keyQ)
                char = 'Q';
              else if (key == PhysicalKeyboardKey.keyR)
                char = 'R';
              else if (key == PhysicalKeyboardKey.keyS)
                char = 'S';
              else if (key == PhysicalKeyboardKey.keyT)
                char = 'T';
              else if (key == PhysicalKeyboardKey.keyU)
                char = 'U';
              else if (key == PhysicalKeyboardKey.keyV)
                char = 'V';
              else if (key == PhysicalKeyboardKey.keyW)
                char = 'W';
              else if (key == PhysicalKeyboardKey.keyX)
                char = 'X';
              else if (key == PhysicalKeyboardKey.keyY)
                char = 'Y';
              else if (key == PhysicalKeyboardKey.keyZ)
                char = 'Z';
              else if (key == PhysicalKeyboardKey.digit0 || key == PhysicalKeyboardKey.numpad0)
                char = '0';
              else if (key == PhysicalKeyboardKey.digit1 || key == PhysicalKeyboardKey.numpad1)
                char = '1';
              else if (key == PhysicalKeyboardKey.digit2 || key == PhysicalKeyboardKey.numpad2)
                char = '2';
              else if (key == PhysicalKeyboardKey.digit3 || key == PhysicalKeyboardKey.numpad3)
                char = '3';
              else if (key == PhysicalKeyboardKey.digit4 || key == PhysicalKeyboardKey.numpad4)
                char = '4';
              else if (key == PhysicalKeyboardKey.digit5 || key == PhysicalKeyboardKey.numpad5)
                char = '5';
              else if (key == PhysicalKeyboardKey.digit6 || key == PhysicalKeyboardKey.numpad6)
                char = '6';
              else if (key == PhysicalKeyboardKey.digit7 || key == PhysicalKeyboardKey.numpad7)
                char = '7';
              else if (key == PhysicalKeyboardKey.digit8 || key == PhysicalKeyboardKey.numpad8)
                char = '8';
              else if (key == PhysicalKeyboardKey.digit9 || key == PhysicalKeyboardKey.numpad9)
                char = '9';
              else if (key == PhysicalKeyboardKey.minus ||
                  key == PhysicalKeyboardKey.numpadSubtract)
                char = '-';
              else if (key == PhysicalKeyboardKey.equal || key == PhysicalKeyboardKey.numpadAdd)
                char = '=';

              if (char != null) {
                _barcodeBuffer += char;
              }
            }
          }
        },
        child: ScreenUtilInit(
          designSize: Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height,
          ),
          minTextAdapt: true,
          splitScreenMode: true,
          ensureScreenSize: true,
          child: ConnectivityAppWrapper(
            app: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                FocusScope.of(context).requestFocus(_scannerFocusNode);
                NotificationMenuController.hide();
              },
              child: GetMaterialApp(
                navigatorKey: navigatorKey,
                title: StringConstants.appName,
                theme: ThemeData.fallback(useMaterial3: true),
                locale: LocalizationService.locale,
                translations: LocalizationService(),
                home: SplashScreen(),
                themeMode: ThemeMode.system,
                debugShowCheckedModeBanner: false,
                builder: (context, child) {
                  final easyLoadingBuilder = EasyLoading.init();
                  final easyLoadingChild = easyLoadingBuilder(context, child);

                  return ToastificationWrapper(
                    config: const ToastificationConfig(
                      alignment: Alignment.topCenter,
                      itemWidth: 640,
                      animationDuration: Duration(milliseconds: 300),
                    ),
                    child: ConnectivityWidgetWrapper(
                      disableInteraction: true,
                      offlineWidget: _buildOfflineWidget(context),
                      child: Stack(
                        children: [
                          easyLoadingChild!,
                          BlocBuilder<LoadingCubit, LoadingState>(
                            builder: (context, state) {
                              return state.isLoading ? LoadingDialog() : const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineWidget(BuildContext context) {
    return Container(
      width: isMobile ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.width * 0.5,
      height: 150,
      padding: const EdgeInsets.all(8),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(text: "No Internet".tr, fontSize: FontConstants.font_18),
                UIHelper.verticalSpaceSm,
                CommonText(
                  text:
                      "Internet is not available. Please check your internet connectivity and try again."
                          .tr,
                  fontSize: FontConstants.font_14,
                  height: 1.3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
