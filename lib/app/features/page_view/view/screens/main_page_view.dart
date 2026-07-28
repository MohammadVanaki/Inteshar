import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/core/common/widgets/bottom_navigation_bar.dart';
import 'package:inteshar/app/features/text_content/view/screen/about_page.dart';
import 'package:inteshar/app/features/home/view/screens/home_page.dart';
import 'package:inteshar/app/features/page_view/view/getX/navigation_controller.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:inteshar/app/features/page_view/view/getX/scaffold_controller.dart';
import 'package:inteshar/app/core/common/widgets/custom_drawer.dart';
import 'package:inteshar/app/features/reporting/view/screens/reporting_page.dart';
import 'package:inteshar/app/features/setting/view/screens/setting_page.dart';

class MainPageView extends GetView<ScaffoldController> {
  const MainPageView({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    //navigation controller
    final BottmNavigationController navigationController =
        Get.put(BottmNavigationController(), permanent: true);
    // final ScaffoldController scaffoldController = Get.put(ScaffoldController());

    return Stack(
      children: [
        Scaffold(
          body: SliderDrawer(
            key: controller.sliderDrawerKey,
            isDraggable: true,
            sliderBoxShadow: SliderBoxShadow(
              color: Theme.of(context).colorScheme.surface.withAlpha(100),
            ),

            appBar: SizedBox(),
            // appBar: AppBar(
            //   elevation: 0,
            //   backgroundColor: Theme.of(context).colorScheme.primary,
            //   leading: IconButton(
            //     icon: SvgPicture.asset(
            //       'assets/svgs/bars-staggered.svg',
            //       colorFilter: ColorFilter.mode(
            //         Theme.of(context).colorScheme.onPrimary,
            //         BlendMode.srcIn,
            //       ),
            //     ),
            //     onPressed: () {
            //       if (controller.drawerOpen.value) {
            //         controller.closeDrawer();
            //       } else {
            //         controller.openDrawer();
            //       }
            //     },
            //     tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            //   ),
            //   actions: [
            //     Padding(
            //       padding: const EdgeInsets.only(left: 20),
            //       child: ZoomTapAnimation(
            //         onTap: () {
            //           Get.toNamed(Routes.notifArchive);
            //         },
            //         child: SvgPicture.asset(
            //           'assets/svgs/bell.svg',
            //           colorFilter: ColorFilter.mode(
            //             Theme.of(context).colorScheme.onPrimary,
            //             BlendMode.srcIn,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            slideDirection: SlideDirection.rightToLeft,
            sliderOpenSize: 260,
            slider: CustomDrawer(
              sliderDrawerKey: controller.sliderDrawerKey,
            ),
            child: Container(
              color: Theme.of(context).colorScheme.primary,
              width: Get.width,
              height: Get.height,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PageView(
                    controller: navigationController.pageController,
                    onPageChanged: navigationController.animatedToPage,
                    // physics: const BouncingScrollPhysics(),
                    children: [
                      HomePage(
                        scaffoldController: controller,
                      ),
                      const AboutPage(),
                      const SettingPage(),
                      const ReportingPage(),
                    ],
                  ),
                  Positioned(
                    bottom: 0,
                    child: GestureDetector(
                      onHorizontalDragUpdate: (_) {},
                      child: CostumBottomNavigationBar(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Obx(
          () => Visibility(
            visible: controller.drawerOpen.value,
            child: Positioned(
              left: 0,
              child: GestureDetector(
                onTap: () {
                  controller.closeDrawer();
                },
                child: Container(
                  color: Colors.transparent,
                  width: Get.width - 260,
                  height: Get.height,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
