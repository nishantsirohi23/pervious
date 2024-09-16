import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:perwork/screens/costumer/addwork.dart';
import 'package:perwork/screens/costumer/food/dishrestraunt.dart';
import 'package:perwork/screens/costumer/profession/viewprofile.dart';
import 'package:badges/badges.dart' as badges;
import 'package:perwork/try/productbottom.dart';
import 'package:shimmer/shimmer.dart';

import '../../../api/apis.dart';
import '../screens/costumer/restrauntscreen.dart';
import '../screens/itemdelivery.dart';
import 'itemcartcheckout.dart';


class SearchScreen extends StatefulWidget {



  SearchScreen();
  @override
  _SearchProfState createState() => _SearchProfState();
}


class _SearchProfState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  @override
  void initState() {
    super.initState();


    _searchController = TextEditingController(text: _searchText);
  }

  final Stream<QuerySnapshot> _usersStream =
  FirebaseFirestore.instance.collection('local_products').snapshots();
  final Stream<QuerySnapshot> _dishStream =
  FirebaseFirestore.instance.collection('dishes').snapshots();
  String _filterType = 'restraunts'; // Default filter typeFirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Container(
          width: screenWidth*0.7,
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

          Expanded(
            child: _buildContentForFilterType(),
          ),
        ],
      ),
      bottomNavigationBar: CartSummary2(),

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
        // Your content for hours filter type
        child:_searchText.isEmpty
            ? Center(
          child: Lottie.asset('assets/lottie/search.json'),
        )
            : StreamBuilder<QuerySnapshot>(
          stream: _dishStream,
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            // Filter documents based on search term
            final List<QueryDocumentSnapshot> filteredDocuments =
            snapshot.data!.docs.where((document) {
              final String name = document['name'] ?? '';
              final String searchTerm =
              _searchController.text.toLowerCase();

              return (name.toLowerCase().contains(searchTerm) );
              // You can add more conditions or use other search methods here as needed
            }).toList();

            if (filteredDocuments.isEmpty) {
              return Container(
                child: Column(
                  children: [
                    Lottie.asset("assets/lottie/restraunt.json"),

                  ],
                ),
              );
            }

            return ListView(
              children: filteredDocuments.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;

                return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>   DishRestraunt(dishId: data['id'],dishname: data['name'],)),
                      );
                    },
                    child: Container(
                      height: 80, // Increased height to accommodate content without overflow
                      padding: EdgeInsets.all(8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,// Align children to the top
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: data['image'], // URL of the image
                              width: 55,
                              height: 60,
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['name'],
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2, // Limit text to 2 lines to prevent overflow
                                  overflow: TextOverflow.ellipsis, // Add ellipsis when exceeding 2 lines
                                ),
                                SizedBox(height: 3), // Add some space between name and rating
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "See in all restraunts",
                                      style: TextStyle(
                                        color: Colors.pink.withOpacity(0.9),
                                        fontSize: 15,
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_ios,color: Colors.pink.withOpacity(0.9),size: 13,)
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                );
              }).toList(),
            );
          },
        )
    );
  }

  Widget _buildRestrauntsContainer() {
    return Container(
        margin: EdgeInsets.only(left:10),

        // Your content for hours filter type
        child: _searchText.isEmpty
            ? Center(
          child: Lottie.asset('assets/lottie/search.json'),
        )
            : StreamBuilder<QuerySnapshot>(
          stream: _usersStream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            final List<QueryDocumentSnapshot> filteredDocuments = snapshot.data!.docs.where((document) {
              final String name = document['name'] ?? '';
              final String username = document['name'] ?? '';
              final String collection = document['name'] ?? '';
              final String subcollection = document['name'] ?? '';
              final String searchTerm = _searchController.text.toLowerCase();

              return (name.toLowerCase().contains(searchTerm) ||
                  username.toLowerCase().contains(searchTerm) ||
                  collection.toLowerCase().contains(searchTerm) ||
                  subcollection.toLowerCase().contains(searchTerm));
              // You can add more conditions or use other search methods here as needed
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
                          MaterialPageRoute(builder: (context) => AddWork(companyName: "",)),
                        );
                        // Add your onTap functionality here
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

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
              ),
              itemCount: filteredDocuments.length,
              itemBuilder: (context, index) {
                var product = filteredDocuments[index];
                return GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) {
                        return ProductBottomSheet(
                          name: product['name'],
                          brand: product['name'],
                          itemId: product.id,
                          des: product['name'],
                          mrp: product['price'].toString(),
                          price: product['price'].toString(),
                          images: List<String>.from(product['image']),
                          flavor: "Flavor",
                        );
                      },
                    );
                  },
                  child: ProductItem(
                    discount: product['name'].toString(),
                    name: product['name'],
                    originalPrice: product['price'].toString(),
                    discountedPrice: product['price'].toString(),
                    imageUrl: product['imageUrl'],
                    itemId: product.id,
                  ),
                );
              },
            );
          },
        )

    );
  }

}
class CartSummary2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("users").doc(APIs.me.id).collection('item_cart').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final items = snapshot.data?.docs ?? [];

        if (items.isEmpty) {
          return SizedBox.shrink();
        }

        int totalQuantity = 0; // Initialize total quantity

        // Iterate over each document and sum up the quantities
        items.forEach((DocumentSnapshot itemDoc) {
          final itemData = itemDoc.data() as Map<String, dynamic>;
          int quantity = itemData['quantity'] ?? 0;
          totalQuantity += quantity;
        });

        return Container(
          padding: EdgeInsets.only(left: 12,right: 12),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [Container(
          height: 70,
            width: items.length>=3?130:items.length*52,
            padding: EdgeInsets.all(10.0),
            color: Colors.white,
            child: Stack(
              children: items.take(3).map((QueryDocumentSnapshot itemDoc) {
                final itemData = itemDoc.data() as Map<String, dynamic>;
                print(itemData);
                return Positioned(
                  left: items.indexOf(itemDoc) * 30.0,
                  child: Container(
                    width: 40, // Adjust width and height as needed
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(itemData['image'] ?? '',),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Text('Total Items: $totalQuantity'),

                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>   ItemCartCheckout()),
                  );
                  // Navigate to cart page or handle continue to cart action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                ),
                child: Row(
                  children: [
                    Text('Cart', style: TextStyle(color: Colors.white)),
                    SizedBox(width: 7,),
                    Icon(Icons.arrow_forward_ios,size: 14, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

