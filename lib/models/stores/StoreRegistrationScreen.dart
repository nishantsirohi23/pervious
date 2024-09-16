import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perwork/models/stores/store.dart';
import 'ProductUploadScreen.dart';

class StoreRegistrationScreen extends StatefulWidget {
  @override
  _StoreRegistrationScreenState createState() => _StoreRegistrationScreenState();
}

class _StoreRegistrationScreenState extends State<StoreRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _storeAddressController = TextEditingController();
  final _storeLatitudeController = TextEditingController();
  final _storeLongitudeController = TextEditingController();
  final _storeImageUrlController = TextEditingController();
  final _storeRatingController = TextEditingController();
  final _storeOpeningHoursController = TextEditingController();

  String? _selectedCategory;
  List<String> _categories = [];
  bool _cod = false;
  bool _freeDelivery = false;
  bool _returnAvailable = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _storeAddressController.dispose();
    _storeLatitudeController.dispose();
    _storeLongitudeController.dispose();
    _storeImageUrlController.dispose();
    _storeRatingController.dispose();
    _storeOpeningHoursController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('store_category').get();
      List<String> categories = snapshot.docs.map((doc) => doc['name'] as String).toList();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load categories: $e')),
      );
    }
  }

  void _registerStore() async {
    if (_formKey.currentState!.validate()) {
      // Create a new store object without the ID
      Store newStore = Store(
        id: '', // Placeholder for Firestore ID
        name: _storeNameController.text,
        address: _storeAddressController.text,
        latitude: double.parse(_storeLatitudeController.text),
        longitude: double.parse(_storeLongitudeController.text),
        imageUrl: _storeImageUrlController.text,
        category: _selectedCategory ?? '',
        rating: _storeRatingController.text,
        products: [], // Initially empty
        openingHours: _storeOpeningHoursController.text,
        cod: _cod,
        freeDelivery: _freeDelivery,
        returnAvailable: _returnAvailable,
        specialisation: 'General', // Set this according to your needs
      );

      try {
        // Get a reference to the 'stores' collection
        CollectionReference storesCollection = FirebaseFirestore.instance.collection('stores');

        // Add a new document with an auto-generated ID
        DocumentReference storeDocRef = await storesCollection.add(newStore.toMap());

        // Update the newStore object with the Firestore-generated ID
        newStore = newStore.copyWith(id: storeDocRef.id);

        // Save the store with the updated ID
        await storeDocRef.set(newStore.toMap());

        // Navigate to the product upload screen after registration
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductUploadScreen(storeId: newStore.id),
          ),
        );

        // Show a confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Store Registered Successfully')),
        );
      } catch (e) {
        // Handle any errors that occur during Firestore operations
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to register store: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register Store')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _storeNameController,
                decoration: InputDecoration(labelText: 'Store Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the store name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _storeAddressController,
                decoration: InputDecoration(labelText: 'Store Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the store address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _storeLatitudeController,
                decoration: InputDecoration(labelText: 'Latitude'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the latitude';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _storeLongitudeController,
                decoration: InputDecoration(labelText: 'Longitude'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the longitude';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _storeImageUrlController,
                decoration: InputDecoration(labelText: 'Image URL'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the image URL';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(labelText: 'Category'),
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _storeRatingController,
                decoration: InputDecoration(labelText: 'Rating'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the store rating';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _storeOpeningHoursController,
                decoration: InputDecoration(labelText: 'Opening Hours'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the store opening hours';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              CheckboxListTile(
                title: Text('Cash on Delivery (COD)'),
                value: _cod,
                onChanged: (bool? value) {
                  setState(() {
                    _cod = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Free Delivery'),
                value: _freeDelivery,
                onChanged: (bool? value) {
                  setState(() {
                    _freeDelivery = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Return Available'),
                value: _returnAvailable,
                onChanged: (bool? value) {
                  setState(() {
                    _returnAvailable = value ?? false;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registerStore,
                child: Text('Register Store'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
