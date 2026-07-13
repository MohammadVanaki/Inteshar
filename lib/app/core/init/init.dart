import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:inteshar/app/features/home/data/data_source/home_api_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/config/error_widget.dart';
import 'package:inteshar/app/core/common/constants/get_version.dart';
import 'package:inteshar/app/features/page_view/view/getX/scaffold_controller.dart';

import 'package:inteshar/app/features/setting/view/getX/setting_controller.dart';

Future<void> init() async {

  Get.put(ScaffoldController());
  Get.put(AppVersionController());
  // Initialize the custom error widget
  CustomErrorWidget.initialize();
  await GetStorage.init();
  Get.put(SettingController());
  Constants.userToken = Constants.localStorage.read('userToken') ?? '';
  Get.put(HomeApiProvider());

  print('Token: ${Constants.userToken}');
  if (Constants.userToken.isNotEmpty) {
    Constants.isLoggedIn = true;
  }

  await [
    Permission.bluetooth,
    Permission.bluetoothScan,
    Permission.bluetoothAdvertise,
    Permission.bluetoothConnect,
  ].request();
}
