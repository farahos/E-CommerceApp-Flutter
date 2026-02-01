import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_app/providers/order_provider.dart';
import 'package:your_app/providers/auth_provider.dart';
import 'package:your_app/widgets/common/loader.dart';
import 'package:your_app/core/utils/enums.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  OrderStatus _selectedFilter = OrderStatus.pending;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    
    final user = authProvider.user;
    if (user != null) {
      await orderProvider.fetchUserOrders(user.id);
    }
  }

  void _viewOrderDetails(String orderId) {
    // TODO: Navigate to order details screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Details'),
        content: Text('Order ID: $orderId\n\nDetails would be shown here.'),
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
    final orderProvider = Provider.of<OrderProvider>(context);
    final orders = orderProvider.userOrders;

    // Filter orders by selected status
    final filteredOrders = _selectedFilter == OrderStatus.pending
        ? orders
        : orders.where((order) => order.status == _selectedFilter.name).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: OrderStatus.values.map((status) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(status.displayName),
                      selected: _selectedFilter == status,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = selected ? status : OrderStatus.pending;
                        });
                      },
                      backgroundColor: status.color.withOpacity(0.1),
                      selectedColor: status.color.withOpacity(0.3),
                      labelStyle: TextStyle(
                        color: _selectedFilter == status ? status.color : Colors.black,
                        fontWeight: _selectedFilter == status ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Orders List
          Expanded(
            child: orderProvider.isLoading
                ? const Loader()
                : orderProvider.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              orderProvider.error!,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadOrders,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : filteredOrders.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                Text(
                                  _selectedFilter == OrderStatus.pending
                                      ? 'No orders found'
                                      : 'No ${_selectedFilter.displayName.toLowerCase()} orders',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/home');
                                  },
                                  child: const Text('Start Shopping'),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadOrders,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredOrders.length,
                              itemBuilder: (context, index) {
                                final order = filteredOrders[index];
                                final status = OrderStatus.fromString(order.status);
                                
                                return _buildOrderCard(order, status);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(order, OrderStatus status) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _viewOrderDetails(order.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id.substring(0, 8)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: status.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          status.icon,
                          size: 14,
                          color: status.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          status.displayName,
                          style: TextStyle(
                            color: status.color,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Order Info
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    order.formattedDate,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Row(
                children: [
                  const Icon(Icons.shopping_bag, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '${order.items.length} items',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Divider(color: Colors.grey[300]),
              
              const SizedBox(height: 12),
              
              // Order Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${order.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}