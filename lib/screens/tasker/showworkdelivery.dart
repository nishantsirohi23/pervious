import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:google_maps_flutter_platform_interface/src/types/marker.dart' as GoogleMapsMarker;
import 'package:provider/provider.dart';

import '../../api/apis.dart';
import '../../try/pigeon.dart';
import '../costumer/pickdeliverylocation.dart';
import '../profilescreen.dart';
import 'ApplySuccessScreen.dart';

class ShowWorkDelivery extends StatefulWidget {
  final String workid;
  const ShowWorkDelivery({Key? key, required this.workid}) : super(key: key);

  @override
  State<ShowWorkDelivery> createState() => _ShowWorkState();
}

class _ShowWorkState extends State<ShowWorkDelivery> {
  bool isLoading = false;
  late Future<DocumentSnapshot<Map<String, dynamic>>> workFuture;
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
  double drivingDistance = 0.0;
  String sdrivingDistance = "0.0";
  Future<void> fetchDistance(double sourcelat,double sourcelong,double destlat,double destlong) async {
    final apiKey = Provider.of<ApiKeyProvider>(context).apiKey;
    double driverlat = sourcelat;
    double driverlong = sourcelong;
    final origins = '$driverlat,$driverlong';

    final destinations = '$destlat,$destlong';

    final url = Uri.parse('https://maps.googleapis.com/maps/api/distancematrix/json'
        '?origins=$origins'
        '&destinations=$destinations'
        '&mode=driving' // Specify travel mode
        '&key=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final distanceInMeters = data['rows'][0]['elements'][0]['distance']['value'];
      // Convert distance from meters to kilometers and format to display with one decimal point
      setState(() {
        drivingDistance = distanceInMeters / 1000.0;
        print(drivingDistance);
        sdrivingDistance = drivingDistance.toStringAsFixed(1);
      });
    } else {
      throw Exception('Failed to fetch driving distance');
    }
  }
  void getdata() async{
    CollectionReference workCollection = FirebaseFirestore.instance.collection(
        'work');
    DocumentSnapshot workData = await workCollection.doc(widget.workid).get();
    fetchDistance(workData['fromlatitude'], workData['fromlongitude'], workData['tolatitude'], workData['tolongitude']);

  }
  @override
  void initState() {
    super.initState();
    getdata();
    // Initialize the Future to fetch the work details
    workFuture = FirebaseFirestore.instance.collection('work').doc(widget.workid).get();

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
                            String address = workData['toaddress'] ?? '';
                            double latitude = workData['fromlatitude'] ?? '';
                            double longitude = workData['fromlongitude'] ?? '';
                            String _receivedfrom = workData['fromaddress'];
                            String _receivedto = workData['toaddress'];
                            DateTime dateTime = DateTime.parse(firebaseDate);
                            String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
                            final LatLng _markerLocation = LatLng(workData['fromlatitude'], workData['fromlongitude']);
                            final LatLng _markerLocation1 = LatLng(workData['tolatitude'], workData['tolongitude']);
                            print('marker');
                            print(_markerLocation1);

                            List<Map<String, dynamic>> fileData = (workData['fileData'] ?? [])?.cast<Map<String, dynamic>>() ?? [];
                            if(fileData.length==0){
                              attachmentvisi = false;
                              filevisi = false;
                            }
                            print(address);
                            if(address=="" || address=="Pick From Location"){
                              locationvisi = false;
                            }
                            bool formto = false;
                            if(workData['fromaddress']=="Pick From Location"){
                              formto = false;
                            }
                            else{
                              formto = true;
                            }
                            String formattedTime = DateFormat('hh:mm a').format(dateTime); // 12-hour AM/PM format



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
                                              height: screenHeight*0.13,
                                              width: screenWidth*0.4,
                                              padding: EdgeInsets.only(left: 10),
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

                                                  Text("Client Budget",style: TextStyle(
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
                                              )
                                          ),
                                          Visibility(
                                              visible: formto,
                                              child: Container(
                                                  height: screenHeight*0.13,
                                                  width: screenWidth*0.4,
                                                  padding: EdgeInsets.only(left: 10),
                                                  decoration: BoxDecoration(
                                                      color: Color(0xFF3c3c3c),
                                                      borderRadius: BorderRadius.all(Radius.circular(22))
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Image.asset("assets/time.png",height: 30,width: 30,),
                                                      SizedBox(height: 5,),
                                                      Text("Distance",style: TextStyle(
                                                          color: Colors.white.withOpacity(0.7),
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.w400

                                                      ),),
                                                      Text(sdrivingDistance,style: TextStyle(

                                                          color: Colors.white.withOpacity(0.7),
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.w600

                                                      ),),
                                                    ],
                                                  )
                                              )),
                                          Visibility(
                                              visible: !formto,
                                              child: Container(
                                                  height: screenHeight*0.13,
                                                  width: screenWidth*0.4,
                                                  padding: EdgeInsets.only(left: 10),
                                                  decoration: BoxDecoration(
                                                      color: Color(0xFF3c3c3c),
                                                      borderRadius: BorderRadius.all(Radius.circular(22))
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Image.asset("assets/time.png",height: 30,width: 30,),
                                                      SizedBox(height: 5,),
                                                      Text("Anywhere",style: TextStyle(
                                                          color: Colors.white.withOpacity(0.7),
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.w400

                                                      ),),
                                                      Text('Nearest',style: TextStyle(

                                                          color: Colors.white.withOpacity(0.7),
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.w600

                                                      ),),
                                                    ],
                                                  )
                                              ))
                                        ],
                                      ),
                                      SizedBox(height: 10,),
                                      Visibility(
                                          visible: workDescription!='',
                                          child: Column(
                                            children: [
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
                                            ],
                                          )),
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

                                      SizedBox(height: 10,),
                                      Visibility(
                                        visible: locationvisi,child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [Visibility(
                                          visible: locationvisi,
                                          child: Text("Work Location",style: TextStyle(
                                              color: Colors.white.withOpacity(1),
                                              fontSize: 19,
                                              fontWeight: FontWeight.w500

                                          ),),
                                        ),
                                          SizedBox(height: 10,),
                                          Visibility(
                                            visible: locationvisi && formto,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(20),
                                              child: Container(
                                                height: 200,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.all(Radius.circular(20))
                                                ),
                                                child: GoogleMap(
                                                  zoomControlsEnabled: false, // Set to false to hide zoom buttons

                                                  myLocationButtonEnabled: false,
                                                  polylines: Set<Polyline>.of([
                                                    Polyline(
                                                      polylineId: PolylineId('route'),
                                                      color: Colors.pink,
                                                      width: 3,
                                                      points: [
                                                        _markerLocation1,

                                                        _markerLocation,
                                                      ],
                                                      patterns: [
                                                        PatternItem.dash(30),
                                                        PatternItem.gap(20),
                                                      ],
                                                    ),
                                                  ]),
                                                  initialCameraPosition: CameraPosition(
                                                    target: _markerLocation,
                                                    zoom: 15,
                                                  ),
                                                  markers: Set<GoogleMapsMarker.Marker>.of([
                                                    GoogleMapsMarker.Marker(
                                                      markerId: MarkerId('marker_1234567'),
                                                      position: _markerLocation,
                                                    ),
                                                    GoogleMapsMarker.Marker(
                                                      markerId: MarkerId('marker_2134567'),
                                                      position:_markerLocation1,
                                                    ),
                                                  ]),
                                                )
                                                ,
                                              ),
                                            ),
                                          ),
                                          Visibility(
                                            visible: locationvisi && !formto,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(20),
                                              child: Container(
                                                height: 200,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.all(Radius.circular(20))
                                                ),
                                                child: GoogleMap(
                                                  zoomControlsEnabled: false, // Set to false to hide zoom buttons
                                                  myLocationButtonEnabled: false,
                                                  initialCameraPosition: CameraPosition(
                                                    target: _markerLocation1,
                                                    zoom: 15,
                                                  ),
                                                  markers: Set<GoogleMapsMarker.Marker>.of([
                                                    GoogleMapsMarker.Marker(
                                                      markerId: MarkerId('marker_1'),
                                                      position: _markerLocation1,
                                                      infoWindow: InfoWindow(
                                                        title: 'Marker Title',
                                                        snippet: 'Marker Snippet',
                                                      ),
                                                    ),
                                                  ]),
                                                ),
                                              ),
                                            ),
                                          ),],
                                      ),),
                                      SizedBox(height: 15,),
                                      Stack(
                                        children: [
                                          Visibility(
                                            visible: formto,
                                            child: Container(
                                              margin: EdgeInsets.only(top: 15),
                                              child: Stack(
                                                children: [
                                                  Column(
                                                    children: [
                                                      GestureDetector(

                                                        child: Container(
                                                          padding: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 10),
                                                          decoration: BoxDecoration(
                                                              color: Colors.pink.withOpacity(0.8),
                                                              borderRadius: BorderRadius.all(Radius.circular(15))
                                                          ),
                                                          child: Row(
                                                            children: [

                                                              Container(
                                                                height: 32,
                                                                width: 32,
                                                                decoration: BoxDecoration(
                                                                    color: Colors.white,
                                                                    borderRadius: BorderRadius.all(Radius.circular(10))
                                                                ),
                                                                child: Icon(Icons.arrow_upward_outlined,color: Colors.pink,),
                                                              ),
                                                              SizedBox(width: 13,),
                                                              Container(
                                                                width: screenWidth*0.7,
                                                                child: Text(_receivedfrom,
                                                                  overflow: TextOverflow.clip,
                                                                  maxLines: 2,
                                                                  style:
                                                                  TextStyle(
                                                                      color: Colors.white,
                                                                      fontSize: 17,
                                                                      fontWeight: FontWeight.w400
                                                                  ),),
                                                              )


                                                            ],
                                                          ),
                                                        ),
                                                      ),

                                                    ],
                                                  ),


                                                ],
                                              ),
                                            ),),
                                          Container(
                                            margin: formto?EdgeInsets.only(top: MediaQuery.of(context).size.height*0.17):EdgeInsets.only(top: 0),
                                            child: Stack(
                                              children: [
                                                Column(
                                                  children: [
                                                    GestureDetector(

                                                      child: Container(
                                                        padding: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 10),
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.all(Radius.circular(15))
                                                        ),
                                                        child: Row(
                                                          children: [

                                                            Container(
                                                              height: 32,
                                                              width: 32,
                                                              decoration: BoxDecoration(
                                                                  color: Colors.pink,
                                                                  borderRadius: BorderRadius.all(Radius.circular(10))
                                                              ),
                                                              child: Icon(Icons.arrow_upward_outlined,color: Colors.white,),
                                                            ),
                                                            SizedBox(width: 13,),
                                                            Container(
                                                              width: screenWidth*0.7,
                                                              child: Text(_receivedto,
                                                                overflow: TextOverflow.clip,
                                                                maxLines: 2,
                                                                style:
                                                                TextStyle(
                                                                    color: Colors.pink,
                                                                    fontSize: 17,
                                                                    fontWeight: FontWeight.w400
                                                                ),),
                                                            )


                                                          ],
                                                        ),
                                                      ),
                                                    ),

                                                  ],
                                                ),


                                              ],
                                            ),
                                          ),
                                          Visibility(
                                            visible: formto,
                                            child: Container(
                                              margin: EdgeInsets.only(left: 26,top: _receivedfrom=="" ? 33.0 : 50.0),
                                              child: CustomPaint(
                                                size: Size(1.0, MediaQuery.of(context).size.height*0.14),
                                                painter: DashedLinePainter(color: Colors.pink),
                                              ),
                                            ),),
                                        ],
                                      ),
                                      SizedBox(height: 15,),
                                      GestureDetector(
                                        onTap: () {
                                          if (workData['negotiable'] == true) {
                                            _showApplyDialog(workData['id'], user.uid,workData['name']);
                                          }
                                          else{
                                            APIs.applyToWork(workData['id'], user.uid, workData['amount'],workData['name']);
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
                                            child: Text('Apply for Work',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 19

                                              ),),
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
  void _showApplyDialog(String workId, String userId, String name) {
    String responseMessage = ''; // Declare responseMessage here

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String inputText = ""; // Initial value for input text
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: EdgeInsets.zero,

              child: Container(
                width: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,

                ),
                padding: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Lottie.asset(
                        'assets/lottie/amount.json',
                        width: 100,
                        height: 100,
                        repeat: false,
                      ),
                      SizedBox(height: 20),
                      Container(
                        height: 50,
                        width: 200,
                        padding: EdgeInsets.only(left: 20, right: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: TextField(
                          controller: _amountController,
                          maxLines: 1,
                          decoration: InputDecoration(
                            hintText: 'Enter your Amount',
                            border: InputBorder.none, // You can customize the border as needed
                          ),
                        ),
                      ),
                      if (isLoading)
                        CircularProgressIndicator()
                      else
                        Text(
                          responseMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: responseMessage.contains('Success') ? Colors.green : Colors.red,
                          ),
                        ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              setState(() {
                                isLoading = true;
                              });
                              try {
                                // Perform apply action with _amountController.text
                                await APIs.applyToWork(workId, userId, double.parse(_amountController.text), name);
                                setState(() {
                                  isLoading = false;
                                  responseMessage = 'Application Successful!';
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => ApplySuccessScreen()),
                                  );
                                });
                              } catch (error) {
                                setState(() {
                                  isLoading = false;
                                  responseMessage = 'Application Failed: $error';
                                });
                              }
                            },
                            child: const Text('Apply'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              ),
            );


          },
        );
      },
    );
  }
}
