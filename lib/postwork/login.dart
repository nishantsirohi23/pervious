import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:perwork/screens/BookingTicket.dart';
import 'package:perwork/screens/tasker/showrequests.darrt.dart';

import '../api/apis.dart';

class UserBooking extends StatefulWidget {
  const UserBooking({Key? key}) : super(key: key);

  @override
  State<UserBooking> createState() => _UserBookingState();
}

class _UserBookingState extends State<UserBooking> {
  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    User user = auth.currentUser!;
    // Stream of data from Firestore
    final Stream<QuerySnapshot> _usersStream =
    FirebaseFirestore.instance.collection('bookings').snapshots();

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text("My booking "),),
      body: Container(
        height: screenHeight*0.95,
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
            snapshot.data!.docs.toList();

            // Filtered list of documents where userId matches user.uid
            final List<QueryDocumentSnapshot> userBookings = filteredDocuments.where((doc) => doc['userId'] == user.uid).toList();

            if (userBookings.isEmpty) {
              return Center(
                child: Container(
                  margin: EdgeInsets.only(top: screenHeight*0.11),


                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Image.asset("assets/empty-cart.png"),
                      SizedBox(height: 0.05,),
                      Text("No Bookings found",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 21,
                            fontWeight: FontWeight.w400
                        ),)
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
                  child: Container(
                    width: screenWidth * 0.9,
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
                                                      width: screenWidth*0.45,
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
                                            Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(fromformattedTime),
                                                    SizedBox(width: 5),
                                                    // Add the dashed line here
                                                    Container(
                                                      width: screenWidth*0.45,
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
                                            Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 8.0),
                                                  child: Container(
                                                    height: screenHeight * 0.038,
                                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue,
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        "8 hours",
                                                        style: TextStyle(fontSize: 15, color: Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 8.0),
                                                  child: Container(
                                                    height: screenHeight * 0.038,
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
                                                    height: screenHeight * 0.038,
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
                                            Row(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                                      border: Border.all(color: Colors.pink)
                                                  ),
                                                  child: Text(status,
                                                    style: TextStyle(
                                                        color: Colors.pink,
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 19
                                                    ),),
                                                ),
                                                SizedBox(width: screenWidth*0.2,),
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
                                                  ),)],
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
        )
        ,
      ),
    );
  }



}
