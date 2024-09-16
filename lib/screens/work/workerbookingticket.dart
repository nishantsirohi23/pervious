import 'dart:ui';

import 'package:barcode/barcode.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/src/types/marker.dart' as GoogleMapsMarker;

import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:perwork/chat/pages/home.dart';
import 'package:perwork/onboding/components/custom_sign_in_dialog.dart';
import 'package:perwork/screens/scanticket.dart';
import 'package:perwork/screens/tasker/requestpayment.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api/apis.dart';
import '../../try/editprofilescreen.dart';


class WorkerBookingTicket extends StatefulWidget {
  final String bookingId;
  const WorkerBookingTicket({Key? key,required this.bookingId}) : super(key: key);

  @override
  State<WorkerBookingTicket> createState() => _BookingTicketState();
}


class _BookingTicketState extends State<WorkerBookingTicket> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> workFuture;
  String profId = "";
  bool hours = false;
  bool days = false;
  bool work = false;
  bool showpayment=true;
  late Razorpay _razorpay;


  String extractTime(String fromTime) {
    // Split the string by space to separate time and AM/PM
    List<String> parts = fromTime.split(' ');

    // Get the time part, which is the first part
    String timePart = parts[0];

    return timePart;
  }
  int finalamount=0;
  bool ispayemntdone = false;




  bool showcomppleted = true;
  void getData() {
    FirebaseFirestore.instance.collection('bookings').doc(widget.bookingId).snapshots().listen((DocumentSnapshot snapshot) {
      setState(() {
        ispayemntdone = snapshot['payment'] ?? false;
        String status = snapshot['status'] ?? false;
        print(ispayemntdone);
        print(status);
        if(status=='completed'){
          setState(() {
            showcomppleted = false;
          });
        }

      });
    });
  }
  @override
  void initState() {
    super.initState();
    getData();
    // Initialize the Future to fetch the work details
    workFuture = FirebaseFirestore.instance.collection('bookings').doc(widget.bookingId).get();




  }


  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
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
                visible: showcomppleted,
                child: GestureDetector(
                  onTap: (){
                    if(ispayemntdone){
                      APIs.statusbooking(widget.bookingId, "completed");
                      MotionToast.success(
                        title:  Text("Request Success"),
                        description:  Text("Booking Completed Successfully Thanks!"),
                      ).show(context);
                    }
                    else{
                      MotionToast.error(
                        title:  Text("Request Failed"),
                        description:  Text("Please ask Customer to make payment!"),
                      ).show(context);
                    }
                  },
                  child: Text(
                    'Mark As Complete',
                    style: TextStyle(
                        color: Colors.pink.withOpacity(0.7)
                    ),
                  ),
                ))
          ],
        ),
      ),
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          Container(
            height: screenHeight*0.86,
            child: SingleChildScrollView(
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
                        String userId = workData['userId'];
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
                        String textStatus = "";

                        if(workData['type']=="hours"){
                          textStatus = workData['totalamount'].toString();
                        }
                        else{
                          textStatus = workData['workeramount'].toString();
                        }
                        bool visisent = true;
                        bool visiaccept = false;
                        bool visireject = false;
                        if(workData['status']=="sent"){
                        }
                        else if(workData['status']=="accept"){
                          visiaccept = true;
                          visisent = false;
                        }
                        else{
                          visireject = true;
                          visisent = false;
                        }




                        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
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
                            String userImage = userData['image'] ?? '';
                            String usernumber = userData['mobile']??'';
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
                                              Image.asset('assets/rupee.png',height: 42,width: 42,),
                                              Text("₹"+textStatus,style: TextStyle(color: Colors.green,fontWeight: FontWeight.w500,fontSize: 21),)
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
                                            height: screenHeight*0.13,
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
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      height: screenWidth*0.2,
                                                      width: screenWidth*0.2,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(screenWidth*0.1),
                                                        image: DecorationImage(
                                                          image: NetworkImage(userImage), // Path to your image
                                                          fit: BoxFit.cover, // Cover the entire container
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 17,),
                                                    Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
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
                                                                                      MaterialPageRoute(builder: (context) =>   HomePage(profid: userId)),
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
                                                                                    print("usernumber from worker booking");
                                                                                    print(usernumber);
                                                                                    FlutterPhoneDirectCaller.callNumber(usernumber);                                                                                  },
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

                                                                                            Text("Call +91 "+usernumber,style:
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
                                        SizedBox(height: 10,),
                                        Visibility(
                                          visible: !ispayemntdone,
                                          child: Container(

                                            height: screenHeight*0.1,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 1.0,
                                              ),
                                              borderRadius: BorderRadius.all(Radius.circular(15)),
                                              color: Colors.white,


                                            ),
                                            width: screenWidth,
                                            padding: EdgeInsets.only(left: 10,right: 10),
                                            child: Row(
                                              children: [
                                                Image.asset("assets/verify.png",height: 45,width: 45,),
                                                SizedBox(width: 10), // Added SizedBox for spacing
                                                Expanded( // Added Expanded to allow the container to take remaining space
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start, // Align text to start
                                                    mainAxisAlignment: MainAxisAlignment.center, // Vertically center text
                                                    children: [
                                                      Row( // Added Row to contain text and arrow
                                                        children: [

                                                          GestureDetector(
                                                            onTap: (){
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(builder: (context) =>   RequestPayment(type: 'booking',fid: widget.bookingId,amount: (workData['totalamount']+5).toString(),)),
                                                              );
                                                            },
                                                            child: Text(
                                                              "Request Payment",
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
                                                          "Payment Pending from the user",
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
                                          ),
                                        ),





                                        Container(
                                          padding: EdgeInsets.all(12),
                                          width: screenWidth,
                                          decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.3),
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
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.all(Radius.circular(15)),
                                            color: Colors.white,


                                          ),
                                          width: screenWidth,
                                          padding: EdgeInsets.only(left: 10,right: 7,top: 6,bottom: 6),
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
                                                        "Contact Number will be shared to the Costumer",
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
                                        ),
                                        SizedBox(height: 13,),


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

        ],
      ),
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
