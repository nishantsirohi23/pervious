import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:perwork/screens/tasker/showwork.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:badges/badges.dart' as badges;
import 'package:perwork/screens/tasker/showworkdelivery.dart';
import 'package:perwork/screens/tasker/taskerhomescreen.dart';
import 'package:shimmer/shimmer.dart';

import '../../api/apis.dart';
import '../../onboding/components/custom_sign_in_dialog.dart';
import '../../try/chatlist.dart';
import '../../try/shownotifications.dart';
import '../../widgets/dashedline.dart';
import '../maps/trackitem.dart';
import '../tasker/ApplySuccessScreen.dart';
import '../work/workerprofile.dart';

class DriverScreenContent extends StatefulWidget {
  const DriverScreenContent({Key? key}) : super(key: key);

  @override
  State<DriverScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<DriverScreenContent> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  FilterType _selectedFilter = FilterType.none; // Define an enum for filter types
  double _selectedDistance = 10; // Default distance value
  Gender _selectedGender = Gender.any; // Default gender value
  double drivingDistance = 0.0;
  String sdrivingDistance = "0.0";
  bool isLoading = false;
  String _latitude = '';
  String _longitude = '';
  String _filterType = 'food'; // Default filter typeFirebaseAuth auth = FirebaseAuth.instance;

  late LatLng _currentPosition = LatLng(0.0, 0.0); // Initializing to default position
  @override
  void initState() {
    super.initState();
    getdate();
    fetchDistance();
  }
  Future<void> fetchDistance() async {

    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      return Future.error('Location services are disabled.');
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Request location permissions
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle accordingly.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Get the current location
    Position currentPosition = await Geolocator.getCurrentPosition();
    double sourcelat = currentPosition.latitude;
    double sourcelong = currentPosition.longitude;
    APIs.updatelatlongprof(sourcelat,sourcelong);






  }
  int nnotibooking = 0;
  int nnotiwork = 0;
  int nmessage = 0;
  int count = 0;
  void getdate() {
    FirebaseFirestore.instance.collection('users').doc(APIs.me.id).snapshots().listen((DocumentSnapshot snapshot) {
      setState(() {
        nnotibooking = snapshot['nnotibooking'] ?? 0;
        nnotiwork = snapshot['nnotiwork'] ?? 0;
        nmessage = snapshot['nmessage'] ?? 0;

      });
    });
  }
  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    User user = auth.currentUser!;
    // Stream of data from Firestore
    final Stream<QuerySnapshot> _usersStream =
    FirebaseFirestore.instance.collection('work').snapshots();
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

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
    return Scaffold(

      body: Stack(
        children: [
          Container(
            height: screenHeight * 0.14,
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/backappbar1.png"),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
            child: Container(
              margin: EdgeInsets.only(left: 20, right: 20, top: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${getGreeting()}!",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: screenHeight*0.02

                            ),
                          ),
                          Text(
                            APIs.me.name,
                            style: TextStyle(color: CupertinoColors.white, fontSize:  screenHeight*0.021, fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            width: 40, // Adjust according to your needs
                            height: 40, // Adjust according to your needs
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.0, // Adjust border width if needed
                              ),
                            ),
                            child: Center(
                              child: GestureDetector(
                                onTap: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ChatList()),
                                  );
                                },child: Center(
                                  child: badges.Badge(
                                    showBadge: ((nmessage)!=0) ? true : false,
                                    position: badges.BadgePosition.topEnd(top: -13, end: -15),
                                    badgeContent: Text((nmessage).toString(),style: TextStyle(color: Colors.white),),
                                    child: FaIcon(
                                      FontAwesomeIcons.message, // Adjust icon as needed
                                      size: 20, // Adjust icon size as needed
                                      color: Colors.white, // Adjust icon color as needed
                                    ),
                                  )
                              ),
                              ),
                            ),
                          ),

                          SizedBox(width: 13),
                          GestureDetector(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => WorkerProfileScreen()),
                              );
                            },
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(
                                APIs.me.image,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          ),

          Container(
              margin: EdgeInsets.only(top: screenHeight*0.15),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _filterType = 'food';
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor: _filterType == 'food'
                              ? MaterialStateProperty.all(Colors.blue)
                              : null,
                        ),
                        child: Text('food', style: TextStyle(color: _filterType == 'food' ? Colors.white : null)),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _filterType = 'work';
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor: _filterType == 'work'
                              ? MaterialStateProperty.all(Colors.blue)
                              : null,
                        ),
                        child: Text('Work', style: TextStyle(color: _filterType == 'work' ? Colors.white : null)),
                      ),

                    ],
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: _buildContentForFilterType(),
                  ),


                ],
              )
          ),
          Visibility(
              visible: isLoading,
              child: Container(
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
  Future<bool> _checkIfUserApplied(DocumentReference workRef) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User user = auth.currentUser!;
    var workersSnapshot = await workRef.collection('workers').get();
    for (var workerDoc in workersSnapshot.docs) {
      if (workerDoc['workerID'] == user.uid) {
        return true; // User has already applied
      }
    }

    return false; // User has not applied
  }

  Widget _buildContentForFilterType() {
    if (_filterType == 'work') {
      return _buildWorkContainer();
    } else {
      return _buildFoodContainer();
    }
  }

  Widget _buildFoodContainer() {
    return Container(
      // Your content for hours filter type
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Container();
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.86,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withOpacity(0),
                  child: Center(
                    child: Lottie.asset("assets/lottie/loading.json"),
                  ),
                ),
              ),
            );
          }
          // Filter documents based on search term
          final List<QueryDocumentSnapshot> filteredDocuments =
          snapshot.data!.docs.toList();

          // Filtered list of documents where userId matches user.uid
          final List<QueryDocumentSnapshot<Map<String, dynamic>>> userBookings = filteredDocuments
              .cast<QueryDocumentSnapshot<Map<String, dynamic>>>()
              .where((doc) => doc['status']!="completed")
              .toList();
          // Sort the user bookings based on the 'createdAt' field
          userBookings.sort((a, b) {
            // Convert 'createdAt' field from string to integer
            int aCreatedAt = int.parse(a['createdAt']);
            int bCreatedAt = int.parse(b['createdAt']);
            // Compare the integers to sort in descending order
            return bCreatedAt.compareTo(aCreatedAt);
          });

          if (userBookings.isEmpty) {
            return Center(
              child: Container(


                alignment: Alignment.center,
                child: Column(
                  children: [
                    Lottie.asset('assets/lottie/empty.json'),

                  ],
                ),
              ),
            );
          }




          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(top: 10),
                  scrollDirection: Axis.vertical,
                  itemCount: userBookings.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot document = userBookings[index];
                    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                    if (data.containsKey('storename')) {
                      if(data['status']=='waiting'){
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TrackItem(
                                  destlat: data['destlong'],
                                  destlong: data['destlat'],
                                  sourcelat: data['sourcelat'],
                                  sourcelong: data['sourcelong'],
                                  orderId: document.id,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(3),
                            margin: EdgeInsets.only(left: 15, right: 10, top: 5, bottom: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(0, 3),
                                ),
                              ],
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Iterate over the items subcollection
                                Container(
                                  height: 60,
                                  child: Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(10)),
                                        ),
                                        margin: EdgeInsets.only(right: 12),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.all(Radius.circular(10)),
                                          child: CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            imageUrl: "https://firebasestorage.googleapis.com/v0/b/perwork.appspot.com/o/categories%2FUntitled%20design-3.png?alt=media&token=e6cec73f-a9ce-4f75-a329-0c07711d85f3", // URL of the image
                                            width: 50,
                                            height: 50,
                                            placeholder: (context, url) => Shimmer.fromColors(
                                              baseColor: Colors.grey[200]!,
                                              highlightColor: Colors.grey[100]!,
                                              child: Container(
                                                width: 84,
                                                height: 60,
                                                color: Colors.white,
                                              ),
                                            ),
                                            errorWidget: (context, url, error) => Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                      Expanded(child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("Item Delivery",maxLines: 2,overflow: TextOverflow.clip,style: TextStyle(fontSize: 17),),

                                        ],
                                      ),),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.asset('assets/rupee.png',height: 25,width: 25,),
                                          Text("₹"+data['orderamount'].toString())
                                        ],
                                      ),
                                      SizedBox(width: 20,)
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 20,right: 20),
                                  child:  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: (){
                                          APIs.acceptfoodorder(document.id);
                                        },
                                        child: Container(
                                          height: 44,
                                          width: 150,
                                          decoration: BoxDecoration(
                                              color: Colors.pink,
                                              border: Border.all(color: Colors.grey.shade300),
                                              borderRadius: BorderRadius.circular(15)
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text("+ Accept",style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 19,
                                                  fontWeight: FontWeight.w500
                                              ),)
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 44,
                                        width: 150,
                                        decoration: BoxDecoration(
                                            color: Colors.pink,
                                            border: Border.all(color: Colors.grey.shade300),
                                            borderRadius: BorderRadius.circular(15)
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(data['distance'].toString()+" kms",style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 19,
                                                fontWeight: FontWeight.w500
                                            ),)
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10,)
                              ],
                            ),
                          ),
                        );
                      }
                      else{
                        return SizedBox();
                      }

                    }
                    else{
                      List<Map<String, dynamic>> dishesData = (data['dishes'] as List<dynamic>).cast<Map<String, dynamic>>();

                      if(data['status']=="preparing"){
                        return GestureDetector(
                          onTap: (){

                          },
                          child: Container(
                            margin: EdgeInsets.only(left: 15, right: 10, top: 5, bottom: 5), // Adjust margins here
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(0, 3),
                                ),
                              ],
                              color: Colors.white,
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 60,
                                  child: Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(10)),
                                        ),
                                        margin: EdgeInsets.only(right: 12),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.all(Radius.circular(10)),
                                          child: CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            imageUrl: data['restimage'], // URL of the image
                                            width: 60,
                                            height: 60,
                                            placeholder: (context, url) => Shimmer.fromColors(
                                              baseColor: Colors.grey[200]!,
                                              highlightColor: Colors.grey[100]!,
                                              child: Container(
                                                width: 84,
                                                height: 60,
                                                color: Colors.white,
                                              ),
                                            ),
                                            errorWidget: (context, url, error) => Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                      Expanded(child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(data['restname'],maxLines: 1,overflow: TextOverflow.clip,style: TextStyle(fontSize: 17),),
                                          Text(data['restaddress'],maxLines: 1,overflow: TextOverflow.clip,style: TextStyle(fontSize: 16),)
                                        ],
                                      ),),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.asset('assets/rupee.png',height: 25,width: 25,),
                                          Text("₹"+data['orderamount'].toString())
                                        ],
                                      ),
                                      SizedBox(width: 20,)
                                    ],
                                  ),
                                ),
                                SizedBox(height: 6,),
                                DashedLine(height: 1, color: Colors.grey),
                                Container(
                                  padding: EdgeInsets.only(top: 4),
                                  height:dishesData.length*35,
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: dishesData.length,
                                    itemBuilder: (context, index) {
                                      final dish = dishesData[index];
                                      return Container(
                                        child: Row(
                                          children: [
                                            Image.network(
                                              dish['image'],
                                              width: 30,
                                              height: 30,
                                              fit: BoxFit.cover,
                                            ),
                                            SizedBox(width: 5),
                                            Text(dish['quantity'].toString()+" x "),
                                            Expanded(
                                              child: Text(
                                                dish['name'],
                                                maxLines: 1,
                                                overflow: TextOverflow.clip,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 20,right: 20),
                                  child:  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: (){
                                          APIs.acceptfoodorder(data['id']);
                                        },
                                        child: Container(
                                          height: 44,
                                          width: 150,
                                          decoration: BoxDecoration(
                                              color: Colors.pink,
                                              border: Border.all(color: Colors.grey.shade300),
                                              borderRadius: BorderRadius.circular(15)
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text("+ Accept",style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 19,
                                                  fontWeight: FontWeight.w500
                                              ),)
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 44,
                                        width: 150,
                                        decoration: BoxDecoration(
                                            color: Colors.pink,
                                            border: Border.all(color: Colors.grey.shade300),
                                            borderRadius: BorderRadius.circular(15)
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(data['distance'].toString()+" kms",style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 19,
                                                fontWeight: FontWeight.w500
                                            ),)
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10,)
                              ],
                            ),

                          ),
                        );
                      }
                      else{
                        return SizedBox();
                      };
                    }

                  },
                ),
              ),
            ],
          );





        },
      )
      ,
    );
  }

  Widget _buildWorkContainer() {
    return  Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('work').orderBy('created_at', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {

              return Container(
                height: 400,
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
              );
            }
            else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
              // No data available
              return Center(
                child: Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.1),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Lottie.asset('assets/lottie/empty.json'),
                    ],
                  ),
                ),
              ); // Show an empty container or any other UI you prefer
            } else if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Container(
                  margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Lottie.asset('assets/lottie/empty.json'),
                      Text('No data available', style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
              );
            }else {
              var workDocs = snapshot.data!.docs;
              // Display your actual UI using the data

              return Container(
                padding: EdgeInsets.all(0),
                child: ListView.builder(
                  padding: EdgeInsets.all(0),
                  itemCount: workDocs.length,
                  itemBuilder: (context, index) {
                    var workDoc = workDocs[index];
                    String profession = workDoc['prof'];
                    String capitalizedProfession = profession.isNotEmpty
                        ? '${profession[0].toUpperCase()}${profession.substring(1)}'
                        : '';
                    String isnego = "Fixed";
                    if(workDoc['negotiable']){
                      isnego = "Negotiable";
                    }
                    count = workDocs.length;
                    if(workDoc['status']=="process" || workDoc['status']=="posted"){
                      return FutureBuilder<bool>(
                        future: _checkIfUserApplied(workDoc.reference),
                        builder: (context, snapshot) {
                          print(snapshot);
                          if (snapshot.connectionState == ConnectionState.waiting) {

                            return Container();
                          }
                          if (snapshot.hasError) {
                            isLoading = false;

                            return Text('Error: ${snapshot.error}');
                          }
                          if(snapshot.data==null){
                            print("snap null");
                          }
                          if (snapshot.data == true) {
                            isLoading = false;

                            // User has already applied, so don't show this work
                            return SizedBox.shrink();
                          } else {
                            count = 1;
                            isLoading = false;
                            print(snapshot.data);
                            print("asdf");
                            if (snapshot.data == null) {
                              print("null");
                              return Text('Empty',style: TextStyle(color: Colors.black),); // Show text indicating empty data
                            }
                            else{
                              return GestureDetector(
                                onTap: () {

                                  if(workDoc['category']=="pickup"){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ShowWorkDelivery(workid: workDoc['id'])),
                                    );
                                  }
                                  else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) =>
                                          ShowWork(workid: workDoc['id'])),
                                    );
                                  }
                                },
                                child: Container(
                                  margin: EdgeInsets.only(left: 15,right: 10,top: 5,bottom: 5),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 5,
                                        blurRadius: 7,
                                        offset: Offset(0, 3), // changes position of shadow
                                      ),
                                    ],
                                    color: Colors.white,
                                  ),
                                  child: Center(
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              CircleAvatar(
                                                radius: 30, // Adjust the radius as needed
                                                backgroundImage: NetworkImage("https://cdn.dribbble.com/userupload/13080831/file/original-a89cc68c06feabb57b332790a356435b.png?resize=1504x1127"), // Replace 'your_image.jpg' with your image asset path
                                              ),
                                              SizedBox(width: MediaQuery.of(context).size.width*0.02,),
                                              Column(
                                                children: [
                                                  SizedBox(
                                                    width: MediaQuery.of(context).size.width*0.7,
                                                    child: Text(
                                                      workDoc['name'],
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 19
                                                      ),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.clip,
                                                      textAlign: TextAlign.start,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                          Visibility(
                                            visible: workDoc['fromaddress']!="",
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(Icons.location_on_outlined),
                                                    Flexible( // Wrap Text with Flexible
                                                      child: Text(
                                                        workDoc['fromaddress'],
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis, // Handle overflow by showing ellipsis
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),),

                                          Visibility(
                                            visible: workDoc['amount']!=0,
                                            child: Row(
                                              children: [
                                                Image.asset("assets/rupee.png",height: 30,width: 30,),
                                                Text(workDoc['amount'].toString()),
                                              ],
                                            ),),
                                          Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(right: 8.0),
                                                child: Container(
                                                  height: MediaQuery.of(context).size.height*0.038,
                                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue,
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Center(
                                                    child: Row(
                                                      children: [

                                                        Text(
                                                          workDoc['priority'],
                                                          style: TextStyle(fontSize: 15, color: Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(right: 8.0),
                                                child: Container(
                                                  height: MediaQuery.of(context).size.height*0.038,
                                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue,
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      isnego,
                                                      style: TextStyle(fontSize: 15, color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                        ],
                                      )
                                  ),
                                ),
                              );
                            }
                            // User has not applied, show this work

                          }
                        },
                      );
                    }
                    return null;
                  },
                ),
              );
            }



          },
        )
    );
  }







  @override
  void dispose() {
    _amountController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

// Enum for filter types
enum FilterType {
  none,
  urgent,
  high,
  normal,
}

// Enum for gender options
enum Gender {
  any,
  male,
  female,
}

