class Store {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final String category;
  final String specialisation;
  final String rating;
  final List<String> products;
  final String openingHours;
  final bool cod;
  final bool freeDelivery;
  final bool returnAvailable;

  Store({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    required this.category,
    required this.specialisation,
    required this.rating,
    required this.products,
    required this.openingHours,
    required this.cod,
    required this.freeDelivery,
    required this.returnAvailable,
  });

  Store.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? '',
        name = json['name'] ?? '',
        address = json['address'] ?? '',
        latitude = json['latitude'] ?? 0.0,
        longitude = json['longitude'] ?? 0.0,
        imageUrl = json['imageUrl'] ?? '',
        category = json['category'] ?? '',
        specialisation = json['specialisation'] ?? '',
        rating = json['rating'] ?? '',
        products = List<String>.from(json['products'] ?? []),
        openingHours = json['openingHours'] ?? '',
        cod = json['cod'] ?? false,
        freeDelivery = json['freeDelivery'] ?? false,
        returnAvailable = json['returnAvailable'] ?? false;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'category': category,
      'specialisation': specialisation,
      'rating': rating,
      'products': products,
      'openingHours': openingHours,
      'cod': cod,
      'freeDelivery': freeDelivery,
      'returnAvailable': returnAvailable,
    };
  }

  Store copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? imageUrl,
    String? category,
    String? specialisation,
    String? rating,
    List<String>? products,
    String? openingHours,
    bool? cod,
    bool? freeDelivery,
    bool? returnAvailable,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      specialisation: specialisation ?? this.specialisation,
      rating: rating ?? this.rating,
      products: products ?? this.products,
      openingHours: openingHours ?? this.openingHours,
      cod: cod ?? this.cod,
      freeDelivery: freeDelivery ?? this.freeDelivery,
      returnAvailable: returnAvailable ?? this.returnAvailable,
    );
  }
}
