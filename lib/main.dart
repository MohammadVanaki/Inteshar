import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/config/connectivity_controller.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/config/theme.dart';
import 'package:inteshar/app/core/notif/firebase_notification_service.dart';
import 'package:inteshar/app/core/routes/routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:inteshar/app/core/init/init.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await init();

  try {
    await checkGooglePlayServices().timeout(const Duration(seconds: 10));
  } catch (e) {
    debugPrint('Timeout: Google Play Services check took too long, skipping.');
  }

  runApp(const MyApp());
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Put connectivity controller in GetX dependency system
    Get.put(ConnectivityController());

    final bool darkMode =
        Constants.localStorage.read('settings')?['darkMode'] ?? false;

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      locale: const Locale('ar'),
      title: Constants.appTitle,
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      darkTheme: MyThemes.darkTheme,
      theme: MyThemes.lightTheme,
      initialRoute: Routes.splash,
      getPages: Routes.pages,
    );
  }
}

Future<void> checkGooglePlayServices() async {
  GooglePlayServicesAvailability availability = await GoogleApiAvailability
      .instance
      .checkGooglePlayServicesAvailability();

  if (availability != GooglePlayServicesAvailability.success) {
    debugPrint('Google Play Services not available: $availability');

    // Notify user about lack of Google Play Services
    showGooglePlayServicesError(availability);
  } else {
    debugPrint('Google Play Services is available.');

    await Firebase.initializeApp();

    // Enable Firebase Crashlytics error reporting
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    FirebaseMessaging.onBackgroundMessage(handleFirebaseBackgroundMessage);
    await FirebaseNotificationService().initializeNotifications();

    // Send a test crash to activate Crashlytics
    // FirebaseCrashlytics.instance.crash(); // REMOVE THIS AFTER FIRST TEST
  }
}

void showGooglePlayServicesError(GooglePlayServicesAvailability availability) {
  // Show a warning if Google Play Services is not available
  debugPrint(
      'Google Play Services is not available: ${availability.toString()}');
}
