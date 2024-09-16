
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:perwork/screens/costumer/showmywork.dart';
import 'package:perwork/screens/costumer/showmywork/showbookride.dart';
import 'package:perwork/screens/maps/TrackFood.dart';
import 'package:perwork/screens/maps/directionScreen.dart';
import 'package:perwork/tree/WorkTree.dart';
import 'package:shimmer/shimmer.dart';

import '../../api/apis.dart';
import '../../try/billsummary.dart';
import '../../try/chatlist.dart';
import '../../try/shownotifications.dart';
import '../maps/trackitem.dart';
import '../profilescreen.dart';
import '../userbooking.dart';
import '../work/trackworkscreen.dart';
import 'package:badges/badges.dart' as badges;


class UserInformation extends StatefulWidget {
  final String filter;

  UserInformation({required this.filter});

  @override
  _UserInformationState createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {
  final Stream<QuerySnapshot> _usersStream =
  FirebaseFirestore.instance.collection('work').snapshots();
  final Stream<QuerySnapshot> _foodStream =
  FirebaseFirestore.instance.collection('orders').snapshots();
  static FirebaseAuth auth = FirebaseAuth.instance;
  static User get user => auth.currentUser!;
  bool isLoading = false;
  int nnotibooking = 0;
  int nnotiwork = 0;
  int nmessage = 0;

  void getdate() {
    FirebaseFirestore.instance.collection('users').doc(APIs.me.id).snapshots().listen((DocumentSnapshot snapshot) {
      setState(() {
        nnotibooking = snapshot['nnotibooking'] ?? 0;
        nnotiwork = snapshot['nnotiwork'] ?? 0;
        nmessage = snapshot['nmessage'] ?? 0;

      });
    });
  }
  String _filterType = ""; // Default filter typeFirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    getdate();
    _filterType = widget.filter;

  }



  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double bottomNavBarHeight = kBottomNavigationBarHeight;
    double screenHeight = MediaQuery.of(context).size.height;
    print(screenHeight);
    screenHeight = screenHeight-bottomNavBarHeight;
    print(screenHeight);

    String getGreeting() {
      var hour = DateTime.now().hour;
      if (hour < 12) {
        return 'Morning';
      } else if (hour < 17) {
        return 'Afternoon';
      } else {
        return 'Evening';
      }
    }
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Column(

              children: [
                Container(
                  height: screenHeight * 0.14,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/backappbar1.png"),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
                  child: Container(
                    margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${getGreeting()}!",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenHeight*0.02

                                  ),
                                ),
                                Text(
                                  "Track Work",
                                  style: TextStyle(color: CupertinoColors.white, fontSize:  screenHeight*0.021),
                                )
                              ],
                            ),
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
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => ChatList()),
                                        );
                                      },
                                      child: Center(
                                          child: badges.Badge(
                                            showBadge: ((nmessage)!=0) ? true : false,
                                            position: badges.BadgePosition.topEnd(top: -13, end: -15),
                                            badgeContent: Text((nmessage).toString(),style: TextStyle(color: Colors.white),),
                                            child: FaIcon(
                                              FontAwesomeIcons.message, // Adjust icon as needed
                                              size: 20, // Adjust icon size as needed
                                              color: Colors.white, // Adjust icon color as needed
                                            ),
                                          )
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 13,),
                                GestureDetector(
                                  onTap: (){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ShowNotifications()),
                                    );
                                  },
                                  child: Container(
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
                                        child: badges.Badge(
                                          showBadge: ((nnotiwork+nnotibooking)!=0) ? true : false,
                                          position: badges.BadgePosition.topEnd(top: -13, end: -15),
                                          badgeContent: Text((nnotiwork+nnotibooking).toString(),style: TextStyle(color: Colors.white),),
                                          child: FaIcon(
                                            FontAwesomeIcons.bell, // Adjust icon as needed
                                            size: 20, // Adjust icon size as needed
                                            color: Colors.white, // Adjust icon color as needed
                                          ),
                                        )
                                    ),
                                  ),
                                ),
                                SizedBox(width: 13),
                                GestureDetector(
                                    onTap: (){
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ProfileScreen()),
                                      );
                                    },
                                    child:  ClipRRect(
                                      borderRadius: BorderRadius.all(Radius.circular(35)),
                                      child: CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        imageUrl: APIs.me.image, // URL of the image
                                        width: 40, // Double the radius to fit the CircleAvatar
                                        height: 40, // Double the radius to fit the CircleAvatar
                                        placeholder: (context, url) => Shimmer.fromColors(
                                          baseColor: Colors.grey[300]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Container(
                                            width: 80, // Double the radius to fit the CircleAvatar
                                            height: 80, // Double the radius to fit the CircleAvatar
                                            color: Colors.white,
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => Icon(Icons.error),
                                      ),
                                    )
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                _filterType = 'food';
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 5), // Adjust as needed
                              decoration: BoxDecoration(
                                border: _filterType == 'food'
                                    ? Border(bottom: BorderSide(color: Colors.blue, width: 2)) // Add underline when selected
                                    : null,
                              ),
                              child: Text(
                                'Food',
                                style: TextStyle(
                                  color: _filterType == 'food' ? Colors.blue : null, // Maintain color
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _filterType = 'work';
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 5), // Adjust as needed
                              decoration: BoxDecoration(
                                border: _filterType == 'work'
                                    ? Border(bottom: BorderSide(color: Colors.blue, width: 2)) // Add underline when selected
                                    : null,
                              ),
                              child: Text(
                                'Work',
                                style: TextStyle(
                                  color: _filterType == 'work' ? Colors.blue : null, // Maintain color
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: _buildContentForFilterType(),
                      ),
                    ],
                  ),
                ),


              ],
            ),
            Visibility(
                visible: isLoading ,
                child: Container(
                  height: screenHeight,
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
        )
    );
  }
  Widget _buildContentForFilterType() {
    if (_filterType == 'food') {
      return _buildFoodContainer();
    } else {
      return _buildWorkContainer();
    }
  }

  Widget _buildFoodContainer() {
    return Container(
      // Your content for hours filter type
      child: StreamBuilder<QuerySnapshot>(
        stream: _foodStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Container();
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return  Container(
              height: MediaQuery.of(context).size.height*0.86,
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
            );
          }

          // Filter documents based on search term
          final List<QueryDocumentSnapshot> filteredDocuments =
          snapshot.data!.docs.toList();

          // Filtered list of documents where userId matches user.uid
          final List<QueryDocumentSnapshot<Map<String, dynamic>>> userBookings = filteredDocuments
              .cast<QueryDocumentSnapshot<Map<String, dynamic>>>()
              .where((doc) => doc['orderBy'] == APIs.me.id  && doc['status']!="completed")
              .toList();
          // Sort the user bookings based on the 'createdAt' field
          userBookings.sort((a, b) {
            // Convert 'createdAt' field from string to integer
            int aCreatedAt = int.parse(a['createdAt']);
            int bCreatedAt = int.parse(b['createdAt']);
            // Compare the integers to sort in descending order
            return bCreatedAt.compareTo(aCreatedAt);
          });

          if (userBookings.isEmpty) {
            return Center(
              child: Container(


                alignment: Alignment.center,
                child: Column(
                  children: [
                    Lottie.asset('assets/lottie/empty.json'),

                  ],
                ),
              ),
            );
          }




          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(top: 10),
                  scrollDirection: Axis.vertical,
                  itemCount: userBookings.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot document = userBookings[index];
                    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                    if (data.containsKey('storename')) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TrackItem(
                                destlat: data['destlat'],
                                destlong: data['destlong'],
                                sourcelat: data['sourcelat'],
                                sourcelong: data['sourcelong'],
                                orderId: document.id,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(3),
                          margin: EdgeInsets.only(left: 15, right: 10, top: 5, bottom: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3),
                              ),
                            ],
                            color: Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Iterate over the items subcollection
                              FutureBuilder<QuerySnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('orders')
                                    .doc(document.id)
                                    .collection('items')
                                    .get(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  }
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  }

                                  // Extract item documents from the subcollection
                                  final List<QueryDocumentSnapshot> itemDocs = snapshot.data!.docs;
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: itemDocs.map((itemDoc) {
                                      final Map<String, dynamic> itemData = itemDoc.data()! as Map<String, dynamic>;
                                      return Container(
                                        margin: EdgeInsets.only(bottom: 5,top: 5),
                                        child:
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [

                                            Image.network(itemData['image'],height: 30,width: 30,),
                                            SizedBox(width: 8,),
                                            Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(itemData['quantity'].toString(),style: TextStyle(
                                                        fontSize: 18
                                                    ),),
                                                    Text(" x ",style: TextStyle(
                                                        fontSize: 17
                                                    )),
                                                    Container(
                                                      width: MediaQuery.of(context).size.width*0.7,
                                                      child: Text('${itemData['name']}',
                                                          maxLines: 1,
                                                          overflow: TextOverflow.clip,                                                        style: TextStyle(
                                                              fontSize: 17
                                                          )),
                                                    )
                                                  ],
                                                ),

                                              ],
                                            ),
                                            Divider(), // Add a divider between items
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    else{
                      List<Map<String, dynamic>> dishesData = (data['dishes'] as List<dynamic>).cast<Map<String, dynamic>>();

                      return GestureDetector(
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TrackFood(destlat: data['destlong'], destlong:data['destlat'] , sourcelat: data['sourcelat'], sourcelong: data['sourcelong'], orderId: data['id'])),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 15, right: 10, top: 5, bottom: 5), // Adjust margins here
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3),
                              ),
                            ],
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: 60,
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                      ),
                                      margin: EdgeInsets.only(right: 12),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                        child: CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          imageUrl: data['restimage'], // URL of the image
                                          width: 60,
                                          height: 60,
                                          placeholder: (context, url) => Shimmer.fromColors(
                                            baseColor: Colors.grey[200]!,
                                            highlightColor: Colors.grey[100]!,
                                            child: Container(
                                              width: 84,
                                              height: 60,
                                              color: Colors.white,
                                            ),
                                          ),
                                          errorWidget: (context, url, error) => Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                    Expanded(child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(data['restname'],maxLines: 1,overflow: TextOverflow.clip,style: TextStyle(fontSize: 17),),
                                        Text(data['restaddress'],maxLines: 1,overflow: TextOverflow.clip,style: TextStyle(fontSize: 16))
                                      ],
                                    ),),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.asset('assets/rupee.png',height: 25,width: 25,),
                                        Text("₹"+data['orderamount'].toString())
                                      ],
                                    ),
                                    SizedBox(width: 20,)
                                  ],
                                ),
                              ),
                              SizedBox(height: 6,),
                              DashedLine(height: 1, color: Colors.grey),
                              Container(
                                padding: EdgeInsets.only(top: 4),
                                height:dishesData.length*35,
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: dishesData.length,
                                  itemBuilder: (context, index) {
                                    final dish = dishesData[index];
                                    return Container(
                                      child: Row(
                                        children: [
                                          Image.network(
                                            dish['image'],
                                            width: 30,
                                            height: 30,
                                            fit: BoxFit.cover,
                                          ),
                                          SizedBox(width: 5),
                                          Text(dish['quantity'].toString()+" x "),
                                          Expanded(
                                            child: Text(
                                              dish['name'],
                                              maxLines: 1,
                                              overflow: TextOverflow.clip,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )
                            ],
                          ),

                        ),
                      );
                    }

                  },
                ),
              ),
            ],
          );


        },
      ),
    );
  }

  Widget _buildWorkContainer() {
    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Container();
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return  Container(
              height: MediaQuery.of(context).size.height*0.86,
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
            );
          }

          var documents = snapshot.data!.docs.where((document) => document['workBy'] == user.uid && document['status'] != 'completed').toList();
          documents.sort((a, b) {
            // Parse 'created_at' string value to integers
            int aCreatedAt = int.parse(a['created_at']);
            int bCreatedAt = int.parse(b['created_at']);
            // Compare integers to sort in descending order
            return bCreatedAt.compareTo(aCreatedAt);
          });

          if (documents.isEmpty) {
            return Center(
              child: Container(


                alignment: Alignment.center,
                child: Column(
                  children: [
                    Lottie.asset('assets/lottie/empty.json'),

                  ],
                ),
              ),
            );
          } else {
            return Container(
              height: MediaQuery.of(context).size.height*0.8-MediaQuery.of(context).size.height*0.02,


              child: ListView.builder(
                padding: EdgeInsets.only(top: 5),
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> data = documents[index].data()! as Map<String, dynamic>;

                  // Determine background color based on priority

                  String status = data['status'] ?? '';
                  bool isNego = data['negotiable'] ?? '';
                  String type = "Fixed";
                  if (isNego==true){
                    type = "Negotiable";

                  }
                  String workImage = "";
                  List<Map<String, dynamic>> fileData = (data['fileData'] ?? [])?.cast<Map<String, dynamic>>() ?? [];

                  if (fileData.isEmpty) {
                    workImage = "https://cdn.dribbble.com/userupload/3640939/file/original-669699737952c579e1adf2dfa11652fa.jpeg?resize=2048x1152";
                  } else {
                    for (var file in fileData) {
                      String type = file['type']; // Assuming 'type' holds the file type information
                      if (type == 'jpeg' || type == 'png' || type == 'jpg') {
                        workImage = file['url']; // Assuming 'url' holds the URL of the image
                        break; // Break once the first image is found
                      }
                    }
                  }
                  double workamount = data['amount'];
                  if(status=='track'){
                    workamount = data['finalamount'];
                  }
// At this point, workImage will either be set to the default URL or the URL of the first image of type jpeg, png, or jpg.
                  double loadwidth = 0.0;
                  if (status=="process"){
                    loadwidth = MediaQuery.of(context).size.width*0.2;
                  }
                  if (status=="track"){
                    loadwidth = MediaQuery.of(context).size.width*0.6;
                  }
                  if (status=="posted"){
                    loadwidth = MediaQuery.of(context).size.width*0.4;
                  }
                  if (status == "completed") {
                    return SizedBox.shrink(); // Skip rendering the container if status is "paydone"
                  }


                  return GestureDetector(
                    onTap: () {
                      workTreeNavigator(context, data);



                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 15,right: 10,bottom: 5,top: 5),
                      padding: EdgeInsets.all(10),
                      height: data['amount']==0.0?MediaQuery.of(context).size.height*0.18:MediaQuery.of(context).size.height*0.22,
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
                      child: Center(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.all(Radius.circular(35)),
                                    child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: workImage, // URL of the image
                                      width: MediaQuery.of(context).size.width*0.14, // Double the radius to fit the CircleAvatar
                                      height: MediaQuery.of(context).size.width*0.14, // Double the radius to fit the CircleAvatar
                                      placeholder: (context, url) => Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          width: MediaQuery.of(context).size.width*0.14, // Double the radius to fit the CircleAvatar
                                          height: MediaQuery.of(context).size.width*0.14, // Double the radius to fit the CircleAvatar
                                          color: Colors.white,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                    ),
                                  ),
                                  SizedBox(width: MediaQuery.of(context).size.width*0.02,),
                                  Column(
                                    children: [
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width*0.7,
                                        child: Text(
                                          data['name'],
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 19
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.clip,
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              SizedBox(height: 5,),

                              Visibility(
                                visible: data['amount']!=0.0,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(width: MediaQuery.of(context).size.width*0.01,),
                                        Image.asset("assets/rupee.png",height: MediaQuery.of(context).size.width*0.08,width: MediaQuery.of(context).size.width*0.08,),
                                        SizedBox(width: MediaQuery.of(context).size.width*0.01,),
                                        Text("₹"+workamount.toString(),style: TextStyle(
                                            color: Colors.black
                                        ),),
                                      ],
                                    ),
                                    SizedBox(height: 5,),
                                  ],
                                ),),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Container(
                                      height: MediaQuery.of(context).size.height*0.038,
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Center(
                                        child: Text(
                                          data['prof'],
                                          style: TextStyle(fontSize: 15, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Container(
                                      height: MediaQuery.of(context).size.height*0.038,
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Center(
                                        child: Row(
                                          children: [

                                            Text(
                                              data['priority'],
                                              style: TextStyle(fontSize: 15, color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Container(
                                      height: MediaQuery.of(context).size.height*0.038,
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Center(
                                        child: Text(
                                          type,
                                          style: TextStyle(fontSize: 15, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: MediaQuery.of(context).size.height*0.01,),
                              Center(
                                child: Container(
                                  height: 20,
                                  width: MediaQuery.of(context).size.width*0.8,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Stack(
                                    children: <Widget>[
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),

                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          width: loadwidth, // Change this value to change the progress
                                        ),
                                      ),

                                    ],
                                  ),
                                ),
                              )



                            ],
                          )
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}

class DashedLine extends StatelessWidget {
  final double height;
  final Color color;

  const DashedLine({Key? key, this.height = 1, this.color = Colors.black}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: _DashedLinePainter(color),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;

  _DashedLinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    final double dashWidth = 5;
    final double dashSpace = 5;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

