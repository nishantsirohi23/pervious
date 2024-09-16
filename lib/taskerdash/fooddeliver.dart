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

class FoodDeliver extends StatefulWidget {
  final double destlat;
  final double destlong;
  final double sourcelat;
  final double sourcelong;
  final String workid;

  const FoodDeliver({Key? key,required this.destlat,required this.destlong,required this.sourcelat,required this.sourcelong,required this.workid}) : super(key: key);

  @override
  _DeliveryBoyScreenState createState() => _DeliveryBoyScreenState(destlat, destlong, sourcelat, sourcelong);
}

class _DeliveryBoyScreenState extends State<FoodDeliver> {
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
    FirebaseFirestore.instance.collection('orders').doc(widget.workid).snapshots().listen((DocumentSnapshot snapshot) {
      setState(() {
        paymentdone = snapshot['payment'] ?? false;

      });
    });
  }
  @override
  void initState() {
    super.initState();
    print(destlat);
    print(destlong);
    print(sourcelat);
    print(sourcelong);
    print(widget.workid);


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
  int workAmount = 0;
  String workamountstr = "";
  String workPriority = '';
  String workBy = '';
  String firebaseDate = '';
  String address = '';
  double latitude = 0.0;
  double longitude = 0.0;
  bool paymentdone =  false;
  String userName = "";
  String userImage = "";
  String usernumber = "";
  List<Map<String, dynamic>> fileData=  [];
  bool formto = true;
  String _receivedfrom = "";
  String _receivedto = "";
  List<Map<String, dynamic>> dishesData = [];

  Future<void> getalldata() async {
    final CollectionReference workCollection = FirebaseFirestore.instance
        .collection('orders');
    DocumentSnapshot workSnapshot = await workCollection.doc(widget.workid).get();
    print(workSnapshot);
    print(workSnapshot['deliveryaddress']);
    setState(() async {
      dishesData = (workSnapshot['dishes'] as List<dynamic>).cast<Map<String, dynamic>>();

      workAmount = workSnapshot['orderamount'];
      workBy = workSnapshot['orderBy'];
      workName = workSnapshot['restname'];
      _receivedfrom = workSnapshot['restaddress'];
      _receivedto = workSnapshot['deliveryaddress'];



      final CollectionReference workCollection1 = FirebaseFirestore.instance
          .collection('users');
      DocumentSnapshot workSnapshot1 = await workCollection1.doc(workSnapshot['orderBy']).get();
      userName = workSnapshot1['name'];
      userImage = workSnapshot1['image'];
      usernumber = workSnapshot1['mobile'];
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
        distanceFilter: 1, // meters
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
          child: Text(""),
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
