import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:intl/intl.dart' as intl;
import '../getX/report_value_controller.dart';

class ReportingDate extends StatelessWidget {
  const ReportingDate({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    ReportValueController reportValueController =
        Get.put(ReportValueController());
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/svgs/calendar-days.svg',
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.onPrimary,
            BlendMode.srcIn,
          ),
        ),
        const Gap(5),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          decoration: Constants.intesharBoxDecoration(context).copyWith(
            border: Border(
              right: BorderSide(
                color: Theme.of(context).colorScheme.secondary,
                width: 8,
              ),
            ),
            color: Theme.of(context).colorScheme.onPrimary.withAlpha(20),
          ),
          child: Obx(
            () {
              return InkWell(
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        reportValueController.startDate.value,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    const Gap(10),
                    SvgPicture.asset(
                      'assets/svgs/angle-small-down.svg',
                      width: 15,
                      height: 15,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.onPrimary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
                onTap: () async {
                  final startDate = await showBoardDateTimePicker(
                    context: context,
                    pickerType: DateTimePickerType.date,
                    options: BoardDateTimeOptions(
                      activeColor: Theme.of(context).colorScheme.secondary,
                      activeTextColor:
                          Theme.of(context).colorScheme.onSecondary,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor:
                          Theme.of(context).colorScheme.onPrimary.withAlpha(40),
                      showDateButton: false,
                      pickerFormat: PickerFormat.ymd,
                      boardTitle: 'حدد التاريخ المطلوب',
                    ),
                  );

                  reportValueController.startDate.value =
                      intl.DateFormat("yyyy-MM-dd").format(startDate!);
                },
              );
            },
          ),
        ),
        const Gap(5),
        const Text('الی'),
        const Gap(5),
        Obx(() => Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              decoration: Constants.intesharBoxDecoration(context).copyWith(
                border: Border(
                  right: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 8,
                  ),
                ),
                color: Theme.of(context).colorScheme.onPrimary.withAlpha(20),
              ),
              child: InkWell(
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        reportValueController.endDate.value,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    const Gap(10),
                    SvgPicture.asset(
                      'assets/svgs/angle-small-down.svg',
                      width: 15,
                      height: 15,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.onPrimary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
                onTap: () async {
                  final endDate = await showBoardDateTimePicker(
                    context: context,
                    pickerType: DateTimePickerType.date,
                    options: BoardDateTimeOptions(
                      activeColor: Theme.of(context).colorScheme.secondary,
                      activeTextColor:
                          Theme.of(context).colorScheme.onSecondary,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor:
                          Theme.of(context).colorScheme.onPrimary.withAlpha(40),
                      showDateButton: false,
                      pickerFormat: PickerFormat.ymd,
                      boardTitle: 'حدد التاريخ المطلوب',
                    ),
                  );

                  reportValueController.endDate.value =
                      intl.DateFormat("yyyy-MM-dd").format(endDate!);
                },
              ),
            )),
      ],
    );
  }
}
