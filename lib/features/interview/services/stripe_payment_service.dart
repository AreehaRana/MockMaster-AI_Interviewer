import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';

/// Handles paying for a custom interview via Stripe's test-mode Payment
/// Sheet. The secret key never lives here or anywhere in the app -- this
/// only talks to the Cloudflare Worker, which holds the secret key
/// server-side, and then shows Stripe's own built-in UI to actually
/// collect card details.
class StripePaymentService {
  StripePaymentService._();

  static const String _workerUrl =
      'https://payment-worker.mockmaster001.workers.dev';

  /// Charges [amountInRupees] (e.g. 199.0 from MPricingCalculator) for
  /// one custom interview.
  ///
  /// Returns true if the payment succeeded, false if the user closed the
  /// sheet without paying (not an error -- just cancelled), and throws
  /// for genuine failures (network, declined card, etc.) so the caller
  /// can show an error message.
  static Future<bool> payForCustomInterview(double amountInRupees) async {
    // STEP 1: ask the server (Cloudflare Worker) to create a PaymentIntent.
    // Stripe amounts are always in the smallest currency unit.
    final res = await http.post(
      Uri.parse(_workerUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'amount': (amountInRupees * 100).round(),
        'currency': 'pkr',
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to create payment intent: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final clientSecret = data['clientSecret'] as String;

    // STEP 2: initialize Stripe's own Payment Sheet with that secret.
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'MockMaster',
      ),
    );

    // STEP 3: show the sheet. Stripe's UI collects card details directly
    // -- this app never touches raw card numbers.
    try {
      await Stripe.instance.presentPaymentSheet();
      return true; // payment completed
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return false; // user closed the sheet -- not an error
      }
      rethrow; // real failure (declined card, network, etc.)
    }
  }
}