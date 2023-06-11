import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/screens/common/landing.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class SellerListProducts extends StatefulWidget {
  const SellerListProducts({super.key});

  @override
  State<SellerListProducts> createState() => _SellerListProductsState();
}

class _SellerListProductsState extends State<SellerListProducts> {
  List<Map<String, dynamic>> sellerProducts = [];

  @override
  void initState() {
    super.initState();
    getSellerProducts();
  }

  Future<void> getSellerProducts() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String sellerId = user.uid;
      final QuerySnapshot productsSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('sellerId', isEqualTo: sellerId)
          .get();

      setState(() {
        sellerProducts = productsSnapshot.docs.map((doc) {
          return doc.data() as Map<String, dynamic>;
        }).toList();
      });
    }
  }

  Widget _buildImageWidget(String base64Image) {
    final bytes = base64Decode(base64Image);
    return Image.memory(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Products'),
        actions: [
          IconButton(
            onPressed: () {
              logout(context);
            },
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: sellerProducts.length,
        itemBuilder: (context, index) {
          final product = sellerProducts[index];
          final imageStrings = product['imageStrings'] as List<dynamic>?;

          return ListTile(
            leading: imageStrings != null && imageStrings.isNotEmpty
                ? _buildImageWidget(imageStrings[0])
                : const Placeholder(), // Placeholder image when no images available
            title: Text(product['title'] ?? ''),
            subtitle: Text('\$${product['price'] ?? ''}'),
            onTap: () {
              // Handle tapping on a product
            },
          );
        },
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LandingPage(),
        ),
      );
    } catch (e) {
      print('Error logging out: $e');
    }
  }
}
