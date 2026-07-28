import 'package:get/get.dart';
import 'package:inteshar/app/features/home/data/data_source/home_api_provider.dart';
import 'package:inteshar/app/features/home/data/models/home_model.dart';

class InternetPackagesController extends GetxController {
  final homeApiProvider = Get.find<HomeApiProvider>();

  final RxList<dynamic> companyList = RxList<dynamic>();
  final RxList<dynamic> packageList = [].obs;

  RxInt companySelected = 0.obs;
  @override
  void onInit() {
    super.onInit();
    companyList.assignAll(
      (homeApiProvider.homeDataList.firstOrNull?.asiacellCategories ?? [])
          .where((category) =>
              category.type == Type.BUNDLE && category.parentId == null)
          .map((category) => category.toJson())
          .toList(),
    );
    buildPackageList(3);
  }

  listOfPackage(int companyId) {
    buildPackageList(companyId);
  }

  buildPackageList(int index) {
    packageList.assignAll(
      (homeApiProvider.homeDataList.firstOrNull?.asiacellCategories ?? [])
          .where((category) =>
              category.type == Type.BUNDLE && category.parentId == index)
          .map((category) => category.toJson())
          .toList(),
    );
  }
}
