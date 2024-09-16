import 'package:perwork/onboding/components/custom_sign_in_dialog.dart';

class Rests {
  late String id;
  late String name;
  late String address;
  late String distance;
  late String image;
  late double latitude;
  late double longitude;
  late String rating;
  late String specs;
  late String time;
  late List<String> dishes;



  Rests({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.image,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.specs,
    required this.time,
    required this.dishes,

  });

  Rests.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    name = json['name'] ?? '';
    address = json['address'] ?? '';
    distance = json['distance'] ?? '';
    image = json['image'] ?? '';
    latitude = json['latitude'] ?? 0.0;
    longitude = json['longitude'] ?? 0.0;
    specs = json['specs'] ?? '';
    time = json['time'] ?? '';
    dishes = List<String>.from(json['specialities'] ?? []);
    rating = json['rating'] ?? '';


  }

  Map<String, dynamic> toMap() {

    return {
      'id': id,
      'name': name,
      'address': address,
      'image': image,
      'latitude': latitude,
      'longitude': longitude,
      'specs': specs,
      'time': time,
      'dishes': dishes,
      'rating': rating,
      'distance':distance


    };


  }
}
