import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _scrollTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_scrollController.hasClients) {
        final maxScrollExtent = _scrollController.position.maxScrollExtent.toDouble();
        final currentScrollPosition = _scrollController.position.pixels.toDouble();
        final targetPosition = currentScrollPosition < maxScrollExtent ? currentScrollPosition + 200.0 : 0.0;
        _scrollController.animateTo(
          targetPosition,
          duration: Duration(seconds: 2),
          curve: Curves.easeInOut,
        );
      }
    });
  }



  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('PerPenny Scrolling List'),
      ),
      body: Container(
        height: 180,
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('examples').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              var items = snapshot.data!.docs.map((doc) {
                return {
                  'name': doc['name'],
                  'title': doc['title'],
                  'image': doc['image'],
                };
              }).toList();

              return ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  var item = items[index];
                  return Container(
                    padding: EdgeInsets.only(left: 10,right: 5,top: 7,bottom: 5),
                    width: screenWidth*0.75,
                    height: 1900,
                    margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Image.network(item['image']),
                            Column(
                              children: [Text(item['title'])],
                            )
                          ],
                        )
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
