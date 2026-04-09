import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class DownloadProgress {
  final int received;
  final int total;
  final double percent;

  DownloadProgress({required this.received, required this.total, required this.percent});
}

class UpdaterService {
  // --- 1. SINGLETON SETUP ---
  static final UpdaterService _instance = UpdaterService._internal();

  factory UpdaterService() => _instance;

  UpdaterService._internal();

  // --- 2. STATE MANAGEMENT ---
  final _progressController = StreamController<DownloadProgress>.broadcast();

  Stream<DownloadProgress> get progressStream => _progressController.stream;

  bool _isDownloading = false;
  bool _hasError = false;

  bool get isUpdating => _isDownloading;
  bool get hasError => _hasError;

  // 🔹 إضافة: تحديد صيغة الملف بناءً على نظام التشغيل
  String get _fileExtension => Platform.isWindows ? ".exe" : ".apk";

  /// CLEANUP: Removes old updates to save space
  Future<void> cleanOldVersions(String currentAppVersion, {String? targetVersion}) async {
    try {
      final dir = await getApplicationSupportDirectory();
      final List<FileSystemEntity> files = dir.listSync();

      for (var file in files) {
        if (file is File) {
          final String fileName = file.path
              .split(Platform.pathSeparator)
              .last; // استخدام Platform.pathSeparator أأمن للويندوز

          // 🔹 التعديل هنا: فحص الصيغة الديناميكية
          if (fileName.endsWith(_fileExtension) || fileName.endsWith(".part")) {
            bool isDownloadingTarget =
                targetVersion != null && fileName.contains("v$targetVersion");

            if (!isDownloadingTarget) {
              await file.delete();
              print("🗑️ Space Saved: Deleted $fileName (Version mismatch or already installed)");
            }
          }
        }
      }
    } catch (e) {
      print("Cleanup error: $e");
    }
  }

  /// STATE CHECK: Used by the timer to see if we already have the file
  Future<String?> getReadyApkPath(String version) async {
    try {
      final dir = await getApplicationSupportDirectory();

      // 🔹 التعديل هنا: استخدام الامتداد الديناميكي
      final path = "${dir.path}/update_v$version$_fileExtension";
      final file = File(path);

      if (await file.exists()) {
        final length = await file.length();
        // Check for 10MB to ensure it's a real file
        if (length > 1024 * 1024 * 10) {
          print("✅ Ready Update found internally: $path ($length bytes)");
          return path;
        } else {
          await file.delete(); // Delete tiny/corrupt file
        }
      }
    } catch (e) {
      print("❌ Error checking Update path: $e");
    }
    return null;
  }

  /// CORE LOGIC: Resumable download
  Future<void> downloadAndInstall(String downloadUrl, String version) async {
    if (_isDownloading) return;
    _isDownloading = true;
    _hasError = false;

    _progressController.add(DownloadProgress(received: 0, total: 0, percent: 0));

    final dir = await getApplicationSupportDirectory();

    // 🔹 التعديل هنا: استخدام الامتداد الديناميكي
    final updatePath = "${dir.path}/update_v$version$_fileExtension";
    final tmpPath = "$updatePath.part";
    final file = File(tmpPath);

    try {
      int localFileLength = await file.exists() ? await file.length() : 0;

      final dio = Dio();
      dio.options.headers['accept-encoding'] = 'identity';

      final response = await dio.get<ResponseBody>(
        downloadUrl,
        options: Options(
          responseType: ResponseType.stream,
          headers: {'range': 'bytes=$localFileLength-'},
          validateStatus: (status) => status == 200 || status == 206,
        ),
      );

      final bool isResuming = response.statusCode == 206;
      final sink = await file.open(mode: isResuming ? FileMode.append : FileMode.write);

      int bytesRemaining = int.tryParse(response.headers.value('content-length') ?? '0') ?? 0;
      int actualTotalExpected = isResuming ? (bytesRemaining + localFileLength) : bytesRemaining;

      int currentReceived = isResuming ? localFileLength : 0;

      await for (final chunk in response.data!.stream) {
        await sink.writeFrom(chunk);
        currentReceived += chunk.length;

        _progressController.add(DownloadProgress(
          received: currentReceived,
          total: actualTotalExpected,
          percent: actualTotalExpected > 0 ? (currentReceived / actualTotalExpected) : 0,
        ));
      }

      // ... (باقي كود التحميل اللي فوق زي ما هو)
      await sink.flush();
      await sink.close();

      // --- VERIFICATION & INSTALL ---
      final int finalSizeOnDisk = await file.length();
      if (actualTotalExpected > 0 && finalSizeOnDisk != actualTotalExpected) {
        if (await file.exists()) await file.delete();
        throw Exception("Verification Failed");
      }

      final finalUpdateFile = File(updatePath);
      if (await finalUpdateFile.exists()) await finalUpdateFile.delete();
      await file.copy(updatePath);
      await file.delete();

      await Future.delayed(const Duration(seconds: 1));
      _isDownloading = false;

      _progressController.add(DownloadProgress(
        received: actualTotalExpected,
        total: actualTotalExpected,
        percent: 1.0,
      ));

      // 🎯 التعديل الأول: استدعاء الدالة الصحيحة المسؤولة عن الصمت
      await installUpdate(updatePath);
    } catch (e) {
      _isDownloading = false;
      _hasError = true;
      _progressController.addError(e);
    }
  }

  // 🎯 التعديل التاني: دالة التثبيت النهائية والوحيدة (امسح installApk خالص)
  Future<void> installUpdate(String path) async {
    File updateFile = File(path);
    if (!await updateFile.exists()) {
      print("Error: Update file does not exist at $path");
      return;
    }

    // تحديد المسار الحالي بدقة
    String currentAppDir = File(Platform.resolvedExecutable).parent.path;
    print("Installing silently at: $currentAppDir");

    try {
      await Process.start(
        updateFile.path,
        [
          '/VERYSILENT', // تثبيت مخفي تماماً
          '/SUPPRESSMSGBOXES', // منع النوافذ والأخطاء
          '/NORESTART', // منع عمل ريستارت للجهاز
          '/FORCECLOSEAPPLICATIONS', // إجبار إغلاق التطبيق لو معلق
          '/DIR=$currentAppDir' // وضع الملفات في مسار التطبيق الحالي بدون علامات تنصيص
        ],
        runInShell: false, // 🛡️ مهمة جداً تكون false عشان لو المسار فيه مسافات ما يضربش
        mode: ProcessStartMode.detached,
      );

      // إغلاق التطبيق فوراً
      exit(0);
    } catch (e) {
      print("Windows Installation failed: $e");
    }
  }
}

// import 'dart:io';
// import 'dart:async';
// import 'package:dio/dio.dart';
// import 'package:open_filex/open_filex.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
//
// class DownloadProgress {
//   final int received;
//   final int total;
//   final double percent;
//   final bool completed;
//   final bool hasError;
//
//   DownloadProgress({
//     required this.received,
//     required this.total,
//     required this.percent,
//     this.completed = false,
//     this.hasError = false,
//   });
// }
//
//
// class UpdaterService {
//   UpdaterService._privateConstructor();
//   static final UpdaterService _instance = UpdaterService._privateConstructor();
//   factory UpdaterService() => _instance;
//
//   final _progressController = StreamController<DownloadProgress>.broadcast();
//   Stream<DownloadProgress> get progressStream => _progressController.stream;
//
//   bool _isDownloading = false;
//   bool _hasError = false;
//
//   bool get isUpdating => _isDownloading;
//   bool get hasError => _hasError;
//
//   /// 1. CLEANUP: Removes APKs from previous versions to save space
//   /// Call this when the app starts: updater.cleanOldVersions("1.12");
//   Future<void> cleanOldVersions(String currentVersion) async {
//     try {
//       final dir = await getApplicationSupportDirectory();
//       final List<FileSystemEntity> files = dir.listSync();
//       for (var file in files) {
//         if (file is File && file.path.endsWith(".apk")) {
//           // Delete if it's NOT the current version's APK
//           if (!file.path.contains("update_v$currentVersion.apk")) {
//             await file.delete();
//             print("🗑️ Space Saved: Deleted old APK ${file.path}");
//           }
//         }
//       }
//     } catch (e) {
//       print("Cleanup error: $e");
//     }
//   }
//
//   /// 2. STATE CHECK: Used by the 5-minute timer to prevent loops
//   Future<String?> getReadyApkPath(String version) async {
//     final dir = await getApplicationSupportDirectory();
//     final path = "${dir.path}/update_v$version.apk";
//     final file = File(path);
//     if (await file.exists()) return path;
//     return null;
//   }
//
//   Future<void> downloadAndInstall(String apkUrl, String version) async {
//     if (_isDownloading) {
//       print("⏳ Already downloading v$version. Skipping call.");
//       return;
//     }
//
//     _isDownloading = true;
//     _hasError = false;
//     // IMPORTANT: Reset progress so UI knows we are starting
//     _progressController.add(DownloadProgress(received: 0, total: 0, percent: 0));
//
//     final dir = await getApplicationSupportDirectory();
//     final apkPath = "${dir.path}/update_v$version.apk";
//     final tmpPath = "$apkPath.part";
//     final file = File(tmpPath);
//
//     int localFileLength = await file.exists() ? await file.length() : 0;
//     print("📡 Requesting Range: bytes=$localFileLength-");
//
//     try {
//       final dio = Dio();
//       // Set a timeout so the 5-minute timer doesn't hang if network is "ghosting"
//       dio.options.connectTimeout = const Duration(seconds: 15);
//
//       final response = await dio.get<ResponseBody>(
//         apkUrl,
//         options: Options(
//           responseType: ResponseType.stream,
//           headers: {'range': 'bytes=$localFileLength-'},
//           validateStatus: (status) => status! < 500,
//         ),
//       );
//
//       // If server returns 200 instead of 206, it means it doesn't support resume
//       // or we are starting from 0.
//       final bool isResuming = response.statusCode == 206;
//
//       // Safety check: If we tried to resume but server sent 200, reset local length
//       int currentReceived = isResuming ? localFileLength : 0;
//
//       final sink = await file.open(mode: isResuming ? FileMode.append : FileMode.write);
//
//       int? totalOnServer = response.data!.contentLength;
//       int? finalSize = totalOnServer != null ? totalOnServer + (isResuming ? localFileLength : 0) : null;
//
//       await for (final chunk in response.data!.stream) {
//         await sink.writeFrom(chunk);
//         currentReceived += chunk.length;
//
//         _progressController.add(DownloadProgress(
//           received: currentReceived,
//           total: finalSize ?? 0,
//           percent: finalSize != null ? (currentReceived / finalSize) : 0,
//         ));
//       }
//       await sink.close();
//
//       if (finalSize != null && currentReceived != finalSize) {
//         throw Exception("Size mismatch: Received $currentReceived of $finalSize");
//       }
//
//       // Finalize: Replace old APK with the new one
//       final finalApkFile = File(apkPath);
//       if (await finalApkFile.exists()) await finalApkFile.delete();
//       await file.rename(apkPath);
//
//       _isDownloading = false;
//       print("✅ Download Complete. Triggering Installation.");
//       await installApk(apkPath);
//
//     } catch (e) {
//       _isDownloading = false;
//       _hasError = true;
//       print("❌ Download Error: $e");
//       // Optional: Send error to the stream so UI can show "Retry"
//       _progressController.addError(e);
//     }
//   }
//
//   Future<void> installApk(String path) async {
//     await OpenFilex.open(path);
//   }
// }
