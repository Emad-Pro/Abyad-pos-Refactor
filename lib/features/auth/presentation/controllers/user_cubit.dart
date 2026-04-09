import 'dart:async';
import 'dart:io';

import 'package:abyadpos_tab/core/config/api_client.dart';
import 'package:abyadpos_tab/core/config/api_endpoints.dart';
import 'package:abyadpos_tab/features/orders/presentation/controllers/order_cubit.dart';
import 'package:abyadpos_tab/features/orders/data/models/order_model.dart';
import 'package:abyadpos_tab/features/auth/data/models/profile_model.dart';
import 'package:abyadpos_tab/features/auth/data/models/user_model.dart';
import 'package:abyadpos_tab/core/storage/sharedpref.dart';
import 'package:abyadpos_tab/features/auth/presentation/screens/login_screen.dart';
import 'package:abyadpos_tab/features/auth/presentation/controllers/user_state.dart';
import 'package:abyadpos_tab/core/widgets/loader/loading_cubit.dart';
import 'package:abyadpos_tab/core/utils/logger_util.dart';
import 'package:abyadpos_tab/core/utils/nearpay_manager.dart';
import 'package:abyadpos_tab/core/utils/restart_widget.dart';
import 'package:abyadpos_tab/core/utils/updater_service.dart';
import 'package:abyadpos_tab/core/widgets/common_methods.dart';
import 'package:abyadpos_tab/core/widgets/ui_helpers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // 👈 أضفنا استدعاء البلوك
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

// 👈 اسم الكلاس اتغير لـ Cubit وبياخد UserState
class UserCubit extends Cubit<UserState> {
  Timer? _configTimer;
  Timer? testTimer;
  ApiClient apiClient;

  UserCubit(this.apiClient) : super(UserState()) {
    _initAppVersion();
  }

  // دالة لجلب إصدار التطبيق عند بدء الكيوبت
  Future<void> _initAppVersion() async {
    final value = await CommonMethods.getPlatformVersion();
    if (!isClosed) emit(state.copyWith(appversion: value));
  }

  // 👈 دالة close المدمجة في الكيوبت بتمسح الـ Timers أوتوماتيك لما الكيوبت يموت
  @override
  Future<void> close() {
    stopConfigUpdater();
    return super.close();
  }

  Future<void> clearUser() async {
    await apiClient.clearToken();
    await SharedPref().saveObject('user', null);
    final pref = await SharedPreferences.getInstance();
    await pref.setString("terminalUUID", "");
    await pref.setBool("configUpdaterStarted", false);

    // 👈 تصفير البيانات من الـ State
    if (!isClosed) emit(state.copyWith(clearUser: true));

    Get.offAll(() => const LoginScreen());
  }

// دالة مخصصة لتحديث حالة الـ products_need_setup
  void setProductsNeedSetup(bool value) {
    if (state.userModel != null) {
      // تعديل القيمة
      state.userModel!.data.products_need_setup = value;
      // إخبار الكيوبت بعمل تحديث للشاشات
      if (!isClosed) emit(state.copyWith());
    }
  }

  Future callApi(BuildContext context) async {
    OrderCubit orderViewModel = BlocProvider.of<OrderCubit>(context, listen: false);
    Future.wait([
      orderViewModel.getOrders(context),
      orderViewModel.getHistoryOrders(context),
      orderViewModel.getAllClothes(context),
      orderViewModel.getAllClothesActiveAndInactive(context),
      fetchProfile(),
    ]);
  }

  Future<void> clearAppFilesystem() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }

      final appDocDir = await getApplicationDocumentsDirectory();
      if (appDocDir.existsSync()) {
        appDocDir.deleteSync(recursive: true);
      }
    } catch (e) {
      print("Error clearing filesystem: $e");
    }
  }

  Future<void> requestUserData(BuildContext context) async {
    try {
      final nearpayManager = NearPayManager();
      await nearpayManager.logout();

      final response = await apiClient.request(
        url: "${ApiEndPoints.BASE_URL}${ApiEndPoints.requestUserData}",
        method: 'GET',
      );

      if (response['status'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        CachedNetworkImage.evictFromCache("https://abyad.sa/uploads/clothes/...");
        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();

        await clearAppFilesystem();

        // 👈 تحديث الـ userModel في الكيوبت
        final newUserModel = UserModel.fromJson(response);
        if (!isClosed) emit(state.copyWith(userModel: newUserModel));

        SharedPref pref = SharedPref();
        await pref.saveObject('user', newUserModel.toJson());
        await apiClient.saveToken(newUserModel.data.token);

        if (context.mounted) {
          RestartWidget.restartApp(context);
        }
        print('App Hard Restarted successfully');
      } else {
        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        UIHelper.showBottomFlash(
          context,
          title: response['message'],
          message: response['message'],
          isError: true,
        );
      }
    } catch (error) {
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      UIHelper.showBottomFlash(
        context,
        title: "$error",
        message: "Error fetching user data: $error",
        isError: true,
      );
    }
  }

  Future<void> checkAppVersionStatic(BuildContext context) async {
    final updater = UpdaterService();
    if (updater.isUpdating) return;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = formatVersion(packageInfo.version);

      final response = await apiClient.request(
          url: "https://raw.githubusercontent.com/Emad-Pro/check_appver/refs/heads/main/ver.json",
          method: 'GET',
          isTest: true);

      if (response != null) {
        String latestVersion = response['data']['latest']?.toString() ?? currentVersion;
        String url = response['data']['url']?.toString() ?? "";
        final bool force = response['data']['force'] ?? false;
        final String message = response['data']['message'] ?? "يوجد تحديث جديد";

        if (url.isEmpty) return;

        int latestNum = UIHelper().versionToNumber(latestVersion);
        int currentNum = UIHelper().versionToNumber(currentVersion);

        print("💡 الرد من جيتهب: $response");
        print("💡 الإصدار الحالي (نص): $currentVersion");
        print("💡 الإصدار الأحدث (نص): $latestVersion");
        print("💡 الإصدار الحالي (رقم): $currentNum");
        print("💡 الإصدار الأحدث (رقم): $latestNum");

        if (currentNum >= latestNum) {
          await updater.cleanOldVersions(currentVersion, targetVersion: latestVersion);
          return;
        }

        String? savedUpdatePath = await updater.getReadyApkPath(latestVersion);

        if (force) {
          if (savedUpdatePath != null) {
            updater.installUpdate(savedUpdatePath);
          } else {
            updater.downloadAndInstall(url, latestVersion);
          }
          UIHelper.showFloatingDownloadWidget(updater, url, version: latestVersion);
        } else {
          UIHelper().showUpdateDialog(context, url,
              message: message, force: false, version: latestVersion);
        }
      }
    } catch (e) {
      debugPrint("❌ Error checking static version: $e");
    }
  }

  Future<void> checkAppVersionV2(BuildContext context) async {
    final updater = UpdaterService();

    if (updater.isUpdating) {
      context.read<LoadingCubit>().hideLoading();
      UIHelper.showBottomFlash(context,
          title: "there_is_ongoing_update".tr,
          message: "there_is_ongoing_update".tr,
          isError: false);
      return;
    }

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = formatVersion(packageInfo.version);

      final response = await apiClient.request(
        url: "${ApiEndPoints.BASE_URL}version/status/$currentVersion",
        method: 'GET',
      );

      if (response != null) {
        context.read<LoadingCubit>().hideLoading();

        final data = response['data'];
        if (data == null) throw Exception("Missing data in version response");

        final String latestVersion = data['latest'].toString();
        final String url = data['url'].toString();
        final bool force = data['force'] ?? false;
        final String message = data['message'] ?? "soft_update_msg".tr;
        int latestNum = UIHelper().versionToNumber(latestVersion);
        int currentNum = UIHelper().versionToNumber(currentVersion);

        if (currentNum == latestNum) {
          await updater.cleanOldVersions(currentVersion, targetVersion: latestVersion);
          UIHelper.showBottomFlash(context,
              title: "up_to_date".tr,
              message: "the_current_version_is_up_to_date".tr,
              isError: false);
          return;
        }

        String? savedApkPath = await updater.getReadyApkPath(latestVersion);

        if (force) {
          if (savedApkPath != null) {
            updater.installUpdate(savedApkPath);
          } else {
            updater.downloadAndInstall(url, latestVersion);
          }
          UIHelper.showFloatingDownloadWidget(updater, url, version: latestVersion);
        } else {
          UIHelper().showUpdateDialog(context, url,
              message: message, force: false, version: latestVersion);
        }
      }
    } catch (e) {
      context.read<LoadingCubit>().hideLoading();
      debugPrint("❌ Error checking version: $e");
      UIHelper.showBottomFlash(context,
          title: "update_check_failed".tr, message: e.toString(), isError: true);
    }
  }

  Future fetchProfile({BuildContext? context}) async {
    if (!isClosed) emit(state.copyWith(isFetchingProfile: true)); // 👈 بدل notifyListeners

    try {
      final response = await apiClient.request(
        url: "laundry-details",
        method: 'GET',
      );

      if (response['status'] == true) {
        final fetchedProfile = ProfileModel.fromJson(response);
        if (!isClosed) emit(state.copyWith(profileModel: fetchedProfile));
      } else {
        logger.log('profile Failed: ${response['message']}');
        if (context != null) {
          UIHelper.showBottomFlash(context,
              title: "خطأ في البروفايل", message: response['message'], isError: true);
        }
      }
    } catch (error) {
      print('Error status profile: $error');
      if (context != null) {
        UIHelper.showBottomFlash(context,
            title: "خطأ في الاتصال", message: error.toString(), isError: true);
      }
    } finally {
      if (!isClosed) emit(state.copyWith(isFetchingProfile: false)); // 👈 بدل notifyListeners
    }
  }

  Future updateProfile({body, filtPATH, required BuildContext context}) async {
    if (!isClosed) emit(state.copyWith(isFetchingProfile: true));

    try {
      final response = await apiClient.requestMultiRequest(
          url: ApiEndPoints.updateLaundary,
          method: 'POST',
          body: body,
          files: filtPATH != null ? {'logo': filtPATH} : null,
          context: context);

      if (response['status'] == true) {
        final newProfile = ProfileModel.fromJson(response);
        UserModel? updatedUser = state.userModel;

        // تحديث رقم الهاتف في الـ userModel كمان وحفظه
        if (updatedUser != null && newProfile.data.phone != null) {
          updatedUser.data.phone = newProfile.data.phone;
          await SharedPref().saveObject('user', updatedUser.toJson());
        }

        if (!isClosed) {
          emit(state.copyWith(profileModel: newProfile, userModel: updatedUser));
        }

        UIHelper.showBottomFlash(context,
            title: "Data Saved Successfully".tr,
            message: "Data Saved Successfully".tr,
            isError: false);
      } else {
        logger.log('profile Update Failed: ${response['message']}');
        UIHelper.showBottomFlash(context,
            title: "خطأ", message: response['message'], isError: true);
      }
    } catch (error) {
      print('Error status updating profile: $error');
      String errorMsg = error.toString().replaceAll("Exception: ", "");
      UIHelper.showBottomFlash(context, title: "خطأ", message: errorMsg, isError: true);
    } finally {
      if (!isClosed) emit(state.copyWith(isFetchingProfile: false));
    }
  }

  Future<Map<String, dynamic>?> lookupUser(String rawPhone) async {
    final jsonBody = await apiClient.requestMultiRequest(
      url: ApiEndPoints.BASE_URL + "wallet/check",
      method: 'POST',
      body: {'phone': '+966$rawPhone'},
    );
    print("_____" + jsonBody.toString());

    if (jsonBody['data'].containsKey('user_status')) return null;

    if (jsonBody['status'] == true && jsonBody['data'] is Map<String, dynamic>) {
      return jsonBody['data'] as Map<String, dynamic>;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>?> lookupUsers(String? rawPhone, String? name) async {
    final jsonBody = await apiClient.requestMultiRequest(
      url: ApiEndPoints.BASE_URL + "wallet/check/list",
      method: 'POST',
      body: name == null ? {'phone': '+966$rawPhone'} : {'name': '$name'},
    );
    print("_____" + jsonBody.toString());

    if (jsonBody['status'] == true && jsonBody['data'] is List && jsonBody['data'].isNotEmpty) {
      return List<Map<String, dynamic>>.from(jsonBody['data']);
    }

    return null;
  }

  Future<void> changePassword(BuildContext context, body) async {
    try {
      final response = await apiClient.requestMultiRequest(
        url: ApiEndPoints.changePassword,
        method: 'POST',
        body: body,
      );

      if (response['status'] == true) {
        UIHelper.showBottomFlash(context,
            title: response['message'], message: response['message'], isError: false);
        // state.userModel! تم استبدالها بـ state.userModel? للأمان
        print('change Successful: ${state.userModel?.data.name}');
      } else {
        UIHelper.showBottomFlash(context,
            title: response['message'], message: response['message'], isError: true);
        print('change Failed: ${response['message']} ${response.toString()} ');
      }
    } catch (error) {
      print('Error during login: $error');

      if (error is ValidationException) {
        print('Validation Errors: ${error.errors}');
        final errorMessages = error.errors.entries
            .map((entry) => '${entry.key}: ${entry.value.join(', ')}')
            .join('\n');
        UIHelper.showDialogOk(context, title: error.message, message: errorMessages);
      } else {
        print('Error..: $error');
        UIHelper.showBottomFlash(context,
            title: error.toString(), message: error.toString(), isError: true);
      }
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      final nearpayManager = NearPayManager();
      await nearpayManager.logout();

      final response = await apiClient.requestMultiRequest(
        url: ApiEndPoints.logout,
        method: 'POST',
      );

      if (response['status'] == true) {
        clearUser();
      } else {
        UIHelper.showBottomFlash(context,
            title: response['message'], message: response['message'], isError: true);
        print('change Failed: ${response['message']} ${response.toString()} ');
      }
    } catch (error) {
      print('Error during login: $error');
      if (error is ValidationException) {
        print('Validation Errors: ${error.errors}');
        final errorMessages = error.errors.entries
            .map((entry) => '${entry.key}: ${entry.value.join(', ')}')
            .join('\n');
        UIHelper.showDialogOk(context, title: error.message, message: errorMessages);
      } else {
        print('Error: $error');
      }
    }
  }

  Future<void> loadPref(BuildContext context) async {
    SharedPref pref = SharedPref();

    try {
      final doc = await pref.readObject('user');

      if (doc != null) {
        final loadedUser = UserModel.fromJson(doc);
        if (!isClosed) emit(state.copyWith(userModel: loadedUser)); // 👈 تحديث الكيوبت

        if (state.userModel != null) {
          await callApi(context);
        }
      } else {
        if (!isClosed) emit(state.copyWith(clearUser: true));
      }
    } catch (e) {
      print("Error loading user from prefs: $e");
      if (!isClosed) emit(state.copyWith(clearUser: true));
    }
  }

  // 👈 دالة refresh أصبحت تصدر نفس الحالة (trigger rebuild)
  Future refresh() async {
    if (!isClosed) emit(state.copyWith());
  }

  void startConfigUpdater(BuildContext context) {
    checkAppVersionStatic(context);
    _configTimer?.cancel();
    testTimer?.cancel();

    testTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      checkAppVersionStatic(context);
    });

    _configTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      checkAppVersionStatic(context);
      updateUserConfig(context);
    });
  }

  void stopConfigUpdater() {
    testTimer?.cancel();
    _configTimer?.cancel();
  }

  String formatVersion(String version) {
    final parts = version.split('.');
    if (parts.isEmpty) return version;

    final major = parts[0];
    final minor = parts.length > 1 ? parts[1] : '0';
    final patch = parts.length > 2 ? parts[2] : '0';

    final minorPatch = (minor + patch).padLeft(2, '0');
    return '$major.$minorPatch';
  }

  Future<String> getDeviceHardwareName() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.product.startsWith('V3')) {
        return "V";
      } else {
        return "D";
      }
    }
    return "D";
  }

  Future<void> updateUserConfig(BuildContext context) async {
    if (state.userModel == null) return; // 👈 استخدمنا state.userModel

    try {
      final updater = UpdaterService();
      if (updater.isUpdating) {
        print("⏳ Update already in progress. Ignoring 15-sec check.");
        return;
      }

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion2 = formatVersion(packageInfo.version);
      final deviceType = await getDeviceHardwareName();

      final url =
          "${ApiEndPoints.getConfigurations}?current_version=$currentVersion2&device_type=$deviceType";

      final response = await apiClient.request(
        url: url,
        method: 'GET',
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer ${state.userModel!.data.token}', // 👈 هنا كمان
        },
      );

      if (response['status'] == true && response['data'] != null) {
        final data = response['data'];

        // 👈 نعمل نسخة جديدة (Copy) من الموديل بالبيانات المتحدثة
        final updatedUserModel = state.userModel!.copyWith(
          data: state.userModel!.data.copyWith(
            nearpay_token: data['nearpay_token'] ?? state.userModel!.data.nearpay_token,
          ),
          appVersion: data['app_version'] != null
              ? AppVersion.fromJson(data['app_version'])
              : state.userModel!.appVersion,
        );

        final pref = SharedPref();
        await pref.saveObject('user', updatedUserModel.toJson());

        // 👈 نحدث الكيوبت
        if (!isClosed) emit(state.copyWith(userModel: updatedUserModel));

        final appVer = updatedUserModel.appVersion;

        if (appVer != null && appVer.url != null) {
          final String latestVer = appVer.latest.toString();
          final String downloadUrl = appVer.url!;
          final bool isForce = appVer.force ?? false;

          int latestNum = UIHelper().versionToNumber(latestVer);
          int currentNum = UIHelper().versionToNumber(currentVersion2);

          if (latestNum > currentNum) {
            String? savedApkPath = await updater.getReadyApkPath(latestVer);

            if (savedApkPath != null) {
              print("✅ APK ready on disk.");
              UIHelper.showFloatingDownloadWidget(updater, downloadUrl, version: latestVer);

              if (isForce) {
                updater.installUpdate(savedApkPath);
              }
            } else {
              print("🚀 Starting/Resuming background download.");
              updater.downloadAndInstall(downloadUrl, latestVer);
              UIHelper.showFloatingDownloadWidget(updater, downloadUrl, version: latestVer);
            }
          } else {
            await updater.cleanOldVersions(currentVersion2);
          }
        }
      }
    } catch (e) {
      print('❌ Error updating user configuration: $e');
    }
  }
}
