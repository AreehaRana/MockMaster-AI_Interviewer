import 'package:flutter/material.dart';

class MTextFieldTheme {
  MTextFieldTheme._();

  /// Light Theme
  static InputDecorationTheme lightTextFieldTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: Colors.grey,
    suffixIconColor: Colors.grey,

    labelStyle: const TextStyle(
      fontSize: 14,
      color: Colors.black,
    ),

    hintStyle: const TextStyle(
      fontSize: 14,
      color: Colors.grey,
    ),

    floatingLabelStyle: TextStyle(
      color: Colors.black.withValues(alpha: 0.8),
    ),

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(
        width: 1,
        color: Colors.grey,
      ),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(
        width: 1,
        color: Colors.black12,
      ),
    ),

    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(
        width: 1,
        color: Colors.red,
      ),
    ),

    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(
        width: 2,
        color: Colors.orange,
      ),
    ),
  );

  /// Dark Theme
  static InputDecorationTheme darkTextFieldTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: Colors.grey,
    suffixIconColor: Colors.grey,

    labelStyle: const TextStyle(
      fontSize: 14,
      color: Colors.white,
    ),

    hintStyle: const TextStyle(
      fontSize: 14,
      color: Colors.white70,
    ),

    floatingLabelStyle: TextStyle(
      color: Colors.white.withValues(alpha: 0.8),
    ),

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(
        width: 1,
        color: Colors.grey,
      ),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(
        width: 1,
        color: Colors.white,
      ),
    ),

    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(
        width: 1,
        color: Colors.red,
      ),
    ),

    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(
        width: 2,
        color: Colors.orange,
      ),
    ),
  );
}