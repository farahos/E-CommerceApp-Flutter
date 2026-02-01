import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/products/admin_products_screen.dart';
import '../screens/admin/products/add_product_screen.dart';
import '../screens/admin/products/edit_product_screen.dart';
import '../screens/admin/categories/admin_categories_screen.dart';
import '../screens/admin/categories/add_category_screen.dart';
import '../screens/admin/orders/admin_orders_screen.dart';
import '../screens/admin/profile/admin_profile_screen.dart';
import '../screens/user/user_dashboard.dart';
import '../screens/user/home/home_screen.dart';
import '../screens/user/products/product_details_screen.dart';
import '../screens/user/cart/cart_screen.dart';
import '../screens/user/orders/my_orders_screen.dart';
import '../screens/user/profile/user_profile_screen.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn = authProvider.isAuthenticated;
      final isAdmin = authProvider.isAdmin;
      final location = state.location;

      // If not logged in, redirect to splash (which will go to login)
      if (!isLoggedIn && !location.startsWith('/auth')) {
        return '/splash';
      }

      // If logged in as admin trying to access user routes
      if (isLoggedIn && isAdmin && location.startsWith('/user')) {
        return '/admin/dashboard';
      }

      // If logged in as user trying to access admin routes
      if (isLoggedIn && !isAdmin && location.startsWith('/admin')) {
        return '/user/dashboard';
      }

      return null;
    },
    routes: [
      // Splash screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Admin routes
      GoRoute(
        path: '/admin/dashboard',
        name: 'admin_dashboard',
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: '/admin/products',
        name: 'admin_products',
        builder: (context, state) => const AdminProductsScreen(),
      ),
      GoRoute(
        path: '/admin/products/add',
        name: 'admin_add_product',
        builder: (context, state) => const AddProductScreen(),
      ),
      GoRoute(
        path: '/admin/products/edit/:id',
        name: 'admin_edit_product',
        builder: (context, state) => EditProductScreen(
          productId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/admin/categories',
        name: 'admin_categories',
        builder: (context, state) => const AdminCategoriesScreen(),
      ),
      GoRoute(
        path: '/admin/categories/add',
        name: 'admin_add_category',
        builder: (context, state) => const AddCategoryScreen(),
      ),
      GoRoute(
        path: '/admin/orders',
        name: 'admin_orders',
        builder: (context, state) => const AdminOrdersScreen(),
      ),
      GoRoute(
        path: '/admin/profile',
        name: 'admin_profile',
        builder: (context, state) => const AdminProfileScreen(),
      ),

      // User routes
      GoRoute(
        path: '/user/dashboard',
        name: 'user_dashboard',
        builder: (context, state) => const UserDashboard(),
      ),
      GoRoute(
        path: '/user/home',
        name: 'user_home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/user/product/:id',
        name: 'user_product_details',
        builder: (context, state) => ProductDetailsScreen(
          productId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/user/cart',
        name: 'user_cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/user/orders',
        name: 'user_orders',
        builder: (context, state) => const MyOrdersScreen(),
      ),
      GoRoute(
        path: '/user/profile',
        name: 'user_profile',
        builder: (context, state) => const UserProfileScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '404',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Page not found',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/user/home'),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
  );
}