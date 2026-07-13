import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/config/functions.dart';
import 'package:inteshar/app/config/status.dart';
import 'package:inteshar/app/core/common/constants/api_client.dart';
import 'package:inteshar/app/core/routes/routes.dart';
import 'package:inteshar/app/features/home/data/data_source/home_api_provider.dart';

class SinginApiProvider extends GetxController {
  late Rx<Status> rxRequestStatus;
  late Rx<Status> rxRequestButtonStatus;
  final ApiClient _apiClient = ApiClient();

  final RxString errorMessage = ''.obs;
  String deviceType = '';
  String deviceId = '';
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool rememberMe = false.obs;

  @override
  void onInit() {
    super.onInit();
    rxRequestStatus = Status.initial.obs;
    rxRequestButtonStatus = Status.initial.obs;

    final savedCredentials =
        Constants.localStorage.read('remember_me_credentials');
    if (savedCredentials != null) {
      usernameController.text = savedCredentials['username'] ?? '';
      passwordController.text = savedCredentials['password'] ?? '';
      rememberMe.value = true;
    }
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    rxRequestStatus.value = Status.loading;
    rxRequestButtonStatus.value = Status.loading;
    errorMessage.value = '';

    deviceType =
        Platform.isAndroid ? 'Android' : (Platform.isIOS ? 'iOS' : 'Unknown');

    try {
      deviceId = (await getId()) ?? 'unknown';

      final response = await _apiClient.dio.post(
        "/login",
        data: {
          'username': username,
          'password': password,
          'device_token': deviceId,
          'app_version': 27,
        },
      );

      if (response.statusCode == 200) {
        debugPrint(
          'response.data===>${response.data['secret_key']}',
          wrapWidth: 102400000,
        );

        if (rememberMe.value) {
          Constants.localStorage.write('remember_me_credentials', {
            'username': username,
            'password': password,
          });
        } else {
          Constants.localStorage.remove('remember_me_credentials');
        }

        // if (response.data['status'] == 'setup_2fa') {
        rxRequestStatus.value = Status.completed;
        rxRequestButtonStatus.value = Status.completed;
        int expireTime = response.data['expire_time'] ?? 120;

        Get.offNamed(Routes.otp, arguments: {
          'username': username,
          'password': password,
          'status': response.data?['status'],
          'deviceToken': deviceId,
          'userId': response.data?['user_id'].toString(),
          'qr': response.data?['qr'] ?? '',
          'secret': response.data?['secret'] ?? '',
          'expire_time': expireTime,
        });
        // }
      } else {
        errorMessage.value = response.data['errors']?[0] ?? 'فشل تسجيل الدخول';
        rxRequestStatus.value = Status.error;
        rxRequestButtonStatus.value = Status.error;
      }
    } catch (e) {
      errorMessage.value = 'فشل تسجيل الدخول';
      rxRequestButtonStatus.value = Status.error;
      rxRequestStatus.value = Status.error;
    }
  }
}
