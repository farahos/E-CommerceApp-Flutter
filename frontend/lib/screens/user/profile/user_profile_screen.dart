import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_app/providers/auth_provider.dart';
import 'package:your_app/widgets/common/custom_button.dart';
import 'package:your_app/widgets/common/confirm_dialog.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => const ConfirmDialog(
        title: 'Logout',
        message: 'Are you sure you want to logout?',
      ),
    );

    if (confirmed == true) {
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
  }

  void _navigateToMyOrders() {
    Navigator.pushNamed(context, '/user/orders');
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: const Text('Settings will be available soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.username ?? 'User',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user?.email ?? 'user@example.com',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(
                        user?.role?.toUpperCase() ?? 'USER',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // User Actions
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.shopping_bag, color: Colors.blue),
                    title: const Text('My Orders'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _navigateToMyOrders,
                  ),
                  Divider(color: Colors.grey[300], height: 0),
                  ListTile(
                    leading: const Icon(Icons.settings, color: Colors.grey),
                    title: const Text('Settings'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showSettings,
                  ),
                  Divider(color: Colors.grey[300], height: 0),
                  ListTile(
                    leading: const Icon(Icons.help, color: Colors.orange),
                    title: const Text('Help & Support'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to help screen
                    },
                  ),
                  Divider(color: Colors.grey[300], height: 0),
                  ListTile(
                    leading: const Icon(Icons.info, color: Colors.purple),
                    title: const Text('About'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to about screen
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Logout Button
            CustomButton(
              text: 'Logout',
              onPressed: () => _logout(context),
              backgroundColor: Colors.red,
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}