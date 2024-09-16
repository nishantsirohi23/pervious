import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter_platform_interface/src/types/marker.dart' as GoogleMapsMarker;
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';


import 'dart:io';

import '../../../api/apis.dart';
import '../../../models/work.dart';
import '../../../utils/LocationService.dart';
import '../../try/pigeon.dart';
import 'SuccessScreen.dart';


class PickUpDelivery extends StatefulWidget {
  const PickUpDelivery({Key? key}) : super(key: key);

  @override
  State<PickUpDelivery> createState() => _PickMultiLocationState();
}


class _PickMultiLocationState extends State<PickUpDelivery> {
  double _fromlatitude = 0.0;
  double _fromlongitude = 0.0;
  double _tolatitude = 0.0;
  double _tolongitude = 0.0;
  double _latitude = 0.0;
  bool isLoading = false;
  double _longitude = 0.0;
  LatLng _markerLocation = LatLng(0.0,0.0);
  LatLng _frommarkerLocation = LatLng(0.0,0.0);
  LatLng _tomarkerLocation = LatLng(0.0,0.0);
  int fareamount = 0;
  bool instructionsadded = false;
  final TextEditingController _farecontroller = TextEditingController();
  final TextEditingController instructionspickup = TextEditingController();
  final TextEditingController instructionsdelivery = TextEditingController();
  final TextEditingController pickuptyped = TextEditingController();
  final TextEditingController deliverytyped = TextEditingController();
  final TextEditingController pickupphone = TextEditingController();
  final TextEditingController deliveryphone = TextEditingController();
  final TextEditingController pickupinstruction = TextEditingController();
  final TextEditingController deliveryinstruction = TextEditingController();
  final TextEditingController companyController = TextEditingController();


  bool filesUploadedSuccessfully = false;
  bool isUploading = false;
  List<Map<String, String>> fileData = [];
  List<File> selectedFiles = [];
  bool isloading = true;
  Future<void> _getCurrentLocation() async {
    FirebaseFirestore.instance.collection('users').doc(APIs.me.id).snapshots().listen((DocumentSnapshot snapshot) {
      setState(() {
        _latitude = snapshot['latitude'] ?? 0;
        _longitude = snapshot['longitude'] ?? 0;
        _markerLocation = LatLng(_latitude, _longitude);
        isloading = false;
      });
    });

  }



  late LocationService _locationService;
  PickResult? selectedFromPlace;
  PickResult? selectedToPlace;

  String _receivedfrom = "From";
  String _receivedto = "To";
  double hline = 50.0;
  bool showloading = false;
  late DateTime selectedDate = DateTime.now();
  late TimeOfDay selectedTime = TimeOfDay.now();
  @override
  void initState() {
    super.initState();
    _locationService = LocationService();

    _getCurrentLocation();

  }
  @override
  Widget build(BuildContext context) {
    final apiKey = Provider.of<ApiKeyProvider>(context).apiKey;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.black, // Change the color to any color you want
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Pick up/Delivery",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),

      body: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    width: screenWidth*0.5-30 ,

                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade100.withOpacity(0.2),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      border: Border.all(color: Colors.pink.withOpacity(0.8))
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.access_alarm_outlined,color: Colors.pink,),
                        Text("Deliver Now",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500
                          ),),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                          Text("starts ₹ 35",
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500
                            ),),
                          SizedBox(width: 15,),
                          Icon(Icons.arrow_circle_down_sharp)
                        ],)

                      ],
                    ),
                  ),
                  Container(
                    width: screenWidth*0.5-30 ,

                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        border: Border.all(color: Colors.pink.withOpacity(0.8))
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.calendar_today_outlined),
                        Text("Schedule",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500
                          ),),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("starts ₹ 35",
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500
                              ),),
                            SizedBox(width: 15,),
                            Icon(Icons.arrow_circle_down_sharp)
                          ],)

                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20,),
              Container(
                margin: EdgeInsets.only(left: 10,right:10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 40.0, // Width of the circle
                          height: 40.0, // Height of the circle (same as width to make it circular)
                          decoration: BoxDecoration(
                            color: Colors.pink.withOpacity(0.8).withOpacity(0.8), // Background color of the circle
                            shape: BoxShape.circle, // Circular shape
                          ),
                          child: Center(
                            child: Text(
                              '1',
                              style: TextStyle(
                                fontSize: 24.0, // Font size of the text
                                color: Colors.white, // Text color
                                fontWeight: FontWeight.w500, // Text style (bold)
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 3,),
                        DashedLine(
                          height: 310.0,  // Height of the entire dashed line
                          dashHeight: 10.0,  // Height of each dash
                          dashWidth: 2.5,  // Width of each dash
                          color: Colors.pink.withOpacity(0.8).withOpacity(0.8),  // Color of the dashes
                        ),


                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 5,),
                        Text("Pickup point",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 21
                          ),
                        ),
                        SizedBox(height: 15,),
                        GestureDetector(
                          onTap: (){
                            LatLng? selectedLatLng;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return PlacePicker(
                                    resizeToAvoidBottomInset: false, // only works in page mode, less flickery
                                    apiKey: Platform.isAndroid
                                        ? apiKey
                                        : apiKey,
                                    hintText: "Find a place ...",
                                    searchingText: "Please wait ...",
                                    selectText: "Select place",
                                    outsideOfPickAreaText: "Place not in area",
                                    initialPosition: LatLng(_latitude,_longitude),
                                    useCurrentLocation: true,
                                    selectInitialPosition: true,
                                    usePinPointingSearch: true,
                                    usePlaceDetailSearch: true,
                                    zoomGesturesEnabled: true,
                                    zoomControlsEnabled: true,
                                    ignoreLocationPermissionErrors: true,
                                    onMapCreated: (GoogleMapController controller) {
                                      print("Map created");
                                    },
                                    onPlacePicked: (PickResult result) {
                                      print("Place picked: ${result.formattedAddress}");
                                      setState(() {
                                        selectedFromPlace = result;
                                        selectedLatLng = result.geometry?.location != null
                                            ? LatLng(
                                          result.geometry!.location!.lat,
                                          result.geometry!.location!.lng,
                                        )
                                            : null;
                                        setState(() {
                                          _fromlatitude = selectedLatLng!.latitude;
                                          _fromlongitude = selectedLatLng!.longitude;
                                          _receivedfrom = selectedFromPlace!.formattedAddress.toString();
                                          if(_receivedfrom.length>23){
                                            print(_receivedfrom.length);
                                            hline = 90.0;
                                          }
                                          _frommarkerLocation = LatLng(_fromlatitude, _fromlongitude);
                                        });

                                        print(_fromlatitude);
                                        print(_fromlongitude);
                                        print(_receivedfrom);

                                        Navigator.of(context).pop();
                                      });
                                    },
                                    onMapTypeChanged: (MapType mapType) {
                                      print("Map type changed to ${mapType.toString()}");
                                    },
                                  );
                                },
                              ),

                            );
                          },
                          child: Container(
                            padding: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 10),
                            decoration: BoxDecoration(
                                color: Colors.pink.withOpacity(0.8).withOpacity(0.8),
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
                                  child: Icon(Icons.arrow_upward_outlined,color: Colors.pink.withOpacity(0.8),),
                                ),
                                SizedBox(width: 13,),
                                Container(
                                  width: screenWidth-148,
                                  child: Text(_receivedfrom,
                                    overflow: TextOverflow.clip,
                                    maxLines: 1,
                                    style:
                                    TextStyle(
                                        color: Colors.white,
                                        fontSize: MediaQuery.of(context).size.width*0.045,
                                        fontWeight: FontWeight.w400
                                    ),),
                                )


                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 8,),
                        Container(
                          height: 70,
                          width: screenWidth - 85,
                          child: TextField(
                            controller: pickuptyped,
                            decoration: InputDecoration(
                              hintText: 'Pick Up Address',
                              hintStyle: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                              ), // Hint text color
                              border: UnderlineInputBorder(
                                borderSide: BorderSide.none, // No border
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey), // Underline color
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey), // Underline color when focused
                              ),
                              suffixIcon: Container(
                                padding: EdgeInsets.all(10),
                                child: Image.asset(
                                  'assets/map1.png', // Path to your image asset
                                  height: 24,
                                  width: 24,
                                ),
                              ),
                            ),
                          ),
                        )
                        ,
                        Container(
                          height: 70,
                          width: screenWidth - 85,
                          child: TextField(
                            controller: pickupphone,
                            decoration: InputDecoration(
                              hintText: 'Phone Number (Otpional)',
                              hintStyle: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                              ), // Hint text color
                              border: UnderlineInputBorder(
                                borderSide: BorderSide.none, // No border
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey), // Underline color
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey), // Underline color when focused
                              ),
                              suffixIcon: Container(
                                padding: EdgeInsets.all(10),
                                child: Image.asset(
                                  'assets/phone.png', // Path to your image asset
                                  height: 24,
                                  width: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Open the bottom sheet when tapped
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20)
                                  ),
                                  width: screenWidth,
                                  height: screenHeight*0.3,
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Container(
                                        width: 60,
                                        height: 7,
                                        decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

                                          Container(
                                            margin: EdgeInsets.only(left: 10,right: 10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text("Instruction for the pickup",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 21
                                                  ),),
                                                Icon(Icons.directions_run, color: Colors.pink.withOpacity(0.8))

                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 7,),
                                          Container(
                                            height: 100,
                                            width: screenWidth * 0.9,
                                            padding: EdgeInsets.only(left: 20, right: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100.withOpacity(0.8),
                                              borderRadius: BorderRadius.all(Radius.circular(15)),
                                            ),
                                            child: TextField(
                                              controller: instructionspickup,
                                              maxLines: 3,
                                              textInputAction: TextInputAction.done, // Ensure the keyboard shows "Done" instead of "Return"
                                              onSubmitted: (value) {
                                                // When the user presses the "Done" button, hide the keyboard
                                                FocusScope.of(context).unfocus();
                                              },
                                              decoration: InputDecoration(
                                                hintText: 'Enter the instructions (Optional)',
                                                border: InputBorder.none, // You can customize the border as needed
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          // Add onPressed action

                                          // Close the
                                          // Call function to post data to Firestore

                                        },
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: Colors.pink.withOpacity(0.8)),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                        ),
                                        icon: Icon(
                                          Icons.check,
                                          color: Colors.pink.withOpacity(0.8),
                                        ),
                                        label: Text(
                                          'Confirm',
                                          style: TextStyle(
                                            color: Colors.pink.withOpacity(0.8),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10,)
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                            width: screenWidth - 85,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white, // Background color
                              borderRadius: BorderRadius.circular(15), // Border radius
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5), // Shadow color
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: Offset(0, 1), // Offset of the shadow
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.directions_run_rounded, color: Colors.pink.withOpacity(0.8),),
                                        SizedBox(width: 5),
                                        Text(
                                          'Instructions for the pickup',
                                          style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    Icon(Icons.keyboard_arrow_down_outlined, color: Colors.pink.withOpacity(0.8),),
                                  ],
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  'You can add any special delivery instructions for the worker',
                                  style: TextStyle(fontSize: 14.0),
                                ),
                              ],
                            ),
                          )
                          ,
                        )
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 10,),
              Container(
                margin: EdgeInsets.only(left: 10,right:10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 40.0, // Width of the circle
                          height: 40.0, // Height of the circle (same as width to make it circular)
                          decoration: BoxDecoration(
                            color: Colors.pink.withOpacity(0.8).withOpacity(0.8), // Background color of the circle
                            shape: BoxShape.circle, // Circular shape
                          ),
                          child: Center(
                            child: Text(
                              '2',
                              style: TextStyle(
                                fontSize: 24.0, // Font size of the text
                                color: Colors.white, // Text color
                                fontWeight: FontWeight.w500, // Text style (bold)
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 3,),
                        DashedLine(
                          height: 310.0,  // Height of the entire dashed line
                          dashHeight: 10.0,  // Height of each dash
                          dashWidth: 2.5,  // Width of each dash
                          color: Colors.pink.withOpacity(0.8).withOpacity(0.8),  // Color of the dashes
                        ),


                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 5,),
                        Text("Delivery point",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 21
                          ),
                        ),
                        SizedBox(height: 15,),
                        GestureDetector(
                          onTap: (){
                            LatLng? selectedLatLng;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return PlacePicker(
                                    resizeToAvoidBottomInset: false, // only works in page mode, less flickery
                                    apiKey: Platform.isAndroid
                                        ? apiKey
                                        : apiKey,
                                    hintText: "Find a place ...",
                                    searchingText: "Please wait ...",
                                    selectText: "Select place",
                                    outsideOfPickAreaText: "Place not in area",
                                    initialPosition: LatLng(_latitude,_longitude),
                                    useCurrentLocation: true,
                                    selectInitialPosition: true,
                                    usePinPointingSearch: true,
                                    usePlaceDetailSearch: true,
                                    zoomGesturesEnabled: true,
                                    zoomControlsEnabled: true,
                                    ignoreLocationPermissionErrors: true,
                                    onMapCreated: (GoogleMapController controller) {
                                      print("Map created");
                                    },
                                    onPlacePicked: (PickResult result) {
                                      print("Place picked: ${result.formattedAddress}");
                                      setState(() {
                                        selectedToPlace = result;
                                        selectedLatLng = result.geometry?.location != null
                                            ? LatLng(
                                          result.geometry!.location!.lat,
                                          result.geometry!.location!.lng,
                                        )
                                            : null;
                                        setState(() {
                                          _tolatitude = selectedLatLng!.latitude;
                                          _tolongitude = selectedLatLng!.longitude;
                                          _receivedto = selectedToPlace!.formattedAddress.toString();
                                          if(_receivedto.length>23){
                                            print(_receivedto.length);
                                            hline = 90.0;
                                          }
                                          _tomarkerLocation = LatLng(_tolatitude, _tolongitude);

                                        });

                                        print(_tolatitude);
                                        print(_tolongitude);
                                        print(_receivedto);

                                        Navigator.of(context).pop();
                                      });
                                    },
                                    onMapTypeChanged: (MapType mapType) {
                                      print("Map type changed to ${mapType.toString()}");
                                    },
                                  );
                                },
                              ),

                            );
                          },
                          child: Container(
                            padding: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 10),
                            decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.all(Radius.circular(15))
                            ),
                            child: Row(
                              children: [

                                Container(
                                  height: 32,
                                  width: 32,
                                  decoration: BoxDecoration(
                                      color: Colors.pink.withOpacity(0.8),
                                      borderRadius: BorderRadius.all(Radius.circular(10))
                                  ),
                                  child: Icon(Icons.arrow_upward_outlined,color: Colors.white,),
                                ),
                                SizedBox(width: 13,),
                                Container(
                                  width: screenWidth-148,
                                  child: Text(_receivedto,
                                    overflow: TextOverflow.clip,
                                    maxLines: 1,
                                    style:
                                    TextStyle(
                                        color: Colors.pink.withOpacity(0.8),
                                        fontSize: MediaQuery.of(context).size.width*0.045,
                                        fontWeight: FontWeight.w400
                                    ),),
                                )


                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 8,),
                        Container(
                          height: 70,
                          width: screenWidth - 85,
                          child: TextField(
                            controller: deliverytyped,
                            decoration: InputDecoration(
                              hintText: 'Delivery Address',
                              hintStyle: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                              ), // Hint text color
                              border: UnderlineInputBorder(
                                borderSide: BorderSide.none, // No border
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey), // Underline color
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey), // Underline color when focused
                              ),
                              suffixIcon: Container(
                                padding: EdgeInsets.all(10),
                                child: Image.asset(
                                  'assets/map1.png', // Path to your image asset
                                  height: 24,
                                  width: 24,
                                ),
                              ),
                            ),
                          ),
                        )
                        ,
                        Container(
                          height: 70,
                          width: screenWidth - 85,
                          child: TextField(
                            controller: deliveryphone,
                            decoration: InputDecoration(
                              hintText: 'Phone Number (Otpional)',
                              hintStyle: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                              ), // Hint text color
                              border: UnderlineInputBorder(
                                borderSide: BorderSide.none, // No border
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey), // Underline color
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey), // Underline color when focused
                              ),
                              suffixIcon: Container(
                                padding: EdgeInsets.all(10),
                                child: Image.asset(
                                  'assets/phone.png', // Path to your image asset
                                  height: 24,
                                  width: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Open the bottom sheet when tapped
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20)
                                  ),
                                  width: screenWidth,
                                  height: screenHeight*0.3,
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Container(
                                        width: 60,
                                        height: 7,
                                        decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

                                          Container(
                                            margin: EdgeInsets.only(left: 10,right: 10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text("Instruction for the delivery",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 21
                                                  ),),
                                                Icon(Icons.directions_run, color: Colors.pink.withOpacity(0.8))

                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 7,),
                                          Container(
                                            height: 100,
                                            width: screenWidth * 0.9,
                                            padding: EdgeInsets.only(left: 20, right: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100.withOpacity(0.8),
                                              borderRadius: BorderRadius.all(Radius.circular(15)),
                                            ),
                                            child: TextField(
                                              controller: instructionsdelivery,
                                              maxLines: 3,
                                              textInputAction: TextInputAction.done, // Ensure the keyboard shows "Done" instead of "Return"
                                              onSubmitted: (value) {
                                                // When the user presses the "Done" button, hide the keyboard
                                                FocusScope.of(context).unfocus();
                                              },
                                              decoration: InputDecoration(
                                                hintText: 'Enter the instructions (Optional)',
                                                border: InputBorder.none, // You can customize the border as needed
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          // Add onPressed action

                                          // Close the
                                          // Call function to post data to Firestore

                                        },
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: Colors.pink.withOpacity(0.8)),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                        ),
                                        icon: Icon(
                                          Icons.check,
                                          color: Colors.pink.withOpacity(0.8),
                                        ),
                                        label: Text(
                                          'Confirm',
                                          style: TextStyle(
                                            color: Colors.pink.withOpacity(0.8),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10,)
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                            width: screenWidth - 85,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white, // Background color
                              borderRadius: BorderRadius.circular(15), // Border radius
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5), // Shadow color
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: Offset(0, 1), // Offset of the shadow
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.directions_run_rounded, color: Colors.pink.withOpacity(0.8),),
                                        SizedBox(width: 5),
                                        Text(
                                          'Instructions for the delivery',
                                          style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    Icon(Icons.keyboard_arrow_down_outlined, color: Colors.pink.withOpacity(0.8),),
                                  ],
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  'You can add any special delivery instructions for the worker',
                                  style: TextStyle(fontSize: 14.0),
                                ),
                              ],
                            ),
                          )
                          ,
                        )
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 20,),

              GestureDetector(
                onTap: () {
                  if (!isUploading) {
                    _pickFiles();
                  }
                },
                child: Container(
                  width: screenWidth*0.9,
                  padding: EdgeInsets.only(top:10,bottom: 10,right: 15),
                  margin: EdgeInsets.only(left: 7, right: 7),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: isUploading
                        ? CircularProgressIndicator()
                        : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(width: 20,),
                            Image.asset("assets/cloud-upload.png", height: 40, width: 40),
                            SizedBox(width: 10,),
                            Text(
                              filesUploadedSuccessfully ? "List Uploaded" : "Upload Items List",
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w400,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.arrow_forward_ios,color: Colors.black87,size: 16,),
                        //Image.asset("assets/file.png", height: 40, width: 40),

                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10,),

              Container(
                height: 100,
                width: screenWidth*0.9,
                padding: EdgeInsets.only(left: 20,right: 10),
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.all(Radius.circular(10))

                ),

                child: TextField(
                  controller: companyController,

                  maxLines: 3,
                  textInputAction: TextInputAction.done, // Ensure the keyboard shows "Done" instead of "Return"
                  onSubmitted: (value) {
                    // When the user presses the "Done" button, hide the keyboard
                    FocusScope.of(context).unfocus();
                  },
                  decoration: InputDecoration(
                    hintText: 'You can add more items (Optional)',
                    border: InputBorder.none, // You can customize the border as needed
                  ),
                ),
              ),
              SizedBox(height: 20,),
              GestureDetector(
                onTap: (){
                  if(_receivedfrom=="From"||_receivedto=="To"){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Pick Both Locations'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                        action: SnackBarAction(
                          label: 'OK',
                          onPressed: () {},
                        ),
                      ),
                    );
                  }
                  else{
                    _addUser();
                  }
                },
                child: Container(
                  height: 50,
                  width: screenWidth,
                  margin: EdgeInsets.only(left: 20,right: 20),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/backofwork.png"),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20))
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10,),
                      Text('Confirm Delivery',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 21
                        ),)
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20,),




            ],
          ),
        ),
      ),

    );
  }
  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'mp3', 'mp4'],
    );

    if (result != null) {
      setState(() {
        selectedFiles = result.paths.map((path) => File(path!)).toList();
      });
      setState(() {
        isUploading = true;
      });
      List<Map<String, String>> uploadedFiles = await _uploadFiles(selectedFiles);
      if (uploadedFiles.isNotEmpty) {
        setState(() {
          filesUploadedSuccessfully = true;
          isUploading = false;
        });
      }
    }
  }

  Future<List<Map<String, String>>> _uploadFiles(List<File> files) async {

    for (File file in files) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageReference.putFile(file);
      await uploadTask.whenComplete(() async {
        String url = await storageReference.getDownloadURL();

        // Extract file extension
        String fileType = file.path.split('.').last;

        // Store file URL and type as a pair
        fileData.add({'url': url, 'type': fileType});
      });
    }

    return fileData;
  }
  Future<DateTime?> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      // Return the selected DateTime
      return picked;
    }

    // Return null if the user cancels or picks the same date
    return null;
  }
  Future<DateTime?> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (picked != null && picked != selectedTime) {
      // Get the current date
      DateTime now = DateTime.now();

      // Construct a DateTime object using the current date and the picked time
      DateTime selectedDateTime = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);

      // Return the selected DateTime
      return selectedDateTime;
    }

    // Return null if the user cancels or picks the same time
    return null;
  }
  void _addUser() async {
    setState(() {
      showloading = true;
    });
    final String fullName = "Pick Up/Delivery";
    final String company = "From "+_receivedfrom+" to "+_receivedto;

    final String amountText = "0010";
    final String prof = "Driver";
    final String  fareamounts= _farecontroller.text;


    double amount = 0.0;

    if (fareamounts.isNotEmpty) {
      amount = double.tryParse(fareamounts) ?? 0.0;
    }

    final int age = int.tryParse(fareamounts) ?? 0;

    if (fullName.isNotEmpty && company.isNotEmpty && age > 0) {

      try {
        setState(() {
          isLoading = true; // Show loading animation
        });

        Work myWork = Work(
            choose: true,
            createdAt: DateTime
                .now()
                .millisecondsSinceEpoch
                .toString(),
            name: fullName,
            pickupinstruction: pickupinstruction.text.toString(),
            pickupphone: pickupphone.text.toString(),
            deliveryphone: deliveryphone.text.toString(),
            deliveryinstruction: deliveryinstruction.text.toString(),
            cod: 'null',
            toTypedaddress: pickuptyped.text.toString(),
            fromTypedaddress: deliverytyped.text.toString(),
            category: 'pickup',
            description: company,
            dateTime: DateTime(selectedDate.year, selectedDate.month,
                selectedDate.day, selectedTime.hour, selectedTime.minute),
            amount: double.parse(fareamounts),
            negotiable: true,
            priority: "normal",
            workBy: APIs.me.id,
            status: "process",
            id: '',
            prof: prof,
            reviewdone: false,
            fileData: fileData,
            fromlongitude: _fromlongitude,
            fromlatitude: _fromlatitude,
            fromaddress: _receivedfrom,
            tolongitude: _tolongitude,
            tolatitude: _tolatitude,
            toaddress:_receivedto
            ,
            payment: false,
            tip: 0,
            grandtotal: 0

        );

        String? result = await APIs.addWork(myWork,fullName);
        // Clear text fields and reset form
        setState(() {
          showloading = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>   SuccessScreen()),
        );
        APIs.sendnotificationtowork(company,"delivery");

      } catch (error) {
        print('Error: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      } finally {
        setState(() {

          selectedDate = DateTime.now();
          selectedTime = TimeOfDay.now();

          isLoading = false; // Hide loading animation
        });
      }
    } else {
      setState(() {showloading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter the offer price'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );

    }
  }

}
class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({this.color = Colors.pink});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2.0 // Adjust line width as needed
      ..style = PaintingStyle.stroke;

    final double dashWidth = 10.0; // Width of each dash
    final double dashSpace = 5.0; // Space between dashes
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

}

class DashedLine extends StatelessWidget {
  final double height;
  final double dashHeight;
  final double dashWidth;
  final Color color;

  DashedLine({
    this.height = 100,
    this.dashHeight = 5,
    this.dashWidth = 2,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boxHeight = constraints.constrainHeight();
          final dashCount = (boxHeight / (2 * dashHeight)).floor();
          return Flex(
            direction: Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dashCount, (_) {
              return SizedBox(
                height: dashHeight,
                width: dashWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: color),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
Widget dateSelectorWidget({required DateTime selectedDate, required Function(DateTime) onDateSelected}) {
  List<DateTime> getDateList() {
    return List.generate(11, (index) {
      return DateTime.now().add(Duration(days: index));
    });
  }

  List<DateTime> dateList = getDateList();

  return Container(
    height: 100,
    padding: EdgeInsets.symmetric(vertical: 10),
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: dateList.length,
      itemBuilder: (context, index) {
        DateTime date = dateList[index];
        bool isSelected = date.day == selectedDate.day &&
            date.month == selectedDate.month &&
            date.year == selectedDate.year;
        return GestureDetector(
          onTap: () {
            onDateSelected(date);
          },
          child: Container(
            width: 80,
            margin: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('dd').format(date),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  DateFormat('MMM').format(date),
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}




