import 'package:auto_height_grid_view/auto_height_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/config/functions.dart';
import 'package:inteshar/app/config/status.dart';
import 'package:inteshar/app/core/extensions/success_color_theme.dart';
import 'package:inteshar/app/core/utils/custom_loading.dart';
import 'package:inteshar/app/features/home/data/data_source/card_price_api.dart';
import 'package:inteshar/app/features/home/view/getX/favority_controller.dart';
import 'package:inteshar/app/features/home/view/getX/purchase_methods_controller.dart';
import 'package:inteshar/app/features/home/view/widgets/separator.dart';
import 'package:inteshar/app/features/purchase_methods/data/data_source/purchase_api_provider.dart';
import 'package:inteshar/app/features/purchase_methods/repositories/methods_manager.dart';
import 'package:inteshar/app/features/purchase_methods/view/screens/purchase_methods_item.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class FavorityItem extends StatelessWidget {
  const FavorityItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final FavorityController favorityController = Get.put(FavorityController());
    final TextEditingController countController = TextEditingController();
    String cardPricestr = '';
    return Obx(
      () {
        return favorityController.favoriteItems.isNotEmpty
            ? Column(
                children: [
                  const Separator(
                    title: 'المفضلة',
                  ),
                  AutoHeightGridView(
                    itemCount: favorityController.favoriteItems.length,
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    shrinkWrap: true,
                    builder: (context, index) {
                      CardPriceApi cardPriceApi = Get.put(CardPriceApi(),
                          tag: 'fav${index.toString()}');
                      return ZoomTapAnimation(
                        onTap: () {
                          cardPriceApi
                              .fetchCardPrice(
                                  cardId: favorityController
                                      .favoriteItems[index].id
                                      .toString())
                              .then(
                            (_) {
                              cardPricestr = cardPriceApi
                                  .cardPriceData.first.cardPrice
                                  .toString();
                              showModalBottomSheet(
                                isScrollControlled: true,
                                showDragHandle: true,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                context: context,
                                builder: (context) {
                                  PurchaseApiProvider purchaseApiProvider =
                                      Get.put(PurchaseApiProvider());
                                  PurchaseMethodsController
                                      purchaseMethodsController = Get.put(
                                          PurchaseMethodsController(),
                                          tag: 'single');
                                  cardPriceApi.cardPriceData.first.cardType ==
                                          'charge'
                                      ? purchaseMethodsController
                                          .hasGlobalCard.value = true
                                      : false;
                                  return Container(
                                    padding: const EdgeInsets.all(20),
                                    width: double.infinity,
                                    alignment: Alignment.topCenter,
                                    height: Get.height * .87,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 160,
                                            clipBehavior: Clip.antiAlias,
                                            decoration:
                                                Constants.intesharBoxDecoration(
                                                    context),
                                            child: Center(
                                              child: CachedNetworkImage(
                                                fit: BoxFit.fill,
                                                height: 160,
                                                width: double.infinity,
                                                imageUrl: favorityController
                                                        .favoriteItems[index]
                                                        .photoUrl ??
                                                    '',
                                                placeholder: (context, url) =>
                                                    const CustomLoading(),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Image.asset(
                                                  'assets/images/not.jpg',
                                                  fit: BoxFit.fill,
                                                  height: 160,
                                                  width: double.infinity,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Gap(20),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: 'الشركة: ',
                                                          style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onPrimary,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text:
                                                              favorityController
                                                                  .favoriteItems[
                                                                      index]
                                                                  .title,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onPrimary,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Obx(() {
                                                    bool isFav = favorityController
                                                        .isFavorite(
                                                            favorityController
                                                                .favoriteItems[
                                                                    index]
                                                                .id!);
                                                    return ZoomTapAnimation(
                                                      onTap: () =>
                                                          favorityController
                                                              .toggleFavorite(
                                                        favorityController
                                                                .favoriteItems[
                                                            index],
                                                        context:
                                                            context, // ارسال context برای بستن مودال
                                                      ),
                                                      child: SvgPicture.asset(
                                                        isFav
                                                            ? 'assets/svgs/star_filled.svg'
                                                            : 'assets/svgs/star.svg',
                                                        width: 25,
                                                        height: 25,
                                                      ),
                                                    );
                                                  })
                                                ],
                                              ),
                                              const Gap(10),
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: 'الفئة: ',
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: favorityController
                                                          .favoriteItems[index]
                                                          .title,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Gap(10),
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: 'السعر: ',
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          '${formatNumber(int.parse(cardPricestr))} IQD',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Gap(10),
                                              Row(
                                                children: [
                                                  Text(
                                                    'العدد:',
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onPrimary,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  const Gap(10),
                                                  SizedBox(
                                                    width: 55,
                                                    height: 50,
                                                    child: TextField(
                                                      controller:
                                                          countController,
                                                      textDirection:
                                                          TextDirection.ltr,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter
                                                            .digitsOnly,
                                                        LengthLimitingTextInputFormatter(
                                                            2),
                                                      ],
                                                      decoration:
                                                          InputDecoration(
                                                        labelText: '',
                                                        border:
                                                            const OutlineInputBorder(),
                                                        filled: true,
                                                        fillColor:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .onPrimary
                                                                .withAlpha(30),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const Gap(20),
                                          const Align(
                                            alignment: Alignment.topRight,
                                            child: Text('الاجراء: '),
                                          ),
                                          const Gap(10),
                                          const PurchaseMethodsItem(
                                            scale: 70,
                                            tag: 'single',
                                          ),
                                          Obx(() {
                                            return (purchaseMethodsController
                                                        .purchaseMethodsSelected
                                                        .value !=
                                                    -1)
                                                ? Container(
                                                    margin:
                                                        const EdgeInsets.all(2),
                                                    child: Column(
                                                      children: [
                                                        SizedBox(
                                                          width:
                                                              double.infinity,
                                                          child: ElevatedButton(
                                                            style: ButtonStyle(
                                                              backgroundColor:
                                                                  WidgetStatePropertyAll(Theme.of(
                                                                          context)
                                                                      .extension<
                                                                          SuccessColorTheme>()
                                                                      ?.successColor),
                                                            ),
                                                            onPressed: () {
                                                              if (countController.text == '' || countController.text == '0') {
                                                                if (!Get.isSnackbarOpen) {
                                                                  Get.snackbar(
                                                                      'تنبيه',
                                                                      'يرجى تحديد العدد المطلوب');
                                                                }
                                                              } else {
                                                                purchaseApiProvider
                                                                    .fetchPurchase(
                                                                        counter:
                                                                            countController
                                                                                .text,
                                                                        type:
                                                                            'print',
                                                                        cardId: favorityController
                                                                            .favoriteItems[index]
                                                                            .id
                                                                            .toString())
                                                                    .then(
                                                                  (isSuccessful) {
                                                                    print(purchaseApiProvider
                                                                        .purchaseDataList
                                                                        .first
                                                                        .printDate);
                                                                    if (isSuccessful) {
                                                                      Navigator.pop(
                                                                          context);

                                                                      manageMethods(
                                                                        type: purchaseMethodsController
                                                                            .purchaseMethodsSelected
                                                                            .value,
                                                                        serials: purchaseApiProvider
                                                                            .purchaseDataList
                                                                            .first
                                                                            .serials,
                                                                        cardTitle:
                                                                            purchaseApiProvider.purchaseDataList.first.cardTitle ??
                                                                                '',
                                                                        photoUrl:
                                                                            purchaseApiProvider.purchaseDataList.first.cardCategory?.photoUrl ??
                                                                                '',
                                                                        ussdCodes:
                                                                            purchaseApiProvider.purchaseDataList.first.ussdCodes ??
                                                                                [],
                                                                        printDate: purchaseApiProvider
                                                                            .purchaseDataList
                                                                            .first
                                                                            .printDate
                                                                            .toString(),
                                                                        title: purchaseApiProvider.purchaseDataList.first.companyTitle ??
                                                                            '',
                                                                        footer:
                                                                            purchaseApiProvider.purchaseDataList.first.cardDetails2?.cardFooter ??
                                                                                '',
                                                                        isReported:
                                                                            false,
                                                                        cardId:
                                                                            purchaseApiProvider.purchaseDataList.first.cardCategory?.id?.toString() ??
                                                                                '',
                                                                      );
                                                                    }
                                                                  },
                                                                );
                                                              }
                                                            },
                                                            child: Obx(
                                                              () {
                                                                switch (purchaseApiProvider
                                                                    .rxRequestStatus
                                                                    .value) {
                                                                  case Status
                                                                        .completed:
                                                                    return const Text(
                                                                        'تأكيد');

                                                                  case Status
                                                                        .error:
                                                                    return Text(
                                                                      purchaseApiProvider
                                                                          .errorMessage
                                                                          .value,
                                                                      style:
                                                                          TextStyle(
                                                                        color: Theme.of(context)
                                                                            .colorScheme
                                                                            .error,
                                                                      ),
                                                                    );
                                                                  case Status
                                                                        .loading:
                                                                    return CustomLoading(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .onPrimary,
                                                                    );
                                                                  case Status
                                                                        .initial:
                                                                    return Text(
                                                                      'تأكيد',
                                                                      style:
                                                                          TextStyle(
                                                                        color: Theme.of(context)
                                                                            .extension<SuccessColorTheme>()
                                                                            ?.onSuccessColor,
                                                                      ),
                                                                    );
                                                                  default:
                                                                    return Text(
                                                                      'تأكيد',
                                                                      style:
                                                                          TextStyle(
                                                                        color: Theme.of(context)
                                                                            .extension<SuccessColorTheme>()
                                                                            ?.onSuccessColor,
                                                                      ),
                                                                    );
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : const SizedBox();
                                          }),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ).whenComplete(() {
                                countController.clear();
                                Get.delete<PurchaseApiProvider>();
                                Get.delete<PurchaseMethodsController>(
                                    tag: 'single');
                              });
                            },
                          );
                        },
                        child: Stack(
                          children: [
                            Container(
                              clipBehavior: Clip.antiAlias,
                              decoration:
                                  Constants.intesharBoxDecoration(context)
                                      .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                              child: Column(
                                children: [
                                  Container(
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                          color: Colors.black.withOpacity(.2),
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        )
                                      ],
                                      borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(30),
                                          bottomRight: Radius.circular(30)),
                                    ),
                                    child: CachedNetworkImage(
                                      fit: BoxFit.fill,
                                      height: 140,
                                      imageUrl: favorityController
                                              .favoriteItems[index].photoUrl ??
                                          '',
                                      placeholder: (context, url) =>
                                          const CustomLoading(),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                        'assets/images/not.jpg',
                                        fit: BoxFit.fill,
                                        height: 160,
                                        width: 160,
                                      ),
                                    ),
                                  ),
                                  const Gap(10),
                                  Text(
                                    favorityController
                                            .favoriteItems[index].title ??
                                        '',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                  ),
                                  const Gap(10),
                                ],
                              ),
                            ),
                            Obx(
                              () => Visibility(
                                visible: cardPriceApi.rxRequestStatus.value ==
                                        Status.loading
                                    ? true
                                    : false,
                                child: Container(
                                  width: double.infinity,
                                  height: 180,
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
                  ),
                ],
              )
            : const SizedBox.shrink();
      },
    );
  }
}
