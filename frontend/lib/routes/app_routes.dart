import 'package:flutter/material.dart';
import 'package:e_commerce_app/screens/auth/login_screen.dart';
import 'package:e-commerce_app/screens/auth/register_screen.dart';
import 'package:e-commerce_app/screens/auth/splash_screen.dart';
import 'package:e-commerce_app/screens/admin/admin_dashboard.dart';
import 'package:e-commerce_app/screens/admin/products/admin_products_screen.dart';
import 'package:e-commerce_app/screens/admin/products/add_product_screen.dart';
import 'package:e-commerce_app/screens/admin/products/edit_product_screen.dart';
import 'package:e-commerce_app/screens/admin/categories/admin_categories_screen.dart';
import 'package:e-commerce_app/screens/admin/orders/admin_orders_screen.dart';
import 'package:e-commerce_app/screens/admin/profile/admin_profile_screen.dart';
import 'package:e-commerce_app/screens/user/user_dashboard.dart';
import 'package:e-commerce_app/screens/user/home/home_screen.dart';
import 'package:e-commerce_app/screens/user/products/product_details_screen.dart';
import 'package:e-commerce_app/screens/user/cart/cart_screen.dart';
import 'package:e-commerce_app/screens/user/orders/my_orders_screen.dart';
import 'package:e-commerce_app/screens/user/profile/user_profile_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminProducts = '/admin/products';
  static const String addProduct = '/admin/products/add';
  static const String editProduct = '/admin/products/edit';
  static const String adminCategories = '/admin/categories';
  static const String adminOrders = '/admin/orders';
  static const String adminProfile = '/admin/profile';
  static const String userDashboard = '/user/dashboard';
  static const String home = '/home';
  static const String productDetails = '/product/details';
  static const String cart = '/cart';
  static const String myOrders = '/user/orders';
  static const String userProfile = '/user/profile';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboard());
      case adminProducts:
        return MaterialPageRoute(builder: (_) => const AdminProductsScreen());
      case addProduct:
        return MaterialPageRoute(builder: (_) => const AddProductScreen());
      case editProduct:
        final productId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => EditProductScreen(productId: productId),
        );
      case adminCategories:
        return MaterialPageRoute(builder: (_) => const AdminCategoriesScreen());
      case adminOrders:
        return MaterialPageRoute(builder: (_) => const AdminOrdersScreen());
      case adminProfile:
        return MaterialPageRoute(builder: (_) => const AdminProfileScreen());
      case userDashboard:
        return MaterialPageRoute(builder: (_) => const UserDashboard());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case productDetails:
        final productId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ProductDetailsScreen(productId: productId),
        );
      case cart:
        return MaterialPageRoute(builder: (_) => const CartScreen());
      case myOrders:
        return MaterialPageRoute(builder: (_) => const MyOrdersScreen());
      case userProfile:
        return MaterialPageRoute(builder: (_) => const UserProfileScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}