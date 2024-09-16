import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:perwork/screens/costumer/ViewWorkContent.dart';
import 'package:perwork/screens/work/workerprofile.dart';
import 'package:perwork/screens/work/workihavetodoothers.dart';
import 'package:perwork/screens/work/workihavetodopickup.dart';
import 'package:perwork/taskerdash/deliver.dart';
import 'package:perwork/taskerdash/fooddeliver.dart';
import 'package:perwork/taskerdash/itemdeliver.dart';
import 'package:shimmer/shimmer.dart';

import '../../api/apis.dart';
import '../../chat/pages/home.dart';
import 'package:badges/badges.dart' as badges;

import '../../try/chatlist.dart';
import '../../try/shownotifications.dart';


class TaskerFood extends StatefulWidget {
  const TaskerFood({Key? key}) : super(key: key);

  @override
  State<TaskerFood> createState() => _TaskerWorkState();
}

class _TaskerWorkState extends State<TaskerFood> {


  @override
  void initState() {
    super.initState();
    getdate();

  }
  String _filterType = 'food'; // Default filter typeFirebaseAuth auth = FirebaseAuth.instance;

  int nnotibooking = 0;
  int nnotiwork = 0;
  int nmessage = 0;

  void getdate() {
    FirebaseFirestore.instance.collection('users').doc(APIs.me.id).snapshots().listen((DocumentSnapshot snapshot) {
      setState(() {

        nmessage = snapshot['nmessage'] ?? 0;

      });
    });
  }




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
                              "Food Work",
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
                margin: EdgeInsets.only(top: screenHeight*0.15),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _filterType = 'food';
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor: _filterType == 'food'
                                ? MaterialStateProperty.all(Colors.blue)
                                : null,
                          ),
                          child: Text('Food', style: TextStyle(color: _filterType == 'food' ? Colors.white : null)),
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
                )
            )
          ],
        )
    );
  }
  Widget _buildContentForFilterType() {
    if (_filterType == 'food') {
      return _buildFoodContainer();
    } else {
      return _buildWorkContainer();
    }
  }
  Widget _buildFoodContainer() {
    return Container(
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
          print(filteredDocuments);
          final List<QueryDocumentSnapshot<Map<String, dynamic>>> userBookings =
          filteredDocuments
              .cast<QueryDocumentSnapshot<Map<String, dynamic>>>()
              .where((doc) =>
          doc['status'] == 'track' &&
              (doc.data().containsKey('assigned') &&
                  (doc['assigned'] == null || doc['assigned'] == APIs.me.id)))
              .toList();


          userBookings.sort((a, b) {
            int aCreatedAt = int.parse(a['createdAt']);
            int bCreatedAt = int.parse(b['createdAt']);
            return bCreatedAt.compareTo(aCreatedAt);
          });
          print(userBookings);
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
                    if (data.containsKey('storename')) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>   ItemDeliver(destlat: data['destlat'],destlong: data['destlong'],sourcelat: data['sourcelat'],sourcelong: data['sourcelong'],workid: document.id,)),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(3),
                          margin: EdgeInsets.only(left: 15, right: 10, top: 5, bottom: 5),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Iterate over the items subcollection
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
                                          imageUrl: "https://firebasestorage.googleapis.com/v0/b/perwork.appspot.com/o/categories%2FUntitled%20design-3.png?alt=media&token=e6cec73f-a9ce-4f75-a329-0c07711d85f3", // URL of the image
                                          width: 50,
                                          height: 50,
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
                                        Text("sdf",maxLines: 2,overflow: TextOverflow.clip,style: TextStyle(fontSize: 17),),

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

                            ],
                          ),
                        ),
                      );
                    }
                    else{
                      List<Map<String, dynamic>> dishesData = (data['dishes'] as List<dynamic>).cast<Map<String, dynamic>>();

                      if(data['status']=="track"){
                        return GestureDetector(
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>   FoodDeliver(destlat: data['destlat'],destlong: data['destlong'],sourcelat: data['sourcelat'],sourcelong: data['sourcelong'],workid: data['id'],)),
                            );
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

                              ],
                            ),

                          ),
                        );
                      }
                      else{
                        return SizedBox();
                      }
                    }
                  },
                ),
              ),
            ],
          )
          ;
        },
      ),
    );
  }

  Widget _buildWorkContainer() {
    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('prof')
            .doc(APIs.me.id)
            .collection('uncompleted')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("No work available. Apply to more works."),
                  Icon(Icons.notifications_none_sharp),
                ],
              ),
            );
          }
          return Container(
            padding: EdgeInsets.all(0),
            child: ListView.builder(
              padding: EdgeInsets.all(0),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot taskDoc = snapshot.data!.docs[index];
                Map<String, dynamic> taskData = taskDoc.data() as Map<String, dynamic>;
                return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    future: FirebaseFirestore.instance.collection('work').doc(taskData['workID']).get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Visibility(visible: false,child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {

                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || !snapshot.data!.exists) {

                        return Text('Work not found');
                      }
                      Map<String, dynamic> workData = snapshot.data!.data()!;

                      return GestureDetector(
                        onTap: (){
                          if(workData['category']=='pickup'){
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => WorkIHaveToDoPickup(workid: workData['id'],destlat: workData["tolatitude"], destlong: workData["tolongitude"], sourcelat: workData["fromlatitude"], sourcelong: workData["fromlongitude"])
                                ));
                          }
                          else{
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => WorkIHaveToDoOther(workid: workData['id'])),
                            );
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 15,right: 10,bottom: 5,top: 5),
                          padding: EdgeInsets.all(10),
                          height: MediaQuery.of(context).size.height*0.19,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(30.0),
                            color: Colors.transparent,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.5),
                                spreadRadius: 3,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [

                                      CircleAvatar(
                                        radius: MediaQuery.of(context).size.width*0.07, // Adjust the radius as needed
                                        backgroundImage: NetworkImage("https://cdn.dribbble.com/users/620539/screenshots/16497048/media/5529c7155e2de6aae3ae9c39a18df610.png?resize=1600x1200&vertical=center"), // Replace 'your_image.jpg' with your image asset path
                                      ),
                                      SizedBox(width: MediaQuery.of(context).size.width*0.02,),
                                      Column(
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context).size.width*0.7,
                                            child: Text(
                                              workData['name'],
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 19
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.clip,
                                              textAlign: TextAlign.start,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 5,),

                                  Row(
                                    children: [
                                      SizedBox(width: MediaQuery.of(context).size.width*0.01,),
                                      Image.asset("assets/rupee.png",height: MediaQuery.of(context).size.width*0.08,width: MediaQuery.of(context).size.width*0.08,),
                                      SizedBox(width: MediaQuery.of(context).size.width*0.01,),
                                      Text("₹"+workData['workeramount'].toString(),style: TextStyle(
                                          color: Colors.black
                                      ),),
                                    ],
                                  ),
                                  SizedBox(height: 5,),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: Container(
                                          height: MediaQuery.of(context).size.height*0.038,
                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Center(
                                            child: Text(
                                              workData['prof'],
                                              style: TextStyle(fontSize: 15, color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: Container(
                                          height: MediaQuery.of(context).size.height*0.038,
                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Center(
                                            child: Row(
                                              children: [

                                                Text(
                                                  workData['priority'],
                                                  style: TextStyle(fontSize: 15, color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: MediaQuery.of(context).size.height*0.01,),




                                ],
                              )
                          ),
                        ),
                      );
                    }
                );
              },
            ),
          );
        },
      ),
    );
  }
}

