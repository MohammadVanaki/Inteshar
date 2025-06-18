import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/config/functions.dart';
import 'package:inteshar/app/config/status.dart';
import 'package:inteshar/app/core/routes/routes.dart';
import 'package:inteshar/app/features/home/data/data_source/home_api_provider.dart';

class SinginApiProvider extends GetxController {
  late Rx<Status> rxRequestStatus;
  late Rx<Status> rxRequestButtonStatus;
  late Dio dio;

  final RxString errorMessage = ''.obs;
  String deviceType = '';
  String deviceId = '';
  final HomeApiProvider updateController = Get.put(HomeApiProvider());
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  // final HomeApiProvider homeApiProvider = Get.put(HomeApiProvider());
  @override
  void onInit() {
    super.onInit();
    rxRequestStatus = Status.initial.obs;
    rxRequestButtonStatus = Status.initial.obs;
    dio = Dio(BaseOptions(
      receiveTimeout: const Duration(milliseconds: 10000),
      validateStatus: (status) {
        return status! < 500;
      },
    ));
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    rxRequestStatus.value = Status.loading;
    rxRequestButtonStatus.value = Status.loading;
    errorMessage.value = '';
    if (Platform.isAndroid) {
      deviceType = 'Android';
    } else if (Platform.isIOS) {
      deviceType = 'iOS';
    } else {
      deviceType = 'Unknown';
    }
    try {
      deviceId = (await getId())!;
      print("device_id: $deviceId");

      print("Constants.fcmToken: ${Constants.fcmToken}");
      print("Constants.userToken: ${Constants.userToken}");

      final response = await dio.post(
        "${Constants.baseUrl}/login",
        queryParameters: {
          'username': username,
          'password': password,
          'app_version': 27,
          'firebase_token': Constants.fcmToken,
          'device_type': deviceType,
          'device_token': deviceId,
        },   
      );

      if (response.statusCode == 200) {
        Constants.userToken = response.data['token'];

        Constants.localStorage.write('userToken', Constants.userToken);
        Constants.isLoggedIn = true;

        Constants.localStorage
            .write('userInfo', {'userName': username, 'password': password});
        rxRequestStatus.value = Status.completed;
        await Future.delayed(const Duration(seconds: 2));
        rxRequestButtonStatus.value = Status.completed;
        Get.offNamed(Routes.home);
        rxRequestStatus = Status.initial.obs;
        rxRequestButtonStatus = Status.initial.obs;
      } else {
        print('===================>>>${response.data['errors'][0]}');
        errorMessage.value = response.data['errors'][0] ?? 'فشل تسجيل الدخول';
        rxRequestStatus.value = Status.error;
        rxRequestButtonStatus.value = Status.error;
      }
    } catch (e) {
      errorMessage.value = 'فشل تسجيل الدخول';
      print('Login Error! :$e');
      rxRequestButtonStatus.value = Status.error;
      rxRequestStatus.value = Status.error;
    }
  }
}
