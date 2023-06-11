import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ArticleFacade {
  final CollectionReference _articlesCollection =
      FirebaseFirestore.instance.collection('articles');

  Future<void> uploadArticle(
      String title, String description, double price) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        DocumentReference newArticleRef = _articlesCollection.doc();

        Map<String, dynamic> articleData = {
          'sellerId': user.uid,
          'title': title,
          'description': description,
          'price': price,
        };

        await newArticleRef.set(articleData);
      }
    } catch (e) {
      print('Error uploading article: $e');
    }
  }
}
