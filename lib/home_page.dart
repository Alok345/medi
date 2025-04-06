import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'login_page.dart';
import 'addcategory.dart';
import 'addproduct.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Optional: Reset any app-level data (like clearing form fields, shared prefs, etc.)
  void resetAppData() {
    debugPrint("App data reset"); // Implement actual clearing logic as needed
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
        await GoogleSignIn().signOut(); // Also sign out from Google
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
        automaticallyImplyLeading: false, // Removes back arrow
        title: const Text('Home Page'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuSelection(context, value),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                enabled: false, // Info only
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
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('type')
              .doc('category')
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Error loading categories'));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('No categories found.'));
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final List categories = data['categories'] ?? [];

            if (categories.isEmpty) {
              return const Center(child: Text('No categories available.'));
            }

            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 6,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        category['image'] != null &&
                                category['image'].toString().isNotEmpty
                            ? Image.network(
                                category['image'],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                            : const Icon(
                                Icons.category,
                                size: 60,
                                color: Colors.grey,
                              ),
                        const SizedBox(height: 10),
                        Text(
                          category['name'] ?? 'No name',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Unit: ${category['unit'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
