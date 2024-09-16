import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:google_maps_flutter_platform_interface/src/types/marker.dart' as GoogleMapsMarker;

import '../api/apis.dart';
import '../chat/pages/home.dart';
import '../screens/costumer/pickdeliverylocation.dart';
import '../screens/tasker/requestpayment.dart';
import '../screens/tasker/taskerhomescreen.dart';
import '../try/pigeon.dart';
import '../try/swithch.dart';

class WorkIHaveToDoPickup extends StatefulWidget {
  final double destlat;
  final double destlong;
  final double sourcelat;
  final double sourcelong;
  final String workid;

  const WorkIHaveToDoPickup({Key? key,required this.destlat,required this.destlong,required this.sourcelat,required this.sourcelong,required this.workid}) : super(key: key);

  @override
  _DeliveryBoyScreenState createState() => _DeliveryBoyScreenState(destlat, destlong, sourcelat, sourcelong);
}

class _DeliveryBoyScreenState extends State<WorkIHaveToDoPickup> {
  final double destlat;
  final double destlong;
  final double sourcelat;
  final double sourcelong;

  _DeliveryBoyScreenState(this.destlat, this.destlong, this.sourcelat, this.sourcelong);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late User _user;

  late GoogleMapController? _mapController;
  late LatLng _currentPosition = LatLng(0.0, 0.0); // Initializing to default position
  bool _isLoading = true;
  bool _mapInitialized = false;
  List<LatLng> polylineCoordinates = [];
  late Size size;
  late String _darkMapStyle;
  final player = AudioPlayer();
  bool isPlaying = false;
  late String currentAudioUrl;
  bool attachmentvisi = true;
  bool locationvisi = true;
  bool filevisi = true;
  final TextEditingController _amountController = TextEditingController();
  double drivingDistance = 0.0;
  String sdrivingDistance = "0.0";
  bool _isMapReady = false;
  Uint8List? _markerIconBytes;
  double _markerIconWidth = 50.0; // Width of the marker icon
  double _markerIconHeight = 50.0;// To store the marker icon bytes
  final double _initFabHeight = 120.0;
  double _fabHeight = 0;
  double _panelHeightOpen = 0;
  double _panelHeightClosed = 200.0;


  bool isLoading = true; // Flag to indicate whether data i
  void getdate() {
    FirebaseFirestore.instance.collection('work').doc(widget.workid).snapshots().listen((DocumentSnapshot snapshot) {
      setState(() {
        paymentdone = snapshot['payment'] ?? false;

      });
    });
  }
  @override
  void initState() {
    super.initState();
    fetchMapData();
    getdate();
    getalldata();
    getpreviouslocation();
    _startLocationUpdates();
    _user = _auth.currentUser!;
  }
  String workid = '';
  String workName = '';
  String workDescription ='';
  double workAmount = 0.0;
  double finalamount = 0.0;

  String workamountstr = "";
  String workPriority = '';
  String workBy = '';
  String firebaseDate = '';
  String address = '';
  double latitude = 0.0;
  double longitude = 0.0;
  bool paymentdone =  false;
  String userName = "";
  String usernumber = "";

  String userImage = "";
  List<Map<String, dynamic>> fileData=  [];
  bool formto = false;
  String _receivedfrom = "";
  String _receivedto = "";
  Future<void> getalldata() async {
    final CollectionReference workCollection = FirebaseFirestore.instance
        .collection('work');
    DocumentSnapshot workSnapshot = await workCollection.doc(widget.workid).get();
    setState(() async {
      workAmount = workSnapshot['workeramount'];
      finalamount = workSnapshot['finalamount'];

      workBy = workSnapshot['workBy'];
      workName = workSnapshot['name'];
      workDescription = workSnapshot['description'];
      fileData = (workSnapshot['fileData'] ?? [])?.cast<Map<String, dynamic>>() ?? [];
      _receivedfrom = workSnapshot['fromaddress'];
      _receivedto = workSnapshot['toaddress'];
      if(workSnapshot['fromaddress']=="Pick From Location"){
        formto = false;
      }
      else{
        formto = true;
      }


      final CollectionReference workCollection1 = FirebaseFirestore.instance
          .collection('users');
      DocumentSnapshot workSnapshot1 = await workCollection1.doc(workSnapshot['workBy']).get();
      userName = workSnapshot1['name'];
      usernumber = workSnapshot1['mobile'];
      userImage = workSnapshot1['image'];
    });


  }
  bool showloading = false;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Call your function here
    getpreviouslocation();
  }

  Future<void> getpreviouslocation() async {
    final CollectionReference workCollection =
    FirebaseFirestore.instance.collection('prof');
    DocumentSnapshot workSnapshot =
    await workCollection.doc(APIs.me.id).get();
    double lat = workSnapshot['latitude'];
    double long = workSnapshot['longitude'];
    _startLocationUpdates();

    setState(() {
      _currentPosition = LatLng(lat, long);
      print(_currentPosition);
    });
    await _updateLocation(
        _currentPosition.latitude, _currentPosition.longitude);
    _startLocationUpdates();
    fetchMapData();
  }

  Future<void> _startLocationUpdates() async {
    _updateCurrentPosition(_currentPosition.latitude, _currentPosition.longitude);

    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0, // meters
      ),
    ).listen((Position position) async {
      print("location changhed");
      // Update the location in Firestore
      await _updateLocation(position.latitude, position.longitude);
      _updateCurrentPosition(position.latitude, position.longitude);
      fetchMapData();

    });
  }

  void _updateCurrentPosition(double latitude, double longitude) {
    setState(() {
      _currentPosition = LatLng(latitude, longitude);
      _isLoading = false; // Set loading to false when position is obtained
    });
    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLng(_currentPosition));
    }
  }
  Future<void> fetchMapData() async {
    await Future.wait([fetchPolyPoints(), fetchDistance()]);
    setState(() {
      isLoading = false; // Data fetching is complete, set loading flag to false
    });
  }

  Future<void> fetchPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    // Fetch polyline points from _currentPosition to source location
    PolylineResult sourceToDestResult = await polylinePoints.getRouteBetweenCoordinates(
      Provider.of<ApiKeyProvider>(context).apiKey, // Replace with your actual API key
      PointLatLng(_currentPosition.latitude, _currentPosition.longitude),
      PointLatLng(sourcelat, sourcelong),
    );

    // Fetch polyline points from source location to destination location
    PolylineResult destToDestResult = await polylinePoints.getRouteBetweenCoordinates(
      Provider.of<ApiKeyProvider>(context).apiKey, // Replace with your actual API key
      PointLatLng(sourcelat, sourcelong),
      PointLatLng(destlat, destlong),
    );

    if (sourceToDestResult.points.isNotEmpty && destToDestResult.points.isNotEmpty) {
      setState(() {
        polylineCoordinates.clear(); // Clear existing polyline coordinates
        polylineCoordinates.addAll(sourceToDestResult.points.map((point) => LatLng(point.latitude, point.longitude)));
        polylineCoordinates.addAll(destToDestResult.points.map((point) => LatLng(point.latitude, point.longitude)));
      });
    }
  }


  Future<void> fetchDistance() async {
    final apiKey = Provider.of<ApiKeyProvider>(context).apiKey;
    double driverlat = _currentPosition.latitude;
    double driverlong = _currentPosition.longitude;
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
      drivingDistance = distanceInMeters / 1000.0;
      print(drivingDistance);
      sdrivingDistance = drivingDistance.toStringAsFixed(1);
    } else {
      throw Exception('Failed to fetch driving distance');
    }
  }

  @override
  Widget build(BuildContext context) {
    _panelHeightOpen = MediaQuery.of(context).size.height * .82;

    size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text('Delivery Boy Screen'),
        ),
        body: _isLoading?CircularProgressIndicator():Stack(
          children: [
            SlidingUpPanel(
              maxHeight: _panelHeightOpen,
              minHeight: _panelHeightClosed,
              parallaxEnabled: true,
              parallaxOffset: .5,
              body: _body(),
              panelBuilder: (sc) => _panel(sc),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.0),
                  topRight: Radius.circular(18.0)),
              onPanelSlide: (double pos) => setState(() {
                _fabHeight = pos * (_panelHeightOpen - _panelHeightClosed) +
                    _initFabHeight;
              }),
            ),
            Visibility(
                visible: showloading,
                child: Container(
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
                )
            )

          ],
        )
    );
  }
  Widget _body() {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(_currentPosition.latitude, _currentPosition.longitude), zoom: 15),
          onMapCreated: (controller) {
            _mapController = controller;
            _mapInitialized = true;
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          polylines: {
            Polyline(
              polylineId: PolylineId("route"),
              points: polylineCoordinates,
              color: Colors.pink,
              width: 6,
            )
          },

          markers: _isLoading || !_mapInitialized
              ? {}
              : {
            GoogleMapsMarker.Marker(
              position: LatLng(sourcelat, sourcelong),
              markerId: MarkerId("source"),
            ),
            GoogleMapsMarker.Marker(
              position: LatLng(destlat, destlong),
              markerId: MarkerId("destination"),
            ),
            GoogleMapsMarker.Marker(
              markerId: MarkerId('current_position'),
              position: _currentPosition,
            ),
          },
        ),
        if (_isLoading || !_mapInitialized)
          Center(
            child: CircularProgressIndicator(),
          ),
      ],
    )
    ;
  }
  Widget _panel(ScrollController sc) {
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Container(
          color: Colors.white.withOpacity(0.1),
          child: ListView(
            controller: sc,
            children: <Widget>[
              SizedBox(
                height: 15.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.all(Radius.circular(12.0))),
                  ),
                ],
              ),

              SizedBox(
                height: 15.0,
              ),
              Container(
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
                          radius: MediaQuery.of(context).size.width*0.07,
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
                                    color: Colors.black.withOpacity(1),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400

                                ),),
                                SizedBox(width: 7,),
                                Text(userName,style: TextStyle(
                                    color: Colors.black.withOpacity(1),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500

                                ),)
                              ],
                            ),
                            SizedBox(width: 10,),
                            Container(
                              margin: EdgeInsets.only(left: 10),
                              child: Text("",style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400

                              ),),
                            )

                          ],
                        )
                      ],
                    ),
                    Visibility(
                      visible: workName!="",
                      child: Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Text(workName,
                          maxLines: 2, // Limiting to 1 line
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: 18
                          ),),

                      ),),
                    SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 10),
                          height: MediaQuery.of(context).size.height*0.13,
                          width: MediaQuery.of(context).size.width*0.4,
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
                                  visible: !paymentdone,
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
                                  visible: paymentdone,
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
                            height: MediaQuery.of(context).size.height*0.13,
                            width: MediaQuery.of(context).size.width*0.4,
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
                                  Text(workAmount.toString(),style: TextStyle(

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
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Work Description",style: TextStyle(
                                color: Colors.black.withOpacity(1),
                                fontSize: MediaQuery.of(context).size.width*0.05,
                                fontWeight: FontWeight.w400

                            ),),
                            SizedBox(height: 5,),
                            Container(
                              child: Text(
                                workDescription, // Assuming workName is the variable holding your text
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: MediaQuery.of(context).size.width * 0.04,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.clip,
                              ),
                            ),
                          ],)),
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
                                              width: MediaQuery.of(context).size.width*0.7,
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
                                          border: Border.all(color: Colors.grey.shade300),
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
                                            width: MediaQuery.of(context).size.width*0.7,
                                            child: Text(_receivedto,
                                              overflow: TextOverflow.clip,
                                              maxLines: 2,
                                              style:
                                              TextStyle(
                                                  color: Colors.black,
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
                    Visibility(
                      visible: fileData!=[],
                      child: Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Text("Attachments",style: TextStyle(
                            color: Colors.black.withOpacity(1),
                            fontSize: MediaQuery.of(context).size.width*0.05,
                            fontWeight: FontWeight.w400

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
                      visible: !paymentdone,
                      child: Container(
                        height: MediaQuery.of(context).size.height*0.1,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          color: Colors.white,


                        ),
                        width: MediaQuery.of(context).size.width,
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
                                            MaterialPageRoute(builder: (context) =>   RequestPayment(type: 'work',fid: widget.workid,amount: (5+finalamount).toString(),)),
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
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(left: 10,top: 6,bottom: 6,right: 7),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CircleAvatar(
                            radius: MediaQuery.of(context).size.width*0.06,
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
                              print("usernumber from deliver");
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
                    SizedBox(height: 15,),
                    Container(
                      padding: EdgeInsets.only(left: 5,right: 5),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300,width: 1),
                          borderRadius: BorderRadius.circular(15)
                      ),
                      child: PickedUpItemSwitch(
                        text: 'Picked up item',
                        onSwitchChanged: (value) {
                          // Your function call here
                          print('Switch is on');
                          APIs.pickedupitem(widget.workid);
                        },
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
                    Visibility(
                      visible: paymentdone,
                      child: GestureDetector(
                        onTap: () {
                          showloading = true;
                          try {

                            APIs.makeWorkComplete(widget.workid);
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
                          width: MediaQuery.of(context).size.width,
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
              )


            ],
          ),
        ));
  }
  Future<void> _updateLocation(double latitude, double longitude) async {
    String uid = _user.uid;

    try {
      await _firestore.collection('prof').doc(uid).update({
        'latitude': latitude,
        'longitude': longitude,
      });
    } catch (e) {
      print('Error updating location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update location.'),
        ),
      );
    }
  }
}
