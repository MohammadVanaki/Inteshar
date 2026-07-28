import 'package:get/get.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/config/status.dart';
import 'package:dio/dio.dart';
import 'package:inteshar/app/core/common/constants/api_client.dart';
import 'package:inteshar/app/features/home/data/models/product_model.dart';

class ProductsApiProvider extends GetxController {
  var productsDataList = <ProductModel>[].obs;
  final ApiClient _apiClient = ApiClient();
  final rxRequestStatus = Status.initial.obs;

  Future<void> fetchProducts(int companyId) async {
    print(companyId);
    print(Constants.userToken);
    rxRequestStatus.value = Status.loading;
    try {
      final response = await _apiClient.dio.post(
        "${Constants.baseUrl}/company_categories",
        queryParameters: {
          "company_id": companyId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${Constants.userToken}',
          },
        ),
      );

      print(response.statusCode);
      print(response);

      if (response.statusCode == 200) {
        rxRequestStatus.value = Status.completed;

        productsDataList.clear();
        productsDataList.addAll(
          (response.data['card_categories'] as List)
              .map((item) => ProductModel.fromJson(item))
              .toList(),
        );
        print(response.statusCode);
      } else {
        rxRequestStatus.value = Status.error;
        Get.snackbar('خطأ', 'فشل في جلب البيانات.');
      }
    } catch (e) {
      print(e);
      rxRequestStatus.value = Status.error;
    }
  }
}
