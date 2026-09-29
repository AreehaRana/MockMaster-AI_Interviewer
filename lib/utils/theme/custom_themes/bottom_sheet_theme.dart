import 'package:flutter/material.dart';

class MBottomSheetTheme {
  MBottomSheetTheme._();

  static BottomSheetThemeData lightBottomSheetTheme =
      const BottomSheetThemeData(
        backgroundColor: Colors.white,
        showDragHandle: true,
        modalBackgroundColor: Colors.white,
        constraints: BoxConstraints(minWidth: double.infinity),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      );

  static BottomSheetThemeData darkBottomSheetTheme = const BottomSheetThemeData(
    backgroundColor: Colors.black,
    showDragHandle: true,
    modalBackgroundColor: Colors.black,
    constraints: BoxConstraints(minWidth: double.infinity),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  );
}
