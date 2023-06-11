import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/screens/sellers/seller_homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class SellerCreateProduct extends StatefulWidget {
  const SellerCreateProduct({super.key});

  @override
  State<SellerCreateProduct> createState() => _CreateProductState();
}

class _CreateProductState extends State<SellerCreateProduct> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _specsController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();
  List<File> _photos = [];

  Future<void> _addPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _photos.add(File(pickedFile.path));
      });
    }
  }

  Future<List<String>> encodeImages(List<File> imageFiles) async {
    List<String> base64Images = [];

    for (var i = 0; i < imageFiles.length; i++) {
      List<int> imageBytes = await imageFiles[i].readAsBytes();
      String base64Image = base64Encode(imageBytes);
      base64Images.add(base64Image);
    }

    return base64Images;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _specsController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<List<String>> uploadImages(List<File> imageFiles) async {
    List<String> downloadURLs = [];

    try {
      FirebaseStorage storage = FirebaseStorage.instance;

      for (var i = 0; i < imageFiles.length; i++) {
        File imageFile = imageFiles[i];
        Reference storageRef =
            storage.ref().child('product_images/image$i.jpg');

        UploadTask uploadTask = storageRef.putFile(imageFile);
        TaskSnapshot storageSnapshot = await uploadTask;

        String downloadURL = await storageSnapshot.ref.getDownloadURL();
        downloadURLs.add(downloadURL);
      }

      return downloadURLs;
    } catch (e) {
      print('Error uploading images: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Product'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: 'Category',
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _specsController,
                decoration: InputDecoration(
                  labelText: 'Specifications',
                ),
                maxLines: 4,
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _addPhoto,
                child: Text('Add Photo'),
              ),
              SizedBox(height: 16.0),
              if (_photos.isNotEmpty)
                Column(
                  children: _photos
                      .map((photo) => Image.file(
                            photo,
                            width: 100.0,
                            height: 100.0,
                          ))
                      .toList(),
                ),
              ElevatedButton(
                onPressed: () async {
                  final User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    final String sellerId = user.uid;
                    final String title = _titleController.text;
                    final String description = _descriptionController.text;
                    final double price = double.parse(_priceController.text);
                    final Map<String, dynamic> specs = {
                      'specs': _specsController.text,
                    };

                    try {
                      // Encode the image files as base64 strings
                      final List<String> imageStrings =
                          await encodeImages(_photos);

                      // Create a new document reference for the product
                      final CollectionReference productsCollection =
                          FirebaseFirestore.instance.collection('products');
                      final DocumentReference newProductRef =
                          productsCollection.doc();

                      // Create a map or object with the product data
                      final Map<String, dynamic> productData = {
                        'title': title,
                        'description': description,
                        'price': price,
                        'specs': specs,
                        'sellerId': sellerId,
                        'imageStrings': imageStrings,
                      };

                      // Save the product data to Firestore
                      await newProductRef.set(productData);

                      // Clear the text fields and photo list after saving
                      _titleController.clear();
                      _descriptionController.clear();
                      _priceController.clear();
                      _specsController.clear();
                      _categoryController.clear();
                      _photos.clear();

                      print('Product created successfully!');

                      save(context);
                    } catch (e) {
                      print('Error creating product: $e');
                    }
                  }
                },
                child: Text('Save Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> save(BuildContext context) async {
  const CircularProgressIndicator();
  await FirebaseAuth.instance.signOut();
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => const SellerHome(),
    ),
  );
}
