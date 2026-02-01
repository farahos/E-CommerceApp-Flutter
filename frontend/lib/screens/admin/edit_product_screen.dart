import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/providers/category_provider.dart';
import 'package:ecommerce_app/providers/product_provider.dart';
import 'package:ecommerce_app/widgets/common/custom_button.dart';
import 'package:ecommerce_app/widgets/common/custom_input.dart';
import 'package:ecommerce_app/widgets/common/loader.dart';
import 'package:ecommerce_app/core/utils/validators.dart';
import 'package:ecommerce_app/models/product_model.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;

  const EditProductScreen({
    super.key,
    required this.productId,
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _descriptionController;
  final List<TextEditingController> _imageControllers = [];
  String? _selectedCategoryId;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _stockController = TextEditingController();
    _descriptionController = TextEditingController();
    _loadData();
  }

  Future<void> _loadData() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    
    await Future.wait([
      productProvider.fetchProductById(widget.productId),
      categoryProvider.fetchCategories(),
    ]);
    
    if (productProvider.selectedProduct != null) {
      final product = productProvider.selectedProduct!;
      
      _nameController.text = product.name;
      _priceController.text = product.price.toString();
      _stockController.text = product.stock.toString();
      _descriptionController.text = product.description;
      _selectedCategoryId = product.categoryId;
      
      // Set up image controllers
      for (final imageUrl in product.images) {
        _imageControllers.add(TextEditingController(text: imageUrl));
      }
      if (_imageControllers.isEmpty) {
        _imageControllers.add(TextEditingController());
      }
      
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate() && _selectedCategoryId != null) {
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);

      // Create ProductModel object instead of Map
      final updatedProduct = ProductModel(
        id: widget.productId,
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        description: _descriptionController.text.trim(),
        images: _imageControllers
            .where((c) => c.text.isNotEmpty)
            .map((c) => c.text.trim())
            .toList(),
        categoryId: _selectedCategoryId!,
        // Add any other required fields from your ProductModel constructor
        // If your ProductModel has additional fields like createdAt, ratings, etc.
        // you might need to preserve them:
        createdAt: productProvider.selectedProduct?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        // Add any other fields that are required by your ProductModel constructor
      );

      final success = await productProvider.updateProduct(updatedProduct);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  void _addImageField() {
    setState(() {
      _imageControllers.add(TextEditingController());
    });
  }

  void _removeImageField(int index) {
    if (_imageControllers.length > 1) {
      setState(() {
        _imageControllers[index].dispose();
        _imageControllers.removeAt(index);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    for (final controller in _imageControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Product'),
        ),
        body: const Center(
          child: Loader(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomInput(
                controller: _nameController,
                label: 'Product Name',
                validator: (value) => Validators.validateRequired(value, 'Product name'),
              ),
              const SizedBox(height: 16),
              
              CustomInput(
                controller: _priceController,
                label: 'Price',
                keyboardType: TextInputType.number,
                validator: (v) => Validators.validateNumber(v, fieldName: 'Price'),
              ),
              const SizedBox(height: 16),
              
              CustomInput(
                controller: _stockController,
                label: 'Stock',
                keyboardType: TextInputType.number,
                validator: (v) => Validators.validateNumber(v, fieldName: 'Stock'),
              ),
              const SizedBox(height: 16),
              
              // Category Dropdown - Fixed label issue
              InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Category', // Changed from 'label' to 'labelText'
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategoryId,
                    hint: const Text('Select a category'),
                    isExpanded: true,
                    items: categoryProvider.categories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Description
              CustomInput(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 4,
                validator: (value) => Validators.validateRequired(value, 'Description'),
              ),
              const SizedBox(height: 16),
              
              // Image URLs
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Image URLs',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._imageControllers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final controller = entry.value;
                    
                    return Padding(
                      padding: EdgeInsets.only(bottom: index == _imageControllers.length - 1 ? 0 : 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: controller,
                              decoration: InputDecoration(
                                hintText: 'Image URL ${index + 1}',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          if (_imageControllers.length > 1)
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () => _removeImageField(index),
                            ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _addImageField,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Image URL'),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Error message
              if (productProvider.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    productProvider.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              // Update Button
              productProvider.isLoading
                  ? const Loader()
                  : CustomButton(
                      text: 'Update Product',
                      onPressed: _updateProduct,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}