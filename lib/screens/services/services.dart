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
import 'package:perwork/screens/costumer/restrauntscreen.dart';
import 'package:perwork/screens/profilescreen.dart';
import 'package:perwork/screens/services/pestcontrol.dart';
import 'package:perwork/screens/services/petcare.dart';
import 'package:perwork/screens/services/repairs.dart';
import 'package:perwork/screens/services/smartphone.dart';
import 'package:perwork/widgets/phone.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../api/apis.dart';
import '../../utils/LocationService.dart';
import '../../widgets/dashedline.dart';
import '../../widgets/work/searchbar.dart';
import '../costumer/addwork.dart';
import 'GiftServices.dart';
import 'ProfessionalWidget.dart';
import 'cleaningwidget.dart';
import 'interiorDesigners.dart';



class Services extends StatefulWidget {
  const Services({Key? key}) : super(key: key);

  @override
  State<Services> createState() => _IntroMainState();
}

class _IntroMainState extends State<Services> {
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
    return FirebaseFirestore.instance.collection('makeup_services').get();
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
                                    searchSuggestions: ['Cake', 'Briyani','Restaurants','Bakery'],
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
            GiftServices(),
            ProfessionalWidget(),
            PestControlWidget(),
            Container(
              margin: EdgeInsets.only(left: 9),
              height: screenHeight * 0.13,
              child: FutureBuilder<QuerySnapshot>(
                future: _itemsData, // Assuming _itemsData returns a Future<QuerySnapshot>
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("Loading");
                  }

                  // Filter documents based on search term
                  final List<QueryDocumentSnapshot> filteredDocuments = snapshot.data!.docs.toList();

                  // Show only the first half of the documents
                  final halfIndex = (filteredDocuments.length / 2).ceil();
                  final firstHalf = filteredDocuments.sublist(0, halfIndex);

                  return ListView(
                    scrollDirection: Axis.horizontal,
                    children: firstHalf.map((DocumentSnapshot document) {
                      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                      final String firstWord = data['name'].split(' ').first;
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: Duration(milliseconds: 400),
                              pageBuilder: (_, __, ___) => IntroSearch(searchText: data['name'], filter: "restaurants"),
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
                            margin: EdgeInsets.only(right: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: screenHeight * 0.04,
                                  backgroundColor: Colors.transparent, // Set background color for the circle
                                  child: ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: data['image'], // URL of the image
                                      width: screenHeight * 0.08, // Ensure width and height match CircleAvatar diameter
                                      height: screenHeight * 0.08,
                                      fit: BoxFit.cover, // Fit the image within the CircleAvatar
                                      placeholder: (context, url) => Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          width: screenHeight * 0.08, // Ensure width and height match CircleAvatar diameter
                                          height: screenHeight * 0.08,
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
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: Duration(milliseconds: 400),
                              pageBuilder: (_, __, ___) => IntroSearch(searchText: data['name'], filter: "restaurants"),
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
                            margin: EdgeInsets.only(right: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: screenHeight * 0.04,
                                  backgroundColor: Colors.transparent, // Set background color for the circle
                                  child: ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: data['image'], // URL of the image
                                      width: screenHeight * 0.08, // Ensure width and height match CircleAvatar diameter
                                      height: screenHeight * 0.08,
                                      fit: BoxFit.cover, // Fit the image within the CircleAvatar
                                      placeholder: (context, url) => Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          width: screenHeight * 0.08, // Ensure width and height match CircleAvatar diameter
                                          height: screenHeight * 0.08,
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
            InteriorDesignerWidget(),
            Container(
              height: 500,
              child: ImageSelectorWidget(collectionName: 'smartphone_services',),
            ),
            SizedBox(height: 10,),

            Petcare(),
            SizedBox(height: 10,),

            SizedBox(height: 10,),

            CleaningWidget(),
            SizedBox(height: 10,),
            RepairsWidget(),
            SizedBox(height: 10,),

            Container(
              margin: EdgeInsets.only(left: 12),
              padding: EdgeInsets.only(bottom: 7),
              child: FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance.collection('service_cleaning').get(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Something went wrong'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No data found'));
                  }

                  final List<QueryDocumentSnapshot> documents = snapshot.data!.docs;

                  return SingleChildScrollView(
                    child: Column(
                      children: documents.map((DocumentSnapshot document) {
                        String docId = document.id;
                        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

                        return GestureDetector(

                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['title'],style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500
                              ),),
                              GestureDetector(

                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(12)),
                                  ),
                                  child: Container(
                                    margin: EdgeInsets.only(left: 8),
                                    height: 170,
                                    padding: EdgeInsets.only(top: 7, bottom: 7),
                                    child: FutureBuilder<QuerySnapshot>(
                                      future: FirebaseFirestore.instance.collection('service_cleaning').doc(docId).collection('lists').get(),
                                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> subSnapshot) {
                                        if (subSnapshot.hasError) {
                                          return Text('Something went wrong');
                                        }

                                        if (subSnapshot.connectionState == ConnectionState.waiting) {
                                          return Text("Loading");
                                        }

                                        final List<QueryDocumentSnapshot> filteredDocuments = subSnapshot.data!.docs;

                                        return ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: filteredDocuments.length,
                                          itemBuilder: (context, index) {
                                            DocumentSnapshot subDocument = filteredDocuments[index];
                                            Map<String, dynamic> subData = subDocument.data()! as Map<String, dynamic>;

                                            return GestureDetector(
                                              onTap: () {
                                                print("asdfasdf");
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => AddWork(companyName:subData['name'],)),
                                                );
                                                // Handle tap
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                                ),
                                                margin: EdgeInsets.only(right: 12),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                                  child: CachedNetworkImage(
                                                    fit: BoxFit.cover,
                                                    imageUrl: subData['image'], // URL of the image
                                                    width: 200,
                                                    height: 70,
                                                    placeholder: (context, url) => Shimmer.fromColors(
                                                      baseColor: Colors.grey[200]!,
                                                      highlightColor: Colors.grey[100]!,
                                                      child: Container(
                                                        width: 200,
                                                        height: 70,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),

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
