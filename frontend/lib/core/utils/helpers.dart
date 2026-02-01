import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class Helpers {
  // Formatters
  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, HH:mm');
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );
  
  // Format date to readable string
  static String formatDate(DateTime date, {bool includeTime = false}) {
    try {
      if (includeTime) {
        return _dateTimeFormat.format(date);
      }
      return _dateFormat.format(date);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  // Format date from string
  static String formatDateFromString(String dateString, {bool includeTime = false}) {
    try {
      final date = DateTime.parse(dateString);
      return formatDate(date, includeTime: includeTime);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  // Format currency
  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  // Format number with commas
  static String formatNumber(int number) {
    return NumberFormat.decimalPattern().format(number);
  }

  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // Calculate discount percentage
  static double calculateDiscount(double originalPrice, double salePrice) {
    if (originalPrice <= 0) return 0;
    return ((originalPrice - salePrice) / originalPrice) * 100;
  }

  // Generate initials from name
  static String getInitials(String name) {
    if (name.isEmpty) return 'U';
    
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    
    return '${parts[0].substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
  }

  // Validate Indonesian phone number
  static bool isValidIndonesianPhone(String phone) {
    final regex = RegExp(r'^(\+62|62|0)8[1-9][0-9]{6,9}$');
    return regex.hasMatch(phone);
  }

  // Validate URL
  static bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return true;
    } catch (_) {
      return false;
    }
  }

  // Capitalize first letter of each word
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    
    return text
        .toLowerCase()
        .split(' ')
        .map((word) => word.isNotEmpty 
            ? word[0].toUpperCase() + word.substring(1) 
            : '')
        .join(' ');
  }

  // Truncate text with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Mask email for privacy
  static String maskEmail(String email) {
    if (email.isEmpty || !email.contains('@')) return email;
    
    final parts = email.split('@');
    if (parts.length != 2) return email;
    
    final username = parts[0];
    final domain = parts[1];
    
    if (username.length <= 2) {
      return '***@$domain';
    }
    
    final maskedUsername = '${username[0]}***${username.substring(username.length - 1)}';
    return '$maskedUsername@$domain';
  }

  // Format duration to readable string
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} days';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hours';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minutes';
    } else {
      return '${duration.inSeconds} seconds';
    }
  }

  // Generate random color based on string
  static Color generateColorFromString(String text) {
    if (text.isEmpty) return Colors.blue;
    
    int hash = 0;
    for (int i = 0; i < text.length; i++) {
      hash = text.codeUnitAt(i) + ((hash << 5) - hash);
    }
    
    final hue = hash.abs() % 360;
    return HSVColor.fromAHSV(1.0, hue.toDouble(), 0.7, 0.9).toColor();
  }

  // Check if string contains any emoji
  static bool containsEmoji(String text) {
    final regex = RegExp(
      r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'
    );
    return regex.hasMatch(text);
  }

  // Format price range
  static String formatPriceRange(double minPrice, double maxPrice) {
    if (minPrice == maxPrice) {
      return formatCurrency(minPrice);
    }
    return '${formatCurrency(minPrice)} - ${formatCurrency(maxPrice)}';
  }

  // URL Launcher
  static Future<bool> launchUrl(String url, {LaunchMode mode = LaunchMode.platformDefault}) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: mode);
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // Launch phone call
  static Future<bool> launchPhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    return launchUrl(url);
  }

  // Launch email
  static Future<bool> launchEmail(String email, {String? subject, String? body}) async {
    String url = 'mailto:$email';
    
    final params = <String>[];
    if (subject != null) params.add('subject=${Uri.encodeComponent(subject)}');
    if (body != null) params.add('body=${Uri.encodeComponent(body)}');
    
    if (params.isNotEmpty) {
      url += '?${params.join('&')}';
    }
    
    return launchUrl(url);
  }

  // Launch maps
  static Future<bool> launchMaps(String address) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}';
    return launchUrl(url);
  }

  // Check internet connectivity
  static Future<bool> hasInternetConnection() async {
    final connectivity = Connectivity();
    final result = await connectivity.checkConnectivity();
    
    return result != ConnectivityResult.none;
  }

  // Get connectivity status
  static Future<String> getConnectivityStatus() async {
    final connectivity = Connectivity();
    final result = await connectivity.checkConnectivity();
    
    switch (result) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.other:
        return 'Other';
      default:
        return 'No Connection';
    }
  }

  // Debounce function
  static Function debounce(Function func, Duration wait) {
    Timer? timer;
    
    return () {
      timer?.cancel();
      timer = Timer(wait, () => func());
    };
  }

  // Throttle function
  static Function throttle(Function func, Duration limit) {
    bool waiting = false;
    
    return () {
      if (!waiting) {
        func();
        waiting = true;
        Timer(limit, () => waiting = false);
      }
    };
  }

  // Calculate age from birth date
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    
    return age;
  }

  // Generate order ID
  static String generateOrderId() {
    final now = DateTime.now();
    final random = now.microsecondsSinceEpoch % 10000;
    return 'ORD${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${random.toString().padLeft(4, '0')}';
  }

  // Validate credit card expiry date
  static bool isValidCreditCardExpiry(String expiry) {
    final regex = RegExp(r'^(0[1-9]|1[0-2])\/?([0-9]{2})$');
    if (!regex.hasMatch(expiry)) return false;
    
    final parts = expiry.split('/');
    final month = int.tryParse(parts[0]);
    final year = int.tryParse('20${parts[1]}');
    
    if (month == null || year == null) return false;
    
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;
    
    if (year < currentYear) return false;
    if (year == currentYear && month < currentMonth) return false;
    
    return true;
  }

  // Calculate distance between two coordinates (in kilometers)
  static double calculateDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    const earthRadius = 6371; // Radius of the earth in km
    
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
        cos(_degreesToRadians(lat2)) *
        sin(dLon / 2) *
        sin(dLon / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = earthRadius * c;
    
    return distance;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  // Get device info helper
  static Map<String, String> getDeviceInfo() {
    return {
      'platform': '${Theme.of(navigatorKey.currentContext!).platform}',
      'locale': Intl.systemLocale,
      'timezone': DateTime.now().timeZoneName,
    };
  }

  // Navigation key for accessing context from anywhere
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Show snackbar from anywhere
  static void showSnackBar(String message, {bool isError = false, int duration = 3}) {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: duration),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Show dialog from anywhere
  static Future<void> showAlertDialog({
    required String title,
    required String message,
    String confirmText = 'OK',
    VoidCallback? onConfirm,
  }) async {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm?.call();
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  // Show loading dialog
  static void showLoadingDialog({String message = 'Loading...'}) {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  // Hide loading dialog
  static void hideLoadingDialog() {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    
    Navigator.of(context, rootNavigator: true).pop();
  }

  // Copy to clipboard
  static Future<void> copyToClipboard(String text, {String? successMessage}) async {
    await Clipboard.setData(ClipboardData(text: text));
    
    if (successMessage != null) {
      showSnackBar(successMessage);
    }
  }

  // Get time ago string
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Calculate reading time
  static String calculateReadingTime(String text, {int wordsPerMinute = 200}) {
    final wordCount = text.split(RegExp(r'\s+')).length;
    final readingTimeMinutes = (wordCount / wordsPerMinute).ceil();
    
    if (readingTimeMinutes == 0) {
      return 'Less than a minute';
    } else if (readingTimeMinutes == 1) {
      return '1 minute';
    } else {
      return '$readingTimeMinutes minutes';
    }
  }

  // Generate avatar color based on user ID
  static Color getAvatarColor(String userId) {
    if (userId.isEmpty) return Colors.blue;
    
    final colors = [
      Colors.red.shade300,
      Colors.blue.shade300,
      Colors.green.shade300,
      Colors.orange.shade300,
      Colors.purple.shade300,
      Colors.pink.shade300,
      Colors.teal.shade300,
      Colors.cyan.shade300,
      Colors.indigo.shade300,
    ];
    
    int hash = 0;
    for (int i = 0; i < userId.length; i++) {
      hash = userId.codeUnitAt(i) + ((hash << 5) - hash);
    }
    
    final index = hash.abs() % colors.length;
    return colors[index];
  }

  // Validate strong password
  static bool isStrongPassword(String password) {
    if (password.length < 8) return false;
    
    final hasUpperCase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowerCase = RegExp(r'[a-z]').hasMatch(password);
    final hasDigits = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecialChars = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    
    return hasUpperCase && hasLowerCase && hasDigits && hasSpecialChars;
  }

  // Get password strength score
  static int getPasswordStrength(String password) {
    int score = 0;
    
    if (password.length >= 8) score += 1;
    if (password.length >= 12) score += 1;
    
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 1;
    if (RegExp(r'[a-z]').hasMatch(password)) score += 1;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 1;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score += 1;
    
    return score;
  }

  // Get password strength text
  static String getPasswordStrengthText(String password) {
    final score = getPasswordStrength(password);
    
    if (score <= 2) return 'Weak';
    if (score <= 4) return 'Fair';
    if (score <= 5) return 'Good';
    return 'Strong';
  }

  // Get password strength color
  static Color getPasswordStrengthColor(String password) {
    final score = getPasswordStrength(password);
    
    if (score <= 2) return Colors.red;
    if (score <= 4) return Colors.orange;
    if (score <= 5) return Colors.blue;
    return Colors.green;
  }

  // Format product SKU
  static String formatProductSku(String sku) {
    if (sku.isEmpty) return 'N/A';
    
    // Remove all non-alphanumeric characters
    final cleaned = sku.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    
    // Format as XXXX-XXXX-XXXX
    if (cleaned.length >= 12) {
      return '${cleaned.substring(0, 4)}-${cleaned.substring(4, 8)}-${cleaned.substring(8, 12)}';
    }
    
    return cleaned;
  }

  // Calculate cart summary
  static Map<String, dynamic> calculateCartSummary(List<Map<String, dynamic>> cartItems) {
    double subtotal = 0;
    double tax = 0;
    double shipping = 0;
    int totalItems = 0;
    
    for (final item in cartItems) {
      final quantity = item['quantity'] as int;
      final price = (item['price'] as num).toDouble();
      
      subtotal += price * quantity;
      totalItems += quantity;
    }
    
    tax = subtotal * 0.1; // 10% tax
    shipping = subtotal > 100 ? 0 : 10; // Free shipping over $100
    
    return {
      'subtotal': subtotal,
      'tax': tax,
      'shipping': shipping,
      'total': subtotal + tax + shipping,
      'totalItems': totalItems,
      'hasFreeShipping': subtotal > 100,
    };
  }

  // Generate QR code data
  static String generateQrCodeData(Map<String, dynamic> data) {
    final jsonString = data.entries
        .map((entry) => '${entry.key}:${entry.value}')
        .join('|');
    return 'ECOMMERCE:$jsonString';
  }

  // Parse QR code data
  static Map<String, String> parseQrCodeData(String qrData) {
    if (!qrData.startsWith('ECOMMERCE:')) {
      return {'error': 'Invalid QR code format'};
    }
    
    final data = qrData.substring(10);
    final pairs = data.split('|');
    
    final result = <String, String>{};
    for (final pair in pairs) {
      final parts = pair.split(':');
      if (parts.length == 2) {
        result[parts[0]] = parts[1];
      }
    }
    
    return result;
  }

  // Check if time is within business hours
  static bool isWithinBusinessHours(DateTime time, {int openHour = 9, int closeHour = 17}) {
    final hour = time.hour;
    final day = time.weekday;
    
    // Monday to Friday, 9 AM to 5 PM
    return day >= DateTime.monday && 
           day <= DateTime.friday && 
           hour >= openHour && 
           hour < closeHour;
  }

  // Get next business day
  static DateTime getNextBusinessDay(DateTime date) {
    DateTime nextDay = date.add(const Duration(days: 1));
    
    while (nextDay.weekday == DateTime.saturday || nextDay.weekday == DateTime.sunday) {
      nextDay = nextDay.add(const Duration(days: 1));
    }
    
    return nextDay;
  }

  // Format phone number for display
  static String formatPhoneNumber(String phone) {
    if (phone.isEmpty) return '';
    
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleaned.length == 10) {
      return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
    } else if (cleaned.length == 11) {
      return '+${cleaned.substring(0, 1)} (${cleaned.substring(1, 4)}) ${cleaned.substring(4, 7)}-${cleaned.substring(7)}';
    }
    
    return phone;
  }

  // Generate random string
  static String generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  // Calculate delivery estimate
  static String calculateDeliveryEstimate(DateTime orderDate, {int businessDays = 3}) {
    DateTime estimate = orderDate;
    int daysAdded = 0;
    
    while (daysAdded < businessDays) {
      estimate = estimate.add(const Duration(days: 1));
      
      if (estimate.weekday != DateTime.saturday && estimate.weekday != DateTime.sunday) {
        daysAdded++;
      }
    }
    
    return formatDate(estimate);
  }

  // Validate image URL
  static bool isValidImageUrl(String url) {
    if (!isValidUrl(url)) return false;
    
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.svg'];
    final lowerUrl = url.toLowerCase();
    
    return imageExtensions.any((ext) => lowerUrl.endsWith(ext));
  }

  // Get file extension from URL
  static String getFileExtension(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      
      if (path.contains('.')) {
        return path.split('.').last.toLowerCase();
      }
    } catch (_) {
      // Ignore error
    }
    
    return '';
  }

  // Check if file is image by extension
  static bool isImageFile(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'tiff'];
    
    return imageExtensions.contains(ext);
  }

  // Check if file is video by extension
  static bool isVideoFile(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    const videoExtensions = ['mp4', 'avi', 'mov', 'wmv', 'flv', 'mkv', 'webm'];
    
    return videoExtensions.contains(ext);
  }

  // Calculate average rating
  static double calculateAverageRating(List<int> ratings) {
    if (ratings.isEmpty) return 0;
    
    final sum = ratings.reduce((a, b) => a + b);
    return sum / ratings.length;
  }

  // Get rating stars
  static List<Widget> getRatingStars(double rating, {double size = 16}) {
    final fullStars = rating.floor();
    final hasHalfStar = rating - fullStars >= 0.5;
    
    final stars = <Widget>[];
    
    for (int i = 0; i < fullStars; i++) {
      stars.add(Icon(Icons.star, color: Colors.amber, size: size));
    }
    
    if (hasHalfStar) {
      stars.add(Icon(Icons.star_half, color: Colors.amber, size: size));
    }
    
    final emptyStars = 5 - stars.length;
    for (int i = 0; i < emptyStars; i++) {
      stars.add(Icon(Icons.star_border, color: Colors.grey, size: size));
    }
    
    return stars;
  }

  // Get pagination info
  static Map<String, dynamic> getPaginationInfo(
    int currentPage,
    int totalItems,
    int itemsPerPage,
  ) {
    final totalPages = (totalItems / itemsPerPage).ceil();
    final hasPrevious = currentPage > 1;
    final hasNext = currentPage < totalPages;
    final startItem = ((currentPage - 1) * itemsPerPage) + 1;
    final endItem = currentPage * itemsPerPage;
    
    return {
      'currentPage': currentPage,
      'totalPages': totalPages,
      'hasPrevious': hasPrevious,
      'hasNext': hasNext,
      'startItem': startItem,
      'endItem': endItem > totalItems ? totalItems : endItem,
      'totalItems': totalItems,
    };
  }

  // Validate Indonesian ID card (KTP)
  static bool isValidIndonesianKtp(String ktp) {
    // Format: 16 digits
    if (ktp.length != 16) return false;
    
    // Must be all digits
    if (!RegExp(r'^\d{16}$').hasMatch(ktp)) return false;
    
    // First 6 digits: Province, Regency, District code
    // Next 6 digits: Birth date (DDMMYY)
    // Next 4 digits: Serial number
    
    return true;
  }

  // Validate Indonesian postal code
  static bool isValidIndonesianPostalCode(String postalCode) {
    // Format: 5 digits
    return RegExp(r'^\d{5}$').hasMatch(postalCode);
  }

  // Get Indonesian province from postal code (simplified)
  static String getIndonesianProvinceFromPostalCode(String postalCode) {
    if (postalCode.length != 5) return 'Unknown';
    
    final firstTwoDigits = postalCode.substring(0, 2);
    
    final provinceMap = {
      '10': 'Jakarta',
      '11': 'Aceh',
      '12': 'Sumatera Utara',
      '13': 'Sumatera Barat',
      '14': 'Riau',
      '15': 'Jambi',
      '16': 'Sumatera Selatan',
      '17': 'Bengkulu',
      '18': 'Lampung',
      '19': 'Kepulauan Bangka Belitung',
      '20': 'Kepulauan Riau',
      '21': 'Banten',
      '22': 'Jawa Barat',
      '23': 'Jawa Tengah',
      '24': 'DI Yogyakarta',
      '25': 'Jawa Timur',
      '26': 'Bali',
      '27': 'Nusa Tenggara Barat',
      '28': 'Nusa Tenggara Timur',
      '29': 'Kalimantan Barat',
      '30': 'Kalimantan Tengah',
      '31': 'Kalimantan Selatan',
      '32': 'Kalimantan Timur',
      '33': 'Kalimantan Utara',
      '70': 'Sulawesi Utara',
      '71': 'Sulawesi Tengah',
      '72': 'Sulawesi Selatan',
      '73': 'Sulawesi Tenggara',
      '74': 'Gorontalo',
      '75': 'Sulawesi Barat',
      '76': 'Maluku',
      '77': 'Maluku Utara',
      '80': 'Papua',
      '81': 'Papua Barat',
    };
    
    return provinceMap[firstTwoDigits] ?? 'Unknown';
  }

  // Color utilities
  static Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    
    return hslDark.toColor();
  }

  static Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    
    return hslLight.toColor();
  }

  // Get contrast color (black or white)
  static Color getContrastColor(Color backgroundColor) {
    // Calculate relative luminance
    final luminance = (0.299 * backgroundColor.red + 
                      0.587 * backgroundColor.green + 
                      0.114 * backgroundColor.blue) / 255;
    
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  // Generate gradient colors
  static List<Color> generateGradientColors(Color baseColor, int steps) {
    final colors = <Color>[];
    
    for (int i = 0; i < steps; i++) {
      final factor = i / (steps - 1);
      colors.add(Color.lerp(baseColor, Colors.white, factor)!);
    }
    
    return colors;
  }
}

// Extension methods for DateTime
extension DateTimeExtensions on DateTime {
  String toFormattedString({bool includeTime = false}) {
    return Helpers.formatDate(this, includeTime: includeTime);
  }

  String get timeAgo {
    return Helpers.timeAgo(this);
  }

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && 
           month == yesterday.month && 
           day == yesterday.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && 
           month == tomorrow.month && 
           day == tomorrow.day;
  }

  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  int get daysSince {
    final now = DateTime.now();
    return now.difference(this).inDays;
  }
}

// Extension methods for String
extension StringExtensions on String {
  bool get isNullOrEmpty => isEmpty;

  bool get isNotNullOrEmpty => !isEmpty;

  String get capitalize => Helpers.capitalizeWords(this);

  String get initials => Helpers.getInitials(this);

  String get maskedEmail => Helpers.maskEmail(this);

  String truncate(int maxLength) => Helpers.truncateText(this, maxLength);

  bool get isValidEmail => Helpers.isValidEmail(this);

  bool get isValidUrl => Helpers.isValidUrl(this);

  bool get isValidImageUrl => Helpers.isValidImageUrl(this);

  bool get isStrongPassword => Helpers.isStrongPassword(this);

  String get passwordStrengthText => Helpers.getPasswordStrengthText(this);

  Color get passwordStrengthColor => Helpers.getPasswordStrengthColor(this);

  double? get tryParseDouble => double.tryParse(this);

  int? get tryParseInt => int.tryParse(this);

  DateTime? get tryParseDateTime {
    try {
      return DateTime.parse(this);
    } catch (_) {
      return null;
    }
  }

  Color get toColorFromString => Helpers.generateColorFromString(this);

  String get toPhoneFormatted => Helpers.formatPhoneNumber(this);

  bool get containsEmoji => Helpers.containsEmoji(this);
}

// Extension methods for double
extension DoubleExtensions on double {
  String get toCurrency => Helpers.formatCurrency(this);

  String get toRoundedString => toStringAsFixed(2);

  String get toPercentage => '${toStringAsFixed(1)}%';

  double get toRounded => double.parse(toStringAsFixed(2));

  bool get isZero => this == 0;

  bool get isPositive => this > 0;

  bool get isNegative => this < 0;
}

// Extension methods for int
extension IntExtensions on int {
  String get toFormattedNumber => Helpers.formatNumber(this);

  String get toFileSize => Helpers.formatFileSize(this);

  Duration get seconds => Duration(seconds: this);

  Duration get minutes => Duration(minutes: this);

  Duration get hours => Duration(hours: this);

  Duration get days => Duration(days: this);

  String get toOrdinal {
    if (this % 100 >= 11 && this % 100 <= 13) {
      return '${this}th';
    }

    switch (this % 10) {
      case 1: return '${this}st';
      case 2: return '${this}nd';
      case 3: return '${this}rd';
      default: return '${this}th';
    }
  }
}

// Extension methods for List
extension ListExtensions<T> on List<T> {
  List<T> get unique {
    return toSet().toList();
  }

  List<T> paginate(int page, int limit) {
    final start = (page - 1) * limit;
    final end = start + limit;
    
    if (start >= length) return [];
    if (end > length) return sublist(start);
    
    return sublist(start, end);
  }

  bool containsAll(List<T> other) {
    for (final item in other) {
      if (!contains(item)) return false;
    }
    return true;
  }

  T? get firstOrNull => isEmpty ? null : first;

  T? get lastOrNull => isEmpty ? null : last;

  List<T> whereNotNull() {
    return where((item) => item != null).cast<T>().toList();
  }

  Map<K, List<T>> groupBy<K>(K Function(T) keySelector) {
    final map = <K, List<T>>{};
    
    for (final item in this) {
      final key = keySelector(item);
      map.putIfAbsent(key, () => []).add(item);
    }
    
    return map;
  }
}

// Extension methods for Map
extension MapExtensions<K, V> on Map<K, V> {
  Map<K, V> get copy => Map<K, V>.from(this);

  Map<K, V> where(bool Function(K key, V value) predicate) {
    final result = <K, V>{};
    
    forEach((key, value) {
      if (predicate(key, value)) {
        result[key] = value;
      }
    });
    
    return result;
  }

  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(K key, V value) transform) {
    final result = <K2, V2>{};
    
    forEach((key, value) {
      final entry = transform(key, value);
      result[entry.key] = entry.value;
    });
    
    return result;
  }

  void removeWhereValue(bool Function(V value) predicate) {
    final keysToRemove = <K>[];
    
    forEach((key, value) {
      if (predicate(value)) {
        keysToRemove.add(key);
      }
    });
    
    for (final key in keysToRemove) {
      remove(key);
    }
  }
}

// Random number generator
class Random {
  final _random = math.Random();

  int nextInt(int max) => _random.nextInt(max);
  
  double nextDouble() => _random.nextDouble();
  
  bool nextBool() => _random.nextBool();
  
  String nextString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(_random.nextInt(chars.length)),
      ),
    );
  }
}

// Global instance
final random = Random();