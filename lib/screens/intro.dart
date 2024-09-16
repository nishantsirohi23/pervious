import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:perwork/screens/costumer/food/dlb.dart';
import 'package:perwork/screens/costumer/food/introsearch.dart';
import 'package:perwork/screens/costumer/restrauntscreen.dart';
import 'package:perwork/screens/profilescreen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../api/apis.dart';
import '../models/stores/StoreDetailsScreen.dart';
import '../try/chatlist.dart';
import '../try/shownotifications.dart';
import '../utils/LocationService.dart';
import '../widgets/dashedline.dart';
import '../widgets/work/RounderImageslider.dart';
import '../widgets/work/searchbar.dart';
import '../widgets/work/spotlightrestraunts.dart';
import 'costumer/profession/searchprof.dart';

class IntroMain extends StatefulWidget {
  const IntroMain({Key? key}) : super(key: key);

  @override
  State<IntroMain> createState() => _IntroMainState();
}

class _IntroMainState extends State<IntroMain> {
  int nnotibooking = 0;
  int nnotiwork = 0;
  Position? _userPosition;
  final double _deliverySpeed = 40.0;
  double _latitude = 0.0;
  double _longitude = 0.0;
  late LocationService _locationService;
  void _loadUserData() async {
    await APIs.getSelfInfo();
    setState(() {
      isLoading = false;
    });
  }
  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _userPosition = position;
      });
    } catch (e) {
      // Handle location error
      print('Error getting location: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    FirebaseFirestore.instance.collection('users').doc(APIs.me.id).snapshots().listen((DocumentSnapshot snapshot) {
      setState(() {
        _latitude = snapshot['latitude'] ?? 0;
        _longitude = snapshot['longitude'] ?? 0;

      });
    });

  }
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // Distance in km
  }

  String _formatDistance(double distance) {
    return '${distance.toStringAsFixed(2)} kms';
  }

  String _calculateDeliveryTime(double distance) {
    double hours = distance / _deliverySpeed;
    return '${(hours * 60).toStringAsFixed(0)} minutes'; // Delivery time in minutes
  }
  Future<QuerySnapshot> getStoresnearby() async {
    try {
      return FirebaseFirestore.instance.collection('stores').get();
    } catch (e) {
      print('Error fetching stores: $e');
      rethrow;
    }
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
    _getUserLocation();
    getdate();
    _storeData =  getStoresnearby();
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

    return FirebaseFirestore.instance.collection('stores').get();
  }Future<QuerySnapshot> getItems() async {
    isLoading = false;
    return FirebaseFirestore.instance.collection('lookingforstores').get();
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
  final List<Widget> myItems = [
    _buildImage('https://firebasestorage.googleapis.com/v0/b/perwork.appspot.com/o/foodmenu%2FBlack%20Orange%20Modern%20Food%20Promotion%20Banner.jpg?alt=media&token=7bc5394f-ed58-4ea7-9e83-02ad07450ac8'),
    _buildImage('https://firebasestorage.googleapis.com/v0/b/perwork.appspot.com/o/foodmenu%2FBlack%20and%20Yellow%20Simple%20Minimalist%20Burger%20Promotion%20Banner.jpg?alt=media&token=dd6cb662-43b2-4b45-a648-b81f840d4c3c'),
    _buildImage('https://firebasestorage.googleapis.com/v0/b/perwork.appspot.com/o/foodmenu%2FRed%20Gold%20Modern%20Ramadan%20Special%20Menu%20Banner.jpg?alt=media&token=fdded3ee-565a-4291-931e-2639d589f1d6'),
    _buildImage('https://firebasestorage.googleapis.com/v0/b/perwork.appspot.com/o/foodmenu%2FYellow%20Creative%20Noodle%20Food%20Promotion%20Banner%20.jpg?alt=media&token=a912b7f2-c118-4769-996f-6277ef807560'),


  ];
  late Future<QuerySnapshot> _futureData;
  late Future<QuerySnapshot> _storeData;
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
          children: [

            Container(
                height: screenHeight * 0.2,
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
                                  pageBuilder: (_, __, ___) => IntroSearch(searchText: "",filter: "",),
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
                                    searchSuggestions: ['Jwellery', 'Electronics','gifts','Stationary'],
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
            SizedBox(height: 15,),
            Container(
                child:  SingleChildScrollView(
                  child: Column(
                    children: [
                      CarouselSlider(
                        options: CarouselOptions(
                          autoPlay: true,
                          height: screenHeight*0.15,
                          autoPlayCurve: Curves.fastOutSlowIn,
                          autoPlayAnimationDuration: const Duration(milliseconds: 800),
                          autoPlayInterval: const Duration(seconds: 2),
                          enlargeCenterPage: true,
                          aspectRatio: 1.0,
                          viewportFraction: 0.76,
                          onPageChanged: (index, reason) {
                            setState(() {
                              myCurrentIndex = index;
                            });
                          },
                        ),
                        items: myItems,
                      ),
                      SizedBox(height: 10,),
                      AnimatedSmoothIndicator(
                        activeIndex: myCurrentIndex,
                        count: myItems.length,
                        effect: WormEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          spacing: 10,
                          dotColor: Colors.grey.shade200,
                          activeDotColor: Colors.grey.shade900,
                          paintStyle: PaintingStyle.fill,
                        ),
                      )
                    ],
                  ),
                )

            ),
            SizedBox(height: 10,),
            Container(
              margin: EdgeInsets.only(left: 12),
              height: screenHeight*0.115,
              padding: EdgeInsets.only(top: 10,bottom: 10),
              child: FutureBuilder<QuerySnapshot>(
                future: _profData, // Assuming _usersStream() returns a Future<QuerySnapshot>
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("Loading");
                  }

                  // Filter documents based on search term
                  final List<QueryDocumentSnapshot> filteredDocuments =
                  snapshot.data!.docs.toList();



                  return ListView(
                    scrollDirection: Axis.horizontal,
                    children: filteredDocuments.map((DocumentSnapshot document) {
                      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

                      return GestureDetector(
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DinnerLunch(type: data['name'])),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(3),
                          margin: EdgeInsets.only(right: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: data['image'], // URL of the image
                              width: 170, // Double the radius to fit the CircleAvatar
                              height: 70, // Double the radius to fit the CircleAvatar
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
                      );
                    }).toList(),
                  );
                },
              ),
            ),

            SizedBox(height: 5,),
            Container(
              margin: EdgeInsets.only(left: 12,right: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("WHAT'S ON YOUR MIND",
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 16,
                    ),),

                ],
              ),
            ),
            SizedBox(height: 3,),
            Container(
              margin: EdgeInsets.only(left: 9),
              height: screenHeight * 0.13,
              child: FutureBuilder<QuerySnapshot>(
                future: _itemsData, // Assuming _usersStream() returns a Future<QuerySnapshot>
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("Loading");
                  }

                  // Filter documents based on search term
                  final List<QueryDocumentSnapshot> filteredDocuments =
                  snapshot.data!.docs.toList();

                  // Show only the first half of the documents
                  final halfIndex = (filteredDocuments.length / 2).ceil();
                  final firstHalf = filteredDocuments.sublist(0, halfIndex);

                  return ListView(
                    scrollDirection: Axis.horizontal,
                    children: firstHalf.map((DocumentSnapshot document) {
                      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                      final String firstWord = data['name'].split(' ').first;
                      return GestureDetector(
                        onTap: (){
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: Duration(milliseconds: 400),
                              pageBuilder: (_, __, ___) => IntroSearch(searchText: data['name'],filter: "restraunts",),
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
                        child: ClipRect(
                          clipBehavior: Clip.hardEdge,
                          child: Container(
                            color: Colors.transparent,
                            margin: EdgeInsets.only(right:20),


                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: screenHeight*0.04,
                                  backgroundColor: Colors.transparent, // Set background color for the circle
                                  child: ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: data['image'], // URL of the image
                                      width: screenHeight*0.07, // Double the radius to fit the CircleAvatar
                                      height: screenHeight*0.07, // Double the radius to fit the CircleAvatar
                                      placeholder: (context, url) => Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          width: screenHeight*0.06, // Double the radius to fit the CircleAvatar
                                          height: screenHeight*0.06, // Double the radius to fit the CircleAvatar
                                          color: Colors.white,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                    ),
                                  ),
                                ),
                                Text(
                                  firstWord, // Replaces spaces with newlines
                                  textAlign: TextAlign.center, // Centers the text
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 9),
              height: screenHeight * 0.13,
              child: FutureBuilder<QuerySnapshot>(
                future: _itemsData, // Assuming _usersStream() returns a Future<QuerySnapshot>
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("Loading");
                  }

                  // Filter documents based on search term
                  final List<QueryDocumentSnapshot> filteredDocuments =
                  snapshot.data!.docs.toList();

                  // Show only the last half of the documents
                  final halfIndex = (filteredDocuments.length / 2).floor();
                  final lastHalf = filteredDocuments.sublist(halfIndex);


                  return ListView(
                    scrollDirection: Axis.horizontal,
                    children: lastHalf.map((DocumentSnapshot document) {
                      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                      final String firstWord = data['name'].split(' ').first;
                      return GestureDetector(
                        onTap: (){
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: Duration(milliseconds: 400),
                              pageBuilder: (_, __, ___) => IntroSearch(searchText: data['name'],filter: "restraunts",),
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
                        child: ClipRect(
                          clipBehavior: Clip.hardEdge,
                          child: Container(
                            color: Colors.transparent,
                            margin: EdgeInsets.only(right:20),


                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: screenHeight*0.04,
                                  backgroundColor: Colors.transparent, // Set background color for the circle
                                  child: ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: data['image'], // URL of the image
                                      width: screenHeight*0.07, // Double the radius to fit the CircleAvatar
                                      height: screenHeight*0.07, // Double the radius to fit the CircleAvatar
                                      placeholder: (context, url) => Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          width: screenHeight*0.06, // Double the radius to fit the CircleAvatar
                                          height: screenHeight*0.06, // Double the radius to fit the CircleAvatar
                                          color: Colors.white,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                    ),
                                  ),
                                ),
                                Text(
                                  firstWord, // Replaces spaces with newlines
                                  textAlign: TextAlign.center, // Centers the text
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),


            SizedBox(height: 10,),

            Container(
              margin: EdgeInsets.only(left: 12,right: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("FEATURED RESTAURUNTS",
                    style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                        fontWeight: FontWeight.w500
                    ),),
                  Text("View All",
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 15.7,
                    ),),
                ],
              ),
            ),
            SizedBox(height: 10,),
            Container(
              margin: EdgeInsets.only(right: 6),
              height: screenHeight*0.27,
              child: FutureBuilder<QuerySnapshot>(
                future: _futureData, // Assuming _usersStream() returns a Future<QuerySnapshot>
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("Loading");
                  }

                  // Filter documents based on search term
                  final List<QueryDocumentSnapshot> filteredDocuments =
                  snapshot.data!.docs.toList();

                  return ListView(
                    scrollDirection: Axis.horizontal,
                    children: filteredDocuments.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;



                      // Determine background color based on priority


                      return GestureDetector(
                        onTap: (){Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>   RestrauntScreen(id: data['id']

                          )),
                        );},
                        child: ClipRect(
                          clipBehavior: Clip.hardEdge,
                          child: Container(
                            margin: EdgeInsets.only(left: 18),
                            height: screenHeight * 0.27,
                            width: screenWidth * 0.41,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    height: screenHeight * 0.165,
                                    width: screenWidth * 0.45,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(20),
                                        topLeft: Radius.circular(20),
                                      ),

                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(20),
                                          topLeft: Radius.circular(20),
                                        ),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(20),
                                            topLeft: Radius.circular(20),
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(20),
                                            topLeft: Radius.circular(20),
                                          ),
                                          child: CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            imageUrl: data['imageUrl'], // URL of the image
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
                                    )

                                ),
                                Container(
                                  color: Colors.transparent,
                                  padding: EdgeInsets.only(left: 7, right: 7, top: 4,bottom: 4),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(

                                        data['name'],maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 19,
                                        ),
                                      ),
                                      Container(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Image.asset(
                                                  "assets/star.png",
                                                  height: 25,
                                                  width: 25,
                                                ),
                                                Text(data['rating']),
                                              ],
                                            ),
                                            SizedBox(width: 3),
                                            Container(
                                              width: 4, // Adjust width and height to change the size of the dot
                                              height: 4,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle, // Shape of the container
                                                color: Colors.black87, // Color of the dot
                                              ),
                                            ),
                                            SizedBox(width: 3),
                                            Text(data['name'] + " mins"),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          data['address'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 17,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );

                    }).toList(),
                  );
                },
              ),
            ),
            SizedBox(height: 12,),
            Container(
              margin: EdgeInsets.only(left: 12,right: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Stores near you",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 19,
                        fontWeight: FontWeight.w500
                    ),),

                ],
              ),
            ),
            SizedBox(height: 10,),
            Container(
              margin: EdgeInsets.only(right: 6),
              child: FutureBuilder<QuerySnapshot>(
                future: _futureData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No stores available.'));
                  }

                  // Get the store data
                  final stores = snapshot.data!.docs.map((doc) {
                    final store = doc.data() as Map<String, dynamic>;
                    final lat = store['latitude']?.toDouble() ?? 0.0;
                    final lon = store['longitude']?.toDouble() ?? 0.0;
                    final distance = _calculateDistance(
                      _userPosition!.latitude,
                      _userPosition!.longitude,
                      lat,
                      lon,
                    );
                    return {
                      'id': doc.id,
                      'name': store['name'],
                      'address': store['address'],
                      'imageUrl': store['imageUrl'],
                      'rating': store['rating'],
                      'distance': distance,
                      'deliveryTime': _calculateDeliveryTime(distance),
                    };
                  }).toList();

                  // Sort stores by distance
                  stores.sort((a, b) => a['distance'].compareTo(b['distance']));

                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true, // Allows the ListView to take only as much space as needed
                    physics: NeverScrollableScrollPhysics(), // Prevents the ListView from being scrollable
                    itemCount: stores.length,
                    itemBuilder: (context, index) {
                      final store = stores[index];

                      return GestureDetector(
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>   RestrauntScreen(id: store['id']

                            )),
                          );
                        },
                        child: ClipRect(
                          clipBehavior: Clip.hardEdge,
                          child: Container(
                            margin: EdgeInsets.only(left: 12,right: 12),
                            width: screenWidth,
                            height: screenHeight*0.36,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(20))
                            ),
                            child: Stack(
                              children: [

                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: screenWidth,
                                      height: screenHeight*0.22 ,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),

                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(20),
                                            topLeft: Radius.circular(20),
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(20),
                                            topLeft: Radius.circular(20),
                                          ),
                                          child: CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            imageUrl: store['imageUrl'], // URL of the image
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
                                      padding: EdgeInsets.all(7),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(bottomRight: Radius.circular(20),bottomLeft: Radius.circular(20)),
                                        color: Colors.white, // Background color of the container
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.shade300.withOpacity(0.8), // Color of the shadow
                                            spreadRadius: 3, // Spread radius
                                            blurRadius: 4, // Blur radius
                                            offset: Offset(0, 3), // Offset of the shadow
                                          ),
                                        ],
                                        border: Border(
                                          left: BorderSide(
                                            color: Colors.grey.shade300, // Color of the left border
                                            width: 1, // Width of the left border
                                          ),
                                          bottom: BorderSide(
                                            color: Colors.grey.shade300, // Color of the bottom border
                                            width: 1, // Width of the bottom border
                                          ),
                                          right: BorderSide(
                                            color: Colors.grey.shade300, // Color of the right border
                                            width: 1, // Width of the right border
                                          ),
                                        ),
                                      ),

                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                width: screenWidth*0.75,
                                                child:  Text(store['name'],
                                                  maxLines: 1,
                                                  overflow: TextOverflow.clip,
                                                  style: TextStyle(
                                                      color: Colors.pink,
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 23
                                                  ),),

                                              ),
                                              Container(
                                                height: 30,
                                                width: 50,
                                                decoration: BoxDecoration(
                                                    color: Colors.pink,
                                                    borderRadius: BorderRadius.all(Radius.circular(10))
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Text(store['rating'],
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.w500
                                                      ),),
                                                    Icon(Icons.star,color: Colors.white,size: 18,)
                                                  ],
                                                ),
                                              )

                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  store['name'],
                                                  maxLines: 1,
                                                  overflow: TextOverflow.clip,
                                                  style: TextStyle(
                                                    color: Colors.black.withOpacity(0.8),

                                                  ),
                                                ),
                                              ),

                                              SizedBox(width: 5,),
                                              Container(
                                                width: 4, // Adjust width and height to change the size of the dot
                                                height: 4,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle, // Shape of the container
                                                  color: Colors.black87, // Color of the dot
                                                ),
                                              ),
                                              SizedBox(width: 5,),

                                              Expanded(
                                                child: Text(
                                                  store['address'],
                                                  maxLines: 1,
                                                  overflow: TextOverflow.clip,
                                                  style: TextStyle(
                                                    color: Colors.black.withOpacity(0.8),

                                                  ),
                                                ),
                                              ),





                                            ],
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(left: 7,right: 7,top: 4),
                                            child:
                                            DashedLine(
                                              width: screenWidth,
                                              height: 1,
                                              color: Colors.grey.shade300,
                                              strokeWidth: 1,
                                              dashLength: 4,
                                              dashSpace: 7,
                                            ),
                                          ),
                                          Text('Customization Available',
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.w500
                                            ),),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                Container(
                                  margin: EdgeInsets.only(bottom: 20),
                                  width: screenHeight*0.48,
                                  padding: EdgeInsets.only(top: 8,bottom: 8),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft:Radius.circular(20),bottomLeft: Radius.circular(10) ,bottomRight: Radius.circular(10)),
                                      color: Colors.pink.withOpacity(1)
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset('assets/clockwhite.png',height: 18,width: 18,),
                                      SizedBox(width: 4,),
                                      Text(store['deliveryTime'],
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500
                                        ),),
                                      SizedBox(width: 5,),
                                      Container(
                                        width: 7, // Adjust width and height to change the size of the dot
                                        height: 7,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle, // Shape of the container
                                          color: Colors.white, // Color of the dot
                                        ),
                                      ),
                                      SizedBox(width: 5,),

                                      Text(_formatDistance(store['distance']),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500
                                        ),),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            SizedBox(height: 15,),


            Visibility(
                visible: isLoading ,
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
      ),

    );
  }
}
