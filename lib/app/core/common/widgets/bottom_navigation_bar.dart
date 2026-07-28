import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      // width: Get.width - 60,
      // height: 70,
      padding: EdgeInsets.all(3),
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEEF2F6),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _bottomAppBarItem(
              icon: 'house',
              page: 0,
              context: context,
            ),
            const SizedBox(width: 3),
            _bottomAppBarItem(
              icon: 'info',
              page: 1,
              context: context,
            ),
            const SizedBox(width: 3),
            _bottomAppBarItem(
              icon: 'settings',
              page: 2,
              context: context,
            ),
            const SizedBox(width: 3),
            _bottomAppBarItem(
              icon: 'stats',
              page: 3,
              context: context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomAppBarItem({
    required String icon,
    required int page,
    required BuildContext context,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(
      () {
        final isSelected = navigationController.currentPage.value == page;

        // Background color of the circular button
        final Color buttonBgColor = isSelected
            ? Theme.of(context).colorScheme.secondary // Golden/Yellow
            : (isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE4E9EE));

        // Icon color based on selection
        final Color iconColor = isSelected
            ? Colors.black87
            : (isDark ? Colors.white70 : const Color(0xFF5C6B73));

        return ZoomTapAnimation(
          onTap: () {
            navigationController.goToPage(page);
          },
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: buttonBgColor,
              shape: BoxShape.circle,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : null,
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/svgs/$icon.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  iconColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
