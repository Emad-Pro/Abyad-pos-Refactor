import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:abyadpos_tab/core/widgets/ui_helpers.dart';

class LocationHelper {
  static Future<bool> ensureLocationIsReady() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      UIHelper.showErrorSnackbar('location_service_disabled'.tr);
      return false;
    }

    // 2. Check permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        UIHelper.showErrorSnackbar('location_permission_denied'.tr);
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      UIHelper.showErrorSnackbar('location_permission_permanent'.tr);
      return false;
    }

    // 3. Force a fresh location fix
    try {
      // Optional: Show a small toast or log saying 'location_fetching'.tr
      await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 3),
      );
      return true;
    } catch (e) {
      // Fallback: check if we at least have a last known location
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown == null) {
        UIHelper.showErrorSnackbar('nearpay_location_required'.tr);
        return false;
      }
      return true;
    }
  }
}