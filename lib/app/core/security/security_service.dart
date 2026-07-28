import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/config/constants.dart';

class SecurityAuditResult {
  final bool isRooted;
  final bool isEmulator;
  final bool isFridaDetected;
  final bool isSignatureValid;
  final String currentSignatureSha256;
  final String installerPackage;

  SecurityAuditResult({
    required this.isRooted,
    required this.isEmulator,
    required this.isFridaDetected,
    required this.isSignatureValid,
    required this.currentSignatureSha256,
    required this.installerPackage,
  });

  bool get isSafe => !isRooted && !isFridaDetected && isSignatureValid;

  factory SecurityAuditResult.fromMap(Map<dynamic, dynamic> map) {
    return SecurityAuditResult(
      isRooted: map['isRooted'] as bool? ?? false,
      isEmulator: map['isEmulator'] as bool? ?? false,
      isFridaDetected: map['isFridaDetected'] as bool? ?? false,
      isSignatureValid: map['isSignatureValid'] as bool? ?? true,
      currentSignatureSha256: map['currentSignatureSha256'] as String? ?? '',
      installerPackage: map['installerPackage'] as String? ?? 'unknown',
    );
  }
}

/// Unified Security Guard Service for Inteshar
class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  static const MethodChannel _channel =
      MethodChannel('com.inteshar.app/security');

  SecurityAuditResult? lastAuditResult;

  /// Runs complete device & runtime security audit.
  Future<SecurityAuditResult> performSecurityCheck({
    String? expectedSignatureSha256,
  }) async {
    if (!Platform.isAndroid) {
      // iOS / Desktop default fallback
      final result = SecurityAuditResult(
        isRooted: false,
        isEmulator: false,
        isFridaDetected: false,
        isSignatureValid: true,
        currentSignatureSha256: '',
        installerPackage: 'apple',
      );
      lastAuditResult = result;
      return result;
    }

    try {
      final Map<dynamic, dynamic>? res = await _channel.invokeMethod(
        'checkDeviceIntegrity',
        {
          'expectedSignatureSha256': expectedSignatureSha256,
        },
      );

      if (res != null) {
        final audit = SecurityAuditResult.fromMap(res);
        lastAuditResult = audit;
        if (kDebugMode) {
          print('🔒 [SecurityService Audit Result]');
          print('   Rooted: ${audit.isRooted}');
          print('   Emulator: ${audit.isEmulator}');
          print('   Frida Hooking: ${audit.isFridaDetected}');
          print('   Signature Valid: ${audit.isSignatureValid}');
          print('   Current SHA-256: ${audit.currentSignatureSha256}');
          print('   Installer Package: ${audit.installerPackage}');
        }
        return audit;
      }
    } catch (e) {
      if (kDebugMode) {
        print(
            '🚨 [SecurityService Error] Failed to perform security check: $e');
      }
    }

    final fallback = SecurityAuditResult(
      isRooted: false,
      isEmulator: false,
      isFridaDetected: false,
      isSignatureValid: true,
      currentSignatureSha256: '',
      installerPackage: 'unknown',
    );
    lastAuditResult = fallback;
    return fallback;
  }

  /// Requests Play Integrity Token from Google Play Services
  Future<String?> requestPlayIntegrityToken({String? nonce}) async {
    if (!Platform.isAndroid) return null;
    try {
      final String? token = await _channel.invokeMethod(
        'requestPlayIntegrityToken',
        {'nonce': nonce},
      );
      return token;
    } catch (e) {
      if (kDebugMode) {
        print(
            '🚨 [SecurityService Error] Play Integrity Token request failed: $e');
      }
      return null;
    }
  }

  /// Enables FLAG_SECURE (prevents screen capture/recording)
  Future<void> enableScreenProtection() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('enableSecureScreen');
    } catch (e) {
      // Ignored
    }
  }

  /// Disables FLAG_SECURE
  Future<void> disableScreenProtection() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('disableSecureScreen');
    } catch (e) {
      // Ignored
    }
  }

  /// Evaluates security policies and shows a blocking dialog if violations occur.
  bool validatePolicyEnforcement() {
    final audit = lastAuditResult;
    if (audit == null) return true;

    String? violationReason;

    if (audit.isFridaDetected && Constants.blockFridaHooking) {
      violationReason =
          'تم اكتشاف أدوات الهندسة العكسية والتعديل (Frida/Xposed)';
    } else if (audit.isRooted && Constants.blockRootedDevices) {
      violationReason = 'تم اكتشاف جهاز متجذر (Rooted)';
    } else if (audit.isEmulator && Constants.blockEmulator) {
      violationReason = 'تشغيل التطبيق على المحاكي (Emulator) غير مسموح به';
    } else if (!audit.isSignatureValid &&
        Constants.enforceSignatureCheck &&
        Constants.expectedApkSignatureSha256.isNotEmpty) {
      violationReason = 'عدم تطابق التوقيع الرقمي للتطبيق (نسخة معدلة)';
    }

    if (violationReason != null) {
      if (kDebugMode) {
        print('🚨 [Security Violation] $violationReason');
      }
      _showBlockingSecurityDialog(violationReason);
      return false;
    }

    return true;
  }

  void _showBlockingSecurityDialog(String reason) {
    Future.microtask(() {
      Get.dialog(
        PopScope(
          canPop: false,
          child: AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.security, color: Colors.red, size: 28),
                SizedBox(width: 8),
                Text('تحذير أمني',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'لا يمكن تشغيل التطبيق في هذه البيئة.',
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    'السبب: $reason',
                    style: TextStyle(
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  SystemNavigator.pop();
                },
                child: const Text('خروج من التطبيق',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      );
    });
  }
}
