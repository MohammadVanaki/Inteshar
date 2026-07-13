import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:inteshar/app/features/home/data/models/home_model.dart';
import 'package:inteshar/app/features/home/repositories/home_repository.dart';

class CompanyArchiveController extends GetxController {
  final HomeRepository homeRepository = Get.find<HomeRepository>();
  RxList<Company> allCompanies = <Company>[].obs;
  RxList<Company> filteredCompanies = <Company>[].obs;
  TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    allCompanies.value =
        homeRepository.getHomeData().first.companyCategories.first.companies;
    filteredCompanies.value = allCompanies;
    searchController.addListener(() {
      filterListFunction();
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void filterListFunction() {
    final query = searchController.text.toLowerCase();

    if (query.isEmpty) {
      filteredCompanies.value = allCompanies;
    } else {
      filteredCompanies.value = allCompanies.where((item) {
        return (item.title ?? '').toLowerCase().contains(query);
      }).toList();
    }
  }
}
