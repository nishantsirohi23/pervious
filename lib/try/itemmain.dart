import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:perwork/screens/costumer/food/dlb.dart';
import 'package:perwork/screens/costumer/food/introsearch.dart';
import 'package:perwork/screens/itemdelivery.dart';
import 'package:perwork/screens/profilescreen.dart';
import 'package:perwork/try/productbottom.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../api/apis.dart';
import '../try/chatlist.dart';
import '../try/shownotifications.dart';
import '../utils/LocationService.dart';
import '../widgets/dashedline.dart';
import '../widgets/work/RounderImageslider.dart';
import '../widgets/work/searchbar.dart';
import '../widgets/work/spotlightrestraunts.dart';
import 'itemcartcheckout.dart';
import 'itemsearchscreen.dart';

class ItemMain extends StatefulWidget {
  const ItemMain({Key? key}) : super(key: key);

  @override
  State<ItemMain> createState() => _IntroMainState();
}

class _IntroMainState extends State<ItemMain> {
  int nnotibooking = 0;
  int nnotiwork = 0;
  double _latitude = 0.0;
  double _longitude = 0.0;
  late LocationService _locationService;
  void _loadUserData() async {
    await APIs.getSelfInfo();
    setState(() {
      isLoading = false;
    });
  }
  Future<void> _getCurrentLocation() async {
    FirebaseFirestore.instance.collection('users').doc(APIs.me.id).snapshots().listen((DocumentSnapshot snapshot) {
      setState(() {
        _latitude = snapshot['latitude'] ?? 0;
        _longitude = snapshot['longitude'] ?? 0;

      });
    });

  }

  bool isLoading = true;
  int nmessage = 0;
  int itemCount = 1;

  Future<void> getdate() async {
    FirebaseFirestore.instance.collection('users').doc(APIs.me.id).snapshots().listen((DocumentSnapshot snapshot) {
      setState(() {
        nnotibooking = snapshot['nnotibooking'] ?? 0;
        nnotiwork = snapshot['nnotiwork'] ?? 0;
        nmessage = snapshot['nmessage'] ?? 0;

      });
    });
    final CollectionReference workCollection = FirebaseFirestore.instance.collection('restraunts');
// Get the snapshots of documents within the collection
    QuerySnapshot querySnapshot = await workCollection.get();

// Get the count of items
    setState(() {
      itemCount = querySnapshot.docs.length;

    });

  }
  @override
  void initState() {
    super.initState();
    getdate();
    _itemsData =
        _futureData = getSpotlightRestaurants();
    _itemsData = getItems();
    _restrauntsData = getRestraunts();
    _profData = getProfs();


    _locationService = LocationService();
    _getCurrentLocation();
    // Fetch user information when the widget is first created
    _loadUserData();

  }

  Future<QuerySnapshot> getSpotlightRestaurants() async {
    isLoading = false;
    return FirebaseFirestore.instance.collection('spotlightrestraunts').get();
  }Future<QuerySnapshot> getItems() async {
    isLoading = false;
    return FirebaseFirestore.instance.collection('lookingfor').get();
  }
  Future<QuerySnapshot> getRestraunts() async {
    isLoading = false;
    return FirebaseFirestore.instance.collection('restraunts').get();
  }
  Future<QuerySnapshot> getProfs() async {
    isLoading = false;
    return FirebaseFirestore.instance.collection('introfirst').get();
  }

  String getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Morning';
    } else if (hour < 17) {
      return 'Afternoon';
    } else {
      return 'Evening';
    }
  }

  late Future<QuerySnapshot> _futureData;
  late Future<QuerySnapshot> _itemsData;
  late Future<QuerySnapshot> _restrauntsData;
  late Future<QuerySnapshot> _profData;


  int myCurrentIndex = 0;

  static Widget _buildImage(String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12), // Adjust the border radius as needed
      child: CachedNetworkImage(
        imageUrl: imagePath,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 280, // Adjust the width as needed
            height: 130, // Adjust the height as needed
            color: Colors.white, // You can set any color here
          ),
        ),
        errorWidget: (context, url, error) => Icon(Icons.error),
        imageBuilder: (context, imageProvider) => Container(
          width: 280,
          height: 130,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );

  }
  @override
  Widget build(BuildContext context) {
    bool showContainer = false;

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;



    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,

      body:SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
                height: screenHeight * 0.3,
                decoration: BoxDecoration(

                    borderRadius: BorderRadius.all(Radius.circular(35))),
                child: Stack(
                  children: [
                    Container(
                      height: screenHeight*0.3,
                      width: screenWidth,

                      decoration: BoxDecoration(

                          borderRadius:  BorderRadius.all(Radius.circular(35))
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(35))
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(35)),
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: 'https://firebasestorage.googleapis.com/v0/b/perwork.appspot.com/o/This%20Match%20Day%2C%20Enjoy.png?alt=media&token=85ba5536-321c-4d29-86db-4a02d9dcb1b1', // URL of the image
                            width: screenWidth, // Double the radius to fit the CircleAvatar
                            height: screenHeight*0.22, // Double the radius to fit the CircleAvatar
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: 84, // Double the radius to fit the CircleAvatar
                                height: 84, // Double the radius to fit the CircleAvatar
                                color: Colors.white,
                              ),
                            ),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          ),

                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20,right: 20),
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  transitionDuration: Duration(milliseconds: 400),
                                  pageBuilder: (_, __, ___) => SearchScreen(),
                                  transitionsBuilder: (_, animation, __, child) {
                                    return ScaleTransition(
                                      scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                                        CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeInOutQuad,
                                        ),
                                      ),
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            },
                            child: Stack(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: screenHeight * 0.12),
                                  child: DynamicSearchBar(
                                    searchSuggestions: ['Chips', 'Cadbury Oreo','Bread','Sanitary'],
                                  ),
                                ),
                                Positioned.fill(
                                  child: Container(
                                    color: Colors.transparent,
                                    margin: EdgeInsets.only(top: screenHeight * 0.12),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            margin: EdgeInsets.only(top: screenHeight*0.053),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Delivering To",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: screenHeight*0.02

                                          ),
                                        ),

                                      ],
                                    ),
                                    Container(
                                      width: screenWidth*0.64,
                                      child: Text(
                                        maxLines: 1,
                                        overflow: TextOverflow.clip,
                                        APIs.me.about,
                                        style: TextStyle(color: CupertinoColors.white, fontSize:  screenHeight*0.021),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [

                                    SizedBox(width: 13),
                                    GestureDetector(
                                        onTap: (){
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => ProfileScreen()),
                                          );
                                        },
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.all(Radius.circular(35)),
                                          child: CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            imageUrl: APIs.me.image, // URL of the image
                                            width: 40, // Double the radius to fit the CircleAvatar
                                            height: 40, // Double the radius to fit the CircleAvatar
                                            placeholder: (context, url) => Shimmer.fromColors(
                                              baseColor: Colors.grey[300]!,
                                              highlightColor: Colors.grey[100]!,
                                              child: Container(
                                                width: 80, // Double the radius to fit the CircleAvatar
                                                height: 80, // Double the radius to fit the CircleAvatar
                                                color: Colors.white,
                                              ),
                                            ),
                                            errorWidget: (context, url, error) => Icon(Icons.error),
                                          ),
                                        )
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),

                        ],
                      ),
                    ),
                  ],
                )
            ),
            SizedBox(height: 14,),

            Container(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('categories').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  var categories = snapshot.data!.docs;
                  var screenWidth = MediaQuery.of(context).size.width;
                  var itemWidth = screenWidth / 4;

                  return GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true, // Let the GridView take only the space it needs
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.vertical,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: categories.length > 8 ? 8 : categories.length, // Limit to first 8 items
                    itemBuilder: (context, index) {
                      var category = categories[index];
                      return GestureDetector(
                        onTap: (){
                          print(category.id);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>   ItemDelivery(categoryId: category.id,categoryName: category["name"],)),
                          );
                        },
                        child: Container(
                          width: itemWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(18.0),
                                  color: Colors.transparent,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.5),
                                      spreadRadius: 3,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                height: itemWidth * 0.6,
                                width: itemWidth * 0.6,
                                padding: EdgeInsets.all(4),
                                child: ClipRRect(
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl: category['image'], // URL of the image
                                    placeholder: (context, url) => Shimmer.fromColors(
                                      baseColor: Colors.grey[100]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(

                                        width: 84, // Double the radius to fit the CircleAvatar
                                        height: 84, // Double the radius to fit the CircleAvatar
                                        color: Colors.white,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                  ),

                                ),
                              ),
                              Container(
                                width: itemWidth * 0.8,
                                child: Text(
                                  category['name'],
                                  overflow: TextOverflow.clip,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 12,right: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Beat the Heat",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 19,
                        fontWeight: FontWeight.w500
                    ),),
                  Text("See All")

                ],
              ),
            ),
            Container(
              height: 250,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('products')
                    .where('availability', isEqualTo: true)
                    .where('collection', isEqualTo: 'Drinks & Juices')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final products = snapshot.data!.docs;

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: products.length > 10 ? 10 : products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              return ProductBottomSheet(
                                name: product['name'],
                                brand: product['description'],
                                itemId: product.id,
                                mrp: product['price'].toString(),
                                des: product['des'],
                                price: product['disprice'].toString(),
                                images: List<String>.from(product['image']),
                                flavor: "Flavor",
                              );
                            },
                          );
                        },
                        child: ProductCard(
                          discount: product['discount'].toString(),
                          name: product['name'],
                          originalPrice: product['price'].toString(),
                          discountedPrice: product['disprice'].toString(),
                          imageUrl: product['image'][0],
                          itemId: product.id,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 12,right: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Fresh Vegetables",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 19,
                        fontWeight: FontWeight.w500
                    ),),
                  Text("See All")

                ],
              ),
            ),
            Container(
              height: 250,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('products')
                    .where('availability', isEqualTo: true)
                    .where('subcollection', isEqualTo: 'Fresh Vegetables')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final products = snapshot.data!.docs;

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: products.length > 10 ? 10 : products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              return ProductBottomSheet(
                                name: product['name'],
                                brand: product['description'],
                                itemId: product.id,
                                mrp: product['price'].toString(),
                                des: product['des'],
                                price: product['disprice'].toString(),
                                images: List<String>.from(product['image']),
                                flavor: "Flavor",
                              );
                            },
                          );
                        },
                        child: ProductCard(
                          discount: product['discount'].toString(),
                          name: product['name'],
                          originalPrice: product['price'].toString(),
                          discountedPrice: product['disprice'].toString(),
                          imageUrl: product['image'][0],
                          itemId: product.id,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 12,right: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Chips and Crisps",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 19,
                        fontWeight: FontWeight.w500
                    ),),
                  Text("See All")

                ],
              ),
            ),
            Container(
              height: 260,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('products')
                    .where('availability', isEqualTo: true)
                    .where('subcollection', isEqualTo: 'Chips and Crisps ')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final products = snapshot.data!.docs;

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: products.length > 10 ? 10 : products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              return ProductBottomSheet(
                                name: product['name'],
                                brand: product['description'],
                                itemId: product.id,
                                mrp: product['price'].toString(),
                                des: product['des'],
                                price: product['disprice'].toString(),
                                images: List<String>.from(product['image']),
                                flavor: "Flavor",
                              );
                            },
                          );
                        },
                        child: ProductCard(
                          discount: product['discount'].toString(),
                          name: product['name'],
                          originalPrice: product['price'].toString(),
                          discountedPrice: product['disprice'].toString(),
                          imageUrl: product['image'][0],
                          itemId: product.id,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('categories').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  var categories = snapshot.data!.docs;
                  var screenWidth = MediaQuery.of(context).size.width;
                  var itemWidth = screenWidth / 4;

                  return GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true, // Let the GridView take only the space it needs
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.vertical,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: (categories.length - 8).clamp(0, 8), // Show only 8 items starting from index 8
                    itemBuilder: (context, index) {
                      var category = categories[index + 8]; // Start from index 8
                      return GestureDetector(
                        onTap: (){
                          print(category.id);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ItemDelivery(categoryId: category.id, categoryName: category["name"],)),
                          );
                        },
                        child: Container(
                          width: itemWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 8,right: 8,bottom: 4,top: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(18.0),
                                  color: Colors.transparent,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.5),
                                      spreadRadius: 3,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                height: itemWidth * 0.6,
                                width: itemWidth * 0.6,
                                padding: EdgeInsets.all(4),
                                child: ClipRRect(
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl: category['image'], // URL of the image
                                    placeholder: (context, url) => Shimmer.fromColors(
                                      baseColor: Colors.grey[100]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
                                        width: 84, // Double the radius to fit the CircleAvatar
                                        height: 84, // Double the radius to fit the CircleAvatar
                                        color: Colors.white,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                  ),
                                ),
                              ),
                              Container(
                                width: itemWidth * 0.8,
                                child: Text(
                                  category['name'],
                                  overflow: TextOverflow.clip,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 12,right: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Kuch Metha",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 19,
                        fontWeight: FontWeight.w500
                    ),),
                  Text("See All")

                ],
              ),
            ),
            Container(
              height: 260,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('products')
                    .where('availability', isEqualTo: true)
                    .where('collection', isEqualTo: 'Chocolates & Sweets')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final products = snapshot.data!.docs;

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: products.length > 10 ? 10 : products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              return ProductBottomSheet(
                                name: product['name'],
                                brand: product['description'],
                                itemId: product.id,
                                mrp: product['price'].toString(),
                                des: product['des'],
                                price: product['disprice'].toString(),
                                images: List<String>.from(product['image']),
                                flavor: "Flavor",
                              );
                            },
                          );
                        },
                        child: ProductCard(
                          discount: product['discount'].toString(),
                          name: product['name'],
                          originalPrice: product['price'].toString(),
                          discountedPrice: product['disprice'].toString(),
                          imageUrl: product['image'][0],
                          itemId: product.id,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 12,right: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Baby Care",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 19,
                        fontWeight: FontWeight.w500
                    ),),
                  Text("See All")

                ],
              ),
            ),
            Container(
              height: 260,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('products')
                    .where('availability', isEqualTo: true)
                    .where('collection', isEqualTo: 'Baby Care')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final products = snapshot.data!.docs;

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: products.length > 10 ? 10 : products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              return ProductBottomSheet(
                                name: product['name'],
                                brand: product['description'],
                                itemId: product.id,
                                mrp: product['price'].toString(),
                                des: product['des'],
                                price: product['disprice'].toString(),
                                images: List<String>.from(product['image']),
                                flavor: "Flavor",
                              );
                            },
                          );
                        },
                        child: ProductCard(
                          discount: product['discount'].toString(),
                          name: product['name'],
                          originalPrice: product['price'].toString(),
                          discountedPrice: product['disprice'].toString(),
                          imageUrl: product['image'][0],
                          itemId: product.id,
                        ),
                      );
                    },
                  );
                },
              ),
            ),













          ],
        ),
      ),
      bottomNavigationBar: CartSummary1(),

    );
  }
}
class ProductCard extends StatelessWidget {
  final String discount;
  final String name;
  final String originalPrice;
  final String discountedPrice;
  final String imageUrl;
  final String itemId;


  ProductCard({
    required this.discount,
    required this.name,
    required this.originalPrice,
    required this.discountedPrice,
    required this.imageUrl,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width*0.36,
      decoration: BoxDecoration(

        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      margin: EdgeInsets.all(5.0),
      child: Padding(
        padding: EdgeInsets.only(left: 10,right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 1,),
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(18.0),
                color: Colors.transparent,

              ),
              child:
              Center(
                child: ClipRRect(
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    height: 90,
                    imageUrl: imageUrl, // URL of the image
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[100]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(

                        width: 84, // Double the radius to fit the CircleAvatar
                        height: 84, // Double the radius to fit the CircleAvatar
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),

                ),
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              discount + "%",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 36.0,
              child: Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.clip,
              ),
            ),
            Row(
              children: [
                Text(
                  originalPrice,
                  style: TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                    fontSize: 17
                  ),
                ),
                SizedBox(width: 5.0),
                Text(
                  discountedPrice,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                      fontSize: 17.5

                  ),
                ),
              ],
            ),
            Center(
              child: QuantitySelector(
                itemId: itemId,
                name: name,
                image: imageUrl,
                price: discountedPrice,
                imageUrl: imageUrl,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class CartSummary1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("users").doc(APIs.me.id).collection('item_cart').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final items = snapshot.data?.docs ?? [];

        if (items.isEmpty) {
          return SizedBox.shrink();
        }

        int totalQuantity = 0; // Initialize total quantity

        // Iterate over each document and sum up the quantities
        items.forEach((DocumentSnapshot itemDoc) {
          final itemData = itemDoc.data() as Map<String, dynamic>;
          int quantity = itemData['quantity'] ?? 0;
          totalQuantity += quantity;
        });

        return Container(
          padding: EdgeInsets.only(left: 12,right: 12),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [Container(
                  height: 70,
                  width: items.length>=3?130:items.length*52,
                  padding: EdgeInsets.all(10.0),
                  color: Colors.white,
                  child: Stack(
                    children: items.take(3).map((QueryDocumentSnapshot itemDoc) {
                      final itemData = itemDoc.data() as Map<String, dynamic>;
                      print(itemData);
                      return Positioned(
                        left: items.indexOf(itemDoc) * 30.0,
                        child: Container(
                          width: 40, // Adjust width and height as needed
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(itemData['image'] ?? '',),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                  Text('Total Items: $totalQuantity'),

                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>   ItemCartCheckout()),
                  );
                  // Navigate to cart page or handle continue to cart action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                ),
                child: Row(
                  children: [
                    Text('Cart', style: TextStyle(color: Colors.white)),
                    SizedBox(width: 7,),
                    Icon(Icons.arrow_forward_ios,size: 14, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

