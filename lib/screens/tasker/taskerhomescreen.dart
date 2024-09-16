import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:perwork/screens/maps/directionScreen.dart';
import 'package:perwork/screens/naviagtion_items/HomeScreenContent.dart';
import 'package:perwork/screens/profilescreen.dart';
import 'package:perwork/screens/tasker/showrequests.darrt.dart';
import 'package:perwork/screens/work/workerprofile.dart';
import 'package:badges/badges.dart' as badges;

import '../../api/apis.dart';
import '../../try/chatlist.dart';
import '../../try/shownotifications.dart';
import '../../utils/LocationService.dart';
import '../costumer/profession/hireapro.dart';
import '../naviagtion_items/PostWorkContent.dart';
import '../costumer/ViewWorkContent.dart';
import '../work/taskerWork.dart';
import '../work/taskerfood.dart';
import 'deliverhomescreen.dart';

class TaskerHomeScreen extends StatelessWidget {
  const TaskerHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const BottomNavigationBarExample(),
    );
  }
}

class BottomNavigationBarExample extends StatefulWidget {
  const BottomNavigationBarExample({Key? key}) : super(key: key);

  @override
  State<BottomNavigationBarExample> createState() =>
      _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState
    extends State<BottomNavigationBarExample> {
  int _selectedIndex = 0;
  bool isLoading = true;

  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  static List<Widget> _widgetOptions = <Widget>[
    APIs.me.type=='delivery'?DriverScreenContent():HomeScreenContent(),
    ShowRequests(),
    APIs.me.type=='delivery'?TaskerFood():TaskerWork()
  ];

  @override
  void initState() {
    super.initState();

    // Fetch user information when the widget is first created

    _loadUserData();
    getdate();


  }
  double _latitude = 0.0;
  double _longitude = 0.0;



  void _loadUserData() async {
    await APIs.getSelfInfo();
    setState(() {
      isLoading = false;
    });
  }

  void _onItemTapped(int index) {
    if (index < _widgetOptions.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }
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
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;



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
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Stack(
        children: [



          _widgetOptions.elementAt(_selectedIndex),





        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Request',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Works',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}


