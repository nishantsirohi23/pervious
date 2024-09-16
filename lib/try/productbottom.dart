import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../api/apis.dart';
import '../models/itemcart.dart';

class ProductBottomSheet extends StatefulWidget {
  final String name;
  final String brand;
  final String des;
  final String mrp;
  final String itemId;
  final String price;
  final List<String> images;
  final String flavor;

  ProductBottomSheet({
    required this.name,
    required this.brand,
    required this.des,
    required this.mrp,
    required this.itemId,
    required this.price,
    required this.images,
    required this.flavor,
  });

  @override
  _ProductBottomSheetState createState() => _ProductBottomSheetState();
}

class _ProductBottomSheetState extends State<ProductBottomSheet> {
  int _quantity = 0;

  @override
  void initState() {
    super.initState();
    _fetchQuantity();
  }

  Future<void> _fetchQuantity() async {
    var doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(APIs.me.id)
        .collection('item_cart')
        .doc(widget.itemId) // Assuming product name is unique identifier
        .get();
    if (doc.exists) {
      setState(() {
        _quantity = doc['quantity'];
      });
    }
  }

  void _addToCart() {
    FirebaseFirestore.instance
        .collection("users")
        .doc(APIs.me.id)
        .collection('item_cart')
        .doc(widget.itemId)
        .set({
      'itemId': widget.name,
      'name': widget.name,
      'price': widget.price,
      'image': widget.images[0],
      'quantity': _quantity,
    });
    Provider.of<CartModel>(context, listen: false)
        .addItem(widget.name, widget.images[0]);
  }

  void _updateCart() {
    if (_quantity > 0) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(APIs.me.id)
          .collection('item_cart')
          .doc(widget.itemId)
          .update({
        'quantity': _quantity,
      });
    } else {
      FirebaseFirestore.instance
          .collection("users")
          .doc(APIs.me.id)
          .collection('item_cart')
          .doc(widget.itemId)
          .delete();
    }
    if (_quantity > 0) {
      Provider.of<CartModel>(context, listen: false)
          .addItem(widget.name, widget.images[0]);
    } else {
      Provider.of<CartModel>(context, listen: false)
          .removeItem(widget.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        color: Colors.white,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                ClipRRect(
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    height: 200,
                    imageUrl: widget.images[0], // URL of the image
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


                SizedBox(height: 10),
                Text(widget.des, style: TextStyle(fontSize: 18)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("₹",style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                        fontSize: 17
                    )),
                    Text(
                      widget.mrp.toString(),
                      style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                          fontSize: 17
                      ),
                    ),
                    SizedBox(width: 5.0),
                    Text(
                      widget.price.toString(),
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                          fontSize: 17.5

                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                _quantity == 0
                    ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _quantity = 1;
                    });
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
                          setState(() {
                            _quantity--;
                          });
                          _updateCart();
                        },
                      ),
                      Text(_quantity.toString()),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            _quantity++;
                          });
                          _updateCart();
                        },
                      ),
                    ],
                  ),
                ),                SizedBox(height: 15),

                Container(
                  child: Text(widget.brand,maxLines: 5,),
                ),
                SizedBox(height: 10,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
