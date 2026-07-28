import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/config/functions.dart';
import 'package:inteshar/app/config/status.dart';
import 'package:inteshar/app/core/common/constants/launch_url.dart';
import 'package:inteshar/app/core/common/widgets/offline_widget.dart';
import 'package:inteshar/app/core/common/widgets/retry_widget.dart';
import 'package:inteshar/app/core/routes/routes.dart';
import 'package:inteshar/app/core/utils/custom_loading.dart';
import 'package:inteshar/app/features/home/data/data_source/home_api_provider.dart';
import 'package:inteshar/app/features/home/data/models/home_model.dart';
import 'package:inteshar/app/features/services/view/screens/invoice_page.dart';
import 'package:inteshar/app/features/text_content/view/screen/text_content.dart';

import 'package:inteshar/app/features/home/view/getX/company_slider_controller.dart';
import 'package:inteshar/app/features/home/view/widgets/ad_slider.dart';
import 'package:inteshar/app/features/home/view/widgets/company_list_slider.dart';
import 'package:inteshar/app/features/home/view/widgets/favority_item.dart';
import 'package:inteshar/app/features/home/view/widgets/other_services.dart';
import 'package:inteshar/app/features/home/view/widgets/product_list.dart';
import 'package:inteshar/app/features/home/view/widgets/separator.dart';
import 'package:inteshar/app/features/page_view/view/getX/scaffold_controller.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.scaffoldController,
  });

  final ScaffoldController scaffoldController;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey _favoritesKey = GlobalKey();

  // Function to refresh the home data
  Future<void> _refreshData(HomeApiProvider homeApiProvider) async {
    await homeApiProvider.fetchHomeData();
  }

  void _scrollToFavorites() {
    final context = _favoritesKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildDrawerButtonsRow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonBgColor = isDark
        ? const Color(0xFF333333)
        : const Color.fromARGB(255, 255, 255, 255);
    final iconColor = isDark ? Colors.white70 : const Color(0xFF5C6B73);

    // 6 buttons mapping to drawer features
    final List<Map<String, dynamic>> items = [
      {
        "icon": 'file-user',
        "onTap": () => Get.toNamed(Routes.userOperation),
        "tooltip": 'عمليات المستخدم',
      },
      {
        "icon": 'checklist-task-budget',
        "onTap": () => Get.toNamed(Routes.reportingTopup),
        "tooltip": 'التقارير',
      },
      {
        "icon": 'user',
        "onTap": () => Get.toNamed(Routes.profilePage),
        "tooltip": 'الملف الشخصي',
      },
      {
        "icon": 'terms-info',
        "onTap": () {
          Get.toNamed(Routes.textContent,
              arguments: const TextContent(
                title: 'الشروط والقوانين',
                text: '''
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
''',
              ));
        },
        "tooltip": 'الشروط والقوانين',
      },
      {
        "icon": 'user-headset',
        "onTap": () {
          final updateController = Get.find<HomeApiProvider>();
          if (updateController.homeDataList.isNotEmpty) {
            final user = updateController.homeDataList.first;
            Get.toNamed(Routes.textContent,
                arguments: TextContent(
                  title: 'الدعم الفني',
                  text: user.user?.agent?.supportText ??
                      '''لا تتردد في التواصل مع خدمة الدعم الفني لأي استفسار أو مساعدة، عبر البريد الالكتروني او الاتصال المباشر''',
                ));
          }
        },
        "tooltip": 'الدعم الفني',
      },
      {
        "icon": 'star',
        "tooltip": 'المفضلة',
        "onTap": _scrollToFavorites,
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: items.map((item) {
          return GestureDetector(
            onTap: item['onTap'],
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: buttonBgColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/svgs/${item['icon']}.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    iconColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final ProductsApiProvider productsApiProvider = Get.find(tag: 'random');
    final CompanySliderController companySliderController =
        Get.put(CompanySliderController());
    final HomeApiProvider homeApiProvider = Get.put(HomeApiProvider());
    homeApiProvider.fetchHomeData();

    return Container(
      color: Theme.of(context).colorScheme.primary,
      width: Get.width,
      child: Obx(
        () {
          switch (homeApiProvider.rxRequestStatus.value) {
            case Status.completed:
              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: Get.width,
                    margin: const EdgeInsets.only(top: 180),
                    child: RefreshIndicator(
                      onRefresh: () async {
                        _refreshData(homeApiProvider);
                        companySliderController.activeCompany.value = -1;
                        companySliderController.selected.value = -1;
                        companySliderController.isLoading.value = false;
                      },
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      color: Theme.of(context).colorScheme.secondary,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20)
                              .copyWith(top: 40),
                          child: Column(
                            children: [
                              // const Separator(title: 'خدمات مميزة'),
                              // const OtherServices(),
                              // const Gap(20),
                              AdSlider(homeApiProvider: homeApiProvider),
                              const Gap(10),
                              // Drawer buttons row added here
                              // _buildDrawerButtonsRow(context),
                              // Container(
                              //   margin:
                              //       const EdgeInsets.symmetric(vertical: 15),
                              //   height: 1.5,
                              //   decoration: BoxDecoration(
                              //     gradient: LinearGradient(
                              //       colors: [
                              //         Theme.of(context)
                              //             .colorScheme
                              //             .secondary
                              //             .withValues(alpha: 0.0),
                              //         Theme.of(context)
                              //             .colorScheme
                              //             .secondary
                              //             .withValues(alpha: 0.7),
                              //         Theme.of(context)
                              //             .colorScheme
                              //             .secondary
                              //             .withValues(alpha: 0.0),
                              //       ],
                              //     ),
                              //   ),
                              // ),
                              // CompanyListSlider(
                              //     companyList: homeApiProvider.homeDataList),
                              // const Gap(20),
                              Obx(() {
                                if (companySliderController
                                        .activeCompany.value ==
                                    -1) {
                                  final List<Company> allCompanies = [];
                                  for (var category in homeApiProvider
                                      .homeDataList.first.companyCategories) {
                                    allCompanies.addAll(
                                        List<Company>.from(category.companies));
                                  }
                                  allCompanies.sort((a, b) =>
                                      (a.idShow ?? 0).compareTo(b.idShow ?? 0));

                                  return ProductsList(
                                    products: allCompanies,
                                  );
                                } else {
                                  return ProductsList(
                                    products: homeApiProvider
                                        .homeDataList
                                        .first
                                        .companyCategories[
                                            companySliderController
                                                .selected.value]
                                        .companies,
                                  );
                                }
                              }),
                              const Gap(10),
                              KeyedSubtree(
                                key: _favoritesKey,
                                child: const FavorityItem(),
                              ),
                              const Gap(120),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Constants.isLoggedIn
                      ? Positioned(
                          top: 0,
                          right: 20,
                          left: 20,
                          child: Obx(() {
                            HomeModel? user;
                            if (homeApiProvider.homeDataList.isNotEmpty) {
                              user = homeApiProvider.homeDataList.first;
                            }
                            return Stack(
                              children: [
                                Container(
                                  width: Get.width,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 40)
                                          .copyWith(bottom: 40),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color(0xFF1E1E1E)
                                        : const Color.fromARGB(
                                            255, 231, 231, 231),
                                    // color: Colors.red,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(30)),
                                    // boxShadow: [
                                    //   BoxShadow(
                                    //     color: Colors.black.withOpacity(0.06),
                                    //     blurRadius: 12,
                                    //     offset: const Offset(0, 4),
                                    //   ),
                                    // ],
                                  ),
                                  padding: const EdgeInsets.all(10)
                                      .copyWith(bottom: 30),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // 1. Top bar (RTL visual: Menu RIGHT, Name CENTER, Bell LEFT)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // In RTL: first child = RIGHT visual => Menu/Drawer
                                          GestureDetector(
                                            onTap: () {
                                              if (widget.scaffoldController
                                                  .drawerOpen.value) {
                                                widget.scaffoldController
                                                    .closeDrawer();
                                              } else {
                                                widget.scaffoldController
                                                    .openDrawer();
                                              }
                                            },
                                            child: Container(
                                              width: 44,
                                              height: 44,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? const Color(0xFF2C2C2C)
                                                    : Colors.white,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.06),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              alignment: Alignment.center,
                                              child: SvgPicture.asset(
                                                'assets/svgs/bars-staggered.svg',
                                                colorFilter:
                                                    const ColorFilter.mode(
                                                        Color(0xFFC59B4C),
                                                        BlendMode.srcIn),
                                                width: 22,
                                                height: 22,
                                              ),
                                            ),
                                          ),
                                          // Center: Username Pill
                                          Expanded(
                                            child: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12),
                                              height: 44,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? const Color(0xFF2C2C2C)
                                                    : Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(22),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.06),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                user?.user?.name ?? '',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                      : Colors.black87,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          // In RTL: last child = LEFT visual => Bell/Notification
                                          GestureDetector(
                                            onTap: () {
                                              Get.toNamed(Routes.notifArchive);
                                            },
                                            child: Container(
                                              width: 44,
                                              height: 44,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? const Color(0xFF2C2C2C)
                                                    : Colors.white,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.06),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              alignment: Alignment.center,
                                              child: SvgPicture.asset(
                                                'assets/svgs/bell.svg',
                                                colorFilter:
                                                    const ColorFilter.mode(
                                                        Color(0xFFC59B4C),
                                                        BlendMode.srcIn),
                                                width: 22,
                                                height: 22,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Gap(10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          // Left balanced side containing IQD Badge
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                child: ShaderMask(
                                                  shaderCallback: (bounds) =>
                                                      const LinearGradient(
                                                    colors: [
                                                      Color(0xFFD49E35),
                                                      Color(0xFF8F6317),
                                                    ],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  ).createShader(bounds),
                                                  child: const Text(
                                                    'IQD',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Gap(8),
                                          // Centered Balance text
                                          ShaderMask(
                                            shaderCallback: (bounds) =>
                                                const LinearGradient(
                                              colors: [
                                                Color(0xFFD49E35),
                                                Color(0xFF8F6317),
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ).createShader(bounds),
                                            child: Text(
                                              formatNumber(homeApiProvider
                                                      .inventory.value) ??
                                                  '0',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 32,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                          const Gap(8),
                                          // Right balanced side to keep center aligned
                                          const Expanded(
                                            child: SizedBox(),
                                          ),
                                        ],
                                      ),
                                      const Gap(8),
                                    ],
                                  ),
                                ),
                                // 3. Pill with Stack: logo floats, TOPUP/باقات inside pill
                                Positioned(
                                  left: 15,
                                  right: 15,
                                  bottom: 15,
                                  child: SizedBox(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(27),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // In RTL: first = RIGHT visual => TOPUP
                                          Expanded(
                                            child: Container(
                                              height: 45,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? const Color(0xFF1E1E1E)
                                                    : const Color(0xFFEEF2F6),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(200)),
                                              ),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Get.toNamed(
                                                    Routes.invoicePage,
                                                    arguments:
                                                        const InvoicePage(
                                                            type: 'topup',
                                                            title: 'TOPUP'),
                                                  );
                                                },
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SvgPicture.asset(
                                                      'assets/svgs/point-of-sale-bill.svg',
                                                      width: 20,
                                                      height: 20,
                                                      colorFilter:
                                                          ColorFilter.mode(
                                                        Theme.of(context)
                                                                    .brightness ==
                                                                Brightness.dark
                                                            ? Colors.white
                                                            : Colors.black87,
                                                        BlendMode.srcIn,
                                                      ),
                                                    ),
                                                    const Gap(6),
                                                    Text(
                                                      'TOPUP',
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                                    .brightness ==
                                                                Brightness.dark
                                                            ? Colors.white
                                                            : Colors.black87,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Space for the floating logo
                                          const SizedBox(width: 80),
                                          // In RTL: last = LEFT visual => باقات
                                          Expanded(
                                            child: Container(
                                              height: 45,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? const Color(0xFF1E1E1E)
                                                    : const Color(0xFFEEF2F6),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(200)),
                                              ),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Get.toNamed(Routes
                                                      .internetPackagesPage);
                                                },
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SvgPicture.asset(
                                                      'assets/svgs/box-open.svg',
                                                      width: 20,
                                                      height: 20,
                                                      colorFilter:
                                                          ColorFilter.mode(
                                                        Theme.of(context)
                                                                    .brightness ==
                                                                Brightness.dark
                                                            ? Colors.white70
                                                            : const Color(
                                                                0xFF5C6B73),
                                                        BlendMode.srcIn,
                                                      ),
                                                    ),
                                                    const Gap(6),
                                                    Text(
                                                      'باقات',
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                                    .brightness ==
                                                                Brightness.dark
                                                            ? Colors.white
                                                            : Colors.black87,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // 4. Floating logo circle — overlays pill center
                                Positioned(
                                  bottom: 11,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: ZoomTapAnimation(
                                      onTap: () {
                                        _refreshData(homeApiProvider);
                                        companySliderController
                                            .activeCompany.value = -1;
                                        companySliderController.selected.value =
                                            -1;
                                        companySliderController
                                            .isLoading.value = false;
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: _SpinningLogo(
                                          photoUrl:
                                              user?.user?.agent?.appPhotoUrl,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }))
                      : Positioned(
                          top: 40,
                          right: 20,
                          left: 20,
                          child: const OfflineWidget(),
                        ),
                ],
              );
            case Status.loading:
              return const CustomLoading();
            case Status.error:
              return RetryWidget(
                onTap: () {
                  homeApiProvider.fetchHomeData();
                },
              );
            default:
              return const Text("Unknown state");
          }
        },
      ),
    );
  }
}

/// لوگوی با انیمیشن تپش قلب (Heartbeat)
class _SpinningLogo extends StatefulWidget {
  const _SpinningLogo({this.photoUrl});
  final String? photoUrl;

  @override
  State<_SpinningLogo> createState() => _SpinningLogoState();
}

class _SpinningLogoState extends State<_SpinningLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    // چرخه تپش قلب: 2.5 ثانیه (دو تپش متوالی + مکث کوتاه)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _scale = TweenSequence<double>([
      // تپ اول (بزرگتر)
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 12,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 12,
      ),
      // تپ دوم (کوچکتر)
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.08, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 12,
      ),
      // مکث قبل از چرخه بعدی
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 54,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = widget.photoUrl;
    final bool hasUrl =
        photoUrl != null && photoUrl.isNotEmpty && photoUrl.startsWith('http');

    return RepaintBoundary(
        child: AnimatedBuilder(
      animation: _scale,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          child: child,
        );
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E1E1E)
              : const Color.fromARGB(255, 231, 231, 231),
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipOval(
            child: hasUrl
                ? CachedNetworkImage(
                    fit: BoxFit.contain,
                    imageUrl: photoUrl,
                    placeholder: (context, url) => const CustomLoading(),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/images/logo_cn.png',
                      fit: BoxFit.contain,
                    ),
                  )
                : Image.asset(
                    'assets/images/logo_cn.png',
                    fit: BoxFit.contain,
                  ),
          ),
        ),
      ),
    ));
  }
}
