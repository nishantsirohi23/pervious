import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screens/tasker/showwork.dart';

class WorkApplications extends StatefulWidget {
  const WorkApplications({Key? key}) : super(key: key);

  @override
  State<WorkApplications> createState() => _WorkApplicationsState();
}

class _WorkApplicationsState extends State<WorkApplications> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    FirebaseAuth auth = FirebaseAuth.instance;
    User user = auth.currentUser!;
    return Scaffold(
      appBar: AppBar(title: Text("Work Applications"),),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('prof').doc(user.uid).collection('workIDs').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          final List<String> workIDs = snapshot.data!.docs.map((doc) => doc['workID'] as String).toList();
          final List<String> status = snapshot.data!.docs.map((doc) => doc['status'] as String).toList();


          return ListView.builder(
            itemCount: workIDs.length,
            itemBuilder: (context, index) {
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('work').doc(workIDs[index]).snapshots(),
                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> workSnapshot) {
                  if (workSnapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (workSnapshot.connectionState == ConnectionState.waiting) {
                    return Text("Loading");
                  }

                  if (!workSnapshot.hasData || !workSnapshot.data!.exists) {
                    return Text('Work not found');
                  }

                  final workData = workSnapshot.data!.data() as Map<String, dynamic>;
                  Color borderColor = Colors.orangeAccent;
                  Color color = Colors.orangeAccent.shade100;
                  if(status[index]=="accepted"){
                    borderColor = Colors.green;
                    color = Colors.green.shade100;
                  }
                  if(status[index]=="rejected"){
                    borderColor = Colors.red;
                    color = Colors.red.shade100;
                  }
                  // Here you can create a widget to display the details of the workData
                  return GestureDetector(
                    onTap: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ShowWork(workid: workData['id'])),
                      );
                    },
                    child: Container(
                      width: screenWidth*0.9,
                      margin: EdgeInsets.only(left: 15,right: 10,top: 5,bottom: 5),
                      padding: EdgeInsets.all(10),
                      height: screenHeight*0.3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
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
                                  CircleAvatar(
                                    radius: 30, // Adjust the radius as needed
                                    backgroundImage: NetworkImage("https://cdn.dribbble.com/userupload/13080831/file/original-a89cc68c06feabb57b332790a356435b.png?resize=1504x1127"), // Replace 'your_image.jpg' with your image asset path
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
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined),
                                  Text("Meerut, UP"),

                                ],
                              ),
                              Row(
                                children: [
                                  Image.asset("assets/rupee.png",height: 50,width: 50,),
                                  Text(workData['amount'].toString()),
                                ],
                              ),
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

                                ],
                              ),
                              SizedBox(height: 10,),
                              Container(
                                width: 150,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10), // Adjust border radius as needed
                                  border: Border.all(
                                    color: borderColor, // Dark yellow border color
                                  ),
                                  color: color, // Light yellow background color
                                ),
                                child: Center(
                                  child: Text(
                                    status[index],
                                    style: TextStyle(
                                      color: Colors.black, // Text color
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )


                            ],
                          )
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
