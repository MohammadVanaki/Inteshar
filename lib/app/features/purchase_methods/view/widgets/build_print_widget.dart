import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/features/home/data/data_source/home_api_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:inteshar/app/core/utils/custom_loading.dart';
import 'package:inteshar/app/features/setting/view/getX/setting_controller.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:barcode/barcode.dart';

class PrintWidget extends StatelessWidget {
  const PrintWidget({
    super.key,
    required this.printDate,
    required this.originalAgent,
    required this.serialId,
    required this.cardTitle,
    required this.serial,
    required this.pinCode,
    required this.code1,
    required this.code2,
    required this.code3,
    required this.code4,
    required this.photoUrl,
    required this.ussd,
    required this.footerText,
    required this.isReported,
    required this.expiryTime,
    required this.cardPhotoScreenshotControllers,
    required this.headerScreenshotControllers,
    required this.qrcodeScreenshotControllers,
    required this.footerScreenshotControllers,
    required this.pinCodeScreenshotControllers,
    required this.barCodeScreenshotControllers,
    required this.cardId,
  });
  final String printDate;
  final String originalAgent;
  final String serialId;
  final String cardTitle;
  final String serial;
  final String pinCode;
  final String photoUrl;
  final String footerText;
  final String expiryTime;
  final String ussd;
  final String code1;
  final String code2;
  final String code3;
  final String code4;
  final bool isReported;
  final ScreenshotController cardPhotoScreenshotControllers;
  final ScreenshotController headerScreenshotControllers;
  final ScreenshotController qrcodeScreenshotControllers;
  final ScreenshotController footerScreenshotControllers;
  final ScreenshotController pinCodeScreenshotControllers;
  final String cardId;
  final ScreenshotController barCodeScreenshotControllers;
  @override
  Widget build(BuildContext context) {
    print('=== PRINT WIDGET DATA LOG ===');
    print('printDate=======>>>$printDate');
    print('originalAgent=======>>>$originalAgent');
    print('serialId=======>>>$serialId');
    print('cardTitle=======>>>$cardTitle');
    print('serial=======>>>$serial');
    print('pinCode=======>>>$pinCode');
    print('photoUrl=======>>>$photoUrl');
    print('footerText=======>>>$footerText');
    print('expiryTime=======>>>$expiryTime');
    print('ussd=======>>>$ussd');
    print('code1=======>>>$code1');
    print('code2=======>>>$code2');
    print('code3=======>>>$code3');
    print('code4=======>>>$code4');
    print('isReported=======>>>$isReported');
    print('cardId=======>>>$cardId');
    print('==============================>>>');
    final updateController = Get.find<HomeApiProvider>();
    final user = updateController.homeDataList.first;
    final settingController = Get.find<SettingController>();

    const double mainPadding = 3.0;
    const TextStyle boldTextStyle8 = TextStyle(
        fontWeight: FontWeight.w700, fontSize: 18, color: Colors.black);
    const TextStyle boldTextStyle10 = TextStyle(
        fontWeight: FontWeight.w700, fontSize: 20, color: Colors.black);

    final Barcode barcode = Barcode.code128();

    // Generate the barcode as SVG with safety check
    String svgBarcode = '';
    try {
      if (cardId.isNotEmpty) {
        svgBarcode = barcode.toSvg('00964$cardId');
      }
    } catch (e) {
      debugPrint("Error generating barcode SVG: $e");
    }

    return Container(
      padding: const EdgeInsets.all(mainPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Screenshot(
            controller: headerScreenshotControllers,
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: Column(
                children: [
                  ColorFiltered(
                    colorFilter:
                        const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                    child: Image.asset(
                      'assets/images/logo-1.png',
                      fit: BoxFit.fill,
                      height: 70,
                      width: 60,
                    ),
                  ),
                  Center(
                    child: Text(
                      ' ${originalAgent.isEmpty ? user.parentAgent : originalAgent}',
                      style: boldTextStyle8,
                    ),
                  ),
                  // Text('INTESHAR COMPANY', style: boldTextStyle8),
                  _buildLabeledContainer(user.user?.name ?? ''),
                ],
              ),
            ),
          ),
          isReported
              ? const Text('--------- 2 ---------', style: boldTextStyle10)
              : const SizedBox(),
          _buildAlignText(
              'Terminal ID : ${user.user?.id ?? ''}', boldTextStyle8),
          _buildAlignText('Time : $printDate', boldTextStyle8),
          _buildAlignText('Order Number :  $serialId', boldTextStyle8),
          _buildAlignText('Expiry Time :  $expiryTime', boldTextStyle8),
          const Gap(5),
          Visibility(
            visible:
                settingController.settings["preview_printCardImage"] ?? false,
            child: SizedBox(
              height: 140,
              width: double.infinity,
              child: Screenshot(
                controller: cardPhotoScreenshotControllers,
                child: Container(
                  width: double.infinity,
                  height: 140,
                  color: Colors.white,
                  child: CachedNetworkImage(
                    fit: BoxFit.fill,
                    imageUrl: photoUrl,
                    placeholder: (context, url) => const CustomLoading(),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/images/not.jpg',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              cardTitle,
              style: boldTextStyle10,
            ),
          ),
          const Gap(5),
          pinCode != ''
              ? Column(
                  children: [
                    _buildAlignText('serial : $serial', boldTextStyle8),
                    _buildAlignText(': Pin Code ', boldTextStyle8),
                    Screenshot(
                      controller: pinCodeScreenshotControllers,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Text(
                            pinCode,
                            style: const TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Screenshot(
                  controller: pinCodeScreenshotControllers,
                  child: Container(
                    width: double.infinity,
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Divider(),
                        Text("serial : $code1",
                            style: const TextStyle(
                                fontSize: 18, color: Colors.black),
                            textAlign: TextAlign.center),
                        const Divider(),
                        Text(
                          code2,
                          style: boldTextStyle10,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.ltr,
                        ),
                        const Divider(),
                        Text(
                          code3,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black),
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.ltr,
                        ),
                        const Divider(),
                        Text(
                          code4,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black),
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.ltr,
                        ),
                        const Divider(),
                      ],
                    ),
                  ),
                ),
          Visibility(
            visible: settingController.settings["preview_printQrcode"] ?? false,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              child: Screenshot(
                controller: qrcodeScreenshotControllers,
                child: (pinCode != '' || ussd.isNotEmpty)
                    ? Container(
                        width: double.infinity,
                        height: 90,
                        color: Colors.white,
                        child: Center(
                          child: QrImageView(
                            data: "tel:${ussd.isNotEmpty ? ussd : pinCode}",
                            version: QrVersions.auto,
                            size: 90.0,
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        height: 5,
                        color: Colors.white,
                      ),
              ),
            ),
          ),
          const Gap(2),
          // 1. Barcode
          Visibility(
            visible:
                settingController.settings["preview_printBarCode"] ?? false,
            child: Screenshot(
              controller: barCodeScreenshotControllers,
              child: Container(
                width: double.infinity,
                height: 60,
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                child: svgBarcode.isNotEmpty
                    ? SvgPicture.string(
                        svgBarcode,
                        width: double.infinity,
                        height: 56,
                        fit: BoxFit.fill,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
          // 2. Footer (below Barcode)
          Visibility(
            visible: (settingController.settings["preview_printInformation"] ??
                    false) &&
                footerText.isNotEmpty,
            child: footerText.isNotEmpty
                ? Screenshot(
                    controller: footerScreenshotControllers,
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 20),
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 4),
                      child: Html(
                        data: footerText,
                        style: {
                          "body": Style(
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                            fontSize: FontSize(15),
                            color: Colors.black,
                          ),
                          "p": Style(
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                            fontSize: FontSize(15),
                            color: Colors.black,
                          ),
                        },
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledContainer(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border.symmetric(horizontal: BorderSide()),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildAlignText(String text, TextStyle style) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: style),
    );
  }
}
