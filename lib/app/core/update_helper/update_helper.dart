import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateHelper {
  final BuildContext context;
  final String versionCheckUrl;

  UpdateHelper({required this.context, required this.versionCheckUrl});

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Call this once in main()
  Future<void> initNotifications() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    await _notificationsPlugin.initialize(
      const InitializationSettings(android: androidInit),
    );

    // Create proper notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'update_channel', // id
      'تحديث التطبيق', // name in Arabic
      description: 'يعرض تقدم التنزيل', // description in Arabic
      importance: Importance.high,
      showBadge: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Check version and show update dialog if needed
  Future<void> checkForUpdate() async {
    try {
      final response = await Dio().get(versionCheckUrl);
      final latestVersion = response.data['version'];
      final apkUrl = response.data['url'];

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      if (_isNewerVersion(latestVersion, currentVersion)) {
        _showUpdateDialog(latestVersion, apkUrl);
      }
    } catch (e) {
      debugPrint("فشل التحقق من التحديث: $e");
    }
  }

  bool _isNewerVersion(String latest, String current) {
    List<int> latestParts = latest.split('.').map(int.parse).toList();
    List<int> currentParts = current.split('.').map(int.parse).toList();

    for (int i = 0; i < latestParts.length; i++) {
      if (i >= currentParts.length || latestParts[i] > currentParts[i])
        return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }

  void _showUpdateDialog(String version, String apkUrl) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "تحديث جديد متوفر",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        content: Text("الإصدار $version أصبح متاحًا. هل ترغب في التحديث الآن؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text("لاحقًا", style: TextStyle(fontSize: 16)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // Request permissions
              // if (!await _requestPermissions()) return;

              downloadAndInstallApk(apkUrl);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              "تحديث الآن",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> downloadAndInstallApk(String apkUrl) async {
    final dir = await getExternalStorageDirectory();
    if (dir == null) return;
    final filePath = '${dir.path}/update.apk';
    const notificationId = 1001;
    print('Starting download: $apkUrl');
    try {
      // در متد downloadAndInstallApk
      int lastProgress = -1;
      DateTime? lastUpdateTime;

      await Dio().download(
        apkUrl,
        filePath,
        onReceiveProgress: (received, total) async {
          if (total != -1) {
            final progress = ((received / total) * 100).toInt();
            final now = DateTime.now();

            // فقط هر 500 میلی‌ثانیه یا با تغییر 5% به‌روزرسانی کن
            if (progress != lastProgress &&
                (lastUpdateTime == null ||
                    now.difference(lastUpdateTime!).inMilliseconds >= 500)) {
              lastProgress = progress;
              lastUpdateTime = now;
              // 👇 ساخت نوتیف در هر درصد جدید
              final androidDetails = AndroidNotificationDetails(
                'update_channel',
                'تحديث التطبيق',
                channelDescription: 'يعرض تقدم التنزيل',
                importance: Importance.high,
                priority: Priority.high,
                onlyAlertOnce: true,
                showProgress: true,
                maxProgress: 100,
                progress: progress,
                ongoing: true, // نوتیف تا آخر دانلود بمونه
                autoCancel: false,
              );

              // کد به‌روزرسانی نوتیفیکیشن اینجا
              await _notificationsPlugin.show(
                notificationId,
                'جارٍ تنزيل التحديث...',
                '$progress%',
                NotificationDetails(android: androidDetails),
              );
            }
          }
        },
      );

      // 👇 بعد از اتمام دانلود
      final completeDetails = AndroidNotificationDetails(
        'update_channel',
        'تحديث التطبيق',
        channelDescription: 'اكتمل التنزيل',
        importance: Importance.high,
        priority: Priority.high,
        ongoing: false,
        autoCancel: true,
      );

      await _notificationsPlugin.show(
        notificationId,
        'اكتمل التنزيل',
        '',
        NotificationDetails(android: completeDetails),
      );

      await OpenFilex.open(filePath);
    } catch (e) {
      debugPrint('فشل التنزيل: $e');
    }
  }

}
