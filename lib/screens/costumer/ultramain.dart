import 'dart:async';

import 'package:another_dashed_container/another_dashed_container.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:perwork/screens/costumer/buyitems.dart';
import 'package:perwork/screens/costumer/pickup.dart';
import 'package:perwork/screens/costumer/profession/searchprof.dart';
import 'package:perwork/screens/costumer/ride/taxi.dart';
import 'package:shimmer/shimmer.dart';

import '../../api/apis.dart';
import '../../try/chatlist.dart';
import 'package:badges/badges.dart' as badges;

import '../../try/shownotifications.dart';
import '../../widgets/work/searchbar.dart';
import '../profilescreen.dart';
import 'addwork.dart';
import 'food/introsearch.dart';


class UltraMain extends StatefulWidget {
  const UltraMain({Key? key}) : super(key: key);

  @override
  State<UltraMain> createState() => _UltraMainState();
}

class _UltraMainState extends State<UltraMain> {
  int nnotibooking = 0;
  int nnotiwork = 0;
  int nmessage = 0;
  bool isLoading = true;
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;
  void _startAutoScroll() {
    _scrollTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (_scrollController.hasClients) {
        final maxScrollExtent = _scrollController.position.maxScrollExtent.toDouble();
        final currentScrollPosition = _scrollController.position.pixels.toDouble();
        final targetPosition = currentScrollPosition < maxScrollExtent ? currentScrollPosition + 200.0 : 0.0;
        _scrollController.animateTo(
          targetPosition,
          duration: Duration(seconds: 2),
          curve: Curves.easeInOut,
        );
      }
    });
  }



  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();    _startAutoScroll();

    getdate();
    _profData = getProfs();
    _rideData = getRides();
    _buyitem =getBuy();
    _deliveryitem= getdelivery();

  }

  final Stream<QuerySnapshot> _usersStream =
  FirebaseFirestore.instance.collection('features').snapshots();
  @override
  Widget build(BuildContext context) {
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
      backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
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
                                  imageUrl: 'https://firebasestorage.googleapis.com/v0/b/perwork.appspot.com/o/Perpenny%20your%20genei.png?alt=media&token=3e32656c-55b7-41f5-a7f3-4da111e7d7e2', // URL of the image
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

                        ],
                      )
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20,right: 20),
                    child: Stack(
                      children: [


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
                                              badgeContent: Text((nmessage).toString(),style: TextStyle(color: Colors.black),),
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
                                            badgeContent: Text((nnotiwork+nnotibooking).toString(),style: TextStyle(color: Colors.black),),
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
                                  )
                                ],
                              )
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Container(
                margin: EdgeInsets.only(left: 12),
                height: 90,
                padding: EdgeInsets.only(top: 10,bottom: 6),
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
                              MaterialPageRoute(builder: (context) => SearchProf(searchText: data['name'],)),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade200,width: 0.8),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            margin: EdgeInsets.only(right: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: data['image'], // URL of the image
                                width: 170, // Double the radius to fit the CircleAvatar
                                height: 70, // Double the radius to fit the CircleAvatar
                                placeholder: (context, url) => Shimmer.fromColors(
                                  baseColor: Colors.grey[200]!,
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
              SizedBox(height: 7,),

              Stack(
                children: [
                  Container(
                    margin:EdgeInsets.only(left: 14,right: 14,top: 160),
                    padding: EdgeInsets.only(top: 20,bottom: 5,left: 10,right: 10),
                    decoration: BoxDecoration(
                        color: Colors.pink.shade300.withOpacity(0.3),
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20))
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset("assets/super.png",height: 30,width: 30,),
                        Container(
                          width: screenWidth*0.76,
                          child: Text("Get 25% off on platform fees with Super Genie",
                            style: TextStyle(
                                color: Colors.pink
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.clip,),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin:EdgeInsets.only(left: 14,right: 14),
                    padding:EdgeInsets.all(15),

                    width: screenWidth,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Post Your Task",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: screenHeight*0.0234,
                                  fontWeight: FontWeight.w500
                              ),),
                            Text("Take a seat, unwind, and let Perpenny do the rest",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: screenHeight*0.019,
                                  fontWeight: FontWeight.w400
                              ),),

                            SizedBox(height: screenHeight*0.01,)
                          ],
                        ),
                        GestureDetector(
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>   AddWork(companyName: "",)),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.only(left: 13,right: 13),
                            height: screenHeight*0.07,
                            decoration: BoxDecoration(
                                color: Colors.pink.withOpacity(0.7),
                                borderRadius: BorderRadius.all(Radius.circular(12))
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Add your Work",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenHeight*0.0234,
                                      fontWeight: FontWeight.w500
                                  ),),
                                Icon(Icons.arrow_forward,color: Colors.white,)],
                            ),
                          ),
                        )
                      ],

                    ),
                  ),

                ],
              ),
              SizedBox(height: 10,),

              Container(
                margin: EdgeInsets.only(left: 10,right: 10),
                decoration: BoxDecoration(

                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Pick Up and Drop',
                        style: TextStyle(fontSize: 18.0, color: Colors.black.withOpacity(0.5)),
                      ),
                    ),

                  ],
                ),
              ),
              Image.network("https://firebasestorage.googleapis.com/v0/b/perwork.appspot.com/o/services%2FYellow%20Illustrative%20Digital%20Education%20For%20Children%20Infographic.jpg?alt=media&token=2a02a912-3f50-4903-a382-afcc14306708"
              ,height: 1200,width: screenWidth,
              fit: BoxFit.cover,),
              Container(
                margin: EdgeInsets.only(left: 12),
                height: 170,
                padding: EdgeInsets.only(top: 7,bottom: 7),
                child: FutureBuilder<QuerySnapshot>(
                  future: _deliveryitem, // Assuming _usersStream() returns a Future<QuerySnapshot>
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
                              MaterialPageRoute(builder: (context) => PickUpDelivery()),
                            );
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
                                imageUrl: data['image'], // URL of the image
                                width: 200, // Double the radius to fit the CircleAvatar
                                height: 70, // Double the radius to fit the CircleAvatar
                                placeholder: (context, url) => Shimmer.fromColors(
                                  baseColor: Colors.grey[200]!,
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
              Container(
                margin: EdgeInsets.only(left: 10,right: 10),
                decoration: BoxDecoration(

                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Get your Items',
                        style: TextStyle(fontSize: 18.0, color: Colors.black.withOpacity(0.5)),
                      ),
                    ),

                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 12),
                height: 170,
                padding: EdgeInsets.only(top: 7,bottom: 7),
                child: FutureBuilder<QuerySnapshot>(
                  future: _buyitem, // Assuming _usersStream() returns a Future<QuerySnapshot>
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
                              MaterialPageRoute(builder: (context) => BuyItems(type: data['name'])),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                            margin: EdgeInsets.only(right: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: data['image'], // URL of the image
                                width: 200, // Double the radius to fit the CircleAvatar
                                height: 90, // Double the radius to fit the CircleAvatar
                                placeholder: (context, url) => Shimmer.fromColors(
                                  baseColor: Colors.grey[200]!,
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
              Container(
                margin: EdgeInsets.only(left: 10,right: 10),
                decoration: BoxDecoration(

                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Book your ride',
                        style: TextStyle(fontSize: 18.0, color: Colors.black.withOpacity(0.5)),
                      ),
                    ),

                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 12),
                height: 170,
                padding: EdgeInsets.only(top: 7,bottom: 7),
                child: FutureBuilder<QuerySnapshot>(
                  future: _rideData, // Assuming _usersStream() returns a Future<QuerySnapshot>
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
                              MaterialPageRoute(builder: (context) => BookTaxi(type: data['name'])),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                                border: Border.all(color: Colors.grey.shade400.withOpacity(0.7),width: 1)
                            ),
                            margin: EdgeInsets.only(right: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: data['image'], // URL of the image
                                width: 200, // Double the radius to fit the CircleAvatar
                                height: 70, // Double the radius to fit the CircleAvatar
                                placeholder: (context, url) => Shimmer.fromColors(
                                  baseColor: Colors.grey[200]!,
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

              Container(
                margin: EdgeInsets.only(left: 20,top: 5,bottom: 7),
                child: Text(
                  "Do anything with perpenny",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 18
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 4),
                height: 142,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('examples').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      var items = snapshot.data!.docs.map((doc) {
                        return {
                          'name': doc['name'],
                          'title': doc['title'],
                          'image': doc['image'],
                        };
                      }).toList();

                      return ListView.builder(padding: EdgeInsets.zero,
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          var item = items[index];
                          String title = item['title'];
                          int maxLength = 45; // Define the maximum length of the title text
                          return Container(
                            padding: EdgeInsets.only(left: 10, right: 5, top: 7, bottom: 5),
                            width: screenWidth * 0.75,
                            margin: EdgeInsets.symmetric(horizontal: 10.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15.0),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1.0,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Image.network(
                                      item['image'],
                                      height: 53,
                                      width: 53,
                                      fit: BoxFit.cover, // Ensure the image fills the container
                                      // Optionally, add a borderRadius to the image
                                      // borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    SizedBox(width: 10), // Add some space between the image and text
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _cutTitle(title, maxLength),
                                            style: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 2, // Limit to two lines for the title
                                            overflow: TextOverflow.clip, // Show ellipsis if text overflows
                                          ),

                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (title.length > maxLength) // Check if the title is longer than maxLength
                                  Text(
                                    maxLines: 3,
                                    overflow: TextOverflow.clip,
                                    title.substring(_cutTitle(title, maxLength).length),
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                          )
                          ;
                        },
                      );
                    }
                  },
                ),
              ),
              Container(
                height: screenHeight*0.3,
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
                      children: filteredDocuments.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;


                        // Determine background color based on priority


                        return GestureDetector(
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AddWork(companyName: "",)),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            width: screenWidth*0.77,
                            margin: EdgeInsets.only(top: 12, bottom: 10, left: 14, right: 5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(20.0),
                              color: Colors.transparent,
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(data['back']),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [


                                Container(
                                  child: Text(
                                    data['title'],
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: screenHeight*0.0303
                                    ),
                                  ),
                                ),
                                Container(
                                  width: screenWidth*0.47,
                                  child:Text(
                                    data['des'],
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400,
                                        fontSize: screenHeight*0.02
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: (){

                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(Radius.circular(8))
                                    ),
                                    padding: EdgeInsets.only(left: 3,right: 3),
                                    child: ShaderMask(
                                      blendMode: BlendMode.srcIn,
                                      shaderCallback: (Rect bounds) {
                                        return LinearGradient(
                                          colors: [Colors.pink, Colors.pinkAccent], // Define your gradient colors
                                        ).createShader(bounds);
                                      },
                                      child: Text(
                                        "START MAGIC!",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 17,
                                          color: Colors.white, // This color will be applied with the gradient
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
        )
    );
  }
}
class DashedBorderSide extends BorderSide {
  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;

    const double dashWidth = 5.0;
    const double dashSpace = 5.0;
    double start = rect.left;
    while (start < rect.right) {
      canvas.drawLine(
        Offset(start, rect.top),
        Offset(start + dashWidth, rect.top),
        paint,
      );
      start += dashWidth + dashSpace;
    }
  }

  const DashedBorderSide({
    this.color = const Color(0xFF000000),
    this.width = 1.0,
    this.style = BorderStyle.solid,
  }) : super(color: color, width: width, style: style);

  final Color color;
  final double width;
  final BorderStyle style;
}String _cutTitle(String title, int maxLength) {
  if (title.length <= maxLength) {
    return title;
  } else {
    int lastSpaceIndex = title.substring(0, maxLength).lastIndexOf(' ');
    return title.substring(0, lastSpaceIndex);
  }
}




