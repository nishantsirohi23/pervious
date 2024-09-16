import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:provider/provider.dart';

import '../../api/apis.dart';
import '../../onboarding/OnboardingScreen.dart';
import '../../try/pigeon.dart';
import '../../utils/LocationService.dart';
import '../../utils/dashed_line.dart';
import 'dart:io';



class PickDeliveryLocation extends StatefulWidget {
  const PickDeliveryLocation({Key? key}) : super(key: key);

  @override
  State<PickDeliveryLocation> createState() => _PickMultiLocationState();
}

class _PickMultiLocationState extends State<PickDeliveryLocation> {
  double _fromlatitude = 0.0;
  double _fromlongitude = 0.0;
  double _tolatitude = 0.0;
  double _tolongitude = 0.0;
  double _latitude = 0.0;
  double _longitude = 0.0;
  final TextEditingController ageController = TextEditingController();
  final TextEditingController tofulladdress = TextEditingController();

  Future<void> _getCurrentLocation() async {
    FirebaseFirestore.instance.collection('users').doc(APIs.me.id).snapshots().listen((DocumentSnapshot snapshot) {
      setState(() {
        _latitude = snapshot['latitude'] ?? 0;
        _longitude = snapshot['longitude'] ?? 0;

      });
    });

  }

  late LocationService _locationService;
  PickResult? selectedFromPlace;
  PickResult? selectedToPlace;

  String _receivedfrom = "Pick From Location";
  String _receivedto = "Pick To Location";
  double hline = 50.0;


  @override
  void initState() {
    super.initState();
    _getCurrentLocation();

    _locationService = LocationService();

  }
  @override
  Widget build(BuildContext context) {
    final apiKey = Provider.of<ApiKeyProvider>(context).apiKey;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Add Multiple Locations"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Colors.black, // Change the color to any color you want
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                SizedBox(height: 8,),
                Container(
                  margin:EdgeInsets.only(left: 14,right: 14),
                  padding:EdgeInsets.all(15),

                  width: screenWidth,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.4),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("You can choose custom location",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: screenHeight*0.0205,
                                fontWeight: FontWeight.w500
                            ),),
                          Text("We can deliver your fav items from your fav store",
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: screenHeight*0.017,
                                fontWeight: FontWeight.w400
                            ),),

                          SizedBox(height: screenHeight*0.01,)
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 0),
                        child: Stack(
                          children: [
                            Column(
                              children: [
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
                                  child: _receivedfrom =="Pick From Location"?Container(
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
                                          width: 260,
                                          child: Text(_receivedfrom,
                                            overflow: TextOverflow.clip,
                                            maxLines: 2,
                                            style:
                                            TextStyle(
                                                color: Colors.white,
                                                fontSize: MediaQuery.of(context).size.width*0.04,
                                                fontWeight: FontWeight.w400
                                            ),),
                                        )


                                      ],
                                    ),
                                  ):Container(
                                    padding: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 10),
                                    decoration: BoxDecoration(
                                        color: Colors.pink.withOpacity(0.8),
                                        borderRadius: BorderRadius.all(Radius.circular(15))
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
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
                                              width: 260,
                                              child: Text(_receivedfrom,
                                                overflow: TextOverflow.clip,
                                                maxLines: 2,
                                                style:
                                                TextStyle(
                                                    color: Colors.white,
                                                    fontSize: MediaQuery.of(context).size.width*0.04,
                                                    fontWeight: FontWeight.w400
                                                ),),
                                            )


                                          ],
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(left: 43,right: 7),
                                          child: Divider(
                                            color: Colors.white, // The color of the line
                                            thickness: 1,      // The thickness of the line
                                            indent: 0.0,         // The amount of space on the left side
                                            endIndent: 0.0,      // The amount of space on the right side
                                          ),
                                        ),
                                        Container(
                                          height: 50,
                                          margin: EdgeInsets.only(left: 40),
                                          padding: EdgeInsets.only(left: 10, right: 10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(color: Colors.white,width: 1),
                                            borderRadius: BorderRadius.all(Radius.circular(15)),
                                          ),
                                          child: Center(
                                            child: TextField(
                                              controller: ageController,
                                              maxLines: 1,
                                              decoration: InputDecoration(
                                                hintText: "Full Address",
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 5,),

                                      ],
                                    )
                                  ),
                                ),

                              ],
                            ),


                          ],
                        ),
                      )

                    ],

                  ),
                ),
                SizedBox(height: 10,),


                Container(
                    margin: EdgeInsets.only(top: 13),
                    child: Column(
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.translucent, // Ensures outer detector still receives events

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
                          child: _receivedto=="Pick To Location"?Container(
                            margin: EdgeInsets.only(left: 13,right: 13),
                            padding: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 10),
                            decoration: BoxDecoration(
                                color: Colors.grey.shade200.withOpacity(0.5),
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
                                  width: 280,
                                  child: Text(_receivedto,
                                    overflow: TextOverflow.clip,
                                    maxLines: 2,
                                    style:
                                    TextStyle(
                                        color: Colors.pink,
                                        fontSize: MediaQuery.of(context).size.width*0.04,
                                        fontWeight: FontWeight.w400
                                    ),),
                                )


                              ],
                            ),
                          ):Container(
                              padding: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 10),
                              margin: EdgeInsets.only(left: 13,right: 13),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.pink,width: 1),
                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2), // Shadow color with opacity
                                    spreadRadius: 2, // Spread of the shadow
                                    blurRadius: 10, // Blur radius for the shadow
                                    offset: Offset(0, 5), // Offset of the shadow (x, y)
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [

                                      Container(
                                        height: 32,
                                        width: 32,
                                        decoration: BoxDecoration(
                                            color: Colors.pink.withOpacity(0.8),
                                            borderRadius: BorderRadius.all(Radius.circular(10))
                                        ),
                                        child: Icon(Icons.arrow_downward_outlined,color: Colors.white,),
                                      ),
                                      SizedBox(width: 13,),
                                      Container(
                                        width: 260,
                                        child: Text(_receivedto,
                                          overflow: TextOverflow.clip,
                                          maxLines: 2,
                                          style:
                                          TextStyle(
                                              color: Colors.pink.withOpacity(0.8),
                                              fontSize: MediaQuery.of(context).size.width*0.04,
                                              fontWeight: FontWeight.w400
                                          ),),
                                      )


                                    ],
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 43,right: 7),
                                    child: Divider(
                                      color: Colors.grey.shade500.withOpacity(0.8), // The color of the line
                                      thickness: 0.5,      // The thickness of the line
                                      indent: 0.0,         // The amount of space on the left side
                                      endIndent: 0.0,      // The amount of space on the right side
                                    ),
                                  ),
                                  Container(
                                    height: 50,
                                    margin: EdgeInsets.only(left: 40),
                                    padding: EdgeInsets.only(left: 10, right: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.pink.withOpacity(0.7),
                                      borderRadius: BorderRadius.all(Radius.circular(15)),
                                    ),
                                    child: Center(
                                      child: TextField(
                                        controller: tofulladdress,
                                        maxLines: 1,

                                        decoration: InputDecoration(
                                          hintText: "Full Address",
                                          border: InputBorder.none,
                                          hintStyle: TextStyle(
                                        color: Colors.white, // Change this to your desired hint text color
                                        ),
                                        ),
                                        style: TextStyle(
                                          color: Colors.white, // Change this to your desired text color
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5,),


                                ],
                              )
                          ),
                        ),

                      ],
                    )
                ),
              ],
            ),

            Container(
              margin: EdgeInsets.only(bottom: 50),
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop({
                    'fromLatitude': _fromlatitude,
                    'fromLongitude': _fromlongitude,
                    'receivedFrom': _receivedfrom,
                    'toLatitude': _tolatitude,
                    'toLongitude': _tolongitude,
                    'receivedTo': _receivedto,
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.pink),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                icon: Icon(
                  Icons.check,
                  color: Colors.pink,
                ),
                label: Text(
                  'Confirm',
                  style: TextStyle(
                    color: Colors.pink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        )
    );
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
