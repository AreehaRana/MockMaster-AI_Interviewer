import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MDeviceUtils {
  /// Hide Keyboard
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  /// Status Bar Color
  static Future<void> setStatusBarColor(Color color) async {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: color),
    );
  }

  /// Landscape
  static bool isLandscapeOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Portrait
  static bool isPortraitOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Full Screen
  static void setFullScreen(bool enable) {
    SystemChrome.setEnabledSystemUIMode(
      enable ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  /// Screen Height
  static double getScreenHeight() {
    return MediaQuery.of(Get.context!).size.height;
  }

  /// Screen Width
  static double getScreenWidth() {
    return MediaQuery.of(Get.context!).size.width;
  }

  /// Pixel Ratio
  static double getPixelRatio() {
    return MediaQuery.of(Get.context!).devicePixelRatio;
  }

  /// Status Bar Height
  static double getStatusBarHeight() {
    return MediaQuery.of(Get.context!).padding.top;
  }

  /// Bottom Navigation Height
  static double getBottomNavigationBarHeight() {
    return kBottomNavigationBarHeight;
  }

  /// AppBar Height
  static double getAppBarHeight() {
    return kToolbarHeight;
  }

  /// Keyboard Height
  static double getKeyboardHeight() {
    return MediaQuery.of(Get.context!).viewInsets.bottom;
  }

  /// Keyboard Visible
  static bool isKeyboardVisible() {
    return MediaQuery.of(Get.context!).viewInsets.bottom > 0;
  }

  /// Physical Device
  static bool isPhysicalDevice() {
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Vibrate
  static void vibrate(Duration duration) {
    HapticFeedback.vibrate();
    Future.delayed(duration, () => HapticFeedback.vibrate());
  }

  /// Preferred Orientation
  static Future<void> setPreferredOrientations(
    List<DeviceOrientation> orientations,
  ) async {
    await SystemChrome.setPreferredOrientations(orientations);
  }

  /// Hide Status Bar
  static void hideStatusBar() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [],
    );
  }

  /// Show Status Bar
  static void showStatusBar() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  /// Internet Connection
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');

      return result.isNotEmpty &&
          result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  /// iOS
  static bool isIOS() {
    return Platform.isIOS;
  }

  /// Android
  static bool isAndroid() {
    return Platform.isAndroid;
  }

  /// Launch URL
  static Future<void> launchUrl(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw Exception('Could not launch $url');
    }
  }
}