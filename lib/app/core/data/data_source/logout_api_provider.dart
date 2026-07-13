import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/config/functions.dart';
import 'package:inteshar/app/config/handle_logout.dart';
import 'package:inteshar/app/core/common/constants/api_client.dart';
import 'package:inteshar/app/core/routes/routes.dart';

final ApiClient _apiClient = ApiClient();

class LogoutApiProvider extends GetxController {
  var isLogoutLoading = false.obs;
  String deviceId = '';
  Future<void> logoutUser() async {
    try {
      isLogoutLoading.value = true;
      deviceId = (await getId()) ?? 'unknown';
      final response = await _apiClient.dio.post(
        "${Constants.baseUrl}/logout",
        data: {
          'device_token': deviceId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${Constants.userToken}',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        Constants.localStorage.remove('userToken');
        Constants.isLoggedIn = false;
        Get.closeAllSnackbars();
        Get.snackbar('تنبيه', 'تم تسجيل الخروج بنجاح');
        Get.offAllNamed(Routes.welcomePage);
      } else if (response.statusCode == 401) {
        handleLogout(response.data['error']['message']);
      } else {
        Get.snackbar('تنبيه', 'لم يتم تسجيل الخروج، يرجى اعادة المحاولة!');
      }
    } catch (e) {
      Get.snackbar('تنبيه', 'لم يتم تسجيل الخروج، يرجى اعادة المحاولة!');
      print(e);
    } finally {
      isLogoutLoading.value = false;
    }
  }
}
