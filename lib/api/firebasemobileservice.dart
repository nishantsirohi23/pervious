import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:perwork/screens/costumer/homescreen.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String verificationId1 = "";
  String vid="";

  Future<String> sendOTP(String phoneNumber1) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+91 9084940146',
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {},
      codeSent: (
          String verificationId, int? resendToken
          ) {
        vid = verificationId;
        print("vid from service");
        print(vid);
        verificationId1 = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
    return vid;
  }

  Future<bool> verifyOTP(BuildContext context, String smsCode,String verid) async {
    print("from verify");
    print(vid);
    print(smsCode);
    try {
      // Create a PhoneAuthCredential using the verificationId and SMS code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verid,
        smsCode: smsCode,
      );

      // Check if the credential is valid by calling signInWithCredential
      // We are not interested in signing in the user, we just want to check if the OTP is correct
      await FirebaseAuth.instance.signInWithCredential(credential);

      // If no exception is thrown, it means the OTP is correct
      // So navigate to the new screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>   CustomerHomeScreen()),
      );

      // Return true indicating OTP verification success
      return true;
    } catch (e) {
      // If there's an error during verification, show an alert indicating wrong OTP
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Invalid OTP. Please try again."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );

      // Return false indicating OTP verification failure
      return false;
    }
  }
}
