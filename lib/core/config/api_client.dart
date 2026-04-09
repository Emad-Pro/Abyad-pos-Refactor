import 'dart:convert';
import 'package:abyadpos_tab/core/config/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  String baseUrl = ApiEndPoints.BASE_URL;
  ApiClient._privateConstructor(); // باني خاص لمنع إنشاء نسخ جديدة بالخطأ
  static final ApiClient _instance = ApiClient._privateConstructor(); // النسخة الوحيدة في التطبيق

  // Factory constructor
  // هذا السطر يضمن أنه كلما كتبت ApiClient() في أي مكان في التطبيق، سيعطيك نفس النسخة دائماً
  factory ApiClient() {
    return _instance;
  }
  // --------------------------------

  String? _cachedToken;
  // حفظ التوكن في الذاكرة العشوائية لسرعة الوصول ولتجنب مشاكل التزامن

  // تهيئة الكلاس (يفضل استدعاؤها عند بدء التطبيق)
  Future<void> initToken() async {
    _cachedToken = await _getTokenFromPrefs();
  }

  // Main API request method
  Future<dynamic> request({
    required String url,
    required String method,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool isTest = false,
    BuildContext? context,
  }) async {
    // التأكد من وجود التوكن في الـ Cache إذا لم يكن موجوداً
    _cachedToken ??= await _getTokenFromPrefs();

    // 2. الهيدرز الأساسية
    Map<String, String> finalHeaders = {
      'accept': 'application/json',
      'Content-Type': 'application/json',
      'X-CSRF-TOKEN': '',
    };

    // 3. إضافة أي هيدرز مبعوتة من الـ Repo (زي ما هي)
    if (headers != null) {
      finalHeaders.addAll(headers);
    }

    // ⭐ 4. التعديل الأهم: إجبار التوكن الصحيح في النهاية!
    // السطر ده هيضمن إن لو الـ HomeRepo بعت توكن قديم بالغلط، السطر ده هيمسحه ويحط التوكن الجديد الصحيح
    if (_cachedToken != null && _cachedToken!.isNotEmpty) {
      finalHeaders['Authorization'] = 'Bearer $_cachedToken';
    }

    try {
      final requestUrl = url.startsWith("http") ? Uri.parse(url) : Uri.parse(baseUrl + url);
      http.Response response;

      // 📌 Log request
      _logRequest(method, requestUrl.toString(), finalHeaders, body);

      // Make the API call based on the method
      switch (method.toUpperCase()) {
        case "GET":
          response = await http.get(requestUrl, headers: isTest ? null : finalHeaders);
          break;
        case "POST":
          response = await http.post(requestUrl, headers: finalHeaders, body: jsonEncode(body));
          break;
        case "PUT":
          response = await http.put(requestUrl, headers: finalHeaders, body: jsonEncode(body));
          break;
        case "DELETE":
          response = await http.delete(requestUrl, headers: finalHeaders);
          break;
        default:
          throw Exception("HTTP method '$method' not supported");
      }

      // 📌 Log Response
      _logResponse(response);

      // Handle the response
      return _handleResponse(response, context);
    } catch (e) {
      debugPrint("Error in API request: $e");
      rethrow;
    }
  }

  Future<dynamic> requestMultiRequest({
    required String url,
    required String method,
    Map<String, String>? body,
    Map<String, String>? headers,
    Map<String, String>? files, // For handling multipart file uploads
    BuildContext? context,
  }) async {
    _cachedToken ??= await _getTokenFromPrefs();

    // 2. الهيدرز الأساسية
    Map<String, String> finalHeaders = {
      'accept': 'application/json',
      'Content-Type': 'application/json',
      'X-CSRF-TOKEN': '',
    };

    // 3. إضافة أي هيدرز مبعوتة من الـ Repo (زي ما هي)
    if (headers != null) {
      finalHeaders.addAll(headers);
    }

    // ⭐ 4. التعديل الأهم: إجبار التوكن الصحيح في النهاية!
    // السطر ده هيضمن إن لو الـ HomeRepo بعت توكن قديم بالغلط، السطر ده هيمسحه ويحط التوكن الجديد الصحيح
    if (_cachedToken != null && _cachedToken!.isNotEmpty) {
      finalHeaders['Authorization'] = 'Bearer $_cachedToken';
    }

    try {
      final requestUrl = url.startsWith("http") ? Uri.parse(url) : Uri.parse(baseUrl + url);
      var request = http.MultipartRequest(method.toUpperCase(), requestUrl);

      if (body != null) {
        request.fields.addAll(body);
      }

      if (files != null) {
        for (var entry in files.entries) {
          request.files.add(
            await http.MultipartFile.fromPath(entry.key, entry.value.toString()),
          );
        }
      }

      request.headers.addAll(finalHeaders);
      _logRequest(method, requestUrl.toString(), finalHeaders, {...?body, ...?files});

      http.StreamedResponse streamedResponse = await request.send();
      var res = await streamedResponse.stream.bytesToString();

      // 📌 Log multipart response
      debugPrint("⬅️ [${streamedResponse.statusCode}] ${requestUrl.toString()}");
      debugPrint("Response Body: $res\n");

      return _handleMultipartResponse(streamedResponse.statusCode, res, context);
    } catch (e) {
      debugPrint("Error in API request: $e");
      rethrow;
    }
  }

  // Handle responses for multipart requests
  dynamic _handleMultipartResponse(int statusCode, String responseBody, BuildContext? context) {
    final body = jsonDecode(responseBody);

    if (statusCode >= 200 && statusCode < 300) {
      return body;
    } else if (statusCode == 404) {
      return body; // Depending on your API, 404 might return expected data or throw error
    } else if (statusCode == 401) {
      _handleUnauthorized(context);
      throw Exception('Unauthorized'); // Add this so the flow stops
    } else if (statusCode == 422) {
      throw ValidationException(
        message: body['message'] ?? 'Validation error',
        errors: body['data'] ?? {},
      );
    } else if (statusCode == 400 &&
        (body['message']?.toString().contains("Payment is pending") ?? false)) {
      return body;
    } else {
      throw Exception(body['message'] ?? 'Unknown error occurred (Status: $statusCode)');
    }
  }

  // Handle API response
  dynamic _handleResponse(http.Response response, BuildContext? context) {
    final statusCode = response.statusCode;

    // Check if body is empty before decoding
    dynamic body;
    if (response.body.isNotEmpty) {
      try {
        body = jsonDecode(response.body);
      } catch (e) {
        throw Exception('Failed to decode JSON response');
      }
    } else {
      body = {};
    }

    if (statusCode >= 200 && statusCode < 300) {
      return body;
    } else if (statusCode == 404) {
      return body;
    } else if (statusCode == 401) {
      _handleUnauthorized(context);
      throw Exception('Unauthorized'); // Add this so the flow stops
    } else if (statusCode == 422) {
      throw ValidationException(
        message: body['message'] ?? 'Validation error',
        errors: body['data'] ?? {},
      );
    } else {
      throw Exception(body['message'] ?? 'Unknown error occurred (Status: $statusCode)');
    }
  }

  // Handle unauthorized error
  void _handleUnauthorized(BuildContext? context) {
    // يجب التوجيه لشاشة تسجيل الدخول هنا
    // Get.offAll(() => LoginScreen());
    debugPrint("⚠️ UNAUTHORIZED REQUEST! Redirecting to login...");
  }

  void _logRequest(
      String method, String url, Map<String, String>? headers, Map<String, dynamic>? body) {
    debugPrint("\n➡️ $method $url");
    if (headers != null) debugPrint("Headers: ${jsonEncode(headers)}");
    if (body != null) debugPrint("Body: ${jsonEncode(body)}");
  }

  // 📌 Helper: Log response
  void _logResponse(http.Response response) {
    debugPrint("⬅️ [${response.statusCode}] ${response.request?.url}");
    // Limit logging length if response is too long
    String bodyStr = response.body;
    if (bodyStr.length > 1000) {
      bodyStr = "${bodyStr.substring(0, 1000)}... [TRUNCATED]";
    }
    debugPrint("Response Body: $bodyStr\n");
  }

  // Get token from SharedPreferences
  Future<String?> _getTokenFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Save token to SharedPreferences AND update Cache immediately
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    _cachedToken = token; // التحديث الفوري هنا هو سر حل المشكلة
  }

  // Clear token from SharedPreferences AND clear Cache
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _cachedToken = null;
  }
}

// Custom exception class for validation errors
class ValidationException implements Exception {
  final String message;
  final Map<String, dynamic> errors;

  ValidationException({required this.message, required this.errors});

  @override
  String toString() {
    return 'ValidationException: $message\nErrors: $errors';
  }
}
