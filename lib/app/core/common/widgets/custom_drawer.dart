import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/core/common/constants/get_version.dart';
import 'package:inteshar/app/core/common/constants/launch_url.dart';
import 'package:inteshar/app/core/common/widgets/offline_widget.dart';
import 'package:inteshar/app/core/data/data_source/logout_api_provider.dart';
import 'package:inteshar/app/core/routes/routes.dart';
import 'package:inteshar/app/core/utils/custom_loading.dart';
import 'package:inteshar/app/features/home/data/data_source/home_api_provider.dart';
import 'package:inteshar/app/features/page_view/view/getX/navigation_controller.dart';
import 'package:inteshar/app/features/text_content/view/screen/text_content.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({
    super.key,
    required this.sliderDrawerKey,
  });
  final GlobalKey<SliderDrawerState> sliderDrawerKey;

  @override
  Widget build(BuildContext context) {
    final BottmNavigationController navigationController =
        Get.put(BottmNavigationController(), permanent: true);

    final AppVersionController appVersionController =
        Get.put(AppVersionController());

    final List<Map<String, dynamic>> drawerItemList = [
      {
        "title": 'الرئيسية',
        "icon": 'house',
        "onTap": () {
          sliderDrawerKey.currentState?.closeSlider();
          navigationController.goToPage(0);
        }
      },
      if (Constants.isLoggedIn)
        {
          "title": 'الملف الشخصي',
          "icon": 'user',
          "onTap": () {
            Get.toNamed(
              Routes.profilePage,
            );
          }
        },
      {
        "title": 'عمليات المستخدم',
        "icon": 'file-user',
        "onTap": () {
          Get.toNamed(
            Routes.userOperation,
          );
        }
      },
      {
        "title": 'تقارير الـ TopUp والباقات',
        "icon": 'stats',
        "onTap": () {
          Get.toNamed(
            Routes.reportingTopup,
          );
        }
      },
      {
        "title": 'الاشعارات',
        "icon": 'bell',
        "onTap": () {
          Get.toNamed(
            Routes.notifArchive,
          );
        }
      },
      {
        "title": 'سياسية الخصوصية',
        "icon": 'confidential-discussion',
        "onTap": () {
          urlLauncher('https://inteshar.net/privacy_inteshar.html');
        }
      },
      {
        "title": 'الدعم الفني',
        "icon": 'user-headset',
        "onTap": () {
          final updateController = Get.find<HomeApiProvider>();
          if (updateController.homeDataList.isEmpty) {
            return const SizedBox.shrink();
          }
          final user = updateController.homeDataList.first;
          Get.toNamed(Routes.textContent,
              arguments: TextContent(
                title: 'الدعم الفني',
                text: user.user?.agent?.supportText ??
                    '''لا تتردد في التواصل مع خدمة الدعم الفني لأي استفسار أو مساعدة، عبر البريد الالكتروني او الاتصال المباشر''',
              ));
        }
      },
      {
        "title": 'الشروط والقوانين',
        "icon": 'terms-info',
        "onTap": () {
          // sliderDrawerKey.currentState?.closeSlider();
          Get.toNamed(Routes.textContent,
              arguments: const TextContent(title: 'الشروط والقوانين', text: '''
•⁠  ⁠شرائك لأي من المنتجات تعبر عن موافقتك لجميع هذه البنود في الصفحة.
•⁠  ⁠جميع المنتجات إلكترونية، غير عينية، وتصل لصفحة “الطلبات” على حسابك بالمتجر.
•⁠  ⁠قبل الدفع يتوجب على العميل قراءة وصف المنتج بعناية.
•⁠  ⁠شراء العميل لاي منتج يعبر عن موافقته لمواصفات وشروط المنتجات المذكورة في هذه الصفحة.
•⁠  ⁠جميع المنتجات غير قابلة للاسترداد والاسترجاع نهائياً.
•⁠  ⁠أي بيانات يخطئ في تزويدها العميل للمتجر تخص الطلب لا يتحمل المتجر أي مسؤولية في ذلك.
•⁠  ⁠في حالة حصول خلل لأي من المنتجات, يجب على العميل توفير فيديو كامل اثناء لحظة شراءه يثبت ذلك ( ولن تقبل الشكوى بدون فيديو ).
•⁠  ⁠لا يتحمل متجرنا أي مسؤولية لمشتريات خاطئة قمت بها بذاتك، بسبب الاهمال أو إدخال معلومات زائفة /خاطئة، أو أي سبب آخر مما قد يؤدي إلى • أضرار/خسارات كما أن المتجر غير ملزم بتبديل أو أسترجاع اي منتج تم وصول بياناتها إليك وبهذا تكون قد فهمت و أقررت وقبلت إخلاء متجرنا من المسؤولية تماماً.
•⁠  ⁠بعد التسليم، لا يعتبر المتجر مسؤول عن أي ضياع أو ضرر للسلع الإلكترونية التي تم شرائها من خلال متجرنا ، وأي خسارة أو ضرر قد يعاني منه المشتري لهذا السبب.
•⁠  ⁠يتم تغيير الاسعار في الموقع بشكل يومي/اسبوعي/شهري ولا يحق للعميل مطالبة الفرق لان هناك عروض يوميا ربما يكون هناك ارتفاع/انخفاض في الاسعار، وليس ملزوم متجرنا بدفع الفرق او تثبيت السعر.
•⁠  ⁠يحق للمتجر تغيير أو إضافة بنود في هذه الصفحة في اي وقت تراه مناسب و يجب على العميل متابعة البنود حتى بدون تنبيه.
'''));
        }
      },
      {
        "title": 'خروج',
        "icon": 'sign-out-alt',
        "onTap": () {
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
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                      )),
                ],
              ),
            );
          }
        },
      },
    ];
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.zero),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Constants.isLoggedIn
              ? Obx(
                  () {
                    final updateController = Get.find<HomeApiProvider>();
                    if (updateController.homeDataList.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    final user = updateController.homeDataList.first;
                    return UserAccountsDrawerHeader(
                      accountName: Text(
                        user.user?.name ?? '',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                      accountEmail: Text(
                        user.user?.username ?? '',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                      currentAccountPicture: ClipOval(
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          height: 70,
                          width: 60,
                          imageUrl: user.user?.photoUrl ?? '',
                          placeholder: (context, url) => const CustomLoading(),
                          errorWidget: (context, url, error) => Image.asset(
                            'assets/images/profile.png',
                            fit: BoxFit.fill,
                            height: 70,
                            width: 60,
                          ),
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    );
                  },
                )
              : Container(
                  margin: const EdgeInsets.only(
                      top: 40, bottom: 20, right: 5, left: 5),
                  child: const OfflineWidget(),
                ),
          ...List.generate(
            drawerItemList.length,
            (index) {
              return index < drawerItemList.length - 1
                  ? drawerItemWidget(
                      title: drawerItemList[index]['title'],
                      icon: drawerItemList[index]['icon'],
                      onTap: drawerItemList[index]['onTap'],
                      totalItems: drawerItemList.length,
                      tag: index,
                      context: context,
                    )
                  : Column(
                      children: [
                        const Divider(),
                        drawerItemWidget(
                          title: drawerItemList[index]['title'],
                          icon: drawerItemList[index]['icon'],
                          onTap: drawerItemList[index]['onTap'],
                          totalItems: drawerItemList.length,
                          tag: index,
                          context: context,
                        ),
                      ],
                    );
            },
          ),
          const Gap(10),
          Column(
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'الاصدار: ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    TextSpan(
                      text: appVersionController.version.value,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(5),
              // ZoomTapAnimation(
              //   onTap: () {
              //     urlLauncher('https://dijlah.org');
              //   },
              //   child: Text.rich(
              //     TextSpan(
              //       children: [
              //         TextSpan(
              //           text: 'Powered by ',
              //           style: TextStyle(
              //             color: Theme.of(context)
              //                 .colorScheme
              //                 .onPrimary
              //                 .withAlpha(100),
              //             fontSize: 13,
              //           ),
              //         ),
              //         TextSpan(
              //           text: 'DIjlah IT',
              //           style: TextStyle(
              //             fontWeight: FontWeight.w700,
              //             color: Theme.of(context)
              //                 .colorScheme
              //                 .onPrimary
              //                 .withAlpha(100),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  ListTile drawerItemWidget({
    required String title,
    required String icon,
    required int tag,
    required int totalItems,
    required Function() onTap,
    required BuildContext context,
  }) {
    bool isLastItem = tag == totalItems - 1;
    return ListTile(
      leading: SvgPicture.asset(
        'assets/svgs/$icon.svg',
        colorFilter: ColorFilter.mode(
          !isLastItem ? Theme.of(context).colorScheme.onPrimary : Colors.red,
          BlendMode.srcIn,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: !isLastItem
              ? Theme.of(context).colorScheme.onPrimary
              : Colors.red,
        ),
      ),
      trailing: !isLastItem
          ? SvgPicture.asset(
              'assets/svgs/angle-left.svg',
              width: 12,
              height: 12,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.onPrimary,
                BlendMode.srcIn,
              ),
            )
          : const SizedBox(),
      onTap: onTap,
    );
  }
}
