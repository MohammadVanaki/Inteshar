import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/core/data/data_source/delete_account_api.dart';
import 'package:inteshar/app/core/data/data_source/logout_api_provider.dart';
import 'package:inteshar/app/features/home/data/data_source/home_api_provider.dart';

class USerInformationWidget extends StatelessWidget {
  const USerInformationWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final updateController = Get.find<HomeApiProvider>();
        final user = updateController.homeDataList.first;
        final List<Map<String, dynamic>> userInformations = [
          {
            "icon": 'envelope-open',
            "title": 'البريد الإلكتروني :',
            "data": user.user?.username ?? '',
          },
          {
            "icon": 'phone-flip',
            "title": 'الهاتف :',
            "data": user.user?.mobile ?? '',
          },
          {
            "icon": 'branding',
            "title": 'الاسم التجاري :',
            "data": user.user?.agent?.name ?? '',
          },
          {
            "icon": 'marker',
            "title": 'العنوان :',
            "data": user.user?.address ?? '',
          },
        ];
        return Column(
          children: [
            ListView.builder(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: userInformations.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    const Gap(5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          'assets/svgs/${userInformations[index]['icon']}.svg',
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                        const Gap(5),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 7),
                            child: Text(userInformations[index]['title']),
                          ),
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 7),
                            child: Text(
                              userInformations[index]['data'],
                              textAlign: TextAlign.start,
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(5),
                    const Divider(
                      indent: 20,
                      endIndent: 20,
                    ),
                  ],
                );
              },
            ),
            const Gap(20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Theme.of(context).colorScheme.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                if (!Get.isRegistered<LogoutApiProvider>()) {
                  Get.put(LogoutApiProvider());
                }
                final LogoutApiProvider profileController =
                    Get.find<LogoutApiProvider>();
                if (Constants.isLoggedIn) {
                  Get.dialog(
                    AlertDialog(
                      title: const Text('تنبيه'),
                      content: const Text('هل تريد تسجيل الخروج من حسابك؟'),
                      actions: [
                        ElevatedButton(
                          onPressed: () => Get.back(),
                          child: const Text('لا'),
                        ),
                        Obx(() => ElevatedButton(
                              onPressed: profileController.isLogoutLoading.value
                                  ? null
                                  : () => profileController.logoutUser(),
                              child: profileController.isLogoutLoading.value
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white))
                                  : const Text(
                                      'نعم',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                            )),
                      ],
                    ),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/svgs/leave.svg',
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.onError,
                        BlendMode.srcIn,
                      ),
                    ),
                    const Gap(10),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'خروج',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onError,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Gap(10),
            TextButton(
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    title: Text(
                      'تنبيه',
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                    content: Row(
                      children: [
                        SvgPicture.asset(
                          width: 20,
                          height: 20,
                          'assets/svgs/light-emergency-on.svg',
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.error,
                            BlendMode.srcIn,
                          ),
                        ),
                        const Gap(10),
                        Text(
                          'هل أنت متأكد من حذف حسابك؟',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                        ),
                      ],
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text(
                          'لا',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          deleteAccount();
                        },
                        child: const Text(
                          'نعم',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/svgs/delete-user.svg',
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.error,
                      BlendMode.srcIn,
                    ),
                    width: 20,
                    height: 20,
                  ),
                  const Gap(10),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'حذف حساب المستخدم',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
