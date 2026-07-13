import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/core/update_helper/update_helper.dart';

class UpdateController extends GetxController {
  void checkUpdate(BuildContext context) {
    final updater = UpdateHelper(
      context: context,
      versionCheckUrl: 'https://inteshar.net/inteshar_version.json',
    );
    updater.checkForUpdate();
  }
}
