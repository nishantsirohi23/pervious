import 'dart:ffi';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:perwork/screens/showall/showallreview.dart';
import 'package:perwork/screens/userbooking.dart';
import 'package:rive/rive.dart';

import '../../../api/apis.dart';
import '../../../models/booking.dart';
import '../profilescreen.dart';




class viewProfileWork extends StatefulWidget {
  final String profid;

  const viewProfileWork({Key? key, required this.profid}) : super(key: key);

  @override
  State<viewProfileWork> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<viewProfileWork> {
  late DocumentSnapshot<Map<String, dynamic>> _profSnapshot;
  bool isLoading = true;
  int lenlist = 0;
  String reviewlist = "0";
  late DateTime selectedDate = DateTime.now();
  late TimeOfDay selectedTime = TimeOfDay.now();

  void _loadUserData() async {
    await APIs.getSelfInfo();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    workFuture = FirebaseFirestore.instance.collection('prof').doc(widget.profid).get();
    _fetchProfDetails();
    _loadUserData();
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
  int _selectedValue = 0;

  List<DropdownMenuItem<int>> _buildDropdownMenuItems() {
    List<DropdownMenuItem<int>> items = [];
    for (int i = 0; i <= 24; i++) {
      items.add(
        DropdownMenuItem(
          value: i,
          child: Text('$i'),
        ),
      );
    }
    return items;
  }




  @override
  Widget build(BuildContext context) {


    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;



    return Scaffold(resizeToAvoidBottomInset: false,
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: workFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return Text('Work not found');
          }

          // Work details
          Map<String, dynamic> workData = snapshot.data!.data()!;
          var listport = workData!.containsKey('portfolio') ? workData['portfolio'] as List<dynamic> : null;
          double screenWidth = MediaQuery.of(context).size.width;
          double screenHeight = MediaQuery.of(context).size.height;
          double? pricePerHour = workData?['price_per_hour']; // Assuming price_per_hour is of type double
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
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Morning!",
                                    style: TextStyle(color: CupertinoColors.white),
                                  ),
                                  Text(
                                    "Nishant Sirohi",
                                    style: TextStyle(color: CupertinoColors.white, fontSize: 20, fontWeight: FontWeight.w600),
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
                                      child: FaIcon(
                                        FontAwesomeIcons.bell, // Adjust icon as needed
                                        size: 20, // Adjust icon size as needed
                                        color: Colors.white, // Adjust icon color as needed
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 13),
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
                                      child: FaIcon(
                                        FontAwesomeIcons.box, // Adjust icon as needed
                                        size: 20, // Adjust icon size as needed
                                        color: Colors.white, // Adjust icon color as needed
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
                        padding: EdgeInsets.all(20.0),
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
                                        padding: EdgeInsets.only(left: 10),
                                        height: MediaQuery.of(context).size.height*0.06,
                                        width: MediaQuery.of(context).size.height*0.06,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey.shade300,

                                            ),
                                            borderRadius: BorderRadius.all(Radius.circular(25))),
                                        child: Center(child: Icon(Icons.arrow_back_ios)),
                                      ),
                                    ),
                                    SizedBox(width: MediaQuery.of(context).size.width*0.05),
                                    CircleAvatar(
                                      radius: MediaQuery.of(context).size.width*0.1, // Adjust the radius as needed
                                      backgroundImage: NetworkImage(workData?['profile_image_url'] ?? ''), // Replace 'your_image.jpg' with your image asset path
                                    ),
                                    SizedBox(width: MediaQuery.of(context).size.width*0.05),

                                    Column(
                                      children: [
                                        Text(
                                          workData?['name'],
                                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 25),
                                        ),
                                        Text(
                                          workData?['username'],
                                          style: TextStyle(color: Colors.black.withOpacity(0.5), fontWeight: FontWeight.w400, fontSize: 21),
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Image.asset(
                                              "assets/linkedin.png",
                                              height: 25,
                                              width: 25,
                                            ),
                                            SizedBox(width: 10),
                                            Image.asset(
                                              "assets/social.png",
                                              height: 25,
                                              width: 25,
                                            ),
                                            SizedBox(width: 10),
                                            Image.asset(
                                              "assets/github.png",
                                              height: 25,
                                              width: 25,
                                            ),
                                            SizedBox(width: 10),
                                            Image.asset(
                                              "assets/instagram.png",
                                              height: 25,
                                              width: 25,
                                            ),
                                          ],
                                        )
                                      ],
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),


                                Text(
                                  "Biography",
                                  style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
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
                                  style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
                                ),
                                SizedBox(height: 7),
                                Container(
                                  height: 25,
                                  width: screenWidth,
                                  margin: EdgeInsets.only(right: 10),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: listspecs.map((spec) {
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 10),
                                          child: Container(
                                            padding: EdgeInsets.only(left: 7,right: 7),
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
                                            "Review",
                                            style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
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
                                                    style: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 17, fontWeight: FontWeight.w400),
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
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          Container(
                                                                            width: 50.0,
                                                                            height: 50.0,
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
                                                                          SizedBox(width: 15),
                                                                          Column(
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              Container(
                                                                                width: screenWidth*0.27,
                                                                                height: screenHeight*0.052,
                                                                                child: Text(
                                                                                  name,
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
                                                                            height: 32,
                                                                            width: 60,
                                                                            decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.all(Radius.circular(20))),
                                                                            child: Row(
                                                                              children: [
                                                                                Image.asset("assets/star.png"),
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
                                              style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "Show All(",
                                                  style: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 17, fontWeight: FontWeight.w400),
                                                ),
                                                Text(
                                                  lenlist.toString()+")",
                                                  style: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 17, fontWeight: FontWeight.w400),
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

            ],
          );
        },
      ),
    );
  }





}
