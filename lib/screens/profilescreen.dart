import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:io' show Platform;

import 'package:perwork/screens/costumer/profileitems/CompletedBookings.dart';
import 'package:perwork/screens/costumer/profileitems/CompletedWorks.dart';
import 'package:perwork/screens/costumer/profileitems/MyReview.dart';
import 'package:perwork/screens/super/super1.dart';

import '../api/apis.dart';
import '../models/chat_user.dart';
import '../onboarding/OnboardingScreen.dart';
import '../taskerdash/workapplications.dart';
import '../try/FrequentQuestion.dart';
import '../try/chatlist.dart';
import '../try/profile_menu.dart';
import '../try/profiledash.dart';
import 'costumer/UserAllWork.dart';
import 'costumer/profileitems/Completedfood.dart';
import 'costumer/profileitems/editfrommain.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => OnboardingScreen()), // Replace LoginScreen with your actual login screen widget
          (Route<dynamic> route) => false,
    );
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
  int bookingCount = 0;

  @override
  void initState() {
    super.initState();
    _getBookingCount();
  }
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> deleteAccount() async {
    try {
      // Step 1: Delete user account from Firebase Authentication
      final currentUser = FirebaseAuth.instance.currentUser;
      await currentUser?.delete();

      // Step 2: Remove user data from Firestore
      final userUid = currentUser?.uid;
      if (userUid != null) {
        // Delete user document from Firestore
        await FirebaseFirestore.instance.collection('users').doc(userUid).delete();
      }
      _signOut(context);
      // Account deletion successful
      print('Account deleted successfully.');
    } catch (e) {
      // Handle any errors that occur during account deletion
      print('Error deleting account: $e');
    }
  }

  Future<void> _getBookingCount() async {
    // Get the reference to the user's document
    DocumentReference userRef = _firestore.collection('users').doc(APIs.me.id);

    // Get the reference to the "booking" subcollection
    CollectionReference bookingRef = userRef.collection('booking');

    // Get the snapshots of documents in the "booking" subcollection
    QuerySnapshot bookingSnapshot = await bookingRef.get();

    // Filter documents where status is "accept" or "sent"
    List<QueryDocumentSnapshot> acceptedAndSentBookings = bookingSnapshot.docs.where((doc) {
      String status = doc['status'];
      return status == 'accept' || status == 'sent';
    }).toList();

    // Get the count of filtered documents
    int count = acceptedAndSentBookings.length;

    // Update the state with the count
    setState(() {
      bookingCount = count;
    });

    print(bookingCount);
  }



  @override
  Widget build(BuildContext context) {
    bool isLoading = true;
    bool addmobile = false;
    if(APIs.me.mobile==""){
      addmobile= true;
    }


    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
              height: screenHeight * 0.20,
              decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/backappbar1.png"),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25))),
              child: Container(
                child: Stack(

                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 20, top: screenHeight*0.005),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: (){
                                      Navigator.pop(context);
                                    },
                                    child: Icon(Icons.arrow_back_ios,color: Colors.white,),
                                  ),
                                  SizedBox(width: 10,),

                                  CircleAvatar(
                                    radius: screenHeight*0.03, // adjust the radius as needed
                                    backgroundImage: NetworkImage(APIs.me.image), // replace URL with your image URL
                                  ),
                                  SizedBox(width: 10,),

                                  Container(
                                    width: screenWidth*0.65,
                                    child:  Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [

                                        Text(
                                          APIs.me.name,
                                          style: TextStyle(color: CupertinoColors.white, fontSize: 18, fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          maxLines: 1,
                                          overflow: TextOverflow.clip,
                                          APIs.me.email,
                                          style: TextStyle(color: CupertinoColors.white, fontSize: 16, fontWeight: FontWeight.w400),
                                        ),
                                        Visibility(
                                          visible: !addmobile,
                                          child: Text(

                                            APIs.me.mobile,
                                            style: TextStyle(color: CupertinoColors.white, fontSize: 20, fontWeight: FontWeight.w400),
                                          ),),
                                        GestureDetector(
                                          onTap: (){
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) =>   EditProfileScreenMain()),
                                            )     ;
                                          },
                                          child: Visibility(
                                            visible: addmobile,
                                            child: Text(
                                              "Edit Profile",
                                              style: TextStyle(color: Colors.pink, fontSize: 19, fontWeight: FontWeight.w500),
                                            ),),
                                        )


                                      ],
                                    ),
                                  )
                                ],
                              ),

                            ],
                          )
                        ],
                      ),
                    ),
                    Positioned(
                        bottom: 0,
                        child: GestureDetector(
                          onTap: (){
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (BuildContext context) {
                                return  Container(
                                  height: 170,
                                  child: Container(
                                    padding: EdgeInsets.all(20.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Reward Points System',
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 10.0),
                                        Row(
                                          children: [
                                            Image.asset("assets/reward.png",height: 30,width: 30,),
                                            Text(
                                              '1 Review = 100 Super Points',
                                              style: TextStyle(
                                                fontSize: 16.0,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4,),
                                        Row(
                                          children: [
                                            Image.asset("assets/super.png",height: 30,width: 30,),
                                            Container(
                                              width: MediaQuery.of(context).size.width*0.7,
                                              child: Text(
                                                '100 Super Points = ₹1 off on buying Super Genie',
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                            width: screenWidth,
                            height: 40,
                            decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25))
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset("assets/reward.png",height: 30,width: 30,),
                                SizedBox(width: 15,),
                                Text("Super Points : "+APIs.me.points.toString(),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18
                                  ),)
                              ],
                            ),
                          ),
                        )
                    )
                  ],
                ),
              )
          ),
          Container(
            margin: EdgeInsets.only(top: screenHeight*0.20),
            width: screenWidth,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 10,),

                  Visibility(
                    visible: !APIs.me.havepremium && Platform.isAndroid,
                    child: GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>   SuperScreen1()),
                        );
                      },
                      child: Container(
                        width: screenWidth,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0), // Add border radius
                          image: DecorationImage(
                            image: AssetImage('assets/superback.png'), // Replace 'assets/background_image.jpg' with your image path
                            fit: BoxFit.cover, // Adjust the fit of the image within the container
                          ),
                        ),
                        margin: const EdgeInsets.only(left: 15,right: 15),

                        padding: const EdgeInsets.only(left: 15,right: 15,top: 10,bottom: 10),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.asset("assets/super.png",height: 30,width: 30,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Get Super Genie",style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: screenHeight*0.023
                                  ),),
                                  Container(
                                    width: screenWidth*0.6,
                                    child:  Text("Super powers, extra off and more",style: TextStyle(
                                        color: Colors.black.withOpacity(0.8),
                                        fontSize: screenHeight*0.017
                                    ),),
                                  ),
                                  Row(
                                    children: [
                                      Text("Learn More",style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                          fontSize: screenHeight*0.02
                                      ),),
                                      Icon(Icons.arrow_right_outlined,color: Colors.pink,)
                                    ],
                                  )
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.pink, width: 1.3), // Pink border
                                  borderRadius: BorderRadius.circular(10.0), // Border radius
                                  color: Colors.transparent, // Transparent background
                                ),
                                width: screenWidth*0.12, // Adjust width as needed
                                height: 32, // Adjust height as needed
                                child: Center(
                                  child: Text(
                                    'BUY',
                                    style: TextStyle(
                                        color: Colors.pink, // Text color
                                        fontWeight: FontWeight.w500 // Adjust font weight as needed
                                    ),
                                  ),
                                ),
                              )


                            ]
                        ),
                      ),
                    ),),
                  SizedBox(height: 10,),
                  EventMainPage(bookingCount: bookingCount,),
                  SizedBox(height: 24),
                  ProfileMenu(
                    text: "Help Center",
                    icon: "assets/star.png",
                    press: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>   FrequentQuestionScreen()),
                      )
                    },
                  ),
                  ProfileMenu(
                    text: "Completed Bookings",
                    icon: "assets/booking.png",
                    press: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>   CompletedBooking()),
                      )
                    },
                  ),
                  ProfileMenu(
                    text: "Completed Works",
                    icon: "assets/works.png",
                    press: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>   CompletedWorks()),
                      )
                    },
                  ),
                  ProfileMenu(
                    text: "Completed Food Orders",
                    icon: "assets/food.png",
                    press: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>   CompletedFood()),
                      )
                    },
                  ),
                  ProfileMenu(
                    text: "Messages",
                    icon: "assets/messages.png",
                    press: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>   ChatList()),
                      )
                    },
                  ),
                  ProfileMenu(
                    text: "My Reviews",
                    icon: "assets/star.png",
                    press: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>   MyReview()),
                      )
                    },
                  ),
                  Visibility(
                    visible: APIs.me.havepremium,
                    child:  ProfileMenu(
                      text: "Super Genie",
                      icon: "assets/super.png",
                      press: () => {
                        showSuperGenieDetailsDialog(context)
                      },
                    ),),
                  ProfileMenu(
                    text: "Log Out",
                    icon: "assets/logout.png",
                    press: () => {
                      _signOut(context)
                    },
                  ),
                  ProfileMenu(
                    text: "Delete Account",
                    icon: "assets/logout.png",
                    press: () => {
                      deleteAccount()
                    },
                  ),
                  SizedBox(height: 20,)





                ],
              ),
            ),

          )
        ],
      ),
    );
  }
  void showSuperGenieDetailsDialog(BuildContext context) {
    String formattedDate = DateFormat('d MMMM yyyy', 'en_US').format(APIs.me.superEndDate);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Super Genie Details'),
          content: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Plan: ${APIs.me.months}'+ ' Months',style: TextStyle(color: Colors.black87,fontSize: 16),),
                Text('Plan ends on: $formattedDate',style: TextStyle(color: Colors.black87,fontSize: 16),),
                Text('Days Left: ${_calculateDaysLeft(APIs.me.superEndDate)}',style: TextStyle(color: Colors.black87,fontSize: 16),),
              ],
            ),
          ),
          actions: [

            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Function to calculate the number of days until a date
  int _calculateDaysLeft(DateTime endDate) {
    DateTime today = DateTime.now();
    Duration difference = endDate.difference(today);
    return difference.inDays;
  }
}

