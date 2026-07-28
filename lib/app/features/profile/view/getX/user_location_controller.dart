import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/config/status.dart';
import 'package:inteshar/app/features/profile/view/getX/edit_profile_page_controller.dart';

class LocationController extends GetxController {
  RxString location = ''.obs;
  RxString address = ''.obs;
  RxString lat = ''.obs;
  RxString lon = ''.obs;
  final Dio _dio = Dio();
  final editProfilePageController = Get.find<EditProfilePageController>();

  // Enum for request status
  final rxRequestStatus = Status.initial.obs;

  // Function to get user location
  Future<void> getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Set status to loading
    rxRequestStatus.value = Status.loading;

    try {
      // Check if location services are enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        rxRequestStatus.value = Status.error;
        Get.snackbar(
          'تنبيه',
          'خدمات الموقع (GPS) غير مفعلة، يرجى تفعيلها من إعدادات الجهاز.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange.withAlpha(230),
          colorText: Colors.white,
        );
        return;
      }

      // Request location permission
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          rxRequestStatus.value = Status.error;
          Get.snackbar(
            'خطأ',
            'تم رفض إذن الوصول إلى الموقع.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red.withAlpha(230),
            colorText: Colors.white,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        rxRequestStatus.value = Status.error;
        Get.snackbar(
          'خطأ',
          'إذن الموقع مرفوض بشكل دائم، يرجى تفعيله من إعدادات التطبيق.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withAlpha(230),
          colorText: Colors.white,
        );
        await Geolocator.openAppSettings();
        return;
      }

      // Get current position with fallback
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 8),
          ),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) {
        rxRequestStatus.value = Status.error;
        Get.snackbar(
          'خطأ',
          'تعذر تحديد موقع الجهاز حالياً.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withAlpha(230),
          colorText: Colors.white,
        );
        return;
      }

      // Update location variables
      location.value = 'Lat: ${position.latitude}, Long: ${position.longitude}';
      lat.value = position.latitude.toString();
      lon.value = position.longitude.toString();

      // Fetch address from API
      await fetchAddressFromAPI(position.latitude, position.longitude);

      // Set status to completed
      rxRequestStatus.value = Status.completed;
    } catch (e) {
      rxRequestStatus.value = Status.error;
      debugPrint('Location Error: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء جلب الموقع: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withAlpha(230),
        colorText: Colors.white,
      );
    }
  }

  // Function to fetch address from API
  Future<void> fetchAddressFromAPI(double latitude, double longitude) async {
    final String apiUrl =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude';

    try {
      final response = await _dio.get(
        apiUrl,
        options: Options(
          headers: {
            'User-Agent': 'IntesharApp/1.0 (com.dijlah.inteshar)',
            'Accept-Language': 'ar,en',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        String fetchedAddress = data['display_name'] ?? '';
        if (fetchedAddress.isNotEmpty) {
          editProfilePageController.addressController.text = fetchedAddress;
        }
      }
    } catch (e) {
      debugPrint('Fetch Address API Error: $e');
    }
  }
}
