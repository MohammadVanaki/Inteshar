import 'package:flutter/material.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/core/common/widgets/internal_page.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterView extends StatelessWidget {
  final String token; // token from response

  const RegisterView({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    print("Received token: $token");
    final url = "https://alwatani.elitesoft.iq/web/?portalToken=$token";

    return Scaffold(
      body: InternalPage(
        title: 'الوطني',
        child: Container(
          width: double.infinity,
          margin:
              const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 20),
          padding: const EdgeInsets.all(20),
          decoration: Constants.intesharBoxDecoration(context).copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
          child: InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(url)),

            // Called every time history/route changes
            onUpdateVisitedHistory: (controller, url, androidIsReload) {
              debugPrint("🔀--->> Route changed: $url");

              // ✅ Detect final payment page (example: contains 'success' or 'fail')
              if (url.toString().contains("payment_result")) {
                // you can also parse transactionId from url if needed
                final transactionId =
                    Uri.parse(url.toString()).queryParameters['transaction_id'];

                if (transactionId != null) {
                  _checkPaymentStatus(context, transactionId);
                }
              }
            },
          ),
        ),
      ),
    );
  }

  /// Check payment status from API
  Future<void> _checkPaymentStatus(
      BuildContext context, String transactionId) async {
    final apiUrl = Uri.parse(
        "https://alwatani.elitesoft.iq/cnct/transaction/$transactionId");

    try {
      final response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        bool apiSuccess = data['is_successful'] == true;
        int status = data['data']['status'];

        String message;
        Color bgColor;

        if (apiSuccess && status == 1) {
          message = "✅ تمت عملية الدفع بنجاح";
          bgColor = Colors.green;
        } else if (apiSuccess && status == 0) {
          message = "⏳ عملية الدفع قيد الانتظار";
          bgColor = Colors.orange;
        } else {
          message = "❌ فشلت عملية الدفع";
          bgColor = Colors.red;
        }

        // show snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message, style: const TextStyle(color: Colors.white)),
            backgroundColor: bgColor,
          ),
        );
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("⚠️ خطأ في التحقق من حالة الدفع: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
