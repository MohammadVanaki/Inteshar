import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/core/routes/routes.dart';
import 'package:inteshar/app/core/utils/custom_loading.dart';
import 'package:inteshar/app/features/home/view/getX/check_update.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool hasSeenOnboarding =
        Constants.localStorage.read('hasSeenOnboarding') ?? false;
    Future.delayed(
      const Duration(seconds: 3),
      () {
        final UpdateController updateController = Get.put(UpdateController());
        updateController.checkUpdate(Get.context!);
        hasSeenOnboarding
            ? Get.offAllNamed(Routes.home)
            : Get.offAllNamed(Routes.intro);
      },
    );
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.primary, BlendMode.color),
            child: Image.asset(
              width: size.width,
              height: size.height,
              'assets/images/splash-bg.jpg',
              fit: BoxFit.fill,
            ),
          ),
          Image.asset(
            'assets/images/logo-1.png',
            fit: BoxFit.fill,
          ),
          Positioned(
            bottom: 40,
            child: Column(
              children: [
                const CustomLoading(),
                const Gap(15),
                Text(
                  'يرجى الانتظار...',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
