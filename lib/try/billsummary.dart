import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_marker/marker_icon.dart';
import 'package:flutter/foundation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/src/types/marker.dart' as GoogleMapsMarker;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:perwork/screens/maps/TrackFood.dart';
import 'package:perwork/try/pigeon.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../api/apis.dart';
import '../../try/editprofilescreen.dart';
import 'my_global.dart';

class TrackFood1 extends StatefulWidget {
  final double destlat;
  final double destlong;
  final double sourcelat;
  final double sourcelong;
  final String orderId;

  const TrackFood1({Key? key,required this.destlat,required this.destlong,required this.sourcelat,required this.sourcelong,required this.orderId}) : super(key: key);

  @override
  State<TrackFood1> createState() => _NavigationState(destlat, destlong, sourcelat, sourcelong);
}

class _NavigationState extends State<TrackFood1> {
  final double destlat;
  final double destlong;
  final double sourcelat;
  final double sourcelong;

  _NavigationState(this.destlat, this.destlong, this.sourcelat, this.sourcelong);

  final Completer<GoogleMapController> _controller = Completer();
  List<LatLng> polylineCoordinates = [];
  late Size size;
  late String _darkMapStyle;
  double drivingDistance = 0.0;
  String sdrivingDistance = "0.0";
  GoogleMapController? _mapController;
  late LatLng _currentPosition;
  double _containerHeight = 200;
  String formattedDateTime = "";
  bool _isMapReady = false;
  Uint8List? _markerIconBytes;
  double _markerIconWidth = 50.0; // Width of the marker icon
  double _markerIconHeight = 50.0;// To store the marker icon bytes
  final double _initFabHeight = 120.0;
  double _fabHeight = 0;
  double _panelHeightOpen = 0;
  double _panelHeightClosed = 200.0;
  String restname = "";
  String restimage = "";
  String totalamount = "";
  bool paymentdone = false;
  String restaddress = "";
  String deladdress = "";
  List<Map<String, dynamic>> dishesData = [];
  bool isLoading = false; // Flag to indicate whether data is being loaded
  bool isLoadingData = true;
  bool isLoadingStream = true;
  Set<Polyline> _polylines = {};
  String orderstatus = "";
  String workerId = "";
  bool timevisiblity = true;
  String apiKey = Globals.apiKey;
  Future<void> _fetchRestFee() async {
    try {
      DocumentSnapshot document = await FirebaseFirestore.instance
          .collection('values') // Replace with your collection name
          .doc('values') // Replace with your document ID
          .get();

      if (document.exists) {
        setState(() {
          apiKey = document.get('api');
          print("Rest fee");
        });
      } else {
        setState(() {
        });
      }
    } catch (e) {
      setState(() {
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchRestFee();
    _fabHeight = _initFabHeight;
    setMarker2();
    setMarker3();
    _fetchMarkerIcon();
    getpreviouslocation();
    getalldata();




  }
  Set<GoogleMapsMarker.Marker> _markers = <GoogleMapsMarker.Marker>{};
  Future<void> getalldata() async {
    final CollectionReference workCollection = FirebaseFirestore.instance
        .collection('orders');
    DocumentSnapshot workSnapshot = await workCollection.doc(widget.orderId).get();
    setState(() {

      DateTime dateTime = workSnapshot['orderPlacedAt'].toDate();
      DateTime localDateTime = dateTime.toLocal();
      formattedDateTime = DateFormat("d MMMM y 'at' hh:mm a").format(localDateTime);
      String status = workSnapshot['status'];
      if(status=="preparing"){
        orderstatus = "Preparing your Order";
        timevisiblity = false;
      }
      else{
        orderstatus = "Order on the way";
        timevisiblity = true;
      }
      restname = workSnapshot['restname'];
      restimage = workSnapshot['restimage'];
      totalamount  = workSnapshot['totalAmount'].toString();
      paymentdone = workSnapshot['payment'];
      restaddress = workSnapshot['restaddress'];
      deladdress = workSnapshot['deliveryaddress'];
      dishesData = (workSnapshot['dishes'] as List<dynamic>).cast<Map<String, dynamic>>();
    });
    setMarker2();
    setMarker3();
    isLoadingData =false;





  }

  void setMarker1() async{
    _markers.add(
      GoogleMapsMarker.Marker(
        markerId: MarkerId('downloadResizePictureCircle'),
        icon: await MarkerIcon.downloadResizePictureCircle(
            'https://firebasestorage.googleapis.com/v0/b/perwork.appspot.com/o/WhatsApp%20Image%202024-02-26%20at%205.41.54%20PM.jpeg?alt=media&token=5962533a-d8c4-442b-ba99-0beb040ee0d0',
            size: 150,
            addBorder: true,
            borderColor: Colors.white,
            borderSize: 15),
        position: LatLng(_currentPosition.latitude, _currentPosition.longitude),
      ),

    );


  }
  void setMarker2() async{

    _markers.add(
      GoogleMapsMarker.Marker(
        markerId: MarkerId('downloadResizePictureCircle1'),
        icon: await MarkerIcon.downloadResizePictureCircle(
            restimage,
            size: 150,
            addBorder: true,
            borderColor: Colors.white,
            borderSize: 15),
        position: LatLng(sourcelat, sourcelong),
      ),

    );

  }
  void setMarker3() async{

    _markers.add(
      GoogleMapsMarker.Marker(
        markerId: MarkerId('downloadResizePictureCircle2'),
        icon: await MarkerIcon.downloadResizePictureCircle(
            APIs.me.image,
            size: 150,
            addBorder: true,
            borderColor: Colors.white,
            borderSize: 15),
        position: LatLng(destlat, destlong),
      ),

    );

  }
  Future<void> getpreviouslocation() async {
    final CollectionReference workCollection =
    FirebaseFirestore.instance.collection('prof');
    DocumentSnapshot workSnapshot =
    await workCollection.doc('').get();
    double lat = workSnapshot['latitude'];
    double long = workSnapshot['longitude'];

    setState(() {
      _currentPosition = LatLng(lat, long);
      print(_currentPosition);
    });

    fetchMapData(lat,long);
  }

  Future<void> fetchMapData(double driverlat,double driverlong) async {

    await Future.wait([fetchPolyPoints( driverlat, driverlong), fetchDistance( driverlat, driverlong)]);
    setState(() {
      isLoading = false; // Data fetching is complete, set loading flag to false
    });
  }

  Future<void> fetchPolyPoints(double driverlat, double driverlong) async {
    PolylinePoints polylinePoints = PolylinePoints();

    // Fetch route from driver's location to source
    PolylineResult driverToSourceResult = await polylinePoints.getRouteBetweenCoordinates(
      apiKey,
      PointLatLng(driverlat, driverlong),
      PointLatLng(sourcelat, sourcelong),
    );

    // Fetch route from source to destination
    PolylineResult sourceToDestResult = await polylinePoints.getRouteBetweenCoordinates(
      apiKey,
      PointLatLng(sourcelat, sourcelong),
      PointLatLng(destlat, destlong),
    );

    if (driverToSourceResult.points.isNotEmpty && sourceToDestResult.points.isNotEmpty) {
      setState(() {
        polylineCoordinates.clear(); // Clear existing polyline coordinates

        // Add driver's location to source points
        driverToSourceResult.points.forEach((PointLatLng point) => polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        ));

        // Add source to destination points
        sourceToDestResult.points.forEach((PointLatLng point) => polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        ));
      });
    }
  }


  Future<void> fetchDistance(double driverlat,double driverlong) async {
    final origins = '$driverlat,$driverlong';
    final destinations = '$destlat,$destlong';
    print(origins);
    print("asdfasdfasdf");
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
      sdrivingDistance = drivingDistance.toStringAsFixed(1);
    } else {
      throw Exception('Failed to fetch driving distance');
    }
  }


  @override
  Widget build(BuildContext context) {
    _polylines.add(Polyline(
      polylineId: PolylineId('route'),
      color: Colors.blue,
      width: 3,
      points: [LatLng(sourcelat, sourcelong), LatLng(destlat, destlong)],
      patterns: [PatternItem.dash(30), PatternItem.gap(20)],
    ));
    _panelHeightOpen = MediaQuery.of(context).size.height * .80;

    size = MediaQuery.of(context).size;

    return Scaffold(

        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('work').doc(widget.orderId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  isLoading = true;

                  return Visibility(visible: false,child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  isLoading = false;
                  return Text('Error: ${snapshot.error}');

                }

                isLoading = false;
                Map<String, dynamic>? data = snapshot.data?.data();
                print(data?['status']);
                if(data?['status']=="track"){
                  orderstatus = 'Order on the Way';
                  timevisiblity = true;
                }


                return TrackFood(destlat: destlat, destlong: destlong, sourcelat: sourcelat, sourcelong: sourcelong, orderId: widget.orderId);


              },
            ),
            Visibility(
                visible: false,
                child: Container(
                  margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.14),
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
  Widget _panel(ScrollController sc) {
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
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
              height: 12.0,
            ),
            Container(
              margin: EdgeInsets.only(left: 8,right: 8),
              padding: EdgeInsets.only(left: 5,right: 5,top: 5,bottom: 5),

              decoration: BoxDecoration(
                  border: Border.all(color:
                  Colors.grey.shade300),
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(12))),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(width: 7,),
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(35)),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: restimage, // URL of the image
                      width: 50, // Double the radius to fit the CircleAvatar
                      height: 50, // Double the radius to fit the CircleAvatar
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 84, // Double the radius to fit the CircleAvatar
                          height: 84, // Double the radius to fit the CircleAvatar
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),

                  ),
                  SizedBox(width: 7,),
                  Container(
                    padding: EdgeInsets.only(left: 5,right: 5,top: 5,bottom: 5),
                    width: MediaQuery.of(context).size.width*0.75,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 7,),
                        Text(restname,
                          maxLines: 2,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                          ),),
                        SizedBox(height: 4,),
                        Text(formattedDateTime,
                          overflow: TextOverflow.clip,
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),),

                        SizedBox(width: 7,),

                      ],
                    ),
                  ),

                ],
              ),
            ),
            SizedBox(height: 10,),
            Container(
              margin: EdgeInsets.only(left: 8,right: 8),
              padding: EdgeInsets.only(left: 5,right: 5,top: 5,bottom: 5),

              decoration: BoxDecoration(
                  border: Border.all(color:
                  Colors.grey.shade300),
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(12))),

              child: Center(
                child: Container(
                  height:dishesData.length*36,
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
                              width: 35,
                              height: 35,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(width: 5),
                            Text(dish['quantity'].toString()+" x ",style: TextStyle(fontSize: 16),),
                            Expanded(
                              child: Text(
                                dish['name'],
                                style: TextStyle(fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                              ),
                            ),
                            Text("₹ "+dish['price'].toString(),
                              style: TextStyle(
                                  fontSize: 16
                              ),),
                            SizedBox(width: 7,)
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 12.0,
            ),
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: Radius.elliptical(20, 60),topRight: Radius.elliptical(20, 60)),

                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(left: 8,right: 8),
                    height: MediaQuery.of(context).size.height * 0.13,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30)),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        // Handle onTap action here

                      },
                      child: AbsorbPointer(
                        absorbing: true, // Set to true to prevent interaction with the child widget
                        child: GestureDetector(
                          onTap: () {
                            // Handle onTap action here

                          },
                          child: GoogleMap(
                            zoomControlsEnabled: false, // Disable zoom controls
                            myLocationButtonEnabled: false, // Disable current location button
                            myLocationEnabled: false,

                            initialCameraPosition: CameraPosition(
                              target: LatLng(destlat,destlong),
                              zoom: 17,
                            ),
                            markers: Set<GoogleMapsMarker.Marker>.of([
                              GoogleMapsMarker.Marker(
                                markerId: MarkerId('marker_1'),
                                position: LatLng(destlat,destlong),
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
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 8,right: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(width: 1.0, color: Colors.grey.shade300),
                      right: BorderSide(width: 1.0, color: Colors.grey.shade300),
                      bottom: BorderSide(width: 1.0, color: Colors.grey.shade300),
                    ),
                    color: Colors.white,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12),bottomRight: Radius.circular(12)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset("assets/house.png",height: 30,width: 30,),
                      Container(
                        padding: EdgeInsets.only(left: 5,right: 5,top: 10,bottom: 10),
                        width: MediaQuery.of(context).size.width*0.7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(width: 7,),
                            Text("Delivery at address",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),),
                            SizedBox(height: 4,),
                            Text(deladdress,
                              maxLines: 2,
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),),
                            SizedBox(height: 4,),

                            Text("Add instructions for the worker",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),),
                            SizedBox(width: 7,),

                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios,color: Colors.black,)
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 10,),
            Container(
              margin: EdgeInsets.only(left: 8,right: 8),

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
                children: [
                  CircleAvatar(
                    radius: MediaQuery.of(context).size.width*0.06,
                    backgroundImage: NetworkImage(
                      APIs.me.image,
                    ),
                  ),
                  SizedBox(width: 10), // Added SizedBox for spacing
                  Container( // Added Expanded to allow the container to take remaining space
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Align text to start
                      mainAxisAlignment: MainAxisAlignment.center, // Vertically center text
                      children: [
                        Row( // Added Row to contain text and arrow
                          children: [
                            Text(
                              "Nishant "+", ",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: MediaQuery.of(context).size.height*0.02,
                              ),
                            ),
                            GestureDetector(
                              onTap: (){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => EditProfileScreen(bookingID: widget.orderId, type: 'work',)),
                                );
                              },
                              child: Text(
                                "+91 8630277740",
                                style: TextStyle(
                                  color: Colors.pink,
                                  fontWeight: FontWeight.w500,
                                  fontSize: MediaQuery.of(context).size.height*0.02,
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
                          width: MediaQuery.of(context).size.width*0.7,
                          child: Text(
                            "Contact Number will be shared to the Worker",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: MediaQuery.of(context).size.height*0.017,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10), // Added SizedBox for spacing


                ],
              ),
            ),

          ],
        ));
  }
  Widget _button(String label, IconData icon, Color color) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Icon(
            icon,
            color: Colors.white,
          ),
          decoration:
          BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.15),
              blurRadius: 8.0,
            )
          ]),
        ),
        SizedBox(
          height: 12.0,
        ),
        Text(label),
      ],
    );
  }
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      _isMapReady = true;
    });
  }

  void _updateCameraPosition() {
    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLng(_currentPosition));
    }
  }
  Future<void> _fetchMarkerIcon() async {
    try {
      var response = await http.get(Uri.parse('https://cdn.dribbble.com/userupload/4359157/file/original-f81ffab8bef01d44252b106f7d0428cb.png?resize=2048x1535')); // Replace with your image URL
      if (response.statusCode == 200) {
        setState(() {
          _markerIconBytes = response.bodyBytes;
        });
      } else {
        print('Failed to load marker icon: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching marker icon: $e');
    }
  }
}



