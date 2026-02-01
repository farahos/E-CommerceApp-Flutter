import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/order_provider.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/loader.dart';
import '../../../widgets/common/confirm_dialog.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).fetchAllOrders();
    });
  }

  Future<void> _updateOrderStatus(String orderId, String currentStatus) async {
    final newStatus = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusOption('pending', currentStatus, 'Pending'),
            _buildStatusOption('paid', currentStatus, 'Paid'),
            _buildStatusOption('shipped', currentStatus, 'Shipped'),
            _buildStatusOption('delivered', currentStatus, 'Delivered'),
            _buildStatusOption('cancelled', currentStatus, 'Cancelled'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (newStatus != null) {
      final success = await Provider.of<OrderProvider>(context, listen: false)
          .updateOrderStatus(orderId, newStatus);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Widget _buildStatusOption(String status, String currentStatus, String label) {
    return ListTile(
      leading: Radio<String>(
        value: status,
        groupValue: currentStatus,
        onChanged: (value) {
          Navigator.pop(context, value);
        },
      ),
      title: Text(label),
      trailing: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: Helpers.getStatusColor(status),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  void _showOrderDetails(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order #${order.id.substring(0, 8)}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildDetailRow('Order ID', order.id.substring(0, 12)),
              _buildDetailRow('Date', order.formattedDate),
              _buildDetailRow('Time', order.formattedTime),
              _buildDetailRow('Status', order.status),
              _buildDetailRow('Total', '\$${order.totalPrice.toStringAsFixed(2)}'),
              const Divider(),
              const Text(
                'Order Items:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...order.items.map((item) => ListTile(
                leading: const Icon(Icons.check_circle, size: 16, color: Colors.green),
                title: Text(item.productName ?? 'Product ${item.productId.substring(0, 8)}'),
                subtitle: Text('Qty: ${item.qty} × \$${item.price.toStringAsFixed(2)}'),
                trailing: Text('\$${(item.qty * item.price).toStringAsFixed(2)}'),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          CustomButton(
            onPressed: () {
              Navigator.pop(context);
              _updateOrderStatus(order.id, order.status);
            },
            text: 'Update Status',
            variant: ButtonVariant.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<OrderProvider>(context, listen: false).fetchAllOrders();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pending', 'pending'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Paid', 'paid'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Shipped', 'shipped'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Delivered', 'delivered'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Cancelled', 'cancelled'),
                ],
              ),
            ),
          ),

          // Orders List
          Expanded(
            child: Consumer<OrderProvider>(
              builder: (context, orderProvider, _) {
                if (orderProvider.isLoading) {
                  return const Center(child: Loader());
                }

                if (orderProvider.error.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          orderProvider.error,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => orderProvider.fetchAllOrders(),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredOrders = _selectedStatus == 'all'
                    ? orderProvider.adminOrders
                    : orderProvider.adminOrders
                        .where((order) => order.status == _selectedStatus)
                        .toList();

                if (filteredOrders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedStatus == 'all'
                              ? 'No orders found'
                              : 'No $selectedStatus orders',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Helpers.getStatusColor(order.status),
                          child: Text(
                            (index + 1).toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text('Order #${order.id.substring(0, 8)}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(Helpers.formatDateTime(order.createdAt)),
                            Text('${order.items.length} items • \$${order.totalPrice.toStringAsFixed(2)}'),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Chip(
                              label: Text(
                                order.status.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                              backgroundColor: Helpers.getStatusColor(order.status),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${order.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        onTap: () => _showOrderDetails(order),
                        onLongPress: () => _updateOrderStatus(order.id, order.status),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedStatus == value,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = selected ? value : 'all';
        });
        Provider.of<OrderProvider>(context, listen: false)
            .setFilterStatus(_selectedStatus);
      },
      selectedColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: _selectedStatus == value ? Colors.white : Colors.black,
      ),
    );
  }
}