import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/core/common/constants/share_app.dart';
import 'package:inteshar/app/core/common/widgets/internal_page.dart';
import 'package:inteshar/app/core/utils/custom_loading.dart';
import 'package:inteshar/app/features/purchase_methods/view/getX/print_controller.dart';
import 'package:inteshar/app/features/setting/view/getX/setting_controller.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    SettingController settingController = Get.find<SettingController>();
    BluetoothController bluetoothController = Get.put(BluetoothController());

    double containerWidth = MediaQuery.of(context).size.width - 60;
    double itemWidth = (containerWidth / 2) - 35;
    return InternalPage(
      title: 'الإعدادات',
      canBack: false,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 90),
        padding: const EdgeInsets.all(20),
        decoration: Constants.intesharBoxDecoration(context).copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Obx(
                () => Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      'assets/svgs/${(settingController.settings["darkMode"] ?? false) ? 'moon' : 'brightness'}.svg',
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.onSurface,
                        BlendMode.srcIn,
                      ),
                      width: 25,
                      height: 25,
                    ),
                    const Gap(10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          (settingController.settings["darkMode"] ?? false)
                              ? 'داکن'
                              : 'فاتح',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    Transform.scale(
                      scale: 0.7,
                      child: Switch(
                        value:
                            (settingController.settings["darkMode"] ?? false),
                        onChanged: (value) {
                          settingController.saveSetting("darkMode", value);
                          Get.changeThemeMode(
                            (settingController.settings["darkMode"] ?? false)
                                ? ThemeMode.dark
                                : ThemeMode.light,
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
              const Gap(10),
              const Divider(),
              const Gap(10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    'assets/svgs/print.svg',
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                    width: 25,
                    height: 25,
                  ),
                  const Gap(10),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        'الطباعة',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(10),
              Obx(
                () => Container(
                  width: containerWidth,
                  height: 50,
                  margin: EdgeInsets.all(20).copyWith(top: 5),
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).colorScheme.onPrimary),
                    borderRadius: BorderRadius.circular(10),
                    color:
                        Theme.of(context).colorScheme.onPrimary.withAlpha(100),
                  ),
                  child: Stack(
                    children: [
                      AnimatedPositioned(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        left:
                            (settingController.isPreviewEnabled.value ? 1 : 0) *
                                itemWidth,
                        top: 0,
                        child: Container(
                          width: itemWidth,
                          height: 40,
                          decoration:
                              Constants.intesharBoxDecoration(context).copyWith(
                            borderRadius: BorderRadius.circular(6),
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ZoomTapAnimation(
                              onTap: () {
                                settingController.setPreviewEnabled(true);
                              },
                              child: Center(
                                child: Text(
                                  'معاينة',
                                  style: TextStyle(
                                    color:
                                        settingController.isPreviewEnabled.value
                                            ? Colors.black
                                            : Colors.black38,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ZoomTapAnimation(
                              onTap: () {
                                settingController.setPreviewEnabled(false);
                              },
                              child: Center(
                                child: Text(
                                  'طباعة مباشرة',
                                  style: TextStyle(
                                    color:
                                        settingController.isPreviewEnabled.value
                                            ? Colors.black38
                                            : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Obx(() => CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/svgs/bullet.svg',
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.onPrimary,
                            BlendMode.srcIn,
                          ),
                          width: 18,
                          height: 18,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'اضافة رمز الاستجابة السريع (qr code)',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    value: settingController.settings[
                            settingController.getKey("printQrcode")] ??
                        false,
                    onChanged: (newValue) {
                      settingController.saveSetting(
                          settingController.getKey("printQrcode"), newValue!);
                    },
                  )),

              // Card image
              Obx(() => CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/svgs/bullet.svg',
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.onPrimary,
                            BlendMode.srcIn,
                          ),
                          width: 18,
                          height: 18,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'طباعة صورة الكارت',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    value: settingController.settings[
                            settingController.getKey("printCardImage")] ??
                        false,
                    onChanged: (newValue) {
                      settingController.saveSetting(
                          settingController.getKey("printCardImage"),
                          newValue!);
                    },
                  )),

              // Information
              Obx(() => CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/svgs/bullet.svg',
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.onPrimary,
                            BlendMode.srcIn,
                          ),
                          width: 18,
                          height: 18,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'طباعة معلومات واعلانات اسفل الفاتورة',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    value: settingController.settings[
                            settingController.getKey("printInformation")] ??
                        false,
                    onChanged: (newValue) {
                      settingController.saveSetting(
                          settingController.getKey("printInformation"),
                          newValue!);
                    },
                  )),

              // Barcode
              Obx(() => CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/svgs/bullet.svg',
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.onPrimary,
                            BlendMode.srcIn,
                          ),
                          width: 18,
                          height: 18,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'باركود الفئات',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    value: settingController.settings[
                            settingController.getKey("printBarCode")] ??
                        false,
                    onChanged: (newValue) {
                      settingController.saveSetting(
                          settingController.getKey("printBarCode"), newValue!);
                    },
                  )),
              const Gap(10),
              const Divider(),
              const Gap(10),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    'assets/svgs/bluetooth-alt.svg',
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                    width: 25,
                    height: 25,
                  ),
                  const Gap(10),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        'الاتصال بالطابعة',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(10),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) {
                      return Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'الأجهزة المتوفرة',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),

                            // List of Bluetooth devices
                            SizedBox(
                              height: 400, // افزایش ارتفاع از 300 به 400
                              child: Obx(() {
                                if (bluetoothController.devicesList.isEmpty) {
                                  return Center(
                                      child: Text('لم يتم العثور على أجهزة'));
                                }
                                return ListView.builder(
                                  itemCount:
                                      bluetoothController.devicesList.length,
                                  itemBuilder: (context, index) {
                                    final device =
                                        bluetoothController.devicesList[index];
                                    return Directionality(
                                      textDirection: TextDirection.ltr,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary
                                              .withAlpha(30),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
                                        child: ListTile(
                                          title: Text(device.name),
                                          subtitle: Text(
                                              device.macAddress.toString()),
                                          onTap: () {
                                            bluetoothController
                                                .deviceName.value = device.name;
                                            bluetoothController.connectToDevice(
                                              device.macAddress,
                                              device.name,
                                            );
                                            Navigator.pop(
                                                context); // close modal
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }),
                            ),

                            const SizedBox(height: 10),

                            // Button to scan for devices
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  bluetoothController
                                      .checkAndRequestBluetooth();
                                },
                                child: Obx(() {
                                  return bluetoothController.isLoading.value
                                      ? CustomLoading(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        )
                                      : const Text('البحث عن أجهزة');
                                }),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Obx(() {
                  // Show connected device name or fallback text
                  String buttonText =
                      bluetoothController.deviceName.value.isNotEmpty
                          ? 'متصل بـ ${bluetoothController.deviceName.value}'
                          : 'عرض الأجهزة';
                  return Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withAlpha(100),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(buttonText),
                        Icon(Icons.bluetooth),
                      ],
                    ),
                  );
                }),
              ),

              const Gap(10),
              const Divider(),
              const Gap(10),
              ZoomTapAnimation(
                onTap: () => shareApp(context),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      'assets/svgs/share-square.svg',
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.onSurface,
                        BlendMode.srcIn,
                      ),
                      width: 25,
                      height: 25,
                    ),
                    const Gap(10),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          'مشاركة التطبيق',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    SvgPicture.asset(
                      'assets/svgs/angle-left.svg',
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.onSurface,
                        BlendMode.srcIn,
                      ),
                      width: 15,
                      height: 15,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
