import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductSearchScreen extends StatefulWidget {
  @override
  _ProductSearchScreenState createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  // Pagination variables
  bool _hasMore = true;
  bool _isLoading = false;
  DocumentSnapshot? _lastDocument;
  List<QueryDocumentSnapshot> _products = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _fetchMoreProducts();
      }
    });
  }

  Future<void> _fetchProducts({bool isNewSearch = true}) async {
    if (isNewSearch) {
      _products = [];
      _lastDocument = null;
      _hasMore = true;
    }

    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    Query query = FirebaseFirestore.instance
        .collection('local_products')
        .where('name', isEqualTo: _searchController.text)
        .where('name', isLessThanOrEqualTo: _searchController.text + '\uf8ff')
        .limit(10);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    try {
      QuerySnapshot querySnapshot = await query.get();
      if (querySnapshot.docs.isEmpty) {
        _hasMore = false;
      } else {
        _lastDocument = querySnapshot.docs.last;
        _products.addAll(querySnapshot.docs);
      }
    } catch (e) {
      print('Error fetching products: $e');
      _hasMore = false;
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchMoreProducts() async {
    if (_isLoading || !_hasMore) return;
    await _fetchProducts(isNewSearch: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Products',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _fetchProducts();
                  },
                ),
              ),
              onChanged: (query) {
                if (query.isEmpty) {
                  setState(() {
                    _products = [];
                    _lastDocument = null;
                    _hasMore = true;
                  });
                }
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _products.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _products.length) {
                  return Center(child: CircularProgressIndicator());
                }

                final product = _products[index].data() as Map<String, dynamic>;
                final imageUrls = List<String>.from(product['imageUrls'] ?? []);

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product['name']),
                      imageUrls.isNotEmpty
                          ? Image.network(imageUrls.first, height: 200, fit: BoxFit.cover)
                          : SizedBox.shrink(),
                      SizedBox(height: 8),
                      Text(product['description']),
                      Text('Price: ${product['price']} ${product['currency']}'),
                      SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
