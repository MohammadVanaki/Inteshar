import 'dart:io';

import 'package:get/get.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/config/status.dart';
import 'package:inteshar/app/core/common/constants/api_client.dart';

class OtpApiProvider extends GetxController {
  final ApiClient _apiClient = ApiClient();
  final rxRequestStatus = Status.initial.obs;
  RxString errorMessage = ''.obs;
  String deviceType = '';
  Future<bool> verifyOtp({
    required String userId,
    required String deviceToken,
    required String password,
    required String username,
    required String code,
  }) async {
    rxRequestStatus.value = Status.loading;
    deviceType =
        Platform.isAndroid ? 'Android' : (Platform.isIOS ? 'iOS' : 'Unknown');
    try {
      print("========>>>>${userId}");
      print("========>>>>${deviceToken}");
      print("========>>>>${code}");
      print("========>>>>${password}");
      print("========>>>>${username}");
      final response = await _apiClient.dio.post(
        "${Constants.baseUrl}/verify-2fa",
        data: {
          'user_id': userId,
          'device_token': deviceToken,
          'code': code,
          'app_version': 27,
          'firebase_token': Constants.fcmToken,
          'device_type': deviceType,
        },
      );
      print("========>>>>${response.statusCode}");
      print("========>>>>${response.data['device_token']}");
      if (response.statusCode == 200) {
        Constants.userToken = response.data['token'];
        Constants.localStorage.write('userToken', Constants.userToken);

        if (response.data['device_token'] != null) {
          Constants.localStorage
              .write('deviceId', response.data['device_token']);
        }

        Constants.localStorage
            .write('userInfo', {'userName': username, 'password': password});

        Constants.isLoggedIn = true;
        rxRequestStatus.value = Status.completed;

        return true;
      } else {
        rxRequestStatus.value = Status.error;
        errorMessage.value = response.data['message'] ?? 'فشل التحقق من الكود';
        return false;
      }
    } catch (e) {
      rxRequestStatus.value = Status.error;
      errorMessage.value = 'حدث خطأ في شبکه الاتصال';
      return false;
    }
  }

  Future<bool> resendOtp({required String username}) async {
    try {
      final response = await _apiClient.dio.post(
        "${Constants.baseUrl}/resend-otp",
        data: {'username': username},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
