
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:perwork/screens/costumer/viewprofilework.dart';
import 'package:perwork/widgets/showbillwork.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shimmer/shimmer.dart';

import '../../api/apis.dart';
import '../../chat/pages/home.dart';
import '../../try/editprofilescreen.dart';
import '../addreview.dart';
import '../maps/directionScreen.dart';
import '../profilescreen.dart';
import '../work/taskerWork.dart';
import 'package:google_maps_flutter_platform_interface/src/types/marker.dart' as GoogleMapsMarker;


class ShowMyWork extends StatefulWidget {
  final String workid;
  const ShowMyWork({Key? key, required this.workid}) : super(key: key);

  @override
  State<ShowMyWork> createState() => _ShowMyWorkState();
}

class _ShowMyWorkState extends State<ShowMyWork> {
  bool isLoading = false;
  late Future<DocumentSnapshot<Map<String, dynamic>>> workFuture;
  late Future<DocumentSnapshot<Map<String, dynamic>>> _fetchDataFuture;
  bool formto = false;
  bool form = false;
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
  String userName = "";




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


  @override
  void initState() {
    super.initState();
    _fetchDataFuture = FirebaseFirestore.instance.collection('work').doc(widget.workid).get();
    workFuture = FirebaseFirestore.instance.collection('work').doc(widget.workid).get();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
    player.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print(response.orderId);
    print(response.paymentId);
    print(response.signature);
    setState(() {

      _isPaymentInProgress = false; // Payment completed, so set the flag to false
    });
    APIs.makePayment(widget.workid, response.paymentId.toString());
    refreshPaymentDate();

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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ShowMyWork(workid: widget.workid)),
                        );

                        Navigator.pop(context);
                        Navigator.pop(context);
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              ShowMyWork(workid: widget.workid)),
                        );
                        Navigator.pop(context);
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
  bool _isLoading = false;

  Future<void> refreshAssignedData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance
          .collection('work')
          .doc(widget.workid)
          .get();

      if (profileSnapshot.exists) {
        setState(() {
          finalworkerAmount = profileSnapshot['finalamount'] ?? '';
          finalwokerid = profileSnapshot['assigned'] ?? '';
        });
      }

      setState(() {
        _fetchDataFuture = FirebaseFirestore.instance.collection('work').doc(widget.workid).get();

        allworkers = false;
        track = true;
        assigned = true;
        _isLoading = false;
        setState(() {
          isLoading = false;

          _isLoading = false;
        });
      });
    } catch (e) {
      print('Error fetching data: $e');
      // Handle error if necessary
    } finally {

    }
  }
  Future<void> refreshPaymentDate() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _fetchDataFuture = FirebaseFirestore.instance.collection('work').doc(widget.workid).get();
      final DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance
          .collection('work')
          .doc(widget.workid)
          .get();
      print("hey called ");

      if (profileSnapshot.exists) {
        setState(() {
          paymentdone = true;
          showpaynow = false;

        });
      }

      setState(() {
        _fetchDataFuture = FirebaseFirestore.instance.collection('work').doc(widget.workid).get();
        paymentdone = true;
        showpaynow = false;



      });
      print(showpaynow);
    } catch (e) {
      print('Error fetching data: $e');
      // Handle error if necessary
    } finally {
      setState(() {
        isLoading = false;
        _isLoading = false;
      });
    }
  }




  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    User user = auth.currentUser!;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    int platformfee =0;
    int gst = 0;
    int workertip = 0;
    int intValue = 0;
    bool ten = false;
    bool twenty = false;
    bool thirty = false;

    int grandtotal = platformfee+gst+workertip+intValue;
    return Scaffold(
      resizeToAvoidBottomInset: false,

      body: Stack(
        children: [

          SingleChildScrollView(
            child: Column(
              children: [

                Container(
                  height: screenHeight,
                  width: screenWidth,
                  padding: EdgeInsets.only(top: screenHeight*0.15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage("assets/backofprint.jpg")
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection:Axis.vertical,
                    child: Column(
                        children: [

                          FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                            future: _fetchDataFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                isLoading = true;
                                return Visibility(visible: false,child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                isLoading = false;

                                return Text('Error: ${snapshot.error}');
                              } else if (!snapshot.hasData || !snapshot.data!.exists) {
                                isLoading = false;

                                return Text('Work not found');
                              }
                              isLoading = false;


                              // Work details
                              Map<String, dynamic> workData = snapshot.data!.data()!;
                              String workid = workData['id']?? '';
                              String workName = workData['name'] ?? '';
                              double workAmount = (workData['amount'] ?? 0.0).toDouble();
                              String workamountstr = workAmount.toString();
                              String workPriority = workData['priority'] ?? '';
                              String workBy = workData['workBy'];
                              String firebaseDate = workData['dateTime'] ?? '';
                              String address = workData['fromaddress'] ?? '';
                              double latitude = workData['fromlatitude'] ?? '';
                              double longitude = workData['fromlongitude'] ?? '';
                              DateTime dateTime = DateTime.parse(firebaseDate);
                              bool rupeevisi = false;
                              String status = workData['status'] ?? '';
                              bool locationtrack = false;
                              int grandpay = 0;
                              int tippay = 0;
                              int platformfeepay = 0;
                              if(workData['toaddress']=="Pick To Location"){
                                formto = false;
                              }
                              else{
                                formto = true;
                              }
                              if(workData['fromaddress']=="Pick From Location"){
                                form = false;
                              }
                              else{
                                form = true;
                              }
                              paymentdone = workData['payment'];
                              if(paymentdone){
                                grandpay = workData['grandtotal'];
                                tippay = workData['tip'];
                                platformfeepay = 5;
                              }

                              if(workData['negotiable']==true){
                                rupeevisi = true;

                              }else{
                                finalworkerAmount = workAmount;
                                rupeevisi = false;
                              }
                              if(rupeevisi==false || status=="track" || status=="completed"){
                                if(paymentdone==false){
                                  showpaynow = true;

                                }
                              }
                              print("from 421");
                              print(showpaynow);
                              if (status == "posted"){
                                assigned = true;

                              }

                              else if (status=="track"){
                                finalwokerid = workData['assigned'] ?? '';
                                finalworkerAmount = workData['finalamount'] ?? '';
                                assigned = true;
                                track = true;
                                message = "CONFIRMED";
                              }
                              else if(status=="completed") {
                                assigned = true;
                                track = true;
                                allworkers = false;
                                completed = true;
                                finalwokerid = workData['assigned'] ?? '';
                                finalworkerAmount = workData['finalamount'] ?? '';
                                finalamount = workData['finalamount'] ?? '';
                                message = "COMPLETED";
                              }
                              if(workData['assigned']!=null){
                                locationtrack = true;
                              }
                              if(locationvisi){
                                if(track){
                                  locationvisi = false;
                                }
                              }
                              else if(status=="paydone"){

                                posted = true;
                                print("ehyyyyyyyyy");

                              }
                              if (!track){
                                allworkers = true;
                              }
                              String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
                              List<Map<String, dynamic>> fileData = (workData['fileData'] ?? [])?.cast<Map<String, dynamic>>() ?? [];
                              if(fileData.length==0){
                                attachmentvisi = false;
                                filevisi = false;
                              }
                              if(address==""){
                                locationtrack = false;
                                locationvisi = false;
                                print(latitude);
                                print(longitude);
                              }
                              String minemobile = "";
                              if(APIs.me.mobile==""){
                                minemobile = "Add Contact";
                              }
                              else{
                                minemobile = APIs.me.mobile;
                              }
                              List<String> words = APIs.me.name.split(' ');


                              String formattedTime = DateFormat('hh:mm a').format(dateTime); // 12-hour AM/PM format
                              final LatLng _markerLocation = LatLng(workData['fromlatitude'], workData['fromlongitude']);
                              final LatLng _markerLocation1 = LatLng(workData['tolatitude'], workData['tolongitude']);




                              return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                future: FirebaseFirestore.instance.collection('users').doc(workBy).get(),
                                builder: (context, userSnapshot) {
                                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                                    isLoading = true;
                                    return Visibility(visible: false,child: CircularProgressIndicator());
                                  } else if (userSnapshot.hasError) {

                                    isLoading = false;

                                    return Text('Error: ${userSnapshot.error}');
                                  } else if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                                    isLoading = false;

                                    return Text('User not found 1');
                                  }
                                  isLoading = false;


                                  // User details
                                  Map<String, dynamic> userData = userSnapshot.data!.data()!;
                                  String userName = userData['name'] ?? '';
                                  String userImage = userData['image'] ?? '';
                                  // Add more user details as needed

                                  return Container(
                                    padding: EdgeInsets.only(left: 10,top: 10,right: 10,bottom: 10),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Display user details
                                        Visibility(
                                          visible: true,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                height: screenHeight*0.1,
                                                width: screenWidth*0.6,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF3c3c3c),
                                                  borderRadius: BorderRadius.only(
                                                      topRight: Radius.circular(12),
                                                      topLeft: Radius.circular(12),
                                                      bottomLeft: Radius.circular(12)
                                                  ),


                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      height: screenHeight*0.11,
                                                      width: screenWidth*0.025,
                                                      color: Colors.blue,
                                                    ),
                                                    SizedBox(width: screenWidth*0.02,),
                                                    Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(formattedDate,
                                                          style: TextStyle(
                                                              fontSize: screenWidth*0.056,
                                                              fontWeight: FontWeight.w700,
                                                              color: Colors.white
                                                          ),),
                                                        Row(
                                                          children: [
                                                            Text("$formattedTime",
                                                              style: TextStyle(
                                                                  fontSize: screenWidth*0.047,
                                                                  color: Colors.white.withOpacity(0.7),
                                                                  fontWeight: FontWeight.w500
                                                              ),),

                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                height: screenHeight*0.1,
                                                width: screenWidth*0.3,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.all(Radius.circular(12)),
                                                    color: Color(0xFF3c3c3c)
                                                ),
                                                child: Center(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Image.asset('assets/verify.png',height: 50,width: 50,),
                                                      Text(
                                                        message,
                                                        style: TextStyle(color: Colors.green),
                                                      )

                                                    ],
                                                  ),
                                                ),
                                              )


                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 5,),
                                        Container(
                                          child: Text(workName,
                                            overflow: TextOverflow.clip,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w400,
                                                fontSize: screenWidth*0.05
                                            ),),

                                        ),
                                        Visibility(
                                            visible: workAmount!=0.0,
                                            child: Container(
                                              margin: EdgeInsets.only(top: 5),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Container(
                                                    height: screenHeight*0.13,
                                                    width: screenWidth*0.4,
                                                    padding: EdgeInsets.only(left: 14),
                                                    decoration: BoxDecoration(
                                                        color: Color(0xFF3c3c3c),
                                                        borderRadius: BorderRadius.all(Radius.circular(22))
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Image.asset("assets/rupee.png",height: 30,width: 30,),
                                                        SizedBox(height: 5,),

                                                        Text("Your Amount",style: TextStyle(
                                                            color: Colors.white.withOpacity(0.7),
                                                            fontSize: 15,
                                                            fontWeight: FontWeight.w500

                                                        ),),
                                                        Text('₹ $workamountstr',style: TextStyle(

                                                            color: Colors.white.withOpacity(0.7),
                                                            fontSize: 20,
                                                            fontWeight: FontWeight.w600

                                                        ),),
                                                      ],
                                                    ),

                                                  ),
                                                  Visibility(
                                                      visible: !track,
                                                      child: Container(
                                                          height: screenHeight*0.13,
                                                          width: screenWidth*0.4,
                                                          padding: EdgeInsets.only(left: 11),
                                                          decoration: BoxDecoration(
                                                              color: Color(0xFF3c3c3c),
                                                              borderRadius: BorderRadius.all(Radius.circular(22))
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Image.asset("assets/time.png",height: 30,width: 30,),
                                                              SizedBox(height: 5,),
                                                              Text("Work type",style: TextStyle(
                                                                  color: Colors.white.withOpacity(0.7),
                                                                  fontSize: 15,
                                                                  fontWeight: FontWeight.w500
                                                              ),),
                                                              Text(workData['category'].substring(0, 1).toUpperCase() + workData['category'].substring(1),style: TextStyle(

                                                                  color: Colors.white.withOpacity(0.7),
                                                                  fontSize: 20,
                                                                  fontWeight: FontWeight.w600

                                                              ),),
                                                            ],
                                                          )
                                                      )
                                                  ),

                                                  Visibility(
                                                      visible: track,
                                                      child: Container(
                                                        padding: EdgeInsets.only(left: 8),
                                                        height: screenHeight*0.13,
                                                        width: screenWidth*0.4,
                                                        decoration: BoxDecoration(
                                                            color: Color(0xFF3c3c3c),
                                                            borderRadius: BorderRadius.all(Radius.circular(22))
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Image.asset("assets/rupee.png",height: 30,width: 30,),
                                                            SizedBox(height: 5,),
                                                            Text("Final Amount",style: TextStyle(
                                                                color: Colors.white.withOpacity(0.7),
                                                                fontSize: 15,
                                                                fontWeight: FontWeight.w500
                                                            ),),
                                                            Text("₹ "+finalworkerAmount.toString()+"+",style: TextStyle(

                                                                color: Colors.white.withOpacity(0.7),
                                                                fontSize: 20,
                                                                fontWeight: FontWeight.w600

                                                            ),),
                                                          ],
                                                        ),
                                                      )
                                                  ),

                                                ],
                                              ),
                                            )
                                        ),
                                        Visibility(
                                          visible: workData['choose'],
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Visibility(
                                                visible: allworkers,
                                                child: Container(
                                                  margin: EdgeInsets.only(left: 2,right: 10,top: 10),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text("Pick your worker",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 19,
                                                            fontWeight: FontWeight.w500
                                                        ),),

                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible: allworkers,
                                                child: Container(
                                                  margin: EdgeInsets.only(top: 5),
                                                  width:screenWidth,
                                                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                                    stream: FirebaseFirestore.instance.collection('work').doc(widget.workid).collection('workers').snapshots(),
                                                    builder: (context, snapshot) {
                                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                                        isLoading = true;

                                                        return Visibility(visible: false,child: CircularProgressIndicator());
                                                      } else if (snapshot.hasError) {
                                                        isLoading = false;

                                                        return Text('Error: ${snapshot.error}');
                                                      } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                                        isLoading = false;

                                                        return Row(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Image.asset("assets/hourglass.png",height: 40,width: 40,),
                                                            SizedBox(width: 10,),
                                                            Column(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [

                                                                Text('Currently no worker applied',style: TextStyle(color: Colors.white,fontSize: 16),),
                                                                Text('for this work Please Wait!',style: TextStyle(color: Colors.white,fontSize: 16)),
                                                              ],
                                                            ),
                                                          ],
                                                        );
                                                      }
                                                      isLoading = false;

                                                      // Worker collection processing
                                                      List<QueryDocumentSnapshot<Map<String, dynamic>>> workers = snapshot.data!.docs;
                                                      // Process workers here
                                                      return Container(
                                                        height: 200,
                                                        // Adjust width based on your requirement
                                                        child: ListView.builder(
                                                          scrollDirection: Axis.horizontal,
                                                          shrinkWrap: true,
                                                          itemCount: workers.length,
                                                          itemBuilder: (context, index) {
                                                            // Access each worker document
                                                            Map<String, dynamic> workerData = workers[index].data();
                                                            // Process worker details here
                                                            String workerId = workerData['workerID'] ?? '';
                                                            double workerAmount = workerData['amount'] ?? '';
                                                            double workerAmountcut = workerData['workeram'] ?? '';

                                                            String workerAmounts = workerAmount.toString();
                                                            // Return a FutureBuilder to get user details based on workerId
                                                            return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                                              future: FirebaseFirestore.instance.collection('prof').doc(workerId).get(),
                                                              builder: (context, userSnapshot) {
                                                                if (userSnapshot.connectionState == ConnectionState.waiting) {
                                                                  isLoading = true;

                                                                  return Visibility(visible: false,child: CircularProgressIndicator());
                                                                } else if (userSnapshot.hasError) {
                                                                  isLoading = false;
                                                                  return Text('Error: ${userSnapshot.error}');
                                                                } else if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                                                                  isLoading = false;

                                                                  return Text('User not found 2');
                                                                }
                                                                isLoading = false;

                                                                // Access user data and display details
                                                                Map<String, dynamic> userData = userSnapshot.data!.data()!;
                                                                String userName = userData['name'] ?? '';
                                                                String userRole = userData['email'] ?? '';
                                                                final List<dynamic> listspecs = userData['specs'] ?? [];
                                                                print(userData);

                                                                // Display worker information

                                                                return Container(
                                                                  margin: EdgeInsets.only(right: 10),
                                                                  height: screenHeight*0.2,
                                                                  width: screenWidth*0.75,
                                                                  padding: EdgeInsets.only(left: 5,right: 5,top: 5,bottom: 5),
                                                                  decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                      color: Colors.white,
                                                                      width: 1.0,
                                                                    ),
                                                                    borderRadius: BorderRadius.circular(20.0),
                                                                    color: Colors.transparent,


                                                                  ),
                                                                  child: Column(
                                                                    children: [
                                                                      Container(
                                                                        margin: EdgeInsets.only(left: 2,top: 2),
                                                                        child: Row(
                                                                          children: [
                                                                            ClipRRect(
                                                                              borderRadius: BorderRadius.all(Radius.circular(35)),
                                                                              child: CachedNetworkImage(
                                                                                fit: BoxFit.cover,
                                                                                imageUrl: userData['profile_image_url'], // URL of the image
                                                                                width: screenWidth*0.16, // Double the radius to fit the CircleAvatar
                                                                                height: screenWidth*0.16, // Double the radius to fit the CircleAvatar
                                                                                placeholder: (context, url) => Shimmer.fromColors(
                                                                                  baseColor: Colors.grey[300]!,
                                                                                  highlightColor: Colors.grey[100]!,
                                                                                  child: Container(
                                                                                    width: screenWidth*0.16, // Double the radius to fit the CircleAvatar
                                                                                    height: screenWidth*0.16, // Double the radius to fit the CircleAvatar
                                                                                    color: Colors.white,
                                                                                  ),
                                                                                ),
                                                                                errorWidget: (context, url, error) => Icon(Icons.error),
                                                                              ),

                                                                            ),

                                                                            SizedBox(width: 10,),
                                                                            Container(
                                                                              width: screenWidth*0.47,
                                                                              child: Column(
                                                                                children: [
                                                                                  Container(
                                                                                    width: screenWidth*0.915,
                                                                                    child: Text(
                                                                                      userData['name'],
                                                                                      style: TextStyle(
                                                                                        color: Colors.white,
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontSize: screenWidth*0.05,
                                                                                        overflow: TextOverflow.ellipsis, // or TextOverflow.ellipsis, etc.
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  Container(
                                                                                    width: screenWidth*0.915,
                                                                                    child: Text(
                                                                                      userData['username'],
                                                                                      style: TextStyle(
                                                                                        color: Colors.white,
                                                                                        fontWeight: FontWeight.w500,
                                                                                        fontSize: screenWidth*0.039,
                                                                                        overflow: TextOverflow.ellipsis, // or TextOverflow.ellipsis, etc.
                                                                                      ),
                                                                                    ),
                                                                                  ),

                                                                                ],
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 10,),
                                                                      Row(
                                                                        children: [
                                                                          Row(
                                                                            children: [
                                                                              Column(
                                                                                children: [
                                                                                  Container(
                                                                                    margin: EdgeInsets.only(left: 18,right: 10),
                                                                                    child: Row(
                                                                                      children: [
                                                                                        Image.asset("assets/expertise.png",width: screenWidth*0.07,height: screenWidth*0.07,),
                                                                                        Text("Experience",
                                                                                          style: TextStyle(
                                                                                              color: Colors.white.withOpacity(1),
                                                                                              fontWeight: FontWeight.w500,
                                                                                              fontSize: screenWidth*0.04
                                                                                          ),)
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(height: 2,),
                                                                                  Container(
                                                                                    margin: EdgeInsets.only(left: 20),
                                                                                    child: Text(userData['experience'],
                                                                                      style: TextStyle(
                                                                                          color: Colors.white,
                                                                                          fontWeight: FontWeight.w600,
                                                                                          fontSize: 17
                                                                                      ),),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          Visibility(
                                                                            visible: !rupeevisi,
                                                                            child: Column(
                                                                              children: [
                                                                                Container(
                                                                                  margin: EdgeInsets.only(left: 18,right: 10),
                                                                                  child: Row(
                                                                                    children: [
                                                                                      Image.asset("assets/star.png",width: 30,height: 30,),
                                                                                      Text("Ratings",
                                                                                        style: TextStyle(
                                                                                            color: Colors.white.withOpacity(1),
                                                                                            fontWeight: FontWeight.w500,
                                                                                            fontSize: 15
                                                                                        ),)
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                SizedBox(height: 2,),
                                                                                Container(
                                                                                    margin: EdgeInsets.only(left: 20),
                                                                                    child: Row(
                                                                                      children: [
                                                                                        Text(userData['rating']+" star",
                                                                                          style: TextStyle(
                                                                                              color: Colors.white,
                                                                                              fontWeight: FontWeight.w600,
                                                                                              fontSize: 17
                                                                                          ),),
                                                                                        Text("("+userData['totalrating']+")",
                                                                                          style: TextStyle(
                                                                                              color: Colors.white,
                                                                                              fontWeight: FontWeight.w600,
                                                                                              fontSize: 17
                                                                                          ),),

                                                                                      ],
                                                                                    )
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Visibility(
                                                                            visible: rupeevisi,
                                                                            child: Column(
                                                                              children: [
                                                                                Container(
                                                                                  margin: EdgeInsets.only(left: 18,right: 10),
                                                                                  child: Row(
                                                                                    children: [
                                                                                      Image.asset("assets/rupee.png",width: 30,height: 30,),
                                                                                      Text("Amount",
                                                                                        style: TextStyle(
                                                                                            color: Colors.white.withOpacity(1),
                                                                                            fontWeight: FontWeight.w500,
                                                                                            fontSize: 15
                                                                                        ),)
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                SizedBox(height: 2,),
                                                                                Container(
                                                                                    margin: EdgeInsets.only(left: 20),
                                                                                    child: Row(
                                                                                      children: [
                                                                                        Text("₹",
                                                                                          style: TextStyle(
                                                                                              color: Colors.white,
                                                                                              fontWeight: FontWeight.w600,
                                                                                              fontSize: 17
                                                                                          ),),
                                                                                        Text(workerAmounts,
                                                                                          style: TextStyle(
                                                                                              color: Colors.white,
                                                                                              fontWeight: FontWeight.w600,
                                                                                              fontSize: 17
                                                                                          ),),

                                                                                      ],
                                                                                    )
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),

                                                                      Container(
                                                                        margin:EdgeInsets.only(left: 10,right: 10),
                                                                        child: Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                          children: [OutlinedButton.icon(
                                                                            onPressed: () {
                                                                              // Add onPressed action
                                                                              try {

                                                                                APIs.acceptWork(workid, workerAmount, workerId,workerAmountcut);

                                                                                print('Work has been accepted successfully.');

                                                                                // Show alert box
                                                                                showDialog(
                                                                                  context: context,
                                                                                  barrierDismissible: false,
                                                                                  builder: (BuildContext context) {
                                                                                    return AlertDialog(

                                                                                      backgroundColor: Colors.white,
                                                                                      content: Column(
                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                        children: [
                                                                                          Lottie.asset(
                                                                                              'assets/lottie/success.json',
                                                                                              width: 100,
                                                                                              height: 100,
                                                                                              repeat: false
                                                                                          ),
                                                                                          SizedBox(height: 20),
                                                                                          Text(
                                                                                            "Work has been assigned to $userName",
                                                                                            style: TextStyle(
                                                                                              fontWeight: FontWeight.bold,
                                                                                              fontSize: 16,
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                      actions: [
                                                                                        TextButton(
                                                                                          onPressed: () {
                                                                                            isLoading = false;
                                                                                            refreshAssignedData();
                                                                                            isLoading = false;
                                                                                            // Perform any actions needed before closing the dialog
                                                                                            if(workData['category']=="pickup"){

                                                                                              Navigator.pushReplacement(
                                                                                                context,
                                                                                                MaterialPageRoute(builder: (context) => Navigation(workid: workData['id'], destlat: workData['tolatitude'], destlong: workData['tolongitude'], sourcelat: workData['fromlatitude'], sourcelong: workData['fromlongitude'], profid: workerId)),
                                                                                              );
                                                                                            }
                                                                                            else{
                                                                                              Navigator.pop(context);
                                                                                            }

                                                                                          },
                                                                                          child: Text('Done'),
                                                                                        ),
                                                                                      ],
                                                                                    );
                                                                                  },
                                                                                );
                                                                              } catch (e) {
                                                                                print('Error accepting work: $e');
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
                                                                              'Accept',
                                                                              style: TextStyle(
                                                                                color: Colors.pink,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                            OutlinedButton(
                                                                                onPressed: () {
                                                                                  // Add onPressed action

                                                                                  Navigator.push(
                                                                                    context,
                                                                                    MaterialPageRoute(builder: (context) => viewProfileWork(profid: userData['id'])),
                                                                                  );
                                                                                },
                                                                                style: OutlinedButton.styleFrom(
                                                                                  side: BorderSide(color: Colors.pink),
                                                                                  shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.circular(10.0),
                                                                                  ),
                                                                                ),
                                                                                child: Container(
                                                                                  margin: EdgeInsets.only(left: 10,right: 10),
                                                                                  child: Row(
                                                                                    children: [

                                                                                      Image.asset("assets/woman.png",height: 25,width: 25,),
                                                                                      SizedBox(width: 2,),
                                                                                      Text(
                                                                                        'View',
                                                                                        style: TextStyle(
                                                                                          color: Colors.pink,
                                                                                          fontWeight: FontWeight.bold,
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                )
                                                                            ),],
                                                                        ),
                                                                      )




                                                                    ],
                                                                  ),
                                                                );

                                                              },
                                                            );
                                                          },
                                                        ),
                                                      );

                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),),
                                        Visibility(
                                            visible: !workData['choose'] && workData['status']=="process" || workData['status']=='posted',
                                            child: Container(
                                              margin: EdgeInsets.only(top: 10),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Image.asset("assets/hourglass.png",height: 40,width: 40,),
                                                  SizedBox(width: 10,),
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [

                                                      Text('Currently no worker assigned',style: TextStyle(color: Colors.white,fontSize: 16),),
                                                      Text('for this work Please Wait!',style: TextStyle(color: Colors.white,fontSize: 16)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )),
                                        Visibility(
                                          visible: track,
                                          child: Container(
                                            margin: EdgeInsets.only(top: 10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text("Worker Assigned",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 19,
                                                      fontWeight: FontWeight.w500
                                                  ),),

                                              ],
                                            ),
                                          ),
                                        ),

                                        Visibility(
                                          visible: track,
                                          child: Container(
                                            child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                              future: FirebaseFirestore.instance.collection('prof').doc(finalwokerid).get(),
                                              builder: (context, userSnapshot) {
                                                if (userSnapshot.connectionState == ConnectionState.waiting) {
                                                  isLoading = true;

                                                  return Container(
                                                    height: 20,
                                                    width: 20,
                                                    child: CircularProgressIndicator(),
                                                  );
                                                } else if (userSnapshot.hasError) {
                                                  isLoading = false;

                                                  return Text('Error: ${userSnapshot.error}');
                                                } else if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                                                  isLoading = false;

                                                  return Text('User not found');
                                                }
                                                isLoading = false;

                                                // Access user data and display details
                                                Map<String, dynamic> userData = userSnapshot.data!.data()!;
                                                userName = userData['name'] ?? '';
                                                String mobile = userData['phone_number'] ?? "";

                                                String userRole = userData['email'] ?? '';
                                                final List<dynamic> listspecs = userData['specialities'] ?? [];

                                                // Display worker information
                                                return Container(
                                                  height: 220,
                                                  width: screenWidth,

                                                  margin: EdgeInsets.only(top: 12, bottom: 10, right: 10),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Colors.white,
                                                      width: 1.0,
                                                    ),
                                                    borderRadius: BorderRadius.circular(30.0),
                                                    color: Colors.transparent,

                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        margin: EdgeInsets.only(left: 12,right: 10,top: 12),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                ClipRRect(
                                                                  borderRadius: BorderRadius.all(Radius.circular(35)),
                                                                  child: CachedNetworkImage(
                                                                    fit: BoxFit.cover,
                                                                    imageUrl: userData['profile_image_url'], // URL of the image
                                                                    width: screenWidth*0.16, // Double the radius to fit the CircleAvatar
                                                                    height: screenWidth*0.16, // Double the radius to fit the CircleAvatar
                                                                    placeholder: (context, url) => Shimmer.fromColors(
                                                                      baseColor: Colors.grey[300]!,
                                                                      highlightColor: Colors.grey[100]!,
                                                                      child: Container(
                                                                        width: screenWidth*0.16, // Double the radius to fit the CircleAvatar
                                                                        height: screenWidth*0.16, // Double the radius to fit the CircleAvatar
                                                                        color: Colors.white,
                                                                      ),
                                                                    ),
                                                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                                                  ),

                                                                ),
                                                                SizedBox(width: 10,),
                                                                Container(
                                                                  width: screenWidth*0.315,
                                                                  child: Column(
                                                                    children: [
                                                                      Container(
                                                                        width: screenWidth*0.280,
                                                                        child: Text(
                                                                          userData['name'],
                                                                          style: TextStyle(
                                                                            color: Colors.white,
                                                                            fontWeight: FontWeight.w500,
                                                                            fontSize: screenWidth*0.05,
                                                                            overflow: TextOverflow.ellipsis, // or TextOverflow.ellipsis, etc.
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        width: screenWidth*0.315,
                                                                        child: Text(
                                                                          userData['username'],
                                                                          style: TextStyle(
                                                                            color: Colors.white,
                                                                            fontWeight: FontWeight.w500,
                                                                            fontSize: screenWidth*0.039,
                                                                            overflow: TextOverflow.ellipsis, // or TextOverflow.ellipsis, etc.
                                                                          ),
                                                                        ),
                                                                      ),

                                                                    ],
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Column(
                                                              children: [
                                                                Container(
                                                                  margin: EdgeInsets.only(left: 18,right: 10),
                                                                  child: Row(
                                                                    children: [
                                                                      Image.asset("assets/expertise.png",width: screenWidth*0.06,height: screenWidth*0.06,),
                                                                      Text("Experience",
                                                                        style: TextStyle(
                                                                            color: Colors.white.withOpacity(1),
                                                                            fontWeight: FontWeight.w500,
                                                                            fontSize: screenWidth*0.04
                                                                        ),)
                                                                    ],
                                                                  ),
                                                                ),
                                                                SizedBox(height: 7,),
                                                                Container(
                                                                  margin: EdgeInsets.only(left: 20),
                                                                  child: Text(userData['experience'],
                                                                    style: TextStyle(
                                                                        color: Colors.white,
                                                                        fontWeight: FontWeight.w600,
                                                                        fontSize: 17
                                                                    ),),
                                                                ),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(height: 10,),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Container(
                                                                margin: EdgeInsets.only(left: 15,right: 10),
                                                                child: Row(
                                                                  children: [
                                                                    Image.asset("assets/rupee.png",width: 30,height: 30,),
                                                                    Text("Amount",
                                                                      style: TextStyle(
                                                                          color: Colors.white.withOpacity(1),
                                                                          fontWeight: FontWeight.w600,
                                                                          fontSize: 15
                                                                      ),)
                                                                  ],
                                                                ),
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets.only(left: 20),
                                                                child: Text(finalworkerAmount.toString(),
                                                                  style: TextStyle(
                                                                      fontSize: 19,
                                                                      color: Colors.white
                                                                  ),),
                                                              ),


                                                              SizedBox(height: 3,),
                                                              Container(
                                                                margin: EdgeInsets.only(left: 18,right: 10),
                                                                child: Row(
                                                                  children: [
                                                                    Image.asset("assets/star.png",width: 30,height: 30,),
                                                                    Text("Ratings",
                                                                      style: TextStyle(
                                                                          color: Colors.white.withOpacity(1),
                                                                          fontWeight: FontWeight.w500,
                                                                          fontSize: 15
                                                                      ),)
                                                                  ],
                                                                ),
                                                              ),
                                                              SizedBox(height: 2,),
                                                              Container(
                                                                  margin: EdgeInsets.only(left: 20),
                                                                  child: Row(
                                                                    children: [
                                                                      Text(userData['rating']+" star",
                                                                        style: TextStyle(
                                                                            color: Colors.white,
                                                                            fontWeight: FontWeight.w600,
                                                                            fontSize: 17
                                                                        ),),
                                                                      Text("("+userData['totalrating']+")",
                                                                        style: TextStyle(
                                                                            color: Colors.white,
                                                                            fontWeight: FontWeight.w600,
                                                                            fontSize: 17
                                                                        ),),
                                                                      SizedBox(width: 10,),
                                                                      Container(

                                                                        child: StreamBuilder<QuerySnapshot>(
                                                                          stream: FirebaseFirestore.instance.collection('prof').doc(userData['id']).collection('reviews').snapshots(),
                                                                          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> playerSnapshot) {
                                                                            if (playerSnapshot.hasError) {
                                                                              return Text('Something went wrong');
                                                                            }

                                                                            if (playerSnapshot.connectionState == ConnectionState.waiting) {
                                                                              return Text("Loading");
                                                                            }

                                                                            List<DocumentSnapshot> playerDocs = playerSnapshot.data!.docs;

                                                                            int displayCount = playerDocs.length > 2 ? 2 : playerDocs.length;

                                                                            return Row(
                                                                              children: List.generate(displayCount, (index) {
                                                                                Map<String, dynamic> playerData = playerDocs[index].data() as Map<String, dynamic>;
                                                                                String userId = playerData['userId'];

                                                                                return StreamBuilder<DocumentSnapshot>(
                                                                                  stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
                                                                                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                                                                                    if (userSnapshot.hasError) {
                                                                                      isLoading = false;

                                                                                      return Text('Something went wrong');
                                                                                    }

                                                                                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                                                                                      isLoading = true;

                                                                                      return Visibility(visible: false,child: CircularProgressIndicator());
                                                                                    }
                                                                                    isLoading = false;


                                                                                    Map<String, dynamic> userData = userSnapshot.data!.data() as Map<String, dynamic>;
                                                                                    String imageUrl = userData['image'];

                                                                                    return Container(
                                                                                      width: 35.0,
                                                                                      height: 35.0,
                                                                                      decoration: BoxDecoration(
                                                                                        color: const Color(0xff7c94b6),
                                                                                        image: DecorationImage(
                                                                                          image: NetworkImage(imageUrl),
                                                                                          fit: BoxFit.cover,
                                                                                        ),
                                                                                        border: Border.all(
                                                                                          color: Colors.white,
                                                                                          width: 2.0,
                                                                                        ),
                                                                                        borderRadius: BorderRadius.all(Radius.circular(50.0)),
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                );
                                                                              }),
                                                                            );
                                                                          },
                                                                        ),
                                                                        //show here the images of users which have posted the reviews
                                                                      )
                                                                    ],
                                                                  )
                                                              ),
                                                            ],
                                                          ),
                                                          Container(
                                                            margin: EdgeInsets.only(right: 15),
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                                              children: [
                                                                OutlinedButton.icon(
                                                                  onPressed: () {
                                                                    showModalBottomSheet(
                                                                      context: context,
                                                                      isScrollControlled: true,
                                                                      builder: (BuildContext context) {
                                                                        return  Container(
                                                                          height: MediaQuery.of(context).size.height*0.42,
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
                                                                                  CircleAvatar(
                                                                                    radius: 30,
                                                                                    backgroundImage: NetworkImage(
                                                                                        userData['profile_image_url']
                                                                                    ),
                                                                                  ),
                                                                                  Text("Contact",
                                                                                    style: TextStyle(
                                                                                        color: Colors.black,
                                                                                        fontSize: 25,
                                                                                        fontWeight: FontWeight.w500
                                                                                    ),),
                                                                                  SizedBox(height: 10,),
                                                                                  GestureDetector(
                                                                                    onTap: () {
                                                                                      Navigator.push(
                                                                                        context,
                                                                                        MaterialPageRoute(builder: (context) =>   HomePage(profid: userData['id'])),
                                                                                      );
                                                                                      // Define a function to create and handle the dialog

                                                                                    },
                                                                                    child: Container(
                                                                                      padding: EdgeInsets.only(right: 20),
                                                                                      decoration: BoxDecoration(
                                                                                        borderRadius: BorderRadius.all(Radius.circular(20)),
                                                                                        color: Colors.pink.withOpacity(0.8),
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
                                                                                                    "assets/messages.png",
                                                                                                    height: 35,
                                                                                                    width: 35,
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                              SizedBox(width: 10),
                                                                                              Text(
                                                                                                "Message",
                                                                                                style: TextStyle(
                                                                                                  color: Colors.white,
                                                                                                  fontWeight: FontWeight.w400,
                                                                                                  fontSize: screenWidth * 0.05, // Adjust the font size as needed
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                          Icon(
                                                                                            Icons.arrow_forward_ios,
                                                                                            color: Colors.white,
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(height: 15,),
                                                                                  GestureDetector(
                                                                                    onTap: () {

                                                                                    },
                                                                                    child: Container(
                                                                                      padding: EdgeInsets.only(right: 20),
                                                                                      decoration: BoxDecoration(
                                                                                        borderRadius: BorderRadius.all(Radius.circular(20)),
                                                                                        color: Colors.grey.shade100,
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
                                                                                                child: Center(child: Image.asset("assets/phone.png",height: 35,width: 35,)),
                                                                                              ),
                                                                                              SizedBox(width: screenWidth*0.02,),

                                                                                              Text("Call +91 "+mobile.toString(),style:
                                                                                              TextStyle(
                                                                                                  color: Colors.black,
                                                                                                  fontWeight: FontWeight.w400,
                                                                                                  fontSize: screenWidth*0.05
                                                                                              ),),
                                                                                            ],
                                                                                          ),

                                                                                          Icon(Icons.arrow_forward_ios,color: Colors.black,)


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
                                                                    'Contact',
                                                                    style: TextStyle(
                                                                      color: Colors.pink,
                                                                      fontWeight: FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                                OutlinedButton.icon(
                                                                  onPressed: () {
                                                                    // Add onPressed action
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
                                                                    'Assigned',
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
                                                      )

                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),

                                        ),


                                        Visibility(
                                          visible: attachmentvisi,
                                          child: Container(
                                            margin: EdgeInsets.only(top: 10),
                                            child: Text("Attachments",style: TextStyle(
                                                color: Colors.white.withOpacity(1),
                                                fontSize: screenWidth*0.05,
                                                fontWeight: FontWeight.w500

                                            ),),
                                          ),
                                        ),
                                        Visibility(
                                          visible: filevisi,
                                          child: Container(
                                              child: MediaQuery.removePadding(
                                                  removeTop: true,
                                                  removeBottom: true,
                                                  context: context,
                                                  child: ListView.builder(
                                                    physics: NeverScrollableScrollPhysics(),
                                                    shrinkWrap: true,
                                                    scrollDirection: Axis.vertical,
                                                    itemCount: fileData.length,
                                                    itemBuilder: (context, index) {
                                                      Map<String, dynamic> file = fileData[index];
                                                      String fileUrl = file['url'] ?? '';
                                                      String fileType = file['type'] ?? '';

                                                      // Check the file type based on its extension
                                                      if (fileType.toLowerCase() == 'jpg' || fileType.toLowerCase() == 'jpeg' || fileType.toLowerCase() == 'png') {
                                                        // Display image using Image.network
                                                        return Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.all(Radius.circular(13)),
                                                            child: CachedNetworkImage(
                                                              fit: BoxFit.cover,
                                                              imageUrl: fileUrl, // URL of the image
                                                              width: screenWidth, // Double the radius to fit the CircleAvatar
                                                              height: screenHeight*0.22, // Double the radius to fit the CircleAvatar
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
                                                        );
                                                      } else if (fileType.toLowerCase() == 'mp3') {
                                                        // Display audio play button
                                                        return Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: ElevatedButton(
                                                            onPressed: () async {
                                                              // Implement audio playback logic
                                                              setState(() {
                                                                isLoading = true;
                                                              });

                                                              if (isPlaying) {
                                                                await player.pause();
                                                              } else {
                                                                await player.play(UrlSource(fileUrl));
                                                              }

                                                              setState(() {
                                                                isLoading = false;
                                                                isPlaying = !isPlaying;
                                                                currentAudioUrl = fileUrl;
                                                              });
                                                            },
                                                            child: isLoading
                                                                ? CircularProgressIndicator()
                                                                : Text(isPlaying ? 'Pause Audio $index' : 'Play Audio $index'),
                                                          ),
                                                        );
                                                      } else if (fileType.toLowerCase() == 'mp4') {
                                                        // Display video play button
                                                        return Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                            },
                                                            child: Text('Play Video $index'),
                                                          ),
                                                        );
                                                      } else {
                                                        // Handle other file types or show an error message
                                                        return Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: Text('Unsupported File Type'),
                                                        );
                                                      }

                                                    },
                                                  ))
                                          ),
                                        ),

                                        Visibility(
                                          visible: locationvisi,child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [Visibility(
                                            visible: locationvisi,
                                            child: Text("Work Location",style: TextStyle(
                                                color: Colors.white.withOpacity(1),
                                                fontSize: 19,
                                                fontWeight: FontWeight.w500

                                            ),),
                                          ),
                                            SizedBox(height: 10,),

                                            Visibility(
                                              visible: formto && form || form || formto,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: Container(
                                                  height: 200,
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.all(Radius.circular(20))
                                                  ),
                                                  child: GoogleMap(
                                                    zoomControlsEnabled: false,
                                                    myLocationButtonEnabled: false,
                                                    polylines: formto && form
                                                        ? Set<Polyline>.of([
                                                      Polyline(
                                                        polylineId: PolylineId('route'),
                                                        color: Colors.pink,
                                                        width: 3,
                                                        points: [
                                                          _markerLocation1,
                                                          _markerLocation,
                                                        ],
                                                        patterns: [
                                                          PatternItem.dash(30),
                                                          PatternItem.gap(20),
                                                        ],
                                                      ),
                                                    ])
                                                        : Set<Polyline>(),
                                                    initialCameraPosition: CameraPosition(
                                                      target: formto && form
                                                          ? _markerLocation
                                                          : workData['category'] == "others"
                                                          ? _markerLocation
                                                          : _markerLocation1,
                                                      zoom: 15,
                                                    ),
                                                    markers: Set<GoogleMapsMarker.Marker>.of([
                                                      GoogleMapsMarker.Marker(
                                                        markerId: MarkerId('marker_1'),
                                                        position: formto && form
                                                            ? _markerLocation
                                                            : workData['category'] == "others"
                                                            ? _markerLocation
                                                            : _markerLocation1,
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
                                            SizedBox(height: 10,),

                                            Visibility(
                                              visible: form,
                                              child: Container(
                                                margin: EdgeInsets.only(top: 15),
                                                child: Stack(
                                                  children: [
                                                    Column(
                                                      children: [
                                                        GestureDetector(

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
                                                                  width: screenWidth*0.7,
                                                                  child: Text(workData['fromaddress'],
                                                                    overflow: TextOverflow.clip,
                                                                    maxLines: 2,
                                                                    style:
                                                                    TextStyle(
                                                                        color: Colors.white,
                                                                        fontSize: 17,
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
                                              ),),
                                            SizedBox(height: 10,),

                                            Visibility(
                                              visible: formto,
                                              child: Container(
                                                child: Stack(
                                                  children: [
                                                    Column(
                                                      children: [
                                                        GestureDetector(

                                                          child: Container(
                                                            padding: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 10),
                                                            decoration: BoxDecoration(
                                                                color: Colors.white,
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
                                                                  width: screenWidth*0.7,
                                                                  child: Text(workData['toaddress'],
                                                                    overflow: TextOverflow.clip,
                                                                    maxLines: 2,
                                                                    style:
                                                                    TextStyle(
                                                                        color: Colors.pink,
                                                                        fontSize: 17,
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
                                              ),)



                                          ],
                                        ),),//work location
                                        Visibility(
                                          visible: locationtrack,
                                          child: Text("Track Location",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 19,
                                                fontWeight: FontWeight.w500
                                            ),),),
                                        Visibility(
                                          visible: locationtrack,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(20),
                                            child: Container(
                                              height: screenHeight * 0.2,
                                              width: screenWidth*0.95,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(Radius.circular(20)),
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
                                                      myLocationButtonEnabled: false,
                                                      zoomControlsEnabled: false, // Set to false to hide zoom buttons
                                                      initialCameraPosition: CameraPosition(
                                                        target: workData['category'] == "others"
                                                            ? _markerLocation
                                                            : _markerLocation1,
                                                        zoom: 15,
                                                      ),
                                                      markers: Set<GoogleMapsMarker.Marker>.of([
                                                        GoogleMapsMarker.Marker(
                                                          markerId: MarkerId('marker_1'),
                                                          position: workData['category'] == "others"
                                                              ? _markerLocation
                                                              : _markerLocation1,
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
                                        ),

                                        Visibility(
                                          visible: workData['description']!="",
                                          child: Container(
                                            margin: EdgeInsets.only(top: 10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text("Work Description",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 19,
                                                      fontWeight: FontWeight.w500
                                                  ),),

                                              ],
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: workData['description'] != "",
                                          child: Container(
                                            margin: EdgeInsets.only(top: 5),

                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    workData['description'],
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 17,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 15,),
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.all(Radius.circular(15)),
                                            color: Colors.white,


                                          ),
                                          width: screenWidth,
                                          padding: EdgeInsets.only(left: 10,top: 6,bottom: 6,right: 7),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: screenWidth*0.06,
                                                backgroundImage: NetworkImage(
                                                  false ? 'https://cdn.dribbble.com/userupload/12569823/file/original-36e7a80c78bcefa16371969c139e81ea.jpg?resize=1504x1128' : APIs.me.image,
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
                                                            fontSize: screenHeight*0.02,
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: (){
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(builder: (context) => EditProfileScreen(bookingID: widget.workid, type: 'work',)),
                                                            );
                                                          },
                                                          child: Text(
                                                            minemobile,
                                                            style: TextStyle(
                                                              color: Colors.pink,
                                                              fontWeight: FontWeight.w500,
                                                              fontSize: screenHeight*0.02,
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
                                                      width: screenWidth*0.7,
                                                      child: Text(
                                                        "Contact Number will be shared to the Worker",
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                        softWrap: true,
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: screenHeight*0.017,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Visibility(
                                          visible: !paymentdone&&track,
                                          child: ShowBillWork(platformfee: "5", gst: gst.toString(), finalworkeramount: finalworkerAmount.toString(), grandtotal: (gst+5+finalworkerAmount).toString()),
                                        ),
                                        SizedBox(height: 15,),
                                        Visibility(
                                          visible: !workData['reviewdone'] && workData['status']=="completed",

                                          child: GestureDetector(
                                            onTap: (){
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => AddReviewScreen(profId: workData['assigned'],type: "work",firebaseid: workData['id'],) ),
                                              );
                                            },
                                            child: Container(
                                              height: 70,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                  width: 1.0,
                                                ),
                                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                                color: Colors.white,
                                              ),
                                              padding: EdgeInsets.all(8),
                                              margin: EdgeInsets.only(bottom: 15),
                                              width: MediaQuery.of(context).size.width,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Image.asset("assets/star.png",height: 25,width: 25,),
                                                      SizedBox(width: 11,),
                                                      Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text("Rate "+ userName,
                                                            style: TextStyle(
                                                              fontSize: 17,
                                                              fontWeight: FontWeight.w400,
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
                                                      ),
                                                    ],
                                                  ),
                                                  Container(
                                                    alignment: Alignment.centerRight,
                                                    height: 46,
                                                    padding: EdgeInsets.only(left: 7,right: 7),
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.all(Radius.circular(15)),
                                                        border: Border.all(color: Colors.grey.shade300,width: 1)
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Text("Get 100"),
                                                        Text("Points")
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),

                                        Visibility(
                                          visible: showpaynow,
                                          child:GestureDetector(
                                            onTap: () {
                                              if(APIs.me.havepremium){
                                                platformfee =int.parse((5).toStringAsFixed(0));

                                              }
                                              else{
                                                platformfee =int.parse((5).toStringAsFixed(0));

                                              }
                                              gst = 0;
                                              workertip = 0;
                                              intValue = finalworkerAmount.toInt();


                                              int grandtotal = platformfee+gst+workertip+intValue;
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
                                                        width: screenWidth,
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
                                                                        fontSize: screenHeight*0.025
                                                                    ),),
                                                                  SizedBox(height: 8,),
                                                                  Container(
                                                                    width: screenWidth,
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
                                                                            Text("Work Amount",
                                                                              style: TextStyle(
                                                                                  color: Colors.black,
                                                                                  fontSize: screenHeight*0.021
                                                                              ),),
                                                                            Text("Rs. "+finalworkerAmount.toString(),
                                                                              style: TextStyle(
                                                                                  color: Colors.pink,
                                                                                  fontSize: screenHeight*0.021
                                                                              ),),
                                                                          ],
                                                                        ),
                                                                        CustomPaint(
                                                                          size: Size(screenWidth*0.9, 10),
                                                                          painter: DashedLinePainter(),
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text("Platform Fee",
                                                                              style: TextStyle(
                                                                                  color: Colors.black,
                                                                                  fontSize: screenHeight*0.019
                                                                              ),),
                                                                            Text("Rs. "+platformfee.toString(),
                                                                              style: TextStyle(
                                                                                  color: Colors.pink,
                                                                                  fontSize: screenHeight*0.019
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
                                                                            Text("GST",
                                                                              style: TextStyle(
                                                                                  color: Colors.black,
                                                                                  fontSize: screenHeight*0.019
                                                                              ),),
                                                                            Text("Free",
                                                                              style: TextStyle(
                                                                                  color: Colors.pink,
                                                                                  fontSize: screenHeight*0.019
                                                                              ),),
                                                                          ],
                                                                        ),

                                                                        Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text("Worker Tip",
                                                                              style: TextStyle(
                                                                                  color: Colors.black,
                                                                                  fontSize: screenHeight*0.019
                                                                              ),),
                                                                            Text("Rs. "+workertip.toString(),
                                                                              style: TextStyle(
                                                                                  color: Colors.pink,
                                                                                  fontSize: screenHeight*0.019
                                                                              ),),
                                                                          ],
                                                                        ),
                                                                        CustomPaint(
                                                                          size: Size(screenWidth*0.9, 10),
                                                                          painter: DashedLinePainter(),
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text("Total Amount",
                                                                              style: TextStyle(
                                                                                  color: Colors.black,
                                                                                  fontSize: screenHeight*0.021
                                                                              ),),
                                                                            Text("Rs. "+grandtotal.toString(),
                                                                              style: TextStyle(
                                                                                  color: Colors.pink,
                                                                                  fontSize: screenHeight*0.021
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
                                                                        fontSize: screenHeight*0.025
                                                                    ),),
                                                                  SizedBox(height: 8,),
                                                                  Container(
                                                                    width: screenWidth,
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
                                                                                width: screenWidth*0.6,
                                                                                child: Column(
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Text("Pay your worker",
                                                                                      style: TextStyle(
                                                                                          color: Colors.black,
                                                                                          fontWeight: FontWeight.w500,
                                                                                          fontSize: screenHeight*0.025
                                                                                      ),),
                                                                                    Text("Your tip means a lot! 100% of your tip will directly go to the worker",
                                                                                      style: TextStyle(
                                                                                          color: Colors.black.withOpacity(0.7),
                                                                                          fontWeight: FontWeight.w500,
                                                                                          fontSize: screenHeight*0.016
                                                                                      ),),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              Container(
                                                                                width: screenWidth*0.25-2,
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

                                                                                      grandtotal = platformfee + gst + workertip + intValue;
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

                                                                                      grandtotal = platformfee + gst + workertip + intValue;
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

                                                                                      grandtotal = platformfee + gst + workertip + intValue;
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
                                                                  //
                                                                  SizedBox(height: 10),
                                                                  GestureDetector(
                                                                    onTap: (){
                                                                      Navigator.pop(context);
                                                                      APIs.AddTiptoWork(workData['id'], grandtotal, workertip);

                                                                      _openCheckout(grandtotal.toDouble(), workertip);
                                                                    },
                                                                    child: Container(
                                                                      height: 50,
                                                                      width: screenWidth,
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
                                                                  SizedBox(height: 10),
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
                                              width: screenWidth,
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
                                            visible: paymentdone,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                                color: Colors.white,

                                              ),
                                              width: screenWidth,
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
                                                          fontSize: screenHeight*0.025
                                                      ),),
                                                    SizedBox(height: 5,),
                                                    Container(
                                                      width: screenWidth,
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
                                                              Text("Work Amount",
                                                                style: TextStyle(
                                                                    color: Colors.black,
                                                                    fontSize: screenHeight*0.021
                                                                ),),
                                                              Text("Rs. "+finalworkerAmount.toString(),
                                                                style: TextStyle(
                                                                    color: Colors.pink,
                                                                    fontSize: screenHeight*0.021
                                                                ),),
                                                            ],
                                                          ),
                                                          CustomPaint(
                                                            size: Size(screenWidth*0.9, 10),
                                                            painter: DashedLinePainter(),
                                                          ),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text("Platform Fee",
                                                                style: TextStyle(
                                                                    color: Colors.black,
                                                                    fontSize: screenHeight*0.019
                                                                ),),
                                                              Text("Rs. "+platformfeepay.toString(),
                                                                style: TextStyle(
                                                                    color: Colors.pink,
                                                                    fontSize: screenHeight*0.019
                                                                ),),
                                                            ],
                                                          ),

                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text("GST",
                                                                style: TextStyle(
                                                                    color: Colors.black,
                                                                    fontSize: screenHeight*0.019
                                                                ),),
                                                              Text("Free",
                                                                style: TextStyle(
                                                                    color: Colors.pink,
                                                                    fontSize: screenHeight*0.019
                                                                ),),
                                                            ],
                                                          ),

                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text("Worker Tip",
                                                                style: TextStyle(
                                                                    color: Colors.black,
                                                                    fontSize: screenHeight*0.019
                                                                ),),
                                                              Text("Rs. "+tippay.toString(),
                                                                style: TextStyle(
                                                                    color: Colors.pink,
                                                                    fontSize: screenHeight*0.019
                                                                ),),
                                                            ],
                                                          ),
                                                          CustomPaint(
                                                            size: Size(screenWidth*0.9, 10),
                                                            painter: DashedLinePainter(),
                                                          ),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text("Total Amount",
                                                                style: TextStyle(
                                                                    color: Colors.black,
                                                                    fontSize: screenHeight*0.021
                                                                ),),
                                                              Text("Rs. "+grandpay.toString(),
                                                                style: TextStyle(
                                                                    color: Colors.pink,
                                                                    fontSize: screenHeight*0.021
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


                                        SizedBox(height: 20,)




                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          )

                        ]
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            height: screenHeight * 0.14,
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/backappbar1.png"),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
            child: Container(
              margin: EdgeInsets.only(left: 20, right: 20, top: screenHeight*0.02),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.only(left: 10),
                              height: MediaQuery.of(context).size.height*0.06,
                              width: MediaQuery.of(context).size.height*0.06,
                              decoration: BoxDecoration(

                                  borderRadius: BorderRadius.all(Radius.circular(105))),
                              child: Center(child: Icon(Icons.arrow_back_ios,color: Colors.white,)),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${getGreeting()}!",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16
                                ),
                              ),
                              Container(
                                width: screenWidth*0.46,
                                child: Text(
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                  APIs.me.name,
                                  style: TextStyle(color: CupertinoColors.white, fontSize:  screenHeight*0.023),
                                ),
                              )
                            ],
                          ),
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
          Visibility(
              visible: isLoading ,
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
      ),
    );
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
