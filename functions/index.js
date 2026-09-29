// ============================================================
// Add this to your EXISTING functions/index.js (don't overwrite
// the file — just add this import + function alongside what's
// already there, e.g. below Firebase's sample "helloWorld" code).
// ============================================================

const functions = require("firebase-functions");

// The secret key is loaded from functions/.env (see setup below),
// NEVER hardcoded here. Firebase's 2nd-gen runtime automatically
// loads a .env file sitting next to index.js.
const stripe = require("stripe")(process.env.STRIPE_SECRET);

/// Creates a Stripe PaymentIntent for one custom-interview purchase.
/// The Flutter app calls this via cloud_functions, gets back a
/// client secret, and hands that to Stripe's built-in Payment Sheet
/// UI — the app itself never sees or handles raw card details.
exports.createPaymentIntent = functions.https.onCall(async (data, context) => {
  const amount = data.amount; // smallest currency unit (e.g. paisa for PKR)
  const currency = data.currency || "pkr";

  if (!amount || amount <= 0) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "amount must be a positive integer in the smallest currency unit."
    );
  }

  const paymentIntent = await stripe.paymentIntents.create({
    amount,
    currency,
    // Automatic payment methods keeps this working with Stripe's
    // test-mode card, without listing payment method types by hand.
    automatic_payment_methods: { enabled: true },
  });

  return { clientSecret: paymentIntent.client_secret };
});