class Product {
  final String id;
  final String name;
  final String description;
  final int price;
  final String currency;
  final List<String> categories;
  final List<String> imageUrls;
  final String storeId;
  final int totalReviews;
  final double rating;
  final bool inStock;
  final bool haveWarranty;
  final String warrantyTime;
  final String deliveryVehicle;
  final bool returnAvailable; // New field for return availability
  final String returnTime; // New field for return time

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.categories,
    required this.imageUrls,
    required this.storeId,
    required this.totalReviews,
    required this.rating,
    required this.inStock,
    required this.haveWarranty,
    required this.warrantyTime,
    required this.deliveryVehicle,
    required this.returnAvailable, // New field for return availability
    required this.returnTime, // New field for return time
  });

  Product.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? '',
        name = json['name'] ?? '',
        description = json['description'] ?? '',
        price = json['price'] ?? 0.0,
        currency = json['currency'] ?? '',
        categories = List<String>.from(json['categories'] ?? []),
        imageUrls = List<String>.from(json['imageUrls'] ?? []),
        storeId = json['storeId'] ?? '',
        totalReviews = json['totalReviews'] ?? 0,
        rating = json['rating'] ?? 0.0,
        inStock = json['inStock'] ?? true,
        haveWarranty = json['haveWarranty'] ?? false,
        warrantyTime = json['warrantyTime'] ?? '',
        deliveryVehicle = json['deliveryVehicle'] ?? 'Bike',
        returnAvailable = json['returnAvailable'] ?? false, // New field for return availability
        returnTime = json['returnTime'] ?? ''; // New field for return time

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'categories': categories,
      'imageUrls': imageUrls,
      'storeId': storeId,
      'totalReviews': totalReviews,
      'rating': rating,
      'inStock': inStock,
      'haveWarranty': haveWarranty,
      'warrantyTime': warrantyTime,
      'deliveryVehicle': deliveryVehicle,
      'returnAvailable': returnAvailable, // New field for return availability
      'returnTime': returnTime, // New field for return time
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    int? price,
    String? currency,
    List<String>? categories,
    List<String>? imageUrls,
    String? storeId,
    int? totalReviews,
    double? rating,
    bool? inStock,
    bool? haveWarranty,
    String? warrantyTime,
    String? deliveryVehicle,
    bool? returnAvailable, // New field for return availability
    String? returnTime, // New field for return time
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      categories: categories ?? this.categories,
      imageUrls: imageUrls ?? this.imageUrls,
      storeId: storeId ?? this.storeId,
      totalReviews: totalReviews ?? this.totalReviews,
      rating: rating ?? this.rating,
      inStock: inStock ?? this.inStock,
      haveWarranty: haveWarranty ?? this.haveWarranty,
      warrantyTime: warrantyTime ?? this.warrantyTime,
      deliveryVehicle: deliveryVehicle ?? this.deliveryVehicle,
      returnAvailable: returnAvailable ?? this.returnAvailable, // New field for return availability
      returnTime: returnTime ?? this.returnTime, // New field for return time
    );
  }
}
