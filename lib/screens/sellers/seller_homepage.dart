import 'package:firebase_app/screens/common/landing.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'seller_create_product.dart';
import 'seller_products.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SellerHome extends StatefulWidget {
  const SellerHome({super.key});

  @override
  State<SellerHome> createState() => _SellerHomeState();
}

class _SellerHomeState extends State<SellerHome> {
  String sellerEmail = ''; //email

  @override
  void initState() {
    super.initState();
    getCurrentUserEmail(); // Fetch the seller's email when the page initializes
  }

  Future<void> getCurrentUserEmail() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String userId = user.uid;
      final DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        final Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        setState(() {
          sellerEmail = userData['email'] as String;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seller"),
        actions: [
          IconButton(
            onPressed: () {
              logout(context);
            },
            icon: const Icon(
              Icons.logout,
            ),
          )
        ],
      ),
      drawer: NavigationDrawer(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('Your Name'),
            accountEmail: Text(sellerEmail),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home Page'),
            onTap: () {
              Navigator.pop(context);
              homepage(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Edit Profile'),
            //onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.list),
            title: Text('Manage Products'),
            onTap: () {
              listProducts(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.add),
            title: Text('Add products'),
            onTap: () {
              createProdut(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('Sold Items'),
            //onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.contact_support),
            title: Text('Support'),
            //onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Log out'),
            onTap: () {
              logout(context);
            },
          ),
        ],
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

  Future<void> homepage(BuildContext context) async {
    const CircularProgressIndicator();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SellerHome(),
      ),
    );
  }

  Future<void> listProducts(BuildContext context) async {
    const CircularProgressIndicator();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SellerListProducts(),
      ),
    );
  }

  Future<void> createProdut(BuildContext context) async {
    const CircularProgressIndicator();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SellerCreateProduct(),
      ),
    );
  }
}
