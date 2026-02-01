import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/providers/auth_provider.dart';
import 'package:ecommerce_app/providers/order_provider.dart';
import 'package:ecommerce_app/providers/product_provider.dart';
import 'package:ecommerce_app/widgets/common/loader.dart';
import 'package:ecommerce_app/widgets/common/custom_button.dart';

import 'package:ecommerce_app/core/constants/app_colors.dart';
import 'package:ecommerce_app/core/utils/validators.dart';
import 'package:go_router/go_router.dart';
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    await Future.wait([
      orderProvider.fetchAllOrders(),
      productProvider.fetchProducts(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Admin Panel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Manage Products'),
              onTap: () {
                      context.go('/admin/products');
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Manage Categories'),
              onTap: () {
                context.go('/admin/categories');
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Manage Orders'),
              onTap: () {
                context.go('/admin/orders');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                context.go('/admin/profile');
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            // Stats Overview
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Consumer<OrderProvider>(
                  builder: (context, orderProvider, _) {
                    if (orderProvider.isLoading) {
                      return Loader();
                    }

                    final stats = orderProvider.getOrderStats();
                    return Column(
                      children: [
                        // Summary Cards
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.5,
                          children: [
                            _buildStatCard(
                              context,
                              'Total Orders',
                              stats['total'].toString(),
                              Icons.shopping_cart,
                              AppColors.primary,
                            ),
                            _buildStatCard(
                              context,
                              'Pending',
                              stats['pending'].toString(),
                              Icons.pending,
                              Colors.orange,
                            ),
                            _buildStatCard(
                              context,
                              'Delivered',
                              stats['delivered'].toString(),
                              Icons.check_circle,
                              Colors.green,
                            ),
                            _buildStatCard(
                              context,
                              'Revenue',
                              '\$${(stats['delivered']! * 100).toString()}',
                              Icons.attach_money,
                              Colors.purple,
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Quick Actions
                        const Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            CustomButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/admin/products/add');
                              },
                              text: 'Add Product',
                              icon: Icons.add,
                              variant: ButtonVariant.primary,
                            ),
                            CustomButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/admin/categories/add');
                              },
                              text: 'Add Category',
                              icon: Icons.add,
                              variant: ButtonVariant.secondary,
                            ),
                            CustomButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/admin/orders');
                              },
                              text: 'View Orders',
                              icon: Icons.shopping_cart,
                              variant: ButtonVariant.outline,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            
            // Recent Orders
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Orders',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Consumer<OrderProvider>(
                      builder: (context, orderProvider, _) {
                        if (orderProvider.isLoading) {
                           Center(child: Loader());
                        }

                        final recentOrders = orderProvider.adminOrders
                            .take(5)
                            .toList();

                        if (recentOrders.isEmpty) {
                          return const Center(
                            child: Text('No orders yet'),
                          );
                        }

                        return Card(
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: recentOrders.length,
                            itemBuilder: (context, index) {
                              final order = recentOrders[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getStatusColor(order.status),
                                  child: Text(
                                    (index + 1).toString(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text('Order #${order.id.substring(0, 8)}'),
                                subtitle: Text(
                                  '${order.items.length} items • \$${order.totalPrice.toStringAsFixed(2)}',
                                ),
                                trailing: Chip(
                                  label: Text(
                                    order.status,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: _getStatusColor(order.status),
                                ),
                                onTap: () {
                                  // Navigate to order details
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}