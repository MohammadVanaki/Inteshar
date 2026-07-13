import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/features/purchase_methods/view/getX/print_controller.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class InternalPage extends StatelessWidget {
  const InternalPage({
    super.key,
    required this.child,
    required this.title,
    this.canBack,
    this.disconnect = false,
  });
  final Widget child;
  final String title;
  final bool? canBack;
  final bool disconnect;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.primary,
        width: Get.width,
        height: Get.height,
        child: Stack(
          children: [
            //Background
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('assets/images/cr-main.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.primary,
                    BlendMode.modulate,
                  ),
                ),
              ),
              height: 190,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 45),
              alignment: Alignment.topCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  disconnect
                      ? ZoomTapAnimation(
                          onTap: () {
                            final BluetoothController bluetoothController =
                                Get.find<BluetoothController>();
                            bluetoothController.disconnectDevice();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            color: Colors.transparent,
                            child: SvgPicture.asset(
                              'assets/svgs/signal-stream-slash.svg',
                              colorFilter: ColorFilter.mode(
                                Theme.of(context).colorScheme.onPrimary,
                                BlendMode.srcIn,
                              ),
                              width: 20,
                              height: 20,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                  const Gap(20),
                  canBack ?? true
                      ? ZoomTapAnimation(
                          onTap: () {
                            Get.back();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(
                                14), // افزایش محدوده لمس به حداقل ۴۸ پیکسل
                            color: Colors.transparent,
                            child: SvgPicture.asset(
                              'assets/svgs/angle-left.svg',
                              colorFilter: ColorFilter.mode(
                                Theme.of(context).colorScheme.onPrimary,
                                BlendMode.srcIn,
                              ),
                              width: 20,
                              height: 20,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 100),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
