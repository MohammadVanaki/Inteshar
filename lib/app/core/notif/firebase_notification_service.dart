import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:inteshar/app/config/constants.dart';

class FirebaseNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Initialize notifications and setup FCM
  Future<void> initializeNotifications() async {
    // Request user permission for notifications
    await _firebaseMessaging.requestPermission();

    // FirebaseMessaging.instance.getToken().then((token) {
    //   print("Device Token: $token");
    // });
    // Retrieve the FCM token
    Constants.fcmToken = (await _firebaseMessaging.getToken())!;
    print("FCM Token: ${Constants.fcmToken}");

    // Configure local notifications
    await _configureLocalNotifications();

    // Register background message handler
    FirebaseMessaging.onBackgroundMessage(handleFirebaseBackgroundMessage);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        _showLocalNotification(message); // Show notification
      }
    });

    // Subscribe to a topic
    await subscribeToTopic("general");
  }

  // Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print("Subscribed to topic: $topic");
    } catch (e) {
      print("Failed to subscribe to topic: $e");
    }
  }

  // Configure local notifications
  Future<void> _configureLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(settings);

    // ⚡ این بخش رو اضافه کن
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'default_channel_id', // id
      'Default Notifications', // name
      description: 'This channel is used for default notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Display a local notification for a foreground message
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    const androidDetails = AndroidNotificationDetails(
      'default_channel_id',
      'Default Notifications',
      channelDescription: 'This channel is used for default notifications.',
      importance: Importance.high,
      priority: Priority.high,
    );

    NotificationDetails platformDetails = const NotificationDetails(
      android: androidDetails,
    );

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        platformDetails,
      );
    }
  }
}

// Background message handler
Future<void> handleFirebaseBackgroundMessage(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}
