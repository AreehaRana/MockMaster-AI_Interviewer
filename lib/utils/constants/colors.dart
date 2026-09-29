import 'package:flutter/material.dart';

class MColors {
  MColors._();

  /// App basic color
  static const Color primaryColor = Color(0xFF4B68FF);
  static const Color secondaryColor = Color(0xFFFFE24B);
  static const Color accent = Color(0xFFb0c7ff);

  /// Generic diagonal gradient (kept from your original)
  static const Gradient linerGradient = LinearGradient(
    begin: Alignment(0.0, 0.0),
    end: Alignment(0.707, -0.707),
    colors: [Color(0xffff9a9e), Color(0xfffad0c4), Color(0xfffad0c4)],
  );

  // ---------------------------------------------------------------------
  // OMBRE SCREEN BACKGROUNDS
  // Swap the colors below with your own theme palette whenever you send it —
  // just replace the Color(0x...) values, everything else keeps working.
  // ---------------------------------------------------------------------

  /// Dark mode ombre — deep navy/black fading into a visible purple-blue glow.
  static const Gradient darkOmbreBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF07070F), // near-black
      Color(0xFF1A1140), // deep indigo
      Color(0xFF3B2472), // visible purple glow (mid)
      Color(0xFF120B2E), // fade back down
      Color(0xFF07070F), // near-black
    ],
    stops: [0.0, 0.3, 0.55, 0.8, 1.0],
  );

  /// Light mode ombre — mostly white, with a soft tinted ombre wash.
  static const Gradient lightOmbreBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF3F5FF),
      Color(0xFFE7ECFF),
      Color(0xFFF6F6FF),
      Color(0xFFFFFFFF),
    ],
    stops: [0.0, 0.3, 0.55, 0.8, 1.0],
  );

  // ---------------------------------------------------------------------
  // GLASSMORPHISM
  // ---------------------------------------------------------------------

  /// Frosted fill color for glass cards in dark mode (low-opacity white).
  static Color glassFillDark = Colors.white.withOpacity(0.06);

  /// Frosted fill color for glass cards in light mode.
  static Color glassFillLight = Colors.white.withOpacity(0.55);

  /// Hairline border that catches the light on the glass edge.
  static Color glassBorderDark = Colors.white.withOpacity(0.14);
  static Color glassBorderLight = Colors.white.withOpacity(0.65);

  /// Soft ambient shadow cast underneath the glass card.
  static Color glassShadowDark = Colors.black.withOpacity(0.45);
  static Color glassShadowLight = Colors.black.withOpacity(0.08);

  // Text colors
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF6C7570);
  static const Color textWhite = Colors.white;

  /// Background colors
  static const Color light = Color(0xFFF6F6F6);
  static const Color dark = Color(0xFF272727);
  static const Color primaryBackground = Color(0xFFF3F5FF);

  ///Background Container Colors
  static const Color lightContainer = Color(0xFFF6F6F6);
  static Color darkContainer = MColors.dark.withOpacity(0.8);

  /// Button Colors
  static const Color buttonPrimary = Color(0xFF4b68ff);
  static const Color buttonSecondary = Color(0xFF6C7570);
  static const Color buttonDisabled = Color(0xFFC4C4C4);

  /// Border Colors
  static const Color borderPrimary = Color(0xFFD9D9D9);
  static const Color borderSecondary = Color(0xFFE6E6E6);

  /// Error and Validation Colors
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);

  /// Neutral Shades
  static const Color black = Color(0xFF232323);
  static const Color darkerGrey = Color(0xFF4F4F4F);
  static const Color darkGrey = Color(0xFF939393);
  static const Color grey = Color(0xFFE0E0E0);
  static const Color softGrey = Color(0xFFF4F4F4);
  static const Color lightGrey = Color(0xFFF9F9F9);
  static const Color white = Color(0xFFFFFFFF);
}