class MPricingCalculator {
  // Price per Custom AI Interview (PKR)
  static const double customInterviewPrice = 199.0;

  static double getDiscount(int quantity) {
    if (quantity >= 20) {
      return 0.20;
    } else if (quantity >= 10) {
      return 0.15;
    } else if (quantity >= 5) {
      return 0.10;
    }
    return 0.0;
  }

  static double calculateTotalPrice(int quantity) {
    double total = quantity * customInterviewPrice;
    double discount = total * getDiscount(quantity);
    return total - discount;
  }

  static String getFormattedPrice(int quantity) {
    return "Rs. ${calculateTotalPrice(quantity).toStringAsFixed(0)}";
  }

  static bool isFreeInterview(String type) {
    return type.toLowerCase() == "basic";
  }

  static bool isPaidInterview(String type) {
    return type.toLowerCase() == "custom";
  }
}
