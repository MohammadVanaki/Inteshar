import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/config/status.dart';
import 'package:inteshar/app/core/routes/routes.dart';
import 'package:inteshar/app/features/auth/data/data_source/otp_api_provider.dart';

class OtpController extends GetxController {
  final OtpApiProvider _apiProvider = Get.put(OtpApiProvider());

  final String username = Get.arguments['username'] ?? '';
  final String password = Get.arguments['password'] ?? '';
  final String userId = Get.arguments['userId'] ?? '';
  final String deviceToken = Get.arguments['deviceToken'] ?? '';
  final int expireTime = Get.arguments['expire_time'] ?? 120;
  final String status = Get.arguments['status'] ?? '';
  final String qr = Get.arguments['qr'] ?? '';
  final String secret = Get.arguments['secret'] ?? '';
  Rx<Status> rxRequestStatus = Status.initial.obs;
  RxString errorMessage = ''.obs;
  final TextEditingController pinController = TextEditingController();
  RxBool isResendLoading = false.obs;
  RxBool isResendEnabled = false.obs;
  RxInt remainingSeconds = 0.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    remainingSeconds.value = expireTime;
    startTimer();
  }

  void startTimer() {
    isResendEnabled.value = false;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        isResendEnabled.value = true;
        _timer?.cancel();
      }
    });
  }

  void verifyOtp(String otpCode) async {
    if (otpCode.length < 6) {
      Get.snackbar('تنبیه', 'یرجی إدخال رمز التحقق المكون من 6 أرقام');
      return;
    }

    rxRequestStatus.value = Status.loading;

    bool success = await _apiProvider.verifyOtp(
      username: username,
      password: password,
      deviceToken: deviceToken,
      userId: userId,
      code: otpCode,
    );
    print("========>>>>${success}");
    if (success) {
      rxRequestStatus.value = Status.completed;
      Get.offAllNamed(Routes.home);
    } else {
      rxRequestStatus.value = Status.error;
      errorMessage.value = _apiProvider.errorMessage.value;

      Get.snackbar(
        'خطأ',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> resendCode() async {
    isResendLoading.value = true;

    try {
      bool success = await _apiProvider.resendOtp(username: username);
      if (success) {
        remainingSeconds.value = expireTime;
        startTimer();
        Get.snackbar('تم', 'تم إعادة إرسال الكود');
      }
    } finally {
      isResendLoading.value = false;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
