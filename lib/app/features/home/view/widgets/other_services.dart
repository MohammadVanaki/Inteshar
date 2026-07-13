import 'package:auto_height_grid_view/auto_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/core/routes/routes.dart';
import 'package:inteshar/app/features/register_web/view/getx/register_controller.dart';
import 'package:inteshar/app/features/register_web/view/screens/register_view.dart';
import 'package:inteshar/app/features/services/view/screens/invoice_page.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class OtherServices extends StatelessWidget {
  const OtherServices({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> otherServicesList = [
      {
        "title": 'TopUp',
        "icon": 'point-of-sale-bill',
        "onTap": () {
          Get.toNamed(Routes.invoicePage,
              arguments: const InvoicePage(type: 'topup', title: 'TOPUP'));
        },
      },
      // {
      //   "title": 'الوطني',
      //   "icon": 'alwatani',
      //   "onTap": () {
      //     Get.defaultDialog(
      //       title: 'تنبيه',
      //       middleText: 'بوابة الوطني متوقفة مؤقتاً وستكون متاحة قريباً.',
      //       textConfirm: 'حسناً',
      //       onConfirm: Get.back,
      //     );
      //   },
      // },
      {
        "title": 'باقات',
        "icon": 'box-open',
        "onTap": () {
          Get.toNamed(Routes.internetPackagesPage);
        },
      },
    ];
    return AutoHeightGridView(
      itemCount: otherServicesList.length,
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      shrinkWrap: true,
      builder: (context, index) {
        return ZoomTapAnimation(
          onTap: otherServicesList[index]['onTap'],
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(40),
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            height: 100,
            child: Column(
              children: [
                Expanded(
                  child: SvgPicture.asset(
                    'assets/svgs/${otherServicesList[index]['icon']}.svg',
                    width: 37,
                    height: 37,
                  ),
                ),
                Text(
                  otherServicesList[index]['title'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
