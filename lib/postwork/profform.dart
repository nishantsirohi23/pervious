import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:perwork/Widget_tree.dart';
import 'package:file_picker/file_picker.dart';

import 'package:perwork/screens/tasker/taskerhomescreen.dart';
import 'package:perwork/screens/work/taskerWork.dart';

import '../api/apis.dart';
import '../models/prof.dart';

class PlatformFormScreen extends StatefulWidget {
  final String id;
  const PlatformFormScreen({Key? key,required this.id}) : super(key: key);

  @override
  State<PlatformFormScreen> createState() => _PlatformFormScreenState();
}

class _PlatformFormScreenState extends State<PlatformFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _biography;
  String? _experience;
  String? _profileImageUrl;
  String? _name;
  double? _pricePerHour;
  String? _username;
  String? _email;
  String? _phoneNumber;
  String? _aadharCardNumber;
  List<String> _specialities = []; // Ensure it's initialized as an empty list
  bool _isLoading = false;  List<Map<String, String>> fileData = [];
   String _image = 'https://cdn.dribbble.com/users/1068771/screenshots/8827348/media/44199dfa134f2b6c5a4afe903c2dc236.jpg?resize=1600x1200&vertical=center';

  TextEditingController _specialityController = TextEditingController();
  bool _loading = false;
  List<File> selectedFiles = [];

  bool isLoading = false;
  bool filesUploadedSuccessfully = false;
  bool isUploading = false;
  bool pickupSelected = false;
  bool otherSelected = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Professional Form'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                            onTap: () {
                              setState(() {
                                pickupSelected = true;
                                otherSelected = false;
                              });
                            },
                            child: Container(
                              height: 34,
                              padding: EdgeInsets.only(left: 10,right: 10),
                              decoration: BoxDecoration(
                                  color: pickupSelected?Colors.pink:Colors.white,
                                  borderRadius: BorderRadius.circular(17),
                                  border: Border.all(color:pickupSelected?Colors.pink:Colors.pink,width: 1 )
                              ),
                              child: Center(
                                child: Text(
                                  "Delivery Agent",
                                  style: TextStyle(fontSize: 16, color: pickupSelected?Colors.white:Colors.pink),
                                ),
                              ),

                            )
                        ),
                        SizedBox(width: 11,),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              pickupSelected = false;
                              otherSelected = true;
                            });
                          },
                          child: Container(
                            height: 34,
                            padding: EdgeInsets.only(left: 10,right: 10),
                            decoration: BoxDecoration(
                                color: otherSelected?Colors.pink:Colors.white,
                                borderRadius: BorderRadius.circular(17),
                                border: Border.all(color:otherSelected?Colors.pink:Colors.pink,width: 1 )
                            ),
                            child: Center(
                              child: Text(
                                "Others",
                                style: TextStyle(fontSize: 16, color: otherSelected?Colors.white:Colors.pink),
                              ),
                            ),

                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Container(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(_image),
                          ),
                          Positioned(
                              left: 0,
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                    color: Colors.pink.withOpacity(0.8),
                                    borderRadius: BorderRadius.all(Radius.circular(20))
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    _pickFiles();
                                  },
                                  icon: Icon(Icons.image, color: Colors.white),
                                ),
                              )
                          ),
                        ],
                      ),
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Biography'),
                      maxLines: 3,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your biography';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _biography = value;
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Experience'),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your experience';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _experience = value;
                      },
                    ),
                    SizedBox(height: 16.0),

                    TextFormField(
                      decoration: InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _name = value;
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Price per Hour'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter price per hour';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _pricePerHour = double.tryParse(value ?? '');
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Username'),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _username = value;
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value?.isEmpty ?? true || !(value?.contains('@') ?? false)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _email = value;
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Phone Number'),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        // Add phone number validation if needed
                        return null;
                      },
                      onSaved: (value) {
                        _phoneNumber = value;
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Aadhar Card Number'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        // Add Aadhar card number validation if needed
                        return null;
                      },
                      onSaved: (value) {
                        _aadharCardNumber = value;
                      },
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _specialityController,
                            decoration: InputDecoration(labelText: 'Speciality'),
                          ),
                        ),
                        SizedBox(width: 16.0),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if (_specialityController.text.isNotEmpty) {
                                _specialities.add(_specialityController.text);
                                _specialityController.clear();
                              }
                            });
                          },
                          child: Text('Add'),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Text('Specialities: ${_specialities.join(', ')}'),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          _formKey.currentState?.save();
                          // Process form data here, for example, send it to backend or display it in a dialog
                          setState(() {
                            _loading = true;
                          });

                          double pricePerHour = _pricePerHour ?? 0.0;
                          Professional myprof = Professional(
                            bankadded: false,
                            walletamount: 0,
                            workamount: 0,
                            mytips: 0,
                            id: widget.id,
                            name: _name.toString(),
                            biography: _biography.toString(),
                            experience: _experience.toString(),
                            pricePerHour: pricePerHour,
                            username: _username.toString(),
                            email: _email.toString(),
                            phoneNumber: _phoneNumber.toString(),
                            aadharCardNumber: _aadharCardNumber.toString(),
                            specialities: _specialities,
                            totalrating: "0",
                            rating: "5",
                            profileImageUrl: _image,
                          );


                          String? result = await APIs.addProf(myprof);
                          CollectionReference users = FirebaseFirestore.instance.collection(
                              'users');

                          // Update data in Firestore
                          await users.doc(widget.id).update({
                            'name': _name.toString(),
                            'mobile': _phoneNumber.toString(),
                            'image': _image.toString(),
                            'type': otherSelected?'others':'delivery'
                          });

                          setState(() {
                            _loading = false;
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => WidgetTree(name: "")),
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result ?? 'Unknown error occurred'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: _loading
                          ? CircularProgressIndicator() // Show loading indicator if _loading is true
                          : Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ),if (_isLoading||isUploading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                  child: Lottie.asset("assets/lottie/loading.json")
              ),
            ),
        ],
      )
    );
  }
  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        selectedFiles = result.paths.map((path) => File(path!)).toList();
      });
      setState(() {
        isUploading = true;
      });
      List<Map<String, String>> uploadedFiles = await _uploadFiles(selectedFiles);
      if (uploadedFiles.isNotEmpty) {
        setState(() {
          filesUploadedSuccessfully = true;
          isUploading = false;
        });
      }
    }
  }

  Future<List<Map<String, String>>> _uploadFiles(List<File> files) async {

    for (File file in files) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageReference.putFile(file);
      await uploadTask.whenComplete(() async {
        String url = await storageReference.getDownloadURL();
        _image = url;

        // Extract file extension
        String fileType = file.path.split('.').last;

        // Store file URL and type as a pair
        fileData.add({'url': url, 'type': fileType});
      });
    }

    return fileData;
  }
}
