import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/config/status.dart';
import 'package:inteshar/app/core/extensions/success_color_theme.dart';
import 'package:inteshar/app/core/utils/custom_loading.dart';
import 'package:inteshar/app/features/services/data/data_source/service_api_provider.dart';

Future<dynamic> internetModalConfirm({
  required BuildContext context,
  required String price,
  required String category,
  required String classification,
  required String categoryId,
  required String type,
}) {
  final formKey = GlobalKey<FormState>();
  ServiceApiProvider serviceApiProvider = Get.put(ServiceApiProvider());
  final TextEditingController phoneController =
      TextEditingController(text: '77');
  return showModalBottomSheet(
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.primary,
    context: context,
    builder: (context) {
      return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          alignment: Alignment.topCenter,
          height: Get.height * .42,
          child: Column(
            children: [
              Form(
                key: formKey,
                child: TextFormField(
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  validator: (value) {
                    if (value!.length < 10 || value.length > 10) {
                      return 'رقم الجوال غير صالح';
                    }
                    return null;
                  },
                  controller: phoneController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    suffixText: '00964',
                    suffixStyle: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withAlpha(200)),
                    border: const OutlineInputBorder(),
                    label: const Text('رقم الهاتف'),
                    labelStyle: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withOpacity(0.7),
                    ),
                    floatingLabelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('التصنيف :'),
                  Text(
                    classification,
                    style: const TextStyle(
                        fontSize: 16,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('الفئة :'),
                  Text(
                    category,
                    style: const TextStyle(
                        fontSize: 16,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('السعر :'),
                  Text(
                    price,
                    style: const TextStyle(
                        fontSize: 16,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700),
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: Obx(() {
                  final requestStatus =
                      serviceApiProvider.rxRequestStatus.value;
                  final isLoading = requestStatus == Status.loading;

                  return ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        Theme.of(context)
                            .extension<SuccessColorTheme>()
                            ?.successColor,
                      ),
                    ),
                    onPressed: isLoading
                        ? null
                        : () {
                            if (formKey.currentState!.validate()) {
                              serviceApiProvider.fetchTransaction(
                                phone: phoneController.text,
                                categoryId: categoryId,
                                type: type,
                                price: category,
                                category: price,
                                context: context,
                                title: 'الباقات',
                              );
                            }
                          },
                    child: isLoading
                        ? const Center(child: CustomLoading())
                        : Text(
                            'تأكيد',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .extension<SuccessColorTheme>()
                                  ?.onSuccessColor,
                            ),
                          ),
                  );
                }),
              ),
            ],
          ),
        ),
      );
    },
  ).whenComplete(
    () {
      Get.delete<ServiceApiProvider>();
    },
  );
}
