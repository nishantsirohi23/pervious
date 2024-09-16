import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:perwork/screens/costumer/profession/viewprofile.dart';
import 'package:badges/badges.dart' as badges;
import 'package:shimmer/shimmer.dart';

import '../../../api/apis.dart';


class SearchProf extends StatefulWidget {
  final String searchText;

  SearchProf({required this.searchText});
  @override
  _SearchProfState createState() => _SearchProfState();
}

class _SearchProfState extends State<SearchProf> {
  TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  int nnotibooking = 0;
  int nnotiwork = 0;
  void getdate() async{
    final DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance.collection('users').doc(APIs.me.id).get();
    nnotibooking = profileSnapshot['nnotibooking'];
    nnotiwork = profileSnapshot['nnotiwork'];


  }
  @override
  void initState() {
    super.initState();
    getdate();
    _searchText = widget.searchText;
    _searchController = TextEditingController(text: _searchText);
  }
  final Stream<QuerySnapshot> _usersStream =
  FirebaseFirestore.instance.collection('prof').snapshots();

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Container(
            width: screenWidth * 0.9,
            padding: EdgeInsets.only(left: 20, right: 10),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),child:
        TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchText = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none, // Remove bottom line
            suffixIcon: _searchText.isNotEmpty
                ? IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchText = '';
                });
              },
            )
                : IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _searchText = _searchController.text;
                });
              },
            ),
          ),
        )

        )
        ,

      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          final searchTerm = _searchController.text.toLowerCase();

          if (searchTerm.isEmpty) {
            // Show a message to start searching when the search text is empty
            return Center(
              child: Lottie.asset('assets/lottie/search.json'),
            );
          }

          // Filter documents based on search term
          final List<QueryDocumentSnapshot> filteredDocuments = snapshot.data!.docs.where((document) {
            final String name = document['name'] ?? '';
            final String username = document['username'] ?? '';
            final List<dynamic> specs = document['specialities'] ?? '';

            return (name.toLowerCase().contains(searchTerm) ||
                username.toLowerCase().contains(searchTerm) ||
                specs.any((spec) => spec.toString().toLowerCase().contains(searchTerm)));
            // You can add more conditions or use other search methods here as needed
          }).toList();

          if (filteredDocuments.isEmpty) {
            return Center(
              child: Lottie.asset('assets/lottie/empty.json'),
            );
          }
          return ListView(
            children: filteredDocuments.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              var listspecs = data['specialities'] as List<dynamic>;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => viewProfile(profid: data['id'])),
                  );
                },
                child: Container(
                  width: screenWidth*0.55,
                  margin: EdgeInsets.only(top: 12, bottom: 10, left: 18, right: 15),
                  padding: EdgeInsets.only(bottom: 7),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 12,right: 10,top: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.all(Radius.circular(100)),
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl: data['profile_image_url'], // URL of the image
                                    width: MediaQuery.of(context).size.width*0.16, // Double the radius to fit the CircleAvatar
                                    height: MediaQuery.of(context).size.width*0.16, // Double the radius to fit the CircleAvatar
                                    placeholder: (context, url) => Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
                                        width: MediaQuery.of(context).size.width*0.16, // Double the radius to fit the CircleAvatar
                                        height: MediaQuery.of(context).size.width*0.16, // Double the radius to fit the CircleAvatar
                                        color: Colors.white,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                  ),
                                ),

                                SizedBox(width: 10,),
                                Container(
                                  width: screenWidth*0.315,
                                  child: Column(
                                    children: [
                                      Container(
                                        width: screenWidth*0.315,
                                        child: Text(
                                          data['name'],
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                            fontSize: screenWidth*0.05,
                                            overflow: TextOverflow.ellipsis, // or TextOverflow.ellipsis, etc.
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: screenWidth*0.315,
                                        child: Text(
                                          data['username'],
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,
                                            fontSize: screenWidth*0.039,
                                            overflow: TextOverflow.ellipsis, // or TextOverflow.ellipsis, etc.
                                          ),
                                        ),
                                      ),

                                    ],
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(left: 18,right: 10),
                                  child: Row(
                                    children: [
                                      Image.asset("assets/expertise.png",width: screenWidth*0.06,height: screenWidth*0.06,),
                                      Text("Experience",
                                        style: TextStyle(
                                            color: Colors.black.withOpacity(0.5),
                                            fontWeight: FontWeight.w400,
                                            fontSize: screenWidth*0.04
                                        ),)
                                    ],
                                  ),
                                ),
                                SizedBox(height: 7,),
                                Container(
                                  margin: EdgeInsets.only(left: 20),
                                  child: Text(data['experience'],
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 17
                                    ),),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 10,),
                      Container(
                        margin: EdgeInsets.only(left: 18,right: 10),
                        child: Row(
                          children: [
                            Image.asset("assets/idea.png",width: 30,height: 30,),
                            Text("Specialities",
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.5),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15
                              ),)
                          ],
                        ),
                      ),
                      SizedBox(height: 7,),

                      Container(
                        height: 25,
                        margin: EdgeInsets.only(left: 20,right: 10),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: listspecs.map((spec) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Container(
                                  padding: EdgeInsets.only(left: 7,right: 7,top: 3,bottom: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Center(
                                    child: Text(
                                      spec,
                                      style: TextStyle(fontSize: 14, color: Colors.white),
                                    ),
                                  ),

                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      SizedBox(height: 7,),
                      Container(
                        margin: EdgeInsets.only(left: 18,right: 10),
                        child: Row(
                          children: [
                            Image.asset("assets/star.png",width: 30,height: 30,),
                            Text("Ratings",
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.5),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15
                              ),)
                          ],
                        ),
                      ),
                      SizedBox(height: 2,),
                      Container(
                          margin: EdgeInsets.only(left: 20),
                          child: Row(
                            children: [
                              Text(data['rating']+" star",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17
                                ),),
                              Text("("+data['totalrating']+")",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17
                                ),),
                              SizedBox(width: 10,),
                              Container(

                                child: StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance.collection('prof').doc(data['id']).collection('reviews').snapshots(),
                                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> playerSnapshot) {
                                    if (playerSnapshot.hasError) {
                                      return Text('Something went wrong');
                                    }

                                    if (playerSnapshot.connectionState == ConnectionState.waiting) {
                                      return Text("Loading");
                                    }

                                    List<DocumentSnapshot> playerDocs = playerSnapshot.data!.docs;

                                    int displayCount = playerDocs.length > 3 ? 3 : playerDocs.length;

                                    return Row(
                                      children: List.generate(displayCount, (index) {
                                        Map<String, dynamic> playerData = playerDocs[index].data() as Map<String, dynamic>;
                                        String userId = playerData['userId'];

                                        return StreamBuilder<DocumentSnapshot>(
                                          stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
                                          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                                            if (userSnapshot.hasError) {
                                              return Text('Something went wrong');
                                            }

                                            if (userSnapshot.connectionState == ConnectionState.waiting) {
                                              return CircularProgressIndicator(); // Or any other loading indicator
                                            }

                                            Map<String, dynamic> userData = userSnapshot.data!.data() as Map<String, dynamic>;
                                            String imageUrl = userData['image'];

                                            return Container(
                                              width: 35.0,
                                              height: 35.0,
                                              decoration: BoxDecoration(
                                                color: const Color(0xff7c94b6),
                                                image: DecorationImage(
                                                  image: NetworkImage(imageUrl),
                                                  fit: BoxFit.cover,
                                                ),
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 2.0,
                                                ),
                                                borderRadius: BorderRadius.all(Radius.circular(50.0)),
                                              ),
                                            );
                                          },
                                        );
                                      }),
                                    );
                                  },
                                ),
                                //show here the images of users which have posted the reviews
                              )
                            ],
                          )
                      ),

                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      )
      ,
    );
  }

  Query _buildSearchQuery() {
    var collection = FirebaseFirestore.instance.collection('prof');
    if (_searchText.isEmpty) {
      return collection;
    } else {
      return collection.where('specs', arrayContains: _searchText);
      // You can add more conditions or use other search methods here as needed
    }
  }
  Widget dialogContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.0),
      ),
      padding: EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Dialog Content',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.0),
          Text(
            'This is the content of the dialog box.',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}


