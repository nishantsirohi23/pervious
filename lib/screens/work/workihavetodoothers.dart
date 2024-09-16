import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:perwork/screens/tasker/taskerhomescreen.dart';

import '../../api/apis.dart';
import '../../chat/pages/home.dart';
import '../../try/swithch.dart';
import '../profilescreen.dart';
import '../tasker/requestpayment.dart';
import 'package:google_maps_flutter_platform_interface/src/types/marker.dart' as GoogleMapsMarker;

class WorkIHaveToDoOther extends StatefulWidget {
  final String workid;
  const WorkIHaveToDoOther({Key? key, required this.workid}) : super(key: key);

  @override
  State<WorkIHaveToDoOther> createState() => _ShowWorkState();
}

class _ShowWorkState extends State<WorkIHaveToDoOther> {
  bool isLoading = false;
  bool showloading = false;
  final player = AudioPlayer();
  bool isPlaying = false;
  late String currentAudioUrl;
  bool attachmentvisi = true;
  bool locationvisi = true;
  bool filevisi = true;
  final TextEditingController _amountController = TextEditingController();




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
  @override
  void initState() {
    super.initState();
    // Initialize the Future to fetch the work details
  }
  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    User user = auth.currentUser!;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,

      backgroundColor: Colors.black,
      body: Stack(
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

                                      borderRadius: BorderRadius.all(Radius.circular(105))),
                                  child: Center(child: Icon(Icons.arrow_back_ios,color: Colors.white,)),
                                ),
                              ),
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
                                    "Nishant Sirohi",
                                    style: TextStyle(color: CupertinoColors.white, fontSize: 20, fontWeight: FontWeight.w600),
                                  )
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [

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
                height: screenHeight*0.8,
                width: screenWidth,
                margin: EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage("https://cdn.dribbble.com/users/1646182/screenshots/9129976/media/4523f332bc2d8e78cad6687702742662.jpg?resize=1600x1200&vertical=center")
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(30))
                ),
                child: SingleChildScrollView(
                  scrollDirection:Axis.vertical,
                  child: Column(
                      children: [

                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance.collection('work').doc(widget.workid).snapshots(),
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
                            String workid = workData['id']?? '';
                            String workName = workData['name'] ?? '';
                            String workDescription = workData['description'] ?? '';
                            double workAmount = (workData['amount'] ?? 0.0).toDouble();
                            String workamountstr = workAmount.toString();
                            String workPriority = workData['priority'] ?? '';
                            String workBy = workData['workBy'];
                            String firebaseDate = workData['dateTime'] ?? '';
                            String address = workData['fromaddress'] ?? '';
                            double latitude = workData['fromlatitude'] ?? '';
                            double longitude = workData['fromlongitude'] ?? '';
                            bool paymentdone = workData['payment'] ?? '';

                            DateTime dateTime = DateTime.parse(firebaseDate);
                            String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
                            List<Map<String, dynamic>> fileData = (workData['fileData'] ?? [])?.cast<Map<String, dynamic>>() ?? [];
                            if(fileData.length==0){
                              attachmentvisi = false;
                              filevisi = false;
                            }
                            print(address);
                            if(address=="" || address=="Pick From Location"){
                              locationvisi = false;
                            }
                            String formattedTime = DateFormat('hh:mm a').format(dateTime); // 12-hour AM/PM format
                            final LatLng _markerLocation = LatLng(latitude, longitude);

                            return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                              stream: FirebaseFirestore.instance.collection('users').doc(workBy).snapshots(),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.connectionState == ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (userSnapshot.hasError) {
                                  return Text('Error: ${userSnapshot.error}');
                                } else if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                                  return Text('User not found');
                                }

                                // User details
                                Map<String, dynamic> userData = userSnapshot.data!.data()!;
                                String userName = userData['name'] ?? '';
                                String userImage = userData['image'] ?? '';
                                String usernumber = userData['mobile']??'';
                                // Add more user details as needed

                                return Container(
                                  padding: EdgeInsets.only(left: 10,top: 10,right: 10,bottom: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Display user details
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            radius: screenWidth*0.07,
                                            backgroundImage: NetworkImage(
                                                userImage
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  SizedBox(width: 10,),
                                                  Text("Posted by",style: TextStyle(
                                                      color: Colors.white.withOpacity(0.7),
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w400

                                                  ),),
                                                  SizedBox(width: 7,),
                                                  Text(userName,style: TextStyle(
                                                      color: Colors.white.withOpacity(1),
                                                      fontSize: 17,
                                                      fontWeight: FontWeight.w500

                                                  ),)
                                                ],
                                              ),
                                              SizedBox(width: 10,),
                                              Container(
                                                margin: EdgeInsets.only(left: 10),
                                                child: Text(formattedDate,style: TextStyle(
                                                    color: Colors.white.withOpacity(0.7),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w400

                                                ),),
                                              )

                                            ],
                                          )
                                        ],
                                      ),
                                      Container(
                                        child: Text(workName,
                                          maxLines: 2, // Limiting to 1 line
                                          overflow: TextOverflow.clip,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              fontSize: screenWidth*0.08
                                          ),),

                                      ),
                                      SizedBox(height: 10,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(left: 10),
                                            height: screenHeight*0.13,
                                            width: screenWidth*0.4,
                                            decoration: BoxDecoration(
                                                color: Color(0xFF3c3c3c),
                                                borderRadius: BorderRadius.all(Radius.circular(22))
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Image.asset("assets/rupee.png",height: 30,width: 30,),
                                                SizedBox(height: 5,),

                                                Text("Payment",style: TextStyle(
                                                    color: Colors.white.withOpacity(0.7),
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w400

                                                ),),
                                                Visibility(
                                                    visible: !workData['payment'] ,
                                                    child:  Row(
                                                      children: [
                                                        Text('Pending',style: TextStyle(

                                                            color: Colors.white.withOpacity(0.7),
                                                            fontSize: 20,
                                                            fontWeight: FontWeight.w600

                                                        ),),
                                                        Icon(Icons.timelapse,color: Colors.white,)
                                                      ],
                                                    )),
                                                Visibility(
                                                    visible: workData['payment'] ,
                                                    child:  Row(
                                                      children: [
                                                        Text('Done',style: TextStyle(

                                                            color: Colors.white.withOpacity(0.7),
                                                            fontSize: 20,
                                                            fontWeight: FontWeight.w600

                                                        ),),
                                                        Icon(Icons.done_all,color: Colors.white,)
                                                      ],
                                                    )),

                                              ],
                                            ),
                                          ),
                                          Container(
                                              height: screenHeight*0.13,
                                              width: screenWidth*0.4,
                                              decoration: BoxDecoration(
                                                  color: Color(0xFF3c3c3c),
                                                  borderRadius: BorderRadius.all(Radius.circular(22))
                                              ),
                                              child: Center(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset("assets/time.png",height: 30,width: 30,),
                                                    SizedBox(height: 5,),
                                                    Text("Final Amount",style: TextStyle(
                                                        color: Colors.white.withOpacity(0.7),
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w400

                                                    ),),
                                                    Text(workData['workeramount'].toString(),style: TextStyle(

                                                        color: Colors.white.withOpacity(0.7),
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.w600

                                                    ),),
                                                  ],
                                                ),
                                              )
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 10,),
                                      Visibility(
                                          visible: workDescription!="",
                                          child:
                                          Column(children: [
                                            Text("Work Description",style: TextStyle(
                                                color: Colors.white.withOpacity(1),
                                                fontSize: screenWidth*0.05,
                                                fontWeight: FontWeight.w500

                                            ),),
                                            SizedBox(height: 5,),
                                            Container(
                                              child: Text(
                                                workDescription, // Assuming workName is the variable holding your text
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: screenWidth * 0.04,
                                                ),
                                                maxLines: 3,
                                                overflow: TextOverflow.clip,
                                              ),
                                            ),
                                          ],)),
                                      Visibility(
                                        visible: attachmentvisi,
                                        child: Container(
                                          margin: EdgeInsets.only(top: 10),
                                          child: Text("Attachments",style: TextStyle(
                                              color: Colors.white.withOpacity(1),
                                              fontSize: screenWidth*0.05,
                                              fontWeight: FontWeight.w500

                                          ),),
                                        ),
                                      ),
                                      Visibility(
                                        visible: filevisi,
                                        child: Container(
                                            child: MediaQuery.removePadding(
                                                removeTop: true,
                                                removeBottom: true,
                                                context: context,
                                                child: ListView.builder(
                                                  physics: NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  scrollDirection: Axis.vertical,
                                                  itemCount: fileData.length,
                                                  itemBuilder: (context, index) {
                                                    Map<String, dynamic> file = fileData[index];
                                                    String fileUrl = file['url'] ?? '';
                                                    String fileType = file['type'] ?? '';

                                                    // Check the file type based on its extension
                                                    if (fileType.toLowerCase() == 'jpg' || fileType.toLowerCase() == 'jpeg' || fileType.toLowerCase() == 'png') {
                                                      // Display image using Image.network
                                                      return Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Image.network(
                                                          fileUrl,
                                                          width: 200,
                                                          height: 200,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      );
                                                    } else if (fileType.toLowerCase() == 'mp3') {
                                                      // Display audio play button
                                                      return Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: ElevatedButton(
                                                          onPressed: () async {
                                                            // Implement audio playback logic
                                                            setState(() {
                                                              isLoading = true;
                                                            });

                                                            if (isPlaying) {
                                                              await player.pause();
                                                            } else {
                                                              await player.play(UrlSource(fileUrl));
                                                            }

                                                            setState(() {
                                                              isLoading = false;
                                                              isPlaying = !isPlaying;
                                                              currentAudioUrl = fileUrl;
                                                            });
                                                          },
                                                          child: isLoading
                                                              ? CircularProgressIndicator()
                                                              : Text(isPlaying ? 'Pause Audio $index' : 'Play Audio $index'),
                                                        ),
                                                      );
                                                    } else if (fileType.toLowerCase() == 'mp4') {
                                                      // Display video play button
                                                      return Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                          },
                                                          child: Text('Play Video $index'),
                                                        ),
                                                      );
                                                    } else {
                                                      // Handle other file types or show an error message
                                                      return Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Text('Unsupported File Type'),
                                                      );
                                                    }

                                                  },
                                                ))
                                        ),
                                      ),
                                      Visibility(
                                        visible: locationvisi,
                                        child: Text("Location",style: TextStyle(
                                            color: Colors.white.withOpacity(1),
                                            fontSize: screenWidth*0.05,
                                            fontWeight: FontWeight.w500

                                        ),),
                                      ),
                                      SizedBox(height: 10,),
                                      Visibility(
                                        visible: locationvisi,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(20),
                                          child: Container(
                                            height: 200,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(Radius.circular(20))
                                            ),
                                            child: GoogleMap(
                                              initialCameraPosition: CameraPosition(
                                                target: _markerLocation,
                                                zoom: 15,
                                              ),
                                              markers: Set<GoogleMapsMarker.Marker>.of([
                                                GoogleMapsMarker.Marker(
                                                  markerId: MarkerId('marker_1'),
                                                  position: _markerLocation,
                                                  infoWindow: InfoWindow(
                                                    title: 'Marker Title',
                                                    snippet: 'Marker Snippet',
                                                  ),
                                                ),
                                              ]),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 15,),
                                      Visibility(
                                        visible: !workData['payment'],
                                        child: Container(

                                          height: screenHeight*0.1,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.all(Radius.circular(15)),
                                            color: Colors.white,


                                          ),
                                          width: screenWidth,
                                          padding: EdgeInsets.only(left: 10,right: 10),
                                          child: Row(
                                            children: [
                                              Image.asset("assets/verify.png",height: 45,width: 45,),
                                              SizedBox(width: 10), // Added SizedBox for spacing
                                              Expanded( // Added Expanded to allow the container to take remaining space
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start, // Align text to start
                                                  mainAxisAlignment: MainAxisAlignment.center, // Vertically center text
                                                  children: [
                                                    Row( // Added Row to contain text and arrow
                                                      children: [

                                                        GestureDetector(
                                                          onTap: (){
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(builder: (context) =>   RequestPayment(type: 'work',fid: widget.workid,amount: (workData['finalamount']+5).toString(),)),
                                                            );
                                                          },
                                                          child: Text(
                                                            "Request Payment",
                                                            style: TextStyle(
                                                              color: Colors.pink,
                                                              fontWeight: FontWeight.w500,
                                                              fontSize: 18,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 5), // Added SizedBox for spacing between text and arrow
                                                        Icon( // Right arrow icon
                                                          Icons.arrow_forward_ios,
                                                          size: 16,
                                                          color: Colors.black,
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 1), // Added SizedBox for spacing
                                                    Container(
                                                      child: Text(
                                                        "Payment Pending from the user",
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                        softWrap: true,
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 15,),

                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                          color: Colors.white,


                                        ),
                                        width: screenWidth,
                                        padding: EdgeInsets.only(left: 10,top: 6,bottom: 6,right: 7),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            CircleAvatar(
                                              radius: screenWidth*0.06,
                                              backgroundImage: NetworkImage(
                                                false ? 'https://cdn.dribbble.com/userupload/12569823/file/original-36e7a80c78bcefa16371969c139e81ea.jpg?resize=1504x1128' : userImage,
                                              ),
                                            ),
                                            OutlinedButton.icon(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) =>   HomePage(profid: workBy)),
                                                );
                                              },
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(color: Colors.pink),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                              ),
                                              icon: Icon(
                                                Icons.message,
                                                color: Colors.pink,
                                              ),
                                              label: Text(
                                                'Message',
                                                style: TextStyle(
                                                  color: Colors.pink,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            OutlinedButton.icon(
                                              onPressed: () {
                                                print("usernumber from work others");
                                                print(usernumber);

                                                FlutterPhoneDirectCaller.callNumber(usernumber);

                                              },
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(color: Colors.pink),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                              ),
                                              icon: Icon(
                                                Icons.call,
                                                color: Colors.pink,
                                              ),
                                              label: Text(
                                                'Call',
                                                style: TextStyle(
                                                  color: Colors.pink,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),

                                      SizedBox(height: 10,),
                                      Container(
                                        padding: EdgeInsets.only(left: 5,right: 5),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(color: Colors.grey.shade300,width: 1),
                                            borderRadius: BorderRadius.circular(15)
                                        ),
                                        child: PickedUpItemSwitch(
                                          text: 'Reached Location',
                                          onSwitchChanged: (value) {
                                            // Your function call here
                                            print('Switch is on');
                                            APIs.reachedLocation(widget.workid);

                                          },
                                        ),
                                      ),
                                      SizedBox(height: 15,),
                                      Visibility(
                                        visible: workData['payment'],
                                        child: GestureDetector(
                                          onTap: () {
                                            showloading = true;
                                            try {

                                              APIs.makeWorkComplete(workid);
                                              print('Work has been completed successfully.');
                                              showloading = false;

                                              // Show alert box
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(

                                                    backgroundColor: Colors.white,
                                                    content: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Lottie.asset(
                                                            'assets/lottie/success.json',
                                                            width: 100,
                                                            height: 100,
                                                            repeat: false
                                                        ),
                                                        SizedBox(height: 20),
                                                        Text(
                                                          "Work has been completed, Payment will be credited into ypur account",
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          showloading = false;
                                                          Navigator.pushReplacement(
                                                            context,
                                                            MaterialPageRoute(builder: (context) => TaskerHomeScreen()),
                                                          );
                                                        },
                                                        child: Text('Done'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            } catch (e) {
                                              print('Error accepting work: $e');
                                            }
                                          },
                                          child: Container(
                                            height: 50,
                                            width: screenWidth,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(20.0), // Adjust the value as needed
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [Color(0xfff4c4f3), Color(0xFFfc67fa)], // Example gradient colors
                                              ),
                                            ),
                                            child: Center(
                                              child: Text('Mark As Complete',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 19

                                                ),),
                                            ),

                                          ),
                                        ),)






                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        )

                      ]
                  ),
                ),
              )
            ],
          ),
          Visibility(
              visible: showloading,
              child: Container(
                height: screenHeight*0.86,
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
              )
          )


        ],
      ),
    );
  }
}

