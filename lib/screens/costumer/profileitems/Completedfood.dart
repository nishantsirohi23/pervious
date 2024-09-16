
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:perwork/screens/costumer/ViewWorkContent.dart';
import 'package:perwork/screens/costumer/showmywork.dart';
import 'package:shimmer/shimmer.dart';

import '../../../api/apis.dart';
import '../../../postwork/login.dart';
import '../../../try/chatlist.dart';
import '../../addreview.dart';
import '../../profilescreen.dart';




class CompletedFood extends StatefulWidget {
  @override
  _UserInformationState createState() => _UserInformationState();
}

class _UserInformationState extends State<CompletedFood> {
  final Stream<QuerySnapshot> _foodStream =
  FirebaseFirestore.instance.collection('orders').snapshots();
  static FirebaseAuth auth = FirebaseAuth.instance;
  static User get user => auth.currentUser!;
  bool isLoading = false;


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Completed Food"),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _foodStream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Container();
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return  Container(
                height: MediaQuery.of(context).size.height*0.86,
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
              );
            }

            // Filter documents based on search term
            final List<QueryDocumentSnapshot> filteredDocuments =
            snapshot.data!.docs.toList();

            // Filtered list of documents where userId matches user.uid
            final List<QueryDocumentSnapshot<Map<String, dynamic>>> userBookings = filteredDocuments
                .cast<QueryDocumentSnapshot<Map<String, dynamic>>>()
                .where((doc) => doc['orderBy'] == APIs.me.id  && doc['status']=="completed")
                .toList();
            // Sort the user bookings based on the 'createdAt' field
            userBookings.sort((a, b) {
              // Convert 'createdAt' field from string to integer
              int aCreatedAt = int.parse(a['createdAt']);
              int bCreatedAt = int.parse(b['createdAt']);
              // Compare the integers to sort in descending order
              return bCreatedAt.compareTo(aCreatedAt);
            });

            if (userBookings.isEmpty) {
              return Center(
                child: Container(


                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Lottie.asset('assets/lottie/empty.json'),

                    ],
                  ),
                ),
              );
            }



            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 10),
                    scrollDirection: Axis.vertical,
                    itemCount: userBookings.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = userBookings[index];
                      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                      List<Map<String, dynamic>> dishesData = (data['dishes'] as List<dynamic>).cast<Map<String, dynamic>>();

                      return GestureDetector(
                        onTap: (){

                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 15, right: 10, top: 5, bottom: 5), // Adjust margins here
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
                          child: Column(
                            children: [
                              Container(
                                height: 60,
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                      ),
                                      margin: EdgeInsets.only(right: 12),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                        child: CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          imageUrl: data['restimage'], // URL of the image
                                          width: 60,
                                          height: 60,
                                          placeholder: (context, url) => Shimmer.fromColors(
                                            baseColor: Colors.grey[200]!,
                                            highlightColor: Colors.grey[100]!,
                                            child: Container(
                                              width: 84,
                                              height: 60,
                                              color: Colors.white,
                                            ),
                                          ),
                                          errorWidget: (context, url, error) => Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                    Expanded(child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(data['restname'],maxLines: 1,overflow: TextOverflow.clip,style: TextStyle(fontSize: 17),),
                                        Text(data['restaddress'],maxLines: 1,overflow: TextOverflow.clip,style: TextStyle(fontSize: 16),)
                                      ],
                                    ),),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.asset('assets/rupee.png',height: 25,width: 25,),
                                        Text("₹"+data['orderamount'].toString())
                                      ],
                                    ),
                                    SizedBox(width: 20,)
                                  ],
                                ),
                              ),
                              SizedBox(height: 6,),
                              DashedLine(height: 1, color: Colors.grey),
                              Container(
                                padding: EdgeInsets.only(top: 4),
                                height:dishesData.length*35,
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: dishesData.length,
                                  itemBuilder: (context, index) {
                                    final dish = dishesData[index];
                                    return Container(
                                      child: Row(
                                        children: [
                                          Image.network(
                                            dish['image'],
                                            width: 30,
                                            height: 30,
                                            fit: BoxFit.cover,
                                          ),
                                          SizedBox(width: 5),
                                          Text(dish['quantity'].toString()+" x "),
                                          Expanded(
                                            child: Text(
                                              dish['name'],
                                              maxLines: 1,
                                              overflow: TextOverflow.clip,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Visibility(
                                  visible: !data['reviewdone'],
                                  child:GestureDetector(
                                    onTap: (){
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => AddReviewScreen(profId: data['assigned'],type: "food",firebaseid: data['id'],) ),
                                      );
                                    },
                                    child: Container(
                                      height: 70,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          top: BorderSide(width: 1.0, color: Colors.grey.shade300), // Adjust width and color as needed
                                        ),
                                        color: Colors.white,
                                      ),
                                      padding: EdgeInsets.all(8),
                                      margin: EdgeInsets.only(bottom: 15),
                                      width: MediaQuery.of(context).size.width,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Image.asset("assets/star.png",height: 25,width: 25,),
                                              SizedBox(width: 11,),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("Rate Worker",
                                                    style: TextStyle(
                                                      fontSize: 17,
                                                      fontWeight: FontWeight.w400,
                                                    ),),
                                                  RatingBar.builder(
                                                    itemSize: 20,
                                                    initialRating: 5,
                                                    minRating: 1,
                                                    direction: Axis.horizontal,
                                                    allowHalfRating: true,
                                                    itemCount: 5,
                                                    itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                                                    itemBuilder: (context, _) => Icon(
                                                      Icons.star,
                                                      color: Colors.amber,
                                                      size: 1,
                                                    ),
                                                    onRatingUpdate: (rating) {
                                                      setState(() {

                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Container(
                                            alignment: Alignment.centerRight,
                                            height: 46,
                                            padding: EdgeInsets.only(left: 7,right: 7),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                                border: Border.all(color: Colors.grey.shade300,width: 1)
                                            ),
                                            child: Column(
                                              children: [
                                                Text("Get 100"),
                                                Text("Points")
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                              )
                            ],
                          ),

                        ),
                      );
                    },
                  ),
                ),
              ],
            );


          },
        )
    );
  }
}
