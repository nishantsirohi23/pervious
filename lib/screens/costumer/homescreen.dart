import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:perwork/api/apis.dart';
import 'package:http/http.dart' as http;

import 'package:perwork/screens/costumer/profession/hireapro.dart';
import 'package:perwork/screens/costumer/ultramain.dart';
import 'package:perwork/screens/intro.dart';
import 'package:perwork/screens/itemdelivery.dart';
import 'package:perwork/screens/userbooking.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/stores/CheckoutScreen.dart';
import '../../try/chatlist.dart';
import '../../try/itemmain.dart';
import '../../try/my_global.dart';
import '../../try/pigeon.dart';
import '../../try/shownotifications.dart';
import '../../utils/LocationService.dart';
import '../naviagtion_items/PostWorkContent.dart';
import '../profilescreen.dart';
import '../services/services.dart';
import 'ViewWorkContent.dart';
import 'food/foodcart.dart';

class CustomerHomeScreen extends StatefulWidget {
  final int initialIndex;

  CustomerHomeScreen({this.initialIndex = 0});

  @override
  _CustomerHomeScreenState createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  late int _selectedIndex;
  late PageController _pageController;
  bool isOpen = false;
  bool isLoading = true;
  bool isCartOpen = false;
  bool carttapclose = false;
  late LocationService _locationService;
  double _latitude = 0.0;
  double _longitude = 0.0;
  String _address = "";
  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=${Globals.apiKey}';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['status'] == 'OK') {
        setState(() {
          _address = data['results'][0]['formatted_address'];
          if(_address.contains('Meerut')){
            inboundornot = true;
          }
          else{
            inboundornot = false;
          }
        });
      } else {
        setState(() {
          _address = 'No address found';
        });
      }
    } else {
      setState(() {
        _address = 'Failed to fetch address';
      });
    }
    APIs.updatelatlonguser(_latitude,_longitude,_address);
    print(_address);
  }
  Future<void> _getCurrentLocation() async {
    Map<String, double> locationData = await _locationService.getCurrentLocation();
    setState(() {
      _latitude = locationData['latitude']!;
      _longitude = locationData['longitude']!;
    });

    _getAddressFromLatLng(_latitude, _longitude);
    print(_latitude);
    print(_longitude);
  }
  bool isWithinBounds(double lat, double lon, Map<String, double> bounds) {
    return lat <= bounds['north']! &&
        lat >= bounds['south']! &&
        lon <= bounds['east']! &&
        lon >= bounds['west']!;
  }
  bool tapclose = false;
  static List<Widget> _widgetOptions = <Widget>[
    UltraMain(),
    IntroMain(),
    hireapro(),
    Services(),
    UserInformation(filter: 'work',),
  ];
  Future<void> _removeFromCart(String storeId) async {
    var collection = FirebaseFirestore.instance.collection('carts').doc(APIs.me.id).collection(storeId);
    var snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
    try {
      await FirebaseFirestore.instance.collection('carts').doc(APIs.me.id).update({
        'total': FieldValue.increment(-1),
      });
      print('Total incremented successfully');
    } catch (e) {
      print('Error incrementing total: $e');
    }
    await FirebaseFirestore.instance.collection('carts').doc(APIs.me.id).update({
      'stores': FieldValue.arrayRemove([storeId])
    }).then((_) {
      print("Item removed from the list successfully!");
    }).catchError((error) {
      print("Failed to remove item from the list: $error");
    });


  }
  @override
  void initState() {
    super.initState();
    _locationService = LocationService();
    _getCurrentLocation();
    getdate();
    _checkCurrentLocation();
    listenToFoodCartDocumentCount();

    setState(() {
      carttapclose = false;
      tapclose  = false;
    });
    _selectedIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

  }
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  final Map<String, double> areaBounds = {
    'north': 29.0323,
    'south': 28.9086,
    'east': 77.8095,
    'west': 77.4544
  };
  Future<void> _checkCurrentLocation() async {


    bool withinBounds = isWithinBounds(
      _latitude,
      _longitude,
      areaBounds,
    );
    String _message = "";
    setState(() {

      _message = withinBounds ? "You're allowed" : "You're not allowed";
    });
    print("from check location");
    print(_message);
  }
  bool inboundornot =  true;
  int totalorder = 0;
  bool morethanone= false;
  int totalcart = 0;
  bool cartmorethanone = true;
  void getdate() {
    FirebaseFirestore.instance.collection('users').doc(APIs.me.id).snapshots().listen((DocumentSnapshot snapshot) {
      setState(() {
        totalorder = snapshot['totalorder'] ?? 0;
        print(totalorder);
        if(totalorder>1){
          setState(() {
            morethanone = true;
          });
        }
      });
    });
  }
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> _fetchStores() async* {
    // Listen to the cart document changes
    Stream<DocumentSnapshot> cartStream = _firestore.collection('carts').doc(APIs.me.id).snapshots();

    await for (DocumentSnapshot cartDoc in cartStream) {
      // Extract the list of store IDs
      List<dynamic> storeIds = cartDoc['stores'];

      // Fetch the store details for each store ID in real-time
      List<Map<String, dynamic>> stores = [];
      for (String storeId in storeIds) {
        DocumentSnapshot storeDoc = await _firestore.collection('stores').doc(storeId).get();
        if (storeDoc.exists) {
          stores.add(storeDoc.data() as Map<String, dynamic>);
        }
      }

      yield stores; // Emit the current list of stores
    }
  }
  Future<void> listenToFoodCartDocumentCount() async {
    final docRef = FirebaseFirestore.instance.collection('carts').doc(APIs.me.id);

    docRef.snapshots().listen(
          (DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          // Update the total variable with the new value
          final data = documentSnapshot.data() as Map<String, dynamic>?;

          // Update the total variable with the new value
          setState(() {
            totalcart = data?['total'] ?? 0;
          });
        } else {
          print('Document does not exist');
        }
      },
      onError: (error) {
        print('Error listening to document changes: $error');
      },
    );

    setState(() {
      isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return isLoading?CircularProgressIndicator():inboundornot ?  WillPopScope(
      onWillPop: () async {
        if (_pageController.page!.toInt() != 0) {
          // If not on the first page, navigate to the previous page
          _pageController.previousPage(
              duration: Duration(milliseconds: 600), curve: Curves.ease);
          return false; // Return false to prevent default behavior
        }
        return true; // Otherwise, allow default behavior
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              height: screenHeight*0.4,
              width: MediaQuery.of(context).size.width,
              color: Colors.black.withOpacity(isOpen ? 0.5 : 0.0),

            ),

            PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: _pageController,
              children: _widgetOptions,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),

            Visibility(
                visible: (totalorder!=0 &&_selectedIndex!=4&&_selectedIndex!=1&&_selectedIndex!=2&&tapclose==false),
                child: Stack(children: [

                  if (!isOpen&&morethanone)
                    Positioned(
                      bottom: 34,
                      left: 35,
                      right: 35,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isOpen = true;
                          });
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(vertical: 5),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.97),
                            border: Border.all(color: Colors.white,width: 0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "+ more",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Other widgets in the background
                  Positioned(
                    left: 15,
                    right: 15,
                    bottom: isOpen ? 17 : 17, // Adjust bottom margin based on isOpen state
                    child: GestureDetector(
                      onTap: () {

                      },
                      child: AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.elasticInOut,
                          width: MediaQuery.of(context).size.width,
                          height: isOpen ? totalorder * 70 : 60, // Adjust height based on isOpen state
                          child: Container(
                              color: Colors.transparent,
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance.collection('users').doc(APIs.me.id).collection('tracks').snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Center(child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Center(child: Text('Error: ${snapshot.error}'));
                                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                    return Container();
                                  } else {
                                    return ListView(
                                      physics: NeverScrollableScrollPhysics(),
                                      padding: EdgeInsets.zero,
                                      children: snapshot.data!.docs.map((doc) {
                                        final data = doc.data() as Map<String, dynamic>;

                                        return Container(
                                          height: 60,
                                          margin: EdgeInsets.only(bottom: 10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(color: Colors.grey.shade300.withOpacity(0.9)),
                                            borderRadius: BorderRadius.circular(13),
                                          ),
                                          padding: EdgeInsets.all(5),
                                          child: Row(
                                            children: [

                                              ClipRRect(
                                                borderRadius: BorderRadius.all(Radius.circular(35)),
                                                child: CachedNetworkImage(
                                                  fit: BoxFit.cover,
                                                  imageUrl: data['image'], // URL of the image
                                                  width: 48, // Double the radius to fit the CircleAvatar
                                                  height: 48, // Double the radius to fit the CircleAvatar
                                                  placeholder: (context, url) => Shimmer.fromColors(
                                                    baseColor: Colors.grey[300]!,
                                                    highlightColor: Colors.grey[100]!,
                                                    child: Container(
                                                      width: 84, // Double the radius to fit the CircleAvatar
                                                      height: 84, // Double the radius to fit the CircleAvatar
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                                ),
                                              ),
                                              SizedBox(width: 5,),
                                              Expanded(
                                                child: Text(data['name'],
                                                  overflow: TextOverflow.clip,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.w400
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10,),
                                              GestureDetector(
                                                onTap: () {
                                                  if (data['type'] == 'work') {
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(builder: (context) => CustomerHomeScreen(initialIndex: 4,)),
                                                    );
                                                  } else if (data['type'] == "booking") {
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(builder: (context) => UserBooking()),
                                                    );
                                                  } else {
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(builder: (context) => CustomerHomeScreen(initialIndex: 4,)),
                                                    );
                                                  }
                                                },
                                                child: Container(
                                                  height: 32,
                                                  width: 70,
                                                  decoration: BoxDecoration(
                                                      color: Colors.pink.withOpacity(0.9),
                                                      borderRadius: BorderRadius.all(Radius.circular(9))
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "Track",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 19
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 5,),
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    tapclose = true;
                                                  });
                                                },
                                                child: Container(
                                                  height: 23,
                                                  width: 23,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.grey.shade300.withOpacity(0.9),
                                                  ),
                                                  child: Icon(
                                                    Icons.close,
                                                    color: Colors.black,
                                                    size: 13,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  }
                                },
                              )

                          )
                      ),
                    ),
                  ),

                  // Cross button to close the container
                  if (isOpen)
                    Positioned(
                      right: MediaQuery.of(context).size.width/2-30,
                      bottom: totalorder * 70 +35,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isOpen = false;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.9),
                          ),
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),

                  // Container showing additional items when closed
                  if (!isOpen&&morethanone)
                    Positioned(
                      bottom: 55,
                      left: MediaQuery.of(context).size.width / 2-40,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isOpen = true;
                          });
                        },
                        child: Container(
                          width: 80,
                          margin: EdgeInsets.symmetric(vertical: 5),
                          padding: EdgeInsets.only(top: 3,bottom: 3,left: 10,right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300.withOpacity(0.8),width: 0.7),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "+$totalorder more",
                            style: TextStyle(
                              color: Colors.pink,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],)),
            Visibility(
                visible: (totalcart!=0 &&_selectedIndex==1&&carttapclose==false),
                child: Stack(children: [

                  if (!isCartOpen&&totalcart>1)
                    Positioned(
                      bottom: 34,
                      left: 35,
                      right: 35,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isCartOpen = true;
                          });
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(vertical: 5),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.97),
                            border: Border.all(color: Colors.white,width: 0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "+ more",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Other widgets in the background
                  Positioned(
                    left: 15,
                    right: 15,
                    bottom: isCartOpen ? 17 : 17, // Adjust bottom margin based on isOpen state
                    child: GestureDetector(
                      onTap: () {

                      },
                      child: AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.elasticInOut,
                          width: MediaQuery.of(context).size.width,
                          height: isCartOpen ? totalcart * 70 : 60, // Adjust height based on isOpen state
                          child: Container(
                              color: Colors.transparent,
                              child: StreamBuilder<List<Map<String, dynamic>>>(
                                stream: _fetchStores(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Center(child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Center(child: Text('Error: ${snapshot.error}'));
                                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                    return Center(child: Text('No stores found in the cart.'));
                                  } else {
                                    List<Map<String, dynamic>> stores = snapshot.data!;
                                    return ListView.builder(
                                      padding: EdgeInsets.zero,
                                      itemCount: stores.length,
                                      itemBuilder: (context, index) {
                                        var store = stores[index];
                                        return Container(
                                          height: 60,
                                          margin: EdgeInsets.only(bottom: 10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(color: Colors.grey.shade300.withOpacity(0.9)),
                                            borderRadius: BorderRadius.circular(13),
                                          ),
                                          padding: EdgeInsets.all(5),
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.all(Radius.circular(35)),
                                                child: CachedNetworkImage(
                                                  fit: BoxFit.cover,
                                                  imageUrl: store['imageUrl'], // URL of the image
                                                  width: 48, // Double the radius to fit the CircleAvatar
                                                  height: 48, // Double the radius to fit the CircleAvatar
                                                  placeholder: (context, url) => Shimmer.fromColors(
                                                    baseColor: Colors.grey[300]!,
                                                    highlightColor: Colors.grey[100]!,
                                                    child: Container(
                                                      width: 84, // Double the radius to fit the CircleAvatar
                                                      height: 84, // Double the radius to fit the CircleAvatar
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                                ),
                                              ),
                                              SizedBox(width: 5,),
                                              Expanded(
                                                child: Text(store['name'],
                                                  overflow: TextOverflow.clip,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.w400
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10,),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => CheckoutScreen(storeId: store['id'])),
                                                  );
                                                },
                                                child: Container(
                                                  height: 32,
                                                  width: 70,
                                                  decoration: BoxDecoration(
                                                      color: Colors.pink.withOpacity(0.9),
                                                      borderRadius: BorderRadius.all(Radius.circular(9))
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "Cart",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 19
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 5,),
                                              GestureDetector(
                                                onTap: () {
                                                  _removeFromCart(store['id']);
                                                },
                                                child: Container(
                                                  height: 23,
                                                  width: 23,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.grey.shade300.withOpacity(0.9),
                                                  ),
                                                  child: Icon(
                                                    Icons.close,
                                                    color: Colors.black,
                                                    size: 13,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  }
                                },
                              )

                          )
                      ),
                    ),
                  ),

                  // Cross button to close the container
                  if (isCartOpen)
                    Positioned(
                      right: MediaQuery.of(context).size.width/2-30,
                      bottom: totalcart * 70 +35,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isCartOpen = false;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.9),
                          ),
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),

                  // Container showing additional items when closed
                  if (!isCartOpen&&cartmorethanone)
                    Positioned(
                      bottom: 55,
                      left: MediaQuery.of(context).size.width / 2-40,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isCartOpen = true;
                          });
                        },
                        child: Container(
                          width: 80,
                          margin: EdgeInsets.symmetric(vertical: 5),
                          padding: EdgeInsets.only(top: 3,bottom: 3,left: 10,right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300.withOpacity(0.8),width: 0.7),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "+$totalcart more",
                            style: TextStyle(
                              color: Colors.pink,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],))


          ],
        ),
        bottomNavigationBar: SizedBox(
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Image.asset('assets/house.png', width: 24, height: 24),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Image.asset('assets/food.png', width: 24, height: 24),
                label: 'Food',
              ),
              BottomNavigationBarItem(
                icon: Image.asset('assets/items.png', width: 24, height: 24),
                label: 'Items',
              ),
              BottomNavigationBarItem(
                icon:
                Image.asset('assets/booking2.png', width: 24, height: 24),
                label: 'Booking',
              ),
              BottomNavigationBarItem(
                icon: Image.asset('assets/map.png', width: 24, height: 24),
                label: 'Track',
              ),
            ],
            currentIndex: _selectedIndex ?? 0, // Ensure _selectedIndex is not null
            selectedItemColor: Colors.blue,
            onTap: _onItemTapped,
          ),
        ),
      ),
    ) :Scaffold(

      body: Column(
        children: [
          Stack(
            children: [
              Container(
                  height: screenHeight * 0.3,
                  decoration: BoxDecoration(

                      borderRadius: BorderRadius.all(Radius.circular(35))),
                  child: Stack(
                    children: [
                      Container(
                        height: screenHeight*0.3,
                        width: MediaQuery.of(context).size.width,

                        decoration: BoxDecoration(

                            borderRadius:  BorderRadius.all(Radius.circular(35))
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(35))
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(35)),
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: 'https://firebasestorage.googleapis.com/v0/b/perwork.appspot.com/o/Perpenny%20your%20genei.png?alt=media&token=3e32656c-55b7-41f5-a7f3-4da111e7d7e2', // URL of the image
                              width: MediaQuery.of(context).size.width, // Double the radius to fit the CircleAvatar
                              height: screenHeight*0.22, // Double the radius to fit the CircleAvatar
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: 84, // Double the radius to fit the CircleAvatar
                                  height: 84, // Double the radius to fit the CircleAvatar
                                  color: Colors.white,
                                ),
                              ),
                              errorWidget: (context, url, error) => Icon(Icons.error),
                            ),

                          ),
                        ),
                      ),

                    ],
                  )
              ),
              Container(
                margin: EdgeInsets.only(left: 20,right: 20),
                child: Stack(
                  children: [


                    Container(
                      margin: EdgeInsets.only(top: screenHeight*0.053),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Welcome!",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenHeight*0.02

                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width*0.46,
                                child: Text(
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                  APIs.me.name,
                                  style: TextStyle(color: CupertinoColors.white, fontSize:  screenHeight*0.021),
                                ),
                              )
                            ],
                          ),
                          Row(
                            children: [

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
                              )
                            ],
                          )
                        ],
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[

                  Image.asset('assets/unavailable.png',height: 190,width: 190,),
                  SizedBox(height: 20),
                  Text(
                    'Services Unavailable',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.pink.shade400,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Some services may not be available in your area. The PerPenny team is working hard to offer all services through our app',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        inboundornot = true;
                      });
                      // Add functionality to contact support or retry
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink.shade400, // updated to use backgroundColor
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      )
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(index,
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    });
  }
}
