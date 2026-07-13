import 'package:get/get.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/config/handle_logout.dart';
import 'package:inteshar/app/config/status.dart';
import 'package:dio/dio.dart';
import 'package:inteshar/app/core/common/constants/api_client.dart';
import 'package:inteshar/app/core/common/widgets/exit_dialog.dart';
import 'package:inteshar/app/features/reporting/data/models/report_model.dart';

class ReportListApiProvider extends GetxController {
  var reportDataList = <ReportModel>[].obs;
  late Rx<Status> rxRequestStatus;
  late Rx<Status> rxRequestButtonStatus;
  final ApiClient _apiClient = ApiClient();
  @override
  void onInit() {
    super.onInit();
    rxRequestStatus = Status.initial.obs;
    rxRequestButtonStatus = Status.initial.obs;
    // dio = Dio(BaseOptions(
    //   receiveTimeout: const Duration(milliseconds: 10000),
    //   validateStatus: (status) {
    //     return status! < 500;
    //   },
    // ));
  }

  Future<void> fetchReportData({
    required String productId,
    required String companyId,
    required String startDate,
    required String endDate,
  }) async {
    rxRequestStatus.value = Status.loading;
    rxRequestButtonStatus.value = Status.loading;
    print('response.statusCode :===> ${productId}');
    print('response.statusCode :===> ${companyId}');
    print('response.statusCode :===> ${startDate}');
    print('response.statusCode :===> ${endDate}');

    try {
      final response = await _apiClient.dio.post(
        "${Constants.baseUrl}/sell_serials",
        queryParameters: {
          'card_category_id': productId,
          'company_id': companyId,
          'start_date': startDate,
          'end_date': endDate,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${Constants.userToken}',
            'Content-Type': 'application/json',
          },
        ),
      );
      print('response.statusCode :===> ${response.statusCode}');
      if (response.statusCode == 200) {
        reportDataList.clear();
        reportDataList.add(ReportModel.fromJson(response.data));
        rxRequestStatus.value = Status.completed;
        await Future.delayed(const Duration(seconds: 2));
        rxRequestButtonStatus.value = Status.completed;
      } else if (response.statusCode == 401) {
        handleLogout(response.data['error']);
      } else {
        // rxRequestStatus.value = Status.error;
        // Get.closeAllSnackbars();

        if ((response.data?['logged_in'] ?? 1) == 0) {
          rxRequestStatus.value = Status.error;
          rxRequestButtonStatus.value = Status.error;
          exitDialog(response.data['errors'][0]);
        } else {
          rxRequestStatus.value = Status.error;
          rxRequestButtonStatus.value = Status.error;
          Get.snackbar('خطأ', 'فشل في جلب البيانات.');
        }
      }
    } catch (e) {
      print(e);
      rxRequestStatus.value = Status.error;
      Get.closeAllSnackbars();
      Get.snackbar('خطأ', 'فشل في جلب البيانات.');
    }
  }
}
