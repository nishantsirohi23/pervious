import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:perwork/api/apis.dart';
import 'package:perwork/screens/tasker/showrequests.darrt.dart';
import 'package:shimmer/shimmer.dart';

import '../onboding/components/custom_sign_in_dialog.dart';
import 'BookingTicket.dart';

class UserBooking extends StatefulWidget {
  const UserBooking({Key? key}) : super(key: key);

  @override
  State<UserBooking> createState() => _UserBookingState();
}

class _UserBookingState extends State<UserBooking> {
  String _filterType = 'hours'; // Default filter typeFirebaseAuth auth = FirebaseAuth.instance;
  final Stream<QuerySnapshot> _usersStream =
  FirebaseFirestore.instance.collection('bookings').snapshots();


  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    User user = auth.currentUser!;
    // Stream of data from Firestore


    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("My Booking"),
      ),
      body: Column(
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
    );
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
              .where((doc) => doc['userId'] == user?.uid && doc['type'] == 'hours' && (doc['status']=='accept' || doc['status']=='sent'))
              .toList();
          // Sort the user bookings based on the 'createdAt' field


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
            DateTime fromDateTimeA = DateTime.fromMillisecondsSinceEpoch(int.parse(a['created_at']));
            DateTime fromDateTimeB = DateTime.fromMillisecondsSinceEpoch(int.parse(b['created_at']));
            return fromDateTimeB.compareTo(fromDateTimeA); // Reverse the comparison
          });


          return ListView(
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
              String fromformattedTime = data['fromTime']; // 24-hour format
              String toformattedTime = data['toTime']; // 24-h
              print(toformattedTime);

              // Return the list item widget
              return  GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>   BookingTicket(bookingId: data['id'])),
                  )       ;         },
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
                                    double amount = userData['price_per_hour'];


                                    return Container(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.all(Radius.circular(35)),
                                                child: CachedNetworkImage(
                                                  fit: BoxFit.cover,
                                                  imageUrl: imageUrl, // URL of the image
                                                  width: MediaQuery.of(context).size.width*0.15, // Double the radius to fit the CircleAvatar
                                                  height: MediaQuery.of(context).size.width*0.15, // Double the radius to fit the CircleAvatar
                                                  placeholder: (context, url) => Shimmer.fromColors(
                                                    baseColor: Colors.grey[300]!,
                                                    highlightColor: Colors.grey[100]!,
                                                    child: Container(
                                                      width: MediaQuery.of(context).size.width*0.15, // Double the radius to fit the CircleAvatar
                                                      height: MediaQuery.of(context).size.width*0.15, // Double the radius to fit the CircleAvatar
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  errorWidget: (context, url, error) => Icon(Icons.error),
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
                                                      amount.toString()+"/hr",
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

                                          Visibility(
                                            visible: !view,
                                            child: Row(
                                              children: [
                                                Image.asset("assets/hourglass.png",height: 32,width: 32,),
                                                SizedBox(width: 7,),
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
              .where((doc) => doc['userId'] == user?.uid && doc['type'] == 'work' && (doc['status']=='accept' || doc['status']=='sent'))
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
            DateTime fromDateTimeA = DateTime.fromMillisecondsSinceEpoch(int.parse(a['created_at']));
            DateTime fromDateTimeB = DateTime.fromMillisecondsSinceEpoch(int.parse(b['created_at']));
            return fromDateTimeB.compareTo(fromDateTimeA); // Reverse the comparison
          });


          return ListView(
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
              String fromformattedTime = data['fromTime']; // 24-hour format
              String toformattedDate = DateFormat('dd/MM/yyyy').format(toworkDate);
              String toformattedTime = data['toTime']; // 24-h

              // Return the list item widget
              return  GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>   BookingTicket(bookingId: data['id'])),
                  )       ;
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
                                    double amount = userData['price_per_hour'];



                                    return Container(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.all(Radius.circular(35)),
                                                child: CachedNetworkImage(
                                                  fit: BoxFit.cover,
                                                  imageUrl: imageUrl, // URL of the image
                                                  width: MediaQuery.of(context).size.width*0.15, // Double the radius to fit the CircleAvatar
                                                  height: MediaQuery.of(context).size.width*0.15, // Double the radius to fit the CircleAvatar
                                                  placeholder: (context, url) => Shimmer.fromColors(
                                                    baseColor: Colors.grey[300]!,
                                                    highlightColor: Colors.grey[100]!,
                                                    child: Container(
                                                      width: MediaQuery.of(context).size.width*0.15, // Double the radius to fit the CircleAvatar
                                                      height: MediaQuery.of(context).size.width*0.15, // Double the radius to fit the CircleAvatar
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  errorWidget: (context, url, error) => Icon(Icons.error),
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
                                                    child: Text(
                                                      amount.toString()+"/hr",
                                                      style: TextStyle(fontSize: 15, color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 7,),

                                          Visibility(
                                            visible: !view,
                                            child: Row(
                                              children: [
                                                Image.asset("assets/hourglass.png",height: 32,width: 32,),
                                                SizedBox(width: 7,),
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
            DateTime fromDateTimeA = DateTime.fromMillisecondsSinceEpoch(int.parse(a['created_at']));
            DateTime fromDateTimeB = DateTime.fromMillisecondsSinceEpoch(int.parse(b['created_at']));
            return fromDateTimeB.compareTo(fromDateTimeA); // Reverse the comparison
          });


          return ListView(
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
                                                      data['hours'],
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


