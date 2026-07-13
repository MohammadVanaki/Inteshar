import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/config/constants.dart';

class SettingController extends GetxController {
  var settings = <String, bool>{}.obs;
  var isPreviewEnabled = true.obs;

  // Default settings for both preview and non-preview
  var defaultSettings = {
    // Preview settings
    "preview_printQrcode": false,
    "preview_printCardImage": false,
    "preview_printInformation": false,
    "preview_printBarCode": false,

    // Non-Preview settings
    "nonPreview_printQrcode": false,
    "nonPreview_printCardImage": false,
    "nonPreview_printInformation": false,
    "nonPreview_printBarCode": false,
  }.obs;

  @override
  void onInit() {
    super.onInit();
    var storedSettings = Constants.localStorage.read('settings');
    if (storedSettings != null) {
      settings.assignAll(Map<String, bool>.from(storedSettings));
    } else {
      settings.assignAll(Map<String, bool>.from(defaultSettings));
    }

    var storedPreview = Constants.localStorage.read('isPreviewEnabled');
    if (storedPreview != null) {
      isPreviewEnabled.value = storedPreview as bool;
    }
  }

  void saveSetting(String key, bool value) {
    settings[key] = value;
    Constants.localStorage.write('settings', settings);
  }

  void setPreviewEnabled(bool value) {
    isPreviewEnabled.value = value;
    Constants.localStorage.write('isPreviewEnabled', value);
  }

  /// Helper: generate key name based on preview state
  String getKey(String baseKey) {
    return isPreviewEnabled.value ? "preview_$baseKey" : "nonPreview_$baseKey";
  }
}
