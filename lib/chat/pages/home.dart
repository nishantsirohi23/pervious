import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../api/apis.dart';
import '../../onboding/components/custom_sign_in_dialog.dart';
import '../model/message.dart';
import '../services/auth.dart';
import '../services/message.dart';
import '../theme/color.dart';
import '../widgets/chat_room_item.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/custom_textfield.dart';
import 'dart:io';

import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final String profid;
  const HomePage({Key? key, required this.profid}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TextEditingController _messageController;
  late MessageService service;
  bool _isLoading = false;
  String profName = "";
  String collectid = "";
  List<File> selectedFiles = [];

  late DateTime selectedDate = DateTime.now();
  late TimeOfDay selectedTime = TimeOfDay.now();
  bool isNegotiable = false;
  String selectedPriority = 'Normal';
  static FirebaseAuth auth = FirebaseAuth.instance;
  static User get user => auth.currentUser!;

  bool isLoading = false;
  bool filesUploadedSuccessfully = false;
  bool isUploading = false;
  String push_token = "";
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {service = MessageService(FirebaseAuth.instance);
    _messageController = TextEditingController();
    fetchProfDetails();
    super.initState();
  }

  @override
  dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // Function to fetch professional details
  fetchProfDetails() async {
    DocumentSnapshot snapshot =
    await FirebaseFirestore.instance.collection('users').doc(widget.profid).get();
    setState(() {
      profName = snapshot['name']; // Assuming the name field exists in the professional document
      push_token = snapshot['push_token'];
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      collectid = user!.uid.toString() + "_" + widget.profid;
    });
    if (APIs.me.type == 'others'||APIs.me.type=='delivery') {
      print(APIs.me.type);
      setState(() {
        collectid = widget.profid + "_" + user!.uid.toString();
      });
      print(collectid);
    }
    return Scaffold(
      backgroundColor: AppColor.appBgColor,
      appBar: _buildAppBar(),
      body: Padding(
        padding: EdgeInsets.only(bottom: 60),
        child: _buildChats(),
      ),
      floatingActionButton: _buildFooter(),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(profName), // Display professional name in the app bar title
    );
  }

  _buildChats() {
    return Container(
      height: MediaQuery.of(context).size.height*0.9,
      child: StreamBuilder<QuerySnapshot>(
        stream: service.loadStreamMessage(10, collectid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          APIs.MakeAllSeen(collectid);
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          });
          var data = snapshot.data!.docs;
          return ListView.builder(
            controller: _scrollController, // Add controller here
            itemBuilder: (context, index) {
              var msg = Message.fromJson(data[index].data() as Map<String, dynamic>);
              return ChatRoomItem(message: msg);
            },
            shrinkWrap: true,
            itemCount: data.length,
          );
        },
      ),
    );
  }

  _buildFooter() {
    return Container(
      padding: EdgeInsets.only(left: 15, right: 5),
      margin: EdgeInsets.only(bottom: 10,left: 5,right: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomTextField(
              controller: _messageController,
              hintText: "Write your message",
            ),
          ),
          IconButton(onPressed: _pickFiles, icon: Icon(Icons.image)),
          IconButton(
            onPressed: _isLoading || isUploading // Disable button when loading or uploading
                ? null
                : () {
              _sendMessage();
            },
            icon: _isLoading || isUploading // Show loading indicator if _isLoading or isUploading is true
                ? CircularProgressIndicator()
                : Icon(
              Icons.send_rounded,
              color: AppColor.primary,
              size: 35,
            ),
          )
        ],
      ),
    );
  }




  _sendMessage() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    var res = await service.sendMessage(_messageController.text, widget.profid);
    String name = APIs.me.name;
    if(user.uid!=widget.profid){
      print(push_token);
      APIs.sendPushNotification("New Message from $name",push_token,_messageController.text);
    }

    setState(() {
      _isLoading = false;
    });

    if (res.status) {
      _messageController.clear();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialogBox(
            title: "Chat",
            descriptions: res.message,
          );
        },
      );
    }
  }
  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'mp3', 'mp4'],
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
    setState(() {
      isUploading = true; // Set loading state to true while uploading
    });

    List<Map<String, String>> fileData = [];

    try {
      for (File file in files) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageReference = FirebaseStorage.instance.ref().child(fileName);
        UploadTask uploadTask = storageReference.putFile(file);

        // Listen to changes in the upload task
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          // Update your loading indicator or progress bar here if needed
        });

        // Await completion of the upload task
        await uploadTask.whenComplete(() async {
          String url = await storageReference.getDownloadURL();

          // Extract file extension
          String fileType = file.path.split('.').last;

          // Store file URL and type as a pair
          fileData.add({'url': url, 'type': fileType});
        });
      }

      setState(() {
        isUploading = false; // Set loading state to false after upload completion
      });
    } catch (e) {
      // Handle errors here
      setState(() {
        isUploading = false; // Ensure loading state is set to false in case of error
      });
      print("Error uploading files: $e");
    }

    // Call method to send image messages after all files are uploaded
    _sendImageMessages(fileData);
    return fileData;
  }


  Future<void> _sendImageMessages(List<Map<String, String>> fileData) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    for (Map<String, String> file in fileData) {
      String imageUrl = file['url']!;
      await service.sendImageMessage(imageUrl, widget.profid);
    }
    String name = APIs.me.name;
    if(user.uid!=widget.profid){
      print(push_token);
      APIs.sendPushNotification("New Message from $name",push_token,"Sent you an attachment");
    }

    setState(() {
      _isLoading = false;
    });
  }

}
