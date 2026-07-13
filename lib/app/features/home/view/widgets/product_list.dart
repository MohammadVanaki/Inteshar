import 'package:auto_height_grid_view/auto_height_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/config/status.dart';
import 'package:inteshar/app/core/routes/routes.dart';
import 'package:inteshar/app/core/utils/custom_loading.dart';
import 'package:inteshar/app/features/home/data/data_source/card_price_api.dart';
import 'package:inteshar/app/features/home/data/data_source/home_api_provider.dart';
import 'package:inteshar/app/features/home/data/models/home_model.dart';
import 'package:inteshar/app/features/home/view/screens/companies_archive_page.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class ProductsList extends StatelessWidget {
  const ProductsList({
    super.key,
    required this.products,
  });
  final List<Company> products;
  @override
  Widget build(BuildContext context) {
    final HomeApiProvider homeApiProvider = Get.find<HomeApiProvider>();
    return AutoHeightGridView(
      itemCount: products.length,
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      shrinkWrap: true,
      builder: (context, index) {
        CardPriceApi cardPriceApi =
            Get.put(CardPriceApi(), tag: index.toString());
        return ZoomTapAnimation(
          onTap: () {
            print('object');
            print('===============>${products[index].id}');
            final filteredList = homeApiProvider
                .homeDataList.first.cardCategories
                ?.where((card) => card.companyId == products[index].id)
                .toList();

            Get.toNamed(
              Routes.companiesArchivePage,
              arguments: CompaniesArchivePage(
                companyList: filteredList ?? [],
              ),
            );
          },
          child: Stack(
            children: [
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: Constants.intesharBoxDecoration(context)
                    .copyWith(color: Theme.of(context).colorScheme.primary),
                child: Column(
                  children: [
                    Center(
                      child: CachedNetworkImage(
                        fit: BoxFit.fill,
                        height: 120,
                        width: double.infinity,
                        imageUrl: products[index].logoUrl ?? '',
                        placeholder: (context, url) => const CustomLoading(),
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/images/not.jpg',
                          fit: BoxFit.fill,
                          height: 120,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        products[index].title ?? '',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ],
                ),
              ),
              Obx(
                () => Visibility(
                  visible: cardPriceApi.rxRequestStatus.value == Status.loading
                      ? true
                      : false,
                  child: Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const CustomLoading(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
