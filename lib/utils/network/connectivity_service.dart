import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class ConnectivityService {
  ConnectivityService._();

  static Future<bool> hasInternet() async {
    if (kIsWeb) {
      return true;
    }
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}