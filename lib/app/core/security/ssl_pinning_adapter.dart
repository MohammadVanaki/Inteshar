import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

/// SSL Certificate & SPKI Pinning Adapter for Dio.
/// Prevents Man-in-the-Middle (MITM) attacks by verifying SHA-256 fingerprints
/// of the server's TLS certificate.
class SslPinningAdapter extends IOHttpClientAdapter {
  final List<String> allowedSha256Fingerprints;

  SslPinningAdapter({
    required this.allowedSha256Fingerprints,
  }) {
    createHttpClient = () {
      final client = HttpClient(
        context: SecurityContext(withTrustedRoots: true),
      );

      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        return _validateCertificate(cert, host);
      };

      return client;
    };

    validateCertificate = (X509Certificate? cert, String host, int port) {
      if (cert == null) return false;
      return _validateCertificate(cert, host);
    };
  }

  bool _validateCertificate(X509Certificate cert, String host) {
    if (allowedSha256Fingerprints.isEmpty) {
      // If no fingerprints are configured, log warning and allow request
      print('⚠️ SSL Pinning: No SHA-256 fingerprints configured. Skipping check.');
      return true;
    }

    final sha256Digest = sha256.convert(cert.der);
    final certDerSha256Hex = sha256Digest.toString().toLowerCase();
    final certDerSha256Base64 = base64.encode(sha256Digest.bytes);

    final spkiDigest = _extractSpkiBytes(cert.der);
    final spkiSha256Hex = spkiDigest != null ? sha256.convert(spkiDigest).toString().toLowerCase() : null;
    final spkiSha256Base64 = spkiDigest != null ? base64.encode(sha256.convert(spkiDigest).bytes) : null;

    for (final allowed in allowedSha256Fingerprints) {
      final cleanAllowed = allowed
          .replaceAll('sha256/', '')
          .replaceAll(':', '')
          .replaceAll(' ', '')
          .trim();
      final cleanAllowedLower = cleanAllowed.toLowerCase();

      final matchesCert = certDerSha256Hex == cleanAllowedLower || certDerSha256Base64 == cleanAllowed;
      final matchesSpki = (spkiSha256Hex != null && spkiSha256Hex == cleanAllowedLower) ||
          (spkiSha256Base64 != null && spkiSha256Base64 == cleanAllowed);

      if (matchesCert || matchesSpki) {
        if (kDebugMode) {
          print('✅ SSL Pinning matched for $host');
        }
        return true;
      }
    }

    if (kDebugMode) {
      print('🚨 SSL Pinning FAILED for host $host!');
      print('🚨 Server Certificate SHA-256 (Hex): $certDerSha256Hex');
      print('🚨 Server Certificate SHA-256 (Base64): $certDerSha256Base64');
      if (spkiSha256Hex != null) {
        print('🚨 Server Public Key SHA-256 (Hex): $spkiSha256Hex');
        print('🚨 Server Public Key SHA-256 (Base64): $spkiSha256Base64');
      }
      print('🚨 Expected Fingerprints: $allowedSha256Fingerprints');
    }
    return false;
  }

  List<int>? _extractSpkiBytes(List<int> der) {
    try {
      final rsaOid = [0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01];
      final ecOid = [0x06, 0x07, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x02, 0x01];

      int oidIndex = -1;
      for (int i = 0; i < der.length - 15; i++) {
        bool matchRsa = true;
        for (int j = 0; j < rsaOid.length; j++) {
          if (der[i + j] != rsaOid[j]) {
            matchRsa = false;
            break;
          }
        }
        if (matchRsa) {
          oidIndex = i;
          break;
        }

        bool matchEc = true;
        for (int j = 0; j < ecOid.length; j++) {
          if (der[i + j] != ecOid[j]) {
            matchEc = false;
            break;
          }
        }
        if (matchEc) {
          oidIndex = i;
          break;
        }
      }

      if (oidIndex > 0 && der[oidIndex - 2] == 0x30) {
        int spkiStart = oidIndex - 2;
        int lenByte = der[spkiStart + 1];
        int spkiLen = 0;
        int headerLen = 2;
        if (lenByte < 128) {
          spkiLen = lenByte;
        } else if (lenByte == 0x81) {
          spkiLen = der[spkiStart + 2];
          headerLen = 3;
        } else if (lenByte == 0x82) {
          spkiLen = (der[spkiStart + 2] << 8) | der[spkiStart + 3];
          headerLen = 4;
        }
        if (spkiLen > 0 && spkiStart + headerLen + spkiLen <= der.length) {
          return der.sublist(spkiStart, spkiStart + headerLen + spkiLen);
        }
      }
    } catch (_) {}
    return null;
  }
}
