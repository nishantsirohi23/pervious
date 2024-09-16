import 'dart:ffi';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perwork/screens/intro.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../api/apis.dart';
import '../models/itemcart.dart';
import '../try/itemcartcheckout.dart';
import '../try/itemsearchscreen.dart';
import '../try/productbottom.dart';
import '../widgets/work/spotlightrestraunts.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

class ItemDelivery extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  ItemDelivery({required this.categoryId, required this.categoryName});

  @override
  _ItemDeliveryState createState() => _ItemDeliveryState();
}

class _ItemDeliveryState extends State<ItemDelivery> {
  String? selectedSubcategory;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.categoryName),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchScreen()),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              height: 130,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('categories')
                    .doc(widget.categoryId)
                    .collection('sub')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  var categories = snapshot.data!.docs;
                  var screenWidth = MediaQuery.of(context).size.width;
                  var screenHeight = MediaQuery.of(context).size.height;
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      var category = categories[index];
                      bool isSelected =
                          selectedSubcategory == category['name'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedSubcategory = category['name'];
                          });
                        },
                        child: Container(
                          width: screenWidth * 0.25,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(18.0),
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
                                height: screenHeight * 0.1,
                                width: screenWidth * 0.25,
                                padding: EdgeInsets.all(14),
                                child: ClipRRect(
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl: category['image'], // URL of the image
                                    placeholder: (context, url) => Shimmer.fromColors(
                                      baseColor: Colors.grey[100]!,
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
                              Container(
                                width: screenWidth * 0.2,
                                child: Text(category['name'],textAlign: TextAlign.center,maxLines: 2,overflow: TextOverflow.clip,),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('products').where("collection",isEqualTo: widget.categoryName).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  // Filter products to only include those with the selected subcategory
                  var products = snapshot.data!.docs.where((doc) {
                    if (selectedSubcategory == null) {
                      return true; // Show all products if no subcategory selected
                    } else {
                      return doc['subcollection'] == selectedSubcategory;
                    }
                  }).toList();

                  if (products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No items Currently',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 8), // Adding some spacing
                          Text(
                            'We are constantly adding new products!',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Text(
                            'Check back again soon to see what\'s new.',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                    ;
                  }

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      var product = products[index];
                      return GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              return ProductBottomSheet(
                                name: product['name'],
                                brand: product['description'],
                                itemId: product.id,
                                mrp: product['price'].toString(),
                                des: product['des'],
                                price: product['disprice'].toString(),
                                images: List<String>.from(product['image']),
                                flavor: "Flavor",
                              );
                            },
                          );
                        },
                        child: ProductItem(
                          discount: product['discount'].toString(),
                          name: product['name'],
                          originalPrice: product['price'].toString(),
                          discountedPrice: product['disprice'].toString(),
                          imageUrl: product['image'][0],
                          itemId: product.id,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),

        bottomNavigationBar: CartSummary(),
      ),
    );
  }
}


class ProductItem extends StatelessWidget {
  final String discount;
  final String name;
  final String originalPrice;
  final String discountedPrice;
  final String imageUrl;
  final String itemId;


  ProductItem({
    required this.discount,
    required this.name,
    required this.originalPrice,
    required this.discountedPrice,
    required this.imageUrl,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(18.0),
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
      margin: EdgeInsets.all(5.0),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  height: 90,
                  imageUrl: imageUrl, // URL of the image
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[100]!,
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
            SizedBox(height: 8.0),
            Text(
              discount + "%",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 36.0,
              child: Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              children: [
                Text(
                  originalPrice,
                  style: TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(width: 5.0),
                Text(
                  discountedPrice,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Center(
              child: QuantitySelector(
                itemId: itemId,
                name: name,
                image: imageUrl,
                price: discountedPrice,
                imageUrl: imageUrl,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuantitySelector extends StatefulWidget {
  final String itemId;
  final String name;
  final String image;
  final String price;
  final String imageUrl;

  QuantitySelector({
    required this.itemId,
    required this.name,
    required this.image,
    required this.price,
    required this.imageUrl,
  });

  @override
  _QuantitySelectorState createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  void _addToCart() {
    FirebaseFirestore.instance.collection("users").doc(APIs.me.id).collection('item_cart').doc(widget.itemId).set({
      'itemId': widget.itemId,
      'name': widget.name,
      'price': widget.price,
      'image': widget.imageUrl,
      'quantity': 1,
    });
    Provider.of<CartModel>(context, listen: false).addItem(widget.itemId, widget.imageUrl);
  }

  void _updateCart(int quantity) {
    if (quantity > 0) {
      FirebaseFirestore.instance.collection("users").doc(APIs.me.id).collection('item_cart').doc(widget.itemId).update({
        'quantity': quantity,
      });
    } else {
      FirebaseFirestore.instance.collection("users").doc(APIs.me.id).collection('item_cart').doc(widget.itemId).delete();
    }
    if (quantity > 0) {
      Provider.of<CartModel>(context, listen: false).addItem(widget.itemId, widget.imageUrl);
    } else {
      Provider.of<CartModel>(context, listen: false).removeItem(widget.itemId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection("users").doc(APIs.me.id).collection('item_cart').doc(widget.itemId).snapshots(),
      builder: (context, snapshot) {
        int _quantity = 0;
        if (snapshot.hasData && snapshot.data!.exists) {
          _quantity = snapshot.data!['quantity'];
        }

        return _quantity == 0
            ? GestureDetector(
          onTap: () {
            _addToCart();
          },
          child: Container(
            height: 38,
            width: 115,
            decoration: BoxDecoration(
                color: Colors.pink,
                borderRadius: BorderRadius.all(Radius.circular(13))),
            child: Center(
              child: Text(
                'ADD',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        )
            : Container(
          height: 38,
          width: 115,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              border: Border.all(width: 1, color: Colors.pink)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  _updateCart(_quantity - 1);
                },
              ),
              Text(_quantity.toString()),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  _updateCart(_quantity + 1);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}





class CartSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context);

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
                  )
              ),
            ],
          ),
        );
      },
    );
  }
}
