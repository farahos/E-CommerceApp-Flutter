class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'please enter an email';
    }
    
    final emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      caseSensitive: false,
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'please enter a valid email address';
    }
    
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'please enter a password';
    }
    
    if (value.length < 4) {
      return 'Password must be at least 4 characters long';
    }
    
    return null;
  }

  static String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'please confirm your password';
    }
    
    if (password != confirmPassword) {
      return 'passwords do not match';
    }
    
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    return null;
  }

  static String? validateNumber(String? value, {String fieldName = 'Tiro'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    final parsed = double.tryParse(value);
    if (parsed == null) {
      return 'please enter a valid number';
    }
    
    if (parsed < 0) {
      return '$fieldName must be greater than or equal to 0';
    }
    
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'please enter a username';
    }
    
    if (value.length < 3) {
      return 'Username must be at least 3 characters long';
    }
    
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'please enter a phone number';
    }
    
    final phoneRegex = RegExp(r'^[0-9+]{8,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'please enter a valid phone number';
    }
    
    return null;
  }
}