class AppValidators {
  static final RegExp _emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$');

  static String? validateRequired(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateEmail(String? v) {
    if (v == null || v.isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(v)) return 'Please enter a valid email';
    return null;
  }

  static String? validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Password must be at least 8 characters';
    if (!v.contains(RegExp(r'[A-Z]'))) {
      return 'Password must include an uppercase letter';
    }
    if (!v.contains(RegExp(r'[a-z]'))) {
      return 'Password must include a lowercase letter';
    }
    if (!v.contains(RegExp(r'[0-9]'))) {
      return 'Password must include a number';
    }
    if (!v.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_]'))) {
      return 'Password must include a special character';
    }
    return null;
  }

  static String? validateConfirmPassword(
    String? value, {
    required String password,
  }) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? sanitizeAndValidateEmail(String? v) {
    if (v == null || v.isEmpty) return 'Email is required';
    final sanitized = v.trim().toLowerCase().replaceAll(RegExp(r'\s'), '');
    if (!_emailRegex.hasMatch(sanitized)) return 'Please enter a valid email';
    return null;
  }
}
