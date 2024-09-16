
import 'package:cloud_firestore/cloud_firestore.dart';

class Globals {
  static String apiKey = ""; // Define your global variable

  // Singleton pattern to ensure only one instance of Globals exists
  static final Globals _instance = Globals._internal();

  factory Globals() {
    return _instance;
  }

  Globals._internal();

  // Function to fetch API key from Firestore
  static Future<void> fetchApiKey() async {
    try {
      DocumentSnapshot document = await FirebaseFirestore.instance
          .collection('values') // Replace with your collection name
          .doc('values') // Replace with your document ID
          .get();

      if (document.exists) {
        apiKey = document.get('api'); // Replace with your field name
        print("API Key fetched: $apiKey"); // Optional: Print for verification
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching API key: $e');
    }
  }
}
