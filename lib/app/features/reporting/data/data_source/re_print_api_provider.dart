import 'package:get/get.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/config/handle_logout.dart';
import 'package:inteshar/app/config/status.dart';
import 'package:dio/dio.dart';
import 'package:inteshar/app/core/common/constants/api_client.dart';
import 'package:inteshar/app/core/common/widgets/exit_dialog.dart';
import 'package:inteshar/app/features/reporting/data/models/re_print_model.dart';

class RePrintApiProvider extends GetxController {
  var rePrintDataList = <RePrintModel>[].obs;
  // late Dio dio;
  final rxRequestStatus = Status.initial.obs;

  final ApiClient _apiClient = ApiClient();

  // @override
  // void onInit() {
  //   super.onInit();
  //   dio = Dio(BaseOptions(
  //     receiveTimeout: const Duration(milliseconds: 10000),
  //     validateStatus: (status) {
  //       return status! < 500;
  //     },
  //   ));
  // }

  Future<bool> fetchRePrintData({
    required String cardId,
    required String serialId,
  }) async {
    rxRequestStatus.value = Status.loading;
    try {
      print(cardId);
      print(serialId);
      final response = await _apiClient.dio.post(
        "${Constants.baseUrl}/re_print",
        queryParameters: {
          'card_id': cardId,
          'serial_id': serialId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${Constants.userToken}',
            'Content-Type': 'application/json',
          },
          extra: {
            'safeToRetry': false,
            'warningMessage': 'حدث خطأ في الاتصال أثناء طلب إعادة الطباعة. قد يؤدي التكرار إلى استهلاك الحد الأقصى المسموح به لإعادة الطباعة. هل تريد إعادة المحاولة؟',
          },
        ),
      );
      print(response.statusCode);

      if (response.statusCode == 200) {
        rxRequestStatus.value = Status.completed;
        rePrintDataList.clear();
        rePrintDataList.add(RePrintModel.fromJson(response.data));

        return true;
      } else if (response.statusCode == 401) {
        handleLogout(response.data['error']);
        return false;
      } else {
        if ((response.data?['logged_in'] ?? 1) == 0) {
          exitDialog(response.data['errors'][0]);
        } else {
          rxRequestStatus.value = Status.error;
          Get.closeAllSnackbars();
          Get.snackbar('خطأ', response.data['error']);
        }
        return false;
      }
    } catch (e) {
      print(e);
      rxRequestStatus.value = Status.error;
      Get.closeAllSnackbars();
      Get.snackbar('خطأ', 'فشل في جلب البيانات.');
      return false;
    }
  }
}
