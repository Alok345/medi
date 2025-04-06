import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'login_page.dart';
import 'addcategory.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  String? selectedCategory;
  List<dynamic> categories = [];

  final TextEditingController productNameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();

  bool isLoading = false;
  String statusMessage = '';

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final doc = await FirebaseFirestore.instance.collection('type').doc('category').get();
    final data = doc.data();
    if (data != null && data['categories'] != null) {
      setState(() {
        categories = data['categories'];
      });
    }
  }

  Future<void> saveProduct() async {
    final name = productNameController.text.trim();
    final qty = quantityController.text.trim();
    final price = priceController.text.trim();
    final color = colorController.text.trim();
    final size = sizeController.text.trim();

    if (selectedCategory == null || name.isEmpty || qty.isEmpty || price.isEmpty) {
      setState(() => statusMessage = 'Please fill in all required fields.');
      return;
    }

    final productData = {
      'category': selectedCategory,
      'product_name': name,
      'product_id': name,
      'available_quantity': qty,
      'price': price,
      'color': color,
      'size': size,
      'createdAt': FieldValue.serverTimestamp(),
    };

    setState(() => isLoading = true);
    await FirebaseFirestore.instance.collection('products').add(productData);
    setState(() {
      isLoading = false;
      statusMessage = 'Product added in database!';
      productNameController.clear();
      quantityController.clear();
      priceController.clear();
      colorController.clear();
      sizeController.clear();
      selectedCategory = null;
    });
  }

  void resetAppData() {
    debugPrint("App data reset");
  }

  void _handleMenuSelection(BuildContext context, String value) async {
    switch (value) {
      case 'create-category':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddCategoryPage()),
        );
        break;
      case 'add-product':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddProductPage()),
        );
        break;
      case 'logout':
        await FirebaseAuth.instance.signOut();
        await GoogleSignIn().signOut();
        resetAppData();
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? user?.email ?? 'Unknown User';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuSelection(context, value),
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.grey),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'create-category',
                child: Text('Create Category'),
              ),
              const PopupMenuItem(
                value: 'add-product',
                child: Text('Add Product'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Category'),
              value: selectedCategory,
              items: categories.map<DropdownMenuItem<String>>((category) {
                return DropdownMenuItem<String>(
                  value: category['name'],
                  child: Text(category['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),
            if (selectedCategory != null) ...[
              const SizedBox(height: 16),
              TextField(
                controller: productNameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Available Quantity'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: colorController,
                decoration: const InputDecoration(labelText: 'Color'),
              ),
              TextField(
                controller: sizeController,
                decoration: const InputDecoration(labelText: 'Size'),
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: saveProduct,
                      child: const Text('Submit'),
                    ),
              const SizedBox(height: 12),
              if (statusMessage.isNotEmpty)
                Text(
                  statusMessage,
                  style: const TextStyle(color: Colors.green),
                ),
            ]
          ],
        ),
      ),
    );
  }
}
