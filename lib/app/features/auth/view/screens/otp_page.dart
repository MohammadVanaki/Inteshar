import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/config/status.dart';
import 'package:inteshar/app/features/auth/view/getX/otp_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pinput/pinput.dart';

class OtpPage extends StatelessWidget {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final OtpController controller = Get.put(OtpController());

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.secondary,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black45),
        borderRadius: BorderRadius.circular(12),
      ),
    );
    print('secret = ${controller.secret}');
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 234, 234, 234),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Gap(20),
                controller.qr != ''
                    ? buildQrImage(controller.qr)
                    : SvgPicture.asset(
                        width: Get.width - 460,
                        height: Get.height * 0.22,
                        'assets/svgs/welcome/otp.svg',
                      ),
                const Gap(10),
                controller.secret != ''
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceVariant
                              .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              color:
                                  Theme.of(context).colorScheme.outlineVariant),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      final Uri uri = Uri.parse(
                                        'otpauth://totp/App:User?secret=${controller.secret}&issuer=inteshar',
                                      );
                                      if (await canLaunchUrl(uri)) {
                                        await launchUrl(uri,
                                            mode:
                                                LaunchMode.externalApplication);
                                      }
                                    },
                                    child: SelectionArea(
                                      child: Text(
                                        controller.secret,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 20,
                                          fontFamily: 'monospace',
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    Clipboard.setData(
                                        ClipboardData(text: controller.secret));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('تم النسخ',
                                            textAlign: TextAlign.right),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.copy_rounded),
                                  tooltip: 'نسخ الرمز',
                                ),
                                const SizedBox(width: 4),
                                IconButton.filled(
                                  onPressed: () async {
                                    final Uri uri = Uri.parse(
                                      'otpauth://totp/App:User?secret=${controller.secret}&issuer=inteshar',
                                    );
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri,
                                          mode: LaunchMode.externalApplication);
                                    }
                                  },
                                  icon: const Icon(Icons.vpn_key_rounded),
                                  tooltip: 'ربط مع تطبيق المصادقة',
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            const Text(
                              "قم بنسخ الرمز أعلاه أو ادخل مباشرة إلى تطبيق المصادقة.",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(),
                const Gap(30),
                Text(
                  'رمز التحقق',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 25,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const Gap(10),
                Text(
                  'يرجى إدخال رمز التحقق من تطبيق Google Authenticator لإكمال عملية تسجيل الدخول',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Gap(40),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Pinput(
                    length: 6,
                    // showCursor: false,
                    cursor: Container(
                      width: 2,
                      height: 30,
                      color: Colors.black45,
                    ),
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        border: Border.all(
                          color: Colors.black45,
                          width: 2,
                        ),
                      ),
                    ),
                    onCompleted: (value) {
                      controller.verifyOtp(value);
                    },
                  ),
                ),
                const Gap(30),
                Obx(() {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            controller.rxRequestStatus.value == Status.error
                                ? Colors.red
                                : Theme.of(context).colorScheme.secondary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed:
                          controller.rxRequestStatus.value == Status.loading
                              ? null
                              : () => controller
                                  .verifyOtp(controller.pinController.text),
                      child: controller.rxRequestStatus.value == Status.loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              controller.rxRequestStatus.value == Status.error
                                  ? 'إعادة المحاولة'
                                  : 'تأكيد',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildQrImage(String base64Image) {
    try {
      // Remove metadata if exists
      final pureBase64 =
          base64Image.contains(',') ? base64Image.split(',').last : base64Image;

      Uint8List bytes = base64Decode(pureBase64);

      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        height: 180,
        width: 180,
      );
    } catch (e) {
      return Image.asset(
        'assets/images/profile.png',
        fit: BoxFit.fill,
        height: 180,
        width: 180,
      );
    }
  }
}
