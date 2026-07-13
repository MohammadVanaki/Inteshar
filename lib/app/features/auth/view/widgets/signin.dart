import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/config/functions.dart';
import 'package:inteshar/app/config/local_auth.dart';
import 'package:inteshar/app/config/status.dart';
import 'package:inteshar/app/core/utils/custom_loading.dart';
import 'package:inteshar/app/features/auth/data/data_source/singin_api_provider.dart';
import 'package:inteshar/app/features/auth/view/getX/welcome_controller.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

final formKey = GlobalKey<FormState>();
FocusNode fildOne = FocusNode();
FocusNode fildTwo = FocusNode();

class Signin extends StatelessWidget {
  const Signin({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final WelcomeController welcomeController = Get.put(WelcomeController());
    final SinginApiProvider singinApiProvider = Get.put(SinginApiProvider());

    final userInfo = Constants.localStorage.read('userInfo');
    return Container(
      padding: const EdgeInsets.all(40),
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/p-login.jpg'),
          fit: BoxFit.fill,
        ),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Gap(120),
                const Gap(40),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          focusNode: fildOne,
                          textInputAction: TextInputAction.next,
                          textDirection: TextDirection.ltr,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: singinApiProvider.usernameController,
                          validator: (value) {
                            if (GetUtils.isEmail(value!)) {
                              return null;
                            }
                            return 'أدخل بريد إلكتروني صالح';
                          },
                          onFieldSubmitted: (v) {
                            FocusScope.of(context).requestFocus(fildTwo);
                          },
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 211, 211, 211),
                                    width: 1),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey, width: 1)),
                              errorBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.red, width: 1),
                              ),
                              focusedErrorBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 1),
                              ),
                              filled: true,
                              fillColor: Theme.of(context)
                                  .colorScheme
                                  .onPrimary
                                  .withAlpha(30),
                              hintText: 'البريد الإلكتروني',
                              hintStyle: const TextStyle(color: Colors.grey)),
                        ),
                        const Gap(20),
                        Obx(
                          () => TextFormField(
                            focusNode: fildTwo,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            obscureText:
                                welcomeController.isPasswordHidden.value,
                            controller: singinApiProvider.passwordController,
                            textDirection: TextDirection.ltr,
                            validator: (value) {
                              if (value!.length > 5) {
                                return null;
                              }
                              return 'أدخل كلمة المرور الخاصة بك بشكل صحيح';
                            },
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 211, 211, 211),
                                    width: 1),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey, width: 1)),
                              errorBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.red, width: 1),
                              ),
                              focusedErrorBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 1),
                              ),
                              hintText: 'كلمة المرور',
                              hintStyle: const TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: Theme.of(context)
                                  .colorScheme
                                  .onPrimary
                                  .withAlpha(30),
                              suffix: ZoomTapAnimation(
                                onTap: () {
                                  welcomeController.isPasswordHidden.value =
                                      !welcomeController.isPasswordHidden.value;
                                },
                                child: SvgPicture.asset(
                                  welcomeController.isPasswordHidden.value
                                      ? 'assets/svgs/eye.svg'
                                      : 'assets/svgs/eye-crossed.svg',
                                  width: 20,
                                  height: 20,
                                  colorFilter: ColorFilter.mode(
                                    Theme.of(context).colorScheme.onPrimary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Gap(10),
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: InkWell(
                            onTap: () {
                              singinApiProvider.rememberMe.toggle();
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Obx(
                                  () => Checkbox(
                                    value: singinApiProvider.rememberMe.value,
                                    onChanged: (value) {
                                      singinApiProvider.rememberMe.value =
                                          value ?? false;
                                    },
                                    activeColor:
                                        Theme.of(context).colorScheme.secondary,
                                    checkColor:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  'تذكرني',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Gap(10),
                        SizedBox(
                          width: double.infinity,
                          child: Obx(
                            () => ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor:
                                    const Color.fromARGB(255, 55, 55, 55),
                                backgroundColor: _getBackgroundColor(
                                    singinApiProvider.rxRequestStatus.value,
                                    context),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: singinApiProvider
                                          .rxRequestButtonStatus.value ==
                                      Status.loading
                                  ? null
                                  : () {
                                      FocusScope.of(context).unfocus();
                                      if (formKey.currentState!.validate()) {
                                        singinApiProvider.login(
                                          username: singinApiProvider
                                              .usernameController.text,
                                          password: singinApiProvider
                                              .passwordController.text,
                                        );
                                      }
                                    },
                              child: Obx(
                                () {
                                  switch (
                                      singinApiProvider.rxRequestStatus.value) {
                                    case Status.initial:
                                    case Status.completed:
                                      return Text(
                                        'دخول',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        ),
                                      );
                                    case Status.error:
                                      return Text(
                                        singinApiProvider.errorMessage.value,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onError,
                                        ),
                                      );
                                    case Status.loading:
                                      return CustomLoading(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(20),
                if (userInfo != null)
                  ZoomTapAnimation(
                    onTap: () async {
                      final authenticate = await LocalAuth.authenticate();

                      if (authenticate) {
                        singinApiProvider.login(
                          username: userInfo['userName'],
                          password: userInfo['password'],
                        );
                      }
                    },
                    child: Column(
                      children: [
                        SvgPicture.asset(
                          width: 40,
                          height: 40,
                          'assets/svgs/fingerprint.svg',
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.onPrimary,
                            BlendMode.srcIn,
                          ),
                        ),
                        const Gap(5),
                        const Text('الدخول ببصمة اليد أو الوجه'),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Color _getBackgroundColor(Status status, BuildContext context) {
  if (status == Status.error) {
    return Theme.of(context).colorScheme.error;
  }
  return Theme.of(context).colorScheme.secondary;
}
