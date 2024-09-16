import 'dart:async';
import 'dart:ffi';
import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:perwork/screens/maps/PickLocationScreen.dart';
import 'package:perwork/screens/userbooking.dart';
import 'package:perwork/widgets/BookingSuccess.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:google_maps_flutter_platform_interface/src/types/marker.dart' as GoogleMarker;
import 'package:badges/badges.dart' as badges;
import 'package:shimmer/shimmer.dart';
import '../../../api/apis.dart';
import '../../../models/booking.dart';
import '../../../try/chatlist.dart';
import '../../../try/my_global.dart';
import '../../../try/pigeon.dart';
import '../../../try/shownotifications.dart';
import '../../../utils/LocationService.dart';
import '../../../utils/dashed_line.dart';
import '../../../utils/showgooglemap.dart';
import '../../maps/directionScreen.dart';
import '../../profilescreen.dart';
import '../../showall/showallreview.dart';
import 'dart:io' show Platform;


import '../../work/taskerWork.dart';





class viewProfile extends StatefulWidget {

  final String profid;

  const viewProfile({Key? key, required this.profid}) : super(key: key);

  @override
  State<viewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<viewProfile> {
  late DocumentSnapshot<Map<String, dynamic>> _profSnapshot;
  bool isLoading = true;
  int lenlist = 0;
  String reviewlist = "0";
  late DateTime selectedDate = DateTime.now();
  late DateTime toselectedDate = DateTime.now();
  late TimeOfDay selectedTime = TimeOfDay.now();
  late TimeOfDay toselectedTime = TimeOfDay.now();
  late TimeOfDay fromselectedTime = TimeOfDay.now();
  PickResult? selectedPlace;
  DateTime fromdate = DateTime.now();
  DateTime todate = DateTime.now();



  void _loadUserData() async {
    await APIs.getSelfInfo();
    setState(() {
      isLoading = false;
    });
  }
  String _receivedText = 'Add Work Location';
  double longitude = 0.0;
  double latitude = 0.0;
  String address = "";
  double _latitude = 0.0;
  double _longitude = 0.0;
  late LocationService _locationService;
  int nnotibooking = 0;
  int nnotiwork = 0;
  int nmessage = 0;
  bool hidebox = true;
  final Completer<GoogleMapController> _controller = Completer();
  final Completer<GoogleMapController> _controller1 = Completer();


  void getdate() async{
    final DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance.collection('users').doc(APIs.me.id).get();
    setState(() {
      nnotibooking = profileSnapshot['nnotibooking'];
      nnotiwork = profileSnapshot['nnotiwork'];
      nmessage = profileSnapshot['nmessage'] ?? 0;

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
  void initState() {
    super.initState();
    getdate();
    workFuture = FirebaseFirestore.instance.collection('prof').doc(widget.profid).get();
    _fetchProfDetails();
    _loadUserData();
    _locationService = LocationService();
    _getCurrentLocation();
  }


  Future<void> _fetchProfDetails() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('prof').doc(widget.profid).get();
      setState(() {
        _profSnapshot = snapshot;
        isLoading = false; // Set isLoading to false once the data is fetched
      });
    } catch (e) {
      print("Error fetching professional details: $e");
      setState(() {
        isLoading = false; // Set isLoading to false in case of an error
      });
    }
  }
  late Future<DocumentSnapshot<Map<String, dynamic>>> workFuture;


  int selectedContainer = 1;





  @override
  Widget build(BuildContext context) {

    final  apiKey = Globals.apiKey;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;



    return Scaffold(
      resizeToAvoidBottomInset: false,

      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: workFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Lottie.asset('assets/lottie/loading.json');
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return Text('Work not found');
          }

          // Work details
          Map<String, dynamic> workData = snapshot.data!.data()!;
          var listport = workData.containsKey('portfolio') ? workData['portfolio'] as List<dynamic> : null;
          double screenWidth = MediaQuery.of(context).size.width;
          double screenHeight = MediaQuery.of(context).size.height;
          double? pricePerHour = workData['price_per_hour']; // Assuming price_per_hour is of type double
          String pricePerHourString = pricePerHour != null ? pricePerHour.toString() : "";
          var listspecs = workData['specialities'] as List<dynamic>;
          reviewlist = workData['totalrating'];
          bool reviewvisi = true;
          bool portvisi = true;

          if (listport == null || listport.isEmpty) {
            lenlist = 0;
            portvisi = false;
          } else {
            lenlist = listport.length;
          }

          if (reviewlist == "0") {
            reviewvisi = false;
          }





          return Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: screenHeight*0.14,

                    decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/backappbar1.png"),
                          fit: BoxFit.cover,


                        ),
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),

                    child: Container(
                      margin: EdgeInsets.only(left: 20,right: 20,top: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${getGreeting()}!",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16
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
                                          print(_longitude);
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
                                  SizedBox(width: 13,),

                                  GestureDetector(
                                    onTap: (){
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ProfileScreen()),
                                      );
                                    },
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        isLoading ? 'https://cdn.dribbble.com/userupload/12569823/file/original-36e7a80c78bcefa16371969c139e81ea.jpg?resize=1504x1128' : APIs.me.image,
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
                      height: screenHeight*0.75,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(top: 10,left: 15),
                        child: _profSnapshot != null
                            ? Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.only(left: 10),
                                        height: MediaQuery.of(context).size.height*0.06,
                                        width: MediaQuery.of(context).size.height*0.06,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey.shade300,

                                            ),
                                            borderRadius: const BorderRadius.all(Radius.circular(25))),
                                        child: const Center(child: Icon(Icons.arrow_back_ios)),
                                      ),
                                    ),
                                    SizedBox(width: MediaQuery.of(context).size.width*0.05),
                                    ClipRRect(
                                      borderRadius: BorderRadius.all(Radius.circular(100)),
                                      child: CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        imageUrl: workData?['profile_image_url'] ?? '', // URL of the image
                                        width: MediaQuery.of(context).size.width*0.2, // Double the radius to fit the CircleAvatar
                                        height: MediaQuery.of(context).size.width*0.2, // Double the radius to fit the CircleAvatar
                                        placeholder: (context, url) => Shimmer.fromColors(
                                          baseColor: Colors.grey[300]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Container(
                                            width: MediaQuery.of(context).size.width*0.2, // Double the radius to fit the CircleAvatar
                                            height: MediaQuery.of(context).size.width*0.2, // Double the radius to fit the CircleAvatar
                                            color: Colors.white,
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => Icon(Icons.error),
                                      ),
                                    ),

                                    SizedBox(width: MediaQuery.of(context).size.width*0.05),

                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          workData?['name'],
                                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 23),
                                        ),
                                        Text(
                                          workData?['username'],
                                          style: TextStyle(color: Colors.black.withOpacity(0.5), fontWeight: FontWeight.w400, fontSize: 20),
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.only(left: 10,right: 10),
                                              decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                                  border: Border.all(color: Colors.pink,width: 1)
                                              ),
                                              child: Text(workData?['experience'],
                                                style: TextStyle(
                                                    color: Colors.pink,
                                                    fontSize: 19
                                                ),),
                                            ),
                                            SizedBox(width: 5),
                                            Image.asset("assets/reward.png",height: 30,width: 30,),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),


                                Text(
                                  "Biography",
                                  style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
                                ),
                                SizedBox(height: 7),
                                Container(
                                  child: Text(
                                    workData?['biography'],
                                    textAlign: TextAlign.left,
                                    maxLines: 4,
                                    overflow: TextOverflow.clip, // or TextOverflow.ellipsis or TextOverflow.clip
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Specialities",
                                  style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
                                ),
                                SizedBox(height: 7),
                                Container(
                                  height: 28,
                                  width: screenWidth,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: listspecs.map((spec) {
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 10),
                                          child: Container(
                                            padding: EdgeInsets.only(left: 7,right: 7,top: 3,bottom: 3),
                                            decoration: BoxDecoration(
                                              color: Colors.blue,
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                            child: Center(
                                              child: Text(
                                                spec,
                                                style: TextStyle(fontSize: 16, color: Colors.white),
                                              ),
                                            ),

                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Visibility(
                                  visible: reviewvisi,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Reviews",
                                            style: TextStyle(color: Colors.black, fontSize: 18,fontWeight: FontWeight.w400),
                                          ),
                                          GestureDetector(
                                              onTap: (){
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => ShowAllReview(profid: widget.profid)),
                                                );
                                              },
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "Show All(",
                                                    style: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 17, fontWeight: FontWeight.w400),
                                                  ),
                                                  Text(
                                                    reviewlist.toString()+")",
                                                    style: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 16, fontWeight: FontWeight.w400),
                                                  )
                                                ],
                                              )
                                          )
                                        ],
                                      ),
                                      StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance.collection('prof').doc(widget.profid).collection('reviews').snapshots(),
                                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> playerSnapshot) {
                                          if (playerSnapshot.hasError) {
                                            return Text('Something went wrong');
                                          }

                                          if (playerSnapshot.connectionState == ConnectionState.waiting) {
                                            return Text("Loading");
                                          }

                                          List<DocumentSnapshot> playerDocs = playerSnapshot.data!.docs;


                                          return SizedBox(
                                            height: MediaQuery.of(context).size.height*0.19, // Set height as needed
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: playerDocs.length,
                                              itemBuilder: (context, index) {
                                                Map<String, dynamic> playerData = playerDocs[index].data() as Map<String, dynamic>;
                                                String userId = playerData['userId'];
                                                // Adjust the UI according to your requirements
                                                return Container(
                                                  width: MediaQuery.of(context).size.width*0.68,
                                                  margin: EdgeInsets.only(left: 0,top: 8,right: 8,bottom: 8),

                                                  padding: EdgeInsets.all(8.0),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                                                    borderRadius: BorderRadius.circular(30.0),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        child: Column(
                                                          children: [
                                                            StreamBuilder<DocumentSnapshot>(
                                                              stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
                                                              builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                                                                if (userSnapshot.hasError) {
                                                                  return Text('Something went wrong');
                                                                }

                                                                if (userSnapshot.connectionState == ConnectionState.waiting) {
                                                                  return CircularProgressIndicator(); // Or any other loading indicator
                                                                }

                                                                Map<String, dynamic> userData = userSnapshot.data!.data() as Map<String, dynamic>;
                                                                String imageUrl = userData['image'];
                                                                String name = userData['name'];

                                                                return Container(
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          Container(
                                                                            width: MediaQuery.of(context).size.height*0.06,
                                                                            height: MediaQuery.of(context).size.height*0.06,
                                                                            decoration: BoxDecoration(
                                                                              color: const Color(0xff7c94b6),
                                                                              image: DecorationImage(
                                                                                image: NetworkImage(imageUrl),
                                                                                fit: BoxFit.cover,
                                                                              ),
                                                                              border: Border.all(
                                                                                color: Colors.white,
                                                                                width: 2.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.all(Radius.circular(50.0)),
                                                                            ),
                                                                          ),
                                                                          SizedBox(width: screenWidth*0.03),
                                                                          Column(
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              Container(
                                                                                width: screenWidth*0.27,
                                                                                child: Text(
                                                                                  name,
                                                                                  maxLines: 2,
                                                                                  style: TextStyle(
                                                                                    fontWeight: FontWeight.w500,
                                                                                    fontSize: screenWidth*0.04,
                                                                                    overflow: TextOverflow.clip, // or TextOverflow.ellipsis, etc.
                                                                                  ),
                                                                                ),
                                                                              ),

                                                                              Text(
                                                                                DateFormat('dd/MM/yyyy').format(playerData['date'].toDate()),
                                                                                style: TextStyle(fontWeight: FontWeight.w300, fontSize: screenWidth*0.035, color: Colors.grey.shade500),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          SizedBox(width: 15),
                                                                          Container(
                                                                            height: screenHeight*0.035,
                                                                            width: screenWidth*0.13,
                                                                            decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.all(Radius.circular(20))),
                                                                            child: Row(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              children: [
                                                                                Image.asset("assets/star.png",height: screenHeight*0.029,width: screenHeight*0.029,),
                                                                                Text(
                                                                                  playerData['star'].toString(),
                                                                                  style: TextStyle(color: Colors.deepOrange),
                                                                                )
                                                                              ],
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                      SizedBox(height: 5),
                                                                      Text(
                                                                        playerData['subject'],
                                                                        style: TextStyle(fontSize: screenWidth*0.034),
                                                                        maxLines: 3,
                                                                        overflow: TextOverflow.ellipsis,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                    visible: portvisi,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Portfolio",
                                              style: TextStyle(color: Colors.black, fontSize: 18, ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "Show All(",
                                                  style: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 17, fontWeight: FontWeight.w400),
                                                ),
                                                Text(
                                                  lenlist.toString()+")",
                                                  style: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 16, fontWeight: FontWeight.w400),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Container(
                                          height: MediaQuery.of(context).size.height*0.15,
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,

                                            child: Row(
                                              children: listport != null
                                                  ? listport.map((spec) {
                                                return Container(
                                                  margin: EdgeInsets.only(right: 10),
                                                  height: MediaQuery.of(context).size.height * 0.15,
                                                  width: MediaQuery.of(context).size.width * 0.4,
                                                  decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                        image: NetworkImage(spec), // Replace with your image asset
                                                        fit: BoxFit.cover, // Adjust BoxFit as needed (e.g., BoxFit.fill, BoxFit.fitWidth)
                                                      ),
                                                      borderRadius: BorderRadius.all(Radius.circular(10))),
                                                );
                                              }).toList()
                                                  : [], // Return an empty list if listport is null
                                            ),

                                          ),
                                        ),
                                      ],
                                    ))

                              ],
                            ),
                          ],
                        )
                            : Center(child: CircularProgressIndicator()),
                      )),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: MediaQuery.of(context).size.height*0.11,
                  child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                      child: Container(
                        height: 250,
                        decoration: BoxDecoration(
                          color: Color(0xFF81c9f7).withOpacity(0.3),
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30)),
                        ),
                        child: Container(
                          margin: EdgeInsets.only(left: 20, right: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 20),
                                  Text(
                                    "Price",
                                    style: TextStyle(color: Colors.grey.withOpacity(0.5), fontWeight: FontWeight.w400, fontSize: 19),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        pricePerHourString,
                                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w400, fontSize: 21),
                                      ),
                                      Text(
                                        "/hour",
                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 19),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              Visibility(visible: !isLoading,child: GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (BuildContext context) {
                                      return StatefulBuilder(
                                        builder: (BuildContext context, StateSetter setState) {
                                          return Container(
                                            height: MediaQuery.of(context).size.height*0.42,
                                            width: MediaQuery.of(context).size.width,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(topLeft: Radius.circular(100), topRight: Radius.circular(50)),
                                            ),
                                            child: AnimatedContainer(
                                              duration: Duration(milliseconds: 300),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
                                              ),
                                              child: Container(

                                                padding: EdgeInsets.only(top: 10,bottom: 20,left: 20,right: 20),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(top: 10),
                                                      width: 60,
                                                      height: 7,
                                                      decoration: BoxDecoration(
                                                          color: Colors.grey.shade200,
                                                          borderRadius: BorderRadius.circular(10)
                                                      ),
                                                    ),
                                                    SizedBox(height: 7,),
                                                    ClipRRect(
                                                      borderRadius: BorderRadius.all(Radius.circular(100)),
                                                      child: CachedNetworkImage(
                                                        fit: BoxFit.cover,
                                                        imageUrl: workData?['profile_image_url'] ?? '', // URL of the image
                                                        width: 60, // Double the radius to fit the CircleAvatar
                                                        height: 60, // Double the radius to fit the CircleAvatar
                                                        placeholder: (context, url) => Shimmer.fromColors(
                                                          baseColor: Colors.grey[300]!,
                                                          highlightColor: Colors.grey[100]!,
                                                          child: Container(
                                                            width: 60, // Double the radius to fit the CircleAvatar
                                                            height: 60, // Double the radius to fit the CircleAvatar
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        errorWidget: (context, url, error) => Icon(Icons.error),
                                                      ),
                                                    ),
                                                    SizedBox(height: 5,),
                                                    Text("Hire the Pro",
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 25,
                                                          fontWeight: FontWeight.w500
                                                      ),),
                                                    SizedBox(height: 10,),
                                                    GestureDetector(
                                                      onTap: !isLoading ?() {
                                                        // Define a function to create and handle the dialog
                                                        void showTimePickerDialog() {
                                                          TimeOfDay startTime = TimeOfDay(hour: 0, minute: 0);
                                                          TimeOfDay endTime = TimeOfDay(hour: 0, minute: 0);
                                                          int hours = 0;
                                                          DateTime newDatehour = DateTime.now();
                                                          bool _switchValue = false;

                                                          showDialog(
                                                            barrierDismissible: false,
                                                            context: context,
                                                            builder: (BuildContext context) {
                                                              return StatefulBuilder(
                                                                  builder: (BuildContext context, StateSetter setState) {


                                                                    return Dialog(
                                                                      backgroundColor: Colors.white,
                                                                      elevation: 0,
                                                                      child: Container(
                                                                        decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(20),
                                                                          color: Colors.white,
                                                                        ),
                                                                        padding: EdgeInsets.all(20),
                                                                        child: Column(
                                                                          mainAxisSize: MainAxisSize.min,
                                                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                          children: [
                                                                            //Date Text
                                                                            GestureDetector(
                                                                              onTap: () async {
                                                                                DateTime? pickedDate = await _selectDate(context);
                                                                                if (pickedDate != null) {
                                                                                  setState(() {
                                                                                    newDatehour = pickedDate;
                                                                                  });
                                                                                }
                                                                              }, child:
                                                                            Container(
                                                                              height: 60,
                                                                              width: screenWidth * 0.7,
                                                                              padding: EdgeInsets.only(left: 20, right: 10),
                                                                              decoration: BoxDecoration(
                                                                                  color: Colors.pink.withOpacity(0.7),
                                                                                  borderRadius: BorderRadius.all(Radius.circular(10))
                                                                              ),
                                                                              child: Row(
                                                                                children: [
                                                                                  Container(
                                                                                    height: 32,
                                                                                    width: 32,
                                                                                    decoration: BoxDecoration(
                                                                                        color: Colors.white,
                                                                                        borderRadius: BorderRadius.all(Radius.circular(10))
                                                                                    ),
                                                                                    child: Icon(Icons.timelapse,color: Colors.pink,),
                                                                                  ),
                                                                                  SizedBox(width: 13,),
                                                                                  Text('Date:',style: TextStyle(color: Colors.white),),
                                                                                  SizedBox(height: 15),
                                                                                  Text(
                                                                                    '${DateFormat('yyyy-MM-dd').format(newDatehour)}',
                                                                                    style: TextStyle(
                                                                                      color: newDatehour == null ? Colors.white : Colors.white, // Change text color based on whether date is selected or not
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),

                                                                            ),
                                                                            ),


                                                                            SizedBox(height: 5,),//Pick Date
                                                                            Stack(
                                                                              children: [
                                                                                Column(
                                                                                  children: [
                                                                                    GestureDetector(
                                                                                      onTap: () async {
                                                                                        DateTime? pickedTime = await _selectTime(context);
                                                                                        if (pickedTime != null) {
                                                                                          setState(() {
                                                                                            fromselectedTime = TimeOfDay.fromDateTime(pickedTime);
                                                                                          });
                                                                                        }
                                                                                      },
                                                                                      child: Container(
                                                                                        height: 60,
                                                                                        width: screenWidth * 0.7,
                                                                                        padding: EdgeInsets.only(left: 20, right: 10),
                                                                                        decoration: BoxDecoration(
                                                                                            color: Colors.pink.withOpacity(0.7),
                                                                                            borderRadius: BorderRadius.all(Radius.circular(10))
                                                                                        ),
                                                                                        child: Row(
                                                                                          children: [

                                                                                            Container(
                                                                                              height: 32,
                                                                                              width: 32,
                                                                                              decoration: BoxDecoration(
                                                                                                  color: Colors.white,
                                                                                                  borderRadius: BorderRadius.all(Radius.circular(10))
                                                                                              ),
                                                                                              child: Icon(Icons.arrow_upward_outlined,color: Colors.pink,),
                                                                                            ),
                                                                                            SizedBox(width: 13,),
                                                                                            Text('From Time:',style: TextStyle(color: Colors.white),),
                                                                                            SizedBox(width: 10),
                                                                                            if (fromselectedTime == null) // Show this only if time is not selected yet
                                                                                              Text('Select a time',style: TextStyle(color: Colors.white),),
                                                                                            if (fromselectedTime != null) // Show this if time is selected
                                                                                              Text('${fromselectedTime.format(context)}',style: TextStyle(color: Colors.white),),


                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    SizedBox(height: 25,),
                                                                                    GestureDetector(
                                                                                      onTap: () async {
                                                                                        DateTime? pickedTime = await _selectTime(context);
                                                                                        if (pickedTime != null) {
                                                                                          setState(() {
                                                                                            toselectedTime = TimeOfDay.fromDateTime(pickedTime);
                                                                                          });
                                                                                        }
                                                                                      },
                                                                                      child: Container(
                                                                                        height: 60,
                                                                                        width: screenWidth * 0.7,
                                                                                        padding: EdgeInsets.only(left: 20, right: 10),
                                                                                        decoration: BoxDecoration(
                                                                                          color: Colors.white.withOpacity(0.8),
                                                                                          borderRadius: BorderRadius.all(Radius.circular(10)),
                                                                                          border: Border.all(
                                                                                            color: Colors.grey.shade300,
                                                                                            width: 1.0,
                                                                                          ),
                                                                                        ),
                                                                                        child: Row(
                                                                                          children: [

                                                                                            Container(
                                                                                              height: 32,
                                                                                              width: 32,
                                                                                              decoration: BoxDecoration(
                                                                                                color: Colors.pink.withOpacity(0.3),
                                                                                                borderRadius: BorderRadius.all(Radius.circular(10)),

                                                                                              ),
                                                                                              child: Icon(Icons.arrow_upward_outlined,color: Colors.pink,),
                                                                                            ),
                                                                                            SizedBox(width: 13,),
                                                                                            Text('To Time:',style: TextStyle(color: Colors.black)),
                                                                                            SizedBox(width: 10),
                                                                                            if (toselectedTime == null) // Show this only if time is not selected yet
                                                                                              Text('Select a time',style: TextStyle(color: Colors.black)),
                                                                                            if (toselectedTime != null) // Show this if time is selected
                                                                                              Text('${toselectedTime.format(context)}',style: TextStyle(color: Colors.black)),


                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                                Container(
                                                                                  margin: EdgeInsets.only(left: 36,top: 40),
                                                                                  child: DashedLineVertical(
                                                                                    height: 60,
                                                                                    color: Colors.black,
                                                                                    strokeWidth: 2,
                                                                                    gap: 8,
                                                                                    dashLength: 10,
                                                                                  ),
                                                                                ),

                                                                              ],
                                                                            ),


                                                                            // Google Map (conditionally shown based on remote work selection)
                                                                            SizedBox(height: 15,),
                                                                            Text("Pick Work Location",style: TextStyle(
                                                                                color: Colors.black,
                                                                                fontSize: 18
                                                                            ),),
                                                                            ClipRRect(
                                                                              borderRadius: BorderRadius.circular(20),
                                                                              child: Container(
                                                                                height: screenHeight * 0.19,
                                                                                width: screenWidth * 0.95,
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                                                                ),
                                                                                child: GestureDetector(
                                                                                  onTap: () async {

                                                                                    LatLng? selectedLatLng;
                                                                                    Navigator.push(
                                                                                      context,
                                                                                      MaterialPageRoute(
                                                                                        builder: (context) {
                                                                                          return PlacePicker(
                                                                                            resizeToAvoidBottomInset: false, // only works in page mode, less flickery
                                                                                            apiKey: Platform.isAndroid
                                                                                                ? Globals.apiKey
                                                                                                : Globals.apiKey,
                                                                                            hintText: "Find a place ...",
                                                                                            searchingText: "Please wait ...",
                                                                                            selectText: "Select place",
                                                                                            outsideOfPickAreaText: "Place not in area",
                                                                                            initialPosition: LatLng(_latitude,_longitude),
                                                                                            useCurrentLocation: true,
                                                                                            selectInitialPosition: true,
                                                                                            usePinPointingSearch: true,
                                                                                            usePlaceDetailSearch: true,
                                                                                            zoomGesturesEnabled: true,
                                                                                            zoomControlsEnabled: true,
                                                                                            ignoreLocationPermissionErrors: true,
                                                                                            onMapCreated: (GoogleMapController controller) {
                                                                                              print("Map created");
                                                                                            },
                                                                                            onPlacePicked: (PickResult result) {
                                                                                              print("Place picked: ${result.formattedAddress}");
                                                                                              setState(() {
                                                                                                selectedPlace = result;
                                                                                                selectedLatLng = result.geometry?.location != null
                                                                                                    ? LatLng(
                                                                                                  result.geometry!.location!.lat,
                                                                                                  result.geometry!.location!.lng,
                                                                                                )
                                                                                                    : null;
                                                                                                _latitude = selectedLatLng!.latitude;
                                                                                                _longitude = selectedLatLng!.longitude;

                                                                                                if (_controller1 != null) {
                                                                                                  _controller1.future.then((value) {
                                                                                                    value.animateCamera(CameraUpdate.newLatLng(LatLng(_latitude, _longitude)));
                                                                                                  });
                                                                                                }
                                                                                                Navigator.of(context).pop();
                                                                                              });
                                                                                            },
                                                                                            onMapTypeChanged: (MapType mapType) {
                                                                                              print("Map type changed to ${mapType.toString()}");
                                                                                            },
                                                                                          );
                                                                                        },
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                  child: AbsorbPointer(
                                                                                    absorbing: true, // Set to true to prevent interaction with the child widget
                                                                                    child: GoogleMap(
                                                                                      compassEnabled: false, // Hide the zoom buttons

                                                                                      initialCameraPosition: CameraPosition(
                                                                                        target: LatLng(_latitude, _longitude),
                                                                                        zoom: 15,
                                                                                      ),onMapCreated: (GoogleMapController controller) {
                                                                                      _controller1.complete(controller);
                                                                                    },
                                                                                      markers: Set<GoogleMarker.Marker>.of([
                                                                                        GoogleMarker.Marker(
                                                                                          markerId: MarkerId('marker_1'),
                                                                                          position: LatLng(_latitude, _longitude),
                                                                                          infoWindow: InfoWindow(
                                                                                            title: 'Marker Title',
                                                                                            snippet: 'Marker Snippet',
                                                                                          ),
                                                                                        ),
                                                                                      ]),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),


                                                                            SizedBox(height: 10,),


                                                                            OutlinedButton.icon(
                                                                              onPressed: () {
                                                                                // Add onPressed action
                                                                                if (selectedPlace != null && selectedPlace!.formattedAddress != null) {
                                                                                  // Place and formattedAddress are not null, proceed with your logic
                                                                                  Navigator.of(context).pop({'startTime': startTime, 'endTime': endTime, 'hours': hours});

                                                                                } else {
                                                                                  // Either selectedPlace or formattedAddress is null, handle the error or notify the user
                                                                                  print("Error: selectedPlace or formattedAddress is null");


                                                                                  MotionToast.error(
                                                                                    title:  Text("Booking Failed"),
                                                                                    description:  Text("Pick Work Location"),
                                                                                  ).show(context);                                                                       }

                                                                              },
                                                                              style: OutlinedButton.styleFrom(
                                                                                side: BorderSide(color: Colors.pink),
                                                                                shape: RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.circular(10.0),
                                                                                ),
                                                                              ),
                                                                              icon: Icon(
                                                                                Icons.check,
                                                                                color: Colors.pink,
                                                                              ),
                                                                              label: Text(
                                                                                'Confirm',
                                                                                style: TextStyle(
                                                                                  color: Colors.pink,
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            OutlinedButton.icon(
                                                                              onPressed: () {
                                                                                selectedPlace = null;
                                                                                _switchValue = true;
                                                                                // Add onPressed action
                                                                                Navigator.pop(context);

                                                                              },
                                                                              style: OutlinedButton.styleFrom(
                                                                                side: BorderSide(color: Colors.pink),
                                                                                shape: RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.circular(10.0),
                                                                                ),
                                                                              ),
                                                                              icon: Icon(
                                                                                Icons.dangerous,
                                                                                color: Colors.pink,
                                                                              ),
                                                                              label: Text(
                                                                                'Cancel',
                                                                                style: TextStyle(
                                                                                  color: Colors.pink,
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                            ),

                                                                          ],
                                                                        ),
                                                                      ),
                                                                    );
                                                                  });

                                                            },
                                                          ).then((value) {

                                                            //print(selectedPlace!.formattedAddress.toString());
                                                            if (selectedPlace != null && selectedPlace!.formattedAddress != null &&_switchValue == false) {
                                                              // Place and formattedAddress are not null, proceed with your logic
                                                              print(selectedPlace!.formattedAddress.toString());
                                                              print(newDatehour);
                                                              print(fromselectedTime);
                                                              print(toselectedTime);
                                                              DateTime fromDateTime = DateTime(1, 1, 1, fromselectedTime.hour, fromselectedTime.minute);
                                                              DateTime toDateTime = DateTime(1, 1, 1, toselectedTime.hour, toselectedTime.minute);

// Calculate the duration between fromselectedTime and toselectedTime
                                                              Duration difference = toDateTime.difference(fromDateTime);

                                                              print('Hour difference: ${difference.inHours}');
                                                              DateTime now = DateTime.now();
                                                              if (difference.inMinutes < 60) {
                                                                MotionToast.error(
                                                                  title:  Text("Booking Failed"),
                                                                  description:  Text("Minimum One hour Booking"),
                                                                ).show(context);
                                                              } else {
                                                                if (newDatehour.isBefore(DateTime(now.year, now.month, now.day))) {
                                                                  isLoading = false;

                                                                  MotionToast.error(
                                                                    title:  Text("Booking Failed"),
                                                                    description:  Text("The date shoud be today or a future Date"),
                                                                  ).show(context);
                                                                } else {
                                                                  print('Selected date is today or after today.');
                                                                  _postDataToFirestore(
                                                                      workData?['id'],
                                                                      "hours",
                                                                      "",
                                                                      context,
                                                                      newDatehour,DateTime.now(),fromselectedTime,toselectedTime,
                                                                      selectedPlace!.formattedAddress.toString()
                                                                  );
                                                                }
                                                                print('Hour difference: ${difference.inHours}');
                                                              }






                                                            } else {
                                                              isLoading = false;

                                                              // Either selectedPlace or formattedAddress is null, handle the error or notify the user
                                                              print("Error: selectedPlace or formattedAddress is null");
                                                              if(_switchValue){

                                                              }
                                                              else{
                                                                isLoading = false;

                                                                MotionToast.error(
                                                                  title:  Text("Booking Failed"),
                                                                  description:  Text("Pick Work Location"),
                                                                ).show(context);
                                                              }
                                                            }




                                                          });
                                                        }


                                                        // Call the function immediately
                                                        showTimePickerDialog();
                                                      }:null,
                                                      child: Container(
                                                        padding: EdgeInsets.only(right: 20),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.all(Radius.circular(20)),
                                                          color: Colors.orangeAccent.shade100,
                                                        ),
                                                        width: MediaQuery.of(context).size.width * 0.9,
                                                        height: 70,
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                SizedBox(width: 15),
                                                                Container(
                                                                  height: 50,
                                                                  width: 50,
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.all(Radius.circular(15)),
                                                                    color: Colors.white,
                                                                  ),
                                                                  child: Center(
                                                                    child: Image.asset(
                                                                      "assets/clock.png",
                                                                      height: 35,
                                                                      width: 35,
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(width: 10),
                                                                Text(
                                                                  "Hire for hourly basis",
                                                                  style: TextStyle(
                                                                    color: Colors.black,
                                                                    fontWeight: FontWeight.w400,
                                                                    fontSize: screenWidth * 0.05, // Adjust the font size as needed
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Icon(
                                                              Icons.keyboard_arrow_down_sharp,
                                                              color: Colors.black,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 15,),
                                                    GestureDetector(
                                                      onTap: !isLoading ?() {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            String inputText = "";
                                                            bool insidevisi = false;// Initial value for input text
                                                            return Visibility(
                                                                visible: hidebox,
                                                                child: StatefulBuilder(
                                                                  builder: (BuildContext context, StateSetter setState) {
                                                                    return Dialog(
                                                                        backgroundColor: Colors.transparent,
                                                                        elevation: 0,
                                                                        insetPadding: EdgeInsets.zero,

                                                                        child: Stack(
                                                                          children: [
                                                                            Center(
                                                                              child: Container(
                                                                                width: screenWidth*0.82,
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(20),
                                                                                  color: Colors.white,

                                                                                ),
                                                                                padding: EdgeInsets.all(20),
                                                                                child: SingleChildScrollView(
                                                                                  child: Column(
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                                    children: [
                                                                                      Container(
                                                                                        height: 60,
                                                                                        width: screenWidth * 0.65,
                                                                                        padding: EdgeInsets.only(left: 20, right: 10),
                                                                                        decoration: BoxDecoration(
                                                                                            color: Colors.pink.withOpacity(0.7),
                                                                                            borderRadius: BorderRadius.all(Radius.circular(10))
                                                                                        ),
                                                                                        child: GestureDetector(
                                                                                          onTap: () async {
                                                                                            DateTime? pickedDate = await _selectDate(context);
                                                                                            if (pickedDate != null) {
                                                                                              setState(() {
                                                                                                fromdate = pickedDate;
                                                                                              });
                                                                                            }
                                                                                          },
                                                                                          child: Row(
                                                                                            children: [
                                                                                              Container(
                                                                                                height: 32,
                                                                                                width: 32,
                                                                                                decoration: BoxDecoration(
                                                                                                    color: Colors.white,
                                                                                                    borderRadius: BorderRadius.all(Radius.circular(10))
                                                                                                ),
                                                                                                child: Icon(Icons.timelapse,color: Colors.pink,),
                                                                                              ),
                                                                                              SizedBox(width: 13,),
                                                                                              Text('Date:',style: TextStyle(color: Colors.white),),
                                                                                              SizedBox(height: 15),
                                                                                              Text(
                                                                                                '${DateFormat('yyyy-MM-dd').format(fromdate)}',
                                                                                                style: TextStyle(
                                                                                                  color: fromdate == null ? Colors.white : Colors.white, // Change text color based on whether date is selected or not
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      SizedBox(height: 10,),

                                                                                      Container(
                                                                                        height: 100,
                                                                                        width: screenWidth*0.9,
                                                                                        padding: EdgeInsets.only(left: 20,right: 10),
                                                                                        decoration: BoxDecoration(
                                                                                          color: Colors.white.withOpacity(0.8),
                                                                                          borderRadius: BorderRadius.all(Radius.circular(10)),
                                                                                          border: Border.all(
                                                                                            color: Colors.grey.shade300,
                                                                                            width: 1.0,
                                                                                          ),
                                                                                        ),

                                                                                        child: TextField(
                                                                                          onChanged: (value) {
                                                                                            inputText = value;
                                                                                          },
                                                                                          maxLines: 3,
                                                                                          decoration: InputDecoration(
                                                                                            hintText: 'Enter your work',
                                                                                            border: InputBorder.none, // You can customize the border as needed
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      SizedBox(height: 20),
                                                                                      Text("Pick Work Location",style: TextStyle(
                                                                                          color: Colors.black,
                                                                                          fontSize: 18
                                                                                      ),),
                                                                                      ClipRRect(
                                                                                        borderRadius: BorderRadius.circular(20),
                                                                                        child: Container(
                                                                                          height: screenHeight * 0.19,
                                                                                          width: screenWidth * 0.95,
                                                                                          decoration: BoxDecoration(
                                                                                            borderRadius: BorderRadius.all(Radius.circular(20)),
                                                                                          ),
                                                                                          child: GestureDetector(
                                                                                            onTap: () async {

                                                                                              LatLng? selectedLatLng;
                                                                                              Navigator.push(
                                                                                                context,
                                                                                                MaterialPageRoute(
                                                                                                  builder: (context) {
                                                                                                    return PlacePicker(
                                                                                                      resizeToAvoidBottomInset: false, // only works in page mode, less flickery
                                                                                                      apiKey: Platform.isAndroid
                                                                                                          ? Globals.apiKey
                                                                                                          : Globals.apiKey,
                                                                                                      hintText: "Find a place ...",
                                                                                                      searchingText: "Please wait ...",
                                                                                                      selectText: "Select place",
                                                                                                      outsideOfPickAreaText: "Place not in area",
                                                                                                      initialPosition: LatLng(_latitude,_longitude),
                                                                                                      useCurrentLocation: true,
                                                                                                      selectInitialPosition: true,
                                                                                                      usePinPointingSearch: true,
                                                                                                      usePlaceDetailSearch: true,
                                                                                                      zoomGesturesEnabled: true,
                                                                                                      zoomControlsEnabled: true,
                                                                                                      ignoreLocationPermissionErrors: true,
                                                                                                      onMapCreated: (GoogleMapController controller) {
                                                                                                        print("Map created");
                                                                                                      },
                                                                                                      onPlacePicked: (PickResult result) {
                                                                                                        print("Place picked: ${result.formattedAddress}");
                                                                                                        setState(() {
                                                                                                          selectedPlace = result;
                                                                                                          selectedLatLng = result.geometry?.location != null
                                                                                                              ? LatLng(
                                                                                                            result.geometry!.location!.lat,
                                                                                                            result.geometry!.location!.lng,
                                                                                                          )
                                                                                                              : null;
                                                                                                          _latitude = selectedLatLng!.latitude;
                                                                                                          _longitude = selectedLatLng!.longitude;
                                                                                                          if (_controller != null) {
                                                                                                            _controller.future.then((value) {
                                                                                                              value.animateCamera(CameraUpdate.newLatLng(LatLng(_latitude, _longitude)));
                                                                                                            });
                                                                                                          }
                                                                                                          Navigator.of(context).pop();
                                                                                                        });
                                                                                                      },
                                                                                                      onMapTypeChanged: (MapType mapType) {
                                                                                                        print("Map type changed to ${mapType.toString()}");
                                                                                                      },
                                                                                                    );
                                                                                                  },
                                                                                                ),
                                                                                              );
                                                                                            },
                                                                                            child: AbsorbPointer(
                                                                                              absorbing: true, // Set to true to prevent interaction with the child widget
                                                                                              child: GoogleMap(
                                                                                                initialCameraPosition: CameraPosition(
                                                                                                  target: LatLng(_latitude, _longitude),
                                                                                                  zoom: 15,
                                                                                                ),
                                                                                                onMapCreated: (GoogleMapController controller) {
                                                                                                  _controller.complete(controller);
                                                                                                },
                                                                                                markers: Set<GoogleMarker.Marker>.of([
                                                                                                  GoogleMarker.Marker(
                                                                                                    markerId: MarkerId('marker_1'),
                                                                                                    position: LatLng(_latitude, _longitude),
                                                                                                    infoWindow: InfoWindow(
                                                                                                      title: 'Marker Title',
                                                                                                      snippet: 'Marker Snippet',
                                                                                                    ),
                                                                                                  ),
                                                                                                ]),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      SizedBox(height: 20),
                                                                                      OutlinedButton.icon(
                                                                                        onPressed: () {

                                                                                          // Add onPressed action
                                                                                          if (selectedPlace != null && selectedPlace!.formattedAddress != null ) {
                                                                                            setState((){
                                                                                              insidevisi = true;
                                                                                            });
                                                                                            insidevisi = true;
                                                                                            // Place and formattedAddress are not null, proceed with your logic
                                                                                            print(selectedPlace!.formattedAddress.toString());
                                                                                            DateTime now = DateTime.now();
                                                                                            if (fromdate.isBefore(DateTime(now.year, now.month, now.day))) {
                                                                                              print('Selected date should not be before today.');
                                                                                              MotionToast.error(
                                                                                                title:  Text("Booking Failed"),
                                                                                                description:  Text("Pck today's date or a future date"),
                                                                                              ).show(context);
                                                                                            } else {
                                                                                              print('Selected date is today or after today.');

                                                                                              _postDataToFirestore(
                                                                                                  workData?['id'],
                                                                                                  "work",
                                                                                                  inputText,
                                                                                                  context,
                                                                                                  fromdate,DateTime.now(),TimeOfDay(hour: 21, minute: 56),TimeOfDay(hour: 21, minute: 56),
                                                                                                  selectedPlace!.formattedAddress.toString()
                                                                                              );


                                                                                            }


                                                                                          } else {
                                                                                            // Either selectedPlace or formattedAddress is null, handle the error or notify the user
                                                                                            print("Error: selectedPlace or formattedAddress is null");
                                                                                            MotionToast.error(
                                                                                              title:  Text("Booking Failed"),
                                                                                              description:  Text("Pick Work Location"),
                                                                                            ).show(context);                                                  }
                                                                                          // Close the
                                                                                          // Call function to post data to Firestore

                                                                                        },
                                                                                        style: OutlinedButton.styleFrom(
                                                                                          side: BorderSide(color: Colors.pink),
                                                                                          shape: RoundedRectangleBorder(
                                                                                            borderRadius: BorderRadius.circular(10.0),
                                                                                          ),
                                                                                        ),
                                                                                        icon: Icon(
                                                                                          Icons.check,
                                                                                          color: Colors.pink,
                                                                                        ),
                                                                                        label: Text(
                                                                                          'Confirm',
                                                                                          style: TextStyle(
                                                                                            color: Colors.pink,
                                                                                            fontWeight: FontWeight.bold,
                                                                                          ),
                                                                                        ),
                                                                                      )

                                                                                    ],
                                                                                  ),
                                                                                ),

                                                                              ),
                                                                            ),
                                                                            Visibility(
                                                                                visible: insidevisi,
                                                                                child: Container(
                                                                                  margin: EdgeInsets.only(top: screenHeight*0.14),
                                                                                  height: screenHeight*0.5,
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
                                                                                ))
                                                                          ],
                                                                        )
                                                                    );



                                                                  },
                                                                ));
                                                          },
                                                        );
                                                      }:null,
                                                      child: Container(
                                                        padding: EdgeInsets.only(right: 20),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.all(Radius.circular(20)),
                                                          color: Colors.grey.shade100,
                                                        ),
                                                        width: MediaQuery.of(context).size.width*0.9,
                                                        height: 70,
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                SizedBox(width: screenWidth*0.02,),
                                                                Container(
                                                                  height: 50,
                                                                  width: 50,
                                                                  decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius.all(Radius.circular(15)),
                                                                      color: Colors.white
                                                                  ),
                                                                  child: Center(child: Image.asset("assets/working.png",height: 35,width: 35,)),
                                                                ),
                                                                SizedBox(width: screenWidth*0.02,),

                                                                Text("Hire per work",style:
                                                                TextStyle(
                                                                    color: Colors.black,
                                                                    fontWeight: FontWeight.w400,
                                                                    fontSize: screenWidth*0.05
                                                                ),),
                                                              ],
                                                            ),

                                                            Icon(Icons.keyboard_arrow_down_sharp,color: Colors.black,)


                                                          ],
                                                        ),
                                                      ),
                                                    ),


                                                  ],
                                                ),
                                              ),
                                            ),
                                          );



                                        },
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.only(left: 21, right: 21),
                                  height: 50,
                                  decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.all(Radius.circular(30))),
                                  child: Center(
                                    child: Text(
                                      "Hire the Pro",
                                      style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ),
                              ))
                            ],
                          ),
                        ),
                      )),
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
          );
        },
      ),
    );
  }



  Future<void> _postDataToFirestore(String profid, String type, String content,BuildContext context,DateTime fromDate,DateTime toDate,TimeOfDay fromtime,TimeOfDay totime ,String address) async {
    setState(() {
      hidebox = false;
      isLoading = true;
    });
    final currentUser = FirebaseAuth.instance.currentUser;
    try {
      String fromTimeString = fromtime.format(context);
      String toTimeString = totime.format(context);
      print("herasdf");
      print(fromTimeString);
      print(toTimeString);
      int timeStringToMinutes(String timeString) {
        List<String> parts = timeString.split(':');
        int hours = int.parse(parts[0]);
        int minutes = int.parse(parts[1].split(' ')[0]);
        String period = parts[1].split(' ')[1];

        if (period == 'PM' && hours != 12) {
          hours += 12;
        } else if (period == 'AM' && hours == 12) {
          hours = 0;
        }

        return hours * 60 + minutes;
      }

// Function to calculate time difference in minutes
      int calculateTimeDifference(int fromMinutes, int toMinutes) {
        // Calculate the difference in minutes
        int difference = toMinutes - fromMinutes;

        // Check if there are any extra minutes beyond the hours
        int extraMinutes = difference % 60;

        // Check if the extra minutes are greater than or equal to 30
        if (extraMinutes >= 30) {
          // Round up to the next hour
          difference += (60 - extraMinutes);
        } else {
          // Round down to the previous hour
          difference -= extraMinutes;
        }

        // Return the rounded time difference in minutes
        return difference;
      }


      int fromMinutes = timeStringToMinutes(fromTimeString);
      int toMinutes = timeStringToMinutes(toTimeString);

      // Calculate time difference in minutes
      int timeDifference = calculateTimeDifference(fromMinutes, toMinutes);

      // Convert time difference back to hours and minutes
      int hoursDifference = timeDifference ~/ 60;

      int totalamount = -1;
      String name = "";
      String image = "";
      final DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance.collection('prof').doc(profid).get();
      double price=0.0;
      if (profileSnapshot.exists) {
        price = profileSnapshot['price_per_hour'];
        name = profileSnapshot['name'];
        image = profileSnapshot['profile_image_url'];
      }
      if(type=='work'){
        totalamount = -1;
      }
      else{

        totalamount =hoursDifference;
        content = totalamount.toString();
        totalamount = price.toInt()*hoursDifference;

      }


      // Create a new booking object with only the id field filled
      Booking booking = Booking(id: '',
          createdAt: DateTime
              .now()
              .millisecondsSinceEpoch
              .toString(),
          workerId: profid,
          reviewdone: false,
          type: type,
          tip: 0,
          grandtotal: 0,
          hours: content,
          days: content,
          work: content,
          fromDate: fromDate,
          toDate: toDate,
          status: 'sent',
          userId: currentUser!.uid,
          lat: _latitude.toString(),
          long: _longitude.toString(),
          fromTime: fromTimeString,
          address: address,
          toTime: toTimeString,
          payment: false,
          totalamount:totalamount );

      // Add the booking to Firestore
      DocumentReference documentReference = await FirebaseFirestore.instance.collection('bookings').add(booking.toMap());

      // Get the document ID and update the booking object with it
      String docId = documentReference.id;
      booking.id = docId;

      // Update the document with the new booking object
      await documentReference.update(booking.toMap());
      await FirebaseFirestore.instance
          .collection('prof')
          .doc(profid)
          .collection('requests')
          .doc(docId) // Use the same ID as the booking documentasdf
          .set({
        'status': 'sent', // Set status to 'sent'
        'bookingId': docId, // Store the booking ID
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('booking')
          .doc(docId) // Use the same ID as the booking document
          .set({
        'status': 'sent', // Set status to 'sent'
        'bookingId': docId, // Store the booking ID
      });
      APIs.addworktotracks(docId,name,image);
      print('Booking data posted successfully with ID: $docId');
      setState(() {
        isLoading = false;
        hidebox = true;
      });


      // Show alert box
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BookingSuccessScreen()),
      );
    } catch (e) {
      print('Error posting booking data: $e');
      // Show alert box

    }
  }
  Future<DateTime?> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      // Return the selected DateTime
      return picked;
    }

    // Return null if the user cancels or picks the same date
    return null;
  }


  Future<DateTime?> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedTime) {
      // Get the current date
      DateTime now = DateTime.now();

      // Construct a DateTime object using the current date and the picked time
      DateTime selectedDateTime = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);

      // Return the selected DateTime
      return selectedDateTime;
    }

    // Return null if the user cancels or picks the same time
    return null;
  }



}
