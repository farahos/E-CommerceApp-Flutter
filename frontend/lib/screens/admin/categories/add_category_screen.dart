import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce_app/providers/category_provider.dart';
import 'package:e_commerce_app/widgets/common/custom_button.dart';
import 'package:e_commerce_app/widgets/common/custom_input.dart';
import 'package:e_commerce_app/widgets/common/loader.dart';
import 'package:e_commerce_app/core/utils/validators.dart';
import 'package:e_commerce_app/core/utils/enums.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final provider = Provider.of<CategoryProvider>(context, listen: false);
    final selectedCategory = provider.selectedCategory;
    
    if (provider.formMode == FormMode.edit && selectedCategory != null) {
      _nameController.text = selectedCategory.name;
      _descriptionController.text = selectedCategory.description;
    }
  }

  Future<void> _saveCategory() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<CategoryProvider>(context, listen: false);
      
      if (provider.formMode == FormMode.create) {
        final success = await provider.createCategory(
          _nameController.text.trim(),
          _descriptionController.text.trim(),
        );
        
        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Category created successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else if (provider.formMode == FormMode.edit) {
        final selectedCategory = provider.selectedCategory;
        if (selectedCategory != null) {
          final success = await provider.updateCategory(
            selectedCategory.id,
            _nameController.text.trim(),
            _descriptionController.text.trim(),
          );
          
          if (success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Category updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          provider.formMode == FormMode.create 
              ? 'Add Category' 
              : 'Edit Category',
        ),
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
                labelText: 'Category Name',
                validator: (value) => Validators.validateRequired(value, 'Category name'),
              ),
              const SizedBox(height: 16),
              
              CustomInput(
                controller: _descriptionController,
                labelText: 'Description',
                maxLines: 4,
                validator: (value) => Validators.validateRequired(value, 'Description'),
              ),
              
              const SizedBox(height: 24),
              
              // Error message
              if (provider.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    provider.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              // Save Button
              provider.isLoading
                  ? const Loader()
                  : CustomButton(
                      text: provider.formMode == FormMode.create 
                          ? 'Create Category' 
                          : 'Update Category',
                      onPressed: _saveCategory,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}