class MValidator {
  ///Empty text validation
  static String?validateEmptyText(String? fieldName, String? value) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }
  /// Email Validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }

    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegExp.hasMatch(value)) {
      return 'Invalid email address.';
    }

    return null;
  }

  /// Password Validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }

    // Minimum length
    if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }

    // Uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter.';
    }

    // Lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter.';
    }

    // Number
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number.';
    }

    // Special character
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character.';
    }

    return null;
  }

  /// Pakistani Phone Number Validation
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required.';
    }

    final phoneRegExp = RegExp(r'^03[0-9]{9}$');

    if (!phoneRegExp.hasMatch(value)) {
      return 'Enter a valid Pakistani phone number.';
    }

    return null;
  }

  /// Name Validation — used for first name, second name, etc.
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required.';
    }

    final name = value.trim();

    if (name.length < 3) {
      return 'Name must be at least 3 characters.';
    }

    // Reject all-digit input like "00000"
    if (RegExp(r'^[0-9]+$').hasMatch(name)) {
      return 'Name cannot be only numbers.';
    }

    // Must start and end with a letter; letters/spaces/hyphens/apostrophes allowed in between
    if (!RegExp(r"^[A-Za-z][A-Za-z' -]*[A-Za-z]$").hasMatch(name)) {
      return 'Enter a valid name.';
    }

    return null;
  }

  /// Username Validation
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required.';
    }

    final username = value.trim();

    if (username.length < 3) {
      return 'Username must be at least 3 characters.';
    }

    // Reject all-digit input like "00000"
    if (RegExp(r'^[0-9]+$').hasMatch(username)) {
      return 'Username cannot be only numbers.';
    }

    // Must start with a letter and end with a letter/number (never underscore or symbol)
    if (!RegExp(r'^[A-Za-z][A-Za-z0-9_]*[A-Za-z0-9]$').hasMatch(username)) {
      return "Username can't start or end with a special character.";
    }

    return null;
  }

  /// Required Field Validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }

    return null;
  }

  /// Confirm Password Validation
  static String? validateConfirmPassword(
    String? password,
    String? confirmPassword,
  ) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Confirm Password is required.';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match.';
    }

    return null;
  }
}