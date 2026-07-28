import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/features/home/data/data_source/products_api_provider.dart';
import 'package:inteshar/app/features/home/data/models/home_model.dart';
import 'package:inteshar/app/features/home/view/getX/company_slider_controller.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class CompanyListSlider extends StatelessWidget {
  const CompanyListSlider({
    super.key,
    required this.companyList,
  });
  final List<HomeModel> companyList;
  @override
  Widget build(BuildContext context) {
    final CompanySliderController companySliderController =
        Get.put(CompanySliderController());

// Define a modifiable list of maps
    final List<Map<String, dynamic>> parsCompanyList = [
      {
        'title': 'الكل',
        'id': -1,
      },
    ];

// Iterate over the categories of the first company in companyList
    for (var i = 0; i < companyList.first.companyCategories.length; i++) {
      var category = companyList.first.companyCategories[i];

      parsCompanyList.add({
        'title': category.title, // Retrieve category title
        'id': category.id, // Retrieve category id
      });
    }

    return SizedBox(
      height: 43.0,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: min(parsCompanyList.length, 10),
        itemBuilder: (BuildContext context, int index) => ZoomTapAnimation(
          onTap: () {
            print(parsCompanyList[index]['id']);
            companySliderController.selected.value = index - 1;
            companySliderController.activeCompany.value =
                parsCompanyList[index]['id'];
            // companySliderController.currentCompany(
            //   index,
            // );
            // productsApiProvider.fetchProducts(parsCompanyList[index]['id']);
          },
          child: Obx(
            () {
              final isSelected =
                  (index - 1) == companySliderController.selected.value;
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Container(
                margin:
                    const EdgeInsets.only(left: 4, top: 4, bottom: 4, right: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    // Outer soft bottom shadow for depth/elevation
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.4)
                          : Colors.black.withValues(alpha: 0.08),
                      blurRadius: isSelected ? 8 : 4,
                      offset: isSelected
                          ? const Offset(0, 3)
                          : const Offset(0, 1.5),
                    ),
                    // Inner/outer top white light-reflection to make it look raised
                    BoxShadow(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.white.withValues(alpha: 0.7),
                      blurRadius: 4,
                      offset: const Offset(0, -1.5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: const Alignment(-0.6, -1.0),
                          end: const Alignment(0.6, 1.0),
                          colors: isSelected
                              ? [
                                  Colors.white
                                      .withValues(alpha: isDark ? 0.95 : 0.95),
                                  Colors.white
                                      .withValues(alpha: isDark ? 0.90 : 0.90),
                                  Colors.white.withValues(alpha: 1.0),
                                  Colors.white
                                      .withValues(alpha: isDark ? 0.70 : 0.75),
                                  Colors.white
                                      .withValues(alpha: isDark ? 0.80 : 0.85),
                                ]
                              : [
                                  Colors.white
                                      .withValues(alpha: isDark ? 0.25 : 0.55),
                                  Colors.white
                                      .withValues(alpha: isDark ? 0.20 : 0.45),
                                  Colors.white
                                      .withValues(alpha: isDark ? 0.45 : 0.80),
                                  Colors.white
                                      .withValues(alpha: isDark ? 0.05 : 0.15),
                                  Colors.white
                                      .withValues(alpha: isDark ? 0.10 : 0.25),
                                ],
                          stops: const [0.0, 0.46, 0.50, 0.54, 1.0],
                        ),
                        border: Border.all(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.9)
                              : Colors.white.withValues(alpha: 0.45),
                          width: 1.2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          parsCompanyList[index]['title'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isSelected
                                ? Colors.black87
                                : (isDark
                                    ? Colors.white70
                                    : Colors.black87.withValues(alpha: 0.75)),
                          ),
                        ),
                      ), // child: CachedNetworkImage(
                      //   fit: BoxFit.cover,
                      //   width: index == companySliderController.selected.value
                      //       ? 120
                      //       : 80,
                      //   height: 80,
                      //   imageUrl: companyList.first.companies[index].logoUrl,
                      //   placeholder: (context, url) => const CustomLoading(),
                      //   errorWidget: (context, url, error) => Image.asset(
                      //     'assets/images/not.jpg',
                      //     fit: BoxFit.fill,
                      //     width: index == companySliderController.selected.value
                      //         ? 120
                      //         : 80,
                      //     height: 80,
                      //   ),
                      // ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
