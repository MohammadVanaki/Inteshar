import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/core/common/constants/api_interceptor.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio dio;

  factory ApiClient() => _instance;

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: Constants.baseUrl,
      receiveTimeout: const Duration(milliseconds: 20000),
      connectTimeout: const Duration(milliseconds: 20000),
      followRedirects: false,
      validateStatus: (status) =>
          status != null && status != 301 && status != 302,
    ));

    dio.interceptors.add(SecurityInterceptor());

    dio.interceptors
        .add(LogInterceptor(responseBody: true, requestHeader: true));

    dio.interceptors.add(FallbackInterceptor());
  }
}

class FallbackInterceptor extends Interceptor {
  static const String _retriedKey = '_fallbackRetried';
  static const String _retryCountKey = '_retryCount';

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    print("🚨 FallbackInterceptor triggered for: ${requestOptions.uri}");
    print(
        "🚨 Error Type: ${err.type}, Message: ${err.message}, Error object: ${err.error}");

    final isRedirectError = err.type == DioExceptionType.badResponse &&
        (err.response?.statusCode == 301 || err.response?.statusCode == 302);

    final isNetworkError = err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        err.message?.contains('HandshakeException') == true ||
        err.message?.contains('SSL') == true ||
        err.error is SocketException ||
        isRedirectError;

    print(
        "ℹ️ isNetworkError check result (including redirects): $isNetworkError");

    if (!isNetworkError) {
      return super.onError(err, handler);
    }

    final safeToRetry = requestOptions.extra['safeToRetry'] ?? true;
    print("ℹ️ safeToRetry: $safeToRetry");

    if (safeToRetry == true) {
      // Auto-retry up to 3 times
      int retryCount = requestOptions.extra[_retryCountKey] ?? 0;
      if (retryCount < 3) {
        retryCount++;
        requestOptions.extra[_retryCountKey] = retryCount;
        print("⚠️ Network error. Auto-retry attempt #$retryCount...");

        // Switch protocol on first retry if needed (original fallback logic)
        if (retryCount == 1) {
          final currentBaseUrl = requestOptions.baseUrl;
          final isCurrentlyHttps = currentBaseUrl.startsWith('https://');
          final oldProtocol = isCurrentlyHttps ? 'https://' : 'http://';
          final newProtocol = isCurrentlyHttps ? 'http://' : 'https://';
          final newBaseUrl =
              currentBaseUrl.replaceFirst(oldProtocol, newProtocol);
          print(
              "🔄 Switching protocol from $oldProtocol to $newProtocol. New base URL: $newBaseUrl");
          Constants.baseUrl = newBaseUrl;
          ApiClient().dio.options.baseUrl = newBaseUrl;
          requestOptions.baseUrl = newBaseUrl;
          if (requestOptions.path.startsWith(oldProtocol)) {
            requestOptions.path =
                requestOptions.path.replaceFirst(oldProtocol, newProtocol);
          }
        }

        await Future.delayed(const Duration(seconds: 2));
        try {
          print(
              "🔄 Retrying request to: ${requestOptions.uri} with baseUrl: ${requestOptions.baseUrl}");
          final response = await ApiClient().dio.fetch(requestOptions);
          print("✅ Retry attempt #$retryCount succeeded!");
          return handler.resolve(response);
        } catch (e) {
          print("❌ Retry attempt #$retryCount failed with error: $e");
          // If it fails, the next error event will trigger onError again and retry
          return;
        }
      } else {
        print("🚨 Reached max retry limit (3). Passing error downstream.");
        return super.onError(err, handler);
      }
    } else {
      // safeToRetry == false -> Show user confirmation dialog
      final warningMessage = requestOptions.extra['warningMessage'] ??
          'حدث خطأ في الاتصال أثناء معالجة الطلب. هل تريد إعادة المحاولة؟';

      final shouldRetry = await _showWarningDialog(warningMessage);
      if (shouldRetry) {
        try {
          final response = await ApiClient().dio.fetch(requestOptions);
          return handler.resolve(response);
        } catch (retryErr) {
          // If manual retry fails, onError will trigger again and show dialog again
          return;
        }
      } else {
        return super.onError(err, handler);
      }
    }
  }

  Future<bool> _showWarningDialog(String message) async {
    final completer = Completer<bool>();
    Get.dialog(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('خطأ في الاتصال',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                completer.complete(false);
              },
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                completer.complete(true);
              },
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
    return completer.future;
  }
}
