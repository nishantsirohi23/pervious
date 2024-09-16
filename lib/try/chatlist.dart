import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:perwork/api/apis.dart';
import 'package:perwork/onboding/components/custom_sign_in_dialog.dart';
import 'package:shimmer/shimmer.dart';

import '../chat/pages/home.dart'; // Import your HomePage widget

class ChatList extends StatefulWidget {
  const ChatList({Key? key}) : super(key: key);

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final CollectionReference _usersCollection =
  FirebaseFirestore.instance.collection('users');
  bool isLoading  = false;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("Messages"),
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _getChatListStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                isLoading  = true;
                return Container();
              } else if (snapshot.hasError) {
                isLoading  = false;

                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                isLoading  = false;
                return Center(
                  child: Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.1),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Lottie.asset('assets/lottie/empty.json'),
                      ],
                    ),
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final chatId = snapshot.data!.docs[index]['chatId'];
                    print(chatId);

                    return FutureBuilder<DocumentSnapshot>(
                      future: _getUserDetailsFromChatId(chatId),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          isLoading  = true;
                          return Container();
                        } else if (userSnapshot.hasError) {
                          isLoading  = false;
                          return Text('Error: ${userSnapshot.error}');
                        } else if (!userSnapshot.hasData) {
                          isLoading  = false;
                          return Text('User not found.');
                        } else {
                          isLoading  = false;

                          final userData =
                          userSnapshot.data!.data() as Map<String, dynamic>;
                          final userName = userData['name'] ?? 'Unknown';
                          final userImage = userData['image'] ?? 'default_image_url';
                          final isOnline = userData['is_online'] ?? false;
                          final CollectionReference workCollection =
                          FirebaseFirestore.instance.collection('chat');

                          return StreamBuilder<DocumentSnapshot>(
                            stream: workCollection.doc(chatId).snapshots(),
                            builder: (context, workSnapshot) {
                              if (workSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                isLoading  = true;
                                return Container();
                              } else if (workSnapshot.hasError) {
                                isLoading  = false;

                                return Text('Error: ${workSnapshot.error}');
                              } else if (!workSnapshot.hasData) {
                                isLoading  = false;

                                return Text('Work not found.');
                              } else {
                                isLoading  = false;

                                final workData =
                                workSnapshot.data!.data() as Map<String, dynamic>;
                                bool unseenvisi = true;
                                final unseer = workData[APIs.me.id] ?? 'Unknown';
                                if (unseer == 0) {
                                  unseenvisi = false;
                                }
                                // Now you have both user details and work details, use them as needed
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HomePage(profid: userData['id']),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 10, right: 10,bottom: 13),
                                    padding: EdgeInsets.all(13),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(30.0),
                                      color: Colors.transparent,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.5),
                                          spreadRadius: 3,
                                          blurRadius: 5,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.all(Radius.circular(35)),
                                                  child: CachedNetworkImage(
                                                    fit: BoxFit.cover,
                                                    imageUrl: userImage, // URL of the image
                                                    width: 50, // Double the radius to fit the CircleAvatar
                                                    height: 50, // Double the radius to fit the CircleAvatar
                                                    placeholder: (context, url) => Shimmer.fromColors(
                                                      baseColor: Colors.grey[300]!,
                                                      highlightColor: Colors.grey[100]!,
                                                      child: Container(
                                                        width: 50, // Double the radius to fit the CircleAvatar
                                                        height: 50, // Double the radius to fit the CircleAvatar
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                                  ),
                                                ),

                                                SizedBox(width: 10),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      userName,
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 19,
                                                        fontWeight: FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            if (isOnline)
                                              Container(
                                                width: 12,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.green,
                                                ),
                                                margin: EdgeInsets.only(right: 20),
                                              ),
                                          ],
                                        ),
                                        Visibility(
                                          visible: unseenvisi,
                                          child: Text(
                                            unseer.toString() + " Unread Messages",
                                            style: TextStyle(color: Colors.blue),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        }
                      },
                    );
                  },
                );
              }
            },
          ),
          Visibility(
              visible: isLoading ,
              child: Container(
                margin: EdgeInsets.only(top: screenHeight*0.14),
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
              )
          )
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getChatListStream() {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .collection('chat_user')
        .snapshots();
  }

  Future<DocumentSnapshot> _getUserDetailsFromChatId(String chatId) async {
    String userId = "";
    if (APIs.me.type == "delivery"||APIs.me.type=='others') {
      userId = chatId.split('_').first;
    } else {
      userId = chatId.split('_').last;
    }
    return await _usersCollection.doc(userId).get();
  }
}

