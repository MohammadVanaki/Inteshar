import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/config/functions.dart';
import 'package:inteshar/app/core/common/widgets/internal_page.dart';
import 'package:inteshar/app/core/common/widgets/offline_widget.dart';
import 'package:inteshar/app/core/utils/custom_loading.dart';
import 'package:inteshar/app/features/services/view/getX/internet_packages_controller.dart';
import 'package:inteshar/app/features/services/view/widgets/internet_modal_confirm.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class InternetPackagesPage extends StatelessWidget {
  const InternetPackagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    InternetPackagesController? internetPackagesController;

    if (Constants.isLoggedIn) {
      internetPackagesController = Get.put(InternetPackagesController());
    }

    return Scaffold(
      body: InternalPage(
        title: 'باقات',
        child: Container(
          width: double.infinity,
          margin:
              const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 20),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: Constants.intesharBoxDecoration(context)
              .copyWith(color: Theme.of(context).colorScheme.primary),
          child: Constants.isLoggedIn
              ? Column(
                  children: [
                    Container(
                      height: 35,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ListView.builder(
                        itemCount:
                            internetPackagesController!.companyList.length,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(bottom: 2),
                        itemBuilder: (context, index) {
                          return ZoomTapAnimation(
                            onTap: () {
                              internetPackagesController!.listOfPackage(
                                  internetPackagesController.companyList[index]
                                      ['id']);
                              internetPackagesController.companySelected.value =
                                  index;
                            },
                            child: Obx(
                              () => Container(
                                margin: const EdgeInsets.only(left: 10),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration:
                                    Constants.intesharBoxDecoration(context)
                                        .copyWith(
                                  color: internetPackagesController
                                              ?.companySelected.value !=
                                          index
                                      ? Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withAlpha(40)
                                      : Theme.of(context).colorScheme.secondary,
                                  boxShadow: [],
                                  border: Border.all(
                                    color: internetPackagesController
                                                ?.companySelected.value !=
                                            index
                                        ? Theme.of(context).colorScheme.surface
                                        : Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    internetPackagesController!
                                        .companyList[index]['title'],
                                    style: TextStyle(
                                      color: internetPackagesController
                                                  .companySelected.value !=
                                              index
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onPrimary
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Gap(20),
                    Obx(
                      () => internetPackagesController!.packageList.isNotEmpty
                          ? Container(
                              height: 140,
                              padding: const EdgeInsets.all(10),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimary
                                      .withAlpha(30)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'باقات مقترحة',
                                    textAlign: TextAlign.start,
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  const Gap(10),
                                  SizedBox(
                                    height: 90,
                                    child: ListView.builder(
                                      itemCount: internetPackagesController!
                                                  .packageList.length <
                                              3
                                          ? internetPackagesController!
                                              .packageList.length
                                          : 3,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) {
                                        return ZoomTapAnimation(
                                          onTap: () {
                                            final agentPrice =
                                                internetPackagesController!
                                                                .packageList[
                                                            index]['agent_price']
                                                        ?['price'] ??
                                                    0;
                                            final packagePrice =
                                                internetPackagesController!
                                                        .packageList[index]
                                                    ['price'];
                                            internetModalConfirm(
                                              context: context,
                                              price:
                                                  '${formatNumber(agentPrice != 0 ? agentPrice : packagePrice)} IQD',
                                              category:
                                                  internetPackagesController!
                                                          .packageList[index]
                                                      ['title'],
                                              classification:
                                                  internetPackagesController!
                                                          .companyList[
                                                      internetPackagesController!
                                                          .companySelected
                                                          .value]['title'],
                                              categoryId:
                                                  internetPackagesController!
                                                      .packageList[index]['id']
                                                      .toString(),
                                              type: 'bundle',
                                            );
                                          },
                                          child: Container(
                                            width: 150,
                                            margin: const EdgeInsets.only(
                                                left: 10, bottom: 2),
                                            padding: const EdgeInsets.all(10),
                                            decoration:
                                                Constants.intesharBoxDecoration(
                                                        context)
                                                    .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              border: Border(
                                                right: BorderSide(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                      .withAlpha(50),
                                                  width: 8,
                                                ),
                                              ),
                                            ),
                                            child: Obx(() => Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      internetPackagesController!
                                                              .packageList[
                                                          index]['title'],
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${formatNumber(internetPackagesController!.packageList[index]['price'])} IQD',
                                                      style: const TextStyle(
                                                          fontSize: 13),
                                                      textDirection:
                                                          TextDirection.ltr,
                                                    ),
                                                  ],
                                                )),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    const Gap(15),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Text(
                          'الباقات',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const Gap(5),
                    Expanded(
                      child: Obx(() => internetPackagesController!
                              .packageList.isEmpty
                          ? const Center(
                              child: Text(
                                'لا توجد باقات متاحة حالياً',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: internetPackagesController!
                                  .packageList.length,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              scrollDirection: Axis.vertical,
                              itemBuilder: (context, index) {
                                return ZoomTapAnimation(
                                  onTap: () {
                                    final agentPrice =
                                        internetPackagesController!
                                                    .packageList[index]
                                                ['agent_price']?['price'] ??
                                            0;
                                    final packagePrice =
                                        internetPackagesController
                                            .packageList[index]['price'];
                                    internetModalConfirm(
                                      context: context,
                                      price:
                                          '${formatNumber(agentPrice != 0 ? agentPrice : packagePrice)} IQD',
                                      category: internetPackagesController
                                          .packageList[index]['title'],
                                      classification: internetPackagesController
                                              .companyList[
                                          internetPackagesController
                                              .companySelected.value]['title'],
                                      categoryId: internetPackagesController
                                          .packageList[index]['id']
                                          .toString(),
                                      type: 'bundle',
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    decoration:
                                        Constants.intesharBoxDecoration(context)
                                            .copyWith(
                                                boxShadow: [],
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary
                                                    .withAlpha(30)),
                                    child: Row(
                                      children: [
                                        Container(
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(
                                            boxShadow: <BoxShadow>[
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(.2),
                                                blurRadius: 5,
                                                offset: const Offset(0, 2),
                                              )
                                            ],
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(5),
                                              topRight: Radius.circular(5),
                                              bottomLeft: Radius.circular(20),
                                              bottomRight: Radius.circular(20),
                                            ),
                                          ),
                                          child: CachedNetworkImage(
                                            fit: BoxFit.fill,
                                            height: 90,
                                            width: 110,
                                            imageUrl:
                                                internetPackagesController!
                                                        .packageList[index]
                                                    ['photo_url'],
                                            placeholder: (context, url) =>
                                                const CustomLoading(),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Image.asset(
                                              'assets/images/asiacell-df.jpg',
                                              fit: BoxFit.fill,
                                              height: 90,
                                              width: 110,
                                            ),
                                          ),
                                        ),
                                        const Gap(20),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                internetPackagesController
                                                        .packageList[index]
                                                    ['title'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 17,
                                                  letterSpacing: 1.1,
                                                ),
                                              ),
                                              const Gap(6),
                                              Text(
                                                '${formatNumber(internetPackagesController.packageList[index]['price'])} IQD',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                                textDirection:
                                                    TextDirection.ltr,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Gap(5),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 3),
                                          child: SvgPicture.asset(
                                            'assets/svgs/angle-left.svg',
                                            colorFilter: ColorFilter.mode(
                                              Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                              BlendMode.srcIn,
                                            ),
                                            width: 12,
                                            height: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )),
                    ),
                    const Gap(10),
                  ],
                )
              : const OfflineWidget(),
        ),
      ),
    );
  }
}
