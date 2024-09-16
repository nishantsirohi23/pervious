
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:perwork/screens/costumer/showmywork.dart';
import 'package:shimmer/shimmer.dart';

import '../../../api/apis.dart';
import '../../../postwork/login.dart';
import '../../../try/chatlist.dart';
import '../tasker/showwork.dart';




class FoodIhaveDone extends StatefulWidget {
  @override
  _UserInformationState createState() => _UserInformationState();
}

class _UserInformationState extends State<FoodIhaveDone> {
  final Stream<QuerySnapshot> _usersStream =
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
        body: Column(

          children: [

            Container(
              // Your content for hours filter type
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('orders').snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Container();
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      height: MediaQuery.of(context).size.height * 0.86,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.black.withOpacity(0),
                          child: Center(
                            child: Lottie.asset("assets/lottie/loading.json"),
                          ),
                        ),
                      ),
                    );
                  }

                  final List<QueryDocumentSnapshot> filteredDocuments =
                  snapshot.data!.docs.toList();

                  final List<QueryDocumentSnapshot<Map<String, dynamic>>> userBookings =
                  filteredDocuments
                      .cast<QueryDocumentSnapshot<Map<String, dynamic>>>()
                      .where((doc) => doc['status'] == 'completed' && doc['assigned']==APIs.me.id) // Filter where status is "preparing"
                      .toList();

                  userBookings.sort((a, b) {
                    int aCreatedAt = int.parse(a['createdAt']);
                    int bCreatedAt = int.parse(b['createdAt']);
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

                  // Render your UI based on userBookings
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
                            if(data['status']=="preparing"){
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
                                      Container(
                                        margin: EdgeInsets.only(left: 20,right: 20),
                                        child:  Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            GestureDetector(
                                              onTap: (){
                                                APIs.acceptfoodorder(data['id']);
                                              },
                                              child: Container(
                                                height: 44,
                                                width: 150,
                                                decoration: BoxDecoration(
                                                    color: Colors.pink,
                                                    border: Border.all(color: Colors.grey.shade300),
                                                    borderRadius: BorderRadius.circular(15)
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Text("+ Accept",style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 19,
                                                        fontWeight: FontWeight.w500
                                                    ),)
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(
                                              height: 44,
                                              width: 150,
                                              decoration: BoxDecoration(
                                                  color: Colors.pink,
                                                  border: Border.all(color: Colors.grey.shade300),
                                                  borderRadius: BorderRadius.circular(15)
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text(data['distance'].toString()+" kms",style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 19,
                                                      fontWeight: FontWeight.w500
                                                  ),)
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 10,)
                                    ],
                                  ),

                                ),
                              );
                            }
                            else{
                              return SizedBox();
                            }
                          },
                        ),
                      ),
                    ],
                  )
                  ;
                },
              )
              ,
            )
          ],
        )
    );
  }
}
class DashedLine extends StatelessWidget {
  final double height;
  final Color color;

  const DashedLine({Key? key, this.height = 1, this.color = Colors.black}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: _DashedLinePainter(color),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;

  _DashedLinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    final double dashWidth = 5;
    final double dashSpace = 5;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
