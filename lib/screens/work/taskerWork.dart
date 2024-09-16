import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perwork/screens/work/workerprofile.dart';
import 'package:perwork/screens/work/workihavetodoothers.dart';
import 'package:perwork/screens/work/workihavetodopickup.dart';
import 'package:perwork/taskerdash/deliver.dart';

import '../../api/apis.dart';
import '../../chat/pages/home.dart';
import 'package:badges/badges.dart' as badges;

import '../../try/chatlist.dart';
import '../../try/shownotifications.dart';


class TaskerWork extends StatefulWidget {
  const TaskerWork({Key? key}) : super(key: key);

  @override
  State<TaskerWork> createState() => _TaskerWorkState();
}

class _TaskerWorkState extends State<TaskerWork> {


  @override
  void initState() {
    super.initState();
    getdate();

  }
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
              margin: EdgeInsets.only(top: screenHeight*0.14),
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
                                  height: screenHeight*0.19,
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
                                                radius: screenWidth*0.07, // Adjust the radius as needed
                                                backgroundImage: NetworkImage("https://cdn.dribbble.com/users/620539/screenshots/16497048/media/5529c7155e2de6aae3ae9c39a18df610.png?resize=1600x1200&vertical=center"), // Replace 'your_image.jpg' with your image asset path
                                              ),
                                              SizedBox(width: screenWidth*0.02,),
                                              Column(
                                                children: [
                                                  SizedBox(
                                                    width: screenWidth*0.7,
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
                                              SizedBox(width: screenWidth*0.01,),
                                              Image.asset("assets/rupee.png",height: screenWidth*0.08,width: screenWidth*0.08,),
                                              SizedBox(width: screenWidth*0.01,),
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
                                                  height: screenHeight*0.038,
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
                                                  height: screenHeight*0.038,
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
                                              Padding(
                                                padding: const EdgeInsets.only(right: 8.0),
                                                child: Container(
                                                  height: screenHeight*0.038,
                                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue,
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "asdf",
                                                      style: TextStyle(fontSize: 15, color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          SizedBox(height: screenHeight*0.01,),




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
            )
          ],
        )
    );
  }
}

