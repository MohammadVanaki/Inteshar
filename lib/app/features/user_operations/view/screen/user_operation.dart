import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/config/functions.dart';
import 'package:inteshar/app/config/status.dart';
import 'package:inteshar/app/core/common/widgets/internal_page.dart';
import 'package:inteshar/app/core/common/widgets/offline_widget.dart';
import 'package:inteshar/app/core/common/widgets/retry_widget.dart';
import 'package:inteshar/app/core/utils/custom_loading.dart';
import 'package:inteshar/app/features/user_operations/data/data_source/operation_api_provider.dart';
import 'package:inteshar/app/features/user_operations/data/models/operation_model.dart';

class UserOperation extends StatelessWidget {
  const UserOperation({super.key});

  @override
  Widget build(BuildContext context) {
    return InternalPage(
      title: 'عمليات المستخدم',
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 20),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: Constants.intesharBoxDecoration(context).copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
        child: Constants.isLoggedIn
            ? Obx(
                () {
                  final OperationApiProvider operationApiProvider =
                      Get.put(OperationApiProvider());
                  switch (operationApiProvider.rxRequestStatus.value) {
                    case Status.loading:
                      return const Center(child: CustomLoading());
                    case Status.error:
                      return Center(
                          child: RetryWidget(
                        onTap: () => operationApiProvider.fetchOperationData(),
                      ));
                    case Status.completed:
                      if (operationApiProvider.operationDataList.isEmpty) {
                        return const Center(
                            child: Text("لا توجد إشعارات جديدة."));
                      }
                      final operations =
                          operationApiProvider.operationDataList.first.data;
                      // print("Category Title: ${operationApiProvider.operationDataList.first.data[2].categoryTitle}");
                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: operationApiProvider
                            .operationDataList.first.data.length,
                        itemBuilder: (context, index) {
                          var operation = operationApiProvider
                              .operationDataList.first.data[index];

                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20)
                                    .copyWith(right: 30),
                                margin: const EdgeInsets.all(20)
                                    .copyWith(right: 25, top: 0),
                                decoration:
                                    Constants.intesharBoxDecoration(context)
                                        .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimary
                                      .withAlpha(30),
                                  boxShadow: [],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildRowWithGap(
                                      "الاجراء : ",
                                      getOperationType(operation),
                                    ),
                                    if (operation.serialCount != null &&
                                        operation.serialCount != 0)
                                      buildRowWithGap("العدد : ",
                                          operation.serialCount.toString()),
                                    buildRowWithGap(
                                        "الفئة : ",
                                        operation.categoryTitle?.toString() ??
                                            ''),
                                    buildRowWithGap(
                                      "المبلغ : ",
                                      formatNumber((operation.userPrice ??
                                              operation.agentPrice ??
                                              operation.parentAgentPrice ??
                                              operation.categoryPrice ??
                                              0)) ??
                                          '',
                                    ),
                                    buildRowWithGap(
                                        "رصيدك السابق:",
                                        getOperationType(operation) ==
                                                "تحويل رصيد"
                                            // If operation type is "Transfer Balance", subtract the total amount * numCount from inventory
                                            ? formatNumber(operation
                                                        .inventory! -
                                                    ((operation
                                                                .deposit ??
                                                            operation
                                                                .userPrice ??
                                                            operation
                                                                .agentPrice ??
                                                            operation
                                                                .parentAgentPrice ??
                                                            operation
                                                                .categoryPrice ??
                                                            0) *
                                                        (operation
                                                                .numCount ??
                                                            1))) ??
                                                ''
                                            // Otherwise, add the total amount * numCount to inventory
                                            : formatNumber(operation
                                                        .inventory! +
                                                    ((operation
                                                                .deposit ??
                                                            operation
                                                                .userPrice ??
                                                            operation
                                                                .agentPrice ??
                                                            operation
                                                                .parentAgentPrice ??
                                                            operation
                                                                .categoryPrice ??
                                                            0) *
                                                        (operation.numCount ??
                                                            1))) ??
                                                ''),
                                    buildRowWithGap(
                                        "رصيدك الحالي : ",
                                        formatNumber(operation.inventory!) ??
                                            ''),
                                    const Gap(10),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        formatDateTime(
                                            operations[index].dateTime),
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary
                                                .withAlpha(180)),
                                        textDirection: TextDirection.ltr,
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                right: 5,
                                child: Container(
                                  width: 45,
                                  height: 45,
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 3,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surface
                                          .withAlpha(90),
                                    ),
                                  ),
                                  child: SvgPicture.asset(
                                    'assets/svgs/file-user.svg',
                                    colorFilter: ColorFilter.mode(
                                      Theme.of(context).colorScheme.onPrimary,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    default:
                      return const Center(child: Text("وضعیت نامشخص"));
                  }
                },
              )
            : const OfflineWidget(),
      ),
    );
  }

  String getOperationType(Datum operation) {
    if (operation.deviceToken != null && operation.deviceToken!.isNotEmpty) {
      return "تسجيل دخول";
    }
    if (operation.deposit != null && operation.deposit! > 0) {
      return "تحويل رصيد";
    }
    if (operation.serialCount != null && operation.serialCount! > 0) {
      return "طباعة";
    }
    return "غير محدد";
  }

  String formatDateTime(int timestamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return "${dateTime.year}/${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute}:${dateTime.second}";
  }

  Widget buildRowWithGap(String label, String? value) {
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink();
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              softWrap: true,
              overflow: TextOverflow.visible,
              style: const TextStyle(fontSize: 14),
            ),
            Flexible(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.left,
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ],
        ),
      );
    }
  }


}
