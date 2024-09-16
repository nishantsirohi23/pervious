import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_marker/marker_icon.dart';
import 'package:flutter/foundation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'dart:ui' as ui;

import 'package:google_maps_flutter_platform_interface/src/types/marker.dart' as GoogleMapsMarker;

import '../../../api/apis.dart';
import '../../../chat/pages/home.dart';
import '../../../try/editprofilescreen.dart';
import '../showmywork.dart';



class ShowMapNotAssigned extends StatefulWidget {
  final double destlat;
  final double destlong;
  final double sourcelat;
  final double sourcelong;
  final String profid;
  final String workid;

  const ShowMapNotAssigned({Key? key,required this.workid,required this.destlat,required this.destlong,required this.sourcelat,required this.sourcelong,required this.profid}) : super(key: key);

  @override
  State<ShowMapNotAssigned> createState() => _NavigationState(destlat, destlong, sourcelat, sourcelong);
}

class _NavigationState extends State<ShowMapNotAssigned> {
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

  bool _isMapReady = false;
  Uint8List? _markerIconBytes;
  double _markerIconWidth = 50.0; // Width of the marker icon
  double _markerIconHeight = 50.0;// To store the marker icon bytes
  final double _initFabHeight = 120.0;
  double _fabHeight = 0;
  double _panelHeightOpen = 0;
  double _panelHeightClosed = 200.0;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _userDataStream;
  bool isLoading = false;
  late Future<DocumentSnapshot<Map<String, dynamic>>> workFuture;
  late Future<DocumentSnapshot<Map<String, dynamic>>> _fetchDataFuture;

  final player = AudioPlayer();
  bool isPlaying = false;
  late String currentAudioUrl;
  bool attachmentvisi = true;
  bool locationvisi = true;
  bool filevisi = true;
  bool posted = true;
  bool assigned = false;
  bool completed = false;
  bool track = false;
  bool allworkers = false;
  bool paymentdone = false;
  late Razorpay _razorpay;
  double finalamount = 0.0;
  String finalwokerid = "asdf";
  double finalworkerAmount = 0.0;
  bool _isPaymentInProgress = false;
  String message = "WAITING";
  bool showpaynow = false;
  bool showbill = false;
  int platformfee =0;
  int gst = 0;
  int workertip = 0;
  int intValue = 0;
  int grandpay = 0;
  int tippay = 0;
  int platformfeepay = 0;
  bool ten = false;
  bool twenty = false;
  bool thirty = false;
  Set<GoogleMapsMarker.Marker> _markers = <GoogleMapsMarker.Marker>{};

  void setMarker2() async{

    _markers.add(
      GoogleMapsMarker.Marker(
        markerId: MarkerId('downloadResizePictureCircle1'),
        icon: await MarkerIcon.downloadResizePictureCircle(
            "https://cdn.dribbble.com/userupload/11784388/file/original-2a9a30fa8acfda6d7327bea4cd3e7aaa.png?resize=1024x1024",
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


  @override
  void initState() {
    super.initState();

    _fetchDataFuture = FirebaseFirestore.instance.collection('work').doc(widget.workid).get();
    workFuture = FirebaseFirestore.instance.collection('work').doc(widget.workid).get();
    _fabHeight = _initFabHeight;


  }




  bool _isLoading = false;



  var sdrivingDuration = "";





  @override
  Widget build(BuildContext context) {

    _panelHeightOpen = MediaQuery.of(context).size.height * .82;

    size = MediaQuery.of(context).size;

    return Scaffold(

        extendBodyBehindAppBar: true,
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
                              Text("Order on the way",
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
                                    SizedBox(width: 4,),
                                    Text(sdrivingDuration+" mins",
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
        )
    );
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








            ],
          ),
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


        if (_currentPosition.latitude != latitude || _currentPosition.longitude != longitude) {
          print(latitude);
          print(longitude);

          _currentPosition = LatLng(latitude, longitude);

          // Update current position
          // Call function when values change
          _updateCameraPosition();
          // Fetch map data
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




