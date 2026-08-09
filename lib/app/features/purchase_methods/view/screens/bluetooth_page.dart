import 'dart:convert';
import 'dart:io';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/features/home/data/data_source/home_api_provider.dart';
import 'package:inteshar/app/features/purchase_methods/services/optimized_printer_service.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:screenshot/screenshot.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/config/functions.dart';
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
    required this.originalAgent,
  });
  final List serialList;
  final List ussdCodes;
  final String photoUrl;
  final String printDate;
  final String cardTitle;
  final String footer;
  final bool isReported;
  final String cardId;
  final String originalAgent;
  // final GlobalKey _globalKey = GlobalKey();
  final BluetoothController bluetoothController =
      Get.find<BluetoothController>();
  @override
  Widget build(BuildContext context) {
    print('printDate=======>$printDate');
    bluetoothController.printed.value = false;
    bluetoothController.printCount.value = 0;
    SettingController settingController = Get.find<SettingController>();
    final updateController = Get.find<HomeApiProvider>();
    // final String cleanFooter = removeHtmlTags(footer);

    List<ScreenshotController> cardPhotoScreenshotControllers = List.generate(
      serialList.length,
      (_) => ScreenshotController(),
    );

    List<ScreenshotController> headerScreenshotControllers = List.generate(
      serialList.length,
      (_) => ScreenshotController(),
    );

    List<ScreenshotController> qrcodeScreenshotControllers = List.generate(
      serialList.length,
      (_) => ScreenshotController(),
    );

    List<ScreenshotController> footerScreenshotControllers = List.generate(
      serialList.length,
      (_) => ScreenshotController(),
    );
    List<ScreenshotController> pinCodeScreenshotControllers = List.generate(
      serialList.length,
      (_) => ScreenshotController(),
    );
    List<ScreenshotController> barCodeScreenshotControllers = List.generate(
      serialList.length,
      (_) => ScreenshotController(),
    );

    Future<Uint8List?> waitUntilCaptured(
      ScreenshotController controller, {
      required String tag,
      int retries = 10,
      Duration delay = const Duration(milliseconds: 50),
      bool allowFailure = false,
    }) async {
      for (int i = 0; i < retries; i++) {
        if (i > 0) {
          await Future.delayed(delay);
        }
        await WidgetsBinding.instance.endOfFrame;

        try {
          final bytes = await controller.capture(pixelRatio: 2.0);
          if (bytes != null && bytes.isNotEmpty) {
            debugPrint("✅ [$tag] عکس گرفته شد در تلاش $i");
            return bytes;
          } else {
            debugPrint("⏳ [$tag] تلاش $i: عکس null یا خالی بود");
          }
        } catch (e) {
          debugPrint("❌ [$tag] خطا در تلاش $i برای capture: $e");
        }
      }

      debugPrint("⚠️ [$tag] بعد از $retries تلاش، capture موفق نبود");
      if (allowFailure) {
        return null;
      }
      throw Exception("[$tag] عکس‌برداری ناموفق بود بعد از $retries تلاش");
    }

    Future<void> captureAndSavePng() async {
      bluetoothController.printCount.value++;
      final user = updateController.homeDataList.first;

      for (final serial in serialList) {
        final int index = serialList.indexOf(serial);

        debugPrint("🔍 شروع چاپ موازی برای index: $index");

        final bool showCardPhoto =
            settingController.settings["preview_printCardImage"] ?? false;
        final bool showQrCode =
            settingController.settings["preview_printQrcode"] ?? false;
        final bool showFooter =
            (settingController.settings["preview_printInformation"] ?? false) &&
                footer.isNotEmpty;
        final bool showBarCode =
            settingController.settings["preview_printBarCode"] ?? false;

        // گرفتن همزمان عکس‌ها به صورت موازی (Parallel) برای حداکثر سرعت
        final results = await Future.wait([
          waitUntilCaptured(
            headerScreenshotControllers[index],
            tag: "Header",
            allowFailure: true,
          ),
          showCardPhoto
              ? waitUntilCaptured(
                  cardPhotoScreenshotControllers[index],
                  tag: "CardPhoto",
                  allowFailure: true,
                )
              : Future.value(null),
          showQrCode
              ? waitUntilCaptured(
                  qrcodeScreenshotControllers[index],
                  tag: "QRCode",
                  allowFailure: true,
                )
              : Future.value(null),
          showFooter
              ? waitUntilCaptured(
                  footerScreenshotControllers[index],
                  tag: "Footer",
                  allowFailure: true,
                )
              : Future.value(null),
          showBarCode
              ? waitUntilCaptured(
                  barCodeScreenshotControllers[index],
                  tag: "BarCode",
                  allowFailure: true,
                )
              : Future.value(null),
          waitUntilCaptured(
            pinCodeScreenshotControllers[index],
            tag: "PinCode",
            allowFailure: true,
          ),
        ]);

        final headerImageBytes = results[0];
        final cardPhotoImageBytes = results[1];
        final qrCodeImageBytes = results[2];
        final footerImageBytes = results[3];
        final barCodeImageBytes = results[4];
        final pinCodeImageBytes = results[5];

        final headerBytes = headerImageBytes != null
            ? await processImageForPrinter(headerImageBytes)
            : null;
        final cardPhotoBytes = cardPhotoImageBytes != null
            ? await processImageForPrinter(cardPhotoImageBytes)
            : null;
        final qrCodeBytes = qrCodeImageBytes != null
            ? await processImageForPrinter(qrCodeImageBytes)
            : null;
        final footerBytes = footerImageBytes != null
            ? await processImageForPrinter(footerImageBytes)
            : null;
        final barCodeBytes = barCodeImageBytes != null
            ? await processImageForPrinter(barCodeImageBytes)
            : null;
        final pinCodeBytes = pinCodeImageBytes != null
            ? await processImageForPrinter(pinCodeImageBytes)
            : null;

        List<int> allBytes = [];

        void addText(String text, {bool bold = false}) {
          if (text.isEmpty) return;
          if (bold) allBytes.addAll(const [0x1B, 0x45, 0x01]);
          allBytes.addAll(utf8.encode(text));
          if (bold) allBytes.addAll(const [0x1B, 0x45, 0x00]);
        }

        // شروع چاپ
        debugPrint("🖨️ شروع جمع‌آوری بایت‌ها برای index $index");
        bluetoothController.printed.value = true;
        
        if (headerBytes != null) {
          allBytes.addAll(headerBytes);
        }
        
        addText(isReported ? '--------- 2 ---------\n' : '');
        
        // Set alignment to Left (0)
        allBytes.addAll(const [0x1B, 0x61, 0x00]);
        addText('Terminal ID : ${user.user?.id ?? ''}\n');
        addText('Time : $printDate\n');
        addText('Order Number : ${serial.id}\n');
        addText('Expiry Time : ${serial.expiredDate ?? serial.code3}');

        if (cardPhotoBytes != null) {
          allBytes.addAll(cardPhotoBytes);
        }

        // Set alignment to Center (1)
        allBytes.addAll(const [0x1B, 0x61, 0x01]);
        
        // Arabic text might not print well as UTF-8, but we keep it as it was
        addText("\n$cardTitle", bold: true);

        // Reset alignment to Left (0)
        allBytes.addAll(const [0x1B, 0x61, 0x00]);
        if (serial.serial?.isNotEmpty ?? false) {
          addText("\nSerial : ${serial.serial}");
        }

        if (serial.code1 != null &&
            serial.code1 is String &&
            (serial.code1 as String).isNotEmpty) {
          addText('\nPin Code :');
        }
        if (pinCodeBytes != null) {
          allBytes.addAll(pinCodeBytes);
        }

        if (qrCodeBytes != null) {
          allBytes.addAll(qrCodeBytes);
        }

        if (barCodeBytes != null) {
          allBytes.addAll(barCodeBytes);
        }

        if (footerBytes != null) {
          allBytes.addAll(footerBytes);
        }

        addText('\n --------------- \n');
        
        debugPrint("✅ ارسال یکپارچه بایت‌ها به پرینتر برای index $index");
        try {
          await PrintBluetoothThermal.writeBytes(allBytes);
        } catch (e) {
          debugPrint("⚠️ خطا در ارسال بایت‌ها به پرینتر: $e");
        }
      }
    }

    OptimizedPrinterService.preWarm(
      photoUrl: photoUrl,
      printCardImage:
          settingController.settings["preview_printCardImage"] ?? false,
    );
    bluetoothController.tryAutoConnectPrinter();

    return InternalPage(
      title: 'طباعة',
      disconnect: true,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: Constants.intesharBoxDecoration(
          context,
        ).copyWith(color: Theme.of(context).colorScheme.primary),
        child: Obx(() {
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
                                child: Column(
                                  children: List.generate(
                                    serialList.length,
                                    (index) => Container(
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.only(bottom: 25),
                                      child: PrintWidget(
                                        printDate: printDate,
                                        cardTitle: cardTitle,
                                        photoUrl: photoUrl,
                                        serialId:
                                            serialList[index]?.id?.toString() ??
                                                '',
                                        serial: serialList[index]?.serial ?? '',
                                        pinCode: serialList[index]?.code ?? '',
                                        ussd: (index < ussdCodes.length)
                                            ? ussdCodes[index]?.code ?? ''
                                            : '',
                                        code1: serialList[index]?.code1 ?? '',
                                        code2: serialList[index]?.code2 ?? '',
                                        code3: serialList[index]?.code3 ?? '',
                                        code4: serialList[index]?.code4 ?? '',
                                        originalAgent: originalAgent,
                                        footerText: footer,
                                        cardPhotoScreenshotControllers:
                                            cardPhotoScreenshotControllers[
                                                index],
                                        headerScreenshotControllers:
                                            headerScreenshotControllers[index],
                                        qrcodeScreenshotControllers:
                                            qrcodeScreenshotControllers[index],
                                        footerScreenshotControllers:
                                            footerScreenshotControllers[index],
                                        pinCodeScreenshotControllers:
                                            pinCodeScreenshotControllers[index],
                                        isReported: isReported,
                                        barCodeScreenshotControllers:
                                            barCodeScreenshotControllers[index],
                                        cardId: cardId,
                                        expiryTime:
                                            serialList[index]?.expiredDate ??
                                                serialList[index]?.code3 ??
                                                '',
                                      ),
                                    ),
                                  ),
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
                              onPressed: (!bluetoothController.printed.value &&
                                      !bluetoothController.isLoading.value)
                                  ? () async {
                                      bluetoothController.isLoading.value =
                                          true;

                                      bool isConnected =
                                          await PrintBluetoothThermal
                                              .connectionStatus;

                                      if (!isConnected) {
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
                                          } catch (e) {
                                            bluetoothController
                                                .isLoading.value = false;
                                            return;
                                          }
                                        } else {
                                          bluetoothController.isLoading.value =
                                              false;
                                          return;
                                        }
                                      }

                                      try {
                                        await captureAndSavePng();
                                        bluetoothController.printed.value =
                                            true;
                                      } catch (e) {
                                        bluetoothController.printed.value =
                                            false;
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
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/svgs/print.svg',
                                          colorFilter: ColorFilter.mode(
                                            Theme.of(
                                              context,
                                            ).colorScheme.onPrimary,
                                            BlendMode.srcIn,
                                          ),
                                          width: 20,
                                          height: 20,
                                        ),
                                        const Gap(5),
                                        Text(
                                          bluetoothController.printed.value
                                              ? "تمت الطباعة"
                                              : "طباعة",
                                        ),
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
                                  bool isConnected = await PrintBluetoothThermal
                                      .connectionStatus;

                                  if (!isConnected) {
                                    // Get.snackbar("جاري محاولة الاتصال",
                                    //     "تم قطع الاتصال بالطابعة، جارٍ إعادة الاتصال...");

                                    final savedPrinter = Constants.localStorage
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
                                        // Get.snackbar("تم الاتصال بنجاح",
                                        //     "تم الاتصال بالطابعة بنجاح، جاري الطباعة...");
                                      } catch (e) {
                                        // Get.snackbar("خطأ في الاتصال",
                                        //     "فشل الاتصال بالطابعة: $e");
                                        return;
                                      }
                                    }
                                  }

                                  buildPrintString();
                                } else {
                                  // Get.closeAllSnackbars();
                                  // Get.snackbar('تنبيه',
                                  //     'تجاوزت الحد الاقصى لعدد مرات تكرار الخدمة!');
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
                      const Gap(5),
                      Text(
                        "تم الاتصال بـ : ${bluetoothController.deviceName.value}",
                      ),
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
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary.withAlpha(30),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  leading: Icon(
                                    device.isPrinter
                                        ? Icons.print_rounded
                                        : Icons.bluetooth_rounded,
                                    color: device.isPrinter
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withAlpha(120),
                                  ),
                                  title: Text(device.name),
                                  subtitle: Text(device.macAddress.toString()),
                                  trailing: Obx(() {
                                    final isThisConnected = bluetoothController
                                            .isConnected.value &&
                                        bluetoothController.deviceName.value ==
                                            device.name;
                                    return isThisConnected
                                        ? const Icon(
                                            Icons.check_circle_rounded,
                                            color: Colors.green,
                                          )
                                        : const SizedBox.shrink();
                                  }),
                                  onTap: () async {
                                    await bluetoothController.connectToDevice(
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
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                )
                              : const Text('البحث عن أجهزة'),
                        ),
                      ),
                    ],
                  ),
          );
        }),
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
      final trimmedImage = trimWhiteMargins(processedImage);

      // تبدیل تصویر به داده‌های باینری مناسب چاپگر
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);

      List<int> bytes;
      if (Platform.isIOS) {
        // On iOS, imageRaster (GS v 0) often prints as garbage due to Bluetooth
        // chunking limits. Using generator.image (ESC *) is safer.
        bytes = generator.image(trimmedImage, align: PosAlign.center);
      } else {
        bytes = generator.imageRaster(
          trimmedImage,
          align: PosAlign.center,
          highDensityHorizontal: true,
          highDensityVertical: true,
        );
      }

      return bytes;
    } catch (e) {
      print("Error processing image: $e");
      return null;
    }
  }

  img.Image trimWhiteMargins(img.Image image) {
    int top = 0;
    int bottom = image.height - 1;

    // پیدا کردن اولین ردیف غیر سفید از بالا
    for (int y = 0; y < image.height; y++) {
      bool rowHasContent = false;
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;
        if (r < 240 || g < 240 || b < 240) {
          rowHasContent = true;
          break;
        }
      }
      if (rowHasContent) {
        top = y;
        break;
      }
    }

    // پیدا کردن اولین ردیف غیر سفید از پایین
    for (int y = image.height - 1; y >= top; y--) {
      bool rowHasContent = false;
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;
        if (r < 240 || g < 240 || b < 240) {
          rowHasContent = true;
          break;
        }
      }
      if (rowHasContent) {
        bottom = y;
        break;
      }
    }

    final safeTop = (top - 1).clamp(0, image.height - 1);
    final safeBottom = (bottom + 1).clamp(0, image.height - 1);
    final cropHeight = safeBottom - safeTop + 1;

    if (cropHeight <= 0 || cropHeight >= image.height) {
      return image;
    }

    return img.copyCrop(
      image,
      x: 0,
      y: safeTop,
      width: image.width,
      height: cropHeight,
    );
  }

  img.Image adjustContrastAndThreshold(
    img.Image originalImage,
    double contrast,
  ) {
    final contrastAdjusted = img.adjustColor(originalImage, contrast: contrast);

    const int threshold = 228;

    for (int y = 0; y < contrastAdjusted.height; y++) {
      for (int x = 0; x < contrastAdjusted.width; x++) {
        final pixel = contrastAdjusted.getPixel(x, y);
        final luminance = img.getLuminance(pixel);

        if (luminance < threshold) {
          contrastAdjusted.setPixel(x, y, img.ColorInt32.rgba(0, 0, 0, 255));
        } else {
          contrastAdjusted.setPixel(
            x,
            y,
            img.ColorInt32.rgba(255, 255, 255, 255),
          );
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
                "\n\n\n",
          ].where((code) => code.isNotEmpty).join("\n"),
      ].join('\n');
    }

    String combinedString =
        '${serialList.map(formatSerial).join('\n --------------- \n')}\n';

    Uint8List byteArray = Uint8List.fromList(utf8.encode(combinedString));

    // تبدیل Uint8List به یک لیست معمولی (List<int>)
    List<int> byteList = byteArray.toList();
    PrintBluetoothThermal.writeBytes(byteList);
    bluetoothController.printed.value = true;
    print('Success');
  }
}
