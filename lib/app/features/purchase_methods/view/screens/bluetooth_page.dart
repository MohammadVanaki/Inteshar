import 'dart:convert';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/features/home/data/data_source/home_api_provider.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:screenshot/screenshot.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:image/image.dart' as img;
import 'package:inteshar/app/config/status.dart';
import 'package:inteshar/app/core/common/widgets/internal_page.dart';
import 'package:inteshar/app/core/utils/custom_loading.dart';
import 'package:inteshar/app/features/purchase_methods/view/getX/print_controller.dart';
import 'package:inteshar/app/features/purchase_methods/view/widgets/build_print_widget.dart';
import 'package:inteshar/app/features/setting/view/getX/setting_controller.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class BluetoothPage extends StatelessWidget {
  BluetoothPage({
    super.key,
    required this.serialList,
    required this.ussdCodes,
    required this.photoUrl,
    required this.printDate,
    required this.cardTitle,
    required this.footer,
    required this.isReported,
    required this.cardId,
  });
  final List serialList;
  final List ussdCodes;
  final String photoUrl;
  final String printDate;
  final String cardTitle;
  final String footer;
  final bool isReported;
  final String cardId;
  // final GlobalKey _globalKey = GlobalKey();
  final BluetoothController bluetoothController =
      Get.find<BluetoothController>();
  @override
  Widget build(BuildContext context) {
    print('printDate=======>$printDate');
    bluetoothController.printed.value = false;
    bluetoothController.printCount.value = 0;
    SettingController settingController = Get.put(SettingController());
    final updateController = Get.find<HomeApiProvider>();

    List<ScreenshotController> cardPhotoScreenshotControllers =
        List.generate(serialList.length, (_) => ScreenshotController());

    List<ScreenshotController> headerScreenshotControllers =
        List.generate(serialList.length, (_) => ScreenshotController());

    List<ScreenshotController> qrcodeScreenshotControllers =
        List.generate(serialList.length, (_) => ScreenshotController());

    List<ScreenshotController> footerScreenshotControllers =
        List.generate(serialList.length, (_) => ScreenshotController());
    List<ScreenshotController> pinCodeScreenshotControllers =
        List.generate(serialList.length, (_) => ScreenshotController());
    List<ScreenshotController> barCodeScreenshotControllers =
        List.generate(serialList.length, (_) => ScreenshotController());

    // final savedPrinter = Constants.localStorage.read('printAddres');
    // if (savedPrinter != null) {
    //   print('macAddress ====> ${savedPrinter['macAddress']}');
    //   print('advName macAddress ====> ${savedPrinter['name']}');
    //   bluetoothController.connectToDevice(
    //     savedPrinter['macAddress'],
    //     savedPrinter['name'],
    //   );

    // }
// تابع کمکی گرفتن عکس با چند بار تلاش
    Future<Uint8List> waitUntilCaptured(
      ScreenshotController controller, {
      int retries = 15,
      Duration delay = const Duration(milliseconds: 300),
    }) async {
      for (int i = 0; i < retries; i++) {
        await Future.delayed(delay);
        await WidgetsBinding.instance.endOfFrame;

        try {
          final bytes =
              await controller.capture(pixelRatio: 2.0); // for better quality
          if (bytes != null && bytes.isNotEmpty) {
            debugPrint("✅ عکس گرفته شد در تلاش $i");
            return bytes;
          } else {
            debugPrint("⏳ تلاش $i: عکس null یا خالی بود");
          }
        } catch (e) {
          debugPrint("❌ خطا در تلاش $i برای capture: $e");
        }
      }

      debugPrint("⚠️ بعد از $retries تلاش، capture موفق نبود");
      throw Exception("عکس‌برداری ناموفق بود بعد از $retries تلاش");
    }

    Future<void> captureAndSavePng() async {
      bluetoothController.printCount.value++;
      final user = updateController.homeDataList.first;

      for (final serial in serialList) {
        final int index = serialList.indexOf(serial);

        debugPrint("🔍 شروع چاپ برای index: $index");

        // گرفتن عکس Header (اجباری)
        final headerImageBytes =
            await waitUntilCaptured(headerScreenshotControllers[index]);
        if (headerImageBytes == null) {
          debugPrint("⚠️ header null شد. چاپ انجام نشد برای index $index");
          continue;
        }
        final headerBytes = await processImageForPrinter(headerImageBytes);

        // کارت
        List<int>? cardPhotoBytes;
        if (settingController.settings["printCardImage"] ?? false) {
          final img =
              await waitUntilCaptured(cardPhotoScreenshotControllers[index]);
          if (img != null) {
            cardPhotoBytes = await processImageForPrinter(img);
          } else {
            debugPrint("❗ کارت image null بود برای index $index");
          }
        }

        // QR Code
        List<int>? qrCodeBytes;
        if (settingController.settings["printQrcode"] ?? false) {
          final img =
              await waitUntilCaptured(qrcodeScreenshotControllers[index]);
          if (img != null) {
            qrCodeBytes = await processImageForPrinter(img);
          } else {
            debugPrint("❗ QR Code null بود برای index $index");
          }
        }

        // Footer
        List<int>? footerBytes;
        if (settingController.settings["printInformation"] ?? false) {
          final img =
              await waitUntilCaptured(footerScreenshotControllers[index]);
          if (img != null) {
            footerBytes = await processImageForPrinter(img);
          } else {
            debugPrint("❗ Footer null بود برای index $index");
          }
        }

        // بارکد
        List<int>? barCodeBytes;
        if (settingController.settings["printBarCode"] ?? false) {
          final img =
              await waitUntilCaptured(barCodeScreenshotControllers[index]);
          if (img != null) {
            barCodeBytes = await processImageForPrinter(img);
          } else {
            debugPrint("❗ Barcode null بود برای index $index");
          }
        }

        // پین‌کد (اجباری)
        final pinImg =
            await waitUntilCaptured(pinCodeScreenshotControllers[index]);
        if (pinImg == null) {
          debugPrint("⚠️ پین‌کد null شد. چاپ انجام نشد برای index $index");
          continue;
        }
        final pinCodeBytes = await processImageForPrinter(pinImg);

        // تابع چاپ متن
        void printText(String text, {bool bold = false, int? size}) {
          PrintBluetoothThermal.writeString(
            printText: PrintTextSize(
              size: size ?? 8,
              text: bold ? "\x1B\x45\x01$text\x1B\x45\x00" : text,
            ),
          );
        }

        // شروع چاپ
        debugPrint("🖨️ شروع ارسال به پرینتر برای index $index");
        bluetoothController.printed.value = true;
        if (headerBytes != null) {
          PrintBluetoothThermal.writeBytes(headerBytes);
        }
        printText(isReported ? '--------- 2 ---------\n' : '');
        printText('Terminal ID : ${user.user?.id ?? ''}\n');
        printText('Time : $printDate\n');
        printText('Order Number : ${serial.id}\n');
        printText('Expiry Time : ${serial.expiredDate ?? serial.code3}');

        if (cardPhotoBytes != null) {
          PrintBluetoothThermal.writeBytes(cardPhotoBytes);
        }

        printText("\n$cardTitle");

        if (serial.serial?.isNotEmpty ?? false) {
          printText("\nSerial : ${serial.serial}");
        }

        if (serial.code1 != null &&
            serial.code1 is String &&
            (serial.code1 as String).isNotEmpty) {
          printText('\nPin Code :');
        }
        if (pinCodeBytes != null) {
          PrintBluetoothThermal.writeBytes(pinCodeBytes);
        }

        if (qrCodeBytes != null) {
          PrintBluetoothThermal.writeBytes(qrCodeBytes);
        }

        if (barCodeBytes != null) {
          PrintBluetoothThermal.writeBytes(barCodeBytes);
        }

        if (footerBytes != null) {
          PrintBluetoothThermal.writeBytes(footerBytes);
        }

        printText('\n --------------- \n\n');
        debugPrint("✅ چاپ کامل شد برای index $index");
      }
    }

    bluetoothController.tryAutoConnectPrinter();

    return InternalPage(
      title: 'طباعة',
      disconnect: true,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: Constants.intesharBoxDecoration(context).copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
        child: Obx(
          () {
            return SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: bluetoothController.isConnected.value
                  ? Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Offstage(
                              offstage: false,
                              child: RepaintBoundary(
                                // key: _globalKey,
                                child: Container(
                                  constraints: const BoxConstraints(
                                    maxWidth: 360.0,
                                  ),
                                  child: FutureBuilder(
                                    future: Future.delayed(const Duration(
                                        seconds: 1)), // ⏳ یک ثانیه صبر
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.done) {
                                        // ✅ حالا ویجت‌ها رو بساز
                                        return Column(
                                          children: List.generate(
                                            serialList.length,
                                            (index) => Container(
                                              alignment: Alignment.center,
                                              margin: const EdgeInsets.only(
                                                  bottom: 25),
                                              child: PrintWidget(
                                                printDate: printDate,
                                                cardTitle: cardTitle,
                                                photoUrl: photoUrl,
                                                serialId: serialList[index]
                                                        ?.id
                                                        ?.toString() ??
                                                    '',
                                                serial:
                                                    serialList[index]?.serial ??
                                                        '',
                                                pinCode:
                                                    serialList[index]?.code ??
                                                        '',
                                                ussd: (index < ussdCodes.length)
                                                    ? ussdCodes[index]?.code ??
                                                        ''
                                                    : '',
                                                code1:
                                                    serialList[index]?.code1 ??
                                                        '',
                                                code2:
                                                    serialList[index]?.code2 ??
                                                        '',
                                                code3:
                                                    serialList[index]?.code3 ??
                                                        '',
                                                code4:
                                                    serialList[index]?.code4 ??
                                                        '',
                                                footerText: footer,
                                                cardPhotoScreenshotControllers:
                                                    cardPhotoScreenshotControllers[
                                                        index],
                                                headerScreenshotControllers:
                                                    headerScreenshotControllers[
                                                        index],
                                                qrcodeScreenshotControllers:
                                                    qrcodeScreenshotControllers[
                                                        index],
                                                footerScreenshotControllers:
                                                    footerScreenshotControllers[
                                                        index],
                                                pinCodeScreenshotControllers:
                                                    pinCodeScreenshotControllers[
                                                        index],
                                                isReported: isReported,
                                                barCodeScreenshotControllers:
                                                    barCodeScreenshotControllers[
                                                        index],
                                                cardId: cardId,
                                                expiryTime: serialList[index]
                                                        ?.expiredDate ??
                                                    serialList[index]?.code3 ??
                                                    '',
                                              ),
                                            ),
                                          ),
                                        );
                                      } else {
                                        return const Center(
                                          child: CustomLoading(),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Gap(5),
                        Obx(() {
                          switch (bluetoothController.rxRequestStatus.value) {
                            case Status.loading:
                              return const CustomLoading();
                            default:
                              return const SizedBox.shrink();
                          }
                        }),
                        const Gap(5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Obx(() {
                              return ElevatedButton(
                                onPressed: (!bluetoothController
                                            .printed.value &&
                                        !bluetoothController.isLoading.value)
                                    ? () async {
                                        bluetoothController.isLoading.value =
                                            true;

                                        bool isConnected =
                                            await PrintBluetoothThermal
                                                .connectionStatus;

                                        if (!isConnected) {
                                          Get.snackbar("جاري محاولة الاتصال",
                                              "تم قطع الاتصال بالطابعة، جارٍ إعادة الاتصال...");

                                          final savedPrinter = Constants
                                              .localStorage
                                              .read('printAddres');

                                          if (savedPrinter != null &&
                                              savedPrinter['macAddress'] !=
                                                  null &&
                                              savedPrinter['name'] != null) {
                                            try {
                                              await bluetoothController
                                                  .connectToDevice(
                                                savedPrinter['macAddress'],
                                                savedPrinter['name'],
                                              );
                                              Get.snackbar("تم الاتصال بنجاح",
                                                  "تم الاتصال بالطابعة بنجاح، جاري الطباعة...");
                                            } catch (e) {
                                              Get.snackbar("خطأ في الاتصال",
                                                  "فشل الاتصال بالطابعة: $e");
                                              bluetoothController
                                                  .isLoading.value = false;
                                              return;
                                            }
                                          } else {
                                            Get.snackbar("خطأ",
                                                "لم يتم تخزين معلومات الطابعة.");
                                            bluetoothController
                                                .isLoading.value = false;
                                            return;
                                          }
                                        }

                                        try {
                                          await captureAndSavePng();
                                          bluetoothController.printed.value =
                                              true;
                                          Get.snackbar(
                                              "نجاح", "تمت الطباعة بنجاح");
                                        } catch (e) {
                                          bluetoothController.printed.value =
                                              false;
                                          Get.snackbar("فشل الطباعة",
                                              "الطباعة لم تنجح، حاول مرة أخرى");
                                        } finally {
                                          bluetoothController.isLoading.value =
                                              false;
                                        }
                                      }
                                    : null,
                                child: bluetoothController.isLoading.value
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2),
                                      )
                                    : Row(
                                        children: [
                                          SvgPicture.asset(
                                            'assets/svgs/print.svg',
                                            colorFilter: ColorFilter.mode(
                                              Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                              BlendMode.srcIn,
                                            ),
                                            width: 20,
                                            height: 20,
                                          ),
                                          const Gap(5),
                                          Text(bluetoothController.printed.value
                                              ? "تمت الطباعة"
                                              : "طباعة"),
                                        ],
                                      ),
                              );
                            }),
                            const Gap(10),
                            ZoomTapAnimation(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  if (bluetoothController.printCount.value <=
                                      (updateController.homeDataList.first.user!
                                              .agent!.maxReprints ??
                                          1)) {
                                    bool isConnected =
                                        await PrintBluetoothThermal
                                            .connectionStatus;

                                    if (!isConnected) {
                                      Get.snackbar("جاري محاولة الاتصال",
                                          "تم قطع الاتصال بالطابعة، جارٍ إعادة الاتصال...");

                                      final savedPrinter = Constants
                                          .localStorage
                                          .read('printAddres');

                                      if (savedPrinter != null &&
                                          savedPrinter['macAddress'] != null &&
                                          savedPrinter['name'] != null) {
                                        try {
                                          await bluetoothController
                                              .connectToDevice(
                                            savedPrinter['macAddress'],
                                            savedPrinter['name'],
                                          );
                                          Get.snackbar("تم الاتصال بنجاح",
                                              "تم الاتصال بالطابعة بنجاح، جاري الطباعة...");
                                        } catch (e) {
                                          Get.snackbar("خطأ في الاتصال",
                                              "فشل الاتصال بالطابعة: $e");
                                          return;
                                        }
                                      } else {
                                        Get.snackbar("خطأ",
                                            "لم يتم تخزين معلومات الطابعة.");
                                        return;
                                      }
                                    }

                                    buildPrintString();
                                  } else {
                                    Get.closeAllSnackbars();
                                    Get.snackbar('تنبيه',
                                        'تجاوزت الحد الاقصى لعدد مرات تكرار الخدمة!');
                                  }
                                },
                                label: const Text('طباعة مختصرة'),
                                icon: SvgPicture.asset(
                                  'assets/svgs/print.svg',
                                  colorFilter: ColorFilter.mode(
                                    Theme.of(context).colorScheme.onPrimary,
                                    BlendMode.srcIn,
                                  ),
                                  width: 20,
                                  height: 20,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: (bluetoothController
                                              .printCount.value <=
                                          (updateController.homeDataList.first
                                                  .user!.agent!.maxReprints ??
                                              1))
                                      ? Theme.of(context).colorScheme.secondary
                                      : Theme.of(context).colorScheme.surface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // const Gap(5),
                        // ZoomTapAnimation(
                        //   child: ElevatedButton.icon(
                        //     onPressed: () {
                        //       bluetoothController.disconnectDevice();
                        //     },
                        //     label: const Text('قطع الاتصال'),
                        //     icon: SvgPicture.asset(
                        //       'assets/svgs/signal-stream-slash.svg',
                        //       colorFilter: ColorFilter.mode(
                        //         Theme.of(context).colorScheme.onPrimary,
                        //         BlendMode.srcIn,
                        //       ),
                        //       width: 20,
                        //       height: 20,
                        //     ),
                        //   ),
                        // ),
                        const Gap(5),
                        Text(
                            "تم الاتصال بـ : ${bluetoothController.deviceName.value}"),
                      ],
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: bluetoothController.devicesList.length,
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
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: ListTile(
                                    title: Text(device.name),
                                    subtitle:
                                        Text(device.macAddress.toString()),
                                    onTap: () {
                                      bluetoothController.deviceName.value =
                                          device.name;
                                      bluetoothController.connectToDevice(
                                        device.macAddress,
                                        device.name,
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              bluetoothController.checkAndRequestBluetooth();
                            },
                            child: bluetoothController.isLoading.value
                                ? CustomLoading(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  )
                                : const Text('البحث عن أجهزة'),
                          ),
                        ),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }

  Future<List<int>?> processImageForPrinter(Uint8List imageBytes) async {
    try {
      // تبدیل بایت‌ها به تصویر
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        print("Error: Failed to decode image.");
        return null;
      }

      // تغییر اندازه تصویر
      final resizedImage = img.copyResize(image, width: 384);
      final processedImage = adjustContrastAndThreshold(resizedImage, 1.5);

      // تبدیل تصویر به داده‌های باینری مناسب چاپگر
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      final bytes = generator.imageRaster(
        processedImage,
        align: PosAlign.center,
        highDensityHorizontal: true,
        highDensityVertical: true,
      );

      return bytes;
    } catch (e) {
      print("Error processing image: $e");
      return null;
    }
  }

  img.Image adjustContrastAndThreshold(
      img.Image originalImage, double contrast) {
    // افزایش کنتراست با adjustColor
    final contrastAdjusted = img.adjustColor(originalImage, contrast: contrast);

    // مقدار آستانه برای باینری کردن تصویر
    const int threshold = 228;

    for (int y = 0; y < contrastAdjusted.height; y++) {
      for (int x = 0; x < contrastAdjusted.width; x++) {
        final pixel = contrastAdjusted.getPixel(x, y);
        final luminance = img.getLuminance(pixel);

        if (luminance < threshold) {
          contrastAdjusted.setPixel(x, y, img.ColorInt32.rgba(0, 0, 0, 255));
        } else {
          contrastAdjusted.setPixel(
              x, y, img.ColorInt32.rgba(255, 255, 255, 255));
        }
      }
    }

    return contrastAdjusted;
  }

  buildPrintString() async {
    bluetoothController.printCount.value++;

    final updateController = Get.find<HomeApiProvider>();
    final user = updateController.homeDataList.first;
    String formatSerial(serial) {
      return [
        bluetoothController.printed.value || isReported
            ? '--------- 2 ---------\n'
            : '',
        'Terminal ID : ${user.user?.id ?? ''}',
        'Time : $printDate',
        'Order Number : ${serial.id}',
        'Expiry Time : ${serial.expiredDate ?? serial.code3}',
        cardTitle,
        if (serial.serial != null &&
            (serial.serial is String) &&
            serial.serial!.isNotEmpty)
          'Serial : ${serial.serial}',
        if (serial.code != null &&
            (serial.code is String) &&
            serial.code!.isNotEmpty)
          if (serial.code != null && serial.code!.isNotEmpty)
            if ((serial.code as String).length > 15)
              '\nPin Code : \n'
                  "\x1D\x21\x00" // کوچک کردن سایز فونت
                  "\x1B\x45\x01" // فعال کردن بولد
                  "${serial.code}"
                  "\x1B\x45\x00" // غیرفعال کردن بولد
                  "\x1D\x21\x00" // بازگشت به سایز فونت اصلی
                  "\x1B\x4D\x00\n\n\n" // بازگشت به فونت اصلی

            else
              '\nPin Code : \n'
                  "\x1B\x61\x00"
                  "\x1B\x4D\x01" // Select font B
                  "\x1B\x45\x01" // Activate bold
                  "\x1B\x45\x01\x1D\x21\x11${serial.code}\x1D\x21\x00\x1B\x45\x00"
                  "\x1B\x4D\x00\n\n\n",
        if (serial.code1 != null &&
            (serial.code1 is String) &&
            serial.code1!.isNotEmpty)
          [
            "${serial.code1}"
                "\n"
                "\x1B\x61\x00"
                "\x1B\x4D\x01" // Select font B
                "\x1B\x45\x01" // Activate bold
                "\x1D\x21\x11${serial.code2}\x1D\x21\x00\x1B\x45\x00"
                "\x1B\x4D\x00" // Reset to font A
                "\n"
                "${serial.code3}"
                "\n"
                "${serial.code4}"
                "\n\n\n"
          ].where((code) => code.isNotEmpty).join("\n"),
      ].join('\n');
    }

    String combinedString =
        serialList.map(formatSerial).join('\n --------------- \n');

    Uint8List byteArray = Uint8List.fromList(utf8.encode(combinedString));

    // تبدیل Uint8List به یک لیست معمولی (List<int>)
    List<int> byteList = byteArray.toList();
    PrintBluetoothThermal.writeBytes(byteList);
    bluetoothController.printed.value = true;
    print('Success');
  }
}
