import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class Constants {
  static const String appTitle = 'inteshar';
  static String baseUrl = "https://v2.inteshar.net/api/v9";
  // static String baseUrl = "https://v2.inteshar.net/api/v9"; // Test API

  /// Pinned Certificate SHA-256 Fingerprints for SSL Pinning (e.g. for v2.inteshar.net)
  static List<String> pinnedSha256Fingerprints = [
    "9d0d4f3e81d07ff5f8aa7f7d01f41b3fad68167d51f5560993e04382d65ba924", // Public Key (v2.inteshar.net)
    "441999c8716edddaedd7bd9b0b11d8bcaf4541007f02f5b48dbd48e3eecf06ca", // Certificate (v2.inteshar.net)
  ];

  /// Security Enforcement Toggles
  static bool blockEmulator = true;
  static bool blockRootedDevices = true;
  static bool blockFridaHooking = true;
  static bool enforceSignatureCheck = true;
  static String expectedApkSignatureSha256 =
      "FB6F1A262D6A427BE36DD8DC6D512A3C3CF91153B073ADBA62D74CADEDC330BD,731827AE0ED016A847D205573763F97F62A21FA8FDD028C1AF1A3A0D9F0BC505";

  static final GetStorage localStorage = GetStorage();
  static String userToken = '';
  static String fcmToken = '';

  static bool isLoggedIn = false;
  static BoxDecoration intesharBoxDecoration(BuildContext context) =>
      BoxDecoration(
        color: Colors.white,
        // boxShadow: const [
        //   BoxShadow(
        //     color: Colors.black26,
        //     blurRadius: 1,
        //     offset: Offset(0, 1),
        //   ),
        // ],
        borderRadius: BorderRadius.circular(10),
      );
}

class TrianglePainter extends CustomPainter {
  final Color color;
  TrianglePainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = color;
    Path path = Path();
    path.moveTo(0, size.height / 2);
    path.lineTo(size.width, size.height / 4);
    path.lineTo(size.width, 3 * size.height / 4);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
