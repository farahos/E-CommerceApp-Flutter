import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_app/providers/category_provider.dart';
import 'package:your_app/widgets/common/loader.dart';
import 'package:your_app/widgets/common/confirm_dialog.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final provider = Provider.of<CategoryProvider>(context, listen: false);
    await provider.fetchCategories();
  }

  Future<void> _deleteCategory(String categoryId) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => const ConfirmDialog(
        title: 'Delete Category',
        message: 'Are you sure you want to delete this category? This action cannot be undone.',
      ),
    );

    if (confirmed == true) {
      final provider = Provider.of<CategoryProvider>(context, listen: false);
      final success = await provider.deleteCategory(categoryId);
      
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _navigateToAddCategory() {
    Navigator.pushNamed(context, '/admin/categories/add');
  }

  void _editCategory(String categoryId) {
    final provider = Provider.of<CategoryProvider>(context, listen: false);
    final category = provider.getCategoryById(categoryId);
    
    if (category != null) {
      provider.selectCategory(category);
      provider.setFormMode(FormMode.edit);
      _navigateToAddCategory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAddCategory,
            tooltip: 'Add Category',
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
                hintText: 'Search categories...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          // TODO: Implement search
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                // TODO: Implement search
              },
            ),
          ),

          // Categories List
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
                              onPressed: _loadCategories,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : provider.categories.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.category_outlined, size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                const Text('No categories found'),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _navigateToAddCategory,
                                  child: const Text('Add First Category'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: provider.categories.length,
                            itemBuilder: (context, index) {
                              final category = provider.categories[index];
                              return _buildCategoryCard(category);
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddCategory,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryCard(category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.category, color: Colors.white),
        ),
        title: Text(
          category.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          category.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _editCategory(category.id),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () => _deleteCategory(category.id),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}