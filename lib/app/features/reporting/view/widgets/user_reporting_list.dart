import 'dart:convert';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:image/image.dart' as img;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/features/home/data/data_source/home_api_provider.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:screenshot/screenshot.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/config/functions.dart';
import 'package:inteshar/app/config/status.dart';
import 'package:inteshar/app/core/utils/custom_loading.dart';
import 'package:inteshar/app/features/home/view/getX/purchase_methods_controller.dart';
import 'package:inteshar/app/features/purchase_methods/data/models/purchase_model.dart';
import 'package:inteshar/app/features/purchase_methods/repositories/methods_manager.dart';
import 'package:inteshar/app/features/purchase_methods/view/getX/print_controller.dart';
import 'package:inteshar/app/features/purchase_methods/view/screens/purchase_methods_item.dart';
import 'package:inteshar/app/features/reporting/data/data_source/re_print_api_provider.dart';
import 'package:inteshar/app/features/reporting/data/models/report_model.dart';
import 'package:inteshar/app/features/reporting/view/getX/report_value_controller.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class USerReportingList extends StatelessWidget {
  const USerReportingList({super.key, required this.reportDataList});
  final List<ReportModel> reportDataList;
  @override
  Widget build(BuildContext context) {
    final BluetoothController bluetoothController =
        Get.put(BluetoothController(), permanent: true);
    final updateController = Get.find<HomeApiProvider>();
    final reportValueController = Get.find<ReportValueController>();
    var serials = reportDataList;
    final totalAmount = serials.first.serials
        .map((e) => e.cardPrice ?? 0)
        .fold(0, (prev, next) => prev + next);

    ScreenshotController headerScreenshotControllers = ScreenshotController();
    return Column(
      children: [
        const Gap(5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Screenshot(
                controller: headerScreenshotControllers,
                child: Container(
                  color: Theme.of(context).colorScheme.primary,
                  child: Row(
                    children: [
                      Text(
                        'العدد : ${serials.first.serials.length}',
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      const Gap(10),
                      Text(
                        'المبلغ الكلي : ${formatNumber(totalAmount)}',
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ZoomTapAnimation(
                child: ElevatedButton.icon(
                  onPressed: !reportValueController.reportPrint.value
                      ? null
                      : () async {
                          reportValueController.reportPrint.value = false;
                          final savedPrinter =
                              Constants.localStorage.read('printAddres');
                          if (savedPrinter != null) {
                            bluetoothController.connectToDevice(
                              savedPrinter['macAddress'],
                              savedPrinter['name'],
                            );
                          }
                          List<int>? headerBytes;
                          List<int>? headerBytesli;
                          final updateController = Get.find<HomeApiProvider>();
                          final user = updateController.homeDataList.first;
                          Uint8List? headerimageBytes =
                              await headerScreenshotControllers.capture();

                          Uint8List imageBytes = await loadImageFromAssets(
                              'assets/images/logo_reports.jpg');
                          headerBytes =
                              await processImageForPrinter(imageBytes);
                          headerBytesli =
                              await processImageForPrinter(headerimageBytes!);
                          String terminalId =
                              '${reportValueController.startDate.value}<-->${reportValueController.endDate.value} \n Terminal ID : ${user.user?.id ?? ''}\n----------------------';
                          Uint8List byteArray =
                              Uint8List.fromList(utf8.encode(terminalId));
                          final byteList = byteArray.toList();
                          try {
                            if (headerBytes != null) {
                              PrintBluetoothThermal.writeBytes(headerBytes);
                            }
                            if (headerBytesli != null) {
                              PrintBluetoothThermal.writeBytes(headerBytesli);
                            }
                            await PrintBluetoothThermal.writeBytes(byteList);
                          } catch (e) {
                            print('Failed to print Terminal ID: $e');
                            return;
                          }

                          for (var serial in serials.first.serials) {
                            final byteList = await buildPrintString(
                              cardTitle: serial.title,
                              printDate: serial.printDate,
                              serialList: [serial],
                            );

                            try {
                              await PrintBluetoothThermal.writeBytes(byteList);
                            } catch (e) {
                              print('Failed to print serial: $e');
                            }
                          }

                          print('All serials printed successfully!');
                        },
                  label: const Text('طباعة'),
                  icon: SvgPicture.asset(
                    'assets/svgs/print.svg',
                    colorFilter: const ColorFilter.mode(
                      Colors.black,
                      BlendMode.srcIn,
                    ),
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Gap(5),
        SizedBox(
          width: Get.width,
          height: Get.height - 480,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding:
                const EdgeInsets.only(bottom: 0, top: 0, left: 20, right: 20),
            itemCount: serials.first.serials.length,
            itemBuilder: (context, index) {
              PurchaseMethodsController purchaseMethodsController =
                  Get.put(PurchaseMethodsController(), tag: index.toString());
              purchaseMethodsController.hasGlobalCard.value =
                  serials.first.serials[index].code1 == null ? true : false;
              purchaseMethodsController.isButtonDisabled.value = 1;

              return InkWell(
                onTap: () {
                  purchaseMethodsController.purchaseMethodsSelected.value = -1;
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: Constants.intesharBoxDecoration(context).copyWith(
                    color:
                        Theme.of(context).colorScheme.onPrimary.withAlpha(30),
                    boxShadow: [],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(serials.first.serials[index].id.toString()),
                          Text(
                            serials.first.serials[index].companyTitle,
                          )
                        ],
                      ),
                      const Gap(10),
                      Text(
                        serials.first.serials[index].title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const Gap(10),
                      Text(
                        serials.first.serials[index].serial ??
                            serials.first.serials[index].code1 ??
                            '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                      const Gap(5),
                      Text(
                        serials.first.serials[index].printDate,
                        textDirection: TextDirection.ltr,
                      ),
                      const Gap(10),
                      SizedBox(
                        width: double.infinity,
                        child: PurchaseMethodsItem(
                          scale: 60,
                          tag: index.toString(),
                        ),
                      ),
                      Obx(
                        () {
                          RePrintApiProvider rePrintApiProvider = Get.put(
                              RePrintApiProvider(),
                              tag: index.toString());
                          return (purchaseMethodsController
                                      .purchaseMethodsSelected.value !=
                                  -1)
                              ? OutlinedButton(
                                  onPressed: () {
                                    if (serials.first.serials[index].rePrint <=
                                        (updateController.homeDataList.first
                                                .user!.agent!.maxReprints ??
                                            1)) {
                                      if (purchaseMethodsController
                                              .isButtonDisabled.value <=
                                          (updateController.homeDataList.first
                                                  .user!.agent!.maxReprints ??
                                              1)) {
                                        rePrintApiProvider
                                            .fetchRePrintData(
                                          cardId: serials
                                              .first.serials[index].cardId
                                              .toString(),
                                          serialId: serials
                                              .first.serials[index].id
                                              .toString(),
                                        )
                                            .then(
                                          (success) {
                                            purchaseMethodsController
                                                .isButtonDisabled.value++;
                                            // Handle success
                                            if (success) {
                                              manageMethods(
                                                type: purchaseMethodsController
                                                    .purchaseMethodsSelected
                                                    .value,
                                                serials: [
                                                  serials.first.serials[index]
                                                ],
                                                cardTitle: serials
                                                    .first.serials[index].title,
                                                photoUrl: serials.first
                                                    .serials[index].photoUrl,
                                                printDate: serials.first
                                                    .serials[index].printDate,
                                                title: serials
                                                    .first.serials[index].title,
                                                ussdCodes: [
                                                  UssdCode(
                                                      code: rePrintApiProvider
                                                              .rePrintDataList
                                                              .first
                                                              .ussdCode ??
                                                          '',
                                                      id: -1)
                                                ],
                                                footer: rePrintApiProvider
                                                            .rePrintDataList
                                                            .first
                                                            .cardDetails2
                                                            ?.cardFooter
                                                            ?.isEmpty ??
                                                        true
                                                    ? (rePrintApiProvider
                                                                .rePrintDataList
                                                                .first
                                                                .cardDetails
                                                                ?.cardFooter
                                                                ?.isEmpty ??
                                                            true
                                                        ? ''
                                                        : rePrintApiProvider
                                                            .rePrintDataList
                                                            .first
                                                            .cardDetails!
                                                            .cardFooter!)
                                                    : rePrintApiProvider
                                                        .rePrintDataList
                                                        .first
                                                        .cardDetails2!
                                                        .cardFooter!,
                                                isReported: true,
                                                cardId: serials
                                                    .first.serials[index].cardId
                                                    .toString(),
                                              );
                                            }
                                          },
                                        );
                                      } else {
                                        Get.closeAllSnackbars();
                                        Get.snackbar('تنبيه',
                                            'تجاوزت الحد الاقصى لعدد مرات تكرار الخدمة!');
                                      }
                                    } else {
                                      Get.closeAllSnackbars();
                                      // Show a snackbar if the reprint limit is exceeded
                                      Get.snackbar('تنبيه',
                                          'تجاوزت الحد الاقصى لعدد مرات تكرار الخدمة!');
                                    }
                                  },
                                  child: Obx(() {
                                    switch (rePrintApiProvider
                                        .rxRequestStatus.value) {
                                      case Status.loading:
                                        return const CustomLoading();
                                      case Status.error:
                                        return const SizedBox(
                                          width: double.infinity,
                                          child: Center(
                                              child: Text('حاول مرة أخرى')),
                                        );
                                      case Status.completed:
                                      case Status.initial:
                                        return SizedBox(
                                          width: double.infinity,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SvgPicture.asset(
                                                'assets/svgs/paper-plane-top.svg',
                                                width: 20,
                                                height: 20,
                                                colorFilter: ColorFilter.mode(
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                              const Gap(10),
                                              Text(
                                                'ارسال',
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      default:
                                        return const SizedBox.shrink();
                                    }
                                  }),
                                )
                              : const SizedBox();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  buildPrintString({
    required String printDate,
    required String cardTitle,
    required List serialList,
  }) async {
    String formatSerial(serial) {
      return [
        'Time : $printDate',
        'Order Number : ${serial.id}',
        cardTitle,
        if (serial.serial != null &&
            (serial.serial is String) &&
            serial.serial!.isNotEmpty)
          'Serial : ${serial.serial}',
        if (serial.code1 != null &&
            (serial.code1 is String) &&
            serial.code1!.isNotEmpty)
          'Code 1 : '
              "\n"
              "${serial.code1}",
        "----------------------",
      ].where((item) => item.isNotEmpty).join('\n');
    }

    String combinedString =
        serialList.map(formatSerial).join('\n --------------- \n');

    Uint8List byteArray = Uint8List.fromList(utf8.encode(combinedString));

    // تبدیل Uint8List به یک لیست معمولی (List<int>)
    // List<int> byteList = byteArray.toList();
    print('Success');
    return byteArray.toList();
  }

  Future<Uint8List> loadImageFromAssets(String assetPath) async {
    // بارگذاری تصویر از assets
    final ByteData data = await rootBundle.load(assetPath);
    final List<int> bytes = data.buffer.asUint8List();

    // تبدیل داده‌ها به تصویر با استفاده از بسته `image`
    img.Image image = img.decodeImage(Uint8List.fromList(bytes))!;

    // تبدیل تصویر به فرمت قابل چاپ (با ابعاد و تنظیمات دلخواه)
    img.Image resizedImage =
        img.copyResize(image, width: 300); // تنظیم اندازه تصویر

    // تبدیل تصویر به بایت برای ارسال به چاپگر
    List<int> imageBytes =
        Uint8List.fromList(img.encodeBmp(resizedImage)); // برای چاپگرهای حرارتی

    return Uint8List.fromList(imageBytes);
  }

  Future<List<int>?> processImageForPrinter(Uint8List imageBytes) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        print("Error: Failed to decode image.");
        return null;
      }
      final resizedImage = img.copyResize(image, width: 384);
      final processedImage = adjustContrastAndThreshold(resizedImage, 1.5);
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
}
