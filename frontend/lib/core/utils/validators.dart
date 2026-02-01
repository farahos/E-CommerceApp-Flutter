class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email ayaa lagama maarmaan ah';
    }
    
    final emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      caseSensitive: false,
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Fadlan geli email sax ah';
    }
    
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password ayaa lagama maarmaan ah';
    }
    
    if (value.length < 6) {
      return 'Password-ku waa inuu ka kooban yahay 6 xaraf ama ka badan';
    }
    
    return null;
  }

  static String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Fadlan ku celi password-ka';
    }
    
    if (password != confirmPassword) {
      return 'Password-yaadu ma isku mid yihiin';
    }
    
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName ayaa lagama maarmaan ah';
    }
    
    return null;
  }

  static String? validateNumber(String? value, {String fieldName = 'Tiro'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName ayaa lagama maarmaan ah';
    }
    
    final parsed = double.tryParse(value);
    if (parsed == null) {
      return 'Fadlan geli tiro sax ah';
    }
    
    if (parsed < 0) {
      return '$fieldName kama yaraan 0';
    }
    
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Magaca isticmaalaha waa lagama maarmaan';
    }
    
    if (value.length < 3) {
      return 'Magaca isticmaalaha waa inuu ka kooban yahay 3 xaraf ama ka badan';
    }
    
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefoonka ayaa lagama maarmaan ah';
    }
    
    final phoneRegex = RegExp(r'^[0-9+]{8,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Fadlan geli lambar telefoon sax ah';
    }
    
    return null;
  }
}