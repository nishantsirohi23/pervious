import 'dart:async';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../api/apis.dart';
import '../../models/stores/simpleproduct.dart';
import '../../screens/costumer/SuccessScreen.dart';

class OrderConfirmScreen extends StatefulWidget {
  final Map<String, Product> cartItems; // Changed from Dish to Product
  final String storeId;
  final String deliveryAddress;
  final double deliveryFee;
  final double distance;
  final double destlat;
  final double destlong;
  final String storename;
  final String storeimage;
  final String storeaddress;
  final double storelat;
  final double storelong;
  final bool payment;
  final String paymentMode;

  OrderConfirmScreen({
    required this.storename,
    required this.storeimage,
    required this.storeaddress,
    required this.storelat,
    required this.storelong,
    required this.cartItems,
    required this.storeId,
    required this.deliveryAddress,
    required this.deliveryFee,
    required this.destlong,
    required this.destlat,
    required this.distance,
    required this.payment,
    required this.paymentMode,
  });

  @override
  _OrderConfirmScreenState createState() => _OrderConfirmScreenState();
}

class _OrderConfirmScreenState extends State<OrderConfirmScreen> {
  int _timer = 15; // Countdown reduced to 15 seconds
  late Timer _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timer > 0) {
        setState(() {
          _timer--;
        });
      } else {
        _confirmOrder();
      }
    });
  }

  void _cancelOrder() {
    _countdownTimer.cancel();
    Navigator.pop(context); // Navigate back to the cart screen
  }

  Future<void> _confirmOrder() async {
    _countdownTimer.cancel();

    final orderId = FirebaseFirestore.instance.collection('orders').doc().id;
    final orderData = {
      // Your order data here...
      'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
      'deliveryFee': widget.deliveryFee.round(),
      'deliveryaddress': widget.deliveryAddress,
      'destlat': widget.destlat,
      'destlong': widget.destlong,
      'distance': widget.distance,
      'dishes': widget.cartItems.values.map((product) => product.toMap()).toList(),
      'id': orderId,
      'orderBy': APIs.me.id,
      'orderPlacedAt': DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, DateTime.now().hour, DateTime.now().minute),
      'orderamount': _calculateOrderAmount().round(),
      'payment': widget.payment,
      'paymentMode': widget.paymentMode,
      'picked': false,
      'restID': widget.storeId,
      'restaddress': widget.storeaddress,
      'restamount': (_calculateOrderAmount() - widget.deliveryFee).round(),
      'restimage': widget.storeimage,
      'restname': widget.storename,
      'reviewdone': false,
      'sourcelat': widget.storelat,
      'sourcelong': widget.storelong,
      'status': "preparing",
      'tip': 0,
      'totalQuantity': widget.cartItems.values.fold<int>(
        0,
            (sum, item) => sum + item.quantity,
      ),
      'totalamount': _calculateTotalAmount().round(),
    };

    await FirebaseFirestore.instance.collection('orders').doc(orderId).set(orderData);

    final List<String> productIdsToRemove = widget.cartItems.keys.toList();

    for (String productId in productIdsToRemove) {
      await _removeFromCart(productId);
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SuccessScreen()),
    );

    APIs.sendnotificationtowork("Store Order", "delivery");
  }

  Future<void> _removeFromCart(String productId) async {
    setState(() {
      widget.cartItems.remove(productId);
    });
    if (widget.cartItems.isEmpty) {
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
  }

  int _calculateTotalAmount() {
    return widget.cartItems.values.fold<int>(
      0,
          (sum, item) => sum + item.price * item.quantity,
    ) +
        widget.deliveryFee.toInt();
  }

  int _calculateOrderAmount() {
    return widget.cartItems.values.fold<int>(
      0,
          (sum, item) => sum + item.price * item.quantity,
    );
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Order'),
        backgroundColor: Colors.white,
      ),
      body: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularCountDownTimer(
              duration: 15, // Countdown duration updated to 15 seconds
              initialDuration: 0,
              controller: CountDownController(),
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.height / 2,
              ringColor: Colors.grey[300]!,
              ringGradient: null,
              fillColor: Colors.pinkAccent[100]!,
              fillGradient: null,
              backgroundColor: Colors.pink[300],
              backgroundGradient: null,
              strokeWidth: 20.0,
              strokeCap: StrokeCap.round,
              textStyle: TextStyle(
                  fontSize: 33.0, color: Colors.white, fontWeight: FontWeight.bold),
              textFormat: CountdownTextFormat.S,
              isReverse: true,
              isReverseAnimation: true,
              isTimerTextShown: true,
              autoStart: true, // Automatically start the timer
              onStart: () {
                debugPrint('Countdown Started');
              },
              onComplete: () {
                debugPrint('Countdown Ended');
                _confirmOrder(); // Automatically confirm the order when the countdown ends
              },
              onChange: (String timeStamp) {
                debugPrint('Countdown Changed $timeStamp');
              },
              timeFormatterFunction: (defaultFormatterFunction, duration) {
                if (duration.inSeconds == 0) {
                  return "Start";
                } else {
                  return Function.apply(defaultFormatterFunction, [duration]);
                }
              },
            ),
            Text(
              'Your order will be confirmed in $_timer seconds',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _confirmOrder,
              child: Text('Confirm Now'),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: _cancelOrder,
              child: Text('Cancel Order'),
            ),
          ],
        ),
      )
    );
  }
}
