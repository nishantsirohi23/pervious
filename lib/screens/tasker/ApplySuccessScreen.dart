import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:perwork/screens/tasker/taskerhomescreen.dart';


class ApplySuccessScreen extends StatefulWidget {
  @override
  _SuccessScreenState createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<ApplySuccessScreen> {
  @override
  void initState() {
    super.initState();
    // Wait for 2 seconds and then navigate to the next screen
    Timer(Duration(seconds: 1, milliseconds: 600), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TaskerHomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/lottie/success.json', width: 200),
            SizedBox(height: 20),
            Text(
              'Success!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

