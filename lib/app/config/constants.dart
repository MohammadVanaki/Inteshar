import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class Constants {
  static const String appTitle = 'inteshar';
  static String baseUrl = "https://v2.inteshar.net/api/v8";
  // static String baseUrl = "https://v2.inteshar.net/api/v9"; // Test API

  static final GetStorage localStorage = GetStorage();
  static String userToken = '';
  static String fcmToken = '';

  static bool isLoggedIn = false;
  static BoxDecoration intesharBoxDecoration(BuildContext context) =>
      BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
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
