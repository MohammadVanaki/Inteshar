import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/config/functions.dart';
import 'package:inteshar/app/config/handle_logout.dart';
import 'package:inteshar/app/config/status.dart';
import 'package:inteshar/app/core/common/constants/api_client.dart';
import 'package:inteshar/app/core/common/widgets/exit_dialog.dart';
import 'package:inteshar/app/features/home/data/data_source/home_api_provider.dart';

class EditeProfileApiProvider extends GetxController {
  final rxRequestStatus = Status.initial.obs;
  final errorMessage = ''.obs;
  final ApiClient _apiClient = ApiClient();
  // final Rx<File?> pickedImageFile = Rx<File?>(null);
  Future<bool> updateProfile({
    required String address,
    required String mobile,
    // String? printCode,
    required String password,
    required String passwordConfirmation,
    required dynamic photo,
    required String? lat,
    required String? lon,
    // required String? activeCode,
  }) async {
    rxRequestStatus.value = Status.loading;
    errorMessage.value = '';
    String deviceId = '';
    try {
      print('Lat: $lat, Long: $lon');
      // print('printCode: $printCode');
      deviceId = (await getId()) ?? 'unknown';
      final Map<String, dynamic> bodyData = {
        'address': address,
        'mobile': mobile,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'lat': lat ?? "",
        'lon': lon ?? "",
        'photo': photo,
        // 'active_print_code': activeCode,
        'device_token': deviceId,
      };
      // if (printCode != null) {
      //   bodyData["print_code"] = printCode;
      // }
      final response = await _apiClient.dio.post(
        "${Constants.baseUrl}/update_profile",
        data: bodyData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${Constants.userToken}',
            'Accept': 'application/json',
          },
        ),
      );
      print('Update Profile${response.statusCode}');
      print('Update Profile${response.data}');

      if (response.statusCode == 200) {
        Constants.localStorage.remove('userInfo');
        Get.closeAllSnackbars();
        Get.snackbar(
          'تنبيه',
          'تم حفظ المعلومات بنجاح',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
          borderRadius: 15,
          margin: const EdgeInsets.all(15),
          duration: const Duration(seconds: 3),
          mainButton: TextButton(
            onPressed: () => Get.back(),
            child: const Text('تم', style: TextStyle(color: Colors.white)),
          ),
        );
        rxRequestStatus.value = Status.completed;
        final HomeApiProvider updateController = Get.find<HomeApiProvider>();
        await updateController.fetchHomeData();
        return true;
      } else if (response.statusCode == 401) {
        handleLogout(response.data['error']['message']);
        return false;
      } else if (response.statusCode == 422) {
        rxRequestStatus.value = Status.error;
        errorMessage.value =
            response.data['message'] ?? response.data['errors']?[0];
        return false;
      } else {
        if ((response.data?['logged_in'] ?? 1) == 0) {
          rxRequestStatus.value = Status.error;
          exitDialog(response.data['errors'][0]);
        } else {
          errorMessage.value = 'لم يتم حفظ المعلومات بشكل صحيح';
          rxRequestStatus.value = Status.error;
        }
        return false;
      }
    } catch (e) {
      errorMessage.value = 'لم يتم حفظ المعلومات بشكل صحيح';
      print('Login Error! :$e');
      rxRequestStatus.value = Status.error;
      return false;
    }
  }
}
