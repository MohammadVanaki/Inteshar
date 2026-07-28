import 'package:auto_height_grid_view/auto_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/config/functions.dart';
import 'package:inteshar/app/core/common/widgets/internal_page.dart';
import 'package:inteshar/app/core/common/widgets/offline_widget.dart';
import 'package:inteshar/app/features/home/data/data_source/home_api_provider.dart';
import 'package:inteshar/app/features/services/view/getX/invoice_controller.dart';
import 'package:inteshar/app/features/services/view/widgets/invoice_modal_confirm.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:inteshar/app/features/home/data/models/home_model.dart';

class InvoicePage extends StatelessWidget {
  const InvoicePage({
    super.key,
    required this.type,
    required this.title,
  });
  final String type;
  final String title;
  @override
  Widget build(BuildContext context) {
    InvoiceController invoiceController = Get.put(InvoiceController());
    final homeApiProvider = Get.find<HomeApiProvider>();
    final List<AsiacellCategory> shortcutList = (homeApiProvider
                .homeDataList.firstOrNull?.asiacellCategories ??
            [])
        .where((category) => category.type == Type.TOPUP)
        .toList();

    shortcutList.sort((a, b) => (a.idShow ?? 0).compareTo(b.idShow ?? 0));

    final formKey = GlobalKey<FormState>();
    return InternalPage(
      title: title,
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          height: 650,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: Constants.intesharBoxDecoration(context)
              .copyWith(color: Theme.of(context).colorScheme.primary),
          child: Constants.isLoggedIn
              ? (shortcutList.isEmpty
                  ? const Center(
                      child: Text(
                        'لا توجد فئات متاحة حالياً',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                    const Gap(20),
                    const Text(
                      'للشراء من الفئة المطلوبة',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    const Gap(5),
                    const Text(
                      'يرجى ادخال رقم الهاتف وتحديد أو اختيار المبلغ المطلوب',
                      style: TextStyle(fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(60),
                    Form(
                      key: formKey,
                      child: TextFormField(
                        textDirection: TextDirection.ltr,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return null;
                          }
                          if (value.length < 10 || value.length > 10) {
                            return 'رقم الجوال غير صالح';
                          }
                          return null;
                        },
                        controller: invoiceController.phoneController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          suffixText: '00964',
                          suffixStyle: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimary
                                  .withAlpha(200)),
                          border: const OutlineInputBorder(),
                          label: const Text(
                            'رقم الهاتف',
                          ),
                          labelStyle: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withOpacity(0.7),
                          ),
                          floatingLabelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const Gap(30),
                    AutoHeightGridView(
                      itemCount: shortcutList.length < 3 ? shortcutList.length : 3,
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      shrinkWrap: true,
                      builder: (context, index) {
                        return ZoomTapAnimation(
                          onTap: () {
                            int position = shortcutList.indexWhere(
                                (item) => item.id == shortcutList[index].id);
                            invoiceController.goToItem(position);
                          },
                          child: Obx(
                            () => Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              decoration:
                                  Constants.intesharBoxDecoration(context)
                                      .copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                border: Border(
                                  right: BorderSide(
                                    color: invoiceController.selected.value ==
                                            index
                                        ? Theme.of(context)
                                            .colorScheme
                                            .secondary
                                        : Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withAlpha(100),
                                    width: 8,
                                  ),
                                ),
                              ),
                              height: 60,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    formatNumber(shortcutList[index].price) ??
                                        '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: invoiceController.selected.value ==
                                              index
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onPrimary
                                          : Theme.of(context)
                                              .colorScheme
                                              .onPrimary
                                              .withAlpha(80),
                                    ),
                                  ),
                                  Text(
                                    'IQD',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: invoiceController.selected.value ==
                                              index
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onPrimary
                                          : Theme.of(context)
                                              .colorScheme
                                              .onPrimary
                                              .withAlpha(80),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const Gap(30),
                    const Text(
                      'المبلغ بالدينار',
                      style: TextStyle(
                        fontSize: 10,
                      ),
                    ),
                    Row(
                      children: [
                        ZoomTapAnimation(
                          onTap: () {
                            if (invoiceController.selected.value > 0) {
                              invoiceController.selected.value--;
                              invoiceController.animatedToItem(
                                  invoiceController.selected.value);
                            }
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimary
                                      .withAlpha(60)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/svgs/angle-right.svg',
                                colorFilter: ColorFilter.mode(
                                  Theme.of(context)
                                      .colorScheme
                                      .onPrimary
                                      .withAlpha(60),
                                  BlendMode.srcIn,
                                ),
                                width: 18,
                                height: 18,
                              ),
                            ),
                          ),
                        ),
                        const Gap(10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 2, vertical: 4),
                            child: Center(
                              child: SizedBox(
                                height: 70,
                                child: RotatedBox(
                                  quarterTurns: 1,
                                  child: ListWheelScrollView.useDelegate(
                                    controller: invoiceController
                                        .fixedExtentScrollController,
                                    physics: const FixedExtentScrollPhysics(),
                                    itemExtent: 90,
                                    diameterRatio: 2.0,
                                    perspective: 0.003,
                                    onSelectedItemChanged: (index) {
                                      invoiceController.selected.value = index;
                                    },
                                    childDelegate:
                                        ListWheelChildBuilderDelegate(
                                      builder: (context, index) {
                                        return Obx(
                                          () => RotatedBox(
                                            quarterTurns: 3,
                                            child: Container(
                                              width: 70,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: index ==
                                                        invoiceController
                                                            .selected.value
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .secondary
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary
                                                        .withAlpha(30),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                formatNumber(shortcutList[index]
                                                        .price) ??
                                                    '',
                                                style: TextStyle(
                                                  fontSize: index ==
                                                          invoiceController
                                                              .selected.value
                                                      ? 24
                                                      : 20,
                                                  fontWeight: index ==
                                                          invoiceController
                                                              .selected.value
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                  color: index ==
                                                          invoiceController
                                                              .selected.value
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .onPrimary
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .onPrimary
                                                          .withAlpha(200),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      childCount: shortcutList.length,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Gap(10),
                        ZoomTapAnimation(
                          onTap: () {
                            if (invoiceController.selected.value <
                                shortcutList.length - 1) {
                              invoiceController.selected.value++;
                              invoiceController.animatedToItem(
                                  invoiceController.selected.value);
                            }
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimary
                                      .withAlpha(60)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/svgs/angle-left.svg',
                                colorFilter: ColorFilter.mode(
                                  Theme.of(context)
                                      .colorScheme
                                      .onPrimary
                                      .withAlpha(60),
                                  BlendMode.srcIn,
                                ),
                                width: 18,
                                height: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(10),
                    const Text(
                      'بامكانك الشراء في كل مرة من 1000 الى 100.000 دينار',
                      style: TextStyle(fontSize: 10),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final agentPrice =
                              shortcutList[invoiceController.selected.value]
                                      .price ??
                                  0;

                          0;
                          final packagePrice =
                              shortcutList[invoiceController.selected.value]
                                  .price;
                          if (formKey.currentState!.validate() &&
                              invoiceController
                                  .phoneController.text.isNotEmpty) {
                            // FocusScope.of(context).unfocus();

                            invoiceModalConfirm(
                              context: context,
                              phone: invoiceController.phoneController.text,
                              category:
                                  '${formatNumber(agentPrice != 0 ? agentPrice : packagePrice)} IQD',
                              price:
                                  shortcutList[invoiceController.selected.value]
                                      .price
                                      .toString(),
                              categoryId:
                                  shortcutList[invoiceController.selected.value]
                                      .id
                                      .toString(),
                              type: type,
                            );
                            invoiceController.phoneController.clear();
                          }
                        },
                        child: const Text('التالي'),
                      ),
                    )
                  ],
                ))
              : const OfflineWidget(),
        ),
      ),
    );
  }
}
