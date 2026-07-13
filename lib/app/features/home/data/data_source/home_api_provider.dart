import 'package:get/get.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/config/handle_logout.dart';
import 'package:inteshar/app/config/status.dart';
import 'package:inteshar/app/core/common/constants/api_client.dart';
import 'package:inteshar/app/features/home/data/models/home_model.dart';
import 'package:dio/dio.dart';
import 'package:inteshar/app/features/home/data/models/product_model.dart';

class HomeApiProvider extends GetxController {
  var homeDataList = <HomeModel>[].obs;
  var productsDataList = <ProductModel>[].obs;
  RxInt inventory = 000.obs;

  final rxRequestStatus = Status.loading.obs;
  final ApiClient _apiClient = ApiClient();
  @override
  void onInit() {
    super.onInit();

    // dio = Dio(BaseOptions(
    //   receiveTimeout: const Duration(milliseconds: 20000),
    //   validateStatus: (status) {
    //     return status! < 500;
    //   },
    // ));
    if (Constants.userToken.isNotEmpty) {
      Constants.isLoggedIn = true;
    }
    // fetchHomeData();
  }

  Future<void> fetchHomeData() async {
    print("userToken =======?>>: ${Constants.userToken.toString()}");
    rxRequestStatus.value = Status.loading;
    try {
      final response = await _apiClient.dio.get(
        "${Constants.baseUrl}/home",
        options: Options(
          headers: {
            'Authorization': 'Bearer ${Constants.userToken}',
            'Content-Type': 'application/json',
          },
        ),
      );
      print("response.statusCode =======?>>: ${response.statusCode}");
      if (response.statusCode == 200) {
        rxRequestStatus.value = Status.completed;
        homeDataList.clear();
        homeDataList.add(HomeModel.fromJson(response.data));
        productsDataList.clear();
        inventory.value = response.data?['user']?['total_balance'] ?? 000;
        if (response.data['card_categories'] != null &&
            response.data['card_categories'] is List) {
          productsDataList.addAll(
            (response.data['card_categories'] as List)
                .map((item) => ProductModel.fromJson(item))
                .toList(),
          );
        }
      } else if (response.statusCode == 401) {
        handleLogout(response.data['error']);
      } else if (response.statusCode == 400) {
        handleLogout('يرجى تسجيل الدخول مرة أخرى');
      } else {
        rxRequestStatus.value = Status.error;
      }
    } catch (e) {
      print(e);
      rxRequestStatus.value = Status.error;
    }
  }

  /// Handles theme color changes
}
