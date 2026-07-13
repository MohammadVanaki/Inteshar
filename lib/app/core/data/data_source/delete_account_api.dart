import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/config/handle_logout.dart';
import 'package:inteshar/app/core/common/constants/api_client.dart';
import 'package:inteshar/app/core/common/widgets/exit_dialog.dart';
import 'package:inteshar/app/core/routes/routes.dart';

// final Dio dio = Dio(BaseOptions(
//   receiveTimeout: const Duration(milliseconds: 10000),
//   validateStatus: (status) {
//     return status! < 500;
//   },
// ));
final ApiClient _apiClient = ApiClient();

Future<void> deleteAccount() async {
  try {
    final response = await _apiClient.dio.get(
      "${Constants.baseUrl}/DeleteAccount",
      options: Options(
        headers: {
          'Authorization': 'Bearer ${Constants.userToken}',
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200) {
      Constants.localStorage.remove('userToken');
      Get.closeAllSnackbars();
      Get.snackbar('تنبيه', 'تم تسجيل الخروج بنجاح');
      Get.offAllNamed(Routes.welcomePage);
    } else if (response.statusCode == 401) {
      handleLogout(response.data['error']);
    } else {
      if ((response.data?['logged_in'] ?? 1) == 0) {
        exitDialog(response.data['errors'][0]);
      } else {
        Get.closeAllSnackbars();
        Get.snackbar('تنبيه', 'لم يتم تسجيل الخروج، يرجى اعادة المحاولة!');
      }
    }
  } catch (e) {
    Get.closeAllSnackbars();
    Get.snackbar('تنبيه', 'لم يتم تسجيل الخروج، يرجى اعادة المحاولة!');
    print(e);
  }
}
