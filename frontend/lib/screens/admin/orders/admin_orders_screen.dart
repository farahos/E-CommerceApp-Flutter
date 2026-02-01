import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_app/providers/order_provider.dart';
import 'package:your_app/widgets/common/loader.dart';
import 'package:your_app/core/utils/enums.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  OrderStatus _selectedStatus = OrderStatus.pending;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final provider = Provider.of<OrderProvider>(context, listen: false);
    await provider.fetchAllOrders();
  }

  void _updateOrderStatus(String orderId, OrderStatus newStatus) async {
    final provider = Provider.of<OrderProvider>(context, listen: false);
    await provider.updateOrderStatus(orderId, newStatus.name);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated to ${newStatus.displayName}'),
          backgroundColor: Colors.green,
        ),
      );
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
    final provider = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
      ),
      body: Column(
        children: [
          // Status Filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: OrderStatus.values.length,
                itemBuilder: (context, index) {
                  final status = OrderStatus.values[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(status.displayName),
                      selected: _selectedStatus == status,
                      onSelected: (selected) {
                        setState(() {
                          _selectedStatus = status;
                        });
                        // TODO: Filter orders by status
                      },
                      backgroundColor: status.color.withOpacity(0.1),
                      selectedColor: status.color.withOpacity(0.3),
                      labelStyle: TextStyle(
                        color: _selectedStatus == status ? status.color : Colors.black,
                        fontWeight: _selectedStatus == status ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Orders List
          Expanded(
            child: provider.isLoading
                ? const Loader()
                : provider.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              provider.error!,
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
                    : provider.allOrders.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                const Text('No orders found'),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: provider.allOrders.length,
                            itemBuilder: (context, index) {
                              final order = provider.allOrders[index];
                              return _buildOrderCard(order);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(order) {
    final status = OrderStatus.fromString(order.status);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: status.color.withOpacity(0.1),
          child: Icon(
            status.icon,
            color: status.color,
          ),
        ),
        title: Text(
          'Order #${order.id.substring(0, 8)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total: \$${order.totalPrice.toStringAsFixed(2)}'),
            Text('Items: ${order.items.length}'),
            Text('Date: ${order.formattedDate}'),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: status.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status.displayName,
                    style: TextStyle(
                      color: status.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          itemBuilder: (context) => OrderStatus.values.map((status) {
            return PopupMenuItem(
              value: status.name,
              child: Row(
                children: [
                  Icon(status.icon, color: status.color),
                  const SizedBox(width: 8),
                  Text(status.displayName),
                ],
              ),
            );
          }).toList(),
          onSelected: (value) {
            final newStatus = OrderStatus.fromString(value);
            _updateOrderStatus(order.id, newStatus);
          },
          child: const Icon(Icons.more_vert),
        ),
        onTap: () => _viewOrderDetails(order.id),
      ),
    );
  }
}