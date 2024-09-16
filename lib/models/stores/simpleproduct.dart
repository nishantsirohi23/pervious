class Product {
  final String id;
  final String name;
  final int price;
  int quantity;
  final String image;
  final String review;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
    required this.review,
  });

  // Add this method to convert Product to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'image': image,
      'review': review,
    };
  }
}
