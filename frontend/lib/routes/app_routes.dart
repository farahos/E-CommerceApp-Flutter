import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Providers
import 'package:ecommerce_app/providers/auth_provider.dart';

// Auth Screens
import 'package:ecommerce_app/screens/auth/splash_screen.dart';
import 'package:ecommerce_app/screens/auth/login_screen.dart';
import 'package:ecommerce_app/screens/auth/register_screen.dart';
import 'package:ecommerce_app/screens/auth/forgot_password_screen.dart';

// Admin Screens
import 'package:ecommerce_app/screens/admin/admin_dashboard.dart';
import 'package:ecommerce_app/screens/admin/admin_products_screen.dart';
import 'package:ecommerce_app/screens/admin/add_product_screen.dart';
import 'package:ecommerce_app/screens/admin/edit_product_screen.dart';
import 'package:ecommerce_app/screens/admin/admin_categories_screen.dart';
import 'package:ecommerce_app/screens/admin/add_category_screen.dart';
import 'package:ecommerce_app/screens/admin/admin_orders_screen.dart';
import 'package:ecommerce_app/screens/admin/admin_profile_screen.dart';

// User Screens
import 'package:ecommerce_app/screens/user/user_dashboard.dart';
import 'package:ecommerce_app/screens/user/home/home_screen.dart';
import 'package:ecommerce_app/screens/user/products/product_details_screen.dart';
import 'package:ecommerce_app/screens/user/cart/cart_screen.dart';
import 'package:ecommerce_app/screens/user/orders/my_orders_screen.dart';
import 'package:ecommerce_app/screens/user/profile/user_profile_screen.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',

    // 🔐 AUTH & ROLE GUARD
    redirect: (BuildContext context, GoRouterState state) {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      final bool isLoggedIn = auth.isAuthenticated;
      final bool isAdmin = auth.isAdmin;
      final String location = state.matchedLocation;

      // 1️⃣ Not logged in → only allow auth pages
      if (!isLoggedIn) {
        final allowed = [
          '/splash',
          '/login',
          '/register',
          '/forgot-password',
        ];
        if (!allowed.contains(location)) {
          return '/login';
        }
      }

      // 2️⃣ Logged in admin → block user routes
      if (isLoggedIn && isAdmin && location.startsWith('/user')) {
        return '/admin/dashboard';
      }

      // 3️⃣ Logged in user → block admin routes
      if (isLoggedIn && !isAdmin && location.startsWith('/admin')) {
        return '/user/dashboard';
      }

      return null; // allow navigation
    },

    // 🧭 ROUTES
    routes: [

      /// SPLASH
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      /// AUTH
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
      GoRoute(
        path: '/forgot-password',
        name: 'forgot_password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      /// ADMIN
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

      /// USER
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

    // ❌ 404 PAGE
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '404',
              style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Page not found'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    ),
  );
}
