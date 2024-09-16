import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glowy_borders/glowy_borders.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:perwork/screens/addreview.dart';
import 'package:perwork/screens/costumer/profileitems/CompletedBookings.dart';
import 'package:perwork/screens/naviagtion_items/HomeScreenContent.dart';
import 'package:perwork/screens/userbooking.dart';
import 'package:shimmer/shimmer.dart';

import '../api/apis.dart';
import '../screens/costumer/showmywork.dart';
import 'package:badges/badges.dart' as badges;


class ShowNotifications extends StatefulWidget {
  const ShowNotifications({Key? key}) : super(key: key);

  @override
  State<ShowNotifications> createState() => _ShowNotificationsState();
}

Future<void> _markAllWorkNotificationsAsSeen() async {
  try {
    // Reference to the notifications collection
    CollectionReference notificationsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(APIs.me.id)
        .collection('notiwork');

    // Get all documents in the collection
    QuerySnapshot snapshot = await notificationsRef.get();

    // Iterate over each document and update the "seen" field
    snapshot.docs.forEach((doc) async {
      await doc.reference.update({'seen': true});
    });
    final CollectionReference workCollection = FirebaseFirestore.instance.collection('users');
    await workCollection
              .doc(APIs.me.id)
              .update({
      'nnotiwork': 0
    });


  } catch (error) {
    print('Error marking notifications as seen: $error');
  }
}
Future<void> _markAllbookingNotificationsAsSeen() async {
  try {
    print('called');
    // Reference to the notifications collection
    CollectionReference notificationsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(APIs.me.id)
        .collection('notibooking');

    // Get all documents in the collection
    QuerySnapshot snapshot = await notificationsRef.get();

    // Iterate over each document and update the "seen" field
    snapshot.docs.forEach((doc) async {
      await doc.reference.update({'seen': true});
    });
    final CollectionReference workCollection = FirebaseFirestore.instance.collection('users');
    await workCollection
        .doc(APIs.me.id)
        .update({
      'nnotibooking': 0
    });
  } catch (error) {
    print('Error marking notifications as seen: $error');
  }
}
String _filterType = 'work'; // Default filter typeFirebaseAuth auth = FirebaseAuth.instance;


class _ShowNotificationsState extends State<ShowNotifications> {
  int nnotibooking = 0;
  int nnotiwork = 0;

  void getdate() {
    FirebaseFirestore.instance.collection('users').doc(APIs.me.id).snapshots().listen((DocumentSnapshot snapshot) {
      setState(() {
        nnotibooking = snapshot['nnotibooking'] ?? 0;
        nnotiwork = snapshot['nnotiwork'] ?? 0;
      });
    });
  }
  void initState() {
    super.initState();
    getdate();
    // Call markAllWorkNotificationsAsSeen() when the screen is initially opened for 'Works'
    if (_filterType == 'work') {
      _markAllWorkNotificationsAsSeen();
    }
  }
  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    User user = auth.currentUser!;
    // Stream of data from Firestore


    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Notifications",
        style: TextStyle(
          color: Colors.white
        ),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.white, // Change the color to any color you want
          onPressed: () {
            Navigator.pop(context);},
        ),
        backgroundColor: Color(0xFF1e1e1e),
      ),
      backgroundColor: Color(0xFF1e1e1e),
      body: Column(
        children: [
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _filterType = 'work';
                    _markAllWorkNotificationsAsSeen(); // Call function for work notifications
                  });
                },
                style: ButtonStyle(
                  backgroundColor: _filterType == 'work'
                      ? MaterialStateProperty.all(Colors.blue)
                      : null,
                ),
                child: badges.Badge(
                  position: badges.BadgePosition.topEnd(top: -13, end: -15),
                  showBadge: (nnotiwork!=0) ? true : false,
                  badgeContent: Text((nnotiwork).toString(),style: TextStyle(color: Colors.white),),
                  child: Text('Works', style: TextStyle(color: _filterType == 'work' ? Colors.white : Colors.white),)),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _filterType = 'booking';
                    _markAllbookingNotificationsAsSeen(); // Call function for booking notifications
                  });
                },
                style: ButtonStyle(
                  backgroundColor: _filterType == 'booking'
                      ? MaterialStateProperty.all(Colors.blue)
                      : null,
                ),
                child: badges.Badge(
                  position: badges.BadgePosition.topEnd(top: -13, end: -15),
                    showBadge: (nnotibooking!=0) ? true : false,
                    badgeContent: Text((nnotibooking).toString(),style: TextStyle(color: Colors.white),),
                  child: Text('Bookings', style: TextStyle(color: _filterType == 'booking' ? Colors.white : Colors.white),))

              ),
            ],
          ),

          SizedBox(height: 10),
          Expanded(
            child: _buildContentForFilterType(),
          ),
        ],
      ),
    );
  }
  Widget _buildContentForFilterType() {
    if (_filterType == 'work') {
      return _showWorkNotification();
    } else {
      return _showBookingNotification();
    }
  }

  Widget _showWorkNotification() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(APIs.me.id)
          .collection('notiwork')
          .orderBy('timestamp', descending: true) // Order by timestamp
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.1),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Lottie.asset('assets/lottie/empty.json'),
                ],
              ),
            ),
          );
        } else {
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              double amount = data['amount'];
              String stramount = amount.toString();
              bool showreview  = false;
              bool showcontact = false;
              bool showamount = true;
              print(data['timestamp']);
              DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(data['timestamp'].seconds * 1000);

              // Format the DateTime object
              String formattedDateTime = DateFormat("dd MMMM yyyy : hh:mm a").format(dateTime);

              print(formattedDateTime);
              String message = " recently applied to your work ";
              if (data['message']=="completed"){
                message = " recently completed your work ";
                if(data['reviewdone']==false){
                  showreview = true;
                }
                showamount = false;
              }
              else if (data['message']=="nearby"){
                message = " recently reached nearby your location ";
                showcontact = true;
                showamount = false;
              }
              else{
                message = " recently applied to your work ";
              }

              if(data['seen']==true){
                return Stack(
                  children: [

                    Container(
                      child: AnimatedGradientBorder(
                        borderSize: 2,
                        glowSize: 4,
                        gradientColors: [
                          Color(0xFFfc00ff),
                          Color(0xFF00dbde),
                          Color(0xFFee9ca7),
                          Color(0xFFb993d6)
                        ],
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.95,
                          height: 150,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                color: Colors.white),
                            padding: EdgeInsets.all(7),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                StreamBuilder<DocumentSnapshot>(
                                  stream: FirebaseFirestore.instance.collection('prof').doc(data['workerID']).snapshots(),
                                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                                    if (userSnapshot.hasError) {
                                      return Text('Something went wrong');
                                    }

                                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    }

                                    Map<String, dynamic> userData = userSnapshot.data!.data() as Map<String, dynamic>;
                                    String imageUrl = userData['profile_image_url'];
                                    String name = userData['name'];
                                    String fullname =data['name'];
                                    String Cutname= "";
                                    if(fullname.length>16){
                                       Cutname = fullname.substring(0, 16);

                                    }
                                    else{
                                       Cutname = fullname;
                                    }

                                    return Container(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.all(Radius.circular(35)),
                                                child: CachedNetworkImage(
                                                  fit: BoxFit.cover,
                                                  imageUrl: imageUrl, // URL of the image
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
                                              SizedBox(width: 10),
                                              Flexible(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    RichText(
                                                      text: TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text: name,
                                                            style: TextStyle(
                                                              color: Colors.black, // Highlight color for "Nishant Sirohi"
                                                              fontWeight: FontWeight.w400,
                                                              fontSize: 19,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: message,
                                                            style: TextStyle(
                                                              color: Colors.black.withOpacity(0.7),
                                                              fontWeight: FontWeight.w400,
                                                              fontSize: 18,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: Cutname,
                                                            style: TextStyle(
                                                              color: Colors.black, // Highlight color for "House Cleaning"
                                                              fontWeight: FontWeight.w400,
                                                              fontSize: 19,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                            ],
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(left: 70),
                                            child: Row(
                                              children: [
                                                Text(formattedDateTime,
                                                  style: TextStyle(
                                                    color: Colors.black.withOpacity(0.7),
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 17,
                                                  ),)
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 4,),
                                          Container(
                                            margin: EdgeInsets.only(left: 20,right: 20),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [

                                                Visibility(
                                                  visible: showamount,
                                                  child: Container(
                                                    padding: EdgeInsets.only(left: 20,right: 20),
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                        color: Colors.pink,
                                                        borderRadius: BorderRadius.all(Radius.circular(10))
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        "₹ "+stramount,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 19
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Visibility(
                                                  visible: data['message']=="completed",
                                                  child: Container(
                                                    padding: EdgeInsets.only(left: 20,right: 20),
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                        color: Colors.pink,
                                                        borderRadius: BorderRadius.all(Radius.circular(10))
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        "Completed",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 19
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Visibility(
                                                  visible: showcontact,
                                                  child: Container(
                                                    padding: EdgeInsets.only(left: 20,right: 20),
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                        color: Colors.pink,
                                                        borderRadius: BorderRadius.all(Radius.circular(10))
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        "Contact",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 19
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),



                                                OutlinedButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(builder: (context) =>   ShowMyWork(workid: data['workID'])),
                                                      );
                                                      

                                                      // Add onPressed action

                                                    },
                                                    style: OutlinedButton.styleFrom(
                                                      side: BorderSide(color: Colors.pink),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(10.0),
                                                      ),
                                                    ),
                                                    child: Container(
                                                      margin: EdgeInsets.only(left: 10,right: 10),
                                                      child: Row(
                                                        children: [

                                                          Image.asset("assets/eye.png",height: 25,width: 25,),
                                                          SizedBox(width: 2,),
                                                          Text(
                                                            'View',
                                                            style: TextStyle(
                                                              color: Colors.pink,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                )

                                              ],
                                            ),
                                          )






                                        ],
                                      ),
                                    );
                                  },
                                )

                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 18,
                      top: 10,
                      child: Container(
                        child: Icon(Icons.dangerous,color: Colors.black,),
                      ),
                    )
                  ],
                );
              }


              return Stack(
                children: [

                  Container(
                    child: AnimatedGradientBorder(
                      borderSize: 2,
                      glowSize: 4,
                      gradientColors: [
                        Color(0xFFfc00ff),
                        Color(0xFF00dbde),
                        Color(0xFFee9ca7),
                        Color(0xFFb993d6)
                      ],
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.95,
                        height: 150,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              color: Colors.white),
                          padding: EdgeInsets.all(7),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance.collection('prof').doc(data['workerID']).snapshots(),
                                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                                  if (userSnapshot.hasError) {
                                    return Text('Something went wrong');
                                  }

                                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  }

                                  Map<String, dynamic> userData = userSnapshot.data!.data() as Map<String, dynamic>;
                                  String imageUrl = userData['profile_image_url'];
                                  String name = userData['name'];


                                  return Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.all(Radius.circular(35)),
                                              child: CachedNetworkImage(
                                                fit: BoxFit.cover,
                                                imageUrl: imageUrl, // URL of the image
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
                                            SizedBox(width: 10),
                                            Flexible(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  RichText(
                                                    text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: name,
                                                          style: TextStyle(
                                                            color: Colors.black, // Highlight color for "Nishant Sirohi"
                                                            fontWeight: FontWeight.w400,
                                                            fontSize: 19,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: message,
                                                          style: TextStyle(
                                                            color: Colors.black.withOpacity(0.7),
                                                            fontWeight: FontWeight.w400,
                                                            fontSize: 18,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: data['name'],
                                                          style: TextStyle(
                                                            color: Colors.black, // Highlight color for "House Cleaning"
                                                            fontWeight: FontWeight.w400,
                                                            fontSize: 19,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                          ],
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(left: 70),
                                          child: Row(
                                            children: [
                                              Text(formattedDateTime,
                                                style: TextStyle(
                                                  color: Colors.black.withOpacity(0.7),
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 17,
                                                ),)
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(left: 20,right: 20),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [

                                              Visibility(
                                                visible: showamount,
                                                child: Container(
                                                  padding: EdgeInsets.only(left: 20,right: 20),
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                      color: Colors.pink,
                                                      borderRadius: BorderRadius.all(Radius.circular(10))
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "₹ "+stramount,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 19
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible: showcontact,
                                                child: Container(
                                                  padding: EdgeInsets.only(left: 20,right: 20),
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                      color: Colors.pink,
                                                      borderRadius: BorderRadius.all(Radius.circular(10))
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "Contact",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 19
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              Visibility(
                                                visible: showreview,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(builder: (context) => AddReviewScreen(profId: data['workerID'],type: "booking",firebaseid: data['id'],) ),
                                                    );
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.only(left: 20,right: 20),
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                        color: Colors.pink,
                                                        borderRadius: BorderRadius.all(Radius.circular(10))
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        "Add Review",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 19
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              OutlinedButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(builder: (context) =>   ShowMyWork(workid: data['workID'])),
                                                    );


                                                    // Add onPressed action

                                                  },
                                                  style: OutlinedButton.styleFrom(
                                                    side: BorderSide(color: Colors.pink),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(10.0),
                                                    ),
                                                  ),
                                                  child: Container(
                                                    margin: EdgeInsets.only(left: 10,right: 10),
                                                    child: Row(
                                                      children: [

                                                        Image.asset("assets/eye.png",height: 25,width: 25,),
                                                        SizedBox(width: 2,),
                                                        Text(
                                                          'View',
                                                          style: TextStyle(
                                                            color: Colors.pink,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                              )

                                            ],
                                          ),
                                        )






                                      ],
                                    ),
                                  );
                                },
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 18,
                    top: 10,
                    child: Container(
                      child: Icon(Icons.dangerous,color: Colors.black,),
                    ),
                  )
                ],
              );

            }).toList(),
          );
        }
      },
    );
  }
  Widget _showBookingNotification() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(APIs.me.id)
          .collection('notibooking')
          .orderBy('timestamp', descending: true) // Order by timestamp
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.1),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Lottie.asset('assets/lottie/empty.json'),
                ],
              ),
            ),
          );
        } else {
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(data['timestamp'].seconds * 1000);

              // Format the DateTime object to get the date in the desired format
              String formattedDate = DateFormat("dd/MM/yyyy").format(dateTime);

              print(formattedDate);
              String message = " recently accepted your booking request ";
              if(data['message']=="accept"){
                message = " recently accepted your booking request ";
              }
              else if (data['message']=="decline"){
                message = " recently declined your booking request ";
              }
              else{
                message = " recently completed your booking request ";
              }
              if(data['seen']==true){
                print("hey");
                return Stack(
                  children: [

                    Container(
                      child: AnimatedGradientBorder(
                        borderSize: 2,
                        glowSize: 4,
                        gradientColors: [
                          Color(0xFFfc00ff),
                          Color(0xFF00dbde),
                          Color(0xFFee9ca7),
                          Color(0xFFb993d6)
                        ],
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.95,
                          height: 130,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                color: Colors.white),
                            padding: EdgeInsets.all(7),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                StreamBuilder<DocumentSnapshot>(
                                  stream: FirebaseFirestore.instance.collection('prof').doc(data['workerID']).snapshots(),
                                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                                    if (userSnapshot.hasError) {
                                      return Text('Something went wrong');
                                    }

                                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    }

                                    Map<String, dynamic> userData = userSnapshot.data!.data() as Map<String, dynamic>;
                                    String imageUrl = userData['profile_image_url'];
                                    String name = userData['name'];


                                    return Container(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.all(Radius.circular(35)),
                                                child: CachedNetworkImage(
                                                  fit: BoxFit.cover,
                                                  imageUrl: imageUrl, // URL of the image
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
                                              SizedBox(width: 10),
                                              Flexible(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    RichText(
                                                      text: TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text: name,
                                                            style: TextStyle(
                                                              color: Colors.black, // Highlight color for "Nishant Sirohi"
                                                              fontWeight: FontWeight.w500,
                                                              fontSize: 19,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: message,
                                                            style: TextStyle(
                                                              color: Colors.black.withOpacity(0.7),
                                                              fontWeight: FontWeight.w400,
                                                              fontSize: 18,
                                                            ),
                                                          ),

                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                            ],
                                          ),

                                          Container(
                                            margin: EdgeInsets.only(left: 20,right: 20),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.only(left: 20,right: 20),
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                      color: Colors.pink,
                                                      borderRadius: BorderRadius.all(Radius.circular(10))
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      formattedDate,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 19
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                OutlinedButton(
                                                    onPressed: () {
                                                      if(data['message']=="completed"){
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(builder: (context) =>   CompletedBooking()),
                                                        );
                                                      }
                                                      else{
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(builder: (context) =>   UserBooking()),
                                                        );
                                                      }

                                                      // Add onPressed action

                                                    },
                                                    style: OutlinedButton.styleFrom(
                                                      side: BorderSide(color: Colors.pink),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(10.0),
                                                      ),
                                                    ),
                                                    child: Container(
                                                      margin: EdgeInsets.only(left: 10,right: 10),
                                                      child: Row(
                                                        children: [

                                                          Image.asset("assets/eye.png",height: 25,width: 25,),
                                                          SizedBox(width: 2,),
                                                          Text(
                                                            'View',
                                                            style: TextStyle(
                                                              color: Colors.pink,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                )
                                              ],
                                            ),
                                          )






                                        ],
                                      ),
                                    );
                                  },
                                )

                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 18,
                      top: 10,
                      child: Container(
                        child: Icon(Icons.dangerous,color: Colors.black,),
                      ),
                    )
                  ],
                );
              }

              return Stack(
                children: [

                  Container(
                    child: AnimatedGradientBorder(
                      borderSize: 2,
                      glowSize: 4,
                      gradientColors: [
                        Color(0xFFfc00ff),
                        Color(0xFF00dbde),
                        Color(0xFFee9ca7),
                        Color(0xFFb993d6)
                      ],
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.95,
                        height: 130,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              color: Colors.white),
                          padding: EdgeInsets.all(7),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance.collection('prof').doc(data['workerID']).snapshots(),
                                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                                  if (userSnapshot.hasError) {
                                    return Text('Something went wrong');
                                  }

                                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  }

                                  Map<String, dynamic> userData = userSnapshot.data!.data() as Map<String, dynamic>;
                                  String imageUrl = userData['profile_image_url'];
                                  String name = userData['name'];


                                  return Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 60.0,
                                              height: 60.0,
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
                                            SizedBox(width: 10),
                                            Flexible(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  RichText(
                                                    text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: name,
                                                          style: TextStyle(
                                                            color: Colors.black, // Highlight color for "Nishant Sirohi"
                                                            fontWeight: FontWeight.w500,
                                                            fontSize: 19,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: message,
                                                          style: TextStyle(
                                                            color: Colors.black.withOpacity(0.7),
                                                            fontWeight: FontWeight.w400,
                                                            fontSize: 18,
                                                          ),
                                                        ),

                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                          ],
                                        ),

                                        Container(
                                          margin: EdgeInsets.only(left: 20,right: 20),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.only(left: 20,right: 20),
                                                height: 40,
                                                decoration: BoxDecoration(
                                                    color: Colors.pink,
                                                    borderRadius: BorderRadius.all(Radius.circular(10))
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    formattedDate,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 19
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              OutlinedButton(
                                                  onPressed: () {
                                                    if(data['message']=="completed"){
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(builder: (context) =>   CompletedBooking()),
                                                      );
                                                    }
                                                    else{
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(builder: (context) =>   UserBooking()),
                                                      );
                                                    }

                                                    // Add onPressed action

                                                  },
                                                  style: OutlinedButton.styleFrom(
                                                    side: BorderSide(color: Colors.pink),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(10.0),
                                                    ),
                                                  ),
                                                  child: Container(
                                                    margin: EdgeInsets.only(left: 10,right: 10),
                                                    child: Row(
                                                      children: [

                                                        Image.asset("assets/eye.png",height: 25,width: 25,),
                                                        SizedBox(width: 2,),
                                                        Text(
                                                          'View',
                                                          style: TextStyle(
                                                            color: Colors.pink,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                              )
                                            ],
                                          ),
                                        )






                                      ],
                                    ),
                                  );
                                },
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 18,
                    top: 10,
                    child: Container(
                      child: Icon(Icons.dangerous,color: Colors.black,),
                    ),
                  )
                ],
              );

            }).toList(),
          );
        }
      },
    );
  }

}
