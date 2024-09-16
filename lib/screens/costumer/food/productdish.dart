// lib/models/dish.dart
class Dish {
  final String id;
  final String name;
  final int price;
  int quantity;
  final String image;

  Dish({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'image': image,
    };
  }
}
