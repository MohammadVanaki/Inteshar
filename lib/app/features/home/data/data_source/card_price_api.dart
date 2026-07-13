import 'package:get/get.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/config/handle_logout.dart';
import 'package:inteshar/app/config/status.dart';
import 'package:dio/dio.dart';
import 'package:inteshar/app/core/common/constants/api_client.dart';
import 'package:inteshar/app/core/common/widgets/exit_dialog.dart';
import 'package:inteshar/app/features/home/data/models/card_price_model.dart';

class CardPriceApi extends GetxController {
  // late Dio dio;
  final rxRequestStatus = Status.initial.obs;
  var cardPriceData = <CardPriceModel>[].obs;
  CancelToken? cancelToken;
  final ApiClient _apiClient = ApiClient();
  // @override
  // void onInit() {
  //   super.onInit();

  //   dio = Dio(BaseOptions(
  //     receiveTimeout: const Duration(milliseconds: 10000),
  //     validateStatus: (status) {
  //       return status! < 500;
  //     },
  //   ));
  // }

  Future fetchCardPrice({required String cardId}) async {
    cardPriceData.clear();
    rxRequestStatus.value = Status.loading;
    print(cardId);

    if (cancelToken != null) {
      cancelToken?.cancel("Request cancelled due to new request.");
    }
    cancelToken = CancelToken();
    rxRequestStatus.value = Status.loading;
    try {
      final response = await _apiClient.dio.post(
        "${Constants.baseUrl}/card_price",
        queryParameters: {
          "card_id": cardId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${Constants.userToken}',
            'Content-Type': 'application/json',
          },
        ),
        cancelToken: cancelToken,
      );
      print(response.statusCode);

      print('-================${response.data['card_price']}');
      print('-================${response.data?['logged_in']}');
      if (response.statusCode == 200) {
        rxRequestStatus.value = Status.completed;
        cardPriceData.clear();
        cardPriceData.add(CardPriceModel.fromJson(response.data));
      } else if (response.statusCode == 401) {
        handleLogout(response.data['error']);
      } else {
        if ((response.data?['logged_in'] ?? 1) == 0) {
          exitDialog(response.data['errors'][0]);
        }
      }
    } catch (e) {
      print(e);
      rxRequestStatus.value = Status.error;
    }
  }
}
