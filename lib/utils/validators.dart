/// Centralized validation logic for user inputs
class Validators {
  /// Validate name (first name or last name)
  static String? validateName(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate both first and last names together
  static String? validateFullName(String? firstName, String? lastName) {
    if (firstName == null || firstName.trim().isEmpty) {
      return 'First name is required';
    }
    if (lastName == null || lastName.trim().isEmpty) {
      return 'Last name is required';
    }
    return null;
  }

  /// Validate Philippine phone number
  static String? validatePhoneNumber(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!phone.trim().startsWith('+63')) {
      return 'Valid Philippine phone number is required';
    }
    return null;
  }

  /// Validate password
  static String? validatePassword(String? password, {int minLength = 6}) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  /// Validate non-empty field with custom field name
  static String? validateNonEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate authentication required (user ID)
  static String? validateAuthRequired(String? userId) {
    if (userId == null || userId.trim().isEmpty) {
      return 'User authentication required';
    }
    return null;
  }
}

