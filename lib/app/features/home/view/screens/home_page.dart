import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/config/functions.dart';
import 'package:inteshar/app/config/status.dart';
import 'package:inteshar/app/core/common/widgets/offline_widget.dart';
import 'package:inteshar/app/core/common/widgets/retry_widget.dart';
import 'package:inteshar/app/core/routes/routes.dart';
import 'package:inteshar/app/core/utils/custom_loading.dart';
import 'package:inteshar/app/features/home/data/data_source/home_api_provider.dart';
import 'package:inteshar/app/features/home/data/models/home_model.dart';
import 'package:inteshar/app/features/home/view/getX/company_slider_controller.dart';
import 'package:inteshar/app/features/home/view/widgets/ad_slider.dart';
import 'package:inteshar/app/features/home/view/widgets/company_list_slider.dart';
import 'package:inteshar/app/features/home/view/widgets/favority_item.dart';
import 'package:inteshar/app/features/home/view/widgets/other_services.dart';
import 'package:inteshar/app/features/home/view/widgets/product_list.dart';
import 'package:inteshar/app/features/home/view/widgets/separator.dart';
import 'package:inteshar/app/features/page_view/view/getX/scaffold_controller.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.scaffoldController,
  });

  // Function to refresh the home data
  Future<void> _refreshData(HomeApiProvider homeApiProvider) async {
    await homeApiProvider.fetchHomeData();
  }

  final ScaffoldController scaffoldController;
  @override
  Widget build(BuildContext context) {
    // final ProductsApiProvider productsApiProvider = Get.find(tag: 'random');
    final CompanySliderController companySliderController =
        Get.put(CompanySliderController());
    final HomeApiProvider homeApiProvider = Get.put(HomeApiProvider());

    homeApiProvider.fetchHomeData();
    return SizedBox(
      width: Get.width,
      child: Obx(
        () {
          switch (homeApiProvider.rxRequestStatus.value) {
            case Status.completed:
              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: Get.width,
                    margin: const EdgeInsets.only(top: 105),
                    child: LiquidPullToRefresh(
                      onRefresh: () async {
                        _refreshData(homeApiProvider);
                        companySliderController.activeCompany.value = -1;
                        companySliderController.selected.value = -1;
                        companySliderController.isLoading.value = false;
                      },
                      showChildOpacityTransition: false,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      springAnimationDurationInMilliseconds: 1500,
                      color:
                          Theme.of(context).colorScheme.secondary.withAlpha(70),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20)
                              .copyWith(top: 60),
                          child: Column(
                            children: [
                              const Separator(title: 'خدمات مميزة'),
                              const OtherServices(),
                              const Gap(20),
                              AdSlider(homeApiProvider: homeApiProvider),
                              const Separator(
                                title: 'الشركات',
                              ),
                              CompanyListSlider(
                                  companyList: homeApiProvider.homeDataList),
                              const Gap(20),
                              Obx(() {
                                if (companySliderController
                                        .activeCompany.value ==
                                    -1) {
                                  final List<Company> allCompanies = [];
                                  for (var category in homeApiProvider
                                      .homeDataList.first.companyCategories) {
                                    allCompanies.addAll(
                                        List<Company>.from(category.companies));
                                  }

                                  return ProductsList(
                                    products: allCompanies,
                                  );
                                } else {
                                  return ProductsList(
                                    products: homeApiProvider
                                        .homeDataList
                                        .first
                                        .companyCategories[
                                            companySliderController
                                                .selected.value]
                                        .companies,
                                  );
                                }
                              }),
                              const Gap(10),
                              const FavorityItem(),
                              const Gap(90),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    width: Get.width,
                    height: 190,
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.primary,
                        BlendMode.modulate,
                      ),
                      child: Image.asset(
                        'assets/images/cr-main.png',
                        width: Get.width,
                        height: 190,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    child: SizedBox(
                      width: Get.width,
                      child: Column(
                        children: [
                          const Gap(10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ZoomTapAnimation(
                                  onTap: () {
                                    if (scaffoldController.drawerOpen.value) {
                                      scaffoldController.closeDrawer();
                                    } else {
                                      scaffoldController.openDrawer();
                                    }
                                  },
                                  child: SvgPicture.asset(
                                    'assets/svgs/bars-staggered.svg',
                                    colorFilter: ColorFilter.mode(
                                      Theme.of(context).colorScheme.onPrimary,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                                Constants.isLoggedIn
                                    ? Obx(
                                        () {
                                          HomeModel? user;
                                          if (homeApiProvider
                                              .homeDataList.isNotEmpty) {
                                            user = homeApiProvider
                                                .homeDataList.first;
                                          }

                                          return user != null
                                              ? Text(
                                                  user.user?.name ?? '',
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary,
                                                    fontSize: 17,
                                                  ),
                                                )
                                              : const SizedBox.shrink();
                                        },
                                      )
                                    : const OfflineWidget(
                                        showLogo: false,
                                      ),
                                ZoomTapAnimation(
                                  onTap: () {
                                    Get.toNamed(
                                      Routes.notifArchive,
                                    );
                                  },
                                  child: SvgPicture.asset(
                                    'assets/svgs/bell.svg',
                                    colorFilter: ColorFilter.mode(
                                      Theme.of(context).colorScheme.onPrimary,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Constants.isLoggedIn
                              ? Obx(
                                  () {
                                    if (homeApiProvider.homeDataList.isEmpty) {
                                      return const Center(
                                        child: CustomLoading(),
                                      );
                                    }

                                    return Column(
                                      children: [
                                        const Gap(5),
                                        Obx(
                                          () => Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                formatNumber(homeApiProvider
                                                        .inventory.value) ??
                                                    '',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const Gap(10),
                                              ZoomTapAnimation(
                                                onTap: () {
                                                  _refreshData(homeApiProvider);
                                                  companySliderController
                                                      .activeCompany.value = -1;
                                                  companySliderController
                                                      .selected.value = -1;
                                                  companySliderController
                                                      .isLoading.value = false;
                                                },
                                                child: SvgPicture.asset(
                                                  'assets/svgs/rotate-square.svg', 
                                                  colorFilter: ColorFilter.mode(
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                    BlendMode.srcIn,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                )
                              : const SizedBox.shrink(),
                        ], 
                      ),
                    ),
                  ),
                ],
              );
            case Status.loading:
              return const CustomLoading();
            case Status.error:
              return RetryWidget(
                onTap: () {
                  homeApiProvider.fetchHomeData();
                },
              );
            default:
              return const Text("Unknown state");
          }
        },
      ),
    );
  }
}
