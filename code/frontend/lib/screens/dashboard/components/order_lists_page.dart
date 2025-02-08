import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../constants/style.dart';
import '../../../components/page_title.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/order_provider.dart';
import '../../../models/order.dart';
import '../../../models/product.dart';

class OrderListsPage extends StatefulWidget {
  @override
  _OrderListsPageState createState() => _OrderListsPageState();
}

class _OrderListsPageState extends State<OrderListsPage> {
  final _clientNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _deliveryDateController = TextEditingController();
  DateTime? _selectedDate;
  List<OrderItem> _newOrderItems = [];

  @override
  void initState() {
    super.initState();
    // Load orders when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrders();
    });
  }

  void _formatDateInput(String value) {
    String numbers = value.replaceAll(RegExp(r'[^0-9]'), '');
    String formattedDate = '';

    for (int i = 0; i < numbers.length && i < 8; i++) {
      if (i == 2 || i == 4) {
        formattedDate += '/';
      }
      formattedDate += numbers[i];
    }

    _deliveryDateController.value = TextEditingValue(
      text: formattedDate,
      selection: TextSelection.collapsed(offset: formattedDate.length),
    );

    // Parse date if complete
    if (formattedDate.length == 10) {
      try {
        final parts = formattedDate.split('/');
        final month = int.parse(parts[0]);
        final day = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        _selectedDate = DateTime(year, month, day);
      } catch (e) {
        _selectedDate = null;
      }
    }
  }

  void _showAddOrderDialog() {
    _newOrderItems = [];
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add New Order'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _clientNameController,
                  decoration: InputDecoration(labelText: 'Client Name'),
                ),
                SizedBox(height: defaultPadding),
                TextField(
                  controller: _cityController,
                  decoration: InputDecoration(labelText: 'City'),
                ),
                SizedBox(height: defaultPadding),
                TextField(
                  controller: _deliveryDateController,
                  decoration: InputDecoration(
                    labelText: 'Delivery Date (MM/DD/YYYY)',
                    helperText: 'Format: MM/DD/YYYY (e.g., 03/25/2024)',
                    errorText: _deliveryDateController.text.isNotEmpty && 
                             !RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(_deliveryDateController.text) 
                             ? 'Invalid format' : null,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                    LengthLimitingTextInputFormatter(10),
                  ],
                  onChanged: _formatDateInput,
                ),
                SizedBox(height: defaultPadding),
                Text(
                  'Order Items',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ..._newOrderItems.map((item) => ListTile(
                      title: Text(item.productName),
                      subtitle: Text('${item.quantity} units @ \$${item.price}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _newOrderItems.remove(item);
                          });
                        },
                      ),
                    )),
                TextButton(
                  onPressed: () => _showAddItemDialog(setState),
                  child: Text('+ Add Item'),
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
              onPressed: () {
                if (_validateForm()) {
                  _addOrder();
                  Navigator.pop(context);
                }
              },
              child: Text('Add Order'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditOrderDialog(Order order) {
    _clientNameController.text = order.clientName;
    _cityController.text = order.city;
    _deliveryDateController.text = "${order.deliveryDate.month.toString().padLeft(2, '0')}/${order.deliveryDate.day.toString().padLeft(2, '0')}/${order.deliveryDate.year}";
    _selectedDate = order.deliveryDate;
    _newOrderItems = List.from(order.items);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Edit Order'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ...existing form fields from _showAddOrderDialog...
                TextField(
                  controller: _clientNameController,
                  decoration: InputDecoration(labelText: 'Client Name'),
                ),
                SizedBox(height: defaultPadding),
                TextField(
                  controller: _cityController,
                  decoration: InputDecoration(labelText: 'City'),
                ),
                SizedBox(height: defaultPadding),
                TextField(
                  controller: _deliveryDateController,
                  decoration: InputDecoration(
                    labelText: 'Delivery Date (MM/DD/YYYY)',
                    helperText: 'Format: MM/DD/YYYY',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                    LengthLimitingTextInputFormatter(10),
                  ],
                  onChanged: _formatDateInput,
                ),
                SizedBox(height: defaultPadding),
                Text(
                  'Order Items',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ..._newOrderItems.map((item) => ListTile(
                      title: Text(item.productName),
                      subtitle: Text('${item.quantity} units @ \$${item.price}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _showEditItemDialog(setState, item),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _newOrderItems.remove(item);
                              });
                            },
                          ),
                        ],
                      ),
                    )),
                TextButton(
                  onPressed: () => _showAddItemDialog(setState),
                  child: Text('+ Add Item'),
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
              onPressed: () {
                if (_validateForm()) {
                  context.read<OrderProvider>().deleteOrder(order.id);
                  _addOrder();
                  Navigator.pop(context);
                }
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddItemDialog(StateSetter updateParent) {
    final quantityController = TextEditingController();
    Product? selectedProduct;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Item'),
        content: Consumer<ProductProvider>(
          builder: (context, productProvider, child) {
            final products = productProvider.products;
            
            if (products.isEmpty) {
              return Text('No products available. Please add products first.');
            }
            
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Product>(
                  decoration: InputDecoration(
                    labelText: 'Select Product',
                    border: OutlineInputBorder(),
                  ),
                  items: products.map((product) {
                    return DropdownMenuItem(
                      value: product,
                      child: Text('${product.name} - \$${product.price.toStringAsFixed(2)} (${product.stock} in stock)'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedProduct = value;
                  },
                ),
                SizedBox(height: defaultPadding),
                TextField(
                  controller: quantityController,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                    helperText: 'Enter a whole number',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              return ElevatedButton(
                onPressed: () {
                  if (selectedProduct == null || quantityController.text.isEmpty) {
                    _showError('Please select a product and enter quantity');
                    return;
                  }

                  final quantity = int.tryParse(quantityController.text);
                  if (quantity == null || quantity <= 0) {
                    _showError('Please enter a valid quantity');
                    return;
                  }

                  if (!productProvider.hasEnoughStock(selectedProduct!, quantity)) {
                    _showError('Not enough stock available');
                    return;
                  }

                  productProvider.updateStock(
                    selectedProduct!,
                    selectedProduct!.stock - quantity
                  );

                  updateParent(() {
                    // Check if item already exists in order
                    final existingItemIndex = _newOrderItems.indexWhere(
                      (item) => item.productName.toLowerCase() == selectedProduct!.name.toLowerCase()
                    );

                    if (existingItemIndex != -1) {
                      // Update existing item quantity
                      final existingItem = _newOrderItems[existingItemIndex];
                      _newOrderItems[existingItemIndex] = OrderItem(
                        productName: existingItem.productName,
                        quantity: existingItem.quantity + quantity,
                        price: selectedProduct!.price,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Updated existing item quantity'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    } else {
                      // Add new item
                      _newOrderItems.add(OrderItem(
                        productName: selectedProduct!.name,
                        quantity: quantity,
                        price: selectedProduct!.price,
                      ));
                    }
                  });
                  Navigator.pop(context);
                },
                child: Text('Add'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(StateSetter updateParent, OrderItem item) {
    final quantityController = TextEditingController(text: item.quantity.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item.productName, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: defaultPadding),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: 'New Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newQuantity = int.tryParse(quantityController.text);
              if (newQuantity != null && newQuantity > 0) {
                updateParent(() {
                  final index = _newOrderItems.indexOf(item);
                  _newOrderItems[index] = OrderItem(
                    productName: item.productName,
                    quantity: newQuantity,
                    price: item.price,
                  );
                });
                Navigator.pop(context);
              } else {
                _showError('Please enter a valid quantity');
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  bool _validateForm() {
    if (_clientNameController.text.isEmpty) {
      _showError('Client name is required');
      return false;
    }
    if (_cityController.text.isEmpty) {
      _showError('City is required');
      return false;
    }
    
    // Updated date validation
    if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(_deliveryDateController.text)) {
      _showError('Enter valid date in MM/DD/YYYY format');
      return false;
    }
    
    final parts = _deliveryDateController.text.split('/');
    final month = int.parse(parts[0]);
    final day = int.parse(parts[1]);
    final year = int.parse(parts[2]);
    
    if (month < 1 || month > 12) {
      _showError('Month must be between 1-12');
      return false;
    }
    if (day < 1 || day > 31) {
      _showError('Day must be between 1-31');
      return false;
    }
    if (year < 2024 || year > 2030) {
      _showError('Year must be between 2024-2030');
      return false;
    }
    
    try {
      _selectedDate = DateTime(year, month, day);
      if (_selectedDate!.isBefore(DateTime.now())) {
        _showError('Delivery date cannot be in the past');
        return false;
      }
    } catch (e) {
      _showError('Invalid date for selected month');
      return false;
    }

    if (_newOrderItems.isEmpty) {
      _showError('At least one item is required');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _addOrder() async {
    final newOrder = Order(
      clientName: _clientNameController.text,
      city: _cityController.text,
      deliveryDate: _selectedDate!,
      items: _newOrderItems,
      status: 'Pending',
    );

    try {
      await context.read<OrderProvider>().addOrder(newOrder);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    _clearForm();
  }

  void _clearForm() {
    _clientNameController.clear();
    _cityController.clear();
    _deliveryDateController.clear();
    _selectedDate = null;
    _newOrderItems = [];
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _cityController.dispose();
    _deliveryDateController.dispose();
    super.dispose();
  }

  Widget _buildOrderCard(Order order) {
    double totalAmount = order.items.fold(
        0, (sum, item) => sum + (item.quantity * item.price));

    return Card(
      margin: EdgeInsets.only(bottom: defaultPadding),
      color: secondaryColor,
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(
              Icons.business,
              color: primaryColor,
            ),
            SizedBox(width: defaultPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.clientName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Delivery to: ${order.city}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: defaultPadding / 2,
                vertical: defaultPadding / 4,
              ),
              decoration: BoxDecoration(
                color: order.status == "Pending"
                    ? Colors.orange.withOpacity(0.2)
                    : Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                order.status,
                style: TextStyle(
                  color:
                      order.status == "Pending" ? Colors.orange : Colors.green,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: defaultPadding / 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Delivery Date: ${order.deliveryDate.day}/${order.deliveryDate.month}/${order.deliveryDate.year}",
                style: TextStyle(color: Colors.white70),
              ),
              Text(
                "Total: \$${totalAmount.toStringAsFixed(2)}",
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Order Items",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: defaultPadding),
                ...order.items.map((item) => Padding(
                      padding: EdgeInsets.only(bottom: defaultPadding / 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item.productName),
                          Text("${item.quantity} units"),
                          Text("\$${(item.quantity * item.price).toStringAsFixed(2)}"),
                        ],
                      ),
                    )),
                Divider(color: Colors.white24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditOrderDialog(order),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteConfirmation(order),
                    ),
                    SizedBox(width: defaultPadding),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: order.status == "Pending"
                            ? Colors.green
                            : Colors.orange,
                      ),
                      onPressed: () {
                        _updateOrderStatus(order, order.status == "Pending" ? "Processing" : "Pending");
                      },
                      icon: Icon(
                        order.status == "Pending"
                            ? Icons.check_circle
                            : Icons.pending,
                      ),
                      label: Text(
                        order.status == "Pending"
                            ? "Mark as Processing"
                            : "Mark as Pending",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Order'),
        content: Text('Are you sure you want to delete this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await context.read<OrderProvider>().deleteOrder(order.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Order deleted successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting order: $e'),
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

  void _updateOrderStatus(Order order, String newStatus) async {
    try {
      await context.read<OrderProvider>().updateOrderStatus(order, newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating order status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(defaultPadding),
            child: Column(
              children: [
                PageTitle(
                  title: "Order Lists",
                  subtitle: "Manage customer orders",
                  icon: Icons.shopping_cart,
                  actions: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                      ),
                      onPressed: _showAddOrderDialog,  // Updated this line
                      icon: Icon(Icons.add),
                      label: Text("New Order"),
                    ),
                  ],
                ),
                SizedBox(height: defaultPadding),
                ...orderProvider.orders.map((order) => _buildOrderCard(order)),
              ],
            ),
          ),
        );
      },
    );
  }
}
