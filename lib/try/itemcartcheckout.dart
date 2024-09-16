import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:perwork/try/pigeon.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../api/apis.dart';
import '../screens/BookingTicket.dart';
import '../screens/costumer/SuccessScreen.dart';
import '../utils/LocationService.dart';
import 'my_global.dart';

class ItemCartCheckout extends StatefulWidget {
  const ItemCartCheckout({Key? key}) : super(key: key);

  @override
  State<ItemCartCheckout> createState() => _ItemCartCheckoutState();
}

class _ItemCartCheckoutState extends State<ItemCartCheckout> {
  int deliveryFee = 0;
  double totalPrice = 0.0;
  double finalPrice = 0.0;
  double nearestDistance = double.infinity;
  double nearestStoreLatitude = 0.0;
  double nearestStoreLongitude = 0.0;
  late LocationService _locationService;
  PickResult? selectedFromPlace;
  PickResult? selectedToPlace;
  double _fromlatitude = 0.0;
  double _fromlongitude = 0.0;
  int totalAmount = 0;
  int restamount = 0;
  double _latitude = 0.0;
  double _longitude = 0.0;
  Future<void> _getCurrentLocation() async {
    setState(() {
      isloading =true;
    });
    FirebaseFirestore.instance.collection('users').doc(APIs.me.id).snapshots().listen((DocumentSnapshot snapshot) {
      setState(() {
        _latitude = snapshot['latitude'] ?? 0;
        _longitude = snapshot['longitude'] ?? 0;
        _fromlatitude = snapshot['latitude'] ?? 0;
        _fromlongitude = snapshot['longitude'] ?? 0;
      });
      _getAddressFromLatLng(_latitude,_longitude);
      calculateDeliveryFee();
    });

  }
  String _address = 'Fetching address...';

  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['status'] == 'OK') {
        setState(() {
          _address = data['results'][0]['formatted_address'];
        });
      } else {
        setState(() {
          _address = 'No address found';
        });
      }
    } else {
      setState(() {
        _address = 'Failed to fetch address';
      });
    }
    setState(() {
      _receivedfrom = _address;
    });
    print(_address);
  }
  String _receivedfrom = APIs.me.about;
  String _receivedto = "Pick To Location";
  double hline = 50.0;
  var sdrivingDuration = "";
  int orderamount = 0;
  double restlat = 0.0;
  double restlong = 0.0;
  String apiKey = Globals.apiKey;
  double drivingDistance = 0.0;
  String sdrivingDistance = "0.0";
  int platformFee = 5;
  int gst = 0;
  String _receivedText = 'Pick Delivery Location';
  String restImage = "";
  String restSpecs = "";
  String restname = "";
  String restAddress = "";
  String receivedFrom = "";
  int workertip = 0;
  int tippay = 0;
  bool ten = false;
  bool twenty = false;
  bool thirty = false;
  bool isloading = true;
  int _restFee = 0;


  late Razorpay _razorpay;
  bool _isPaymentInProgress = false;

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print(response.orderId);
    print(response.paymentId);
    print(response.signature);
    setState(() {

      _isPaymentInProgress = false; // Payment completed, so set the flag to false
    });
    placeOrder(true,"now");

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
    });
    var options = {
      'key': 'rzp_live_ymUGpkKEgzMtUI',
      'amount': amount * 100, // amount in the smallest currency sub-unit
      'name': 'PerPenny',
      'description': 'Item Delivery',
      'prefill': {
        'contact': APIs.me.mobile,
        'email': APIs.me.email
      }
    };
    try {
      setState(() {
        _isPaymentInProgress = true; // Payment process started, so set the flag to true
      });
      // Show loading indicator

      _razorpay.open(options);
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
  void initState() {
    super.initState();
    _fetchRestFee();
    _locationService = LocationService();


    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

  }
  void placeOrder(bool payment, String paymentMode) async {
    final cartItemsSnapshot = await FirebaseFirestore.instance.collection("users").doc(APIs.me.id).collection('item_cart').get();
    final items = cartItemsSnapshot.docs;

    final orderId = FirebaseFirestore.instance.collection('orders').doc().id;
    final orderData = {
      'status': "waiting",
      'orderBy': APIs.me.id,
      'reviewdone': false,
      'storeAddress': "",
      'storename': "",
      'deliveryaddress': _receivedfrom,
      'destlong': _fromlongitude,
      'destlat': _fromlatitude,
      'sourcelong': nearestStoreLongitude,
      'sourcelat': nearestStoreLatitude,
      'restamount': 12,
      'picked': false,
      'createdAt': DateTime
          .now()
          .millisecondsSinceEpoch
          .toString(),
      'orderPlacedAt': DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, DateTime.now().hour, DateTime.now().minute),
      'distance': nearestDistance,
      'paymentMode': paymentMode,
      'payment': payment,
      'orderamount': totalPrice.round(),
      'totalamount':  finalPrice,
      'deliveryFee': deliveryFee,
    };

    try {
      // Create new order document
      await FirebaseFirestore.instance.collection('orders').doc(orderId).set(orderData);

      // Add items to the sub-collection
      for (var item in items) {
        final itemData = item.data() as Map<String, dynamic>;
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .collection('items')
            .doc(item.id)
            .set({

          'itemId': item.id,
          'name': itemData['name'] ?? '',
          'image': itemData['image'] ?? '',
          'price': itemData['price'] ?? '0.0',
          'quantity': itemData['quantity'] ?? 0,
        });
      }

      // Clear the cart
      for (var item in items) {
        await FirebaseFirestore.instance.collection("users").doc(APIs.me.id).collection('item_cart').doc(item.id).delete();
      }
      APIs.addfoodtotracks(orderId, "https://firebasestorage.googleapis.com/v0/b/perwork.appspot.com/o/categories%2FUntitled%20design-3.png?alt=media&token=e6cec73f-a9ce-4f75-a329-0c07711d85f3","Item Delivery");

      // Navigate to success screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SuccessScreen()),
      );
      APIs.sendnotificationtowork("Item Order","delivery");

      // Send notification
    } catch (e) {
      print('Failed to place order: $e');
    }
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
          _restFee = document.get('itemfee'); // Replace with your field name
          isloading = false;
          print("Rest fee");
          print(_restFee);
        });
      } else {
        setState(() {
          isloading = false;
        });
      }
      _getCurrentLocation();

    } catch (e) {
      setState(() {
        isloading = false;
      });
    }
  }

  Future<void> calculateDeliveryFee() async {

    QuerySnapshot storeSnapshot = await FirebaseFirestore.instance.collection('itemstores').get();


    for (var doc in storeSnapshot.docs) {
      final storeData = doc.data() as Map<String, dynamic>;
      double storeLatitude = storeData['latitude'];
      double storeLongitude = storeData['longitude'];
      print("from calculate");
      print(_fromlatitude);
      print(_fromlongitude);
      double distance = await fetchDistance(_fromlatitude.toString(), _fromlongitude.toString(), storeLatitude.toString(), storeLongitude.toString());
      print(distance);
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestStoreLatitude = storeLatitude;
        nearestStoreLongitude = storeLongitude;
      }
    }
    print("this is distance");
    print(nearestDistance);
    setState(() {
      if(nearestDistance>3){
        setState(() {
          deliveryFee = (nearestDistance * _restFee).round();
        });

      }
      else{
        setState(() {
          deliveryFee = 30;
        });


      }
      isloading = false;
    });
  }

  Future<double> fetchDistance(String sourcelat, String sourcelong, String destlat, String destlong) async {
    final origins = '$sourcelat,$sourcelong';
    final destinations = '$destlat,$destlong';

    final url = Uri.parse('https://maps.googleapis.com/maps/api/distancematrix/json'
        '?origins=$origins'
        '&destinations=$destinations'
        '&mode=driving'
        '&key=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final distanceInMeters = data['rows'][0]['elements'][0]['distance']['value'];
      return distanceInMeters / 1000.0; // Convert to kilometers
    } else {
      throw Exception('Failed to fetch driving distance');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart Checkout'),
      ),
      body: Column(
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
                            nearestDistance = double.infinity;
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
                          calculateDeliveryFee();


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
          Expanded(child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection("users").doc(APIs.me.id).collection('item_cart').snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              final items = snapshot.data?.docs ?? [];

              if (items.isEmpty) {
                return Center(child: Text('Your cart is empty.'));
              }

              totalPrice = calculateTotalPrice(items);
              finalPrice = totalPrice + deliveryFee + 5 ;

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final itemData = items[index].data() as Map<String, dynamic>;
                        return CartItem(
                          itemId: items[index].id,
                          name: itemData['name'] ?? '',
                          image: itemData['image'] ?? '',
                          price: itemData['price'] ?? '0.0',
                          quantity: itemData['quantity'] ?? 0,
                          onIncrease: increaseQuantity,
                          onDecrease: decreaseQuantity,
                        );
                      },
                    ),
                  ),
                  if (isloading)
                    Center(child: CircularProgressIndicator())
                  else
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
                                        visible: true,
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
                                                  finalPrice.toString(),
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
                                                                                  Text("Rs. "+'${totalPrice.toStringAsFixed(2)}',
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
                                                                                  Text("Rs. "+5.toString(),
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
                                                                                  Text("Rs. "+'${deliveryFee.toStringAsFixed(2)}',
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
                                                                                  Text("Rs. "+finalPrice.toString(),
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
                                                                                                  _openCheckout(finalPrice);
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

                                                                                                  placeOrder(false,"cod");
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

                                  ],),


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
                                                            // Define a function to create and handle the dialog
                                                            //placeorder();
                                                            Navigator.pop(context);

                                                            _openCheckout(finalPrice);

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

                                                            placeOrder(false,"cod");

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
            },
          ))
        ],
      ),
    );
  }

  double calculateTotalPrice(List<QueryDocumentSnapshot> items) {
    double totalPrice = 0;
    items.forEach((item) {
      final itemData = item.data() as Map<String, dynamic>;
      final price = double.tryParse(itemData['price']?.toString() ?? '0.0') ?? 0.0;
      final quantity = itemData['quantity'] ?? 0;
      totalPrice += price * quantity;
    });
    return totalPrice;
  }

  void increaseQuantity(String itemId) {
    FirebaseFirestore.instance.collection("users").doc(APIs.me.id).collection('item_cart').doc(itemId).update({
      'quantity': FieldValue.increment(1),
    });
  }

  void decreaseQuantity(String itemId, int currentQuantity) {
    if (currentQuantity > 1) {
      FirebaseFirestore.instance.collection("users").doc(APIs.me.id).collection('item_cart').doc(itemId).update({
        'quantity': FieldValue.increment(-1),
      });
    } else {
      FirebaseFirestore.instance.collection("users").doc(APIs.me.id).collection('item_cart').doc(itemId).delete();
    }
  }
}

class CartItem extends StatelessWidget {
  final String itemId;
  final String name;
  final String image;
  final String price;
  final int quantity;
  final Function(String) onIncrease;
  final Function(String, int) onDecrease;

  const CartItem({
    Key? key,
    required this.itemId,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double counterWidth = (30 * quantity).toDouble();
    if (counterWidth > 90) counterWidth = 90.0;

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(image),
      ),
      title: Text(name),
      subtitle: Row(
        children: [
          Text('Price: $price'),
          SizedBox(width: 10),
          Container(
            width: 130,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    onDecrease(itemId, quantity);
                  },
                ),
                Text('$quantity'),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    onIncrease(itemId);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
