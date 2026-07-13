import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/config/handle_logout.dart';
import 'package:inteshar/app/config/status.dart';
import 'package:inteshar/app/core/common/constants/api_client.dart';
import 'package:inteshar/app/core/common/widgets/exit_dialog.dart';
import 'package:inteshar/app/features/register_web/view/screens/register_view.dart';

class RegisterController extends GetxController {
  final rxRequestStatus = Status.initial.obs;
  final ApiClient _apiClient = ApiClient();
  Future fetchTransaction(BuildContext context) async {
    rxRequestStatus.value = Status.loading;

    try {
      final response = await _apiClient.dio.post(
        "${Constants.baseUrl}/masal_transaction",
        queryParameters: {
          'type': 'bill',
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${Constants.userToken}',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('++++++++++${response.statusCode}');
      print('++++++++++${response}');

      if (response.statusCode == 200) {
        rxRequestStatus.value = Status.completed;

        // Get the access_token from response
        final token = response.data['data']['access_token'];

        // Navigate to RegisterView and pass token
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterView(token: token),
          ),
        );
      } else if (response.statusCode == 401) {
        handleLogout(response.data['error']);
      } else {
        if ((response.data?['logged_in'] ?? 1) == 0) {
          rxRequestStatus.value = Status.completed;
          exitDialog(response.data['errors'][0]);
        } else {
          rxRequestStatus.value = Status.error;
        }
      }
    } catch (e) {
      rxRequestStatus.value = Status.error;
      print(e);
    }
  }
}
