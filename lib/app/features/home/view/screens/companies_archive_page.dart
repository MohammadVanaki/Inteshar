import 'dart:convert';
import 'dart:ui' as img;

import 'package:auto_height_grid_view/auto_height_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';

import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' hide Image;
import 'package:image/image.dart' as img;
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/config/functions.dart';
import 'package:inteshar/app/config/status.dart';
import 'package:inteshar/app/core/common/widgets/internal_page.dart';
import 'package:inteshar/app/core/extensions/success_color_theme.dart';
import 'package:inteshar/app/core/utils/custom_loading.dart';
import 'package:inteshar/app/features/home/data/data_source/card_price_api.dart';
import 'package:inteshar/app/features/home/data/data_source/home_api_provider.dart';
import 'package:inteshar/app/features/home/data/models/home_model.dart';
import 'package:inteshar/app/features/home/view/getX/favority_controller.dart';
import 'package:inteshar/app/features/home/view/getX/purchase_methods_controller.dart';
import 'package:inteshar/app/features/page_view/view/getX/navigation_controller.dart';
import 'package:inteshar/app/features/purchase_methods/data/data_source/purchase_api_provider.dart';
import 'package:inteshar/app/features/purchase_methods/repositories/methods_manager.dart';
import 'package:inteshar/app/features/purchase_methods/view/getX/print_controller.dart';
import 'package:inteshar/app/features/purchase_methods/view/screens/purchase_methods_item.dart';
import 'package:inteshar/app/features/setting/view/getX/setting_controller.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:http/http.dart' as http;
import 'package:barcode/barcode.dart' as bc;
import 'dart:ui' as ui;
import 'package:screenshot/screenshot.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class CompaniesArchivePage extends StatelessWidget {
  static List<int>? _cachedLogoBytes;
  static List<int>? _cachedAppLogoBytes;
  static final Map<String, List<int>> _cachedCardImages = {};
  static final Map<String, List<int>> _cachedFooters = {};
  static final Map<String, List<int>> _cachedUserNames = {};
  static CapabilityProfile? _cachedProfile;
  static final Map<String, Future<List<int>>> _pendingImages = {};

  static Future<CapabilityProfile> _getProfile() async {
    _cachedProfile ??= await CapabilityProfile.load();
    return _cachedProfile!;
  }

  /// ✅ ساخت بایت ESC/POS از یک تصویر در assets — کش‌شده، CPU only
  static Future<List<int>> _buildAssetImageBytes(
      String assetPath, int width) async {
    if (_cachedAppLogoBytes != null) return _cachedAppLogoBytes!;
    try {
      final byteData = await rootBundle.load(assetPath);
      final Uint8List bytes = byteData.buffer.asUint8List();
      img.Image? image = img.decodeImage(bytes);
      if (image == null) return [];

      // برش و چیدن حاشیه‌های خالی (Auto-crop/trim white margins)
      img.Image cropped = img.copyCrop(
        image,
        x: 0,
        y: 0,
        width: image.width,
        height: image.height,
      );

      // پیدا کردن مرزهای عمودی غیر سفید برای کراپ دقیق‌تر
      int top = 0;
      int bottom = image.height - 1;

      // جستجوی سطر غیر سفید از بالا
      outerTop:
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);
          // اگر پیکسل کاملا سفید نباشد (مثلا درخشندگی زیر 240)
          if (pixel.r < 240 || pixel.g < 240 || pixel.b < 240) {
            top = y;
            break outerTop;
          }
        }
      }

      // جستجوی سطر غیر سفید از پایین
      outerBottom:
      for (int y = image.height - 1; y >= top; y--) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);
          if (pixel.r < 240 || pixel.g < 240 || pixel.b < 240) {
            bottom = y;
            break outerBottom;
          }
        }
      }

      // انجام کراپ در صورت لزوم
      if (top < bottom) {
        cropped = img.copyCrop(
          image,
          x: 0,
          y: top,
          width: image.width,
          height: (bottom - top + 1),
        );
      }

      img.Image resized = img.copyResize(cropped, width: width);
      img.Image grayscale = img.grayscale(resized);
      final profile = await _getProfile();
      final generator = Generator(PaperSize.mm58, profile);
      final result = generator.image(grayscale);
      _cachedAppLogoBytes = result;
      return result;
    } catch (e) {
      print('Error loading asset image: $e');
      return [];
    }
  }

  const CompaniesArchivePage({
    super.key,
    required this.companyList,
  });
  final List<CardCategory> companyList;
  @override
  Widget build(BuildContext context) {
    // final CompanyArchiveController companyArchiveController =
    //     Get.put(CompanyArchiveController());
    final navigationController = Get.find<BottmNavigationController>();

    final TextEditingController countController =
        TextEditingController(text: '0');
    final FavorityController favorityController = Get.put(FavorityController());
    final SettingController settingController = Get.put(SettingController());
    final BluetoothController bluetoothController =
        Get.put(BluetoothController());

    final HomeApiProvider homeApiProvider = Get.find<HomeApiProvider>();
    final int? companyId =
        companyList.isNotEmpty ? companyList.first.companyId : null;

    List<CardCategory> dynamicCategories() {
      if (companyId == null) return companyList;
      return homeApiProvider.homeDataList.firstOrNull?.cardCategories
              ?.where((card) => card.companyId == companyId)
              .toList() ??
          companyList;
    }

    String cardPricestr = '';
    return InternalPage(
      disconnect: false,
      title:
          companyList.isNotEmpty ? (companyList.first.companyTitle ?? '') : '',
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: Constants.intesharBoxDecoration(context).copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
        child: Column(
          children: [
            // Directionality(
            //   textDirection: TextDirection.ltr,
            //   child: TextField(
            //     controller: companyArchiveController.searchController,
            //     autofocus: false,
            //     decoration: InputDecoration(
            //       labelText: 'search',
            //       suffixIcon: Padding(
            //         padding: const EdgeInsets.all(10.0),
            //         child: RotatedBox(
            //           quarterTurns: 1,
            //           child: SvgPicture.asset(
            //             'assets/svgs/search.svg',
            //             colorFilter: ColorFilter.mode(
            //               Theme.of(context).colorScheme.primary,
            //               BlendMode.srcIn,
            //             ),
            //           ),
            //         ),
            //       ),
            //       border: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(8.0),
            //       ),
            //     ),
            //   ),
            // ),
            const Gap(10),
            Expanded(
              child: LiquidPullToRefresh(
                  onRefresh: () async {
                    await homeApiProvider.fetchHomeData();
                  },
                  showChildOpacityTransition: false,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  springAnimationDurationInMilliseconds: 350,
                  color: Colors.white,
                  child: Obx(() {
                    final currentList = dynamicCategories();
                    return AutoHeightGridView(
                      itemCount: currentList.length,
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      shrinkWrap: true,
                      builder: (context, index) {
                        final company = currentList[index];
                        CardPriceApi cardPriceApi =
                            Get.put(CardPriceApi(), tag: index.toString());
                        return ZoomTapAnimation(
                          onTap: () async {
                            await cardPriceApi.fetchCardPrice(
                              cardId: company.id.toString(),
                            );
                            if (cardPriceApi.cardPriceData.isNotEmpty) {
                              cardPricestr = cardPriceApi
                                  .cardPriceData.first.cardPrice
                                  .toString();
                              showModalBottomSheet(
                                isScrollControlled: true,
                                showDragHandle: true,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                context: context,
                                builder: (context) {
                                  PurchaseApiProvider purchaseApiProvider =
                                      Get.put(PurchaseApiProvider());
                                  PurchaseMethodsController
                                      purchaseMethodsController = Get.put(
                                          PurchaseMethodsController(),
                                          tag: 'single');
                                  cardPriceApi.cardPriceData.first.cardType ==
                                          'charge'
                                      ? purchaseMethodsController
                                          .hasGlobalCard.value = true
                                      : false;
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context)
                                          .viewInsets
                                          .bottom,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      width: double.infinity,
                                      alignment: Alignment.topCenter,
                                      height: Get.height * .87,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            Container(
                                              height: 160,
                                              clipBehavior: Clip.antiAlias,
                                              decoration: Constants
                                                  .intesharBoxDecoration(
                                                      context),
                                              child: Center(
                                                child: CachedNetworkImage(
                                                  fit: BoxFit.fill,
                                                  height: 160,
                                                  width: double.infinity,
                                                  imageUrl:
                                                      company.photoUrl ?? '',
                                                  placeholder: (context, url) =>
                                                      SizedBox(
                                                    height: 160,
                                                    width: 160,
                                                    child:
                                                        const CustomLoading(),
                                                  ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Image.asset(
                                                    'assets/images/not.jpg',
                                                    fit: BoxFit.fill,
                                                    height: 160,
                                                    width: double.infinity,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const Gap(20),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text.rich(
                                                      TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text: 'الشركة: ',
                                                            style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onPrimary,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: company.title,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onPrimary,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Obx(() {
                                                      bool isFav =
                                                          favorityController
                                                              .isFavorite(
                                                                  company.id!);
                                                      return ZoomTapAnimation(
                                                        onTap: () =>
                                                            favorityController
                                                                .toggleFavorite(
                                                                    companyList[
                                                                        index]),
                                                        child: SvgPicture.asset(
                                                          isFav
                                                              ? 'assets/svgs/star_filled.svg'
                                                              : 'assets/svgs/star.svg',
                                                          width: 25,
                                                          height: 25,
                                                        ),
                                                      );
                                                    }),
                                                  ],
                                                ),
                                                const Gap(10),
                                                Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: 'الفئة: ',
                                                        style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onPrimary,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: company.title,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onPrimary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const Gap(10),
                                                Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: 'السعر: ',
                                                        style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onPrimary,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            '${formatNumber(int.parse(cardPricestr))} IQD',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onPrimary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const Gap(10),
                                                StatefulBuilder(
                                                  builder: (context, setState) {
                                                    final int currentVal =
                                                        int.tryParse(
                                                                countController
                                                                    .text) ??
                                                            0;
                                                    return Row(
                                                      children: [
                                                        Text(
                                                          'العدد:',
                                                          style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onPrimary,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                        const Gap(15),
                                                        // دکمه منفی حجم‌دار
                                                        ZoomTapAnimation(
                                                          onTap: currentVal > 0
                                                              ? () {
                                                                  setState(() {
                                                                    countController
                                                                        .text = (currentVal -
                                                                            1)
                                                                        .toString();
                                                                  });
                                                                }
                                                              : null,
                                                          child: Container(
                                                            width: 44,
                                                            height: 44,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onPrimary
                                                                  .withAlpha(
                                                                      currentVal >
                                                                              0
                                                                          ? 40
                                                                          : 15),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                              boxShadow:
                                                                  currentVal > 0
                                                                      ? [
                                                                          BoxShadow(
                                                                            color:
                                                                                Colors.black.withOpacity(0.15),
                                                                            blurRadius:
                                                                                6,
                                                                            offset:
                                                                                const Offset(0, 3),
                                                                          )
                                                                        ]
                                                                      : null,
                                                            ),
                                                            child: Icon(
                                                              Icons.remove,
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onPrimary
                                                                  .withOpacity(
                                                                      currentVal >
                                                                              0
                                                                          ? 1.0
                                                                          : 0.4),
                                                              size: 22,
                                                            ),
                                                          ),
                                                        ),
                                                        // نمایش دهنده عدد در وسط
                                                        SizedBox(
                                                          width: 50,
                                                          child: Center(
                                                            child: Text(
                                                              currentVal
                                                                  .toString(),
                                                              style: TextStyle(
                                                                color: currentVal ==
                                                                        0
                                                                    ? Colors.red
                                                                    : Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onPrimary,
                                                                fontSize: 22,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        // دکمه مثبت حجم‌دار
                                                        ZoomTapAnimation(
                                                          onTap: () {
                                                            setState(() {
                                                              countController
                                                                      .text =
                                                                  (currentVal +
                                                                          1)
                                                                      .toString();
                                                            });
                                                          },
                                                          child: Container(
                                                            width: 44,
                                                            height: 44,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onPrimary
                                                                  .withAlpha(
                                                                      40),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                          0.15),
                                                                  blurRadius: 6,
                                                                  offset:
                                                                      const Offset(
                                                                          0, 3),
                                                                )
                                                              ],
                                                            ),
                                                            child: Icon(
                                                              Icons.add,
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onPrimary,
                                                              size: 22,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                            const Gap(20),
                                            const Align(
                                              alignment: Alignment.topRight,
                                              child: Text('الاجراء: '),
                                            ),
                                            const Gap(10),
                                            const PurchaseMethodsItem(
                                              scale: 70,
                                              tag: 'single',
                                            ),
                                            Obx(() {
                                              return (purchaseMethodsController
                                                          .purchaseMethodsSelected
                                                          .value !=
                                                      -1)
                                                  ? Container(
                                                      margin:
                                                          const EdgeInsets.all(
                                                              2),
                                                      child: Column(
                                                        children: [
                                                          SizedBox(
                                                            width:
                                                                double.infinity,
                                                            child: Obx(
                                                              () => purchaseApiProvider
                                                                      .isProcessing
                                                                      .value
                                                                  ? (purchaseApiProvider
                                                                              .totalPrintCount
                                                                              .value >
                                                                          0
                                                                      ? Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            CustomLoading(
                                                                              color: Theme.of(context).colorScheme.secondary,
                                                                            ),
                                                                            const Gap(8),
                                                                            Text(
                                                                              "جاري طباعة الكارت ${purchaseApiProvider.currentPrintCount.value} من ${purchaseApiProvider.totalPrintCount.value} ...",
                                                                              style: TextStyle(
                                                                                color: Theme.of(context).colorScheme.onPrimary,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )
                                                                      : Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            CustomLoading(
                                                                              color: Theme.of(context).colorScheme.secondary,
                                                                            ),
                                                                            const Gap(8),
                                                                            Text(
                                                                              "جاري معالجة الطلب وشراء الكروت...",
                                                                              style: TextStyle(
                                                                                color: Theme.of(context).colorScheme.onPrimary,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ))
                                                                  : ElevatedButton(
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        backgroundColor: purchaseApiProvider.isProcessing.value
                                                                            ? Colors.grey
                                                                            : Theme.of(context).extension<SuccessColorTheme>()?.successColor,
                                                                        disabledBackgroundColor:
                                                                            Colors.grey,
                                                                      ),
                                                                      onPressed: purchaseApiProvider
                                                                              .isProcessing
                                                                              .value
                                                                          ? null
                                                                          : () {
                                                                              if (purchaseApiProvider.isProcessing.value) {
                                                                                return;
                                                                              }
                                                                              if (countController.text == '' || countController.text == '0') {
                                                                                if (!Get.isSnackbarOpen) {
                                                                                  Get.snackbar('تنبيه', 'يرجى تحديد العدد المطلوب', backgroundColor: Colors.red.withOpacity(0.2));
                                                                                }
                                                                              } else {
                                                                                purchaseApiProvider.isProcessing.value = true;

                                                                                // پیش-بارگذاری تصاویر در بکگراوند همزمان با درخواست API
                                                                                final userProvider0 = Get.find<HomeApiProvider>();
                                                                                if (userProvider0.homeDataList.isNotEmpty) {
                                                                                  final logoUrl = userProvider0.homeDataList.first.user?.agent?.appPhotoUrl ?? '';
                                                                                  final cardPhotoUrl = company.photoUrl ?? '';
                                                                                  // fire-and-forget — بدون await
                                                                                  buildNetworkImage(logoUrl, 220).ignore();
                                                                                  if (settingController.settings["nonPreview_printCardImage"] ?? false) {
                                                                                    buildNetworkImage(cardPhotoUrl, 200).ignore();
                                                                                  }
                                                                                }

                                                                                purchaseApiProvider
                                                                                    .fetchPurchase(
                                                                                  counter: countController.text,
                                                                                  type: 'print',
                                                                                  cardId: company.id.toString(),
                                                                                )
                                                                                    .then((isSuccessful) async {
                                                                                  try {
                                                                                    if (isSuccessful) {
                                                                                      print('____________________${settingController.isPreviewEnabled.value}');
                                                                                      print('____________________${purchaseMethodsController.purchaseMethodsSelected.value}');

                                                                                      if (purchaseMethodsController.purchaseMethodsSelected.value != 0) {
                                                                                        Navigator.pop(context);

                                                                                        manageMethods(
                                                                                          type: purchaseMethodsController.purchaseMethodsSelected.value,
                                                                                          serials: purchaseApiProvider.purchaseDataList.first.serials,
                                                                                          cardTitle: purchaseApiProvider.purchaseDataList.first.cardTitle ?? '',
                                                                                          photoUrl: purchaseApiProvider.purchaseDataList.first.cardCategory?.photoUrl ?? '',
                                                                                          ussdCodes: purchaseApiProvider.purchaseDataList.first.ussdCodes ?? [],
                                                                                          printDate: purchaseApiProvider.purchaseDataList.first.printDate.toString(),
                                                                                          title: purchaseApiProvider.purchaseDataList.first.companyTitle ?? '',
                                                                                          footer: purchaseApiProvider.purchaseDataList.first.cardDetails2?.cardFooter ?? '',
                                                                                          isReported: false,
                                                                                          cardId: purchaseApiProvider.purchaseDataList.first.cardCategory?.id?.toString() ?? '',
                                                                                        );
                                                                                      } else if (settingController.isPreviewEnabled.value && purchaseMethodsController.purchaseMethodsSelected.value == 0) {
                                                                                        manageMethods(
                                                                                          type: purchaseMethodsController.purchaseMethodsSelected.value,
                                                                                          serials: purchaseApiProvider.purchaseDataList.first.serials,
                                                                                          cardTitle: purchaseApiProvider.purchaseDataList.first.cardTitle ?? '',
                                                                                          photoUrl: purchaseApiProvider.purchaseDataList.first.cardCategory?.photoUrl ?? '',
                                                                                          ussdCodes: purchaseApiProvider.purchaseDataList.first.ussdCodes ?? [],
                                                                                          printDate: purchaseApiProvider.purchaseDataList.first.printDate.toString(),
                                                                                          title: purchaseApiProvider.purchaseDataList.first.companyTitle ?? '',
                                                                                          footer: purchaseApiProvider.purchaseDataList.first.cardDetails2?.cardFooter ?? '',
                                                                                          isReported: false,
                                                                                          cardId: purchaseApiProvider.purchaseDataList.first.cardCategory?.id?.toString() ?? '',
                                                                                        );
                                                                                      } else {
                                                                                        bool isConnected = await PrintBluetoothThermal.connectionStatus;

                                                                                        if (!isConnected) {
                                                                                          Get.dialog(
                                                                                            AlertDialog(
                                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                                                              backgroundColor: Theme.of(context).colorScheme.surface,
                                                                                              title: const Text("خطأ في الاتصال", style: TextStyle(fontWeight: FontWeight.bold)),
                                                                                              content: const Text("لم يتم الاتصال بالطابعة، هل تريد الانتقال إلى صفحة الاعدادات؟"),
                                                                                              actions: [
                                                                                                TextButton(onPressed: () => Get.back(), child: const Text("إلغاء")),
                                                                                                ElevatedButton(
                                                                                                  onPressed: () {
                                                                                                    Get.back();
                                                                                                    Get.toNamed("/printerSettings");
                                                                                                    navigationController.goToPage(2);
                                                                                                  },
                                                                                                  child: const Text("إعدادات"),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          );
                                                                                          return;
                                                                                        }

                                                                                        final userProvider = Get.find<HomeApiProvider>();
                                                                                        final user = userProvider.homeDataList.first;
                                                                                        final purchaseData = purchaseApiProvider.purchaseDataList.first;
                                                                                        final serials = purchaseData.serials;

                                                                                        if (serials != null && serials.isNotEmpty) {
                                                                                          const CustomLoading();

                                                                                          try {
                                                                                            final sw = Stopwatch()..start();

                                                                                            // ساخت بایت‌های مربوط به عکس‌ها به صورت موازی (GPU-bound و تنها یک‌بار)
                                                                                            final results = await Future.wait([
                                                                                              _buildAssetImageBytes('assets/images/logo-print.jpg', 80),
                                                                                              buildNetworkImage(user.user?.agent?.appPhotoUrl ?? '', 220),
                                                                                              (settingController.settings["nonPreview_printCardImage"] ?? false) ? buildNetworkImage(purchaseData.cardCategory?.photoUrl ?? '', 200) : Future.value(<int>[]),
                                                                                            ]);
                                                                                            print('[PRINT-TIMING] images: ${sw.elapsedMilliseconds}ms');

                                                                                            final List<int> appLogoBytes = results[0];
                                                                                            final List<int> logoBytes = results[1];
                                                                                            final List<int> cardImageBytes = results[2];

                                                                                            // بارکد (GPU-bound، یک‌بار)
                                                                                            final List<int> barcodeBytes = (settingController.settings["nonPreview_printBarCode"] ?? false) ? await buildBarcode93('00964${purchaseData.cardCategory?.id?.toString() ?? ''}') : const <int>[];

                                                                                            print('[PRINT-TIMING] barcode: ${sw.elapsedMilliseconds}ms');

                                                                                            // بخش‌های استاتیک متنی — با ESC/POS خام، بدون GPU، فوری
                                                                                            final userName = user.user?.name ?? '';
                                                                                            final bool hasNonAscii = userName.codeUnits.any((unit) => unit > 127);

                                                                                            // اگر اسم فارسی/عربی است به صورت تصویر رندر می‌شود تا علامت سوال نشود
                                                                                            final List<int> userNameBytes;
                                                                                            if (hasNonAscii) {
                                                                                              if (_cachedUserNames.containsKey(userName)) {
                                                                                                userNameBytes = _cachedUserNames[userName]!;
                                                                                              } else {
                                                                                                userNameBytes = await _buildCodeImageWithBorder(userName, width: 220, drawBorder: false, isBold: true);
                                                                                                _cachedUserNames[userName] = userNameBytes;
                                                                                              }
                                                                                            } else {
                                                                                              userNameBytes = _buildRawTextBytes('====[ $userName ]====', bold: true);
                                                                                            }

                                                                                            // تبدیل نام نماینده (فروشگاه) به عکس در صورت عربی/فارسی بودن
                                                                                            final agentName = user.user?.agent?.name ?? '';
                                                                                            final List<int> agentNameBytes;
                                                                                            if (agentName.isNotEmpty) {
                                                                                              final bool hasNonAsciiAgent = agentName.codeUnits.any((unit) => unit > 127);
                                                                                              if (hasNonAsciiAgent) {
                                                                                                if (_cachedUserNames.containsKey(agentName)) {
                                                                                                  agentNameBytes = _cachedUserNames[agentName]!;
                                                                                                } else {
                                                                                                  agentNameBytes = await _buildCodeImageWithBorder(agentName, width: 220, drawBorder: false, isBold: true);
                                                                                                  _cachedUserNames[agentName] = agentNameBytes;
                                                                                                }
                                                                                              } else {
                                                                                                agentNameBytes = _buildRawTextBytes(agentName, bold: true);
                                                                                              }
                                                                                            } else {
                                                                                              agentNameBytes = [];
                                                                                            }

                                                                                            final List<int> headerStaticBytes = [
                                                                                              ...appLogoBytes,
                                                                                              ...agentNameBytes,
                                                                                              ...userNameBytes,
                                                                                              ..._buildRawTextBytes('========================'),
                                                                                              ..._buildRawTextBytes('Terminal ID: ${user.user?.id ?? ''}', align: 0),
                                                                                              ..._buildRawTextBytes('Time: ${purchaseData.printDate}', align: 0),
                                                                                            ];

                                                                                            final List<int> cardTitleBytes = _buildRawTextBytes(purchaseData.cardTitle ?? '', bold: true, align: 1);

                                                                                            final String htmlFooter = purchaseData.cardDetails2?.cardFooter ?? '';
                                                                                            final List<int> cardFooterBytes = (settingController.settings["nonPreview_printInformation"] ?? false) ? await buildHtmlImage(htmlFooter, 256) : const <int>[];

                                                                                            purchaseApiProvider.totalPrintCount.value = serials.length;

                                                                                            // حلقه کاملاً ترتیبی: ساخت→چاپ فوری برای هر کارت، بدون انتظار برای کارت‌های بعدی
                                                                                            for (int i = 0; i < serials.length; i++) {
                                                                                              purchaseApiProvider.currentPrintCount.value = i + 1;
                                                                                              final serial = serials[i];

                                                                                              // ساخت تصویر کد با بوردر (Canvas-based، یک خط، دارای کادر)
                                                                                              final List<int> codeBytes;
                                                                                              if (serial.code != null && serial.code != '') {
                                                                                                codeBytes = await _buildCodeImageWithBorder(serial.code ?? '', drawBorder: true, isBold: true);
                                                                                              } else {
                                                                                                codeBytes = [
                                                                                                  ..._buildRawTextBytes(serial.code1 ?? ''),
                                                                                                  ...await _buildCodeImageWithBorder(serial.code2 ?? '', drawBorder: true, isBold: true),
                                                                                                  if (serial.code3 != null && serial.code3!.isNotEmpty) ..._buildRawTextBytes(serial.code3 ?? ''),
                                                                                                  ..._buildRawTextBytes(serial.code4 ?? ''),
                                                                                                ];
                                                                                              }
                                                                                              print('serial.code: ${serial.code}');
                                                                                              print('serial.code1: ${serial.code1}');
                                                                                              print('serial.code2: ${serial.code2}');
                                                                                              print('serial.code3: ${serial.code3}');
                                                                                              print('serial.code4: ${serial.code4}');

                                                                                              // ساخت بایت‌های کارت جاری
                                                                                              final List<int> ticketBytes = [
                                                                                                ...logoBytes,
                                                                                                ...headerStaticBytes,
                                                                                                ..._buildRawTextBytes('Order Number: ${serial.id ?? ''}', align: 0),
                                                                                                ..._buildRawTextBytes('Expiry: ${serial.expiredDate ?? serial.code3 ?? ''}', align: 0),
                                                                                                ...cardImageBytes,
                                                                                                ...cardTitleBytes,
                                                                                                ..._buildRawTextBytes('Serial: ${serial.serial ?? ''}', align: 0),
                                                                                                ...codeBytes,
                                                                                                10,
                                                                                                //  10,
                                                                                                ...barcodeBytes,
                                                                                                // 10,
                                                                                              ];

                                                                                              // ساخت بایت‌های نهایی شامل QR کد و فوتر
                                                                                              final List<int> finalBytes = [
                                                                                                ...ticketBytes,
                                                                                              ];
                                                                                              if ((settingController.settings["nonPreview_printQrcode"] ?? false) && serial.code != null && serial.code != '' && (purchaseData.ussdCodes != null) && (i < purchaseData.ussdCodes!.length) && (purchaseData.ussdCodes![i].code != null)) {
                                                                                                final qrBytes = await buildQRCode("tel:${purchaseData.ussdCodes![i].code}", size: 100);
                                                                                                finalBytes.addAll([
                                                                                                  0x1B,
                                                                                                  0x61,
                                                                                                  0x01,
                                                                                                  ...qrBytes
                                                                                                ]);
                                                                                              }

                                                                                              // اضافه کردن فوتر در انتهای کارت
                                                                                              if (cardFooterBytes.isNotEmpty) {
                                                                                                finalBytes.addAll([
                                                                                                  // 10,
                                                                                                  ...cardFooterBytes
                                                                                                ]);
                                                                                              }

                                                                                              // خط پایان و برش فیزیکی
                                                                                              finalBytes.addAll([
                                                                                                ..._buildRawTextBytes('----------------------------'),
                                                                                              ]);

                                                                                              // چاپ بلافاصله — بدون انتظار برای کارت‌های بعدی
                                                                                              print('[PRINT-TIMING] sending card ${i + 1} bytes=${finalBytes.length} at ${sw.elapsedMilliseconds}ms');
                                                                                              await PrintBluetoothThermal.writeBytes(finalBytes);
                                                                                              print('[PRINT-TIMING] writeBytes done for card ${i + 1} at ${sw.elapsedMilliseconds}ms');

                                                                                              // تأخیر کوتاه بین کارت‌ها فقط برای فاصله فیزیکی کاغذ
                                                                                              if (i < serials.length - 1) {
                                                                                                await Future.delayed(const Duration(milliseconds: 500));
                                                                                              }
                                                                                            }
                                                                                          } catch (e) {
                                                                                            print("Error in printing: $e");
                                                                                          } finally {
                                                                                            purchaseApiProvider.totalPrintCount.value = 0;
                                                                                            purchaseApiProvider.currentPrintCount.value = 0;
                                                                                          }
                                                                                        }
                                                                                        Get.back();
                                                                                      }
                                                                                    }
                                                                                  } finally {
                                                                                    purchaseApiProvider.isProcessing.value = false;
                                                                                  }
                                                                                }).catchError((error) {
                                                                                  purchaseApiProvider.isProcessing.value = false;
                                                                                });
                                                                              }
                                                                            },
                                                                      child: purchaseApiProvider
                                                                              .isProcessing
                                                                              .value
                                                                          ? CustomLoading(
                                                                              color: Theme.of(context).colorScheme.onPrimary,
                                                                            )
                                                                          : Obx(
                                                                              () {
                                                                                switch (purchaseApiProvider.rxRequestStatus.value) {
                                                                                  case Status.completed:
                                                                                    return const Text('تأكيد');
                                                                                  case Status.error:
                                                                                    return Text(
                                                                                      purchaseApiProvider.errorMessage.value,
                                                                                      style: TextStyle(
                                                                                        color: Theme.of(context).colorScheme.error,
                                                                                      ),
                                                                                    );
                                                                                  case Status.loading:
                                                                                    return CustomLoading(
                                                                                      color: Theme.of(context).colorScheme.onPrimary,
                                                                                    );
                                                                                  case Status.initial:
                                                                                    return Text(
                                                                                      'تأكيد',
                                                                                      style: TextStyle(
                                                                                        color: Theme.of(context).extension<SuccessColorTheme>()?.onSuccessColor,
                                                                                      ),
                                                                                    );
                                                                                }
                                                                              },
                                                                            ),
                                                                    ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  : const SizedBox();
                                            }),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ).whenComplete(() {
                                countController.text = '0';
                                Get.delete<PurchaseApiProvider>();
                                Get.delete<PurchaseMethodsController>(
                                    tag: 'single');
                              });
                            }

                            // cardPriceApi
                            //     .fetchCardPrice(
                            //         cardId: company.id.toString())
                            //     .then(
                            //   (_) {
                            //     cardPricestr = cardPriceApi
                            //         .cardPriceData.first.cardPrice
                            //         .toString();
                            //   },
                            // );
                          },
                          child: Stack(
                            children: [
                              Container(
                                clipBehavior: Clip.antiAlias,
                                decoration:
                                    Constants.intesharBoxDecoration(context)
                                        .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                child: Column(
                                  children: [
                                    Container(
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                            color: Colors.black.withOpacity(.2),
                                            blurRadius: 5,
                                            offset: const Offset(0, 2),
                                          )
                                        ],
                                        borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(30),
                                            bottomRight: Radius.circular(30)),
                                      ),
                                      child: CachedNetworkImage(
                                        fit: BoxFit.fill,
                                        height: 140,
                                        imageUrl: company.photoUrl ?? '',
                                        placeholder: (context, url) => SizedBox(
                                          height: 160,
                                          width: 160,
                                          child: const CustomLoading(),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Image.asset(
                                          'assets/images/not.jpg',
                                          fit: BoxFit.fill,
                                          height: 160,
                                          width: 160,
                                        ),
                                      ),
                                    ),
                                    const Gap(10),
                                    Text(
                                      company.title ?? '',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                    const Gap(10),
                                  ],
                                ),
                              ),
                              Obx(
                                () => Visibility(
                                  visible: cardPriceApi.rxRequestStatus.value ==
                                          Status.loading
                                      ? true
                                      : false,
                                  child: Container(
                                    width: double.infinity,
                                    height: 180,
                                    decoration: BoxDecoration(
                                      color: Colors.black26,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const CustomLoading(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  })),
            ),
            const Gap(10),
          ],
        ),
      ),
    );
  }

  /// ✅ ساخت بایت‌های ESC/POS خام برای یک خط متن ASCII — بدون GPU، بدون Canvas، فوری
  List<int> _buildRawTextBytes(String text,
      {bool bold = false,
      bool doubleHeight = false,
      bool doubleWidth = false,
      int align = 1}) {
    final List<int> bytes = [];
    // Alignment: 0 = left, 1 = center, 2 = right
    bytes.addAll([0x1B, 0x61, align]);
    // Bold on/off
    bytes.addAll([0x1B, 0x45, bold ? 0x01 : 0x00]);
    // Double height + width
    if (doubleHeight || doubleWidth) {
      int mode = 0;
      if (doubleHeight) mode |= 0x10;
      if (doubleWidth) mode |= 0x20;
      bytes.addAll([0x1D, 0x21, mode]);
    }
    // Convert tabs to spaces and clean up special spaces
    final String processedText = text
        .replaceAll('\t', '    ') // Replace tab with 4 spaces
        .replaceAll(RegExp(r'[\u00a0\u2000-\u200a\u202f\u205f\u3000]'),
            ' '); // Replace special spaces

    // Text content
    bytes.addAll(
        latin1.encode(processedText.replaceAll(RegExp(r'[^\x20-\x7E]'), '?')));
    bytes.add(0x0A); // newline
    // Reset size and bold
    bytes.addAll([0x1D, 0x21, 0x00]);
    bytes.addAll([0x1B, 0x45, 0x00]);
    return bytes;
  }

  /// ✅ ساخت تصویر کد با کادر گرد — Canvas، یک خط تضمینی، بوردر واقعی
  Future<List<int>> _buildCodeImageWithBorder(String code,
      {int width = 384, bool drawBorder = true, bool isBold = true}) async {
    if (code.isEmpty) return [];

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // کوچک‌کردن خودکار فونت تا متن در یک خط جا بشه
    const double maxFont = 30;
    const double minFont = 10;
    final double availableW = (width - 32).toDouble();
    double fontSize = maxFont;
    late TextPainter tp;

    final String cleanCode = code.replaceAll('-', '\u2011');

    while (fontSize >= minFont) {
      tp = TextPainter(
        text: TextSpan(
          text: cleanCode,
          style: TextStyle(
            color: Colors.black,
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.normal,
            letterSpacing: drawBorder ? 1.0 : 0.5,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        maxLines: 1,
      );
      tp.layout(
          maxWidth: double.infinity); // اندازه‌گیری طول واقعی بدون شکستن خط
      if (tp.width <= availableW) {
        tp.layout(
            maxWidth: availableW); // پس از پیدا شدن سایز مناسب، چیدمان نهایی
        break;
      }

      fontSize -= 2;
    }

    const double padV = 12;
    const double padH = 10;
    final double totalH = tp.height + padV * 2;
    final double totalW = width.toDouble();

    // زمینه سفید
    canvas.drawRect(
      Rect.fromLTWH(0, 0, totalW, totalH),
      Paint()..color = Colors.white,
    );

    if (drawBorder) {
      // کادر گرد ضخیم‌تر و شکیل‌تر
      final borderPaint = Paint()
        ..color = const ui.Color(0xFF000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(padH, 2, totalW - padH * 2, totalH - 4),
          const Radius.circular(8),
        ),
        borderPaint,
      );
    }

    // متن وسط‌چین
    final dx = (totalW - tp.width) / 2;
    tp.paint(canvas, Offset(dx, padV));

    final picture = recorder.endRecording();
    final imgUi = await picture.toImage(width, totalH.toInt());
    final byteData = await imgUi.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return [];
    return _convertRgbaToRasterBytes(
        byteData.buffer.asUint8List(), width, totalH.toInt());
  }

  /// ✅ تبدیل سریع پیکسل‌های RGBA به بایت‌های پرینتر حرارتی با استفاده از دستور استاندارد GS v 0
  List<int> _convertRgbaToRasterBytes(
      Uint8List rgbaBytes, int width, int height) {
    final List<int> bytes = [];
    final int widthBytes = (width + 7) ~/ 8;
    final int xL = widthBytes % 256;
    final int xH = widthBytes ~/ 256;
    final int yL = height % 256;
    final int yH = height ~/ 256;

    // دستور پرینت تصویر به صورت Raster: GS v 0 0 xL xH yL yH
    bytes.addAll([29, 118, 48, 0, xL, xH, yL, yH]);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < widthBytes * 8; x += 8) {
        int byteVal = 0;
        for (int bit = 0; bit < 8; bit++) {
          final int px = x + bit;
          if (px < width) {
            final int idx = (y * width + px) * 4;
            if (idx + 3 < rgbaBytes.length) {
              final int r = rgbaBytes[idx];
              final int g = rgbaBytes[idx + 1];
              final int b = rgbaBytes[idx + 2];
              final int a = rgbaBytes[idx + 3];

              // اگر پیکسل شفاف باشد، آن را سفید فرض می‌کنیم
              if (a > 127) {
                // محاسبه درخشندگی برای سیاه یا سفید کردن پیکسل
                final int luminance =
                    (r * 0.299 + g * 0.587 + b * 0.114).round();
                if (luminance < 128) {
                  byteVal |= (128 >> bit);
                }
              }
            }
          }
        }
        bytes.add(byteVal);
      }
    }
    return bytes;
  }

  /// ✅ ساخت بایت بارکد Code93
  Future<List<int>> buildBarcode93(String cardId,
      {int width = 300, int height = 80}) async {
    final barcode = bc.Barcode.code93();
    final svgString = barcode.toSvg(cardId,
        width: width.toDouble(), height: height.toDouble());

    final pictureInfo = await vg.loadPicture(SvgStringLoader(svgString), null);
    final uiImage = await pictureInfo.picture.toImage(width, height);
    final byteData =
        await uiImage.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return [];
    return _convertRgbaToRasterBytes(
        byteData.buffer.asUint8List(), width, height);
  }

  /// ✅ ساخت بایت از عکس اینترنتی
  Future<List<int>> buildNetworkImage(String url, int width) async {
    if (url.isEmpty) return [];

    // بررسی کش
    if (width == 220 && _cachedLogoBytes != null) {
      return _cachedLogoBytes!;
    }
    final cacheKey = '$url-$width';
    if (_cachedCardImages.containsKey(cacheKey)) {
      return _cachedCardImages[cacheKey]!;
    }

    // جلوگیری از درخواست‌های تکراری همزمان برای یک تصویر
    if (_pendingImages.containsKey(cacheKey)) {
      return _pendingImages[cacheKey]!;
    }

    final future = _fetchAndProcessImage(url, width, cacheKey);
    _pendingImages[cacheKey] = future;
    try {
      return await future;
    } finally {
      _pendingImages.remove(cacheKey);
    }
  }

  Future<List<int>> _fetchAndProcessImage(
      String url, int width, String cacheKey) async {
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      final Uint8List bytes = response.bodyBytes;

      img.Image? image = img.decodeImage(bytes);
      if (image == null) return [];

      img.Image resized = img.copyResize(image, width: width);
      img.Image grayscale = img.grayscale(resized);

      final profile = await _getProfile();
      final generator = Generator(PaperSize.mm58, profile);
      final result = generator.image(grayscale);

      if (width == 220) {
        _cachedLogoBytes = result;
      } else {
        _cachedCardImages[cacheKey] = result;
      }
      return result;
    } catch (e) {
      print("Error loading network image: $e");
      return [];
    }
  }

  /// ✅ ساخت بایت متن فارسی
  Future<List<int>> buildPersianText(List<Map<String, dynamic>> lines,
      {int width = 384}) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    double yOffset = 0.0;

    for (var line in lines) {
      final text = line["text"] ?? "";
      final bold = line["bold"] ?? false;
      final fontSize = line["fontSize"] ?? 26;
      final drawBorder = line["border"] ?? false;

      final textStyle = TextStyle(
        color: Colors.black,
        fontSize: fontSize.toDouble(),
        fontFamily: 'dijlah',
        fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
      );

      final tp = TextPainter(
        text: TextSpan(text: text, style: textStyle),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
      );

      tp.layout(maxWidth: width.toDouble());
      final dx = (width - tp.width) / 2;
      tp.paint(canvas, Offset(dx, yOffset));

      if (drawBorder) {
        final paint = Paint()
          ..color = const ui.Color(0xFF000000)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

        final rrect = RRect.fromRectAndRadius(
          Rect.fromLTWH(dx, yOffset, tp.width, tp.height),
          const Radius.circular(6),
        );
        canvas.drawRRect(rrect, paint);
      }

      yOffset += tp.height + 6;
    }

    final picture = recorder.endRecording();
    final imgUi = await picture.toImage(width, yOffset.toInt());
    final byteData = await imgUi.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return [];
    return _convertRgbaToRasterBytes(
        byteData.buffer.asUint8List(), width, yOffset.toInt());
  }

  /// ✅ ساخت بایت QR Code
  Future<List<int>> buildQRCode(String data, {int size = 200}) async {
    final qr = QrPainter(
      data: data,
      version: QrVersions.auto,
      gapless: true,
      color: const ui.Color(0xFF000000),
      emptyColor: const ui.Color(0xFFFFFFFF),
    );

    final pic = await qr.toImage(size.toDouble());
    final byteData = await pic.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return [];
    return _convertRgbaToRasterBytes(byteData.buffer.asUint8List(), size, size);
  }

  Future<List<int>> buildHtmlImage(String htmlContent, int width) async {
    if (htmlContent.isEmpty) return [];

    final cacheKey = '$htmlContent-$width';
    if (_cachedFooters.containsKey(cacheKey)) {
      return _cachedFooters[cacheKey]!;
    }

    final processedHtml = htmlContent.replaceAllMapped(
      RegExp(r'(\d+)\s*pt', caseSensitive: false),
      (match) {
        final val = int.tryParse(match.group(1) ?? '') ?? 12;
        return '${(val * 2.2).toInt()}px';
      },
    );
    print('processedHtml ____________________${processedHtml}');
    final screenshotController = ScreenshotController();

    final widget = Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        color: Colors.white,
        width: width.toDouble(),
        padding: const EdgeInsets.all(5),
        child: Html(
          data: processedHtml,
          style: {
            "p": Style(
              color: Colors.black,
              textAlign: TextAlign.right,
              direction: TextDirection.rtl,
            ),
            "body": Style(
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
              color: Colors.black,
              textAlign: TextAlign.right,
              direction: TextDirection.rtl,
            ),
            "span": Style(
              direction: TextDirection.rtl,
            ),
          },
        ),
      ),
    );

    try {
      final Uint8List pngBytes = await screenshotController.captureFromWidget(
        widget,
        delay: const Duration(milliseconds: 50),
        context: Get.context,
        pixelRatio: 1.0,
      );
      final img.Image? image = img.decodeImage(pngBytes);
      if (image == null) return [];
      final resized = img.copyResize(image, width: width);
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      final result = generator.image(resized);
      _cachedFooters[cacheKey] = result;
      return result;
    } catch (e) {
      debugPrint("Error rendering HTML to image: $e");
      return [];
    }
  }
}
