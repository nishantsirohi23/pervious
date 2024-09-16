import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:telephony/telephony.dart';

import '../screens/costumer/homescreen.dart';
import '../try/mobile_auth.dart';

class LoginPageCustomer extends StatefulWidget {
  const LoginPageCustomer({Key? key}) : super(key: key);

  @override
  State<LoginPageCustomer> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPageCustomer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final Telephony telephony = Telephony.instance;

  TextEditingController _phoneContoller = TextEditingController();
  TextEditingController _otpContoller = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();

  bool isLoading = false; // Track loading state

  void listenToIncomingSMS(BuildContext context) {
    print("Listening to sms.");
    telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) {
          // Handle message
          print("sms received : ${message.body}");
          // verify if we are reading the correct sms or not

          if (message.body!.contains("PerPenny")) {
            String otpCode = message.body!.substring(0, 6);
            setState(() {
              _otpContoller.text = otpCode;
              // wait for 1 sec and then press handle submit
              Future.delayed(Duration(seconds: 1), () {
                handleSubmit(context);
              });
            });
          }
        },
        listenInBackground: false);
  }

  // handle after otp is submitted
  void handleSubmit(BuildContext context) {
    if (_formKey1.currentState!.validate()) {
      AuthService.loginWithOtp(otp: _otpContoller.text).then((value) {
        if (value == "Success") {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CustomerHomeScreen()),
          );
          MotionToast.success(
            title: Text("Verification Success"),
            description: Text("Mobile Number Verified Successfully"),
          ).show(context);
        } else {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              value,
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ));
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Lottie.asset("assets/lottie/splash.json"),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Mobile Verification 👋",
                          style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.w700),
                        ),
                        Text("Enter you phone number to continue."),
                        SizedBox(
                          height: 20,
                        ),
                        Form(
                          key: _formKey,
                          child: TextFormField(
                            controller: _phoneContoller,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                                prefixText: "+91 ",
                                labelText: "Enter you phone number",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(32))),
                            validator: (value) {
                              if (value!.length != 10)
                                return "Invalid phone number";
                              return null;
                            },
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  isLoading = true; // Start loading
                                });
                                AuthService.sentOtp(
                                    phone: _phoneContoller.text,
                                    errorStep: () =>
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(
                                            "Error in sending OTP",
                                            style: TextStyle(
                                                color: Colors.white),
                                          ),
                                          backgroundColor: Colors.red,
                                        )),
                                    nextStep: () {
                                      // start listening for otp
                                      listenToIncomingSMS(context);
                                      showDialog(
                                          context: context,
                                          builder: (context) =>
                                              AlertDialog(
                                                title: Text(
                                                    "OTP Verification"),
                                                content: Column(
                                                  mainAxisSize:
                                                  MainAxisSize.min,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    Text(
                                                        "Enter 6 digit OTP"),
                                                    SizedBox(
                                                      height: 12,
                                                    ),
                                                    Form(
                                                      key: _formKey1,
                                                      child: TextFormField(
                                                        keyboardType:
                                                        TextInputType
                                                            .number,
                                                        controller:
                                                        _otpContoller,
                                                        decoration:
                                                        InputDecoration(
                                                            labelText:
                                                            "Enter you phone number",
                                                            border: OutlineInputBorder(
                                                                borderRadius:
                                                                BorderRadius.circular(
                                                                    32))),
                                                        validator: (value) {
                                                          if (value!
                                                              .length !=
                                                              6)
                                                            return "Invalid OTP";
                                                          return null;
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () =>
                                                          handleSubmit(
                                                              context),
                                                      child:
                                                      Text("Submit"))
                                                ],
                                              ));
                                    })
                                    .then((_) {
                                  setState(() {
                                    isLoading = false; // Stop loading
                                  });
                                });
                              }
                            },
                            child: Text("Send OTP"),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.yellow,
                                foregroundColor: Colors.black),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Center(
              child: Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.05),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Lottie.asset('assets/lottie/loading.json'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
