import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:your_app/providers/auth_provider.dart';
import 'package:your_app/providers/product_provider.dart';
import 'package:your_app/providers/category_provider.dart';
import 'package:your_app/providers/order_provider.dart';
import 'package:your_app/widgets/layout/admin_drawer.dart';
import 'package:your_app/widgets/common/loader.dart';
import 'package:your_app/core/constants/app_colors.dart';
import 'package:your_app/core/utils/helpers.dart';
import 'package:your_app/core/utils/enums.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AdminScreen _currentScreen = AdminScreen.dashboard;
  DateTimeRange? _selectedDateRange;
  String _selectedTimeRange = 'today';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedDateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    );
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    
    await Future.wait([
      productProvider.fetchProducts(),
      categoryProvider.fetchCategories(),
      orderProvider.fetchAllOrders(),
    ]);
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
        _selectedTimeRange = 'custom';
      });
    }
  }

  void _handleScreenSelection(AdminScreen screen) {
    setState(() {
      _currentScreen = screen;
    });
    
    switch (screen) {
      case AdminScreen.products:
        Navigator.pushNamed(context, '/admin/products');
        break;
      case AdminScreen.categories:
        Navigator.pushNamed(context, '/admin/categories');
        break;
      case AdminScreen.orders:
        Navigator.pushNamed(context, '/admin/orders');
        break;
      case AdminScreen.users:
        // TODO: Navigate to users management
        break;
      case AdminScreen.settings:
        // TODO: Navigate to settings
        break;
      case AdminScreen.dashboard:
        // Stay on dashboard
        break;
    }
  }

  void _viewOrderDetails(String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Details'),
        content: Text('Order ID: $orderId'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _viewProductDetails(String productId) {
    Navigator.pushNamed(context, '/product/details', arguments: productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: AdminDrawer(
        currentScreen: _currentScreen,
        onScreenSelected: _handleScreenSelection,
      ),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Admin Dashboard'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadDashboardData,
          tooltip: 'Refresh',
        ),
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            // TODO: Show notifications
          },
          tooltip: 'Notifications',
        ),
      ],
    );
  }

  Widget _buildBody() {
    final productProvider = Provider.of<ProductProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    if (productProvider.isLoading || 
        categoryProvider.isLoading || 
        orderProvider.isLoading) {
      return const Loader();
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Range Selector
            _buildDateRangeSelector(),
            const SizedBox(height: 20),
            
            // Stats Cards
            _buildStatsCards(
              productProvider,
              categoryProvider,
              orderProvider,
            ),
            const SizedBox(height: 20),
            
            // Charts Section
            _buildChartsSection(orderProvider),
            const SizedBox(height: 20),
            
            // Recent Orders
            _buildRecentOrders(orderProvider),
            const SizedBox(height: 20),
            
            // Low Stock Products
            _buildLowStockProducts(productProvider),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.date_range, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedTimeRange == 'custom' && _selectedDateRange != null
                    ? '${Helpers.formatDate(_selectedDateRange!.start)} - ${Helpers.formatDate(_selectedDateRange!.end)}'
                    : _selectedTimeRange.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                setState(() {
                  _selectedTimeRange = value;
                  if (value != 'custom') {
                    final now = DateTime.now();
                    switch (value) {
                      case 'today':
                        _selectedDateRange = DateTimeRange(
                          start: DateTime(now.year, now.month, now.day),
                          end: now,
                        );
                        break;
                      case 'yesterday':
                        final yesterday = now.subtract(const Duration(days: 1));
                        _selectedDateRange = DateTimeRange(
                          start: DateTime(yesterday.year, yesterday.month, yesterday.day),
                          end: yesterday,
                        );
                        break;
                      case 'last7':
                        _selectedDateRange = DateTimeRange(
                          start: now.subtract(const Duration(days: 7)),
                          end: now,
                        );
                        break;
                      case 'last30':
                        _selectedDateRange = DateTimeRange(
                          start: now.subtract(const Duration(days: 30)),
                          end: now,
                        );
                        break;
                      case 'thisMonth':
                        _selectedDateRange = DateTimeRange(
                          start: DateTime(now.year, now.month, 1),
                          end: now,
                        );
                        break;
                      case 'lastMonth':
                        final lastMonth = now.month == 1 
                            ? DateTime(now.year - 1, 12, 1)
                            : DateTime(now.year, now.month - 1, 1);
                        final lastMonthEnd = DateTime(
                          lastMonth.year,
                          lastMonth.month + 1,
                          0,
                        );
                        _selectedDateRange = DateTimeRange(
                          start: lastMonth,
                          end: lastMonthEnd,
                        );
                        break;
                    }
                  }
                });
                
                if (value == 'custom') {
                  _selectDateRange(context);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'today',
                  child: Text('Today'),
                ),
                const PopupMenuItem(
                  value: 'yesterday',
                  child: Text('Yesterday'),
                ),
                const PopupMenuItem(
                  value: 'last7',
                  child: Text('Last 7 Days'),
                ),
                const PopupMenuItem(
                  value: 'last30',
                  child: Text('Last 30 Days'),
                ),
                const PopupMenuItem(
                  value: 'thisMonth',
                  child: Text('This Month'),
                ),
                const PopupMenuItem(
                  value: 'lastMonth',
                  child: Text('Last Month'),
                ),
                const PopupMenuItem(
                  value: 'custom',
                  child: Text('Custom Range'),
                ),
              ],
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text('Select Range'),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(
    ProductProvider productProvider,
    CategoryProvider categoryProvider,
    OrderProvider orderProvider,
  ) {
    final filteredOrders = _selectedDateRange != null
        ? orderProvider.allOrders.where((order) {
            final orderDate = order.createdAt;
            return orderDate.isAfter(_selectedDateRange!.start) &&
                   orderDate.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
          }).toList()
        : orderProvider.allOrders;

    final totalRevenue = filteredOrders.fold<double>(0, (sum, order) => sum + order.totalPrice);
    final totalOrders = filteredOrders.length;
    final averageOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0;

    final lowStockProducts = productProvider.products.where((p) => p.stock < 10).length;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          title: 'Total Revenue',
          value: Helpers.formatCurrency(totalRevenue),
          icon: Icons.attach_money,
          color: Colors.green,
          trend: '+12.5%',
        ),
        _buildStatCard(
          title: 'Total Orders',
          value: totalOrders.toString(),
          icon: Icons.shopping_cart,
          color: Colors.blue,
          trend: '+8.2%',
        ),
        _buildStatCard(
          title: 'Avg Order Value',
          value: Helpers.formatCurrency(averageOrderValue),
          icon: Icons.trending_up,
          color: Colors.orange,
          trend: '+5.3%',
        ),
        _buildStatCard(
          title: 'Low Stock',
          value: lowStockProducts.toString(),
          icon: Icons.warning,
          color: Colors.red,
          trend: 'Need restock',
        ),
        _buildStatCard(
          title: 'Total Products',
          value: productProvider.products.length.toString(),
          icon: Icons.inventory,
          color: Colors.purple,
          trend: '${productProvider.products.length} items',
        ),
        _buildStatCard(
          title: 'Categories',
          value: categoryProvider.categories.length.toString(),
          icon: Icons.category,
          color: Colors.teal,
          trend: 'Active',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? trend,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                if (trend != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: trend.contains('+') ? Colors.green.withOpacity(0.1) : 
                             trend.contains('-') ? Colors.red.withOpacity(0.1) : 
                             Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      trend,
                      style: TextStyle(
                        fontSize: 10,
                        color: trend.contains('+') ? Colors.green : 
                               trend.contains('-') ? Colors.red : 
                               Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(OrderProvider orderProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sales Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildRevenueChart(orderProvider),
                  _buildOrderStatusChart(orderProvider),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Revenue'),
                Tab(text: 'Status'),
              ],
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              indicatorSize: TabBarIndicatorSize.tab,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart(OrderProvider orderProvider) {
    // Group orders by date for the selected date range
    final Map<String, double> revenueByDate = {};
    
    if (_selectedDateRange != null) {
      final filteredOrders = orderProvider.allOrders.where((order) {
        final orderDate = order.createdAt;
        return orderDate.isAfter(_selectedDateRange!.start) &&
               orderDate.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
      
      // Group by day
      for (final order in filteredOrders) {
        final dateKey = Helpers.formatDate(order.createdAt);
        revenueByDate[dateKey] = (revenueByDate[dateKey] ?? 0) + order.totalPrice;
      }
    }
    
    final chartData = revenueByDate.entries.map((entry) {
      return ChartData(entry.key, entry.value);
    }).toList();
    
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        labelRotation: 45,
        labelStyle: const TextStyle(fontSize: 10),
      ),
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat.currency(symbol: '\$'),
        labelStyle: const TextStyle(fontSize: 10),
      ),
      series: <ChartSeries<ChartData, String>>[
        LineSeries<ChartData, String>(
          dataSource: chartData,
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          color: Colors.blue,
          markerSettings: const MarkerSettings(isVisible: true),
          dataLabelSettings: const DataLabelSettings(isVisible: false),
        ),
      ],
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }

  Widget _buildOrderStatusChart(OrderProvider orderProvider) {
    final statusCounts = <String, int>{};
    
    for (final order in orderProvider.allOrders) {
      statusCounts[order.status] = (statusCounts[order.status] ?? 0) + 1;
    }
    
    final chartData = statusCounts.entries.map((entry) {
      final status = OrderStatus.fromString(entry.key);
      return ChartData(status.displayName, entry.key == 'delivered' ? 100 : entry.value.toDouble());
    }).toList();
    
    return SfCircularChart(
      series: <CircularSeries>[
        DoughnutSeries<ChartData, String>(
          dataSource: chartData,
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          dataLabelMapper: (ChartData data, _) => '${data.x}\n${data.y.toStringAsFixed(0)}',
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          pointColorMapper: (ChartData data, _) {
            switch (data.x) {
              case 'Pending': return Colors.orange;
              case 'Paid': return Colors.blue;
              case 'Shipped': return Colors.purple;
              case 'Delivered': return Colors.green;
              case 'Cancelled': return Colors.red;
              default: return Colors.grey;
            }
          },
        ),
      ],
      legend: Legend(isVisible: true, position: LegendPosition.bottom),
    );
  }

  Widget _buildRecentOrders(OrderProvider orderProvider) {
    final recentOrders = orderProvider.allOrders
      .where((order) => order.status == 'pending' || order.status == 'paid')
      .take(5)
      .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Orders',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/admin/orders');
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentOrders.isEmpty)
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No recent orders'),
                  ],
                ),
              )
            else
              ...recentOrders.map((order) => _buildOrderListItem(order)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderListItem(order) {
    final status = OrderStatus.fromString(order.status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: status.color.withOpacity(0.1),
          child: Icon(status.icon, color: status.color, size: 20),
        ),
        title: Text(
          'Order #${order.id.substring(0, 8)}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('\$${order.totalPrice.toStringAsFixed(2)}'),
            Text(
              Helpers.formatDate(order.createdAt),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: status.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status.displayName,
            style: TextStyle(
              fontSize: 12,
              color: status.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        onTap: () => _viewOrderDetails(order.id),
      ),
    );
  }

  Widget _buildLowStockProducts(ProductProvider productProvider) {
    final lowStockProducts = productProvider.products
      .where((product) => product.stock < 10)
      .take(5)
      .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Low Stock Products',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Filter products by low stock
                    Navigator.pushNamed(context, '/admin/products');
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (lowStockProducts.isEmpty)
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.inventory_outlined, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('All products are well stocked'),
                  ],
                ),
              )
            else
              ...lowStockProducts.map((product) => _buildProductListItem(product)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductListItem(product) {
    final stockStatus = product.stock == 0 
        ? 'Out of Stock'
        : product.stock < 5 
          ? 'Critical' 
          : 'Low';

    final statusColor = product.stock == 0 
        ? Colors.red
        : product.stock < 5 
          ? Colors.orange 
          : Colors.amber;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: product.images.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.images[0],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 24),
                    );
                  },
                ),
              )
            : Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image_not_supported, size: 24),
              ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('\$${product.price.toStringAsFixed(2)}'),
            const SizedBox(height: 2),
            Text(
              'Stock: ${product.stock}',
              style: TextStyle(color: statusColor),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_shopping_cart, size: 20),
          onPressed: () {
            // TODO: Quick restock action
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Restock Product'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Add stock quantity for ${product.name}'),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Update product stock
                      Navigator.pop(context);
                      Helpers.showSnackBar('Product stock updated');
                    },
                    child: const Text('Update'),
                  ),
                ],
              ),
            );
          },
          tooltip: 'Restock',
        ),
        onTap: () => _viewProductDetails(product.id),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => _buildQuickActionsMenu(),
        );
      },
      icon: const Icon(Icons.add),
      label: const Text('Quick Action'),
      backgroundColor: AppColors.primary,
    );
  }

  Widget _buildQuickActionsMenu() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _buildQuickActionButton(
                icon: Icons.add_circle,
                label: 'Add Product',
                color: Colors.blue,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/admin/products/add');
                },
              ),
              _buildQuickActionButton(
                icon: Icons.category,
                label: 'Add Category',
                color: Colors.green,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/admin/categories/add');
                },
              ),
              _buildQuickActionButton(
                icon: Icons.receipt,
                label: 'View Orders',
                color: Colors.orange,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/admin/orders');
                },
              ),
              _buildQuickActionButton(
                icon: Icons.people,
                label: 'View Users',
                color: Colors.purple,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to users
                },
              ),
              _buildQuickActionButton(
                icon: Icons.bar_chart,
                label: 'View Reports',
                color: Colors.teal,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to reports
                },
              ),
              _buildQuickActionButton(
                icon: Icons.settings,
                label: 'Settings',
                color: Colors.grey,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to settings
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Data model for charts
class ChartData {
  final String x;
  final double y;

  ChartData(this.x, this.y);
}