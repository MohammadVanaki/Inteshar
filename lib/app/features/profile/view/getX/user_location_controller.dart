import 'package:dio/dio.dart';
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
        // Get.snackbar('Error', 'Location services are disabled.',
        //     snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // Request location permission
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          rxRequestStatus.value = Status.error;
          // Get.snackbar('Error', 'Location permissions are denied.',
          //     snackPosition: SnackPosition.BOTTOM);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        rxRequestStatus.value = Status.error;
        // Get.snackbar('Error', 'Location permissions are permanently denied.',
        //     snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // Get the user's current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Update the location variable
      location.value = 'Lat: ${position.latitude}, Long: ${position.longitude}';
      lat.value = position.latitude.toString();
      lon.value = position.longitude.toString();
      // Fetch address from API
      await fetchAddressFromAPI(position.latitude, position.longitude);

      // If everything is successful, set status to completed
      rxRequestStatus.value = Status.completed;
    } catch (e) {
      rxRequestStatus.value = Status.error;
      // Get.snackbar('Error', 'An error occurred: $e',
      //     snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Function to fetch address from API
  Future<void> fetchAddressFromAPI(double latitude, double longitude) async {
    final String apiUrl =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude';

    try {
      final response = await _dio.get(apiUrl);

      if (response.statusCode == 200) {
        // Extract the address from the response
        final data = response.data;
        String fetchedAddress = data['display_name'] ?? 'Address not found';
        editProfilePageController.addressController.text = fetchedAddress;
      } else {
        throw Exception('Failed to fetch address');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching address: $e');
    }
  }
}
