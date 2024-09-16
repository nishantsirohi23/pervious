import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:perwork/models/stores/StoreRegistrationScreen.dart';
import 'package:perwork/models/stores/StoreScreen.dart';
import 'package:perwork/onboarding/OnboardingScreen.dart';
import 'package:perwork/postwork/login.dart';
import 'package:perwork/screens/costumer/homescreen.dart';
import 'package:perwork/screens/tasker/taskerhomescreen.dart';
import 'package:perwork/try/shownotifications.dart';
import 'package:perwork/widgets/phonenumber.dart';

import 'api/apis.dart';
import 'models/stores/ProductUploadScreen.dart';
import 'models/stores/SearchProduct.dart';

class WidgetTree extends StatefulWidget {
  final String name;

  const WidgetTree({Key? key, required this.name}) : super(key: key);

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Fetch user information when the widget is first created
    _loadUserData();
  }

  void _loadUserData() async {
    if (APIs.auth.currentUser != null) {
      await APIs.getSelfInfo();
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    if (_isLoading) {
      // Show loading indicator while user data is being fetched
      return Scaffold(
        body: Center(
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
          ),
        ),
      );
    } else {
      if (APIs.auth.currentUser != null) {
        // Navigate to home screen based on the name parameter
        if (APIs.me.type=="others") {
          return TaskerHomeScreen();
        }
        if(APIs.me.type=="delivery"){
          return TaskerHomeScreen();
        }
        if(APIs.me.mobile!=""){
          return CustomerHomeScreen();
        }
        return PhoneInputScreen();
      }  else {
        print("User not signed in");
        // Navigate to login screen
        return OnboardingScreen();
      }
    }
  }
}
