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


class BuyItems extends StatefulWidget {
  final String type;
  const BuyItems({Key? key,required this.type}) : super(key: key);

  @override
  State<BuyItems> createState() => _PickMultiLocationState();
}

class _PickMultiLocationState extends State<BuyItems> {

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

  bool isloading = true;
  Future<void> _getCurrentLocation() async {
    FirebaseFirestore.instance.collection('users').doc(APIs.me.id).snapshots().listen((DocumentSnapshot snapshot) {
      setState(() {
        _latitude = snapshot['latitude'] ?? 0.0;
        _longitude = snapshot['longitude'] ?? 0.0;
        _markerLocation = LatLng(_latitude, _longitude);
        isloading = false;
      });
    });

  }
  late LocationService _locationService;
  PickResult? selectedFromPlace;
  PickResult? selectedToPlace;

  String _receivedfrom = "Pick From Location";
  String _receivedto = "Select Delivery Location";
  double hline = 50.0;
  final TextEditingController companyController = TextEditingController();
  bool filesUploadedSuccessfully = false;
  bool isUploading = false;
  List<Map<String, String>> fileData = [];
  List<File> selectedFiles = [];
  late DateTime selectedDate = DateTime.now();
  late TimeOfDay selectedTime = TimeOfDay.now();
  @override
  void initState() {
    super.initState();
    _locationService = LocationService();

    _getCurrentLocation();

  }
  bool customstore = false;
  @override
  Widget build(BuildContext context) {
    final apiKey = Provider.of<ApiKeyProvider>(context).apiKey;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Dismiss keyboard when tapping outside
      },
      child: Scaffold(
          extendBodyBehindAppBar: false,
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
              widget.type.substring(0, 1).toUpperCase()+ widget.type.substring(1)+" Delivery",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          body: isloading?CircularProgressIndicator():Stack(
            children: [
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus(); // Dismiss keyboard when tapping outside
                },
                child: SingleChildScrollView(
                  child: Column(
                    children: [

                      Container(
                        margin:EdgeInsets.only(left: 14,right: 14),
                        padding:EdgeInsets.all(15),

                        width: screenWidth,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Get From your Fav Stores",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: screenHeight*0.0234,
                                      fontWeight: FontWeight.w400
                                  ),),


                                SizedBox(height: screenHeight*0.01,)
                              ],
                            ),
                            Visibility(
                                visible: !customstore,
                                child: GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      customstore = true;
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.only(left: 13,right: 13),
                                    height: screenHeight*0.07,
                                    decoration: BoxDecoration(
                                        color: Colors.pink.withOpacity(0.8),
                                        borderRadius: BorderRadius.all(Radius.circular(12))
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Add Store Location",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: screenHeight*0.0234,
                                              fontWeight: FontWeight.w500
                                          ),),
                                        Icon(Icons.arrow_forward,color: Colors.white,)],
                                    ),
                                  ),
                                )),
                            Visibility(
                                visible: customstore,
                                child: GestureDetector(
                                  onTap: (){

                                  },
                                  child:  Container(
                                    margin: EdgeInsets.only(top: 8),
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
                                )),

                          ],

                        ),
                      ),
                      SizedBox(height: 10,),
                      Container(
                        margin: EdgeInsets.only(top: 10),
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
                                    margin: EdgeInsets.only(left: 13,right: 13),
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
                                          child: Icon(Icons.arrow_downward,color: Colors.pink,),
                                        ),
                                        SizedBox(width: 13,),
                                        Container(
                                          width: 280,
                                          child: Text(_receivedto,
                                            overflow: TextOverflow.clip,
                                            maxLines: 2,
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
                      SizedBox(height: 12,),

                      Container(
                        height: 100,
                        margin: EdgeInsets.only(left: 13, right: 13),
                        width: screenWidth,
                        padding: EdgeInsets.only(left: 20, right: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
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
                            hintText: 'Enter your Items',
                            border: InputBorder.none, // You can customize the border as needed
                          ),
                        ),
                      ),
                      SizedBox(height: 7,),
                      Text("OR"),
                      SizedBox(height: 7,),
                      GestureDetector(
                        onTap: () {
                          if (!isUploading) {
                            _pickFiles();
                          }
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.2,
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(left: 13, right: 13),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: isUploading
                                ? CircularProgressIndicator()
                                : Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset("assets/cloud-upload.png", height: 75, width: 75),
                                Text(
                                  filesUploadedSuccessfully ? "Items uploaded successfully" : "Upload Items List",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15,),
                      Container(
                        padding: EdgeInsets.only(top: 3,bottom: 3),
                        decoration: BoxDecoration(
                            color: Colors.pink.withOpacity(0.8),
                            borderRadius: BorderRadius.all(Radius.circular(15))
                        ),
                        margin: EdgeInsets.only(left: 13,right: 13),
                        child: Row(
                          children: [
                            SizedBox(width: 10,),
                            Image.asset("assets/rupee.png",height: 30,width: 30,),
                            SizedBox(width: 10,),

                            Container(
                              width: screenWidth * 0.46,
                              child: TextField(
                                controller: _farecontroller,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Allow only numbers
                                style: TextStyle(fontSize: 21, color: Colors.white), // Set text color to white
                                decoration: InputDecoration(
                                  hintText: 'Offer your price', // Add hint text here
                                  hintStyle: TextStyle(color: Colors.white), // Set hint color to white
                                  border: InputBorder.none, // Remove underline
                                  contentPadding: EdgeInsets.zero, // Remove default padding
                                ),
                              ),
                            ),

                            Container(
                              height: 40,
                              width: 115,
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
                                      String inputText = ""; // Initial value for input text
                                      return StatefulBuilder(
                                        builder: (BuildContext context, StateSetter setState) {
                                          return Dialog(
                                            backgroundColor: Colors.transparent,
                                            elevation: 0,
                                            insetPadding: EdgeInsets.zero,

                                            child: Container(
                                              width: screenWidth*0.82,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(20),
                                                color: Colors.white,

                                              ),
                                              padding: EdgeInsets.all(20),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                                  children: [
                                                    Container(
                                                      height: 60,
                                                      width: screenWidth * 0.65,
                                                      padding: EdgeInsets.only(left: 20, right: 10),
                                                      decoration: BoxDecoration(
                                                          color: Colors.pink.withOpacity(0.9),
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
                                                              child: Icon(Icons.timelapse,color: Colors.pink,),
                                                            ),
                                                            SizedBox(width: 13,),
                                                            Text('Date: ',style: TextStyle(color: Colors.white,fontSize: 17),),
                                                            SizedBox(height: 15),
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
                                                    SizedBox(height: 13,),
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
                                                        height: 60,
                                                        width: screenWidth * 0.7,
                                                        padding: EdgeInsets.only(left: 20, right: 10),
                                                        decoration: BoxDecoration(
                                                            color: Colors.grey.shade100,
                                                            borderRadius: BorderRadius.all(Radius.circular(10))
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
                                                            Text('Time:',style: TextStyle(color: Colors.black87,fontSize: 17),),
                                                            SizedBox(width: 10),
                                                            if (selectedTime == null) // Show this only if time is not selected yet
                                                              Text('Select a time',style: TextStyle(color: Colors.black87),),
                                                            if (selectedTime != null) // Show this if time is selected
                                                              Text('${selectedTime.format(context)}',style: TextStyle(color: Colors.black87),),


                                                          ],
                                                        ),
                                                      ),
                                                    ),


                                                    SizedBox(height: 20),
                                                    OutlinedButton.icon(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        // Add onPressed action
                                                        // Close the
                                                        // Call function to post data to Firestore

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
                                                    )

                                                  ],
                                                ),
                                              ),

                                            ),
                                          );


                                        },
                                      );
                                    },
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.clock, // Adjust icon as needed
                                      size: 20, // Adjust icon size as needed
                                      color: Colors.pink.withOpacity(0.8), // Adjust icon color as needed
                                    ),
                                    SizedBox(width: 7), // Adding some space between the icon and the text
                                    Container(
                                      child: Text(
                                        "Now",
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
                      GestureDetector(
                        onTap: (){
                          if(_receivedto=="Select Delivery Location"){
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please Pick Delivery Location'),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 2),
                                action: SnackBarAction(
                                  label: 'OK',
                                  onPressed: () {},
                                ),
                              ),
                            );
                          }
                          else if(_farecontroller.text==""){
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Enter your offer price'),
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
                          margin: EdgeInsets.only(left: 13,right: 13),
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
                              Text('Buy '+widget.type,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 21
                                ),)
                            ],
                          ),
                        ),
                      ),



                    ],
                  ),
                ),
              ),
              Visibility(
                  visible: isLoading || isUploading,
                  child: Container(
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
    final String fullName = "Buy "+widget.type;
    final String company = "- from "+_receivedfrom+" to "+_receivedto;
    final String amountText = "0010";
    final String prof = "Driver";
    final String  fareamounts= _farecontroller.text;

    double amount = 0.0;

    if (amountText.isNotEmpty) {
      amount = double.tryParse(amountText) ?? 0.0;
    }

    final int age = int.tryParse("0010") ?? 0;

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
            cod: 'null',
            pickupinstruction: "",
            pickupphone: "",
            deliveryphone: "",
            deliveryinstruction: "",
            toTypedaddress: "",
            fromTypedaddress: "",
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


