import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mockmaster/utils/constants/colors.dart';
import 'package:mockmaster/utils/theme/theme.dart';
import'package:mockmaster/bindings/general_bindings.dart';

/// use this class to setup themes initial binding any animation and much more

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: MAppTheme.lightTheme,
      darkTheme: MAppTheme.darkTheme,
      initialBinding: GeneralBindings(),
      home: const Scaffold(backgroundColor: MColors.primaryColor,body:Center(child:CircularProgressIndicator(color:Colors.white)))
    );
  }
}