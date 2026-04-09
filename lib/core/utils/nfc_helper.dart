
import 'package:abyadpos_tab/core/widgets/ui_helpers.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:flutter/material.dart';

class NfcHelper {
  static Future<void> startNfc() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (isAvailable) {
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          print("NFC Tag discovered: $tag");

        }, pollingOptions: {
        NfcPollingOption.iso14443,
        NfcPollingOption.iso15693,
        NfcPollingOption.iso18092,
      },

      );
    } else {
      print("NFC not available on this device.");
    }
  }

  // Future<void> checkNfcStatus(BuildContext context) async {
  //   bool isAvailable = await NfcManager.instance.isAvailable();
  //         // NfcManager.instance.stopSession();
  //   if (isAvailable) {
  //     debugPrint("NFC is available and enabled.");
  //   } else {
  //     debugPrint("NFC is not available or turned off.");
  //
  //     // Show clearer bilingual message
  //     UIHelper.showBottomFlash(
  //       context,
  //       title: "NFC Disabled / تم إيقاف NFC",
  //       message:
  //       "Please enable NFC in your device settings to continue.\nيرجى تفعيل خاصية NFC من إعدادات الجهاز للمتابعة.",
  //       isError: true,
  //     );
  //
  //     // Open NFC settings (Android only)
  //     try {
  //       final intent = AndroidIntent(
  //         action: 'android.settings.NFC_SETTINGS',
  //         flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
  //       );
  //       await intent.launch();
  //     } catch (e) {
  //       debugPrint("Failed to open NFC settings: $e");
  //     }
  //   }
  // }
  Future<bool> checkNfcStatus(BuildContext context) async {
    bool isAvailable = await NfcManager.instance.isAvailable();

    if (isAvailable) {
      return true;
    } else {
      // Show dialog asking user to enable NFC
      UIHelper.showDialogOk(
        context,
        title: "nfc_disabled".tr,
        message: "enable_nfc_message".tr,
        onConfirm: () async {
          // Check NFC status again
          bool stillDisabled = !(await NfcManager.instance.isAvailable());

          if (stillDisabled) {
            // NFC still disabled → open settings
            try {
              final intent = AndroidIntent(
                action: 'android.settings.NFC_SETTINGS',
                flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
              );
              await intent.launch();
            } catch (e) {
              debugPrint("Failed to open NFC settings: $e");
            }
          }
          // Close the dialog in any case
          Get.back();
        },

      );
      return false;
    }
  }
}