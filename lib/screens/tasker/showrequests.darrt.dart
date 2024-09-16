import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:perwork/api/apis.dart';
import 'package:perwork/screens/tasker/showrequests.darrt.dart';

import '../../onboding/components/custom_sign_in_dialog.dart';
import '../../try/chatlist.dart';
import '../../try/shownotifications.dart';
import '../BookingTicket.dart';
import 'package:badges/badges.dart' as badges;

import '../work/workerprofile.dart';




class ShowRequests extends StatefulWidget {
  const ShowRequests({Key? key}) : super(key: key);

  @override
  State<ShowRequests> createState() => _UserBookingState();
}

class _UserBookingState extends State<ShowRequests> {
  String _filterType = 'hours'; // Default filter typeFirebaseAuth auth = FirebaseAuth.instance;
  final Stream<QuerySnapshot> _usersStream =
  FirebaseFirestore.instance.collection('bookings').snapshots();
  int nnotibooking = 0;
  int nnotiwork = 0;
  int nmessage = 0;
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getdate();
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


  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    User user = auth.currentUser!;
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

    // Stream of data from Firestore


    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(resizeToAvoidBottomInset: false,

      body:Stack(
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
                            "Track Work",
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
                          SizedBox(width: 13,),
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
            margin:EdgeInsets.only(top: screenHeight*0.14),
            child: Column(
              children: [
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _filterType = 'hours';
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor: _filterType == 'hours'
                            ? MaterialStateProperty.all(Colors.blue)
                            : null,
                      ),
                      child: Text('Hours', style: TextStyle(color: _filterType == 'hours' ? Colors.white : null)),
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
            ),
          ),

        ],
      ),
    );
  }



  String calculateHourDifference(String fromTime, String toTime) {
    // Parse fromTime and toTime
    DateFormat format = DateFormat('h:mm a');
    DateTime fromDate = format.parse(fromTime);
    DateTime toDate = format.parse(toTime);

    // Calculate time difference
    Duration difference = toDate.difference(fromDate);

    // Calculate hours
    int hours = difference.inHours;

    // Format the result
    String result = '$hours Hours';

    return result;
  }
  String calculateDayDifference(String fromDateStr, String toDateStr) {
    // Parse strings to DateTime objects
    DateFormat formatter = DateFormat('dd/MM/yyyy');
    DateTime fromDate = formatter.parse(fromDateStr);
    DateTime toDate = formatter.parse(toDateStr);

    // Calculate difference between dates
    Duration difference = toDate.difference(fromDate);

    // Calculate days
    int days = difference.inDays;

    // Format the result
    String result = '$days Days';

    return result;
  }


  Widget _buildContentForFilterType() {
    if (_filterType == 'work') {
      return _buildWorkContainer();
    } else if (_filterType == 'days') {
      return _buildDaysContainer();
    } else {
      return _buildHoursContainer();
    }
  }

  Widget _buildHoursContainer() {
    return Container(
      // Your content for hours filter type
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
          snapshot.data!.docs.toList();

          // Filtered list of documents where userId matches user.uid
          final List<QueryDocumentSnapshot<Map<String, dynamic>>> userBookings = filteredDocuments
              .cast<QueryDocumentSnapshot<Map<String, dynamic>>>()
              .where((doc) => doc['workerId'] == user?.uid && doc['type'] == 'hours' && doc['status']=='sent')
              .toList();
          if (userBookings.isEmpty) {
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
          }

          userBookings.sort((a, b) {
            DateTime fromDateTimeA = a['fromDate'].toDate();
            DateTime fromDateTimeB = b['fromDate'].toDate();
            return fromDateTimeA.compareTo(fromDateTimeB);
          });

          return ListView(
            padding: EdgeInsets.zero,
            scrollDirection: Axis.vertical,
            children: userBookings.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

              DateTime fromworkDate = data['fromDate'].toDate();
              DateTime toworkDate = data['toDate'].toDate();


              // Format the dates as desired (dd/mm/yyyy)
              String fromformattedDate = DateFormat('dd/MM/yyyy').format(fromworkDate);
              String fromformattedTime = data['fromTime']; // 24-hour format
              String toformattedTime = data['toTime']; // 24-h
              print(toformattedTime);

              // Return the list item widget
              return  GestureDetector(
                onTap: (){
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  margin: EdgeInsets.only(left: 15, right: 10, top: 5, bottom: 5),
                  padding: EdgeInsets.all(10),
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
                  child: Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                StreamBuilder<DocumentSnapshot>(
                                  stream: FirebaseFirestore.instance.collection('users').doc(data['userId']).snapshots(),
                                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                                    if (userSnapshot.hasError) {
                                      return Text('Something went wrong');
                                    }

                                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    }

                                    Map<String, dynamic> userData = userSnapshot.data!.data() as Map<String, dynamic>;
                                    String imageUrl = userData['image'];
                                    String name = userData['name'];


                                    return Container(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context).size.width*0.15,
                                                height: MediaQuery.of(context).size.width*0.15,
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
                                              SizedBox(width: 10,),
                                              Text(
                                                name,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 19,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 4,),


                                          Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(right: 8.0),
                                                child: Container(
                                                  height: MediaQuery.of(context).size.height * 0.038,
                                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue,
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Center(
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          fromformattedDate,
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
                                                  height: MediaQuery.of(context).size.height * 0.038,
                                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue,
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      data['hours']+" Hours",
                                                      style: TextStyle(fontSize: 15, color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 7,),

                                          Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Text(fromformattedTime),
                                                  SizedBox(width: 5),
                                                  // Add the dashed line here
                                                  Container(
                                                    width: MediaQuery.of(context).size.width*0.45,
                                                    height: 1,
                                                    child: CustomPaint(
                                                      painter: DashedPainter(),
                                                    ),
                                                  ),
                                                  SizedBox(width: 5),
                                                  Text(toformattedTime),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 7,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  // Add your onPressed function here
                                                  APIs.statusbooking(data['id'], "accept");
                                                },
                                                style: ButtonStyle(
                                                  backgroundColor: MaterialStateProperty.all(Colors.white),
                                                  shape: MaterialStateProperty.all(
                                                    RoundedRectangleBorder(
                                                      side: BorderSide(color: Colors.green, width: 2),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.check,
                                                      color: Colors.green,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'Accept',
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: 10,),
                                              ElevatedButton(
                                                onPressed: () {
                                                  APIs.statusbooking(data['id'], "decline");

                                                },
                                                style: ButtonStyle(
                                                  backgroundColor: MaterialStateProperty.all(Colors.white),
                                                  shape: MaterialStateProperty.all(
                                                    RoundedRectangleBorder(
                                                      side: BorderSide(color: Colors.red, width: 2),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.close,
                                                      color: Colors.red,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'Decline',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          )



                                        ],
                                      ),
                                    );
                                  },
                                )
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );// Replace YourListItemWidget with your actual list item widget
            }).whereType<Widget>().toList(), // Filter out null items and convert to List<Widget>
          );

        },
      ),
    );
  }

  Widget _buildWorkContainer() {
    return Container(
      // Your content for hours filter type
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
          snapshot.data!.docs.toList();

          // Filtered list of documents where userId matches user.uid
          final List<QueryDocumentSnapshot<Map<String, dynamic>>> userBookings = filteredDocuments
              .cast<QueryDocumentSnapshot<Map<String, dynamic>>>()
              .where((doc) => doc['workerId'] == user?.uid && doc['type'] == 'work'  && doc['status']=='sent' )
              .toList();


          if (userBookings.isEmpty) {
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
          }

          userBookings.sort((a, b) {
            DateTime fromDateTimeA = a['fromDate'].toDate();
            DateTime fromDateTimeB = b['fromDate'].toDate();
            return fromDateTimeA.compareTo(fromDateTimeB);
          });

          return ListView(
            padding: EdgeInsets.zero,
            scrollDirection: Axis.vertical,
            children: userBookings.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

              DateTime fromworkDate = data['fromDate'].toDate();
              DateTime toworkDate = data['toDate'].toDate();


              String fromformattedDate = DateFormat('dd/MM/yyyy').format(fromworkDate);
              String fromformattedTime = data['fromTime']; // 24-hour format
              String toformattedDate = DateFormat('dd/MM/yyyy').format(toworkDate);
              String toformattedTime = data['toTime']; // 24-h

              // Return the list item widget
              return  GestureDetector(
                onTap: (){

                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  margin: EdgeInsets.only(left: 15, right: 10, top: 5, bottom: 5),
                  padding: EdgeInsets.all(10),
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
                  child: Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                StreamBuilder<DocumentSnapshot>(
                                  stream: FirebaseFirestore.instance.collection('users').doc(data['userId']).snapshots(),
                                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                                    if (userSnapshot.hasError) {
                                      return Text('Something went wrong');
                                    }

                                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    }

                                    Map<String, dynamic> userData = userSnapshot.data!.data() as Map<String, dynamic>;
                                    String imageUrl = userData['image'];
                                    String name = userData['name'];



                                    return Container(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context).size.width*0.15,
                                                height: MediaQuery.of(context).size.width*0.15,
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
                                              SizedBox(width: 10,),
                                              Text(
                                                name,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 19,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 4,),
                                          Container(
                                            width: MediaQuery.of(context).size.width*0.87,
                                            child: Text(data['work'],
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: MediaQuery.of(context).size.width*0.042
                                              ),),

                                          ),
                                          SizedBox(height: 7,),
                                          Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(right: 8.0),
                                                child: Container(
                                                  height: MediaQuery.of(context).size.height * 0.038,
                                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue,
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      fromformattedDate,
                                                      style: TextStyle(fontSize: 15, color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(right: 8.0),
                                                child: Container(
                                                  height: MediaQuery.of(context).size.height * 0.038,
                                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue,
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Center(
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          'Remote',
                                                          style: TextStyle(fontSize: 15, color: Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 7,),

                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                                        ),
                                                        content: Column(
                                                          mainAxisSize: MainAxisSize.min, // Avoid potential overflow
                                                          children: [
                                                            TextField(
                                                              controller: _amountController,
                                                              decoration: const InputDecoration(
                                                                hintText: 'Enter Amount',
                                                              ),
                                                              keyboardType: TextInputType.number, // Set keyboard type for numbers
                                                            ),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                TextButton(
                                                                  onPressed: () => Navigator.pop(context), // Close dialog on Cancel
                                                                  child: const Text('Cancel'),
                                                                ),
                                                                TextButton(
                                                                  onPressed: () {
                                                                    // Handle confirm button press
                                                                    final amountText = _amountController.text;
                                                                    if (amountText.isEmpty) {
                                                                      // Handle empty input (optional)
                                                                      return;
                                                                    }
                                                                    final amount = int.tryParse(amountText) ?? 0;
                                                                    APIs.statusbooking(data['id'], "accept");
                                                                    APIs.AddAmounttoBooking(data['id'],amount);
                                                                    Navigator.pop(context); // Close dialog on Confirm
                                                                  },
                                                                  child: const Text('Confirm'),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        backgroundColor: Colors.white,
                                                      );
                                                    },
                                                  );
                                                  // Add your onPressed function here


                                                },
                                                style: ButtonStyle(
                                                  backgroundColor: MaterialStateProperty.all(Colors.white),
                                                  shape: MaterialStateProperty.all(
                                                    RoundedRectangleBorder(
                                                      side: BorderSide(color: Colors.green, width: 2),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.check,
                                                      color: Colors.green,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'Accept',
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: 10,),
                                              ElevatedButton(
                                                onPressed: () {
                                                  APIs.statusbooking(data['id'], "decline");

                                                },
                                                style: ButtonStyle(
                                                  backgroundColor: MaterialStateProperty.all(Colors.white),
                                                  shape: MaterialStateProperty.all(
                                                    RoundedRectangleBorder(
                                                      side: BorderSide(color: Colors.red, width: 2),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.close,
                                                      color: Colors.red,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'Decline',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          )

                                        ],
                                      ),
                                    );
                                  },
                                )
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );// Replace YourListItemWidget with your actual list item widget
            }).whereType<Widget>().toList(), // Filter out null items and convert to List<Widget>
          );

        },
      ),
    );
  }

  Widget _buildDaysContainer() {
    return Container(
      // Your content for hours filter type
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
          snapshot.data!.docs.toList();

          // Filtered list of documents where userId matches user.uid
          final List<QueryDocumentSnapshot<Map<String, dynamic>>> userBookings = filteredDocuments
              .cast<QueryDocumentSnapshot<Map<String, dynamic>>>()
              .where((doc) => doc['userId'] == user?.uid && doc['type'] == 'days' && (doc['status']=='accept' || doc['status']=='sent'))
              .toList();
          if (userBookings.isEmpty) {
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
          }

          userBookings.sort((a, b) {
            DateTime fromDateTimeA = a['fromDate'].toDate();
            DateTime fromDateTimeB = b['fromDate'].toDate();
            return fromDateTimeA.compareTo(fromDateTimeB);
          });

          return ListView(
            padding: EdgeInsets.zero,
            scrollDirection: Axis.vertical,
            children: userBookings.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

              DateTime fromworkDate = data['fromDate'].toDate();
              DateTime toworkDate = data['toDate'].toDate();
              String status = "Sent";
              bool view = false;
              if (data['status'] == "accept") {
                status = "Accepted";
                view = true;
              } else if (data['status'] == "decline") {
                status = "Rejected";
              }

              // Format the dates as desired (dd/mm/yyyy)
              String fromformattedDate = DateFormat('dd/MM/yyyy').format(fromworkDate);
              String toformattedDate = DateFormat('dd/MM/yyyy').format(toworkDate);

              String difference = calculateDayDifference(fromformattedDate, toformattedDate);

              // Return the list item widget
              return  GestureDetector(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  margin: EdgeInsets.only(left: 15, right: 10, top: 5, bottom: 5),
                  padding: EdgeInsets.all(10),
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
                  child: Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                StreamBuilder<DocumentSnapshot>(
                                  stream: FirebaseFirestore.instance.collection('prof').doc(data['workerId']).snapshots(),
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
                                              SizedBox(width: 10,),
                                              Text(
                                                name,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 19,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Text(fromformattedDate),
                                                  SizedBox(width: 5),
                                                  // Add the dashed line here
                                                  Container(
                                                    width: MediaQuery.of(context).size.width*0.45,
                                                    height: 1,
                                                    child: CustomPaint(
                                                      painter: DashedPainter(),
                                                    ),
                                                  ),
                                                  SizedBox(width: 5),
                                                  Text(toformattedDate),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(right: 8.0),
                                                child: Container(
                                                  height: MediaQuery.of(context).size.height * 0.038,
                                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue,
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      difference,
                                                      style: TextStyle(fontSize: 15, color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(right: 8.0),
                                                child: Container(
                                                  height: MediaQuery.of(context).size.height * 0.038,
                                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue,
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Center(
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          'Remote',
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
                                                  height: MediaQuery.of(context).size.height * 0.038,
                                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue,
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "Fixed",
                                                      style: TextStyle(fontSize: 15, color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10,),
                                          Container(
                                            width: MediaQuery.of(context).size.width*0.87,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Visibility(
                                                      visible:!view,
                                                      child: Container(
                                                        padding: EdgeInsets.all(10),
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.all(Radius.circular(10)),
                                                            border: Border.all(color: Colors.grey.shade300)
                                                        ),
                                                        child: Text(status,
                                                          style: TextStyle(
                                                              color: Colors.pink,
                                                              fontWeight: FontWeight.w500,
                                                              fontSize: 19
                                                          ),),
                                                      ),
                                                    ),

                                                    Visibility(
                                                      visible: view,
                                                      child: GestureDetector(
                                                        onTap: (){
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(builder: (context) => BookingTicket(bookingId: data['id'])),
                                                          );
                                                        },
                                                        child: Container(
                                                          padding: EdgeInsets.all(10),
                                                          decoration: BoxDecoration(
                                                              color: Colors.white,
                                                              borderRadius: BorderRadius.all(Radius.circular(10)),
                                                              border: Border.all(color: Colors.grey.shade300)
                                                          ),
                                                          child: Text("View Booking",
                                                            style: TextStyle(
                                                                color: Colors.pink.shade300,
                                                                fontWeight: FontWeight.w500,
                                                                fontSize: 19
                                                            ),),
                                                        ),
                                                      ),),
                                                  ],
                                                ),
                                                Visibility(
                                                  visible: true,
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      bool success = await APIs.deleteBooking(data['id']);
                                                      if (success) {
                                                        print('Booking deleted successfully');
                                                      } else {
                                                        print('Failed to delete booking');
                                                      }
                                                    },
                                                    child: Container(
                                                      padding: EdgeInsets.all(10),
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: BorderRadius.all(Radius.circular(10)),
                                                          border: Border.all(color: Colors.grey.shade300)
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.cancel,color: Colors.pink.shade300,),
                                                          Text("Cancel",
                                                            style: TextStyle(
                                                                color: Colors.pink.shade300,
                                                                fontWeight: FontWeight.w500,
                                                                fontSize: 19
                                                            ),),
                                                        ],
                                                      ),
                                                    ),
                                                  ),)
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 7,),
                                          Visibility(
                                            visible: !view,
                                            child: Row(
                                              children: [
                                                Image.asset("assets/hourglass.png",height: 40,width: 40,),
                                                const Text("Waiting for the Confirmation",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.w400,fontSize: 17
                                                  ),)
                                              ],
                                            ),
                                          ),

                                        ],
                                      ),
                                    );
                                  },
                                )
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );// Replace YourListItemWidget with your actual list item widget
            }).whereType<Widget>().toList(), // Filter out null items and convert to List<Widget>
          );

        },
      ),
    );
  }
}
class DashedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1 // Adjust thickness of dashed line here
      ..style = PaintingStyle.stroke;

    final double dashWidth = 5;
    final double dashSpace = 5;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}



