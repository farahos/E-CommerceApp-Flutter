import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_app/providers/auth_provider.dart';
import 'package:your_app/providers/product_provider.dart';
import 'package:your_app/providers/category_provider.dart';
import 'package:your_app/providers/cart_provider.dart';
import 'package:your_app/providers/order_provider.dart';
import 'package:your_app/routes/app_routes.dart';
import 'package:your_app/core/theme/app_theme.dart';
import 'package:your_app/screens/auth/splash_screen.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: MaterialApp(
        title: 'E-Commerce App',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.generateRoute,
        home: const SplashScreen(),
        
        // Global configuration
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: 1.0, // Prevent text scaling
            ),
            child: GestureDetector(
              onTap: () {
                // Hide keyboard when tapping outside
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus && 
                    currentFocus.focusedChild != null) {
                  FocusManager.instance.primaryFocus?.unfocus();
                }
              },
              child: child!,
            ),
          );
        },
      ),
    );
  }
}

// Extension untuk context helpers
extension AppContext on BuildContext {
  // Theme shortcuts
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  // Screen size shortcuts
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1200;
  bool get isDesktop => screenWidth >= 1200;
  
  // Provider shortcuts
  AuthProvider get authProvider => Provider.of<AuthProvider>(this, listen: false);
  ProductProvider get productProvider => Provider.of<ProductProvider>(this, listen: false);
  CategoryProvider get categoryProvider => Provider.of<CategoryProvider>(this, listen: false);
  CartProvider get cartProvider => Provider.of<CartProvider>(this, listen: false);
  OrderProvider get orderProvider => Provider.of<OrderProvider>(this, listen: false);
  
  // Navigation shortcuts
  void pop<T>([T? result]) => Navigator.of(this).pop(result);
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) =>
      Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);
  Future<T?> pushReplacementNamed<T>(String routeName, {Object? arguments}) =>
      Navigator.of(this).pushReplacementNamed(routeName, arguments: arguments);
  Future<T?> pushNamedAndRemoveUntil<T>(
    String newRouteName,
    bool Function(Route<dynamic>) predicate, {
    Object? arguments,
  }) =>
      Navigator.of(this).pushNamedAndRemoveUntil(
        newRouteName,
        predicate,
        arguments: arguments,
      );
}

// Global snackbar utility
void showSnackBar(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: 'OK',
        textColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ),
  );
}

// Loading dialog utility
void showLoadingDialog(BuildContext context, {String message = 'Loading...'}) {
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

// Confirmation dialog utility
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Yes',
  String cancelText = 'No',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            confirmText,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}

// Error handler utility
void handleApiError(BuildContext context, dynamic error, {VoidCallback? onRetry}) {
  String errorMessage = 'An error occurred';
  
  if (error is String) {
    errorMessage = error;
  } else if (error.toString().contains('Unauthorized')) {
    errorMessage = 'Session expired. Please login again.';
    // Auto logout on unauthorized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.authProvider.logout();
      context.pushNamedAndRemoveUntil('/login', (route) => false);
    });
  } else if (error.toString().contains('Network is unreachable')) {
    errorMessage = 'No internet connection. Please check your network.';
  } else if (error.toString().contains('Timeout')) {
    errorMessage = 'Request timeout. Please try again.';
  }
  
  showSnackBar(context, errorMessage, isError: true);
  
  // Log error for debugging
  if (!error.toString().contains('Unauthorized')) {
    print('API Error: $error');
  }
}

// Format currency utility
String formatCurrency(double amount, {String symbol = '\$'}) {
  return '$symbol${amount.toStringAsFixed(2)}';
}

// Date format utility
String formatDate(DateTime date, {bool includeTime = false}) {
  if (includeTime) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
  return '${date.day}/${date.month}/${date.year}';
}

// Validation utilities
bool isValidEmail(String email) {
  final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  return emailRegex.hasMatch(email);
}

bool isValidPassword(String password) {
  return password.length >= 6;
}

// Debounce utility
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

// Throttle utility
class Throttler {
  final Duration duration;
  DateTime? _lastCallTime;

  Throttler({required this.duration});

  bool canCall() {
    if (_lastCallTime == null) {
      _lastCallTime = DateTime.now();
      return true;
    }
    
    final now = DateTime.now();
    final difference = now.difference(_lastCallTime!);
    
    if (difference >= duration) {
      _lastCallTime = now;
      return true;
    }
    
    return false;
  }
}

// Keyboard visibility utility
bool isKeyboardVisible(BuildContext context) {
  return MediaQuery.of(context).viewInsets.bottom > 0;
}

// Safe area padding utility
EdgeInsets getSafeAreaPadding(BuildContext context) {
  return MediaQuery.of(context).padding;
}

// Responsive breakpoints
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1200;
  static const double desktop = 1200;
}

// Responsive layout builder
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext, bool isMobile) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < Breakpoints.mobile;
        return builder(context, isMobile);
      },
    );
  }
}