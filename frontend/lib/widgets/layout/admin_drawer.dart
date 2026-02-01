import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce_app/providers/auth_provider.dart';
import 'package:e_commerce_app/core/utils/enums.dart';

class AdminDrawer extends StatelessWidget {
  final AdminScreen currentScreen;
  final Function(AdminScreen) onScreenSelected;

  const AdminDrawer({
    super.key,
    required this.currentScreen,
    required this.onScreenSelected,
  });

  Future<void> _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          UserAccountsDrawerHeader(
            accountName: Text(user?.username ?? 'Admin'),
            accountEmail: Text(user?.email ?? 'admin@example.com'),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.blue),
            ),
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
          ),

          // Drawer Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  AdminScreen.dashboard,
                  currentScreen == AdminScreen.dashboard,
                ),
                _buildDrawerItem(
                  context,
                  AdminScreen.products,
                  currentScreen == AdminScreen.products,
                ),
                _buildDrawerItem(
                  context,
                  AdminScreen.categories,
                  currentScreen == AdminScreen.categories,
                ),
                _buildDrawerItem(
                  context,
                  AdminScreen.orders,
                  currentScreen == AdminScreen.orders,
                ),
                _buildDrawerItem(
                  context,
                  AdminScreen.users,
                  currentScreen == AdminScreen.users,
                ),
                _buildDrawerItem(
                  context,
                  AdminScreen.settings,
                  currentScreen == AdminScreen.settings,
                ),
              ],
            ),
          ),

          // Logout Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => _logout(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    AdminScreen screen,
    bool isSelected,
  ) {
    return ListTile(
      leading: Icon(
        screen.icon,
        color: isSelected ? Colors.blue : Colors.grey,
      ),
      title: Text(
        screen.displayName,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.blue : Colors.black,
        ),
      ),
      tileColor: isSelected ? Colors.blue.withOpacity(0.1) : null,
      onTap: () => onScreenSelected(screen),
    );
  }
}