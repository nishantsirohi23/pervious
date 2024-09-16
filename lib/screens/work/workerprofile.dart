import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:perwork/screens/costumer/profileitems/CompletedBookings.dart';
import 'package:perwork/screens/costumer/profileitems/CompletedWorks.dart';
import 'package:perwork/screens/costumer/profileitems/MyReview.dart';
import 'package:perwork/screens/tasker/showrequests.darrt.dart';
import 'package:perwork/screens/work/bookingihavedone.dart';
import 'package:perwork/screens/work/workihavedone.dart';

import '../../api/apis.dart';
import '../../onboarding/OnboardingScreen.dart';
import '../../taskerdash/workapplications.dart';
import '../../try/chatlist.dart';
import '../../try/profile_menu.dart';
import '../../try/profiledash.dart';
import '../../try/taskerprofiledash.dart';
import '../costumer/profileitems/editfrommain.dart';
import '../tasker/MyReview.dart';
import 'addbankaccount.dart';
import 'foodihvaedone.dart';



class WorkerProfileScreen extends StatefulWidget {
  const WorkerProfileScreen({Key? key}) : super(key: key);

  @override
  State<WorkerProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<WorkerProfileScreen> {
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


  Future<void> _getBookingCount() async {
    // Get the reference to the user's document
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Reference to the "bookings" collection
    CollectionReference bookingsCollection = firestore.collection('bookings');

    // Query to get documents where status is 'accept'
    QuerySnapshot querySnapshot =
    await bookingsCollection.where('status', isEqualTo: 'accept').get();

    // Return the count of documents matching the query
    // Get the count of filtered documents
    int count =      querySnapshot.docs.length;

    // Update the state with the count
    setState(() {
      bookingCount = count;
    });

    print(bookingCount);
  }



  @override
  Widget build(BuildContext context) {
    bool isLoading = true;

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
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
              margin: EdgeInsets.only(left: 20, right: 20, top: screenHeight*0.02),
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
                              Text(
                                APIs.me.name,
                                style: TextStyle(color: CupertinoColors.white, fontSize: 20, fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>   EditProfileScreenMain()),
                              )     ;                       },
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
                                child: FaIcon(
                                  FontAwesomeIcons.edit, // Adjust icon as needed
                                  size: 20, // Adjust icon size as needed
                                  color: Colors.white, // Adjust icon color as needed
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 13),


                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: screenHeight*0.14),
            width: screenWidth,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  SizedBox(height: 10,),


                  TaskerEventMainPage(bookingCount: bookingCount),
                  SizedBox(height: 24),
                  ProfileMenu(
                    text: "Completed Works",
                    icon: "assets/works.png",
                    press: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>   WorkIHaveDone()),
                      )
                    },
                  ),
                  Visibility(
                    visible: APIs.me.type=="delivery",
                    child: ProfileMenu(
                      text: "Completed Food",
                      icon: "assets/food.png",
                      press: () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>   FoodIhaveDone()),
                        )
                      },
                    ),),
                  ProfileMenu(
                    text: "Completed Bookings",
                    icon: "assets/booking.png",
                    press: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>   BookingIHaveDone()),
                      )
                    },
                  ),

                  ProfileMenu(
                    text: "Bank Account",
                    icon: "assets/payment.png",
                    press: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>   BankDetailsPage()),
                      )
                    },
                  ),
                  ProfileMenu(
                    text: "Work Applications",
                    icon: "assets/works.png",
                    press: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>   WorkApplications()),
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
                    text: "My Review",
                    icon: "assets/star.png",
                    press: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>   TaskerMyReview()),
                      )
                    },
                  ),


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
}
