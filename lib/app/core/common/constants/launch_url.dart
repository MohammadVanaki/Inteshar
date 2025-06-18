import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> urlLauncher(String url) async {
  try {
    if (url.trim().isEmpty || !url.startsWith('http')) {
      throw FormatException('Invalid URL: $url');
    }

    final Uri uri = Uri.parse(url);

    if (uri.host.isEmpty) {
      throw FormatException('Invalid host in URI: $url');
    }

    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  } catch (e) {
    print('Error: $e');
    Get.snackbar('خطأ', 'حدث خطأ أثناء فتح الرابط: $e');
  }
}
