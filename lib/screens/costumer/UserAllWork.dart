import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';

class UserAllWork extends StatefulWidget {
  const UserAllWork({Key? key}) : super(key: key);

  @override
  State<UserAllWork> createState() => _UserAllWorkState();
}

class _UserAllWorkState extends State<UserAllWork> {
  late Stream<QuerySnapshot> userWorkStream;

  @override
  void initState() {
    super.initState();
    getUserWorkStream();
  }

  void getUserWorkStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      userWorkStream = userDocRef.collection('work').where('status', isEqualTo: 'completed').snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Completed Works'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: userWorkStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Container(
                margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.05),


                alignment: Alignment.center,
                child: Column(
                  children: [
                    Lottie.asset('assets/lottie/empty.json'),
                    SizedBox(height: 0.05,),
                    Text("No Completed Work",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 21,
                          fontWeight: FontWeight.w400
                      ),)
                  ],
                ),
              ),
            );
          } else {

            return ListView(
              children: snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
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
                // Customize the display of each work document here
                return Container(
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
                              Text("₹"+data['amount'].toString(),style: TextStyle(
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





                        ],
                      )
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
