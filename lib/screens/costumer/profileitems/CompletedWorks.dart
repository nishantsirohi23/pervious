
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:perwork/screens/costumer/showmywork.dart';

import '../../../api/apis.dart';
import '../../../postwork/login.dart';
import '../../../try/chatlist.dart';
import '../../profilescreen.dart';




class CompletedWorks extends StatefulWidget {
  @override
  _UserInformationState createState() => _UserInformationState();
}

class _UserInformationState extends State<CompletedWorks> {
  final Stream<QuerySnapshot> _usersStream =
  FirebaseFirestore.instance.collection('work').snapshots();
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
          title: Text("Completed Works"),
        ),
        body: Column(

          children: [

            StreamBuilder<QuerySnapshot>(
              stream: _usersStream,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading");
                }

                var documents = snapshot.data!.docs.where((document) => document['workBy'] == user.uid && document['status'] == 'completed').toList();


                if (documents.isEmpty) {
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
                } else {
                  return Container(
                    height: screenHeight*0.74,


                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 5),
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> data = documents[index].data()! as Map<String, dynamic>;

                        // Determine background color based on priority
                        Color backgroundColor;
                        switch (data['priority']) {
                          case 'Urgent':
                            backgroundColor = Colors.white;
                            break;
                          case 'High':
                            backgroundColor = Colors.white;
                            break;
                          case 'Normal':
                          default:
                            backgroundColor = Colors.white;
                        }
                        String status = data['status'] ?? '';
                        bool isNego = data['negotiable'] ?? '';
                        String type = "Fixed";
                        if (isNego==true){
                          type = "Negotiable";

                        }
                        String workImage = "";
                        List<Map<String, dynamic>> fileData = (data['fileData'] ?? [])?.cast<Map<String, dynamic>>() ?? [];

                        if (fileData.isEmpty) {
                          workImage = "https://cdn.dribbble.com/userupload/3640939/file/original-669699737952c579e1adf2dfa11652fa.jpeg?resize=2048x1152";
                        } else {
                          for (var file in fileData) {
                            String type = file['type']; // Assuming 'type' holds the file type information
                            if (type == 'jpeg' || type == 'png' || type == 'jpg') {
                              workImage = file['url']; // Assuming 'url' holds the URL of the image
                              break; // Break once the first image is found
                            }
                          }
                        }


// At this point, workImage will either be set to the default URL or the URL of the first image of type jpeg, png, or jpg.
                        double loadwidth = 0.0;
                        if (status=="process"){
                          loadwidth = screenWidth*0.2;
                        }
                        if (status=="track"){
                          loadwidth = screenWidth*0.6;
                        }
                        if (status=="posted"){
                          loadwidth = screenWidth*0.4;
                        }
                        if (status == "paydone") {
                          return SizedBox.shrink(); // Skip rendering the container if status is "paydone"
                        }


                        return GestureDetector(
                          onTap: () {

                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ShowMyWork(workid: data['id'])),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.only(left: 15,right: 10,bottom: 5,top: 5),
                            padding: EdgeInsets.all(10),
                            height: screenHeight*0.22,
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
                                          backgroundImage: NetworkImage(workImage), // Replace 'your_image.jpg' with your image asset path
                                        ),
                                        SizedBox(width: screenWidth*0.02,),
                                        Column(
                                          children: [
                                            SizedBox(
                                              width: screenWidth*0.7,
                                              child: Text(
                                                data['name'],
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
                                        Text("₹"+data['finalamount'].toString(),style: TextStyle(
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
                                                data['prof'],
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
                                                    data['priority'],
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
                                                type,
                                                style: TextStyle(fontSize: 15, color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: screenHeight*0.01,),
                                    Center(
                                      child: Container(
                                        height: 20,
                                        width: screenWidth*0.8,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.white),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Stack(
                                          children: <Widget>[
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),

                                              ),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                width: screenWidth*0.8, // Change this value to change the progress
                                              ),
                                            ),

                                          ],
                                        ),
                                      ),
                                    )



                                  ],
                                )
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            )
          ],
        )
    );
  }
}
