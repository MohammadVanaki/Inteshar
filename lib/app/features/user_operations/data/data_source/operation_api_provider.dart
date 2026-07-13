import 'package:get/get.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/config/handle_logout.dart';
import 'package:inteshar/app/config/status.dart';
import 'package:dio/dio.dart';
import 'package:inteshar/app/core/common/constants/api_client.dart';
import 'package:inteshar/app/core/common/widgets/exit_dialog.dart';
import 'package:inteshar/app/features/user_operations/data/models/operation_model.dart';

class OperationApiProvider extends GetxController {
  var operationDataList = <OperationModel>[].obs;
  final rxRequestStatus = Status.loading.obs;
  final ApiClient _apiClient = ApiClient();

  @override
  void onInit() {
    super.onInit();
    // dio = Dio(BaseOptions(
    //   receiveTimeout: const Duration(milliseconds: 10000),
    //   validateStatus: (status) {
    //     return status! < 500;
    //   },
    // ));
    fetchOperationData();
  }

  Future<void> fetchOperationData() async {
    rxRequestStatus.value = Status.loading;
    try {
      final response = await _apiClient.dio.get(
        "${Constants.baseUrl}/turnover",
        options: Options(
          headers: {
            'Authorization': 'Bearer ${Constants.userToken}',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        rxRequestStatus.value = Status.completed;
        operationDataList.clear();
        operationDataList.add(OperationModel.fromJson(response.data));
      } else if (response.statusCode == 401) {
        handleLogout(response.data['error']);
      } else {
        if ((response.data?['logged_in'] ?? 1) == 0) {
          exitDialog(response.data['errors'][0]);
        } else {
          rxRequestStatus.value = Status.error;
        }
      }
    } catch (e) {
      print(e);
      rxRequestStatus.value = Status.error;
    }
  }
}
