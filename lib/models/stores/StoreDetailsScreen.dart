import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';

class StoreDetailsScreen extends StatefulWidget {
  final String storeId;

  StoreDetailsScreen({required this.storeId});

  @override
  _StoreDetailsScreenState createState() => _StoreDetailsScreenState();
}

class _StoreDetailsScreenState extends State<StoreDetailsScreen> {
  late Future<DocumentSnapshot> _storeFuture;
  late Future<QuerySnapshot> _productsFuture;

  @override
  void initState() {
    super.initState();
    _storeFuture = FirebaseFirestore.instance.collection('stores').doc(widget.storeId).get();
    _productsFuture = FirebaseFirestore.instance
        .collection('stores')
        .doc(widget.storeId)
        .collection('products')
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Store Details')),
      body: FutureBuilder<DocumentSnapshot>(
        future: _storeFuture,
        builder: (context, storeSnapshot) {
          if (storeSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (storeSnapshot.hasError) {
            return Center(child: Text('Error: ${storeSnapshot.error}'));
          }

          if (!storeSnapshot.hasData) {
            return Center(child: Text('Store not found.'));
          }

          final store = storeSnapshot.data!.data() as Map<String, dynamic>;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(store['name']),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Address: ${store['address']}'),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Opening Hours: ${store['openingHours']}'),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Rating: ${store['rating']}'),
              ),
              Expanded(
                child: FutureBuilder<QuerySnapshot>(
                  future: _productsFuture,
                  builder: (context, productsSnapshot) {
                    if (productsSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (productsSnapshot.hasError) {
                      return Center(child: Text('Error: ${productsSnapshot.error}'));
                    }

                    if (!productsSnapshot.hasData || productsSnapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No products available.'));
                    }

                    final products = productsSnapshot.data!.docs;

                    return ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index].data() as Map<String, dynamic>;
                        final imageUrls = List<String>.from(product['imageUrls'] ?? []);

                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product['name']),
                              CarouselSlider(
                                options: CarouselOptions(
                                  height: 200,
                                  autoPlay: true,
                                  enlargeCenterPage: true,
                                  aspectRatio: 16 / 9,
                                  viewportFraction: 0.8,
                                ),
                                items: imageUrls.map((imageUrl) {
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return Container(
                                        width: MediaQuery.of(context).size.width,
                                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                        ),
                                        child: Image.network(imageUrl, fit: BoxFit.cover),
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
                              SizedBox(height: 8),
                              Text(product['description']),
                              Text('Price: ${product['price']} ${product['currency']}'),
                              SizedBox(height: 20),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
