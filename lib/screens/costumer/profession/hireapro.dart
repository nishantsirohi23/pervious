import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:perwork/screens/costumer/profession/searchprof.dart';
import 'package:perwork/screens/costumer/profession/viewprofile.dart';
import 'package:perwork/screens/intro.dart';
import 'package:perwork/screens/naviagtion_items/HomeScreenContent.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:perwork/screens/userbooking.dart';
import 'package:perwork/try/chatlist.dart';
import 'package:perwork/try/shownotifications.dart';
import 'package:shimmer/shimmer.dart';

import '../../../api/apis.dart';
import '../../../try/profile_menu.dart';
import '../../../utils/LocationService.dart';
import 'package:badges/badges.dart' as badges;

import '../../profilescreen.dart';
import '../profileitems/CompletedBookings.dart';




class hireapro extends StatefulWidget {
  const hireapro({Key? key}) : super(key: key);

  @override
  State<hireapro> createState() => _hireaproState();
}

class _hireaproState extends State<hireapro> with SingleTickerProviderStateMixin {
  bool isLoading = true;
  String _latitude = '';
  String _longitude = '';
  late LocationService _locationService;
  late AnimationController _animationController;
  late Animation<Offset> _animation;



  Future<void> _getCurrentLocation() async {
    FirebaseFirestore.instance.collection('users').doc(APIs.me.id).snapshots().listen((DocumentSnapshot snapshot) {
      setState(() {
        _latitude = snapshot['latitude'] ?? 0;
        _longitude = snapshot['longitude'] ?? 0;

      });
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
      return 'Evening';
    }
  }
  int nnotibooking = 0;
  int nnotiwork = 0;
  int nmessage = 0;

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
  void initState() {
    super.initState();
    getdate();

    _locationService = LocationService();
    _getCurrentLocation();
    // Fetch user information when the widget is first created
    _loadUserData();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _openNewScreen() {
    _animationController.forward();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => IntroMain()),
    ).then((_) {
      _animationController.reverse();
    });
  }

  void _loadUserData() async {
    await APIs.getSelfInfo();
    setState(() {
      isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double systemNavigationBarHeight = MediaQuery.of(context).padding.bottom;
    final Stream<QuerySnapshot> _usersStream =
    FirebaseFirestore.instance.collection('prof').snapshots();
    FirebaseAuth auth = FirebaseAuth.instance;
    User user = auth.currentUser!;
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: screenHeight*0.19,
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/backappbar1.png"),
                  fit: BoxFit.cover,

                )
            ),
            child: Container(
              margin: EdgeInsets.only(left: 20,right: 20,top: 10),
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
                              child:  ClipRRect(
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
                  )
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: screenHeight*0.19-30,
          child: Container(
            height: screenHeight*0.5,
            width: screenWidth,
            decoration: BoxDecoration(
              color: Color(0xFF61BDF6),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(35.0), // Adjust the radius as needed
                topRight: Radius.circular(35.0), // Adjust the radius as needed
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight*0.024,),
                Text("What are you looking",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600,fontSize: screenHeight*0.033),),
                Text("for your work",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600,fontSize: screenHeight*0.033),),

                SizedBox(height: screenHeight*0.015,),
                GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SearchProf(searchText: "",)),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 20, right: 20),
                    height: screenHeight*0.066,
                    child: Center(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(25)),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                          child: Container(
                            height: 250,
                            decoration: BoxDecoration(
                              color: Color(0xFF81c9f7),
                              borderRadius: const BorderRadius.all(Radius.circular(30)),
                            ),
                            child: GestureDetector(
                              onTap: (){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => SearchProf(searchText: "",)),
                                );
                              },
                              child: Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.search, color: Colors.white,size: 30,),
                                    SizedBox(width: 10),
                                    Text(
                                      'Looking for Maid?',
                                      style: TextStyle(color: Colors.white,fontSize: screenHeight*0.021),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: screenHeight*0.019,),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(width: 20,),
                      GestureDetector(
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SearchProf(searchText: "plumber",)),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(25)),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                            child: Container(
                              height: screenHeight*0.04,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Color(0xFF81c9f7),
                                borderRadius: const BorderRadius.all(Radius.circular(30)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [

                                  Text(
                                    'Plumber',
                                    style: TextStyle(color: Colors.white,fontSize: screenHeight*0.018),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 15,),
                      GestureDetector(
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SearchProf(searchText: "lawyer",)),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(25)),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                            child: Container(
                              height: screenHeight*0.04,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Color(0xFF81c9f7),
                                borderRadius: const BorderRadius.all(Radius.circular(30)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [

                                  Text(
                                    'Lawyer',
                                    style: TextStyle(color: Colors.white,fontSize: screenHeight*0.018),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 15,),
                      GestureDetector(
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SearchProf(searchText: "mechanic",)),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(25)),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                            child: Container(
                              height: screenHeight*0.04,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Color(0xFF81c9f7),
                                borderRadius: const BorderRadius.all(Radius.circular(30)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [

                                  Text(
                                    'Mechanic',
                                    style: TextStyle(color: Colors.white,fontSize: screenHeight*0.018),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 15,),
                      GestureDetector(
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SearchProf(searchText: "driver",)),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(25)),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                            child: Container(
                              height: screenHeight*0.04,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Color(0xFF81c9f7),
                                borderRadius: const BorderRadius.all(Radius.circular(30)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [

                                  Text(
                                    'Driver',
                                    style: TextStyle(color: Colors.white,fontSize: screenHeight*0.018),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 15,),
                      GestureDetector(
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SearchProf(searchText: "carpenter",)),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(25)),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                            child: Container(
                              height: screenHeight*0.04,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Color(0xFF81c9f7),
                                borderRadius: const BorderRadius.all(Radius.circular(30)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [

                                  Text(
                                    'Carpainter',
                                    style: TextStyle(color: Colors.white,fontSize: screenHeight*0.018),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                )

              ],
            ),

          ),
        ),
        Positioned(
            top: screenHeight*0.44,
            child: Container(
              height: screenHeight,
              width: screenWidth,
              decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(35),topLeft: Radius.circular(35))
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onVerticalDragUpdate: (details) {
                              // Listen to vertical drag updates
                              if (details.delta.dy < -0.2) {
                                // Detect upward swipe
                              }
                            },
                            child:  Column(
                              children: [
                                SizedBox(height: 10,),
                                Container(

                                  width: 60,
                                  height: 7,
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                ),
                                Container(
                                  margin:EdgeInsets.only(left: 20,top: screenHeight*0.011),
                                  child: Text("Featured Professionals",
                                    style: TextStyle(color: CupertinoColors.black,fontSize: screenHeight*0.024,fontWeight: FontWeight.w500),),
                                ),
                              ],
                            ),),


                          Container(
                            height: screenHeight*0.37,
                            width: screenWidth,
                            child: StreamBuilder<QuerySnapshot>(
                              stream: _usersStream,
                              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.hasError) {
                                  return Text('Something went wrong');
                                }

                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Text("Loading");
                                }

                                // Filter documents based on search term
                                final List<QueryDocumentSnapshot> filteredDocuments =
                                snapshot.data!.docs




                                    .toList();


                                return ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: filteredDocuments
                                      .take(5) // Take only the first five items
                                      .map((DocumentSnapshot document) {
                                    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                                    var listspecs = data['specialities'] as List<dynamic>;



                                    // Determine background color based on priority


                                    return GestureDetector(
                                      onTap: (){
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => viewProfile(profid: data['id'])),
                                        );
                                      },
                                      child: Container(
                                        height: screenHeight,

                                        width: screenWidth*0.57,

                                        margin: EdgeInsets.only(top: 12, bottom: 10, left: 18, right: 5),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.circular(30.0),
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
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(left: 12,right: 10,top: 12),
                                                child: Row(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius: BorderRadius.all(Radius.circular(35)),
                                                      child: CachedNetworkImage(
                                                        fit: BoxFit.cover,
                                                        imageUrl: data['profile_image_url'], // URL of the image
                                                        width: 50, // Double the radius to fit the CircleAvatar
                                                        height: 50, // Double the radius to fit the CircleAvatar
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
                                                    SizedBox(width: 10,),
                                                    Container(
                                                      child: Column(
                                                        children: [
                                                          Text(data['name'],
                                                            style: TextStyle(
                                                                color: Colors.black,
                                                                fontWeight: FontWeight.w500,
                                                                fontSize: screenHeight*0.02
                                                            ),),
                                                          Text(data['username'],
                                                            style: TextStyle(
                                                                color: Colors.black.withOpacity(0.5),
                                                                fontWeight: FontWeight.w400,
                                                                fontSize: screenHeight*0.019
                                                            ),)

                                                        ],
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 10,),
                                              Container(
                                                margin: EdgeInsets.only(left: 18,right: 10),
                                                child: Row(
                                                  children: [
                                                    Image.asset("assets/expertise.png",width: 30,height: 30,),
                                                    Text("Experience",
                                                      style: TextStyle(
                                                          color: Colors.black.withOpacity(0.5),
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: screenHeight*0.0185
                                                      ),)
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: screenHeight*0.005,),
                                              Container(
                                                margin: EdgeInsets.only(left: 20),
                                                child: Text(data['experience'],
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: screenHeight*0.02
                                                  ),),
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(left: 18,right: 10),
                                                child: Row(
                                                  children: [
                                                    Image.asset("assets/idea.png",width: 30,height: 30,),
                                                    Text("Specialities",
                                                      style: TextStyle(
                                                          color: Colors.black.withOpacity(0.5),
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: screenHeight*0.0185
                                                      ),)
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: screenHeight*0.005,),

                                              Container(
                                                height: 25,
                                                margin: EdgeInsets.only(left: 20,right: 10),
                                                child: SingleChildScrollView(
                                                  scrollDirection: Axis.horizontal,
                                                  child: Row(
                                                    children: listspecs.map((spec) {
                                                      return Padding(
                                                        padding: const EdgeInsets.only(right: 8.0),
                                                        child: Container(
                                                          padding: EdgeInsets.only(left: 7,right: 7,top: 3,bottom: 3),
                                                          decoration: BoxDecoration(
                                                            color: Colors.blue,
                                                            borderRadius: BorderRadius.circular(20),
                                                          ),
                                                          child: Text(
                                                            spec,
                                                            style: TextStyle(fontSize: screenHeight*0.016, color: Colors.white),
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: screenHeight*0.005,),
                                              Container(
                                                margin: EdgeInsets.only(left: 18,right: 10),
                                                child: Row(
                                                  children: [
                                                    Image.asset("assets/star.png",width: 30,height: 30,),
                                                    Text("Ratings",
                                                      style: TextStyle(
                                                          color: Colors.black.withOpacity(0.5),
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: screenHeight*0.0185
                                                      ),)
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 2,),
                                              Container(
                                                  margin: EdgeInsets.only(left: 20),
                                                  child: Row(
                                                    children: [
                                                      Text(data['rating']+" star",
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight: FontWeight.w500,
                                                            fontSize: screenHeight*0.02
                                                        ),),
                                                      Text("("+data['totalrating']+")",
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight: FontWeight.w500,
                                                            fontSize: screenHeight*0.02
                                                        ),),
                                                      SizedBox(width: 10,),
                                                      Container(

                                                        child: StreamBuilder<QuerySnapshot>(
                                                          stream: FirebaseFirestore.instance.collection('prof').doc(data['id']).collection('reviews').snapshots(),
                                                          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> playerSnapshot) {
                                                            if (playerSnapshot.hasError) {
                                                              return Text('Something went wrong');
                                                            }

                                                            if (playerSnapshot.connectionState == ConnectionState.waiting) {
                                                              return Text("Loading");
                                                            }

                                                            List<DocumentSnapshot> playerDocs = playerSnapshot.data!.docs;

                                                            int displayCount = playerDocs.length > 2 ? 2 : playerDocs.length;

                                                            return Row(
                                                              children: List.generate(displayCount, (index) {
                                                                Map<String, dynamic> playerData = playerDocs[index].data() as Map<String, dynamic>;
                                                                String userId = playerData['userId'];

                                                                return StreamBuilder<DocumentSnapshot>(
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

                                                                    return Container(
                                                                      width:screenWidth*0.08,
                                                                      height: screenWidth*0.08,
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
                                                                    );
                                                                  },
                                                                );
                                                              }),
                                                            );
                                                          },
                                                        ),
                                                        //show here the images of users which have posted the reviews
                                                      )
                                                    ],
                                                  )
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
                        ],
                      ),
                    ),




                  ],
                ),
              ),
            )
        ),
        SlideTransition(
          position: _animation,
          child: GestureDetector(
              onVerticalDragUpdate: (_) {}, // Prevent dragging on new screen34
              child: Visibility(
                visible: false,
                child: Container(
                  color: Colors.blue,
                  child: Center(
                    child: Text(
                      'New Screen',
                      style: TextStyle(fontSize: 24.0, color: Colors.white),
                    ),
                  ),
                ),
              )
          ),
        ),

      ],
    );
  }
}
