import 'package:perwork/onboding/components/custom_sign_in_dialog.dart';

class Dishesss {
  late String id;
  late String name;
  late int price;
  late int review;
  late String image;




  Dishesss({
    required this.id,
    required this.name,
    required this.image,
    required this.review,
    required this.price,



  });

  Dishesss.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    name = json['name'] ?? '';
    image = json['image'] ?? '';
    price = json['latitude'] ?? 0;
    review = json['longitude'] ?? 0;



  }

  Map<String, dynamic> toMap() {

    return {
      'id': id,
      'name': name,
      'image': image,
      'review': review,
      'price': price,


    };


  }
}
