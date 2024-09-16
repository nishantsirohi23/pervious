import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:perwork/screens/BookingTicket.dart';
import 'package:perwork/screens/costumer/homescreen.dart';
import 'package:perwork/screens/costumer/showmywork.dart';
import 'package:perwork/screens/userbooking.dart';

import '../api/apis.dart';
import '../screens/profilescreen.dart';

class EditProfileScreen extends StatefulWidget {
  final String bookingID;
  final String type;

  const EditProfileScreen({Key? key, required this.bookingID,required this.type}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late String _name;
  late String _email;
  late String _mobile;
  late String _image;
  List<File> selectedFiles = [];

  bool isLoading = false;
  bool filesUploadedSuccessfully = false;
  bool isUploading = false;
  TextEditingController? _nameController;
  TextEditingController? _emailController;
  TextEditingController? _mobileController;

  bool _isLoading = false;  List<Map<String, String>> fileData = [];


  @override
  void initState() {
    super.initState();
    _name = APIs.me.name;
    _email = APIs.me.email;
    _mobile = APIs.me.mobile;
    _image = APIs.me.image;

    _nameController = TextEditingController(text: _name);
    _emailController = TextEditingController(text: _email);
    _mobileController = TextEditingController(text: _mobile);
  }

  @override
  void dispose() {
    _nameController?.dispose();
    _emailController?.dispose();
    _mobileController?.dispose();
    super.dispose();
  }

  Future<void> _updateUserInfo() async {
    print("asdfgasdfas");
    setState(() {
      _isLoading = true;
    });

    String newName = _nameController!.text.isNotEmpty ? _nameController!.text : _name;
    String newMobile = _mobileController!.text.isNotEmpty ? _mobileController!.text : _mobile;
    String image = _image;

    try {
      if(widget.type=="booking"){
        await APIs.updateMyInfo(newName, newMobile,image, widget.bookingID);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserBooking()),
        );
      }
      else{
        await APIs.updateMyInfo(newName, newMobile,image, widget.bookingID);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CustomerHomeScreen(initialIndex: 4,)),
        );
      }

    } catch (e) {
      print("Error: $e");
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Dismiss keyboard when tapping outside
      },
      child: Scaffold(
resizeToAvoidBottomInset: false,
backgroundColor: Colors.white,
        body: Stack(
          children: [
            Container(
              height: screenHeight * 0.14,
              decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/backofwork.png"),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
              child: Container(
                margin: EdgeInsets.only(left: 20, right: 20, top: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40, // Adjust according to your needs
                              height: 40, // Adjust according to your needs
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.0, // Adjust border width if needed
                                ),
                              ),
                              child: Center(
                                child: GestureDetector(
                                  onTap: (){
                                    Navigator.pop(context);
                                  },
                                  child: FaIcon(
                                    FontAwesomeIcons.arrowLeft, // Adjust icon as needed
                                    size: 20, // Adjust icon size as needed
                                    color: Colors.white, // Adjust icon color as needed
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 18,),
                            Text("Edit Profile",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w500
                              ),)
                          ],
                        ),
                        Row(
                          children: [

                            SizedBox(width: 13),
                            GestureDetector(
                              onTap: (){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                                );
                              },
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  APIs.me.image,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(_image),
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
                    SizedBox(height: 20),
                    Container(
                      height: 60,
                      width: screenWidth * 0.9,
                      padding: EdgeInsets.only(left: 20, right: 10),
                      decoration: BoxDecoration(
                        color: Colors.pink.shade200.withOpacity(0.3),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Center(
                        child: TextField(
                          controller: _nameController,
                          maxLines: 1,
                          decoration: InputDecoration(
                            hintText: "Name",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    Container(
                      height: 60,
                      width: screenWidth * 0.9,
                      padding: EdgeInsets.only(left: 20, right: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Center(
                        child: TextField(
                          controller: _emailController,
                          maxLines: 1,
                          enabled: false, // Set to false to make the TextField non-editable
                          decoration: InputDecoration(
                            hintText: "Email",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),


                    Container(
                      height: 60,
                      width: screenWidth * 0.9,
                      padding: EdgeInsets.only(left: 20, right: 10),
                      decoration: BoxDecoration(
                        color: Colors.pink.shade200.withOpacity(0.3),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Center(
                        child: TextField(
                          controller: _mobileController,
                          maxLines: 1,
                          decoration: InputDecoration(
                            hintText: "Mobile Number",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),

                    GestureDetector(
                      onTap: (){
                        _updateUserInfo();
                      },
                      child: Container(
                        height: 50,
                        margin: EdgeInsets.only(left: 20,right: 20),
                        decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/backofwork.png"),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(20))
                        ),
                        child: Center(child: Text('Save Changes',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 21
                          ),)),
                      ),
                    )
                  ],
                ),
              ),
            ),
            if (_isLoading||isUploading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                    child: Lottie.asset("assets/lottie/loading.json")
                ),
              ),
          ],
        ),
      ),
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


