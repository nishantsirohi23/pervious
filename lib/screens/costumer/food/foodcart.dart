import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:io';

import '../../../api/apis.dart';
import '../../../models/dishcart.dart';
import '../../../try/pigeon.dart';
import '../../../utils/LocationService.dart';
import '../SuccessScreen.dart';
import '../pickmultilocation.dart';
import '../restrauntscreen.dart';
import '../showmywork.dart';
import 'package:http/http.dart' as http;


class FoodCartScreen extends StatefulWidget {
  final String restId;
  const FoodCartScreen({Key? key,required this.restId}) : super(key: key);

  @override
  State<FoodCartScreen> createState() => _FoodCartScreenState();
}


class _FoodCartScreenState extends State<FoodCartScreen> {
  double _fromlatitude = 0.0;
  double _fromlongitude = 0.0;
  String apiKey = "";
  int totalAmount = 0;
  int restamount = 0;
  double _latitude = 0.0;
  double _longitude = 0.0;
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

  String _receivedfrom = "Pick Delivery Location";
  String _receivedto = "Pick To Location";
  double hline = 50.0;
  var sdrivingDuration = "";
  int orderamount = 0;
  double restlat = 0.0;
  double restlong = 0.0;
  double drivingDistance = 0.0;
  String sdrivingDistance = "0.0";
  int platformFee = 5;
  int gst = 0;
  int deliveryFee = 0;
  String _receivedText = 'Pick Delivery Location';
  String restImage = "";
  String restSpecs = "";
  String restname = "";
  String restAddress = "";
  String receivedFrom = "";
  String restreview = "";
  String resttime = "";
  int _restFee = 0;
  int workertip = 0;
  int tippay = 0;
  bool ten = false;
  bool twenty = false;
  bool thirty = false;
  bool isloading = true;
  void getRestrauntDetails() async{
    final CollectionReference workCollection = FirebaseFirestore.instance
        .collection('stores');
    DocumentSnapshot workSnapshot = await workCollection.doc(widget.restId).get();
    setState(() {
      restlat = workSnapshot['latitude'];
      restlong = workSnapshot['longitude'];
      restImage = workSnapshot['imageUrl'];
      restSpecs = workSnapshot['name'];
      restname = workSnapshot['name'];
      restreview = workSnapshot['name'];
      resttime = workSnapshot['name'];
      restAddress =  workSnapshot['address'];
    });


  }
  Map<String, Dish> dishes = {};

  List<dynamic> dishesList = [];
  late Razorpay _razorpay;
  bool _isPaymentInProgress = false;

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print(response.orderId);
    print(response.paymentId);
    print(response.signature);
    setState(() {

      _isPaymentInProgress = false; // Payment completed, so set the flag to false
    });
    placeorder(true,"now");

    //APIs.makePayment(widget.workid, response.paymentId.toString());
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>   SuccessScreen()),
    );
    // Show the dialog

  }


  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    print(response);
    setState(() {
      isloading = false;
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

  void _openCheckout(double amount) {
    setState(() {
      isloading = true;
    });
    var options = {
      'key': 'rzp_live_ymUGpkKEgzMtUI',
      'amount': amount * 100, // amount in the smallest currency sub-unit
      'name': 'PerPenny',
      'description': 'Fine T-Shirt',
      'prefill': {
        'contact': '123',
        'email': APIs.me.email
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
  Future<void> _fetchRestFee() async {
    try {
      DocumentSnapshot document = await FirebaseFirestore.instance
          .collection('values') // Replace with your collection name
          .doc('values') // Replace with your document ID
          .get();

      if (document.exists) {
        setState(() {
          apiKey = document.get('api');
          _restFee = document.get('restfee'); // Replace with your field name
          isloading = false;
          print("Rest fee");
          print(_restFee);
        });
      } else {
        setState(() {
          isloading = false;
        });
      }
    } catch (e) {
      setState(() {
        isloading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchRestFee();
    _getCurrentLocation();
    getRestrauntDetails();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _locationService = LocationService();
    isloading = false;

  }
  void placeorder(bool payment, String paymentmode,) async{
    setState(() {
      isloading = true;
    });
    try {
      int totalItem =  0;
      dishes.forEach((_, dish) {
        totalItem += dish.quantity;
      });

      // Prepare the order data
      Map<String, dynamic> orderData = {
        'status': "preparing",
        'totalQuantity': totalItem,
        'orderBy': APIs.me.id,
        'reviewdone': false,
        'restaddress': restAddress,
        'restname': restname,
        'deliveryaddress': _receivedText,
        'destlong': _fromlongitude,
        'destlat': _fromlatitude,
        'sourcelong': restlong,
        'sourcelat': restlat,
        'restamount': restamount,
        'picked': false,
        'createdAt': DateTime
            .now()
            .millisecondsSinceEpoch
            .toString(),
        'orderPlacedAt': DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day, DateTime.now().hour, DateTime.now().minute),
        'restimage': restImage,
        'restID': widget.restId,
        'distance': drivingDistance,
        'paymentMode': paymentmode,
        'payment': payment,
        'totalamount': totalAmount,
        'orderamount': orderamount,
        'tip': workertip,
        'deliveryFee': deliveryFee,
        'dishes': dishesList,
      };

      // Add the order to Firestore and get the document ID
      DocumentReference docRef = await FirebaseFirestore.instance.collection("orders").add(orderData);
      String orderId = docRef.id;

      // Update the order data with the document ID
      orderData['id'] = orderId;
      APIs.addfoodtotracks(orderId, restImage,restname);

      // Update the order in Firestore with the document ID
      await docRef.set(orderData);

      // Delete the cart document
      await FirebaseFirestore.instance.collection("users").doc(APIs.me.id).collection('foodcart').doc(widget.restId).delete();

      // Navigate to success screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SuccessScreen()),
      );

      // Send notification
      APIs.sendnotificationtowork("Food Order","delivery");
    } catch (e) {
      print('Failed to place order: $e');
    }
  }
  Future<void> fetchDistance(String sourcelat,String sourcelong,String destlat,String destlong) async {

    print("source");
    print(sourcelat);
    print(sourcelong);
    print(destlat);
    print(destlong);
    final origins = '$sourcelat,$sourcelong';
    final destinations = '$destlat,$destlong';


    final url = Uri.parse('https://maps.googleapis.com/maps/api/distancematrix/json'
        '?origins=$origins'
        '&destinations=$destinations'
        '&mode=driving' // Specify travel mode
        '&key=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final distanceInMeters = data['rows'][0]['elements'][0]['distance']['value'];
      // Convert distance from meters to kilometers and format to display with one decimal point
      drivingDistance = distanceInMeters / 1000.0;
      print(drivingDistance);
      if (drivingDistance > 3) {
        setState(() {
          deliveryFee = (drivingDistance*_restFee).toInt();
          orderamount = totalAmount + deliveryFee + platformFee;
        });
      } else {
        setState(() {
          deliveryFee = 30;
          orderamount = totalAmount + deliveryFee + platformFee;
        });
      }

      isloading =false;
    } else {
      throw Exception('Failed to fetch driving distance');
    }
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Food Cart'),
      ),
      body: Stack(
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection("users").doc(APIs.me.id).collection('foodcart').doc(widget.restId).collection('dishes').doc('dishes').snapshots(),
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (!snapshot.hasData || !snapshot.data!.exists) {
                return Center(
                  child: Text('No items in the cart'),
                );
              } else {
                // Extract dishes data from snapshot
                Map<String, dynamic>? data = snapshot.data!.data() as Map<String, dynamic>?;

                dishesList = data?['dishes'] ?? [];


                // Calculate total amount
                totalAmount = 0;
                dishesList.forEach((dish) {
                  totalAmount += (dish['quantity'] as int) * (dish['price'] as int);
                });
                restamount = 0;
                dishesList.forEach((dish) {
                  restamount += (dish['quantity'] as int) * (dish['restprice'] as int);
                });


                // Build list view of cart items
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: (){Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) =>   RestrauntScreen(id: widget.restId

                        )),
                      );},
                      child: Container(
                        height: 100,
                        width: screenWidth,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(20))
                        ),
                        margin: EdgeInsets.only(left: 15,right: 15),
                        padding: EdgeInsets.all(7),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: screenWidth*0.73,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(restname,
                                      maxLines: 1,
                                      overflow: TextOverflow.clip,
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 24
                                      ),),
                                    ClipRect(
                                      clipBehavior: Clip.hardEdge,
                                      child: Row(
                                        children: [

                                          Expanded(
                                            child: Text(
                                              restAddress,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: 2),
                                    Expanded(
                                      child: Text(
                                        restSpecs,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.black.withOpacity(0.7),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400
                                        ),
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.all(Radius.circular(35)),
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: restImage, // URL of the image
                                  width: 55, // Double the radius to fit the CircleAvatar
                                  height: 55, // Double the radius to fit the CircleAvatar
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


                            ]
                        ),
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
                                      _fromlatitude =  double.parse(selectedLatLng!.latitude.toStringAsFixed(6));
                                      _fromlongitude =  double.parse(selectedLatLng!.longitude.toStringAsFixed(6));
                                      _receivedfrom = selectedFromPlace!.formattedAddress.toString();
                                      _receivedText = _receivedfrom;
                                      isloading  = true;

                                    });
                                    print(restlat.toString());
                                    print(restlong.toString());
                                    print(_fromlatitude.toString());
                                    print(_fromlongitude.toString());
                                    fetchDistance(restlat.toString(),restlong.toString() , _fromlatitude.toString(),_fromlongitude.toString());



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
                        margin: EdgeInsets.only(left: 15,right: 15),
                        padding: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 10),
                        decoration: BoxDecoration(
                            color: Colors.pink.withOpacity(0.95),
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
                    SizedBox(height: 10,),

                    Expanded(
                      child: ListView.builder(
                        itemCount: dishesList.length,
                        itemBuilder: (context, index) {
                          // Extract dish details
                          String id = dishesList[index]['id'];
                          String name = dishesList[index]['name'];
                          String image = dishesList[index]['image'];
                          int price = dishesList[index]['price'];
                          int restprice = dishesList[index]['restprice'];
                          int quantity = dishesList[index]['quantity'];
                          dishes[id] = Dish(id: id, name: name, image: image, price: price, quantity: quantity,restprice: restprice);

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
                                          imageUrl: image,
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
                                                name,
                                                maxLines: 2, // Allow max 2 lines before ellipsis
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 17,
                                                ),
                                              ),
                                              Text(
                                                "₹ " + price.toString(),
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 17,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      fetchDistance(restlat.toString(),restlong.toString() , _fromlatitude.toString(),_fromlongitude.toString());

                                                      updateQuantity(id, quantity +1 , 'add');
                                                    },
                                                    child: Image.asset("assets/plus.png", height: 26, width: 26,),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(quantity.toString(), style: TextStyle(fontSize: 19),),
                                                  SizedBox(width: 8),
                                                  GestureDetector(
                                                    onTap: () {
                                                      updateQuantity(id, quantity - 1, "minus");
                                                    },
                                                    child: Image.asset("assets/minus.png", height: 26, width: 26,),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                            ),
                          );
                        },
                      ),
                    ),

                    Container (
                      height: MediaQuery.of(context).size.height*0.085,
                      child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                          child: Container(
                            height: 250,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("assets/backofwork.png"),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30)),
                            ),
                            child: Container(
                              margin: EdgeInsets.only(left: 30, right: 20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Stack(children: [
                                    Visibility(
                                        visible: !(_receivedText=="Pick Delivery Location"),
                                        child: Column(
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
                                                  orderamount.toString(),
                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 21),
                                                ),
                                                GestureDetector(
                                                  onTap: (){

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
                                                              padding: EdgeInsets.only(left: 20,right: 5,top: 10,bottom: 20),
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
                                                                                  Text("Order Amount",
                                                                                    style: TextStyle(
                                                                                        color: Colors.black,
                                                                                        fontSize: screenHeight*0.021
                                                                                    ),),
                                                                                  Text("Rs. "+totalAmount.toString(),
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
                                                                                  Text("Rs. "+platformFee.toString(),
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
                                                                                  Text("Delivery",
                                                                                    style: TextStyle(
                                                                                        color: Colors.black,
                                                                                        fontSize: screenHeight*0.019
                                                                                    ),),
                                                                                  Text("Rs. "+deliveryFee.toString(),
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
                                                                                  Text("Rs. "+orderamount.toString(),
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

                                                                                            orderamount = (deliveryFee + gst + workertip + totalAmount).toInt();
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

                                                                                            orderamount = (deliveryFee + gst + workertip + totalAmount).toInt();
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

                                                                                            orderamount = (deliveryFee + gst + workertip + totalAmount).toInt();
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
                                                                          onTap: () {
                                                                            showModalBottomSheet(
                                                                              context: context,
                                                                              isScrollControlled: true,
                                                                              builder: (BuildContext context) {
                                                                                return StatefulBuilder(
                                                                                  builder: (BuildContext context, StateSetter setState) {
                                                                                    return Container(
                                                                                      height: MediaQuery.of(context).size.height*0.3,
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

                                                                                              SizedBox(height: 10,),
                                                                                              GestureDetector(
                                                                                                onTap: () {
                                                                                                  Navigator.pop(context);
                                                                                                  _openCheckout(orderamount.toDouble());
                                                                                                  // Define a function to create and handle the dialog
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
                                                                                                                "assets/payment.png",
                                                                                                                height: 35,
                                                                                                                width: 35,
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                          SizedBox(width: 10),
                                                                                                          Text(
                                                                                                            "Pay Now",
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
                                                                                                  Navigator.pop(context);

                                                                                                  placeorder(false,"cod");
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
                                                                                                            child: Center(child: Image.asset("assets/cod.png",height: 35,width: 35,)),
                                                                                                          ),
                                                                                                          SizedBox(width: screenWidth*0.02,),

                                                                                                          Text("Cash on Delivery",style:
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
                                                                              child: Text('Order Now',
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
                                                  child: Icon(Icons.keyboard_arrow_up,color: Colors.white,),
                                                )
                                              ],
                                            )
                                          ],
                                        )),
                                    Visibility(
                                        visible: (_receivedText=="Pick Delivery Location"),
                                        child: Column(
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
                                                  totalAmount.toString()+" + Fees",
                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 21),
                                                ),

                                              ],
                                            )
                                          ],
                                        )),
                                  ],),


                                  GestureDetector(
                                    onTap: () {
                                      if(_receivedText=="Pick Delivery Location"){
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Pick Delivery Location'),
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
                                                  height: MediaQuery.of(context).size.height*0.3,
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

                                                          SizedBox(height: 10,),
                                                          GestureDetector(
                                                            onTap: () {
                                                              // Define a function to create and handle the dialog
                                                              //placeorder();
                                                              Navigator.pop(context);

                                                              _openCheckout(orderamount.toDouble());

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
                                                                            "assets/payment.png",
                                                                            height: 35,
                                                                            width: 35,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(width: 10),
                                                                      Text(
                                                                        "Pay Now",
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

                                                              Navigator.pop(context);

                                                              placeorder(false,"cod");

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
                                                                        child: Center(child: Image.asset("assets/cod.png",height: 35,width: 35,)),
                                                                      ),
                                                                      SizedBox(width: screenWidth*0.02,),

                                                                      Text("Cash on Delivery",style:
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
                                    },
                                    child: Container(
                                      padding: EdgeInsets.only(left: 21, right: 21),
                                      height: screenHeight*0.057,
                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(30))),
                                      child: Center(
                                        child: Text(
                                          "Order Now",
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

                  ],
                );
              }
            },
          ),
          Visibility(
              visible: isloading,
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

  Future<void> updateQuantity(String id, int newQuantity,String opr) async {
    // Reference to the dish document
    DocumentReference dishRef = FirebaseFirestore.instance.collection('users').doc(APIs.me.id).collection('foodcart').doc(widget.restId).collection('dishes').doc('dishes');
    final CollectionReference collectionReference1 = FirebaseFirestore.instance.collection('users').doc(APIs.me.id).collection('foodcart');

// Increment the value of the existing field by one
    if(opr=="plus"){
      collectionReference1.doc(widget.restId).update({
        "total": FieldValue.increment(1), // Replace 'fieldName' with the name of your existing field
      }).then((value) {
        print("Field value incremented successfully!");
      }).catchError((error) {
        print("Failed to increment field value: $error");
      });
    }
    else{
      collectionReference1.doc(widget.restId).update({
        "total": FieldValue.increment(-1), // Replace 'fieldName' with the name of your existing field
      }).then((value) {
        print("Field value incremented successfully!");
      }).catchError((error) {
        print("Failed to increment field value: $error");
      });
    }

    // Run a transaction to update the quantity
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(dishRef);

      if (!snapshot.exists) {
        throw Exception("Dish document does not exist!");
      }

      // Extract dishes data from snapshot
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

      List<dynamic> dishesList = data?['dishes'] ?? [];

      // Find the dish with the given id
      for (int i = 0; i < dishesList.length; i++) {
        if (dishesList[i]['id'] == id) {
          // Update the quantity
          dishesList[i]['quantity'] = newQuantity;

          // If the new quantity is zero, remove the dish from the list
          if (newQuantity == 0) {
            dishesList.removeAt(i);
          }

          // Update the Firestore document with the modified dishes list
          transaction.update(dishRef, {'dishes': dishesList});
          return;
        }
      }
    }).catchError((error) {
    });
  }

}
