import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/config/handle_logout.dart';
import 'package:inteshar/app/config/status.dart';
import 'package:inteshar/app/core/common/constants/api_client.dart';
import 'package:inteshar/app/core/common/widgets/exit_dialog.dart';
import 'package:inteshar/app/features/home/data/data_source/home_api_provider.dart';
import 'package:inteshar/app/features/purchase_methods/data/models/purchase_model.dart';

class PurchaseApiProvider extends GetxController {
  final rxRequestStatus = Status.initial.obs;
  var purchaseDataList = <PurchaseModel>[].obs;
  final errorMessage = ''.obs;
  final RxBool isProcessing = false.obs;
  final RxBool isSuccessful = true.obs;
  final RxInt totalPrintCount = 0.obs;
  final RxInt currentPrintCount = 0.obs;
  final HomeApiProvider updateController = Get.find<HomeApiProvider>();

  final ApiClient _apiClient = ApiClient();

  // @override
  // void onInit() {
  //   super.onInit();
  //   dio = Dio(BaseOptions(
  //     receiveTimeout: const Duration(milliseconds: 20000),
  //     validateStatus: (status) {
  //       return status! < 500;
  //     },
  //   ));
  // }

  Future<bool> fetchPurchase({
    required String counter,
    required String type,
    required String cardId,
  }) async {
    errorMessage.value = '';
    rxRequestStatus.value = Status.loading;
    isSuccessful.value = true;

    print(counter);
    print(type);
    print(cardId);
    print(Constants.userToken);
    try {
      final response = await _apiClient.dio.post(
        "${Constants.baseUrl}/print",
        queryParameters: {
          'serial_count': counter,
          'sell_type': type,
          'card_id': cardId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${Constants.userToken}',
            'Content-Type': 'application/json',
          },
          extra: {
            'safeToRetry': false,
            'warningMessage': 'حدث خطأ في الاتصال أثناء شراء الكارت. يرجى التحقق من رصيدك وقائمة مشترياتك أولاً لتجنب الشراء المكرر وسحب الرصيد مرتين. هل تريد إعادة المحاولة على أي حال؟',
          },
        ),
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        purchaseDataList.clear();
        purchaseDataList.add(PurchaseModel.fromJson(response.data));
        rxRequestStatus.value = Status.completed;
        //
        // await updateController.updateInformation();
        updateController.inventory.value = response.data['inventory'];
        updateController.update();
        print('1111printDate=======>${response.data['print_date']}');
        isSuccessful.value = true;
        return true;
      } else if (response.statusCode == 401) {
        handleLogout(response.data['error']);
        isSuccessful.value = false;
        return false;
      } else {
        print('===w==w=e=w=we=e=====');
        print(response.data['errors'][0]);
        if ((response.data?['logged_in'] ?? 1) == 0) {
          rxRequestStatus.value = Status.error;
          exitDialog(response.data['errors'][0]);
        } else {
          errorMessage.value = response.data?['errors']?[0] ?? 'حاول مرة أخرى';
          Get.closeAllSnackbars();
          Get.snackbar('خطأ', errorMessage.value);
          rxRequestStatus.value = Status.error;
        }

        isSuccessful.value = false;
        return false;
      }
    } catch (e) {
      print(e);
      errorMessage.value = 'حاول مرة أخرى';
      rxRequestStatus.value = Status.error;

      isSuccessful.value = false;
      return false;
    }
  }

  @override
  void onClose() {
    super.onClose();
    rxRequestStatus.value = Status.initial;
  }
}
