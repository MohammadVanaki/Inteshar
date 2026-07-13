import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/config/functions.dart';

class SecurityInterceptor extends Interceptor {
  final String _macSecretKey = "9fK3xLmP8qR2vT7zW1aB4cD6eF9hJ2kL5mN8pQ3rS6tU";

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    int tsMillisReal = DateTime.now().millisecondsSinceEpoch;
    int tsSeconds = (tsMillisReal / 1000).floor();
    String nonce = _generateSecureNonce();

    String tsForPayload = (options.method == "POST")
        ? tsMillisReal.toString()
        : (tsSeconds * 1000).toString();

    String jsonBody = "";
    if (options.method == "POST" && options.data != null) {
      jsonBody = jsonEncode(options.data);
    }

    String urlForPayload = options.path.replaceFirst('https://', 'http://');

    String payload =
        "$tsForPayload$nonce${options.method}$urlForPayload$jsonBody";
    String signature = _hmacSign(payload);

    options.headers["Authorization"] = "Bearer ${Constants.userToken}";
    options.headers["X-Timestamp"] = tsSeconds.toString();
    options.headers["X-Nonce"] = nonce;
    options.headers["X-Signature"] = signature;
    options.headers["Accept"] = "application/json";
    options.headers["Content-Type"] = "application/json";
    options.headers["User-Agent"] = "Flutter-App/1.0";

    if (options.method == "POST") {
      options.headers["X-Timestamp-Millis"] = tsMillisReal.toString();
    }

    // String deviceToken = Constants.localStorage.read('deviceId') ?? "";
    String deviceToken = (await getId()) ?? 'unknown';
    if (deviceToken.isNotEmpty) {
      options.headers["X-Device-Token"] = deviceToken;
    }

    print("\n========== 🔐 SIGNATURE DEBUG ==========");
    print("📌 PAYLOAD: $payload");
    print("📌 SIGNATURE: $signature");
    print("========================================\n");

    super.onRequest(options, handler);
  }

  String _hmacSign(String data) {
    var key = utf8.encode(_macSecretKey);
    var bytes = utf8.encode(data);
    var hmacSha256 = Hmac(sha256, key);
    return base64.encode(hmacSha256.convert(bytes).bytes);
  }

  String _generateSecureNonce() {
    final random = Random.secure();
    int nonce = 0;
    for (int i = 0; i < 8; i++) {
      nonce = (nonce << 8) | random.nextInt(256);
    }
    return (nonce.abs()).toString();
  }
}
