import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/core/common/constants/dashed_border.dart';
import 'package:inteshar/app/core/routes/routes.dart';

class OfflineWidget extends StatelessWidget {
  const OfflineWidget({
    super.key,
    this.showLogo,
  });
  final bool? showLogo;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        showLogo ?? true
            ? Image.asset(
                'assets/images/logo_cn.png',
                fit: BoxFit.fill,
                height: 80,
                width: 80,
              )
            : const SizedBox.shrink(),
        const Gap(10),
        DashedBorder(
          color: Theme.of(context).colorScheme.onPrimary,
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: TextButton(
                onPressed: () {
                  Get.offAndToNamed(Routes.welcomePage);
                },
                child: Text(
                  'انضم إلينا الآن .. وقم بتسجيل الدخول',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                )),
          ),
        ),
      ],
    );
  }
}
