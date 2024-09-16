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
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/src/types/marker.dart' as GoogleMapsMarker;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:perwork/screens/profilescreen.dart';
import 'package:perwork/widgets/showbill.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../api/apis.dart';
import '../../chat/pages/home.dart';
import '../../try/editprofilescreen.dart';
import '../../try/my_global.dart';
import '../../try/pigeon.dart';
import '../costumer/pickdeliverylocation.dart';

class TrackItem extends StatefulWidget {
  final double destlat;
  final double destlong;
  final double sourcelat;
  final double sourcelong;
  final String orderId;

  const TrackItem({Key? key,required this.destlat,required this.destlong,required this.sourcelat,required this.sourcelong,required this.orderId}) : super(key: key);

  @override
  State<TrackItem> createState() => _NavigationState(destlat, destlong, sourcelat, sourcelong);
}

class _NavigationState extends State<TrackItem> {
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
  int totalamount = 0;
  int orderamount = 0;
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
  bool timevisiblity = false;
  String profid = "";
  String workername = "";
  String workernumber = "";
  String workerimage  = "";
  String totalrating = "";
  double distance = 0.0;
  late Razorpay _razorpay;
  bool showbill = false;
  bool _isPaymentInProgress = false;
  int gst = 0;
  int workertip = 0;
  int deliveryfee = 0;
  bool ten = false;
  bool twenty = false;
  bool thirty = false;

  late Future<DocumentSnapshot<Map<String, dynamic>>> _fetchDataFuture;
  Future<void> refreshPaymentDate() async {

    final CollectionReference workCollection = FirebaseFirestore.instance
        .collection('orders');
    DocumentSnapshot workSnapshot = await workCollection.doc(widget.orderId).get();
    setState(() {
      paymentdone = workSnapshot['payment'] ?? true;
    });
    if(paymentdone){
      setState(() {
        showbill = true;
        totalamount = workSnapshot['totalamount'].round();
        orderamount = workSnapshot['orderamount'];
        workertip = 1;
        deliveryfee = workSnapshot['deliveryFee'];
      });
    }

  }

  @override
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print(response.orderId);
    print(response.paymentId);
    print(response.signature);
    setState(() {

      _isPaymentInProgress = false; // Payment completed, so set the flag to false
    });
    APIs.makefoodPayment(widget.orderId,response.paymentId.toString());
    //refreshPaymentDate();

    // Show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          // Custom dialog styling

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.27,
            width: MediaQuery.of(context).size.width * 0.95,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context);

                        refreshPaymentDate();
// Close the dialog
                      },
                    ),
                  ],
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.17,
                  width: MediaQuery.of(context).size.width,
                  child: Lottie.asset('assets/lottie/payment.json'),
                ),
                Text(
                  "Payment Successful",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    print(response);
    setState(() {
      _isPaymentInProgress = false; // Payment completed (even if it failed), so set the flag to false
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context)
      {
        return Dialog(
          // Custom dialog styling

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            height: MediaQuery
                .of(context)
                .size
                .height * 0.27,
            width: MediaQuery
                .of(context)
                .size
                .width * 0.95,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {

                        Navigator.pop(context);
                        // Close the dialog
                      },
                    ),
                  ],
                ),
                Container(
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.17,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  child: Lottie.asset('assets/lottie/payment.json'),
                ),
                Text(
                  "Payment Failed!",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  void _handleExternalWallet(ExternalWalletResponse response) {
    print(response);
    setState(() {
      _isPaymentInProgress = false; // Payment completed (via external wallet), so set the flag to false
    });
  }
  void _openCheckout(double amount,int workertip) {
    var options = {
      'key': 'rzp_live_ymUGpkKEgzMtUI',
      'amount': amount * 100, // amount in the smallest currency sub-unit
      'name': 'PerPenny',
      'description': 'Fine T-Shirt',
      'prefill': {
        'contact': '9000090000',
        'email': 'gaurav.kumar@example.com'
      }
    };
    try {
      setState(() {
        _isPaymentInProgress = true; // Payment process started, so set the flag to true
      });
      // Show loading indicator

      _razorpay.open(options);
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isPaymentInProgress = false; // Payment process failed, so set the flag to false
      });
    }
  }
  List<Map<String, dynamic>> _itemList = [];

  Future<void> _fetchItems() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .collection('items')
          .get();

      setState(() {
        _itemList = querySnapshot.docs.map((doc) {
          return doc.data() as Map<String, dynamic>;
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }
  void initState() {
    super.initState();
    _fetchItems();
    getalldata();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _userDataStream = FirebaseFirestore.instance.collection('prof').doc('112').snapshots();

    _fetchDataFuture = FirebaseFirestore.instance.collection('orders').doc(widget.orderId).get();
    _fabHeight = _initFabHeight;

    _fetchMarkerIcon();
    getalldata();
    getStreamData();




  }
  bool pickedup = false;
  void getStreamData() async {
    FirebaseFirestore.instance.collection('orders').doc(widget.orderId).snapshots().listen((DocumentSnapshot snapshot) {
      setState(()  async {
        String status = snapshot['status'];
        if(status=="track"){
          setState(() {
            orderstatus = "Order on the way";
            timevisiblity = true;
            profid = snapshot['assigned'];
            pickedup = snapshot['picked'];


          });



        }
        _userDataStream = FirebaseFirestore.instance.collection('prof').doc(profid).snapshots();
        final CollectionReference profCollection = FirebaseFirestore.instance
            .collection('prof');
        DocumentSnapshot profSnapshot = await profCollection.doc(profid).get();
        setState(() {
          workerimage = profSnapshot['profile_image_url'] ?? '';
          workername = profSnapshot['name'] ?? '';
          workernumber = profSnapshot['phone_number'] ?? "";
          totalrating = profSnapshot['totalrating'] ?? '';
        });
        getpreviouslocation();

        if(status=="completed") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ProfileScreen()),
          );
        }
        print(status);

      });

    });

  }
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _userDataStream;
  Set<GoogleMapsMarker.Marker> _markers = <GoogleMapsMarker.Marker>{};
  Set<GoogleMapsMarker.Marker> _markers1 = <GoogleMapsMarker.Marker>{};
  List<String> words = APIs.me.name.split(' ');
  String minemobile = "";


  Future<void> getalldata() async {
    if(APIs.me.mobile==""){
      minemobile = "Add Contact";
    }
    else{
      minemobile = APIs.me.mobile;
    }
    final CollectionReference workCollection = FirebaseFirestore.instance
        .collection('orders');
    DocumentSnapshot workSnapshot = await workCollection.doc(widget.orderId).get();
    setState(() {

      DateTime dateTime = workSnapshot['orderPlacedAt'].toDate();
      DateTime localDateTime = dateTime.toLocal();
      formattedDateTime = DateFormat("d MMMM y 'at' hh:mm a").format(localDateTime);
      String status = workSnapshot['status'];
      distance =  workSnapshot['distance'];
      restname = "restname";
      restimage = "https://firebasestorage.googleapis.com/v0/b/perwork.appspot.com/o/categories%2Fcleaning.png?alt=media&token=3860681e-1f1e-4806-9729-0f1cc52ce412";
      double totalAmountDouble = workSnapshot['totalamount']; // Assuming workSnapshot['totalamount'] is double
      int totalAmountInt = totalAmountDouble.toInt(); // Convert double to int
      orderamount = workSnapshot['orderamount'];

// Now you can use totalAmountInt as an int value
      totalamount = totalAmountInt;
      paymentdone = workSnapshot['payment'];
      showbill = paymentdone;
      deliveryfee = workSnapshot['deliveryFee'];
      restaddress = '';
      deladdress = workSnapshot['deliveryaddress'];
      print(deladdress);
      dishesData = [];

      if(paymentdone){
        showbill = true;
        totalamount = workSnapshot['totalamount'].round();
        orderamount = workSnapshot['orderamount'];
        workertip = workSnapshot['tip'];
        deliveryfee = workSnapshot['deliveryFee'];
      }

      if(status=="waiting"){
        orderstatus = "Preparing your Order";
        timevisiblity = false;
      }
      else{
        orderstatus = "Order on the way";
        timevisiblity = true;
      }

    });
    ();
    setMarker2();
    setMarker3();
    sourcemarker();
    destmarker();
    print(totalamount);




  }
  void setMarker1() async{
    setState(() async {
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
    });
    setState(() {
      _markers;
    });


  }
  void setMarker2() async{
    print(restimage);
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
        position: LatLng(destlong,destlat),
      ),


    );
    isLoadingData =false;

  }
  void sourcemarker() async{

    _markers1.add(
      GoogleMapsMarker.Marker(
        markerId: MarkerId('downloadResizePictureCircle2232345345'),
        icon: await MarkerIcon.downloadResizePictureCircle(
            restimage,
            size: 150,
            addBorder: true,
            borderColor: Colors.white,
            borderSize: 15),
        position: LatLng(sourcelat, sourcelong),
      ),


    );
    isLoadingData =false;

  }
  void destmarker() async{

    _markers1.add(
      GoogleMapsMarker.Marker(
        markerId: MarkerId('downloadResizePictureCircle22453'),
        icon: await MarkerIcon.downloadResizePictureCircle(
            APIs.me.image,
            size: 150,
            addBorder: true,
            borderColor: Colors.white,
            borderSize: 15),
        position: LatLng(destlong,destlat),
      ),


    );
    isLoadingData =false;

  }
  Future<void> getpreviouslocation() async {
    final CollectionReference workCollection =
    FirebaseFirestore.instance.collection('prof');
    DocumentSnapshot workSnapshot =
    await workCollection.doc(profid).get();
    double lat = workSnapshot['latitude'];
    double long = workSnapshot['longitude'];
    setMarker1();

    setState(() {
      isLoading = false;
      _currentPosition = LatLng(lat, long);
      print(_currentPosition);
    });

    fetchMapData(lat,long);
  }
  Future<void> fetchMapData(double driverlat,double driverlong) async {

    await Future.wait([fetchPolyPoints( ), fetchDistance( driverlat, driverlong)]);
    setState(() {
      isLoading = false; // Data fetching is complete, set loading flag to false
    });
  }
  Future<void> fetchPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    // Fetch route from source to destination
    PolylineResult sourceToDestResult = await polylinePoints.getRouteBetweenCoordinates(
      Globals.apiKey,
      PointLatLng(sourcelat, sourcelong),
      PointLatLng(destlong,destlat),
    );

    if (sourceToDestResult.points.isNotEmpty) {
      setState(() {
        polylineCoordinates.clear(); // Clear existing polyline coordinates

        // Add source to destination points
        sourceToDestResult.points.forEach((PointLatLng point) => polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        ));
      });
    }
  }
  var sdrivingDuration = "";
  Future<void> fetchDistance(double driverlat, double driverlong) async {
    final apiKey = Globals.apiKey;
    final driverLocation = '$driverlat,$driverlong';
    final sourceLocation = '$sourcelat,$sourcelong';
    final destLocation = '$destlong,$destlat';

    if(!pickedup){
      // Fetch distance and duration from driver location to source location
      final sourceUrl = Uri.parse('https://maps.googleapis.com/maps/api/distancematrix/json'
          '?origins=$driverLocation'
          '&destinations=$sourceLocation'
          '&mode=driving'
          '&key=$apiKey');

      final sourceResponse = await http.get(sourceUrl);

      if (sourceResponse.statusCode == 200) {
        final sourceData = json.decode(sourceResponse.body);
        final sourceDistanceInMeters = sourceData['rows'][0]['elements'][0]['distance']['value'];
        final sourceDurationInSeconds = sourceData['rows'][0]['elements'][0]['duration']['value'];

        // Fetch distance and duration from source location to destination location
        final destUrl = Uri.parse('https://maps.googleapis.com/maps/api/distancematrix/json'
            '?origins=$sourceLocation'
            '&destinations=$destLocation'
            '&mode=driving'
            '&key=$apiKey');

        final destResponse = await http.get(destUrl);

        if (destResponse.statusCode == 200) {
          final destData = json.decode(destResponse.body);
          final destDistanceInMeters = destData['rows'][0]['elements'][0]['distance']['value'];
          final destDurationInSeconds = destData['rows'][0]['elements'][0]['duration']['value'];

          // Combine distances and durations
          final totalDistanceInMeters = sourceDistanceInMeters + destDistanceInMeters;
          final totalDurationInSeconds = sourceDurationInSeconds + destDurationInSeconds;

          // Convert to km and minutes
          drivingDistance = totalDistanceInMeters / 1000.0;
          sdrivingDistance = drivingDistance.toStringAsFixed(1);

          var drivingDuration = totalDurationInSeconds / 60;
          sdrivingDuration = drivingDuration.ceil().toString();

          setState(() {
            sdrivingDuration = drivingDuration.ceil().toString();
          });
          print(sdrivingDuration);
        } else {
          throw Exception('Failed to fetch driving distance and duration from source to destination');
        }
      } else {
        throw Exception('Failed to fetch driving distance and duration from driver to source');
      }
    }
    else{
      final driverUrl = Uri.parse('https://maps.googleapis.com/maps/api/distancematrix/json'
          '?origins=$driverLocation'
          '&destinations=$destLocation'
          '&mode=driving'
          '&key=$apiKey');

      final driverResponse = await http.get(driverUrl);

      if (driverResponse.statusCode == 200) {
        final driverData = json.decode(driverResponse.body);
        final driverDistanceInMeters = driverData['rows'][0]['elements'][0]['distance']['value'];
        final driverDurationInSeconds = driverData['rows'][0]['elements'][0]['duration']['value'];

        // Convert to km and minutes
        final totalDistanceInMeters = driverDistanceInMeters;
        final totalDurationInSeconds = driverDurationInSeconds;

        drivingDistance = totalDistanceInMeters / 1000.0;
        sdrivingDistance = drivingDistance.toStringAsFixed(1);

        var drivingDuration = totalDurationInSeconds / 60;
        sdrivingDuration = drivingDuration.ceil().toString();

        setState(() {
          sdrivingDuration = drivingDuration.ceil().toString();
        });
        print(sdrivingDuration);
      } else {
        throw Exception('Failed to fetch driving distance and duration from driver to destination');
      }


    }
  }

  @override
  Widget build(BuildContext context) {
    _polylines.add(Polyline(
      polylineId: PolylineId('route'),
      color: Colors.pink,
      width: 3,
      points: [LatLng(sourcelat, sourcelong), LatLng(destlong,destlat)],
      patterns: [PatternItem.dash(30), PatternItem.gap(20)],
    ));
    _panelHeightOpen = MediaQuery.of(context).size.height * .80;

    size = MediaQuery.of(context).size;


    return Scaffold(
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Stack(
              children: [

                // Loading indicator while fetching data
                if (isLoading)
                  Center(
                    child: CircularProgressIndicator(),
                  ),
                Container(
                  margin: EdgeInsets.only(top: size.height * 0.1, left: size.width - 130),
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFffbb02),
                        const Color(0xFFffbb02),
                      ],
                      begin: const FractionalOffset(0.0, 0.0),
                      end: const FractionalOffset(1.0, 0.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp,
                    ),
                  ),
                  width: 115,
                  padding: EdgeInsets.only(left: 9, right: 9),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$sdrivingDistance Km",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          "Your Location",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SlidingUpPanel(
                  maxHeight: _panelHeightOpen,
                  minHeight: _panelHeightClosed,
                  parallaxEnabled: true,
                  parallaxOffset: .5,
                  body: timevisiblity?_body():GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(widget.sourcelat, widget.sourcelong),
                      zoom: 15.5,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    polylines: _polylines,
                    markers: _markers1,


                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                  ),
                  panelBuilder: (sc) => _panel(sc),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18.0),
                      topRight: Radius.circular(18.0)),
                  onPanelSlide: (double pos) => setState(() {
                    _fabHeight = pos * (_panelHeightOpen - _panelHeightClosed) +
                        _initFabHeight;
                  }),
                ),
                Positioned(
                    top: 0,
                    right: 0,
                    left: 0,
                    child: Container(
                        padding: EdgeInsets.only(top: 55),
                        height: size.height*0.18,
                        width: size.width,
                        decoration: BoxDecoration(
                            color: Colors.pink
                        ),
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: (){
                                Navigator.pop(context);
                              },
                              child:Container(
                                margin: EdgeInsets.only(left: 16,top: 5),
                                child: Icon(Icons.arrow_back_ios,color: Colors.white,),
                              ),
                            ),
                            Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(orderstatus,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 21,
                                        fontWeight: FontWeight.w500
                                    ),),

                                  Container(
                                    margin: EdgeInsets.only(bottom: 20),
                                    width: size.width*0.48,
                                    padding: EdgeInsets.only(top: 8,bottom: 8),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white.withOpacity(0.5)
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.asset('assets/clockwhite.png',height: 18,width: 18,),
                                        Visibility(
                                            visible: timevisiblity,
                                            child: Row(children: [
                                              SizedBox(width: 4,),
                                              Text(sdrivingDistance+" mins",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500
                                                ),),
                                              SizedBox(width: 5,),
                                              Container(
                                                width: 7, // Adjust width and height to change the size of the dot
                                                height: 7,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle, // Shape of the container
                                                  color: Colors.white, // Color of the dot
                                                ),
                                              ),
                                            ],)),
                                        SizedBox(width: 5,),

                                        Text("On Time",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500
                                          ),),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        )
                    )),



              ],
            ),
            Visibility(
                visible:  isLoadingData ,
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

            Visibility(
                visible: timevisiblity,
                child: Column(
                  children: [
                    SizedBox(
                      height: 12.0,
                    ),
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
                        child: Column(
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.all(Radius.circular(35)),
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl: workerimage, // URL of the image
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
                                SizedBox(width: 10), // Added SizedBox for spacing
                                Container( // Added Expanded to allow the container to take remaining space
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start, // Align text to start
                                    mainAxisAlignment: MainAxisAlignment.center, // Vertically center text
                                    children: [


                                      Row( // Added Row to contain text and arrow
                                        children: [
                                          Text(
                                            workername,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500,
                                              fontSize: MediaQuery.of(context).size.height*0.02,
                                            ),
                                          ),


                                        ],
                                      ),
                                      SizedBox(height: 1), // Added SizedBox for spacing
                                      Container(
                                        width: MediaQuery.of(context).size.width*0.7,
                                        child: Text(
                                          totalrating+"+ star deliveries",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                          style: TextStyle(
                                            color: Colors.black.withOpacity(0.7),
                                            fontSize: MediaQuery.of(context).size.height*0.017,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: size.width*0.7,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            OutlinedButton.icon(
                                              onPressed: () {
                                                print("usernumber from track food");
                                                print(workernumber);
                                                FlutterPhoneDirectCaller.callNumber(workernumber);
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
                                            ),
                                            OutlinedButton.icon(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) =>   HomePage(profid: profid)),
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

                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Visibility(child: SizedBox(height: 5,),),
                            Visibility(child: Container(
                              height: 1,
                              color: Colors.grey.shade300,
                            ),),
                            Visibility(
                              visible: true,
                              child: Container(
                                padding: EdgeInsets.all(8),
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  children: [
                                    Image.asset("assets/star.png",height: 25,width: 25,),
                                    SizedBox(width: 11,),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Rate "+workername,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),),
                                        RatingBar.builder(
                                          itemSize: 20,
                                          initialRating: 5,
                                          minRating: 1,
                                          direction: Axis.horizontal,
                                          allowHalfRating: true,
                                          itemCount: 5,
                                          itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                                          itemBuilder: (context, _) => Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 1,
                                          ),
                                          onRatingUpdate: (rating) {
                                            setState(() {

                                            });
                                          },
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),),


                          ],
                        )
                    ),
                  ],
                )),
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
                    child:  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _itemList.map((itemData) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 5, top: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.network(
                                itemData['image'],
                                height: 30,
                                width: 30,
                              ),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            itemData['quantity'].toString(),
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          Text(
                                            " x ",
                                            style: TextStyle(fontSize: 17),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.6,
                                            child: Text(
                                              '${itemData['name']}',
                                              maxLines: 1,
                                              overflow: TextOverflow.clip,
                                              style: TextStyle(fontSize: 17),
                                            ),
                                          )
                                        ],
                                      ),
                                      Text("₹ "+itemData['price'])
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  ),
                                ],
                              ),
                              Divider(), // Add a divider between items
                            ],
                          ),
                        );
                      }).toList(),
                    )
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
                              target: LatLng(destlong,destlat),
                              zoom: 17,
                            ),
                            markers: Set<GoogleMapsMarker.Marker>.of([
                              GoogleMapsMarker.Marker(
                                markerId: MarkerId('marker_1'),
                                position: LatLng(destlong,destlat),
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
                              words.first+", ",
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
                                minemobile,
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
                  SizedBox(width: 10),



                ],
              ),
            ),
            Visibility(
              visible: !paymentdone,
              child: Container(
                margin: EdgeInsets.only(top: 7,bottom: 10),
                child: ShowBill(deliveryfee: deliveryfee.toString(),gst: 0.toString(),finalworkeramount: orderamount.toString(),grandtotal: totalamount.toString(),),
              ),
            ),
            Visibility(
              visible: !paymentdone,
              child:GestureDetector(
                onTap: () {

                  gst = 0;
                  workertip = 0;


                  int grandtotal = deliveryfee+gst+workertip+totalamount;
                  showModalBottomSheet(
                    backgroundColor: Colors.white,
                    context: context,
                    builder: (BuildContext context) {
                      return StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
                              color: Colors.white,
                            ),
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.only(left: 20,right: 20,top: 10,bottom: 20),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 60,
                                    height: 7,
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Text("Bill Details:",
                                        style: TextStyle(
                                            color: Colors.pink,
                                            fontSize: MediaQuery.of(context).size.height*0.025
                                        ),),
                                      SizedBox(height: 8,),
                                      Container(
                                        width: MediaQuery.of(context).size.width,
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.2),
                                              spreadRadius: 1,
                                              blurRadius: 3,
                                              offset: Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text("Order Amount",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: MediaQuery.of(context).size.height*0.021
                                                  ),),
                                                Text("Rs. "+orderamount.toString(),
                                                  style: TextStyle(
                                                      color: Colors.pink,
                                                      fontSize: MediaQuery.of(context).size.height*0.021
                                                  ),),
                                              ],
                                            ),
                                            CustomPaint(
                                              size: Size(MediaQuery.of(context).size.width*0.9, 10),
                                              painter: DashedLinePainter(),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text("Delivery Fee",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: MediaQuery.of(context).size.height*0.019
                                                  ),),
                                                Text("Rs. "+deliveryfee.toString(),
                                                  style: TextStyle(
                                                      color: Colors.pink,
                                                      fontSize: MediaQuery.of(context).size.height*0.019
                                                  ),),
                                              ],
                                            ),
                                            Visibility(
                                              visible: APIs.me.havepremium,
                                              child: Container(
                                                child: Text("You got 25% off on platform fees",
                                                  style: TextStyle(
                                                      color: Colors.black.withOpacity(0.7)
                                                  ),),
                                              ),
                                            ),

                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text("Platform Fee",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: MediaQuery.of(context).size.height*0.019
                                                  ),),
                                                Text("Rs. 5",
                                                  style: TextStyle(
                                                      color: Colors.pink,
                                                      fontSize: MediaQuery.of(context).size.height*0.019
                                                  ),),
                                              ],
                                            ),

                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text("Worker Tip",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: MediaQuery.of(context).size.height*0.019
                                                  ),),
                                                Text("Rs. "+workertip.toString(),
                                                  style: TextStyle(
                                                      color: Colors.pink,
                                                      fontSize: MediaQuery.of(context).size.height*0.019
                                                  ),),
                                              ],
                                            ),
                                            CustomPaint(
                                              size: Size(MediaQuery.of(context).size.width*0.9, 10),
                                              painter: DashedLinePainter(),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text("Total Amount",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: MediaQuery.of(context).size.height*0.021
                                                  ),),
                                                Text("Rs. "+totalamount.toString(),
                                                  style: TextStyle(
                                                      color: Colors.pink,
                                                      fontSize: MediaQuery.of(context).size.height*0.021
                                                  ),),
                                              ],
                                            ),


                                          ],
                                        ),
                                        // Add child widgets here if needed
                                      ),
                                      SizedBox(height: 5,),

                                      Text("Pay Tip:",
                                        style: TextStyle(
                                            color: Colors.pink,
                                            fontSize: MediaQuery.of(context).size.height*0.025
                                        ),),
                                      SizedBox(height: 8,),
                                      Container(
                                        width: MediaQuery.of(context).size.width,
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.2),
                                              spreadRadius: 1,
                                              blurRadius: 3,
                                              offset: Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: MediaQuery.of(context).size.width*0.6,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text("Pay your worker",
                                                          style: TextStyle(
                                                              color: Colors.black,
                                                              fontWeight: FontWeight.w500,
                                                              fontSize: MediaQuery.of(context).size.height*0.025
                                                          ),),
                                                        Text("Your tip means a lot! 100% of your tip will directly go to the worker",
                                                          style: TextStyle(
                                                              color: Colors.black.withOpacity(0.7),
                                                              fontWeight: FontWeight.w500,
                                                              fontSize: MediaQuery.of(context).size.height*0.016
                                                          ),),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    width: MediaQuery.of(context).size.width*0.25-2,
                                                    child: Image.asset("assets/onb2.png",),
                                                  )
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 3,),
                                            Container(
                                              child: SingleChildScrollView(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: (){
                                                        setState(() {
                                                          ten = !ten;
                                                          twenty = false;
                                                          thirty = false;
                                                          if(ten){
                                                            workertip = 10;
                                                          }
                                                          else{
                                                            workertip = 0;
                                                          }

                                                          grandtotal = deliveryfee.toInt() + gst + workertip +  totalamount;
                                                          // Update the value of `ten`
                                                        });
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.only(left: 18, right: 18, top: 5, bottom: 5),
                                                        decoration: BoxDecoration(
                                                          color: ten ? Colors.pink.withOpacity(0.4): Colors.white,
                                                          border: Border.all(
                                                            color: Colors.grey, // Border color
                                                          ),
                                                          borderRadius: BorderRadius.circular(10), // Border radius
                                                        ),
                                                        child: Text(
                                                          "₹10",
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 18,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 15,),
                                                    GestureDetector(
                                                      onTap: (){
                                                        setState(() {
                                                          twenty = !twenty;
                                                          ten = false;
                                                          thirty = false;
                                                          if(twenty){
                                                            workertip = 20;
                                                          }
                                                          else{
                                                            workertip = 0;
                                                          }

                                                          grandtotal = deliveryfee.toInt() + gst + workertip +  totalamount;
                                                          // Update the value of `ten`
                                                        });
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.only(left: 18, right: 18, top: 5, bottom: 5),
                                                        decoration: BoxDecoration(
                                                          color: twenty ? Colors.pink.withOpacity(0.4): Colors.white,
                                                          border: Border.all(
                                                            color: Colors.grey, // Border color
                                                          ),
                                                          borderRadius: BorderRadius.circular(10), // Border radius
                                                        ),
                                                        child: Text(
                                                          "₹20",
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 18,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 15,),

                                                    GestureDetector(
                                                      onTap: (){
                                                        setState(() {
                                                          thirty= !thirty;
                                                          ten = false;
                                                          twenty = false;
                                                          if(thirty){
                                                            workertip = 30;
                                                          }
                                                          else{
                                                            workertip = 0;
                                                          }

                                                          grandtotal = deliveryfee.toInt() + gst + workertip +  totalamount;
                                                          // Update the value of `ten`
                                                        });
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.only(left: 18, right: 18, top: 5, bottom: 5),
                                                        decoration: BoxDecoration(
                                                          color: thirty ? Colors.pink.withOpacity(0.4): Colors.white,
                                                          border: Border.all(
                                                            color: Colors.grey, // Border color
                                                          ),
                                                          borderRadius: BorderRadius.circular(10), // Border radius
                                                        ),
                                                        child: Text(
                                                          "₹30",
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 18,
                                                          ),
                                                        ),
                                                      ),
                                                    )

                                                  ],
                                                ),
                                                scrollDirection: Axis.horizontal,
                                              ),
                                            )


                                          ],
                                        ),
                                        // Add child widgets here if needed
                                      ),

                                      SizedBox(height: 10),
                                      GestureDetector(
                                        onTap: (){
                                          Navigator.pop(context);
                                          APIs.AddTiptoFood(widget.orderId, totalamount, workertip);

                                          _openCheckout(totalamount.toDouble(), workertip);
                                        },
                                        child: Container(
                                          height: 50,
                                          width: MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20.0), // Adjust the value as needed
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [Color(0xffE100FF), Color(0xFFfc67fa)], // Example gradient colors
                                            ),
                                          ),
                                          child: Center(
                                            child: Text('Pay Now',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 19

                                              ),),
                                          ),

                                        ),
                                      ),
                                      SizedBox(height: 20),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(left: 12,right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xffE100FF), Color(0xFFfc67fa)],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Pay Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
                visible: showbill,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    color: Colors.white,

                  ),
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(11),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Bill Details:",
                          style: TextStyle(
                              color: Colors.pink,
                              fontSize: MediaQuery.of(context).size.height*0.025
                          ),),
                        SizedBox(height: 5,),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Order Amount",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: MediaQuery.of(context).size.height*0.021
                                    ),),
                                  Text("Rs. "+orderamount.toString(),
                                    style: TextStyle(
                                        color: Colors.pink,
                                        fontSize: MediaQuery.of(context).size.height*0.021
                                    ),),
                                ],
                              ),
                              CustomPaint(
                                size: Size(MediaQuery.of(context).size.width*0.9, 10),
                                painter: DashedLinePainter(),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Delivery Fee",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: MediaQuery.of(context).size.height*0.019
                                    ),),
                                  Text("Rs. "+deliveryfee.toString(),
                                    style: TextStyle(
                                        color: Colors.pink,
                                        fontSize: MediaQuery.of(context).size.height*0.019
                                    ),),
                                ],
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Platform Fee",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: MediaQuery.of(context).size.height*0.019
                                    ),),
                                  Text("Rs. 5",
                                    style: TextStyle(
                                        color: Colors.pink,
                                        fontSize: MediaQuery.of(context).size.height*0.019
                                    ),),
                                ],
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Worker Tip",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: MediaQuery.of(context).size.height*0.019
                                    ),),
                                  Text("Rs. "+workertip.toString(),
                                    style: TextStyle(
                                        color: Colors.pink,
                                        fontSize: MediaQuery.of(context).size.height*0.019
                                    ),),
                                ],
                              ),
                              CustomPaint(
                                size: Size(MediaQuery.of(context).size.width*0.9, 10),
                                painter: DashedLinePainter(),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Total Amount",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: MediaQuery.of(context).size.height*0.021
                                    ),),
                                  Text("Rs. "+totalamount.toString(),
                                    style: TextStyle(
                                        color: Colors.pink,
                                        fontSize: MediaQuery.of(context).size.height*0.021
                                    ),),
                                ],
                              ),


                            ],
                          ),
                          // Add child widgets here if needed
                        ),
                        SizedBox(height: 5,),



                      ],
                    ),
                  ),
                )
            ),

          ],
        ));
  }
  Widget _body() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _userDataStream,
      builder: (context, snapshot) {
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
        if (!snapshot.hasData || snapshot.data!.data() == null) {
          return Center(
            child: Text('No data found for the provided prof ID.'),
          );
        }

        var userData = snapshot.data!.data()!;
        var latitude = userData['latitude'];
        var longitude = userData['longitude'];

        setMarker1();

        if (_currentPosition.latitude != latitude || _currentPosition.longitude != longitude) {
          setMarker1();

          print(latitude);
          print(longitude);

          _currentPosition = LatLng(latitude, longitude);

          // Update current position
          // Call function when values change
          _updateCameraPosition();
          // Fetch map data
          fetchMapData(latitude, longitude);
        }


        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(_currentPosition.latitude, _currentPosition.longitude),
                zoom: 15,
              ),
              myLocationEnabled: false,
              zoomGesturesEnabled: true,
              buildingsEnabled: true,
              cameraTargetBounds: CameraTargetBounds.unbounded,
              compassEnabled: true,
              scrollGesturesEnabled: true,
              rotateGesturesEnabled: true,
              tiltGesturesEnabled: true,
              myLocationButtonEnabled: false,
              polylines: {
                Polyline(
                  polylineId: PolylineId("route"),
                  points: polylineCoordinates,
                  color: Colors.pink,
                  width: 3,
                )
              },
              markers: _markers,


              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
            // Loading indicator while fetching data
            if (isLoading)
              Center(
                child: CircularProgressIndicator(),
              ),
            Container(
              margin: EdgeInsets.only(top: size.height * 0.1, left: size.width - 130),
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFffbb02),
                    const Color(0xFFffbb02),
                  ],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(1.0, 0.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp,
                ),
              ),
              width: 115,
              padding: EdgeInsets.only(left: 9, right: 9),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$sdrivingDistance Km",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      "Your Location",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),



          ],
        )
        ;
      },
    );
  }
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      _isMapReady = true;
    });
  }

  void _updateCameraPosition() {
    if (_controller != null) {
      _controller.future.then((value) {
        value.animateCamera(CameraUpdate.newLatLng(_currentPosition));
      });
    }
  }

  Future<void> _fetchMarkerIcon() async {
    try {
      var response = await http.get(Uri.parse('https://firebasestorage.googleapis.com/v0/b/perwork.appspot.com/o/categories%2Fcleaning.png?alt=media&token=3860681e-1f1e-4806-9729-0f1cc52ce412')); // Replace with your image URL
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
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final double dashWidth = 5;
    final double dashSpace = 5;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, size.height / 2),
          Offset(startX + dashWidth, size.height / 2), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}




