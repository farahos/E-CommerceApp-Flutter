import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_app/models/product_model.dart';
import 'package:your_app/providers/product_provider.dart';
import 'package:your_app/widgets/common/loader.dart';
import 'package:your_app/widgets/common/confirm_dialog.dart';
import 'package:your_app/core/constants/app_strings.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    await provider.fetchProducts();
  }

  Future<void> _deleteProduct(String productId) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => const ConfirmDialog(
        title: 'Delete Product',
        message: 'Are you sure you want to delete this product?',
      ),
    );

    if (confirmed == true) {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      final success = await provider.deleteProduct(productId);
      
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _navigateToAddProduct() {
    Navigator.pushNamed(context, '/admin/products/add');
  }

  void _navigateToEditProduct(String productId) {
    Navigator.pushNamed(
      context,
      '/admin/products/edit',
      arguments: productId,
    );
  }

  void _viewProductDetails(String productId) {
    // For admin, we might want different detail view
    Navigator.pushNamed(
      context,
      '/product/details',
      arguments: productId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAddProduct,
            tooltip: 'Add Product',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          provider.searchProducts('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: provider.searchProducts,
            ),
          ),

          // Products List
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
                              onPressed: _loadProducts,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : provider.products.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                const Text('No products found'),
                                if (_searchController.text.isNotEmpty)
                                  TextButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      provider.searchProducts('');
                                    },
                                    child: const Text('Clear search'),
                                  ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: provider.products.length,
                            itemBuilder: (context, index) {
                              final product = provider.products[index];
                              return _buildProductCard(product);
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddProduct,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: product.images.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.images[0],
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported),
                    );
                  },
                ),
              )
            : Container(
                width: 60,
                height: 60,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported),
              ),
        title: Text(
          product.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('\$${product.price.toStringAsFixed(2)}'),
            Text('Stock: ${product.stock}'),
            Text(
              'Category: ${product.categoryId.substring(0, 8)}...',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _navigateToEditProduct(product.id),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () => _deleteProduct(product.id),
              tooltip: 'Delete',
            ),
          ],
        ),
        onTap: () => _viewProductDetails(product.id),
      ),
    );
  }
}