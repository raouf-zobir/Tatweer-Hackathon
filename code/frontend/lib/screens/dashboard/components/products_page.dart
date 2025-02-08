import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/style.dart';
import '../../../utils/responsive.dart';
import '../../../components/page_title.dart';
import '../../../providers/product_provider.dart';
import '../../../models/product.dart';

class ProductsPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'General';
  IconData _selectedIcon = Icons.inventory;

  final List<String> _categories = ['General', 'Perishable', 'Fragile', 'Heavy', 'Sensitive'];
  final List<IconData> _icons = [
    Icons.inventory,
    Icons.eco,
    Icons.devices,
    Icons.chair,
    Icons.checkroom,
    Icons.book,
    Icons.medical_services,
  ];

  @override
  void initState() {
    super.initState();
    // Load products when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Product Name'),
              ),
              SizedBox(height: defaultPadding),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: defaultPadding),
              TextField(
                controller: _stockController,
                decoration: InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: defaultPadding),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value!);
                },
                decoration: InputDecoration(labelText: 'Category'),
              ),
              SizedBox(height: defaultPadding),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              SizedBox(height: defaultPadding),
              DropdownButtonFormField<IconData>(
                value: _selectedIcon,
                items: _icons.map((icon) {
                  return DropdownMenuItem(
                    value: icon,
                    child: Icon(icon),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedIcon = value!);
                },
                decoration: InputDecoration(labelText: 'Icon'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_validateInputs()) {
                _addProduct();
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditProductDialog(Product product) {
    _nameController.text = product.name;
    _priceController.text = product.price.toString();
    _stockController.text = product.stock.toString();
    _descriptionController.text = product.description;
    _selectedCategory = product.category;
    _selectedIcon = product.icon;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Product Name'),
              ),
              SizedBox(height: defaultPadding),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: defaultPadding),
              TextField(
                controller: _stockController,
                decoration: InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: defaultPadding),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value!);
                },
                decoration: InputDecoration(labelText: 'Category'),
              ),
              SizedBox(height: defaultPadding),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              SizedBox(height: defaultPadding),
              DropdownButtonFormField<IconData>(
                value: _selectedIcon,
                items: _icons.map((icon) {
                  return DropdownMenuItem(
                    value: icon,
                    child: Icon(icon),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedIcon = value!);
                },
                decoration: InputDecoration(labelText: 'Icon'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _clearForm();
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_validateInputs()) {
                try {
                  final updatedProduct = Product(
                    name: _nameController.text,
                    price: double.parse(_priceController.text),
                    stock: int.parse(_stockController.text),
                    category: _selectedCategory,
                    description: _descriptionController.text,
                    icon: _selectedIcon,
                  );

                  await context.read<ProductProvider>()
                      .updateProduct(product.name, updatedProduct);
                      
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Product updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating product: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                _clearForm();
              }
            },
            child: Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await context.read<ProductProvider>()
                    .deleteProduct(product.name);
                    
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Product deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting product: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  bool _validateInputs() {
    if (_nameController.text.isEmpty) {
      _showError('Product name is required');
      return false;
    }
    if (_priceController.text.isEmpty || double.tryParse(_priceController.text) == null) {
      _showError('Valid price is required');
      return false;
    }
    if (_stockController.text.isEmpty || int.tryParse(_stockController.text) == null) {
      _showError('Valid stock quantity is required');
      return false;
    }
    if (_descriptionController.text.isEmpty) {
      _showError('Description is required');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _addProduct() async {
    final productProvider = context.read<ProductProvider>();
    final newProduct = Product(
      name: _nameController.text,
      price: double.parse(_priceController.text),
      stock: int.parse(_stockController.text),
      category: _selectedCategory,
      description: _descriptionController.text,
      icon: _selectedIcon,
    );

    try {
      // Check if product exists before adding
      if (await productProvider.productExists(newProduct.name)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('A product with this name already exists'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      await productProvider.addProduct(newProduct);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product added successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearForm() {
    _nameController.clear();
    _priceController.clear();
    _stockController.clear();
    _descriptionController.clear();
    _selectedCategory = 'General';
    _selectedIcon = Icons.inventory;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Widget _buildProductCard(Product product) {
    return Card(
      color: secondaryColor,
      child: Padding(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(defaultPadding * 0.75),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    product.icon,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
                _buildStockIndicator(product.stock),
              ],
            ),
            SizedBox(height: defaultPadding),
            Text(
              product.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: defaultPadding / 2),
            Text(
              product.description,
              style: TextStyle(color: Colors.white70),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: defaultPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "\$${product.price.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: defaultPadding / 2,
                    vertical: defaultPadding / 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(product.category),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showEditProductDialog(product),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteConfirmation(product),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockIndicator(int stock) {
    Color color;
    if (stock > 100) {
      color = Colors.green;
    } else if (stock > 50) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding / 2,
        vertical: defaultPadding / 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        "$stock in stock",
        style: TextStyle(color: color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(defaultPadding),
            child: Column(
              children: [
                PageTitle(
                  title: "Products",
                  subtitle: "Manage your product inventory",
                  icon: Icons.inventory,
                  actions: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: defaultPadding,
                          vertical: defaultPadding / 2,
                        ),
                      ),
                      onPressed: _showAddProductDialog,
                      icon: Icon(Icons.add),
                      label: Text("Add Product"),
                    ),
                  ],
                ),
                SizedBox(height: defaultPadding),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: Responsive.isMobile(context)
                        ? 1
                        : Responsive.isTablet(context)
                            ? 2
                            : 3,
                    crossAxisSpacing: defaultPadding,
                    mainAxisSpacing: defaultPadding,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: productProvider.products.length,
                  itemBuilder: (context, index) => _buildProductCard(productProvider.products[index]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
