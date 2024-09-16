import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../../api/apis.dart';


class TrackWork extends StatefulWidget {
  final String workId;

  const TrackWork({Key? key, required this.workId}) : super(key: key);

  @override
  _TrackWorkState createState() => _TrackWorkState();
}

class _TrackWorkState extends State<TrackWork> {

  bool isLoading = false;
  late Future<DocumentSnapshot<Map<String, dynamic>>> workFuture;
  final player = AudioPlayer();
  bool isPlaying = false;
  late String currentAudioUrl;
  bool attachmentvisi = true;
  bool locationvisi = true;
  bool filevisi = true;
  final TextEditingController _amountController = TextEditingController();





  @override
  void initState() {
    super.initState();
    // Initialize the Future to fetch the work details
    workFuture = FirebaseFirestore.instance.collection('work').doc(widget.workId).get();
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
                                    "Morning!",
                                    style: TextStyle(color: CupertinoColors.white),
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
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                  isLoading ? 'https://cdn.dribbble.com/userupload/12569823/file/original-36e7a80c78bcefa16371969c139e81ea.jpg?resize=1504x1128' : APIs.me.image,
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
                    color: Colors.black,

                    borderRadius: BorderRadius.all(Radius.circular(30))
                ),
                child: SingleChildScrollView(
                  scrollDirection:Axis.vertical,
                  child: Column(
                      children: [

                        FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
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
                            String workid = workData['id']?? '';
                            String workName = workData['name'] ?? '';
                            String workDescription = workData['description'] ?? '';
                            double workAmount = (workData['amount'] ?? 0.0).toDouble();
                            String workamountstr = workAmount.toString();
                            String workPriority = workData['priority'] ?? '';
                            String workBy = workData['workBy'];
                            String firebaseDate = workData['dateTime'] ?? '';
                            String address = workData['address'] ?? '';
                            double latitude = workData['latitude'] ?? '';


                            double longitude = workData['longitude'] ?? '';
                            DateTime dateTime = DateTime.parse(firebaseDate);
                            String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
                            List<Map<String, dynamic>> fileData = (workData['fileData'] ?? [])?.cast<Map<String, dynamic>>() ?? [];
                            if(fileData.length==0){
                              attachmentvisi = false;
                              filevisi = false;
                            }
                            if(address==""){
                              locationvisi = false;
                            }
                            String formattedTime = DateFormat('hh:mm a').format(dateTime); // 12-hour AM/PM format
                            final LatLng _markerLocation = LatLng(latitude, longitude);



                            return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                              future: FirebaseFirestore.instance.collection('users').doc(workBy).get(),
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
                                // Add more user details as needed

                                return Container(
                                  padding: EdgeInsets.only(left: 10,top: 10,right: 10,bottom: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Display user details

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
                                                    Image.asset("assets/rupee.png",height: 30,width: 30,),
                                                    SizedBox(height: 5,),

                                                    Text("Client Fix Budget",style: TextStyle(
                                                        color: Colors.white.withOpacity(0.7),
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w400

                                                    ),),
                                                    Text('₹ $workamountstr',style: TextStyle(

                                                        color: Colors.white.withOpacity(0.7),
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.w600

                                                    ),),
                                                  ],
                                                ),
                                              )
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
                                                    Text("Timeline for work",style: TextStyle(
                                                        color: Colors.white.withOpacity(0.7),
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w400

                                                    ),),
                                                    Text('$formattedTime',style: TextStyle(

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
                                              markers: Set<Marker>.of([
                                                Marker(
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

        ],
      ),
    );
  }
}
