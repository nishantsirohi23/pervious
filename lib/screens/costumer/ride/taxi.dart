import 'dart:ui';

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
import '../../../try/pigeon.dart';
import '../../../utils/LocationService.dart';
import '../SuccessScreen.dart';


class BookTaxi extends StatefulWidget {
  final String type;
  const BookTaxi({Key? key,required this.type}) : super(key: key);

  @override
  State<BookTaxi> createState() => _PickMultiLocationState();
}

class _PickMultiLocationState extends State<BookTaxi> {
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
  final TextEditingController _farecontroller = TextEditingController();
  bool filesUploadedSuccessfully = false;
  bool isUploading = false;
  List<Map<String, String>> fileData = [];
  List<File> selectedFiles = [];
  bool isloading = false;
  Future<void> _getCurrentLocation() async {
    Map<String, double> locationData = await _locationService.getCurrentLocation();
    setState(() {
      _latitude = locationData['latitude']!;
      _longitude = locationData['longitude']!;
      _markerLocation = LatLng(_latitude, _longitude);
      isloading = false;
    });
    print(_latitude);
    print(_longitude);
  }
  int passenger = 1;
  late LocationService _locationService;
  PickResult? selectedFromPlace;
  PickResult? selectedToPlace;
  String _receivedfrom = "From";
  String _receivedto = "Where To";
  double hline = 50.0;
  late DateTime selectedDate = DateTime.now();
  late TimeOfDay selectedTime = TimeOfDay.now();
  @override
  void initState() {
    super.initState();
    setState(() {
      isloading = true;
    });
    _locationService = LocationService();
    _getCurrentLocation();
  }
  @override
  Widget build(BuildContext context) {
    final apiKey = Provider.of<ApiKeyProvider>(context).apiKey;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Colors.black, // Change the color to any color you want
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Book '+widget.type,
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        body: Stack(
          children: [
            Visibility(
              visible: !isloading,
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _markerLocation,
                      zoom: 15,
                    ),
                    polylines:(_receivedfrom !="From" &&
                        _receivedto != "To")
                        ? Set<Polyline>.of([
                      Polyline(
                        polylineId: PolylineId('route'),
                        color: Colors.pink,
                        width: 3,
                        points: [
                          _frommarkerLocation,
                          _tomarkerLocation,
                        ],
                        patterns: [
                          PatternItem.dash(30),
                          PatternItem.gap(20),
                        ],
                      ),
                    ])
                        : Set<Polyline>.of([]),

                    markers: Set<GoogleMapsMarker.Marker>.of([
                      GoogleMapsMarker.Marker(
                        markerId: MarkerId('marker_1'),
                        position: _frommarkerLocation,
                        infoWindow: InfoWindow(
                          title: 'Marker Title',
                          snippet: 'Marker Snippet',
                        ),
                      ),
                      GoogleMapsMarker.Marker(
                        markerId: MarkerId('marker_2'),
                        position: _tomarkerLocation,
                        infoWindow: InfoWindow(
                          title: 'Marker Title',
                          snippet: 'Marker Snippet',
                        ),
                      ),
                    ]),
                  ),
                  Visibility(
                    visible: true,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(15))
                      ),
                      height: 145,
                      margin: EdgeInsets.only(top: screenHeight*0.13,left: 10,right: 10),
                      child: Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 15),
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
                                        margin: EdgeInsets.only(left: 20,right: 20),
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
                                              child: Icon(Icons.arrow_upward_outlined,color: Colors.pink.withOpacity(0.8),),
                                            ),
                                            SizedBox(width: 13,),
                                            Container(
                                              width: 260,
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

                                  ],
                                ),


                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 46,top: _receivedfrom=="" ? 33.0 : 40.0),
                            child: CustomPaint(
                              size: Size(1.0, MediaQuery.of(context).size.height*0.08),
                              painter: DashedLinePainter(color: Colors.pink),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.09),
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
                                        margin: EdgeInsets.only(left: 20,right: 20),
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
                                              width: 260,
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

                                  ],
                                ),


                              ],
                            ),
                          ),

                        ],
                      ),
                    ),),
                  Positioned(
                      bottom: 0,
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
                          ),
                          width: screenWidth,
                          child: Column(
                            children: [
                              SizedBox(height: 20,),

                              Container(
                                padding: EdgeInsets.only(top: 3,bottom: 3),
                                decoration: BoxDecoration(
                                  color: Colors.pink.withOpacity(0.8),
                                  borderRadius: BorderRadius.all(Radius.circular(15))
                                ),
                                margin: EdgeInsets.only(left: 20,right: 20),
                                child: Row(
                                  children: [
                                    SizedBox(width: 10,),
                                    Image.asset("assets/rupee.png",height: 30,width: 30,),
                                    SizedBox(width: 10,),

                                    Container(
                                      width: screenWidth * 0.55,
                                      child: TextField(
                                        controller: _farecontroller,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Allow only numbers
                                        style: TextStyle(fontSize: 21, color: Colors.white), // Set text color to white
                                        decoration: InputDecoration(
                                          hintText: 'Offer your fare..', // Add hint text here
                                          hintStyle: TextStyle(color: Colors.white), // Set hint color to white
                                          border: InputBorder.none, // Remove underline
                                          contentPadding: EdgeInsets.zero, // Remove default padding
                                        ),
                                      ),
                                    ),


                                    Container(
                                      height: 40,
                                      width: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(Radius.circular(15)),
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          // Show a dropdown menu to pick passenger number
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                backgroundColor: Colors.white, // Set background color to white
                                                title: Text("Select Passenger"),
                                                content: Container(
                                                  height: 150,
                                                  width: 100,
                                                  child: ListView.builder(
                                                    itemCount: 10, // Assuming you want options from 1 to 10
                                                    itemBuilder: (context, index) {
                                                      return ListTile(
                                                        title: Text("${index + 1}"),
                                                        onTap: () {
                                                          setState(() {
                                                            passenger = index + 1; // Update passenger number
                                                          });
                                                          Navigator.of(context).pop(); // Close the dialog
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            FaIcon(
                                              FontAwesomeIcons.person, // Adjust icon as needed
                                              size: 20, // Adjust icon size as needed
                                              color: Colors.pink.withOpacity(0.8), // Adjust icon color as needed
                                            ),
                                            SizedBox(width: 7), // Adding some space between the icon and the text
                                            Container(
                                              child: Text(
                                                "$passenger",
                                                style: TextStyle(
                                                  color: Colors.pink.withOpacity(0.8),
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                            Icon(Icons.keyboard_arrow_down_outlined, color: Colors.pink.withOpacity(0.8)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20,),

                              Container(
                                width: screenWidth,
                                margin: EdgeInsets.only(left: 20,right: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Image.asset(
                                      "assets/clock.png",
                                      height: 35,
                                      width: 35,
                                    ),
                                    Container(
                                      height: 50,
                                      padding: EdgeInsets.only(left: 10, right: 10),
                                      decoration: BoxDecoration(
                                          color: Colors.pink.withOpacity(0.8),
                                          borderRadius: BorderRadius.all(Radius.circular(10))
                                      ),
                                      child: GestureDetector(
                                        onTap: () async {
                                          DateTime? pickedDate = await _selectDate(context);
                                          if (pickedDate != null) {
                                            print(pickedDate);
                                            setState(() {
                                              selectedDate = pickedDate;
                                            });
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            Container(
                                              height: 32,
                                              width: 32,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.all(Radius.circular(10))
                                              ),
                                              child: Icon(Icons.timelapse,color: Colors.pink.withOpacity(0.8),),
                                            ),
                                            SizedBox(width: 5,),

                                            Text(
                                              ' ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                                              style: TextStyle(
                                                color: selectedDate == null ? Colors.white : Colors.white, // Change text color based on whether date is selected or not
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        DateTime? pickedTime = await _selectTime(context);
                                        if (pickedTime != null) {
                                          setState(() {
                                            selectedTime = TimeOfDay.fromDateTime(pickedTime);
                                          });
                                        }
                                      },
                                      child: Container(
                                        height: 50,
                                        padding: EdgeInsets.only(left: 20, right: 10),
                                        decoration: BoxDecoration(
                                            color: Colors.pink.withOpacity(0.8),
                                            borderRadius: BorderRadius.all(Radius.circular(10))
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
                                            if (selectedTime == null) // Show this only if time is not selected yet
                                              Text('Select a time',style: TextStyle(color: Colors.white),),
                                            if (selectedTime != null) // Show this if time is selected
                                              Text('${selectedTime.format(context)}',style: TextStyle(color: Colors.white),),
                                            SizedBox(width: 13,),


                                          ],
                                        ),
                                      ),
                                    ),



                                  ],
                                ),
                              ),

                              SizedBox(height: 20,),

                              GestureDetector(
                                onTap: (){
                                  isloading =  true;
                                  if(_receivedfrom=="From"||_receivedto==""){
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
                                      Text('Book '+widget.type,
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
                          )

                      )
                  ),
                ],
              ),),
            Visibility(
                visible: isloading ,
                child: Container(
                  margin: EdgeInsets.only(top: screenHeight*0.14),
                  height: screenHeight*0.86,
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
    final String fullName = "Book "+widget.type;
    final String company = "- from "+_receivedfrom+"to "+_receivedto;
    final String amountText = "0010";
    final String prof = "Driver";
    final String  fareamounts= _farecontroller.text;

    double amount = 0.0;

    if (amountText.isNotEmpty) {
      amount = double.tryParse(amountText) ?? 0.0;
    }

    final int age = int.tryParse("0010") ?? 0;

    if (fareamounts!="") {

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
            cod: 'null',
            toTypedaddress: "",
            fromTypedaddress: "",
            pickupinstruction: "",
            pickupphone: "",
            deliveryphone: "",
            deliveryinstruction: "",
            category: 'bookride'+passenger.toString(),
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
            fileData: [],
            fromlongitude: _fromlongitude,
            fromlatitude: _fromlatitude,
            fromaddress: _receivedfrom,
            tolongitude: _tolongitude,
            tolatitude: _tolatitude,
            toaddress:_receivedto,
            payment: false,
            tip: 0,
            grandtotal: 0

        );

        String? result = await APIs.addWork(myWork,fullName);
        // Clear text fields and reset form

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>   SuccessScreen()),
        );
        APIs.sendnotificationtowork(company,'others');

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enter Amount'),
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



