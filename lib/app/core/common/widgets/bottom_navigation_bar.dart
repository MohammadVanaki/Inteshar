import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/features/page_view/view/getX/navigation_controller.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class CostumBottomNavigationBar extends StatelessWidget {
  CostumBottomNavigationBar({
    super.key,
  });

  final BottmNavigationController navigationController =
      Get.put(BottmNavigationController(), permanent: true);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      height: 70,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 1,
            offset: Offset(0, -1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _bottomAppBarItem(
              icon: 'house', page: 0, context: context, title: 'الرئيسية'),
          _bottomAppBarItem(
              icon: 'info', page: 1, context: context, title: 'حول التطبيق'),
          _bottomAppBarItem(
              icon: 'settings', page: 2, context: context, title: 'الإعدادات'),
          _bottomAppBarItem(
              icon: 'stats', page: 3, context: context, title: 'تقارير'),
        ],
      ),
    );
  }

  Widget _bottomAppBarItem({
    required String icon,
    required String title,
    required int page,
    required BuildContext context,
  }) {
    return ZoomTapAnimation(
      onTap: () {
        navigationController.goToPage(page);
      },
      child: Obx(
        () => Container(
          decoration: BoxDecoration(
            gradient: navigationController.currentPage.value == page
                ? LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.surface.withAlpha(50)
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : const LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.transparent
                    ],
                  ),
          ),
          width: 70,
          height: 70,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/svgs/$icon.svg',
                colorFilter: ColorFilter.mode(
                  navigationController.currentPage.value == page
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.onSurface,
                  BlendMode.srcIn,
                ),
              ),
              const Gap(5),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: navigationController.currentPage.value == page
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onPrimary.withAlpha(60),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
