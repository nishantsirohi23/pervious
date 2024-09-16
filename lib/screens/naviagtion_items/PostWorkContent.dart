import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:perwork/screens/costumer/addwork.dart';
import 'package:perwork/screens/costumer/pickmultilocation.dart';
import 'package:perwork/screens/naviagtion_items/HomeScreenContent.dart';
import 'package:perwork/screens/profilescreen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:slide_to_act/slide_to_act.dart';

import '../../api/apis.dart';
import '../../models/work.dart';
import '../../taskerdash/workapplications.dart';
import '../../try/chatlist.dart';
import '../../try/shownotifications.dart';
import '../../utils/LocationService.dart';
import '../costumer/ViewWorkContent.dart';
import '../costumer/buyitems.dart';
import '../costumer/pickup.dart';
import '../costumer/ride/taxi.dart';
import '../maps/PickLocationScreen.dart';
import '../userbooking.dart';
import 'package:badges/badges.dart' as badges;


class AddUser extends StatefulWidget {
  @override
  _AddUserState createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController profcontroller = TextEditingController();

  List<File> selectedFiles = [];

  late DateTime selectedDate = DateTime.now();
  late TimeOfDay selectedTime = TimeOfDay.now();
  bool isNegotiable = false;
  String selectedPriority = 'Normal';
  static FirebaseAuth auth = FirebaseAuth.instance;
  static User get user => auth.currentUser!;
  double _latitude = 0.0;
  double _longitude = 0.0;
  late LocationService _locationService;
  int nnotibooking = 0;
  int nnotiwork = 0;
  int nmessage = 0;
  late Future<QuerySnapshot> _profData;
  Future<QuerySnapshot> getProfs() async {
    isLoading = false;
    return FirebaseFirestore.instance.collection('proflist').get();
  }
  late Future<QuerySnapshot> _rideData;
  Future<QuerySnapshot> getRides() async {
    isLoading = false;
    return FirebaseFirestore.instance.collection('rideitem').get();
  }
  late Future<QuerySnapshot> _deliveryitem;
  Future<QuerySnapshot> getdelivery() async {
    isLoading = false;
    return FirebaseFirestore.instance.collection('deliveryitem').get();
  }
  late Future<QuerySnapshot> _buyitem;
  Future<QuerySnapshot> getBuy() async {
    isLoading = false;
    return FirebaseFirestore.instance.collection('buy').get();
  }
  void getdate() {
    FirebaseFirestore.instance.collection('users').doc(APIs.me.id).snapshots().listen((DocumentSnapshot snapshot) {
      setState(() {
        nnotibooking = snapshot['nnotibooking'] ?? 0;
        nnotiwork = snapshot['nnotiwork'] ?? 0;
        nmessage = snapshot['nmessage'] ?? 0;

      });
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

  bool isLoading = false;
  bool filesUploadedSuccessfully = false;
  bool isUploading = false;
  List<Map<String, String>> fileData = [];
  String _paymentOption = '';
  late Razorpay _razorpay;
  bool _isPaymentInProgress = false;
  PickResult? selectedPlace;
  void _loadUserData() async {
    await APIs.getSelfInfo();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getdate();
    _profData = getProfs();
    _rideData = getRides();
    _buyitem =getBuy();
    _deliveryitem= getdelivery();
    _locationService = LocationService();
    _getCurrentLocation();
    // Fetch user information when the widget is first created
    _loadUserData();

  }

  @override
  void dispose() {
    super.dispose();
  }










  String _receivedText = 'Add Location';
  double longitude = 0.0;
  double latitude = 0.0;
  String address = "";
  double fromLatitude= 0.0;
  double fromLongitude = 0.0;
  String receivedFrom = "";
  double toLatitude = 0.0;
  double toLongitude = 0.0;
  String receivedTo = "";



  void _updateReceivedText(double longitude, double latitude, String address) {
    setState(() {
      this.longitude = longitude;
      this.latitude = latitude;
      this.address = address;
      _receivedText = 'Location Picked';
    });
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final Stream<QuerySnapshot> _usersStream =
    FirebaseFirestore.instance.collection('features').snapshots();
    return Scaffold(
        resizeToAvoidBottomInset: false,

        body: Stack(
          children: [
            Container(
              height: screenHeight * 0.3,
              decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/backappbar1.png"),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35))),
              child: Container(
                margin: EdgeInsets.only(left: 20,right: 20),
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: screenHeight*0.12),
                      child: Row(
                        children: [
                          Container(
                            width: screenWidth*0.5,
                            child: Text("Post Your Task, Watch the Magic!",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenHeight*0.03,
                                  fontWeight: FontWeight.w500
                              ),),
                          ),
                          Transform.scale(
                              scale: 1.1, // Adjust the scale factor as needed to zoom out
                              child:                         Image.asset("assets/witch.png",height: screenHeight*0.14,width: screenWidth*0.39,)

                          )

                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 40),
                      child: Row(
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
                              Container(
                                width: screenWidth*0.46,
                                child: Text(
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                  APIs.me.name,
                                  style: TextStyle(color: CupertinoColors.white, fontSize:  screenHeight*0.021),
                                ),
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
                                    },
                                    child: Center(
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
                              SizedBox(width: 13,),
                              GestureDetector(
                                onTap: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ShowNotifications()),
                                  );
                                },
                                child: Container(
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
                                      child: badges.Badge(
                                        showBadge: ((nnotiwork+nnotibooking)!=0) ? true : false,
                                        position: badges.BadgePosition.topEnd(top: -13, end: -15),
                                        badgeContent: Text((nnotiwork+nnotibooking).toString(),style: TextStyle(color: Colors.white),),
                                        child: FaIcon(
                                          FontAwesomeIcons.bell, // Adjust icon as needed
                                          size: 20, // Adjust icon size as needed
                                          color: Colors.white, // Adjust icon color as needed
                                        ),
                                      )
                                  ),
                                ),
                              ),
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
                                          width: 88, // Double the radius to fit the CircleAvatar
                                          height: 88, // Double the radius to fit the CircleAvatar
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
            ),
            Container(
              margin: EdgeInsets.only(top: screenHeight*0.31),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight*0.02,),







                  ],
                ),

              ),
            ),
            Visibility(
                visible: isLoading || isUploading,
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
        )


    );
  }


}
