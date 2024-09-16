import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:perwork/screens/costumer/SuccessScreen.dart';
import 'package:perwork/screens/costumer/pickdeliverylocation.dart';
import 'package:perwork/screens/costumer/pickmultilocation.dart';
import 'package:perwork/screens/naviagtion_items/HomeScreenContent.dart';
import 'package:perwork/screens/profilescreen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:slide_to_act/slide_to_act.dart';

import '../../api/apis.dart';
import '../../models/work.dart';
import '../../taskerdash/workapplications.dart';
import '../../try/chatlist.dart';
import '../../try/shownotifications.dart';
import '../../utils/LocationService.dart';
import '../costumer/ViewWorkContent.dart';
import '../maps/PickLocationScreen.dart';
import '../userbooking.dart';
import 'package:badges/badges.dart' as badges;


class AddWork extends StatefulWidget {
  final String companyName;

  AddWork({required this.companyName});

  @override
  _AddWorkState createState() => _AddWorkState();
}

class _AddWorkState extends State<AddWork> {
  final TextEditingController companyController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController profcontroller = TextEditingController();

  List<File> selectedFiles = [];

  late DateTime selectedDate = DateTime.now();
  late TimeOfDay selectedTime = TimeOfDay.now();
  bool isNegotiable = true;
  String selectedPriority = 'Normal';
  static FirebaseAuth auth = FirebaseAuth.instance;
  static User get user => auth.currentUser!;
  double _latitude = 0.0;
  double _longitude = 0.0;
  late LocationService _locationService;
  int nnotibooking = 0;
  int nnotiwork = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;
  void _startAutoScroll() {
    _scrollTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (_scrollController.hasClients) {
        final maxScrollExtent = _scrollController.position.maxScrollExtent.toDouble();
        final currentScrollPosition = _scrollController.position.pixels.toDouble();
        final targetPosition = currentScrollPosition < maxScrollExtent ? currentScrollPosition + 200.0 : 0.0;
        _scrollController.animateTo(
          targetPosition,
          duration: Duration(seconds: 2),
          curve: Curves.easeInOut,
        );
      }
    });
  }



  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }
  void getdate() async{
    final DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance.collection('users').doc(APIs.me.id).get();
    setState(() {
      nnotibooking = profileSnapshot['nnotibooking'];
      nnotiwork = profileSnapshot['nnotiwork'];
    });


  }



  Future<void> _getCurrentLocation() async {
    FirebaseFirestore.instance.collection('users').doc(APIs.me.id).snapshots().listen((DocumentSnapshot snapshot) {
      setState(() {
        _latitude = snapshot['latitude'] ?? 0;
        _longitude = snapshot['longitude'] ?? 0;

      });
    });

  }


  bool isLoading = false;
  bool filesUploadedSuccessfully = false;
  bool isUploading = false;
  List<Map<String, String>> fileData = [];
  String _paymentOption = '';
  late Razorpay _razorpay;
  bool _isPaymentInProgress = false;
  PickResult? selectedPlace;
  String workType = "";
  String mpercentage = "";
  String full_address_drop = "";
  String landmark_drop = "";
  String delivery_instructions_drop = "";


  Future<void> fetchChatCompletion(String des) async {
    final String url = 'https://api.openai.com/v1/chat/completions';
    final String apiKey = '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';

    final Map<String, dynamic> requestBody = {
      "model": "gpt-3.5-turbo-0125",
      "response_format": {"type": "json_object"},
      "messages": [
        {
          "role": "system",
          "content": "You are a helpful assistant designed to output JSON."
        },
        {
          "role": "user",
          "content":
          "Classify the work as 1. Delivery or pickup drop off or bring something buy something 2. Any other work the work is - "+des+". return the answer in 1 or 2 with matching percentage"
        }
      ]
    };

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print(jsonResponse);
        Map<String, dynamic> content = jsonDecode(jsonResponse['choices'][0]['message']['content']);

// Initialize variables with default values
        String classification = '';
        String percentage = '';

// Extract classification and percentage from the content Map
        if (content.containsKey('matching_percentage')) {
          percentage = content['matching_percentage'].toString();
        } else if (content.containsKey('percentage')) {
          percentage = content['percentage'].toString();
        }

        if (content.containsKey('classification')) {
          classification = content['classification'].toString();
        }

        print('Classification: $classification');
        print('Percentage: $percentage');

        setState(() {
          workType = classification;
          mpercentage = percentage;
        });



      } else {
        print('Failed to fetch chat completion. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
  @override
  void initState() {
    super.initState();
    companyController.text = widget.companyName;
    _startAutoScroll();
    getdate();

    _locationService = LocationService();
  }


  String _receivedText = 'Add Work Location';
  double longitude = 0.0;
  double latitude = 0.0;
  String address = "";
  double fromLatitude= 0.0;
  double fromLongitude = 0.0;
  String receivedFrom = "";
  double toLatitude = 0.0;
  double toLongitude = 0.0;
  String receivedTo = "";
  bool assignAutomatically = false;

  void _updateReceivedText(double longitude, double latitude, String address) {
    setState(() {
      this.longitude = longitude;
      this.latitude = latitude;
      this.address = address;
      _receivedText = 'Location Picked';
    });
  }
  String getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Morning';
    } else if (hour < 17) {
      return 'Afternoon';
    } else {
      return 'Evening';
    }
  }
  bool pickupSelected = false;
  bool otherSelected = true;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Dismiss keyboard when tapping outside
      },
      child: Scaffold(
        backgroundColor: Colors.white,
          body: Stack(
            children: [
              Container(
                height: screenHeight * 0.14,
                decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/backofwork.png"),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
                child: Container(
                  margin: EdgeInsets.only(left: 20, right: 20, top: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40, // Adjust according to your needs
                                height: 40, // Adjust according to your needs
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.0, // Adjust border width if needed
                                  ),
                                ),
                                child: Center(
                                  child: GestureDetector(
                                    onTap: (){
                                      Navigator.pop(context);
                                    },
                                    child: FaIcon(
                                      FontAwesomeIcons.arrowLeft, // Adjust icon as needed
                                      size: 20, // Adjust icon size as needed
                                      color: Colors.white, // Adjust icon color as needed
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 18,),
                              Text("Post Work",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 21,
                                    fontWeight: FontWeight.w500
                                ),)
                            ],
                          ),
                          Row(
                            children: [

                              SizedBox(width: 13),
                              GestureDetector(
                                onTap: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                                  );
                                },
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    isLoading ? 'https://cdn.dribbble.com/userupload/12569823/file/original-36e7a80c78bcefa16371969c139e81ea.jpg?resize=1504x1128' : APIs.me.image,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: screenHeight*0.14),
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus(); // Dismiss keyboard when tapping outside
                  },
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15,right: 15,top: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      pickupSelected = true;
                                      otherSelected = false;
                                    });
                                  },
                                  child: Container(
                                    height: 34,
                                    padding: EdgeInsets.only(left: 10,right: 10),
                                    decoration: BoxDecoration(
                                        color: pickupSelected?Colors.pink.withOpacity(0.9):Colors.white,
                                        borderRadius: BorderRadius.circular(17),
                                        border: Border.all(color:pickupSelected?Colors.pink:Colors.pink,width: 1 )
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Pickup/Delivery",
                                        style: TextStyle(fontSize: 16, color: pickupSelected?Colors.white:Colors.pink),
                                      ),
                                    ),

                                  )
                              ),
                              SizedBox(width: 11,),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    pickupSelected = false;
                                    otherSelected = true;
                                  });
                                },
                                child: Container(
                                  height: 34,
                                  padding: EdgeInsets.only(left: 10,right: 10),
                                  decoration: BoxDecoration(
                                      color: otherSelected?Colors.pink.withOpacity(0.9):Colors.white,
                                      borderRadius: BorderRadius.circular(17),
                                      border: Border.all(color:otherSelected?Colors.pink:Colors.pink,width: 1 )
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Others",
                                      style: TextStyle(fontSize: 16, color: otherSelected?Colors.white:Colors.pink),
                                    ),
                                  ),

                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10,),
                          Container(
                            height: 100,
                            width: screenWidth * 0.9,
                            padding: EdgeInsets.only(left: 20, right: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100.withOpacity(0.8),
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
                                hintText: 'Enter your work...',
                                border: InputBorder.none, // You can customize the border as needed
                              ),
                            ),
                          ),

                          SizedBox(height: 15,),
                          Container(
                            margin: EdgeInsets.only(left: 6,right: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                    width: screenWidth*0.45,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Image.asset("assets/information.png",height: 30,width: 30,),
                                        SizedBox(width: 5,),
                                        Container(
                                          width: screenWidth*0.42-28,
                                          child: Text(
                                              "Enter amount you're ready to pay!"
                                          ),
                                        )
                                      ],
                                    )
                                ),
                                Container(
                                  height: 60,
                                  width: screenWidth * 0.42,
                                  padding: EdgeInsets.only(left: 20, right: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100.withOpacity(0.8),
                                    borderRadius: BorderRadius.all(Radius.circular(15)),
                                  ),
                                  child: Center(
                                    child: TextField(
                                      controller: ageController,
                                      maxLines: 1,
                                      decoration: InputDecoration(
                                        hintText: "Price",
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ),





                          SizedBox(height: 15),
                          GestureDetector(
                            onTap: () {
                              if (!isUploading) {
                                _pickFiles();
                              }
                            },
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.2,
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.only(left: 7, right: 7),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: isUploading
                                    ? SizedBox()
                                    : Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset("assets/folder.png", height: 90, width: 90),
                                    Text(
                                      filesUploadedSuccessfully ? "Files uploaded successfully" : "Upload and Attach files",
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
                          SizedBox(height: 15),
                          GestureDetector(
                            onTap: ()async{
                              // Open PickMultiLocation screen and wait for result
                              if(pickupSelected){
                                Map<String, dynamic>? result = await Navigator.push(context, MaterialPageRoute(builder: (context) => PickDeliveryLocation()));

                                // Handle the received data
                                if (result != null) {
                                  fromLatitude = double.parse(result['fromLongitude'].toStringAsFixed(6));
                                  fromLongitude = double.parse(result['fromLatitude'].toStringAsFixed(6));
                                  receivedFrom = result['receivedFrom'];
                                  _receivedText = receivedFrom;
                                  toLatitude = double.parse(result['toLongitude'].toStringAsFixed(6));
                                  toLongitude = double.parse(result['toLatitude'].toStringAsFixed(6));
                                  receivedTo = result['receivedTo'];


                                  // Do something with the received data
                                }
                              }
                              else{
                                Map<String, dynamic>? result = await Navigator.push(context, MaterialPageRoute(builder: (context) => PickMultiLocation()));

                                // Handle the received data
                                if (result != null) {
                                  setState(() {
                                    full_address_drop = result['full_address'];
                                    landmark_drop = result['landmark'];
                                    delivery_instructions_drop = result['add_direction'];
                                    print(full_address_drop);
                                    print(landmark_drop);
                                    print(delivery_instructions_drop);
                                    fromLatitude = double.parse(result['fromLongitude'].toStringAsFixed(6));
                                    fromLongitude = double.parse(result['fromLatitude'].toStringAsFixed(6));
                                    receivedFrom = result['receivedFrom'];
                                    _receivedText = receivedFrom;
                                    toLatitude = double.parse(result['toLongitude'].toStringAsFixed(6));
                                    toLongitude = double.parse(result['toLatitude'].toStringAsFixed(6));
                                    receivedTo = result['receivedTo'];
                                  });


                                  // Do something with the received data
                                }
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100.withOpacity(0.8),
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                              ),
                              margin: EdgeInsets.only(left: 10,right: 10),
                              height: 70,
                              width: screenWidth,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 13,right: 13),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: screenWidth*0.65,
                                      child: Text(_receivedText,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 18

                                        ),),
                                    ),
                                    Icon(Icons.arrow_forward_ios,color: Colors.black,)
                                  ],
                                ),
                              ),
                            ),
                          ),


// Function to get icon based on received t



                          SizedBox(height: 20),
                          // Loading animation based on isLoading state


                          GestureDetector(
                            onTap: () {
                              //_addUser();
                              final String company = companyController.text;
                              final String amountText = ageController.text;
                              final String prof = profcontroller.text;
                              double amount = 0.0;

                              if (amountText.isNotEmpty) {
                                amount = double.tryParse(amountText) ?? 0.0;
                              }

                              final int age = int.tryParse(ageController.text) ?? 0;

                              if (company.isEmpty){
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Please fill in all fields.'),
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
                                if(pickupSelected){
                                  if(receivedTo==""){
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Please select destination Location'),
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
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (BuildContext context) {
                                        return StatefulBuilder(
                                          builder: (BuildContext context, StateSetter setState) {
                                            return Container(
                                              height: MediaQuery.of(context).size.height*0.35,
                                              width: MediaQuery.of(context).size.width,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(topLeft: Radius.circular(100), topRight: Radius.circular(50)),
                                              ),
                                              child: AnimatedContainer(
                                                duration: Duration(milliseconds: 300),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
                                                ),
                                                child: Container(

                                                  padding: EdgeInsets.only(top: 10,bottom: 20,left: 20,right: 20),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Container(
                                                        margin: EdgeInsets.only(top: 10),
                                                        width: 60,
                                                        height: 7,
                                                        decoration: BoxDecoration(
                                                            color: Colors.grey.shade200,
                                                            borderRadius: BorderRadius.circular(10)
                                                        ),
                                                      ),
                                                      SizedBox(height: 7,),

                                                      Text("Pick the Time",
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 25,
                                                            fontWeight: FontWeight.w500
                                                        ),),
                                                      SizedBox(height: 10,),
                                                      GestureDetector(
                                                        onTap: () {
                                                          // Define a function to create and handle the dialog
                                                          _addUser();
                                                        },
                                                        child: Container(
                                                          padding: EdgeInsets.only(right: 20),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.all(Radius.circular(20)),
                                                            color: Colors.orangeAccent.shade100,
                                                          ),
                                                          width: MediaQuery.of(context).size.width * 0.9,
                                                          height: 70,
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  SizedBox(width: 15),
                                                                  Container(
                                                                    height: 50,
                                                                    width: 50,
                                                                    decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius.all(Radius.circular(15)),
                                                                      color: Colors.white,
                                                                    ),
                                                                    child: Center(
                                                                      child: Image.asset(
                                                                        "assets/clock.png",
                                                                        height: 35,
                                                                        width: 35,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(width: 10),
                                                                  Text(
                                                                    "As Soon As Possible",
                                                                    style: TextStyle(
                                                                      color: Colors.black,
                                                                      fontWeight: FontWeight.w400,
                                                                      fontSize: screenWidth * 0.05, // Adjust the font size as needed
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Icon(
                                                                Icons.keyboard_arrow_down_sharp,
                                                                color: Colors.black,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),






                                                      SizedBox(height: 15,),
                                                      GestureDetector(
                                                        onTap: () {
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
                                                                                  color: Colors.pink.withOpacity(0.7),
                                                                                  borderRadius: BorderRadius.all(Radius.circular(15))
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
                                                                                    color: Colors.grey.shade200,
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
                                                                                _addUser();
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
                                                        child: Container(
                                                          padding: EdgeInsets.only(right: 20),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.all(Radius.circular(20)),
                                                            color: Colors.grey.shade100.withOpacity(0.8),
                                                          ),
                                                          width: MediaQuery.of(context).size.width*0.9,
                                                          height: 70,
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  SizedBox(width: screenWidth*0.02,),
                                                                  Container(
                                                                    height: 50,
                                                                    width: 50,
                                                                    decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.all(Radius.circular(15)),
                                                                        color: Colors.white
                                                                    ),
                                                                    child: Center(child: Image.asset("assets/working.png",height: 35,width: 35,)),
                                                                  ),
                                                                  SizedBox(width: screenWidth*0.02,),

                                                                  Text("Choose Custom Time",style:
                                                                  TextStyle(
                                                                      color: Colors.black,
                                                                      fontWeight: FontWeight.w400,
                                                                      fontSize: screenWidth*0.05
                                                                  ),),
                                                                ],
                                                              ),

                                                              Icon(Icons.keyboard_arrow_down_sharp,color: Colors.black,)


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
                                        );
                                      },
                                    );
                                  }
                                }
                                else{
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (BuildContext context) {
                                      return StatefulBuilder(
                                        builder: (BuildContext context, StateSetter setState) {
                                          return Container(
                                            height: MediaQuery.of(context).size.height*0.35,
                                            width: MediaQuery.of(context).size.width,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(topLeft: Radius.circular(100), topRight: Radius.circular(50)),
                                            ),
                                            child: AnimatedContainer(
                                              duration: Duration(milliseconds: 300),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
                                              ),
                                              child: Container(

                                                padding: EdgeInsets.only(top: 10,bottom: 20,left: 20,right: 20),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(top: 10),
                                                      width: 60,
                                                      height: 7,
                                                      decoration: BoxDecoration(
                                                          color: Colors.grey.shade200,
                                                          borderRadius: BorderRadius.circular(10)
                                                      ),
                                                    ),
                                                    SizedBox(height: 7,),

                                                    Text("Pick the Time",
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 25,
                                                          fontWeight: FontWeight.w500
                                                      ),),
                                                    SizedBox(height: 10,),
                                                    GestureDetector(
                                                      onTap: () {
                                                        // Define a function to create and handle the dialog
                                                        _addUser();
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.only(right: 20),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.all(Radius.circular(20)),
                                                          color: Colors.orangeAccent.shade100,
                                                        ),
                                                        width: MediaQuery.of(context).size.width * 0.9,
                                                        height: 70,
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                SizedBox(width: 15),
                                                                Container(
                                                                  height: 50,
                                                                  width: 50,
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.all(Radius.circular(15)),
                                                                    color: Colors.white,
                                                                  ),
                                                                  child: Center(
                                                                    child: Image.asset(
                                                                      "assets/clock.png",
                                                                      height: 35,
                                                                      width: 35,
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(width: 10),
                                                                Text(
                                                                  "As Soon As Possible",
                                                                  style: TextStyle(
                                                                    color: Colors.black,
                                                                    fontWeight: FontWeight.w400,
                                                                    fontSize: screenWidth * 0.05, // Adjust the font size as needed
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Icon(
                                                              Icons.keyboard_arrow_down_sharp,
                                                              color: Colors.black,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),






                                                    SizedBox(height: 15,),
                                                    GestureDetector(
                                                      onTap: () {
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
                                                                                color: Colors.pink.withOpacity(0.7),
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
                                                                                  color: Colors.grey.shade200,
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
                                                                              _addUser();
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
                                                      child: Container(
                                                        padding: EdgeInsets.only(right: 20),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.all(Radius.circular(20)),
                                                          color: Colors.grey.shade100.withOpacity(0.8),
                                                        ),
                                                        width: MediaQuery.of(context).size.width*0.9,
                                                        height: 70,
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                SizedBox(width: screenWidth*0.02,),
                                                                Container(
                                                                  height: 50,
                                                                  width: 50,
                                                                  decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius.all(Radius.circular(15)),
                                                                      color: Colors.white
                                                                  ),
                                                                  child: Center(child: Image.asset("assets/working.png",height: 35,width: 35,)),
                                                                ),
                                                                SizedBox(width: screenWidth*0.02,),

                                                                Text("Choose Custom Time",style:
                                                                TextStyle(
                                                                    color: Colors.black,
                                                                    fontWeight: FontWeight.w400,
                                                                    fontSize: screenWidth*0.05
                                                                ),),
                                                              ],
                                                            ),

                                                            Icon(Icons.keyboard_arrow_down_sharp,color: Colors.black,)


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
                                      );
                                    },
                                  );
                                }
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
                              child: Center(child: Text('Post Work',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 21
                                ),)),
                            ),
                          ),
                          SizedBox(height: 10,),
                          Container(
                            height: 180,
                            child: StreamBuilder<QuerySnapshot>(
                              stream: _firestore.collection('examples').snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(child: Text('Error: ${snapshot.error}'));
                                } else {
                                  var items = snapshot.data!.docs.map((doc) {
                                    return {
                                      'name': doc['name'],
                                      'title': doc['title'],
                                      'image': doc['image'],
                                    };
                                  }).toList();

                                  return ListView.builder(
                                    controller: _scrollController,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: items.length,
                                    itemBuilder: (context, index) {
                                      var item = items[index];
                                      String title = item['title'];
                                      int maxLength = 45; // Define the maximum length of the title text
                                      return Container(
                                        padding: EdgeInsets.only(left: 10, right: 5, top: 7, bottom: 5),
                                        width: screenWidth * 0.75,
                                        height: 190,
                                        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(15.0),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Image.network(
                                                  item['image'],
                                                  height: 53,
                                                  width: 53,
                                                  fit: BoxFit.cover, // Ensure the image fills the container
                                                  // Optionally, add a borderRadius to the image
                                                  // borderRadius: BorderRadius.circular(20.0),
                                                ),
                                                SizedBox(width: 10), // Add some space between the image and text
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        _cutTitle(title, maxLength),
                                                        style: TextStyle(
                                                          fontSize: 15.0,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                        maxLines: 2, // Limit to two lines for the title
                                                        overflow: TextOverflow.ellipsis, // Show ellipsis if text overflows
                                                      ),

                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (title.length > maxLength) // Check if the title is longer than maxLength
                                              Text(
                                                maxLines: 3,
                                                overflow: TextOverflow.clip,
                                                title.substring(_cutTitle(title, maxLength).length),
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                          ],
                                        ),
                                      )
                                      ;
                                    },
                                  );
                                }
                              },
                            ),
                          ),


                        ],
                      ),
                    ),
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
    final String company = companyController.text;
    final String amountText = ageController.text;
    final String prof = profcontroller.text;
    double amount = 0.0;

    if (amountText.isNotEmpty) {
      amount = double.tryParse(amountText) ?? 0.0;
    }

    final int age = int.tryParse(ageController.text) ?? 0;

    if (company.isNotEmpty) {

      try {
        setState(() {
          Navigator.pop(context);
          isLoading = true; // Show loading animation
        });

        Work myWork = Work(          choose: true,

            createdAt: DateTime
                .now()
                .millisecondsSinceEpoch
                .toString(),
            name: company,
            cod: 'null',
            category: pickupSelected?"pickup":"others",
            description: "",
            dateTime: DateTime(selectedDate.year, selectedDate.month,
                selectedDate.day, selectedTime.hour, selectedTime.minute),
            amount: amount,
            negotiable: isNegotiable,
            toTypedaddress: "",
            fromTypedaddress: "",
            pickupinstruction: "",
            pickupphone: "",
            deliveryphone: "",
            deliveryinstruction: "",
            priority: selectedPriority,
            workBy: user.uid,
            status: "process",
            id: '',
            prof: prof,
            reviewdone: false,
            fileData: fileData,
            fromlongitude: fromLatitude,
            fromlatitude: fromLongitude,
            fromaddress: receivedFrom,
            tolongitude: toLatitude,
            tolatitude: toLongitude,
            toaddress:receivedTo,
            payment: false,
            tip: 0,
            grandtotal: 0

        );

        String? result = await APIs.addWork(myWork,company);
        // Clear text fields and reset form
        companyController.clear();
        ageController.clear();
        profcontroller.clear();
        selectedFiles.clear();
        selectedDate = DateTime.now();
        selectedTime = TimeOfDay.now();
        isNegotiable = false;
        selectedPriority = 'Normal';
        _receivedText = 'Add Work Location';
        longitude = 0.0;
        latitude = 0.0;
        address = "";
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>   SuccessScreen()),
        );
        APIs.sendnotificationtowork(company,pickupSelected?"delivery":"others");

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
          // Clear text fields and reset form
          companyController.clear();
          ageController.clear();
          profcontroller.clear();
          selectedFiles.clear();
          selectedDate = DateTime.now();
          selectedTime = TimeOfDay.now();
          isNegotiable = false;
          selectedPriority = 'Normal';
          _receivedText = 'Add Work Location';
          longitude = 0.0;
          latitude = 0.0;
          address = "";
          isLoading = false; // Hide loading animation
        });
      }
    } else {
    }
  }
}
String _cutTitle(String title, int maxLength) {
  if (title.length <= maxLength) {
    return title;
  } else {
    int lastSpaceIndex = title.substring(0, maxLength).lastIndexOf(' ');
    return title.substring(0, lastSpaceIndex);
  }
}

