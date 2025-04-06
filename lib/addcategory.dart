import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'addproduct.dart';
import 'login_page.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  String _statusMessage = '';

  Future<void> _submitForm() async {
    final name = _nameController.text.trim();
    final unit = _unitController.text.trim();
    final image = _imageController.text.trim();

    if (name.isEmpty || unit.isEmpty) {
      setState(() {
        _statusMessage = 'Name and Unit are required.';
      });
      return;
    }

    try {
      final timestamp = Timestamp.now();

      await FirebaseFirestore.instance.collection('type').doc('category').set({
        'categories': FieldValue.arrayUnion([
          {'name': name, 'unit': unit, 'image': image, 'createdAt': timestamp},
        ]),
      }, SetOptions(merge: true));

      setState(() {
        _statusMessage = 'Category saved in database';
        _nameController.clear();
        _unitController.clear();
        _imageController.clear();
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error saving category: $e';
      });
    }
  }

  void resetAppData() {
    debugPrint("App data reset.");
  }

  void _handleMenuSelection(String value) async {
    switch (value) {
      case 'add-category':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AddCategoryPage()),
        );
        break;
      case 'add-product':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AddProductPage()),
        );
        break;
      case 'logout':
        await FirebaseAuth.instance.signOut();
        await GoogleSignIn().signOut();
        resetAppData();

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? user?.email ?? 'Unknown User';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Category'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuSelection,
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
                value: 'add-category',
                child: Text('Create Category'),
              ),
              const PopupMenuItem(
                value: 'add-product',
                child: Text('Add Product'),
              ),
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Category Name'),
            ),
            TextField(
              controller: _unitController,
              decoration: const InputDecoration(labelText: 'Unit'),
            ),
            TextField(
              controller: _imageController,
              decoration: const InputDecoration(
                labelText: 'Image URL (optional)',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _submitForm, child: const Text('Submit')),
            const SizedBox(height: 20),
            Text(_statusMessage, style: const TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }
}
