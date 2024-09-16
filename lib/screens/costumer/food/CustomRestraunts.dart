import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:io';

import '../../../api/apis.dart';
import '../../../models/dishcart.dart';
import '../../../try/my_global.dart';
import '../../../try/pigeon.dart';
import '../../../utils/LocationService.dart';

void main() {
  runApp(MaterialApp(
    home: CustomRestaurant(),
  ));
}

class CustomRestaurant extends StatefulWidget {
  const CustomRestaurant({Key? key}) : super(key: key);

  @override
  State<CustomRestaurant> createState() => _RestrauntScreenState();
}

class _RestrauntScreenState extends State<CustomRestaurant> {
  List<Map<String, dynamic>> dishes = []; // List to store dishes and quantities

  TextEditingController dishNameController = TextEditingController(); // Controller for dish name text field
  TextEditingController quantityController = TextEditingController(); // Controller for quantity text field
  double _fromlatitude = 0.0;
  double _fromlongitude = 0.0;
  double _tolatitude = 0.0;
  double _tolongitude = 0.0;
  double _latitude = 0.0;
  bool isLoading = false;
  double _longitude = 0.0;

  PickResult? selectedFromPlace;
  PickResult? selectedToPlace;
  String restImage = "";
  String restSpecs = "";
  String restname = "";
  String restAddress = "";
  String receivedFrom = "";
  String _receivedfrom = "Select Store Location";
  String _receivedto = "Select Delivery Location";
  LatLng _markerLocation = LatLng(0.0,0.0);
  LatLng _frommarkerLocation = LatLng(0.0,0.0);
  LatLng _tomarkerLocation = LatLng(0.0,0.0);
  int fareamount = 0;
  final TextEditingController _farecontroller = TextEditingController();

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
    _getCurrentLocation();
    _locationService = LocationService();
    isloading = false;

  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Custom Restaurant"),
      ),
      body: Column(
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
                    visible: true,
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
                                                ? Globals.apiKey
                                                : Globals.apiKey,
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
          SizedBox(height: 5,),
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
                                    ? Globals.apiKey
                                    : Globals.apiKey,
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
          Container(
            height: dishes.length*100,
            child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: dishes.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(left: 15, right: 15),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        border: Border.all(color: Colors.grey.shade300),
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.all(7),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(35)),
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl:
                              "https://cdn.dribbble.com/userupload/7695541/file/original-620aa7f90d8e125a10179577588ac0d7.png?resize=2048x1536",
                              width: 62,
                              height: 62,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: 62,
                                  height: 62,
                                  color: Colors.white,
                                ),
                              ),
                              errorWidget: (context, url, error) => Icon(Icons.error),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dishes[index]['name'],
                                    maxLines: 2, // Allow max 2 lines before ellipsis
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 17,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            dishes[index]['quantity']++;
                                          });
                                        },
                                        child: Image.asset(
                                          "assets/plus.png",
                                          height: 26,
                                          width: 26,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        dishes[index]['quantity'].toString(),
                                        style: TextStyle(fontSize: 19),
                                      ),
                                      SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () {
                                          if (dishes[index]['quantity'] > 1) {
                                            setState(() {
                                              dishes[index]['quantity']--;
                                            });
                                          } else {
                                            setState(() {
                                              dishes.removeAt(index);
                                            });
                                          }
                                        },
                                        child: Image.asset(
                                          "assets/minus.png",
                                          height: 26,
                                          width: 26,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: dishNameController,
                    decoration: InputDecoration(labelText: 'Dish Name'),
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: TextField(
                    controller: quantityController,
                    decoration: InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {
                    String dishName = dishNameController.text.trim();
                    String quantityText = quantityController.text.trim();
                    if (dishName.isNotEmpty && quantityText.isNotEmpty) {
                      int quantity = int.tryParse(quantityText) ?? 1;
                      setState(() {
                        dishes.add({'name': dishName, 'quantity': quantity});
                        dishNameController.clear(); // Clear dish name text field
                        quantityController.clear(); // Clear quantity text field
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please enter both dish name and quantity.'),
                        ),
                      );
                    }
                  },
                  child: Text('Add More'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
