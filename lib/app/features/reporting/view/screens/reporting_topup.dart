import 'dart:convert';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/features/purchase_methods/view/getX/print_controller.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:screenshot/screenshot.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:image/image.dart' as img;

import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/config/functions.dart';
import 'package:inteshar/app/config/status.dart';
import 'package:inteshar/app/core/common/widgets/internal_page.dart';
import 'package:inteshar/app/core/common/widgets/offline_widget.dart';
import 'package:inteshar/app/core/common/widgets/retry_widget.dart';
import 'package:inteshar/app/core/utils/custom_loading.dart';
import 'package:inteshar/app/features/home/data/data_source/home_api_provider.dart';
import 'package:inteshar/app/features/reporting/data/data_source/topup_report_api_provider.dart';
import 'package:inteshar/app/features/reporting/view/getX/report_value_controller.dart';
import 'package:inteshar/app/features/reporting/view/widgets/date.dart';

class ReportingTopup extends StatelessWidget {
  const ReportingTopup({super.key});
  @override
  Widget build(BuildContext context) {
    TopupReportApiProvider topupReportApiProvider =
        Get.put(TopupReportApiProvider());
    ReportValueController reportValueController =
        Get.put(ReportValueController());

    TextStyle titleStyle = const TextStyle(fontSize: 15);
    TextStyle dataStyle =
        const TextStyle(fontWeight: FontWeight.w700, fontSize: 17);
    ScreenshotController headerScreenshotControllers = ScreenshotController();
    final BluetoothController bluetoothController =
        Get.put(BluetoothController(), permanent: true);
    return InternalPage(
        title: 'تقارير الـ TopUp والباقات',
        child: Container(
          transform: Matrix4.translationValues(0, -1, 0),
          width: Get.width,
          height: Get.height - Get.mediaQuery.padding.bottom,
          child: Column(
            children: [
              const Gap(10),
              Container(
                alignment: Alignment.center,
                width: Get.width - 40,
                padding: const EdgeInsets.all(20),
                decoration: Constants.intesharBoxDecoration(context),
                child: Constants.isLoggedIn
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const ReportingDate(),
                          const Gap(10),
                          Obx(
                            () => ElevatedButton(
                              onPressed: topupReportApiProvider
                                          .rxRequestButtonStatus.value ==
                                      Status.loading
                                  ? null
                                  : () {
                                      reportValueController.reportPrint.value =
                                          true;
                                      topupReportApiProvider.fetchReportData(
                                        startDate: reportValueController
                                            .startDate.value,
                                        endDate:
                                            reportValueController.endDate.value,
                                      );
                                    },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/svgs/paper-plane-top.svg',
                                    width: 20,
                                    height: 20,
                                    colorFilter: ColorFilter.mode(
                                      Theme.of(context).colorScheme.onPrimary,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const Gap(10),
                                  const Text(
                                    'ارسال',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Gap(10),
                          SizedBox(
                            width: Get.width,
                            height: Get.height -
                                265 -
                                Get.mediaQuery.padding.bottom,
                            child: Obx(() {
                              switch (topupReportApiProvider
                                  .rxRequestStatus.value) {
                                case Status.loading:
                                  return const CustomLoading();
                                case Status.error:
                                  return RetryWidget(
                                    onTap: () =>
                                        topupReportApiProvider.fetchReportData(
                                      startDate:
                                          reportValueController.startDate.value,
                                      endDate:
                                          reportValueController.endDate.value,
                                    ),
                                  );
                                case Status.completed:
                                  return topupReportApiProvider.reportDataList
                                          .first.transactions.isNotEmpty
                                      ? Column(
                                          children: [
                                            const Gap(5),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Screenshot(
                                                    controller:
                                                        headerScreenshotControllers,
                                                    child: Container(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onPrimary,
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            'العدد : ${topupReportApiProvider.reportDataList.first.transactions.length}',
                                                            style: TextStyle(
                                                                fontSize: 12),
                                                          ),
                                                          const Gap(6),
                                                          Text(
                                                            ' المجموع : ${formatNumber(topupReportApiProvider.reportDataList.first.transactions.fold(0, (sum, item) => sum! + item.price))} IQD',
                                                            style: TextStyle(
                                                                fontSize: 12),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Obx(
                                                    () {
                                                      return ZoomTapAnimation(
                                                        child:
                                                            ElevatedButton.icon(
                                                          onPressed:
                                                              !reportValueController
                                                                      .reportPrint
                                                                      .value
                                                                  ? null
                                                                  : () async {
                                                                      reportValueController
                                                                          .reportPrint
                                                                          .value = false;
                                                                      final savedPrinter = Constants
                                                                          .localStorage
                                                                          .read(
                                                                              'printAddres');
                                                                      if (savedPrinter !=
                                                                          null) {
                                                                        bluetoothController
                                                                            .connectToDevice(
                                                                          savedPrinter[
                                                                              'macAddress'],
                                                                          savedPrinter[
                                                                              'name'],
                                                                        );
                                                                      }
                                                                      List<int>?
                                                                          headerBytes;
                                                                      List<int>?
                                                                          headerBytesli;
                                                                      final updateController =
                                                                          Get.find<
                                                                              HomeApiProvider>();
                                                                      final user = updateController
                                                                          .homeDataList
                                                                          .first;
                                                                      Uint8List?
                                                                          headerimageBytes =
                                                                          await headerScreenshotControllers
                                                                              .capture();

                                                                      Uint8List
                                                                          imageBytes =
                                                                          await loadImageFromAssets(
                                                                              'assets/images/logo_topup.jpg');
                                                                      headerBytes =
                                                                          await processImageForPrinter(
                                                                              imageBytes);
                                                                      headerBytesli =
                                                                          await processImageForPrinter(
                                                                              headerimageBytes!);
                                                                      String
                                                                          terminalId =
                                                                          '${reportValueController.startDate.value}<-->${reportValueController.endDate.value} \n Terminal ID : ${user.user?.id ?? ''}\n----------------------';
                                                                      Uint8List
                                                                          byteArray =
                                                                          Uint8List.fromList(
                                                                              utf8.encode(terminalId));
                                                                      final byteList =
                                                                          byteArray
                                                                              .toList();
                                                                      try {
                                                                        if (headerBytes !=
                                                                            null) {
                                                                          PrintBluetoothThermal.writeBytes(
                                                                              headerBytes);
                                                                        }
                                                                        if (headerBytesli !=
                                                                            null) {
                                                                          PrintBluetoothThermal.writeBytes(
                                                                              headerBytesli);
                                                                        }
                                                                        await PrintBluetoothThermal.writeBytes(
                                                                            byteList);
                                                                      } catch (e) {
                                                                        print(
                                                                            'Failed to print Terminal ID: $e');
                                                                        return;
                                                                      }

                                                                      for (var serial in topupReportApiProvider
                                                                          .reportDataList
                                                                          .first
                                                                          .transactions) {
                                                                        final byteList =
                                                                            await buildPrintString(
                                                                          cardTitle:
                                                                              serial.transactionType,
                                                                          printDate: serial
                                                                              .createdAtFormatted
                                                                              .toString(),
                                                                          serialList: [
                                                                            serial
                                                                          ],
                                                                        );

                                                                        try {
                                                                          await PrintBluetoothThermal.writeBytes(
                                                                              byteList);
                                                                        } catch (e) {
                                                                          print(
                                                                              'Failed to print serial: $e');
                                                                        }
                                                                      }

                                                                      print(
                                                                          'All serials printed successfully!');
                                                                    },
                                                          label: const Text(
                                                              'طباعة'),
                                                          icon:
                                                              SvgPicture.asset(
                                                            'assets/svgs/print.svg',
                                                            colorFilter:
                                                                ColorFilter
                                                                    .mode(
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onPrimary,
                                                              BlendMode.srcIn,
                                                            ),
                                                            width: 20,
                                                            height: 20,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  )
                                                ],
                                              ),
                                            ),
                                            const Gap(5),
                                            Expanded(
                                              child: ListView.builder(
                                                  physics:
                                                      const BouncingScrollPhysics(),
                                                  itemCount:
                                                      topupReportApiProvider
                                                          .reportDataList
                                                          .first
                                                          .transactions
                                                          .length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      margin:
                                                          const EdgeInsets.only(
                                                              bottom: 10),
                                                      decoration: Constants
                                                              .intesharBoxDecoration(
                                                                  context)
                                                          .copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary
                                                            .withAlpha(30),
                                                        boxShadow: [],
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'النوع :',
                                                                style:
                                                                    titleStyle,
                                                              ),
                                                              const Gap(10),
                                                              Expanded(
                                                                child: Text(
                                                                  topupReportApiProvider
                                                                      .reportDataList
                                                                      .first
                                                                      .transactions[
                                                                          index]
                                                                      .transactionType,
                                                                  style:
                                                                      dataStyle,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const Gap(5),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'الفئة :',
                                                                style:
                                                                    titleStyle,
                                                              ),
                                                              const Gap(10),
                                                              Expanded(
                                                                child: Text(
                                                                  topupReportApiProvider
                                                                      .reportDataList
                                                                      .first
                                                                      .transactions[
                                                                          index]
                                                                      .asiacellProductTitle,
                                                                  style:
                                                                      dataStyle,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const Gap(5),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'الهاتف :',
                                                                style:
                                                                    titleStyle,
                                                              ),
                                                              const Gap(10),
                                                              Expanded(
                                                                child: Text(
                                                                  topupReportApiProvider
                                                                      .reportDataList
                                                                      .first
                                                                      .transactions[
                                                                          index]
                                                                      .mobile,
                                                                  style:
                                                                      dataStyle,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const Gap(5),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'السعر :',
                                                                style:
                                                                    titleStyle,
                                                              ),
                                                              const Gap(10),
                                                              Expanded(
                                                                child: Text(
                                                                  '${formatNumber(topupReportApiProvider.reportDataList.first.transactions[index].price)} IQD',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .right,
                                                                  textDirection:
                                                                      TextDirection
                                                                          .ltr,
                                                                  style:
                                                                      dataStyle,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const Gap(5),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'التاريخ :',
                                                                style:
                                                                    titleStyle,
                                                              ),
                                                              const Gap(10),
                                                              Expanded(
                                                                child: Text(
                                                                  topupReportApiProvider
                                                                      .reportDataList
                                                                      .first
                                                                      .transactions[
                                                                          index]
                                                                      .createdAtFormatted
                                                                      .toString(),
                                                                  style:
                                                                      dataStyle,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .right,
                                                                  textDirection:
                                                                      TextDirection
                                                                          .ltr,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const Gap(5),
                                                        ],
                                                      ),
                                                    );
                                                  }),
                                            ),
                                          ],
                                        )
                                      : const Center(
                                          child: Text('لا توجد بيانات لعرضها'));

                                default:
                                  return const SizedBox.shrink();
                              }
                            }),
                          ),
                        ],
                      )
                    : const OfflineWidget(),
              ),
            ],
          ),
        ));
  }

  buildPrintString({
    required String printDate,
    required String cardTitle,
    required List serialList,
  }) async {
    String formatSerial(transaction) {
      // Handle both Map and Object cases
      String getId() {
        if (transaction is Map) {
          return transaction['id']?.toString() ?? '';
        } else {
          // Try to access as object property
          try {
            return (transaction as dynamic).id?.toString() ?? '';
          } catch (e) {
            return '';
          }
        }
      }

      String getSerial() {
        if (transaction is Map) {
          return transaction['serial']?.toString() ?? '';
        } else {
          try {
            return (transaction as dynamic).serial?.toString() ?? '';
          } catch (e) {
            return '';
          }
        }
      }

      String getCode1() {
        if (transaction is Map) {
          return transaction['code1']?.toString() ?? '';
        } else {
          try {
            return (transaction as dynamic).code1?.toString() ?? '';
          } catch (e) {
            return '';
          }
        }
      }

      String getType() {
        if (transaction is Map) {
          return transaction['type']?.toString() ?? '';
        } else {
          try {
            return (transaction as dynamic).transactionType?.toString() ?? '';
          } catch (e) {
            return '';
          }
        }
      }

      String getCategory() {
        if (transaction is Map) {
          return transaction['category']?.toString() ?? '';
        } else {
          try {
            return (transaction as dynamic).asiacellProductTitle?.toString() ??
                '';
          } catch (e) {
            return '';
          }
        }
      }

      String getPhone() {
        if (transaction is Map) {
          return transaction['phone']?.toString() ?? '';
        } else {
          try {
            return (transaction as dynamic).mobile?.toString() ?? '';
          } catch (e) {
            return '';
          }
        }
      }

      String getPrice() {
        if (transaction is Map) {
          return transaction['price']?.toString() ?? '';
        } else {
          try {
            return (transaction as dynamic).price?.toString() ?? '';
          } catch (e) {
            return '';
          }
        }
      }

      List<String> lines = [
        'Type : ${getType()}',
        'Category : ${getCategory()}',
        'Phone : ${getPhone()}',
        'Price : ${getPrice()} IQD',
        'Date : $printDate',
      ];

      String serialVal = getSerial();
      if (serialVal.isNotEmpty) {
        lines.add('Serial : $serialVal');
      }

      String code1Val = getCode1();
      if (code1Val.isNotEmpty) {
        lines.add('Code 1 : \n$code1Val');
      }

      String orderId = getId();
      if (orderId.isNotEmpty) {
        lines.add('Order Number : $orderId');
      }

      lines.add("----------------------");

      return lines.where((item) => item.isNotEmpty).join('\n');
    }

    String combinedString =
        serialList.map(formatSerial).join('\n --------------- \n');

    Uint8List byteArray = Uint8List.fromList(utf8.encode(combinedString));

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
