import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/widgets/layout/user_bottom_nav.dart';
import 'package:ecommerce_app/screens/user/home/home_screen.dart';
import 'package:ecommerce_app/screens/user/cart/cart_screen.dart';
import 'package:ecommerce_app/screens/user/orders/my_orders_screen.dart';
import 'package:ecommerce_app/screens/user/profile/user_profile_screen.dart';
import 'package:ecommerce_app/core/constants/app_strings.dart';
class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    Container(), // Categories screen (to be implemented)
    const CartScreen(),
    const MyOrdersScreen(),
    const UserProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
  title: Text(_getAppBarTitle()),
  actions: _getAppBarActions(),
),

      body: _screens[_currentIndex],
      bottomNavigationBar: UserBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'Categories';
      case 2:
        return 'Shopping Cart';
      case 3:
        return 'My Orders';
      case 4:
        return 'Profile';
      default:
        return 'E-Commerce';
    }
  }

  List<Widget> _getAppBarActions() {
    switch (_currentIndex) {
      case 0: // Home
        return [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Implement notifications
            },
          ),
        ];
      case 2: // Cart
        return [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              // Clear cart
            },
          ),
        ];
      default:
        return [];
    }
  }
}