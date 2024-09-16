import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:perwork/models/stores/simpleproduct.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shimmer/shimmer.dart';

import '../../api/apis.dart';
import '../../screens/BookingTicket.dart';
import '../../screens/costumer/pickmultilocation.dart';
import '../../screens/costumer/restrauntscreen.dart' as rest;
import 'Orderconfirmscreen.dart';

class CheckoutScreen extends StatefulWidget {
  final String storeId; // Store ID to fetch products from cart

  CheckoutScreen({required this.storeId});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  Map<String, Product> cartItems = {};
  double fromLatitude= 0.0;
  double fromLongitude = 0.0;
  String receivedFrom = "";
  double toLatitude = 0.0;
  double drivingDistance = 0.0;
  String sdrivingDistance = "0.0";
  int platformFee = 5;
  bool isloading = true;
  int gst = 0;
  int deliveryFee = 0;
  double toLongitude = 0.0;
  String receivedTo = "";
  String _receivedText = 'Add Delivery Location';
  int _restFee = 0;
  String apiKey = "";
  String storename = "";
  String StoreAddress = "";
  String StoreImage = "";
  double storelat = 0.0;
  double storelong = 0.0;
  String rating = "";
  late Razorpay _razorpay;
  bool _isPaymentInProgress = false;

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print(response.orderId);
    print(response.paymentId);
    print(response.signature);
    setState(() {

      _isPaymentInProgress = false; // Payment completed, so set the flag to false
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderConfirmScreen(
          cartItems: cartItems,
          destlong: fromLatitude,
          destlat: fromLongitude,
          storeId: widget.storeId,
          deliveryAddress: _receivedText, // Replace with actual delivery address
          deliveryFee: deliveryFee.toDouble(), // Replace with actual delivery fee
          distance: drivingDistance,
          storeaddress: StoreAddress,
          storeimage: StoreImage,
          storelat: storelat,
          storelong: storelong,
          storename: storename,
          payment: false,
          paymentMode: "now",
          // Replace with actual distance
        ),
      ),
    );
    //APIs.makePayment(widget.workid, response.paymentId.toString());

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
  @override
  void initState() {
    super.initState();
    _loadCartItems();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _fetchRestFee();
  }
  Future<void> _fetchRestFee() async {
    try {


      DocumentSnapshot storeDoc = await FirebaseFirestore.instance.collection('stores').doc(widget.storeId).get();

      if (storeDoc.exists) {
        Map<String, dynamic> storeData = storeDoc.data() as Map<String, dynamic>;

        // Storing the store details directly in variables
        setState(() {
          storename = storeData['name'];
          StoreAddress = storeData['address'];
          StoreImage = storeData['imageUrl'];
          storelat = storeData['latitude'];
          storelong = storeData['longitude'];
        });
      } else {
        // Handle the case where the store does not exist
        print('Store not found');
      }
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
      print("deriving distance");
      print(drivingDistance);
      if (drivingDistance > 3) {
        setState(() {
          deliveryFee = (drivingDistance*6).toInt();
          print("delivery fee from ");
          print(deliveryFee);
          _calculateTotalPrice();
        });
      } else {
        setState(() {
          deliveryFee = 30;
          print("delivery fee from ");
          print(deliveryFee);
          _calculateTotalPrice();
        });
      }


      isloading =false;
    } else {
      throw Exception('Failed to fetch driving distance');
    }
  }


  // Function to load cart items from Firebase
  Future<void> _loadCartItems() async {
    final cartRef = FirebaseFirestore.instance
        .collection('carts')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection(widget.storeId);

    final cartSnapshot = await cartRef.get();
    setState(() {
      for (var doc in cartSnapshot.docs) {
        cartItems[doc.id] = Product(
          id: doc.id,
          name: doc['name'],
          price: doc['price'],
          quantity: doc['quantity'],
          image: doc['image'],
          review: doc['review'],
        );
      }
    });
  }

  // Function to increase quantity
  Future<void> _increaseQuantity(String productId) async {
    setState(() {
      cartItems[productId]!.quantity += 1;
    });

    final cartRef = FirebaseFirestore.instance
        .collection('carts')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection(widget.storeId);

    await cartRef.doc(productId).update({
      'quantity': cartItems[productId]!.quantity,
    });
  }

  // Function to decrease quantity
  Future<void> _decreaseQuantity(String productId) async {
    if (cartItems[productId]!.quantity > 1) {
      setState(() {
        cartItems[productId]!.quantity -= 1;
      });

      final cartRef = FirebaseFirestore.instance
          .collection('carts')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection(widget.storeId);

      await cartRef.doc(productId).update({
        'quantity': cartItems[productId]!.quantity,
      });
    } else {

      _removeFromCart(productId);
    }
  }

  // Function to remove item from cart
  Future<void> _removeFromCart(String productId) async {
    setState(() {
      cartItems.remove(productId);
    });
    if(cartItems.isEmpty){
      try {
        await FirebaseFirestore.instance.collection('carts').doc(APIs.me.id).update({
          'total': FieldValue.increment(-1),
        });
        print('Total incremented successfully');
      } catch (e) {
        print('Error incrementing total: $e');
      }
      await FirebaseFirestore.instance.collection('carts').doc(APIs.me.id).update({
        'stores': FieldValue.arrayRemove([widget.storeId])
      }).then((_) {
        print("Item removed from the list successfully!");
      }).catchError((error) {
        print("Failed to remove item from the list: $error");
      });
    }
    final cartRef = FirebaseFirestore.instance
        .collection('carts')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection(widget.storeId);

    await cartRef.doc(productId).delete();

    Navigator.pop(context);
  }

  // Function to calculate total price
  int _calculateTotalPrice() {
    print("Calculta e pricde called");
    print(deliveryFee);

    return cartItems.values.fold<int>(
      0, (sum, item) => sum + item.price * item.quantity,
    )+deliveryFee;
  }

  // Function to handle placing the order

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Checkout"),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              GestureDetector(
                onTap: (){Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) =>   rest.RestrauntScreen(id: widget.storeId


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
                              Text(storename,
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
                                        StoreAddress,
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
                                  "restSpecs",
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
                            imageUrl: StoreImage, // URL of the image
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
              SizedBox(height: 20,),

              GestureDetector(
                onTap: ()async{
                  // Open PickMultiLocation screen and wait for result
                  Map<String, dynamic>? result = await Navigator.push(context, MaterialPageRoute(builder: (context) => PickMultiLocation()));

                  // Handle the received data
                  if (result != null) {
                    setState(() {
                      fromLatitude = double.parse(result['fromLongitude'].toStringAsFixed(6));
                      fromLongitude = double.parse(result['fromLatitude'].toStringAsFixed(6));
                      receivedFrom = result['receivedFrom'];
                      _receivedText = receivedFrom;
                      toLatitude = double.parse(result['toLongitude'].toStringAsFixed(6));
                      toLongitude = double.parse(result['toLatitude'].toStringAsFixed(6));
                      receivedTo = result['receivedTo'];
                      fetchDistance(storelat.toString(),storelong.toString() , fromLongitude.toString(),fromLatitude.toString());

                    });


                    // Do something with the received data
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.pink.shade400,
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
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 18

                            ),),
                        ),
                        Icon(Icons.arrow_forward_ios,color: Colors.white,)
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    String productId = cartItems.keys.elementAt(index);
                    Product product = cartItems[productId]!;

                    return Container(
                      margin:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(35)),
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: product.image, // URL of the image
                              width: 52, // Double the radius to fit the CircleAvatar
                              height: 52, // Double the radius to fit the CircleAvatar
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: 104, // Double the radius to fit the CircleAvatar
                                  height: 104, // Double the radius to fit the CircleAvatar
                                  color: Colors.white,
                                ),
                              ),
                              errorWidget: (context, url, error) => Icon(Icons.error),
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "₹${product.price}",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  _decreaseQuantity(productId);
                                },
                                icon: Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                ),
                              ),
                              Text(
                                '${product.quantity}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  _increaseQuantity(productId);
                                },
                                icon: Icon(
                                  Icons.add_circle,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 15,
                      offset: Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Total: ₹${_calculateTotalPrice()}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Visibility(
                          visible: _receivedText=="Add Delivery Location",
                          child: Text(
                          " + Delivery Fee",
                          style: TextStyle(
                            fontSize: 18,color: Colors.pink,
                            fontWeight: FontWeight.w500,
                          ),
                        ),)
                      ],
                    ),

                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: (){

                        if(_receivedText=="Add Delivery Location"){
                          MotionToast.error(
                            title:  Text("Order Failed"),
                            description:  Text("Pick Delivery Location"),
                          ).show(context);
                        }
                        else{
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
                                                        Text("Rs. ${_calculateTotalPrice()-deliveryFee}",
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
                                                        Text("GST",
                                                          style: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: screenHeight*0.019
                                                          ),),
                                                        Text("Rs. "+"0".toString(),
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
                                                        Text("Rs. ${_calculateTotalPrice()+5}",
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
                                                                        _openCheckout((_calculateTotalPrice()+5).toDouble());
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
                                                                        Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                            builder: (context) => OrderConfirmScreen(
                                                                              cartItems: cartItems,
                                                                              destlong: fromLatitude,
                                                                              destlat: fromLongitude,
                                                                              storeId: widget.storeId,
                                                                              deliveryAddress: _receivedText, // Replace with actual delivery address
                                                                              deliveryFee: deliveryFee.toDouble(), // Replace with actual delivery fee
                                                                              distance: drivingDistance,
                                                                              storeaddress: StoreAddress,
                                                                              storeimage: StoreImage,
                                                                              storelat: storelat,
                                                                              storelong: storelong,
                                                                              storename: storename,
                                                                              payment: false,
                                                                              paymentMode: "now",
                                                                              // Replace with actual distance
                                                                            ),
                                                                          ),
                                                                        );
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

                        }
                      },
                      child: Container(
                        height: 55,
                        width: screenWidth,
                        margin: EdgeInsets.only(left: 1,right: 1),
                        decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/backofwork.png"),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(20))
                        ),
                        child: Center(child: Text('Checkout',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 21
                          ),)),
                      ),
                    ),



                  ],
                ),
              ),
            ],
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
      )
    );
  }
}

