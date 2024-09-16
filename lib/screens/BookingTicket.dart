import 'dart:ui';

import 'package:barcode/barcode.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/src/types/marker.dart' as GoogleMapsMarker;

import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:perwork/chat/pages/home.dart';
import 'package:perwork/onboding/components/custom_sign_in_dialog.dart';
import 'package:perwork/screens/scanticket.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/apis.dart';
import '../try/editprofilescreen.dart';
import '../widgets/showbillwork.dart';
import 'addreview.dart';

class BookingTicket extends StatefulWidget {
  final String bookingId;
  const BookingTicket({Key? key,required this.bookingId}) : super(key: key);

  @override
  State<BookingTicket> createState() => _BookingTicketState();
}


class _BookingTicketState extends State<BookingTicket> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> workFuture;
  String profId = "";
  bool hours = false;
  bool days = false;
  bool work = false;
  bool showpayment=true;
  bool ten = false;
  bool twenty = false;
  bool thirty = false;
  late Razorpay _razorpay;
  Future<void> refreshPaymentDate() async {

    try {
      workFuture = FirebaseFirestore.instance.collection('bookings').doc(widget.bookingId).get();
      final DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance
          .collection('work')
          .doc(widget.bookingId)
          .get();
      print("hey called ");

      if (profileSnapshot.exists) {
        setState(() {

          showpayment = false;

        });
      }

      setState(() {
        workFuture = FirebaseFirestore.instance.collection('bookings').doc(widget.bookingId).get();
        showpayment = false;




      });
    } catch (e) {
      print('Error fetching data: $e');
      // Handle error if necessary
    } finally {
      setState(() {
        workFuture = FirebaseFirestore.instance.collection('bookings').doc(widget.bookingId).get();
        showpayment = false;
      });
    }
  }


  String extractTime(String fromTime) {
    // Split the string by space to separate time and AM/PM
    List<String> parts = fromTime.split(' ');

    // Get the time part, which is the first part
    String timePart = parts[0];

    return timePart;
  }
  int finalamount=0;
  int platformfee = 0;
  int workertip = 0;
  int gst = 0;
  int grandtotal = 0;
  bool eidtvisi = true;
  void fetchamount()async{
    final DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance.collection('bookings').doc(widget.bookingId).get();
    if(profileSnapshot['status']=="completed"){
      eidtvisi = false;
    }

    if(profileSnapshot['payment']==true ){
      showpayment = false;
    }
    if (profileSnapshot['totalamount']==-1){
      showpayment = false;
    }
    if (profileSnapshot.exists) {
      finalamount = profileSnapshot['totalamount'];

      int intValue = finalamount.toInt();
      platformfee = (5).toInt();
      grandtotal = gst+workertip+platformfee;

    }
    setState(() {
      finalamount = profileSnapshot['totalamount'];
      int intValue = finalamount.toInt();
      platformfee = (5).toInt();
      if(profileSnapshot['payment']){
        workertip = profileSnapshot['tip'];
      }
      grandtotal = gst+workertip+platformfee+finalamount;
    });
  }






  @override
  void initState() {
    super.initState();
    fetchamount();
    // Initialize the Future to fetch the work details
    workFuture = FirebaseFirestore.instance.collection('bookings').doc(widget.bookingId).get();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);


  }
  bool _isPaymentInProgress = false;

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print(response.orderId);
    print(response.paymentId);
    print(response.signature);
    setState(() {
      _isPaymentInProgress = false; // Payment completed, so set the flag to false
    });
    APIs.makeBookingPayment(widget.bookingId, response.paymentId.toString());
    refreshPaymentDate();
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
                          MaterialPageRoute(builder: (context) => BookingTicket(bookingId: widget.bookingId)),
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

    // Show the dialog

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
                              BookingTicket(bookingId: widget.bookingId)),
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

  void _openCheckout(int amount) {
    var options = {
      'key': 'rzp_live_ymUGpkKEgzMtUI',
      'amount': amount * 100, // amount in the smallest currency sub-unit
      'name': 'PerPenny',
      'description': "",
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
  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final double appBarHeight = AppBar().preferredSize.height;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Visibility(
                visible: eidtvisi,
                child: Text(
                  'Edit Booking',
                  style: TextStyle(
                      color: Colors.pink.withOpacity(0.7)
                  ),
                ),)
            ],
          ),
        ),
        backgroundColor: Colors.grey.shade100,
        body: Container(
          height: screenHeight,
          child: Stack(
            children: [
              Container
                (
                height: showpayment ? screenHeight - 86-appBarHeight: screenHeight,              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  margin: EdgeInsets.only(top: 15, bottom: 15),
                  child: Column(
                    children: [
                      FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        future: workFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData || !snapshot.data!.exists) {
                            return Text('Work not found');
                          }

                          // Work details
                          Map<String, dynamic> workData = snapshot.data!.data()!;
                          String workerId = workData['workerId'];
                          profId = workData['workerId'];
                          DateTime fromworkDate = workData['fromDate'].toDate();
                          DateTime toworkDate = workData['toDate'].toDate();
                          String formattedDate = DateFormat('E, dd MMM yyyy').format(fromworkDate);

// Format the dates as desired (dd/mm/yyyy)
                          String fromformattedDate = DateFormat('dd/MM/yyyy').format(fromworkDate);
                          String fromformattedTime = DateFormat('HH:mm').format(fromworkDate); // 24-hour format
                          String toformattedDate = DateFormat('dd/MM/yyyy').format(toworkDate);
                          String toformattedTime = DateFormat('HH:mm').format(toworkDate);
                          double workamount = 0.0;
                          if (workData['type']=='hours'){
                            hours = true;


                          }
                          else if (workData['type']=='days'){
                            days = true;
                          }
                          else{
                            if (workData['totalamount']==-1){
                              showpayment = false;
                            }

                            work = true;
                          }
                          String fromTime = workData['fromTime'];
                          String toTime = workData['toTime'];
                          String fromtimeOnly = extractTime(fromTime);
                          String totimeOnly = extractTime(toTime);
                          String textStatus = 'CONFIRMED';
                          bool visisent = true;
                          bool visiaccept = false;
                          bool visireject = false;
                          if(workData['status']=="sent"){
                            textStatus = "WAITING";
                          }
                          else if(workData['status']=="accept"){
                            textStatus = "CONFIRMED";
                            visiaccept = true;
                            visisent = false;
                          }
                          else if(workData['status']=='decline'){
                            visireject = true;
                            visisent = false;
                            textStatus = "DECLINED";
                          }
                          else{
                            textStatus = "COMPLETED";

                          }




                          return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                            future: FirebaseFirestore.instance.collection('prof').doc(workerId).get(),
                            builder: (context, userSnapshot) {
                              if (userSnapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (userSnapshot.hasError) {
                                return Text('Error: ${userSnapshot.error}');
                              } else if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                                return Text('User not found');
                              }

                              // User details
                              Map<String, dynamic> userData = userSnapshot.data!.data()!;
                              String userName = userData['name'] ?? '';
                              String usermobile = userData['phone_number'] ?? "";
                              String userImage = userData['profile_image_url'] ?? '';
                              String rating = userData['rating'] ?? '';
                              String totalrating = userData['totalrating'] ?? '';
                              double price_per_hour = userData['price_per_hour'] ?? '';
                              double ratingValue = double.tryParse(rating) ?? 0.0;
                              List<String> words = APIs.me.name.split(' ');
                              String minemobile = "";
                              if(APIs.me.mobile==""){
                                minemobile = "Add Contact";
                              }
                              else{
                                minemobile = APIs.me.mobile;
                              }



                              // Add more user details as needed

                              return Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [


                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Container(
                                          height: screenHeight*0.1,
                                          width: screenWidth*0.6,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              bottomRight: Radius.circular(12),
                                              topRight: Radius.circular(12),
                                            ),


                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                height: screenHeight*0.12,
                                                width: screenWidth*0.025,
                                                color: Colors.pink.withOpacity(0.7),
                                              ),
                                              SizedBox(width: screenWidth*0.02,),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(formattedDate,
                                                    style: TextStyle(
                                                        fontSize: screenWidth*0.056,
                                                        fontWeight: FontWeight.w700
                                                    ),),
                                                  Row(
                                                    children: [
                                                      Text(fromtimeOnly,
                                                        style: TextStyle(
                                                            fontSize: screenWidth*0.047,
                                                            color: Colors.black.withOpacity(0.4),
                                                            fontWeight: FontWeight.w500
                                                        ),),
                                                      Visibility(
                                                          visible: !work,
                                                          child: Row(
                                                            children: [
                                                              Text(" - ",
                                                                style: TextStyle(
                                                                    fontSize: screenWidth*0.047,
                                                                    color: Colors.black.withOpacity(0.4),
                                                                    fontWeight: FontWeight.w500
                                                                ),),
                                                              Text(totimeOnly,
                                                                style: TextStyle(
                                                                    fontSize: screenWidth*0.047,
                                                                    color: Colors.black.withOpacity(0.4),
                                                                    fontWeight: FontWeight.w500
                                                                ),),
                                                            ],
                                                          ))
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          height: screenHeight*0.12,
                                          width: screenWidth*0.3,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(12)),
                                              color: Colors.white
                                          ),
                                          child: Center(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Image.asset('assets/verify.png',height: 50,width: 50,),
                                                Text(textStatus,style: TextStyle(color: Colors.green),)
                                              ],
                                            ),
                                          ),
                                        )


                                      ],
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 15,right: 15,top: 12,bottom: 12),
                                      width: screenWidth,
                                      child: Column(
                                        children: [
                                          Container(
                                              height: screenHeight*0.16,
                                              padding: EdgeInsets.only(right: 10),
                                              width: screenWidth,
                                              decoration: BoxDecoration(
                                                  color: Colors.yellow.shade100.withOpacity(0.3),
                                                  borderRadius: BorderRadius.only(topRight: Radius.circular(12),topLeft: Radius.circular(12))
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                                        child: CachedNetworkImage(
                                                          fit: BoxFit.cover,
                                                          imageUrl: userImage, // URL of the image
                                                          width: screenWidth*0.21, // Double the radius to fit the CircleAvatar
                                                          height: screenHeight*0.12, // Double the radius to fit the CircleAvatar
                                                          placeholder: (context, url) => Shimmer.fromColors(
                                                            baseColor: Colors.grey[300]!,
                                                            highlightColor: Colors.grey[100]!,
                                                            child: Container(
                                                              width: screenWidth*0.21, // Double the radius to fit the CircleAvatar
                                                              height: screenHeight*0.12, // Double the radius to fit the CircleAvatar
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                          errorWidget: (context, url, error) => Icon(Icons.error),
                                                        ),
                                                      ),

                                                      Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            userName,
                                                            style: TextStyle(
                                                              color: Colors.black,
                                                              fontWeight: FontWeight.w500,
                                                              fontSize: 21,
                                                            ),
                                                          ),
                                                          Row(
                                                            children: [
                                                              // Dynamically generate stars based on rating
                                                              for (int i = 0; i < ratingValue; i++)
                                                                Image.asset(
                                                                  "assets/star2.png",
                                                                  height: 25,
                                                                  width: 25,
                                                                ),
                                                              for (int i = 0; i < 5 - ratingValue; i++)
                                                                Image.asset(
                                                                  "assets/emptystar.png", // Assuming this is your empty star image
                                                                  height: 25,
                                                                  width: 25,
                                                                ),
                                                              SizedBox(width: 7,),
                                                              Text(rating.toString(), style: TextStyle(color: Colors.black.withOpacity(0.8), fontSize: 19)),
                                                              Text("/5", style: TextStyle(color: Colors.black.withOpacity(0.8), fontSize: 19)),
                                                              Text("($totalrating)", style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 19)),
                                                            ],
                                                          ),
                                                          SizedBox(height: 2,),

                                                          Container(
                                                            height: 60,
                                                            color: Colors.transparent,
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
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
                                                                                        userImage
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
                                                                                        MaterialPageRoute(builder: (context) =>   HomePage(profid: workerId)),
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

                                                                                              Text("Call +91 "+usermobile,style:
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
                                                                    Icons.contact_mail,
                                                                    color: Colors.pink,
                                                                  ),
                                                                  label: Text(
                                                                    'Contact',
                                                                    style: TextStyle(
                                                                      color: Colors.pink,
                                                                      fontWeight: FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),

                                                ],
                                              )
                                          ),





                                          Container(
                                            padding: EdgeInsets.all(12),
                                            width: screenWidth,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(bottomRight: Radius.circular(12),bottomLeft: Radius.circular(12))
                                            ),
                                            child: Column(

                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [

                                                Text("Location",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.w400,
                                                      fontSize: screenWidth*0.05
                                                  ),),
                                                SizedBox(height: 2,),
                                                Text(workData['address'],
                                                  style: TextStyle(color: Colors.black.withOpacity(0.5),fontSize: screenWidth*0.04),),
                                                SizedBox(height: 7,),

                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(20),
                                                  child: Container(
                                                    height: screenHeight*0.17,
                                                    width: screenWidth,
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.all(Radius.circular(30))
                                                    ),
                                                    child: GoogleMap(
                                                      initialCameraPosition: CameraPosition(
                                                        target: LatLng(double.parse(workData['lat']),double.parse(workData['long'])),
                                                        zoom: 15,
                                                      ),
                                                      markers: Set<GoogleMapsMarker.Marker>.of([
                                                        GoogleMapsMarker.Marker(
                                                          markerId: MarkerId('marker_1'),
                                                          position: LatLng(double.parse(workData['lat']),double.parse(workData['long'])),
                                                          infoWindow: InfoWindow(
                                                            title: 'Address',
                                                            snippet: workData['address'],
                                                          ),
                                                        ),
                                                      ]),
                                                    ),
                                                  ),
                                                ),



                                                SizedBox(height: 7,),
                                                Visibility(
                                                  visible: work,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text("Work Details",
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight: FontWeight.w400,
                                                            fontSize: screenWidth*0.05
                                                        ),),
                                                      SizedBox(height: 3,),

                                                      Text(workData['work'],
                                                        style: TextStyle(color: Colors.black.withOpacity(0.5),fontSize: 17),),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 7,),



                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 10,),
                                          Visibility(
                                            visible: eidtvisi,
                                            child: Container(
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
                                                    radius: 24,
                                                    backgroundImage: NetworkImage(
                                                      false ? 'https://cdn.dribbble.com/userupload/12569823/file/original-36e7a80c78bcefa16371969c139e81ea.jpg?resize=1504x1128' : APIs.me.image,
                                                    ),
                                                  ),
                                                  SizedBox(width: 10), // Added SizedBox for spacing
                                                  Expanded( // Added Expanded to allow the container to take remaining space
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
                                                                fontSize: 19,
                                                              ),
                                                            ),
                                                            GestureDetector(
                                                              onTap: (){
                                                                Navigator.pushReplacement(
                                                                  context,
                                                                  MaterialPageRoute(builder: (context) => EditProfileScreen(bookingID: widget.bookingId, type: 'booking',)),
                                                                );
                                                              },
                                                              child: Text(
                                                                minemobile,
                                                                style: TextStyle(
                                                                  color: Colors.pink,
                                                                  fontWeight: FontWeight.w500,
                                                                  fontSize: 18,
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
                                                          child: Text(
                                                            "Contact Number will be shared to the Worker",
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                            softWrap: true,
                                                            style: TextStyle(
                                                              color: Colors.black,
                                                              fontWeight: FontWeight.w400,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),),
                                          Visibility(
                                            visible: !workData['reviewdone'] && workData['status']=="completed",

                                            child: GestureDetector(
                                              onTap: (){
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => AddReviewScreen(profId: workData['workerId'],type: "booking",firebaseid: workData['id'],) ),
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
                                                margin: EdgeInsets.only(bottom: 10),
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
                                          SizedBox(height: showpayment?15:10,),
                                          Visibility(
                                            visible: !workData['payment']&&workData['status']=="accept",
                                            child: ShowBillWork(platformfee: "5", gst: gst.toString(), finalworkeramount: finalamount.toString(), grandtotal: (gst+5+finalamount).toString()),
                                          ),

                                          Visibility(
                                              visible: workData['payment'],
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
                                                                Text("Rs. "+finalamount.toString(),
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

                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Text("GST",
                                                                  style: TextStyle(
                                                                      color: Colors.black,
                                                                      fontSize: screenHeight*0.019
                                                                  ),),
                                                                Text("Rs. "+gst.toString(),
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



                                                    ],
                                                  ),
                                                ),
                                              )
                                          ),



                                        ],
                                      ),
                                    )



                                  ],
                                ),
                              );
                            },
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
              ),
              Visibility(
                  visible: showpayment,
                  child: Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 82,
                      child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("assets/backofwork.png"),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30)),
                            ),
                            child: Container(
                              margin: EdgeInsets.only(left: 20, right: 20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Amount",
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 19),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            grandtotal.toString(),
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 21),
                                          ),
                                          GestureDetector(
                                            onTap: (){
                                              if(APIs.me.havepremium){
                                                platformfee =int.parse((5).toStringAsFixed(0));

                                              }
                                              else{
                                                platformfee =int.parse((5).toStringAsFixed(0));

                                              }
                                              gst = 0;
                                              workertip = 0;
                                              int intValue = finalamount.toInt();


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
                                                            mainAxisAlignment: MainAxisAlignment.start,
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
                                                                mainAxisAlignment: MainAxisAlignment.start,
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
                                                                            Text("Rs. "+finalamount.toString(),
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
                                                                            Text("Rs. "+gst.toString(),
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
                                                                      APIs.AddTiptoBooking(widget.bookingId, grandtotal, workertip);
                                                                      _openCheckout(grandtotal);
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
                                            child: Icon(Icons.keyboard_arrow_up),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _openCheckout(grandtotal);

                                    },
                                    child: Container(
                                      padding: EdgeInsets.only(left: 21, right: 21),
                                      height: screenHeight*0.057,
                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(30))),
                                      child: Center(
                                        child: Text(
                                          "Pay Now",
                                          style: TextStyle(color: Colors.pink, fontSize: 21, fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                            ,
                          )),
                    ),
                  ))
            ],
          ),
        )
    );
  }

}
Future<void> _makePhoneCall(String phoneNumber) async {
  final Uri launchUri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );
  await launchUrl(launchUri);
}
Future<String?> generateBarcode(String ticketId) async {
  final dm = Barcode.code128();
  return dm.toSvg(ticketId, width: 400, height: 200);
}
class QRCodeWidget extends StatelessWidget {
  final String data;

  const QRCodeWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: screenHeight * 0.22,
      gapless: false,
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
