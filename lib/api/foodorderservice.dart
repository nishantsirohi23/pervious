import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dishcart.dart';

class FoodOrderService {
  static Future<void> placeOrder({
    required String id, // Add this parameter to receive the document ID

    required int totalQuantity,
    required String restID,
    required double distance,
    required String paymentMode,
    required int totalAmount,
    required bool payment,
    required int tip,
    required String orderBy,
    required String restname,
    required String restimage,
    required DateTime orderPlacedAt,
    required String restaddress,
    required String deliveryaddress,
    required double sourcelat,
    required double sourcelong,
    required double destlat,
    required double destlong,
    required String status,
    required int deliveryFee,

    required Map<String, Dish> dishes,
  }) async {
    try {
      // Example: Saving order data to Firestore
      await FirebaseFirestore.instance.collection('orders').add({
        'id': id, // Include the document ID in the document data
        'deliveryFee':deliveryFee,
        'totalQuantity': totalQuantity,
        'restID': restID,
        'distance': distance,
        'paymentMode': paymentMode,
        'totalAmount': totalAmount,
        'payment': payment,
        'tip': tip,
        'orderBy': orderBy,
        'restname': restname,
        'restimage': restimage,
        'orderPlacedAt': orderPlacedAt,
        'restaddress': restaddress,
        'deliveryaddress': deliveryaddress,
        'sourcelat': sourcelat,
        'sourcelong': sourcelong,
        'destlat': destlat,
        'destlong': destlong,
        'status': status,
        'dishes': dishes.entries.map((entry) => entry.value.toMap()).toList(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Order placed successfully');
    } catch (e) {
      print('Error placing order: $e');
      throw Exception('Failed to place order');
    }
  }
}
