import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_app/providers/auth_provider.dart';
import 'package:your_app/widgets/layout/user_bottom_nav.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(), // Will be created
    const CartScreen(), // Will be created
    const MyOrdersScreen(), // Will be created
    const UserProfileScreen(), // Will be created
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (authProvider.user == null) {
      // Redirect to login if not authenticated
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
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
}