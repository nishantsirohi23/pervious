import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:perwork/screens/profilescreen.dart';
import '../../api/apis.dart';
import '../../models/stores/CheckoutScreen.dart';

import 'package:carousel_slider/carousel_slider.dart';



class RestrauntScreen extends StatefulWidget {
  final String id;


  RestrauntScreen({
    required this.id,

  });

  @override
  _RestrauntScreenState createState() => _RestrauntScreenState();
}

class _RestrauntScreenState extends State<RestrauntScreen> {
  Map<String, Product> dishes = {};
  String _searchQuery = "";
  bool isopen = false;
  String name = "";
  String address = "";
  String rating = "";
  String image = "";
  String storecategory = "";
  bool cod_available = false;
  bool return_available = false;
  double storelat = 0.0;
  double storelong = 0.0;
  bool isloading = true;
  double drivingDistance = 0.0;
  int time = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCustomDialog();
    });
    _loadCartItems();
    getStoreDetails(widget.id);
  }
  void _showCustomDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _buildDialog(context);
      },
    );
  }
  Widget _buildDialog(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          bottom: 80, // Adjust this value to control the space between the dialog and the cancel button
          left: 10,   // Left margin
          right: 10,  // Right margin
          child: Container(
            width: screenWidth - 20, // Full screen width minus 20 (10 left + 10 right)
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOption("assets/cod.png", 'COD', 'Send a message to your contact',cod_available),
                Divider(
                  color: Colors.grey.shade300,
                ),
                _buildOption("assets/hourglass.png", 'Return Available', 'Add a contact to be able to send messages',return_available),
                Divider(
                  color: Colors.grey.shade300,
                ),
                _buildOption("assets/stock.png", 'Open box delivery', 'Join the community around you',true),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 10, // Position the cancel button at the bottom
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Text('Cancel'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOption(String image_icon, String title, String subtitle,bool available) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [Image.asset(image_icon,height: 28,width: 28,),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 15.5,
                    color: Colors.black,
                    fontFamily: 'Roboto', // or any other font family
                  ),
                  child: Text(title),
                ),

                SizedBox(height: 5),
                DefaultTextStyle(
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontFamily: 'Roboto', // or any other font family
                  ),
                  child: Text(subtitle),
                ),

              ],
            ),],
        ),
        (available==true)?Image.asset("assets/verify.png",height: 25,width: 25,):Icon(Icons.cancel,color: Colors.red,)
      ],
    );

  }
  Future<void> getStoreDetails(String storeId) async {
    // Fetch store data from Firestore
    DocumentSnapshot storeSnapshot = await FirebaseFirestore.instance
        .collection('stores')
        .doc(storeId)
        .get();

    if (storeSnapshot.exists) {
      Map<String, dynamic> storeData = storeSnapshot.data() as Map<String, dynamic>;

      // Fetch user's current location
      Position userPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      double userLat = userPosition.latitude;
      double userLong = userPosition.longitude;

      // Calculate the distance between user and store
      double storeLat = storeData['latitude'] ?? 0.0;
      double storeLong = storeData['longitude'] ?? 0.0;
      double distanceInMeters = Geolocator.distanceBetween(userLat, userLong, storeLat, storeLong);
      double distanceInKm = distanceInMeters / 1000.0;

      // Calculate driving time (assuming speed is 30 km/h) and round it to an integer
      int drivingTimeInMinutes = ((distanceInKm / 30) * 60).round();

      // Update the state synchronously
      setState(() {
        name = storeData['name'] ?? '';
        image = storeData['imageUrl'] ?? '';
        storelat = storeLat;
        storecategory = storeData['category'] ?? '';
        storelong = storeLong;
        cod_available = storeData['cod']?? false;
        return_available = storeData['returnAvailable']?? false;
        address = storeData['address'] ?? '';
        rating = storeData['rating'] ?? '';
        drivingDistance = distanceInKm; // Store distance in km
        time = drivingTimeInMinutes; // Store driving time in minutes as an integer
        isloading = false;
      });
    } else {
      print("Store not found");
    }
  }

  // Function to load cart items from Firebase
  Future<void> _loadCartItems() async {
    final cartRef = FirebaseFirestore.instance
        .collection('carts')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection(widget.id);

    final cartSnapshot = await cartRef.get();
    setState(() {
      for (var doc in cartSnapshot.docs) {
        dishes[doc.id] = Product(
          id: doc.id,
          name: doc['name'],
          price: doc['price'], // Price is now an int
          quantity: doc['quantity'],
          image: doc['image'],
          review: doc['name'],
        );
      }
    });
  }

  // Function to add item to cart
  Future<void> _addToCart(Map<String, dynamic> datadish) async {
    try {
      // Attempt to get documents from the "asdf" collection
      final collectionQuery = FirebaseFirestore.instance.collection('carts').doc(APIs.me.id).collection(widget.id).limit(1).get();

      final querySnapshot = await collectionQuery;

      if (querySnapshot.docs.isNotEmpty) {
        print('Collection "asdf" exists');
      } else {
        try {
          await FirebaseFirestore.instance.collection('carts').doc(APIs.me.id).set({
            'total': FieldValue.increment(1),
          }, SetOptions(merge: true));
          await FirebaseFirestore.instance.collection('carts').doc(APIs.me.id).update({
            'stores': FieldValue.arrayUnion([widget.id])
          }).then((_) {
            print("Item added to the list successfully!");
          }).catchError((error) {
            print("Failed to add item to the list: $error");
          });
          print('Total incremented successfully');
        } catch (e) {
          print('Error incrementing total: $e');
        }
        print('Collection "asdf" does not exist');
      }
    } catch (e) {
      print('Error checking collection: $e');
    }

    final dishId = datadish['id'];
    final cartRef = FirebaseFirestore.instance
        .collection('carts')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection(widget.id);

    if (dishes.containsKey(dishId)) {
      // Update quantity if dish already exists in cart
      dishes[dishId]!.quantity += 1;
    } else {
      // Add new dish to cart
      dishes[dishId] = Product(
        id: dishId,
        name: datadish['name'],
        price: datadish['price'], // Price is handled as an int
        quantity: 1,
        image: datadish['imageUrls'][0],
        review: datadish['name'],
      );
    }

    await cartRef.doc(dishId).set({
      'name': dishes[dishId]!.name,
      'price': dishes[dishId]!.price, // Saving price as int
      'quantity': dishes[dishId]!.quantity,
      'image': dishes[dishId]!.image,
      'review': dishes[dishId]!.review,
    });
    setState(() {
      isloading = false;
    });


  }

  // Function to increase quantity
  Future<void> _increaseQuantity(String dishId) async {
    setState(() {
      dishes[dishId]!.quantity += 1;
    });

    final cartRef = FirebaseFirestore.instance
        .collection('carts')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection(widget.id);

    await cartRef.doc(dishId).update({
      'quantity': dishes[dishId]!.quantity,
    });
    setState(() {
      isloading = false;
    });
  }

  // Function to decrease quantity
  Future<void> _decreaseQuantity(String dishId) async {
    if (dishes[dishId]!.quantity > 1) {
      setState(() {
        dishes[dishId]!.quantity -= 1;
      });

      final cartRef = FirebaseFirestore.instance
          .collection('carts')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection(widget.id);

      await cartRef.doc(dishId).update({
        'quantity': dishes[dishId]!.quantity,
      });
      setState(() {
        isloading = false;
      });
    } else {


      _removeFromCart(dishId);
    }
  }

  // Function to remove item from cart
  Future<void> _removeFromCart(String dishId) async {
    setState(() {
      dishes.remove(dishId);
    });
    if(dishes.isEmpty){
      try {
        await FirebaseFirestore.instance.collection('carts').doc(APIs.me.id).update({
          'total': FieldValue.increment(-1),
        });
        print('Total incremented successfully');
      } catch (e) {
        print('Error incrementing total: $e');
      }
      await FirebaseFirestore.instance.collection('carts').doc(APIs.me.id).update({
        'stores': FieldValue.arrayRemove([widget.id])
      }).then((_) {
        print("Item removed from the list successfully!");
      }).catchError((error) {
        print("Failed to remove item from the list: $error");
      });
    }

    final cartRef = FirebaseFirestore.instance
        .collection('carts')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection(widget.id);

    await cartRef.doc(dishId).delete();
    setState(() {
      isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    void _showProductDetails(Map<String, dynamic> data) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          String dishId = data['id'];
          bool isInCart = dishes.containsKey(dishId);

          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10,),
                Center(
                  child: Container(
                    width: 50,
                    height: 7,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10)
                    ),
                  ),
                ),
                SizedBox(height: 10,),

                // Image Carousel
                Expanded(child:
                SingleChildScrollView(
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CarouselSlider(
                          items: data['imageUrls'].map<Widget>((url) {
                            return Builder(
                              builder: (BuildContext context) {
                                return CachedNetworkImage(
                                  imageUrl: url,
                                  fit: BoxFit.cover,
                                  width: MediaQuery.of(context).size.width,
                                  placeholder: (context, url) => Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      color: Colors.white,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                );
                              },
                            );
                          }).toList(),
                          options: CarouselOptions(
                            height: MediaQuery.of(context).size.height * 0.23,
                            enlargeCenterPage: true,
                            enableInfiniteScroll: true,
                            autoPlay: true,
                          ),
                        ),

                        SizedBox(height: 20),
                        // Product Name and Price
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                data['name'],
                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),

                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(

                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                gradient: LinearGradient(
                                  colors: [Color(0xFFf9def6), Color(0xFFfdf0e4)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              height: 200,
                              width: MediaQuery.of(context).size.width*0.37,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Image.asset("assets/analysis.png",height: 50,width: 80,),
                                      Container(
                                        width: 40.0,  // Adjust the size as needed
                                        height: 40.0,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.north_east,  // The arrow pointing northeast icon
                                          color: Colors.black, // The color of the icon
                                          size: 24.0,          // Adjust the size of the icon as needed
                                        ),
                                      )

                                    ],
                                  ),
                                  Container(
                                    height: 30,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text("₹",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 27,
                                              fontWeight: FontWeight.w600
                                          ),),
                                        Text(data['price'].toString(),
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 27,
                                              fontWeight: FontWeight.w600
                                          ),),
                                        Text(".00",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w400
                                          ),)
                                      ],
                                    ),
                                  ),
                                  Container(
                                      padding: EdgeInsets.only(right: 5),
                                      height: 40,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Color(0xFFfb7d44), Color(0xFFfe84ba)], // Gradient colors
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        borderRadius: BorderRadius.circular(30.0), // Adjust the value for more or less rounded ends
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Container(
                                            width: 25.0,  // Adjust the size as needed
                                            height: 25.0,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.percent,  // The arrow pointing northeast icon
                                              color: Color(0xFFfb7d44), // The color of the icon
                                              size: 24.0,          // Adjust the size of the icon as needed
                                            ),
                                          ),
                                          Text("Extra 5% off",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 15),)

                                        ],
                                      )
                                  )

                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width*0.52,
                                  height: 100,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                      color: Color(0xFFf8f8f8)
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset("assets/stock.png",height: 30,width: 30,),
                                          SizedBox(width: 10,),
                                          (data['returnAvailable']==true)? Text(data['returnTime'],style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: 17),)
                                              :                                          Text("No Return",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: 17),)

                                        ],
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 7,right: 7),
                                        child: Divider(
                                          color: Colors.grey, // The color of the line
                                          thickness: 0.3,      // The thickness of the line
                                          indent: 0.0,         // The amount of space on the left side
                                          endIndent: 0.0,      // The amount of space on the right side
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Image.asset("assets/cod.png",height: 30,width: 30,),
                                          SizedBox(width: 10,),
                                          Text("COD:  ",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w400,fontSize: 16),),
                                          (cod_available==true)?Text("Available",style: TextStyle(color: Colors.green,fontWeight: FontWeight.w500,fontSize: 17),):Text("Not",style: TextStyle(color: Colors.red,fontWeight: FontWeight.w500,fontSize: 17),)
                                        ],
                                      ),

                                    ],
                                  ),
                                ),
                                SizedBox(height: 20,),
                                Container(

                                    width: MediaQuery.of(context).size.width*0.52,
                                    height: 70,
                                    padding: EdgeInsets.only(left:10,right: 20,top: 10,bottom: 10),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(20)),
                                        color: Color(0xFFf8f8f8)
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.star,color:Colors.yellow,size: 30,),
                                            Text(data['rating'].toString(),
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w600
                                              ),),
                                          ],
                                        ),
                                        Text("|",style: TextStyle(fontSize: 27,fontWeight: FontWeight.w100),),
                                        Text(data['totalReviews'].toString()+" Reviews",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 15,
                                          ),),
                                      ],
                                    )
                                )
                              ],
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20,vertical:
                          12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                data['description'],
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),

                            ],
                          ),
                        ),
                        Container(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                SizedBox(width: 10,),

                                Container(
                                    padding: EdgeInsets.only(right: 5,left: 10),
                                    height: 34,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Color(0xFFfb7d44), Color(0xFFfe84ba)], // Gradient colors
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(30.0), // Adjust the value for more or less rounded ends
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [

                                        Text("Extra 5% off",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 15),)

                                      ],
                                    )
                                ),
                                SizedBox(width: 10,),
                                Container(
                                    padding: EdgeInsets.only(right: 5,left: 10),
                                    height: 34,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Color(0xFFfb7d44), Color(0xFFfe84ba)], // Gradient colors
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(30.0), // Adjust the value for more or less rounded ends
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [

                                        Text("Extra 5% off",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 15),)

                                      ],
                                    )
                                ),
                                SizedBox(width: 10,),


                                Container(
                                    padding: EdgeInsets.only(right: 5,left: 10),
                                    height: 34,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Color(0xFFfb7d44), Color(0xFFfe84ba)], // Gradient colors
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(30.0), // Adjust the value for more or less rounded ends
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [

                                        Text("Extra 5% off",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 15),)

                                      ],
                                    )
                                ),
                                SizedBox(width: 10,),

                                Container(
                                    padding: EdgeInsets.only(right: 5,left: 10),
                                    height: 34,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Color(0xFFfb7d44), Color(0xFFfe84ba)], // Gradient colors
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(30.0), // Adjust the value for more or less rounded ends
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [

                                        Text("Extra 5% off",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 15),)

                                      ],
                                    )
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
                StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total: ₹${data['price'] * (dishes[dishId]?.quantity ?? 1)}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          isInCart
                              ? Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  isloading = true;
                                  if (dishes[dishId]!.quantity == 1) {
                                    isloading = true;
                                    _decreaseQuantity(dishId);
                                    Navigator.pop(context); // Close the bottom sheet if quantity is 1
                                  } else {
                                    setState(() {
                                      isloading = true;

                                      _decreaseQuantity(dishId);
                                    });
                                  }
                                },
                                icon: Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                ),
                              ),
                              Text(
                                '${dishes[dishId]!.quantity}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    isloading = true;
                                    _increaseQuantity(dishId);
                                  });
                                },
                                icon: Icon(
                                  Icons.add_circle,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          )
                              : GestureDetector(
                            onTap: () {

                              isloading = true;
                              _addToCart(data);
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: 40,
                              width: 130,
                              padding: EdgeInsets.only(left: 5,right: 5),
                              decoration: BoxDecoration(
                                  color: Colors.pink.withOpacity(0.9),
                                  borderRadius: BorderRadius.all(Radius.circular(13))
                              ),
                              child: Center(
                                child: Text(
                                  "Add to Cart",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 19
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    }


    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final CollectionReference dishesCollection =
    FirebaseFirestore.instance.collection('stores');

    final Stream<QuerySnapshot> _usersStream = dishesCollection
        .doc(widget.id)
        .collection('products')
        .snapshots();

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: screenHeight * 0.25,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/backappbar1.png"),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 50,
                      left: 20,
                      right: 25,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                child: Container(
                                  width: screenWidth * 0.6,
                                  height: 42,
                                  padding:
                                  EdgeInsets.only(left: 20, right: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                  ),
                                  child: Center(
                                    child: TextField(
                                      onChanged: (value) {
                                        setState(() {
                                          _searchQuery = value;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Search...',
                                        suffixIcon: Icon(Icons.search),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ProfileScreen()),
                                  );
                                },
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    APIs.me.image,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: screenWidth,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      margin: EdgeInsets.only(
                          left: 20, right: 20, top: 100, bottom: 20),
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: screenWidth * 0.63,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: screenHeight * 0.027,
                                  ),
                                ),
                                ClipRect(
                                  clipBehavior: Clip.hardEdge,
                                  child: Row(
                                    children: [
                                      Text(
                                        time.toString()+" mins",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Container(
                                        width: 4,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          address,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 7),
                                Expanded(
                                  child: Text(
                                    storecategory,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(0.7),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.all(Radius.circular(35)),
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: image , // URL of the image
                                  width: 55, // Double the radius to fit the CircleAvatar
                                  height: 55, // Double the radius to fit the CircleAvatar
                                  placeholder: (context, url) => Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      width: 110, // Double the radius to fit the CircleAvatar
                                      height: 110, // Double the radius to fit the CircleAvatar
                                      color: Colors.white,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                ),
                              ),

                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.yellow,
                                    size: 20,
                                  ),
                                  Text(
                                    rating,
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                ],
                              ),

                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _usersStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Something went wrong'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    return ListView(
                      padding: EdgeInsets.zero,
                      children: snapshot.data!.docs
                          .where((DocumentSnapshot document) {
                        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                        return data['name']
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase());
                      })
                          .map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                        String dishId = data['id'];
                        bool isInCart = dishes.containsKey(dishId);

                        return GestureDetector(
                          onTap: () {
                            _showProductDetails(data);

                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.all(Radius.circular(20)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: CachedNetworkImage(
                                    imageUrl: data['imageUrls'][0],
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        Shimmer.fromColors(
                                          baseColor: Colors.grey[300]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Container(
                                            width: 80,
                                            height: 80,
                                            color: Colors.white,
                                          ),
                                        ),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['name'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            color: Colors.yellow,
                                            size: 20,
                                          ),
                                          Text(
                                            data['name'],
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        "₹${data['price']}",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10),
                                isInCart
                                    ? Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        isloading = true;
                                        _decreaseQuantity(dishId);
                                      },
                                      icon: Icon(
                                        Icons.remove_circle,
                                        color: Colors.red,
                                      ),
                                    ),
                                    Text(
                                      '${dishes[dishId]!.quantity}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        isloading = true;
                                        _increaseQuantity(dishId);
                                      },
                                      icon: Icon(
                                        Icons.add_circle,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                )
                                    : GestureDetector(
                                  onTap: () {

                                    isloading = true;
                                    _addToCart(data);
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 70,
                                    padding: EdgeInsets.only(left: 5,right: 5),
                                    decoration: BoxDecoration(
                                        color: Colors.pink.withOpacity(0.9),
                                        borderRadius: BorderRadius.all(Radius.circular(15))
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Add",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 19
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
          Visibility(
            visible: dishes.isNotEmpty, // Check if dishes is not empty
            child: Positioned(
              bottom: 0,
              child: Container(
                width: screenWidth,
                height: screenHeight * 0.10,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 15,
                      offset: Offset(0, -3),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total: ₹${dishes.values.fold<int>(
                        0,
                            (sum, item) => sum + item.price * item.quantity,
                      )}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CheckoutScreen(storeId: widget.id)),
                        );
                      },
                      child: Container(
                        height: 40,
                        width: 115,
                        padding: EdgeInsets.only(left: 5,right: 5),
                        decoration: BoxDecoration(
                            color: Colors.pink.withOpacity(0.9),
                            borderRadius: BorderRadius.all(Radius.circular(9))
                        ),
                        child: Center(
                          child: Text(
                            "Go to Cart",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 19
                            ),
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
          Visibility(
              visible: isloading ,
              child: Container(
                margin: EdgeInsets.only(top: screenHeight*0.14),
                height: screenHeight*0.86,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3), // Adjust the sigmaX and sigmaY values for the blur effect
                  child: Container(
                    // Your content here
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black.withOpacity(0), // Adjust the opacity as needed
                    child: Center(
                        child: Lottie.asset("assets/lottie/loading.json")
                    ),
                  ),
                ),
              )
          )


        ],
      ),
    );
  }

}

class Product {
  final String id;
  final String name;
  final int price; // Price is now an int
  int quantity;
  final String image;
  final String review;

  Product({
    required this.id,
    required this.name,
    required this.price, // Price is handled as an int
    required this.quantity,
    required this.image,
    required this.review,
  });
}
