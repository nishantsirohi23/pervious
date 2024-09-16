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
import '../models/dishes.dart';
import '../models/prof.dart';
import '../models/restraunts.dart';

class Adddishes extends StatefulWidget {
  final String restId;
  const Adddishes({Key? key,required this.restId}) : super(key: key);

  @override
  State<Adddishes> createState() => _PlatformFormScreenState();
}

class _PlatformFormScreenState extends State<Adddishes> {
  final _formKey = GlobalKey<FormState>();

  String? name;
  String? image;
  int revie = 0;
  int price = 0;

  List<String> _specialities = []; // Ensure it's initialized as an empty list
  bool _isLoading = false;  List<Map<String, String>> fileData = [];
  late String _image;

  TextEditingController _specialityController = TextEditingController();
  bool _loading = false;
  List<File> selectedFiles = [];

  bool isLoading = false;
  bool filesUploadedSuccessfully = false;
  bool isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Restaurant Form'),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: AssetImage("assets/onb2.png"),
                            ),
                            Positioned(
                                right: 0,
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
                        decoration: InputDecoration(labelText: 'Name'),
                        maxLines: 1,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your biography';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          name = value;
                        },
                      ),

                      TextFormField(
                        decoration: InputDecoration(labelText: 'price'),
                        maxLines: 1,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter a price';
                          }
                          // Check if the entered value can be parsed into an integer
                          if (int.tryParse(value!) == null) {
                            return 'Please enter a valid integer for the price';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          // Parse the string value to an integer and assign it to price
                          price = int.parse(value!);
                        },
                      ),

                      SizedBox(height: 16.0),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'review'),
                        maxLines: 1,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter a price';
                          }
                          // Check if the entered value can be parsed into an integer
                          if (int.tryParse(value!) == null) {
                            return 'Please enter a valid integer for the price';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          // Parse the string value to an integer and assign it to price
                          revie = int.parse(value!);
                        },
                      ),


                      SizedBox(height: 16.0),




                      SizedBox(height: 16.0),


                      SizedBox(height: 16.0),

                     
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            _formKey.currentState?.save();
                            // Process form data here, for example, send it to backend or display it in a dialog
                            setState(() {
                              _loading = true;
                            });


                            Dishesss myprof = Dishesss(
                                id: '',
                               name:  name.toString(),
                                price: price,
                                review: revie,
                                image: _image

                            );



                            setState(() {
                              _loading = false;
                            });
                            String? result = await APIs.addDish(myprof,widget.restId);

                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Adddishes(restId: widget.restId)),
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
      Reference storageReference = FirebaseStorage.instance.ref().child('restrantsimage').child(widget.restId).child(fileName);
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
