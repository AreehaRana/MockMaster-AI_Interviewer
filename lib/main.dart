import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:mockmaster/app.dart';
import 'package:mockmaster/data/repositories/repositories.authentication/authentication_repository.dart';
import 'package:mockmaster/firebase_options.dart';

/// Entry point of Flutter App
Future<void> main() async {
  // Widgets Binding
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();

  // Load .env (GEMINI_API_KEY etc.) before anything tries to read it --
  // GeminiQuestionService and ChatbotAiService both depend on this
  // having already run.
  await dotenv.load(fileName: ".env");

  // TEMPORARY DEBUG -- remove once the key loads correctly.
  debugPrint('DOTENV LOADED KEYS: ${dotenv.env.keys.toList()}');
  debugPrint('STRIPE KEY VALUE: "${dotenv.env['STRIPE_PUBLISHABLE_KEY']}"');

  // GetX Local Storage
  await GetStorage.init();

  // Await Splash until other items load
  FlutterNativeSplash.preserve(
    widgetsBinding: widgetsBinding,
  );

  // Initialize Firebase & Authentication Repository
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then(
    (FirebaseApp value) => Get.put(AuthenticationRepository()),
  );

  // Initialize Stripe -- must happen before any screen tries to use
  // Stripe.instance.initPaymentSheet / presentPaymentSheet.
  // NOTE: dotenv.env[...] takes the VARIABLE NAME (as written in .env),
  // not the key value itself -- make sure .env has a line like:
  //   STRIPE_PUBLISHABLE_KEY=pk_test_...
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  await Stripe.instance.applySettings();

  // Load all the Material Design / Themes / Localizations / Bindings
  runApp(const App());
}