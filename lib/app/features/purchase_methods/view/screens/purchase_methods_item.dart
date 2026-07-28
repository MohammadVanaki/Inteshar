import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/features/home/view/getX/purchase_methods_controller.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class PurchaseMethodsItem extends StatelessWidget {
  const PurchaseMethodsItem({
    super.key,
    required this.scale,
    required this.tag,
  });

  final double scale;
  final String tag;

  @override
  Widget build(BuildContext context) {
    final PurchaseMethodsController purchaseMethodsController =
        Get.put(PurchaseMethodsController(), tag: tag);

    return Column(
      children: [
        SizedBox(
          height: scale,
          width: double.infinity,
          child: Center(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: purchaseMethodsController.purchaseMethodsList.length,
              itemBuilder: (context, index) {
                return ZoomTapAnimation(
                  onTap: () {
                    if (Constants.isLoggedIn) {
                      purchaseMethodsController.selectMethod(index: index);
                    } else {
                      Get.snackbar(
                        'تنبيه',
                        'لاتمام عملية الشراء يرجى تسجيل الدخول',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red.withOpacity(0.8),
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(16),
                        duration: const Duration(seconds: 3),
                      );
                    }
                  },
                  child: Tooltip(
                    message: purchaseMethodsController
                        .purchaseMethodsList[index]['message'],
                    child: Obx(
                      () => Container(
                        width: scale,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        padding: const EdgeInsets.all(8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: index ==
                                    purchaseMethodsController
                                        .purchaseMethodsSelected.value
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).colorScheme.surface,
                          ),
                          color: purchaseMethodsController
                                      .purchaseMethodsSelected.value ==
                                  index
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/svgs/${purchaseMethodsController.purchaseMethodsList[index]['icon']}.svg',
                              colorFilter: ColorFilter.mode(
                                purchaseMethodsController
                                            .purchaseMethodsSelected.value ==
                                        index
                                    ? Colors.black
                                    : Theme.of(context).colorScheme.onPrimary,
                                BlendMode.srcIn,
                              ),
                              width: scale - 40,
                              height: scale - 40,
                            ),
                            const Gap(6),
                            Text(
                              purchaseMethodsController
                                  .purchaseMethodsList[index]['message'],
                              style: TextStyle(
                                fontSize: 10,
                                color: purchaseMethodsController
                                            .purchaseMethodsSelected.value ==
                                        index
                                    ? Colors.black
                                    : Theme.of(context).colorScheme.onPrimary,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // const Gap(10),
      ],
    );
  }
}
