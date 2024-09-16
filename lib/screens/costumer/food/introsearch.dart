import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:perwork/screens/costumer/addwork.dart';
import 'package:perwork/screens/costumer/food/dishrestraunt.dart';
import 'package:perwork/screens/costumer/profession/viewprofile.dart';
import 'package:badges/badges.dart' as badges;
import 'package:shimmer/shimmer.dart';

import '../../../api/apis.dart';
import '../restrauntscreen.dart';
import 'CustomRestraunts.dart';

class IntroSearch extends StatefulWidget {
  final String searchText;
  final String filter;

  IntroSearch({required this.searchText, required this.filter});

  @override
  _IntroSearchState createState() => _IntroSearchState();
}

class _IntroSearchState extends State<IntroSearch> {
  TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  String _filterType = 'restraunts'; // Default filter type

  @override
  void initState() {
    super.initState();
    _searchText = widget.searchText;
    if (widget.filter.isNotEmpty) {
      _filterType = widget.filter;
    }
    _searchController = TextEditingController(text: _searchText);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Container(
          width: screenWidth * 0.7,
          padding: EdgeInsets.only(left: 20, right: 10),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: TextField(
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
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFilterOption('restraunts', 'Stores'),
              _buildFilterOption('dish', 'Products'),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: _buildContentForFilterType(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String type, String label) {
    return InkWell(
      onTap: () {
        setState(() {
          _filterType = type;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          border: _filterType == type
              ? Border(bottom: BorderSide(color: Colors.pink, width: 2))
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: _filterType == type ? Colors.pink : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildContentForFilterType() {
    if (_filterType == 'restraunts') {
      return _buildRestrauntsContainer();
    } else {
      return _buildDishesContainer();
    }
  }

  Widget _buildDishesContainer() {
    return Container(
      margin: EdgeInsets.only(left: 10),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('local_products').snapshots(),
        builder: (context, snapshot) {
          if (_searchController.text.isEmpty) {
            return Center(child: Text('Start typing to search for products'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No products found'));
          }

          // Filter the products based on the search text
          final List<QueryDocumentSnapshot> filteredDocuments = snapshot.data!.docs.where((document) {
            final String name = document['name'] ?? '';
            final String searchTerm = _searchController.text.toLowerCase();
            return name.toLowerCase().contains(searchTerm);
          }).toList();

          if (filteredDocuments.isEmpty) {
            return Center(child: Text('No products match your search criteria'));
          }

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.7,
            ),
            itemCount: filteredDocuments.length,
            itemBuilder: (context, index) {
              final product = filteredDocuments[index];
              final productData = product.data() as Map<String, dynamic>;
              final imageUrl = productData['imageUrl'] ?? '';
              final price = productData['price'] ?? 'No price';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RestrauntScreen(id: productData['storeId']),
                    ),
                  );
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              color: Colors.white,
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                        )
                            : Icon(Icons.image, size: 80), // Placeholder
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Price: $price',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }



  Widget _buildRestrauntsContainer() {
    return Container(
      margin: EdgeInsets.only(left: 10),
      child: _searchText.isEmpty
          ? Center(child: Lottie.asset('assets/lottie/search.json'))
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('stores').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final List<QueryDocumentSnapshot> filteredDocuments =
          snapshot.data!.docs.where((document) {
            final String name = document['name'] ?? '';
            final String searchTerm = _searchController.text.toLowerCase();
            return name.toLowerCase().contains(searchTerm);
          }).toList();

          if (filteredDocuments.isEmpty) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              padding: EdgeInsets.only(top: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Lottie.asset("assets/lottie/restraunt.json"),
                  SizedBox(height: 20),
                  Text(
                    "We offer custom restaurant delivery from any of your favorite restaurants",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(height: 15),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddWork(companyName: ""),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.pink,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        "Check Out",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView(
            children: filteredDocuments.map((document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RestrauntScreen(id: data['id']),
                    ),
                  );
                },
                child: Container(
                  height: 80,
                  padding: EdgeInsets.all(8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: data['imageUrl'],
                          width: 55,
                          height: 55,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 55,
                              height: 60,
                              color: Colors.white,
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['name'],
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 19,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 3),
                            Text(
                              "Rated ${data['rating']} stars",
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.7),
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
