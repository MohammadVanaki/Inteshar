import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';

String? formatNumber(int? number) {
  if (number == null || number == 0) {
    return null;
  }
  return number.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (Match match) => '${match.group(1)},',
      );
}

String dateFormat(String dateStr) {
  try {
    DateTime dateTime = DateTime.parse(dateStr);
    return DateFormat('yyyy/MM/dd').format(dateTime);
  } catch (e) {
    return 'تاریخ نامعتبر';
  }
}

Color colorFromHex(String hexColor) =>
    Color(int.parse(hexColor.replaceFirst('#', '0xFF')));

String removeHtmlTags(String htmlString) {
  final RegExp tagRegExp =
      RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
  htmlString = htmlString.replaceAll('&nbsp;', ' ');
  htmlString = htmlString.replaceAll('<br />', '\n');

  return htmlString.replaceAll(tagRegExp, '');
}

List<TextSpan> parseHtmlToTextSpans(String htmlString, TextStyle baseStyle) {
  String processed = htmlString
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'")
      .replaceAll('&amp;', '&')
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&rlm;', '\u200F')
      .replaceAll('&lrm;', '\u200E');

  final regExp = RegExp(r'(<[^>]+>)');
  final matches = regExp.allMatches(processed);
  
  List<TextSpan> spans = [];
  int lastIndex = 0;
  
  bool isBold = false;
  bool isItalic = false;
  bool isUnderline = false;
  
  void addText(String text) {
    if (text.isEmpty) return;
    spans.add(TextSpan(
      text: text,
      style: baseStyle.copyWith(
        fontWeight: isBold ? FontWeight.bold : baseStyle.fontWeight,
        fontStyle: isItalic ? FontStyle.italic : baseStyle.fontStyle,
        decoration: isUnderline ? TextDecoration.underline : baseStyle.decoration,
      ),
    ));
  }

  for (final match in matches) {
    if (match.start > lastIndex) {
      addText(processed.substring(lastIndex, match.start));
    }
    
    String tag = match.group(0)!.toLowerCase();
    if (tag == '<b>' || tag == '<strong>') {
      isBold = true;
    } else if (tag == '</b>' || tag == '</strong>') {
      isBold = false;
    } else if (tag == '<i>' || tag == '<em>') {
      isItalic = true;
    } else if (tag == '</i>' || tag == '<em>') {
      isItalic = false;
    } else if (tag == '<u>') {
      isUnderline = true;
    } else if (tag == '</u>') {
      isUnderline = false;
    } else if (tag == '</p>' || tag == '</div>') {
      addText('\n');
    }
    
    lastIndex = match.end;
  }
  
  if (lastIndex < processed.length) {
    addText(processed.substring(lastIndex));
  }
  
  return spans;
}

Future<String?> getId() async {
  var deviceInfo = DeviceInfoPlugin();
  var storage = const FlutterSecureStorage();

  String? savedId = await storage.read(key: 'unique_device_id');
  if (savedId != null) return savedId;

  String finalId = '';

  if (Platform.isAndroid) {
    var androidInfo = await deviceInfo.androidInfo;

    String hardwareSerial = androidInfo.serialNumber;

    if (hardwareSerial != 'unknown' && hardwareSerial.isNotEmpty) {
      finalId = hardwareSerial;
    } else {
      finalId =
          "${androidInfo.brand}-${androidInfo.model}-${androidInfo.id}-${androidInfo.board}-${androidInfo.hardware}-${androidInfo.fingerprint}";
    }
  } else if (Platform.isIOS) {
    var iosInfo = await deviceInfo.iosInfo;
    finalId = iosInfo.identifierForVendor ?? const Uuid().v4();
  }

  if (finalId.isEmpty) {
    finalId = const Uuid().v4();
  }

  await storage.write(key: 'unique_device_id', value: finalId);
  return finalId;
}
