import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:perwork/screens/tasker/taskerhomescreen.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../Widget_tree.dart';
import 'package:crypto/crypto.dart';

import '../../api/apis.dart';
import '../../postwork/customerverify.dart';
import '../../postwork/profform.dart';
import '../../postwork/workerverify.dart';
import '../../screens/costumer/homescreen.dart';
import '../../try/hireperhour.dart';
import '../../try/hireperhour.dart';
import 'sign_in_form.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final User? user = auth.currentUser;
final uid = user?.uid;

final _firestore = FirebaseFirestore.instance;

late Stream<List<DocumentSnapshot>> stream;

class CustomSigninDialog extends StatefulWidget {
  final bool isWorker;
  final ValueChanged onCLosed;

  CustomSigninDialog({required this.isWorker, required this.onCLosed});

  @override
  _CustomSigninDialogState createState() => _CustomSigninDialogState();
}

class _CustomSigninDialogState extends State<CustomSigninDialog> {
  bool isLoading = false;

  Future<UserCredential?> _signInWithGoogle() async {
    setState(() {
      isLoading = true;
    });
    try {
      await InternetAddress.lookup('google.com');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      print("credential");
      print(credential);
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      print('\n_signInWithGoogle: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong'),
          duration: Duration(seconds: 2),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
      return null;
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  Future<UserCredential?> _signInWithEmailAndPassword(
      String email, String password) async {
    setState(() {
      isLoading = true;
    });
    try {
      await InternetAddress.lookup('google.com');
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } catch (e) {
      print('\n_signInWithEmailAndPassword: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong'),
          duration: Duration(seconds: 2),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
      return null;
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _handleEmailSignIn() {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter username and password'),
          duration: Duration(seconds: 2),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: username, password: password)
        .then((credential) async {
      // Sign-in successful
      print('User signed in: ${credential.user}');
      if (await APIs.userExists()) {
        if (widget.isWorker) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => PlatformFormScreen(id: credential.user!.uid)),
                (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => WidgetTree(name: "")),
                (route) => false,
          );
        }
      } else {
        // User does not exist, handle appropriately
      }
    }).catchError((e) {
      // Error handling
      print('Sign in error: $e');
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No user found for that email.'),
              duration: Duration(seconds: 2),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {},
              ),
            ),
          );
        } else if (e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Wrong password provided for that user.'),
              duration: Duration(seconds: 2),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {},
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sign in failed. Please try again later.'),
              duration: Duration(seconds: 2),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {},
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed. Please try again later.'),
            duration: Duration(seconds: 2),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      }
    }).whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
  }

  void _handleGoogleBtnClick() {
    setState(() {
      isLoading = true;
    });
    _signInWithGoogle().then((user) async {
      if (user != null) {
        print('\nUser: ${user.user}');
        print('\nUserAdditionalInfo: ${user.additionalUserInfo}');
        if (await APIs.userExists()) {
          if (widget.isWorker) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => PlatformFormScreen(id: user.user!.uid)),
                  (route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => WidgetTree(name: "")),
                  (route) => false,
            );
          }
        } else {
          await APIs.createUser(widget.isWorker ? "worker" : "costumer")
              .then((value) {
            if (widget.isWorker) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => PlatformFormScreen(id: user.user!.uid)),
                    (route) => false,
              );
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => WidgetTree(name: "")),
                    (route) => false,
              );
            }
          });
        }
      }
      setState(() {
        isLoading = false;
      });
    });
  }




  Future<void> signInWithApple() async {
    setState(() {
      isLoading = true;
    });

    final appleProvider = AppleAuthProvider();
    try {
      final userCredential = kIsWeb
          ? await FirebaseAuth.instance.signInWithPopup(appleProvider)
          : await FirebaseAuth.instance.signInWithProvider(appleProvider);

      if (userCredential != null && userCredential.user != null) {
        final user = userCredential.user!;
        print('\nUser: $user');

        // Check if user email or display name is missing
        if (user.email == "null") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CompleteProfileScreen(user: user, isWorker: false,)),
          );
          return;
        }

        if (await APIs.userExists()) {
          if (widget.isWorker) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => PlatformFormScreen(id: user.uid)),
                  (route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => WidgetTree(name: "")),
                  (route) => false,
            );
          }
        } else {
          await APIs.createUser(widget.isWorker ? "worker" : "customer");
          if (widget.isWorker) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => PlatformFormScreen(id: user.uid)),
                  (route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => WidgetTree(name: "")),
                  (route) => false,
            );
          }
        }
      }
    } catch (e) {
      // Handle error
      print('Error signing in with Apple: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      child: Container(
        height: Platform.isIOS?560:250,
        padding: const EdgeInsets.symmetric(vertical: 32,horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.94),
          borderRadius: const BorderRadius.all(Radius.circular(40)),
        ),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          body: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                children: [
                  const Text(
                    "Sign In",
                    style: TextStyle(fontSize: 34, fontFamily: "Poppins"),
                  ),
                  SizedBox(height: 15,),

                  GestureDetector(
                    onTap: _handleGoogleBtnClick,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/google.png",
                            height: 44,
                            width: 44,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            "Google Sign In",
                            style: TextStyle(fontSize: 17),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Visibility(
                      visible:Platform.isIOS,child: Column(
                    children: [
                      GestureDetector(
                        onTap: signInWithApple,
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/apple.png",
                                height: 44,
                                width: 44,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                "Apple Sign In",
                                style: TextStyle(fontSize: 17),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
                      Text("Already a Customer? Sign in"),
                      SizedBox(height: 20,),

                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: _handleEmailSignIn,
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width*0.5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0), // Adjust the value as needed
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xffE100FF), Color(0xFFfc67fa)], // Example gradient colors
                            ),
                          ),
                          child: Center(
                            child: Text('Sign In',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19

                              ),),
                          ),

                        ),
                      ),
                    ],
                  )),


                  if (isLoading)
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.05),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              "Loading...",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w400),
                            )
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: -48,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.black),
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onCLosed(null);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<Object?> customSigninDialog(BuildContext context, bool isWorker,
    {required ValueChanged onCLosed}) {
  return showDialog(
    useSafeArea: true,
    context: context,
    builder: (context) => CustomSigninDialog(isWorker: isWorker, onCLosed: onCLosed),
  ).then(onCLosed);
}

class CompleteProfileScreen extends StatefulWidget {
  final User user;
  final bool isWorker;

  CompleteProfileScreen({required this.user, required this.isWorker});

  @override
  _CompleteProfileScreenState createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _email;
  String? _displayName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complete Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (widget.user.email == null)
                TextFormField(
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _email = value;
                  },
                ),
              if (widget.user.displayName == null)
                TextFormField(
                  decoration: InputDecoration(labelText: 'Full Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _displayName = value;
                  },
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    try {
                      if (_email != null) {
                        await widget.user.verifyBeforeUpdateEmail(_email!);
                      }
                      if (_displayName != null) {
                        await widget.user.updateDisplayName(_displayName!);
                      }

                      // Redirect to appropriate screen
                      if (widget.isWorker) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => PlatformFormScreen(id: widget.user.uid)),
                              (route) => false,
                        );
                      } else {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => WidgetTree(name: "")),
                              (route) => false,
                        );
                      }
                    } catch (e) {
                      // Handle error
                      print('Error updating profile: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update profile. Please try again.')),
                      );
                    }
                  }
                },
                child: Text('Complete Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


