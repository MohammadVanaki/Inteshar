import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inteshar/app/features/home/data/data_source/home_api_provider.dart';

class EditProfilePageController extends GetxController {
  final updateController = Get.find<HomeApiProvider>();
  final RxBool isPasswordHidden = true.obs;
  final RxBool isPasswordHiddenConfirm = true.obs;
  RxString networkImageUrl = ''.obs;
  var pickedImageFile = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

  final addressController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    if (updateController.homeDataList.isNotEmpty) {
      final user = updateController.homeDataList.first;
      networkImageUrl.value = user.user?.photoUrl ?? '';
    } else {
      networkImageUrl = ''.obs;
    }
  }

  @override
  void onClose() {
    addressController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    super.onClose();
  }

  // Method to pick image from gallery and crop in circle shape
  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 90,
    );

    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 85,
        maxWidth: 512,
        maxHeight: 512,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'قص الصورة',
            toolbarColor: const Color(0xFF1E1E1E),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            cropStyle: CropStyle.circle,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
            ],
          ),
          IOSUiSettings(
            title: 'قص الصورة',
            cropStyle: CropStyle.circle,
            aspectRatioPickerButtonHidden: true,
            resetAspectRatioEnabled: false,
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      if (croppedFile != null) {
        pickedImageFile.value = File(croppedFile.path);
      }
    }
  }

  // Method to reset to network image
  void resetToNetworkImage() {
    pickedImageFile.value = null;
  }

  // متد تبدیل تصویر به Base64 (تصویر JPEG فشرده و کراپ‌شده با Prefix مناسب)
  String? convertImageToBase64() {
    final imageFile = pickedImageFile.value;
    if (imageFile != null) {
      final bytes = imageFile.readAsBytesSync();
      final base64String = base64Encode(bytes);
      return 'data:image/jpeg;base64,$base64String';
    }
    return null;
  }
}
