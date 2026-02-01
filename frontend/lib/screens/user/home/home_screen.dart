import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../widgets/product/product_card.dart';
import '../../../widgets/common/custom_input.dart';
import '../../../widgets/common/loader.dart';
import '../../../core/constants/app_strings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    
    await Future.wait([
      productProvider.fetchProducts(),
      categoryProvider.fetchCategories(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.home),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/user/cart');
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.pushNamed(context, '/user/profile');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            // Search Bar
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: CustomInput(
                  controller: _searchController,
                  hint: 'Search products...',
                  prefixIcon: Icons.search,
                  onChanged: (value) {
                    Provider.of<ProductProvider>(context, listen: false)
                        .searchProducts(value);
                  },
                ),
              ),
            ),
            
            // Categories Filter
            Consumer<CategoryProvider>(
              builder: (context, categoryProvider, _) {
                if (categoryProvider.isLoading) {
                  return const SliverToBoxAdapter(child: Loader());
                }
                
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: SizedBox(
                      height: 50,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          // All Categories
                          FilterChip(
                            label: const Text('All'),
                            selected: categoryProvider.selectedCategory == null,
                            onSelected: (_) {
                              categoryProvider.clearFilters();
                              Provider.of<ProductProvider>(context, listen: false)
                                  .clearFilters();
                            },
                          ),
                          
                          const SizedBox(width: 8),
                          
                          // Category Chips
                          ...categoryProvider.categories.map((category) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(category.name),
                                selected: categoryProvider.selectedCategory == category.id,
                                onSelected: (_) {
                                  categoryProvider.filterByCategory(category.id);
                                  Provider.of<ProductProvider>(context, listen: false)
                                      .filterByCategory(category.id);
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // Products Grid
            Consumer<ProductProvider>(
              builder: (context, productProvider, _) {
                if (productProvider.isLoading) {
                  return const SliverFillRemaining(
                    child: Center(child: Loader()),
                  );
                }
                
                if (productProvider.error.isNotEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            productProvider.error,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadData,
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                if (productProvider.products.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No products found',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          if (_searchController.text.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                _searchController.clear();
                                productProvider.searchProducts('');
                              },
                              child: const Text('Clear search'),
                            ),
                        ],
                      ),
                    ),
                  );
                }
                
                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.7,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = productProvider.products[index];
                        return ProductCard(
                          product: product,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/user/product/${product.id}',
                            );
                          },
                          onAddToCart: () {
                            Provider.of<CartProvider>(context, listen: false)
                                .addToCart(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.name} added to cart'),
                              ),
                            );
                          },
                        );
                      },
                      childCount: productProvider.products.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}