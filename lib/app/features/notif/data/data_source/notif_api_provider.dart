import 'dart:io';

import 'package:get/get.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/config/handle_logout.dart';
import 'package:inteshar/app/config/status.dart';
import 'package:dio/dio.dart';
import 'package:inteshar/app/core/common/constants/api_client.dart';
import 'package:inteshar/app/core/common/widgets/exit_dialog.dart';
import 'package:inteshar/app/features/notif/data/models/notif_model.dart';

class NotifApiProvider extends GetxController {
  var notifDataList = <NotificationsModel>[].obs;

  String deviceType = '';
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
    fetchNotifData();
  }

  Future<void> fetchNotifData() async {
    rxRequestStatus.value = Status.loading;
    if (Platform.isAndroid) {
      deviceType = 'android';
    } else if (Platform.isIOS) {
      deviceType = 'iOS';
    } else {
      deviceType = 'Unknown';
    }
    print('deviceType ---->$deviceType');
    try {
      final response = await _apiClient.dio.post(
        "${Constants.baseUrl}/notifications",
        queryParameters: {
          'device_type': deviceType,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${Constants.userToken}',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        rxRequestStatus.value = Status.completed;
        notifDataList.clear();
        notifDataList.add(NotificationsModel.fromJson(response.data));
      } else if (response.statusCode == 401) {
        handleLogout(response.data['error']);
      } else {
        if ((response.data?['logged_in'] ?? 1) == 0) {
          rxRequestStatus.value = Status.error;
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
