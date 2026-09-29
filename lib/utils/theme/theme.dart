import 'package:flutter/material.dart';

import 'package:mockmaster/utils/theme/custom_themes/appbar_theme.dart';
import 'package:mockmaster/utils/theme/custom_themes/bottom_sheet_theme.dart';
import 'package:mockmaster/utils/theme/custom_themes/checkbox_theme.dart';
import 'package:mockmaster/utils/theme/custom_themes/chip_theme.dart';
import 'package:mockmaster/utils/theme/custom_themes/elevated_button_theme.dart';
import 'package:mockmaster/utils/theme/custom_themes/text_field_theme.dart';
import 'package:mockmaster/utils/theme/custom_themes/text_theme.dart';

class MAppTheme {
  MAppTheme._();

  /// Light Theme
  /// NOTE: scaffoldBackgroundColor is left as a flat fallback color, but every
  /// screen should be wrapped in `MGradientBackground` so the ombre gradient
  /// paints behind the content instead of a flat fill. Scaffold itself is
  /// set to transparent at the screen level so the gradient shows through.
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    canvasColor: Colors.transparent,

    textTheme: MTextTheme.lightTextTheme,
    appBarTheme: MAppBarTheme.lightAppBarTheme,
    checkboxTheme: MCheckboxTheme.lightCheckboxTheme,
    chipTheme: MChipTheme.lightChipTheme,
    bottomSheetTheme: MBottomSheetTheme.lightBottomSheetTheme,
    elevatedButtonTheme: MElevatedButtonTheme.lightElevatedButtonTheme,
    inputDecorationTheme: MTextFieldTheme.lightTextFieldTheme,
  );

  /// Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.black,
    canvasColor: Colors.transparent,

    textTheme: MTextTheme.darkTextTheme,
    appBarTheme: MAppBarTheme.darkAppBarTheme,
    checkboxTheme: MCheckboxTheme.darkCheckboxTheme,
    chipTheme: MChipTheme.darkChipTheme,
    bottomSheetTheme: MBottomSheetTheme.darkBottomSheetTheme,
    elevatedButtonTheme: MElevatedButtonTheme.darkElevatedButtonTheme,
    inputDecorationTheme: MTextFieldTheme.darkTextFieldTheme,
  );
}