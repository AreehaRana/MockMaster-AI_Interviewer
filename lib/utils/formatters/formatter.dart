import 'package:intl/intl.dart';

class MFormatter {
  /// Format Date
  static String formatDate(DateTime? date) {
    date ??= DateTime.now();
    return DateFormat('dd-MMM-yyyy').format(date);
  }

  /// Format Currency (PKR)
  static String formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'en_PK',
      symbol: 'Rs. ',
      decimalDigits: 2,
    ).format(amount);
  }

  /// Format Pakistani Phone Number
  /// Example:
  /// 03001234567 -> 0300 1234567
  /// 923001234567 -> +92 300 1234567
  static String formatPhoneNumber(String phoneNumber) {
    // Remove everything except digits
    phoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Local Pakistani Number
    if (phoneNumber.length == 11) {
      return '${phoneNumber.substring(0, 4)} ${phoneNumber.substring(4)}';
    }

    // International Pakistani Number
    if (phoneNumber.length == 12 && phoneNumber.startsWith('92')) {
      return '+92 ${phoneNumber.substring(2, 5)} ${phoneNumber.substring(5)}';
    }

    return phoneNumber;
  }

  /// International Phone Number Formatter
  ///
  /// Example:
  /// +923001234567 -> (+92) 30 01 23 45 67
  /// +11234567890  -> (+1) 123 45 67 89 0
  ///
  /// Not fully tested.
  static String internationalFormatPhoneNumber(String phoneNumber) {
    // Remove non-digit characters
    var digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Return original if too short
    if (digitsOnly.length < 3) return phoneNumber;

    // Extract country code
    String countryCode = '+${digitsOnly.substring(0, 2)}';
    digitsOnly = digitsOnly.substring(2);

    // Build formatted number
    final formattedNumber = StringBuffer();
    formattedNumber.write('($countryCode) ');

    int i = 0;

    while (i < digitsOnly.length) {
      int groupLength = 2;

      // USA numbers start with 3 digits after +1
      if (i == 0 && countryCode == '+1') {
        groupLength = 3;
      }

      int end = i + groupLength;

      if (end > digitsOnly.length) {
        end = digitsOnly.length;
      }

      formattedNumber.write(digitsOnly.substring(i, end));

      if (end < digitsOnly.length) {
        formattedNumber.write(' ');
      }

      i = end;
    }

    return formattedNumber.toString();
  }
}