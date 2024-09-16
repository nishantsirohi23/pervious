import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:provider/provider.dart';

import '../../api/apis.dart';
import '../../onboarding/OnboardingScreen.dart';
import '../../try/pigeon.dart';
import '../../utils/LocationService.dart';
import '../../utils/dashed_line.dart';
import 'dart:io';

class PickMultiLocation extends StatefulWidget {
  const PickMultiLocation({Key? key}) : super(key: key);

  @override
  State<PickMultiLocation> createState() => _PickMultiLocationState();
}

class _PickMultiLocationState extends State<PickMultiLocation> {
  double _fromlatitude = 0.0;
  double _fromlongitude = 0.0;
  double _tolatitude = 0.0;
  double _tolongitude = 0.0;
  double _latitude = 0.0;
  double _longitude = 0.0;
  late GoogleMapController _mapController;

  Set<Marker> _markers = {};

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
  final TextEditingController companyController = TextEditingController();
  final TextEditingController landmarkController = TextEditingController();

  final TextEditingController ageController = TextEditingController();

  String _receivedfrom = "Pick Location";
  String _receivedto = "Pick To Location";
  double hline = 50.0;
  void _changeCameraPosition(double latitude, double longitude) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(latitude, longitude),
        ),
      );

    }
  }
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _locationService = LocationService();
  }

  void _updateMapWithMarker(LatLng latLng, String? address) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(address ?? 'default_id'),
          position: latLng,
          infoWindow: InfoWindow(title: address ?? 'No address provided'),
        ),
      );
      _mapController.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  @override
  Widget build(BuildContext context) {
    final apiKey = Provider.of<ApiKeyProvider>(context).apiKey;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Pick Location"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [

          Visibility(
            replacement: SizedBox.shrink(), // This ensures no space is taken

            visible:_receivedfrom == "Pick Location",
            child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 15),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            LatLng? selectedLatLng;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return PlacePicker(
                                    resizeToAvoidBottomInset: false,
                                    apiKey: Platform.isAndroid
                                        ? apiKey
                                        : apiKey,
                                    hintText: "Find a place ...",
                                    searchingText: "Please wait ...",
                                    selectText: "Select place",
                                    outsideOfPickAreaText: "Place not in area",
                                    initialPosition: LatLng(_latitude, _longitude),
                                    useCurrentLocation: true,
                                    selectInitialPosition: true,
                                    usePinPointingSearch: true,
                                    usePlaceDetailSearch: true,
                                    zoomGesturesEnabled: true,
                                    zoomControlsEnabled: true,
                                    ignoreLocationPermissionErrors: true,
                                    onMapCreated: (GoogleMapController controller) {
                                      _mapController = controller;
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
                                        if (selectedLatLng != null) {
                                          _updateMapWithMarker(selectedLatLng!, result.formattedAddress);
                                        }
                                        _fromlatitude = selectedLatLng?.latitude ?? 0.0;
                                        _fromlongitude = selectedLatLng?.longitude ?? 0.0;
                                        _receivedfrom = selectedFromPlace?.formattedAddress ?? "Pick Location";
                                        _changeCameraPosition(_fromlatitude,_fromlongitude);
                                        if (_receivedfrom.length > 23) {
                                          print(_receivedfrom.length);
                                          hline = 90.0;
                                        }
                                      });
                                      print(_fromlatitude);
                                      print(_fromlongitude);
                                      print(_receivedfrom);
                                      Navigator.of(context).pop();
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
                            margin: EdgeInsets.only(left: 13, right: 13),
                            padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.pink.withOpacity(0.8),
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 32,
                                  width: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: Icon(Icons.arrow_upward_outlined, color: Colors.pink),
                                ),
                                SizedBox(width: 13),
                                Container(
                                  width: 280,
                                  child: Text(
                                    _receivedfrom,
                                    overflow: TextOverflow.clip,
                                    maxLines: 2,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: MediaQuery.of(context).size.width * 0.055,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),),
          Column(

            children: [
              Visibility(
                  replacement: SizedBox.shrink(), // This ensures no space is taken

                  visible:_receivedfrom != "Pick Location",
                  child: Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 12,right: 12),
                        width: MediaQuery.of(context).size.width,  // Adjust width as needed
                        height: 210, // Adjust height as needed
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0), // Adjust radius as needed
                          child: GoogleMap(
                            zoomControlsEnabled: false,
                            myLocationButtonEnabled: false,
                            initialCameraPosition: CameraPosition(
                              target: LatLng(_fromlatitude, _fromlongitude), // Example coordinates
                              zoom: 14.0,
                            ),
                            onMapCreated: (GoogleMapController controller) {
                              _mapController = controller;
                            },
                            markers: {
                              Marker(markerId: MarkerId("demo"),
                                  position: LatLng(_fromlatitude,_fromlongitude))
                            },
                          ),
                        ),
                      ),
                      Positioned(
                          left:0,
                          right: 0,
                          bottom: 20,
                          child: Container(
                            margin: EdgeInsets.only(left: 10,right: 10),
                            child: GestureDetector(
                              onTap: () {
                                LatLng? selectedLatLng;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return PlacePicker(
                                        resizeToAvoidBottomInset: false,
                                        apiKey: Platform.isAndroid
                                            ? apiKey
                                            : apiKey,
                                        hintText: "Find a place ...",
                                        searchingText: "Please wait ...",
                                        selectText: "Select place",
                                        outsideOfPickAreaText: "Place not in area",
                                        initialPosition: LatLng(_latitude, _longitude),
                                        useCurrentLocation: true,
                                        selectInitialPosition: true,
                                        usePinPointingSearch: true,
                                        usePlaceDetailSearch: true,
                                        zoomGesturesEnabled: true,
                                        zoomControlsEnabled: true,
                                        ignoreLocationPermissionErrors: true,
                                        onMapCreated: (GoogleMapController controller) {
                                          _mapController = controller;
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
                                            if (selectedLatLng != null) {
                                              _updateMapWithMarker(selectedLatLng!, result.formattedAddress);
                                            }
                                            _fromlatitude = selectedLatLng?.latitude ?? 0.0;
                                            _fromlongitude = selectedLatLng?.longitude ?? 0.0;
                                            _receivedfrom = selectedFromPlace?.formattedAddress ?? "Pick Location";
                                            _changeCameraPosition(_fromlatitude,_fromlongitude);

                                            if (_receivedfrom.length > 23) {
                                              print(_receivedfrom.length);
                                              hline = 90.0;
                                            }
                                          });
                                          print(_fromlatitude);
                                          print(_fromlongitude);
                                          print(_receivedfrom);
                                          Navigator.of(context).pop();
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
                                margin: EdgeInsets.only(left: 13, right: 13),
                                padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 32,
                                      width: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.pink,
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                      ),
                                      child: Icon(Icons.arrow_upward_outlined, color: Colors.white),
                                    ),
                                    SizedBox(width: 13),
                                    Container(
                                      width: MediaQuery.of(context).size.width*0.7,
                                      child: Text(
                                        _receivedfrom,
                                        overflow: TextOverflow.clip,
                                        maxLines: 2,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: MediaQuery.of(context).size.width * 0.04,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ))
                    ],
                  )
              ),
              SizedBox(height: 50,),

              Visibility(
                visible:_receivedfrom != "Pick Location",

                child: Container(
                  margin: EdgeInsets.only(left: 10,right: 10),
                  child: Column(
                    children: [
                      Container(
                        height: 60,
                        padding: EdgeInsets.only(left: 20, right: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100.withOpacity(0.8),
                          border: Border.all(color: Colors.grey.shade300,width: 1),
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
                      SizedBox(height: 22),
                      Container(
                        height: 60,
                        padding: EdgeInsets.only(left: 20, right: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100.withOpacity(0.8),
                          border: Border.all(color: Colors.grey.shade300,width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        child: Center(
                          child: TextField(
                            controller: landmarkController,
                            maxLines: 1,
                            decoration: InputDecoration(
                              hintText: "Landmark (Optional)",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 22),
                      Container(
                        height: 100,
                        padding: EdgeInsets.only(left: 20, right: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100.withOpacity(0.8),
                          border: Border.all(color: Colors.grey.shade300,width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(15)),
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
                            hintText: 'Add direction or instructions for the delivery',
                            border: InputBorder.none, // You can customize the border as needed
                          ),
                        ),
                      ),
                      SizedBox(height: 22),

                    ],
                  ),
                ),),
            ],
          ),


          Positioned(
            bottom: 30,
            left: (MediaQuery.of(context).size.width-200)/2,
            child: Center(
              child: Container(
                width: 200,
                margin: EdgeInsets.only(bottom: 10),
                child: OutlinedButton.icon(
                  onPressed: () {
                    if(_receivedfrom=="Pick Location"){
                      MotionToast.error(
                        title:  Text("Pick Location"),
                        description:  Text("Click on Pick Location to choose your location"),
                      ).show(context);
                    }
                    else{
                      Navigator.of(context).pop({
                        'full_address': ageController.text,
                        'landmark': landmarkController.text,
                        'add_direction' :companyController.text,
                        'fromLatitude': _fromlatitude,
                        'fromLongitude': _fromlongitude,
                        'receivedFrom': _receivedfrom,
                        'toLatitude': _tolatitude,
                        'toLongitude': _tolongitude,
                        'receivedTo': _receivedto,
                      });
                    }

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
                    'Save and Confirm',
                    style: TextStyle(
                      color: Colors.pink,
                      fontWeight: FontWeight.bold,
                    ),
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
class CustomTextField extends StatelessWidget {
  final String labelText;
  final Widget? suffixIcon;
  final Color borderColor;
  final TextStyle textStyle;

  CustomTextField({
    required this.labelText,
    this.suffixIcon,
    Color? borderColor,
    TextStyle? textStyle,
  })  : this.borderColor = borderColor ?? Colors.pink.shade300, // Default border color
        this.textStyle = textStyle ?? const TextStyle(fontSize: 16, color: Colors.black,fontWeight: FontWeight.w400); // Default text style

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: textStyle, // Set the text style
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor), // Set the border color
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor), // Set the border color when enabled
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor), // Set the border color when focused
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}