import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perwork/models/stores/storeproduct.dart';

class ProductUploadScreen extends StatefulWidget {
  final String storeId;

  ProductUploadScreen({required this.storeId});

  @override
  _ProductUploadScreenState createState() => _ProductUploadScreenState();
}

class _ProductUploadScreenState extends State<ProductUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _productDescriptionController = TextEditingController();
  final _productPriceController = TextEditingController();
  final _productCategoryController = TextEditingController();
  final _productImageUrlsController = TextEditingController();
  final _productRatingController = TextEditingController();
  final _productTotalReviewsController = TextEditingController();
  final _productCategoriesController = TextEditingController();
  final _warrantyTimeController = TextEditingController(); // Controller for warranty time
  final _returnTimeController = TextEditingController(); // Controller for return time

  bool _inStock = true; // Default value for inStock
  bool _haveWarranty = false; // Default value for warranty
  bool _returnAvailable = false; // Default value for return availability
  String _deliveryVehicle = 'Bike'; // Default value for delivery vehicle

  @override
  void dispose() {
    _productNameController.dispose();
    _productDescriptionController.dispose();
    _productPriceController.dispose();
    _productCategoryController.dispose();
    _productImageUrlsController.dispose();
    _productRatingController.dispose();
    _productTotalReviewsController.dispose();
    _productCategoriesController.dispose();
    _warrantyTimeController.dispose(); // Dispose warranty time controller
    _returnTimeController.dispose(); // Dispose return time controller
    super.dispose();
  }

  void _uploadProduct() async {
    if (_formKey.currentState!.validate()) {
      // Create a new product object without the ID
      Product newProduct = Product(
        id: '', // Placeholder for Firestore ID
        name: _productNameController.text,
        description: _productDescriptionController.text,
        price: double.parse(_productPriceController.text).round(),
        currency: 'USD', // Change this if needed
        categories: _productCategoriesController.text.split(','), // Assume categories are comma-separated
        imageUrls: _productImageUrlsController.text.split(','), // Assume URLs are comma-separated
        storeId: widget.storeId,
        totalReviews: int.parse(_productTotalReviewsController.text),
        rating: double.parse(_productRatingController.text),
        inStock: _inStock,
        haveWarranty: _haveWarranty, // Include warranty status
        warrantyTime: _warrantyTimeController.text, // Include warranty time
        deliveryVehicle: _deliveryVehicle, // Include delivery vehicle type
        returnAvailable: _returnAvailable, // Include return availability
        returnTime: _returnTimeController.text, // Include return time
      );

      try {
        // Get a reference to the products subcollection
        CollectionReference productsCollection = FirebaseFirestore.instance
            .collection('stores')
            .doc(widget.storeId)
            .collection('products');

        // Add a new document with an auto-generated ID
        DocumentReference productDocRef = await productsCollection.add(newProduct.toMap());

        // Update the newProduct object with the Firestore-generated ID
        newProduct = newProduct.copyWith(id: productDocRef.id);

        // Save the product with the updated ID in the products subcollection
        await productDocRef.set(newProduct.toMap());

        // Store the product details in the local_products collection
        CollectionReference localProductsCollection = FirebaseFirestore.instance.collection('local_products');

        // Create a map with required fields for the local_products collection
        Map<String, dynamic> localProductData = {
          'id': newProduct.id,
          'storeId': newProduct.storeId,
          'name': newProduct.name,
          'imageUrl': newProduct.imageUrls.isNotEmpty ? newProduct.imageUrls[0] : '', // Use the first image URL
          'price': newProduct.price,
        };

        // Add the product to the local_products collection
        await localProductsCollection.doc(newProduct.id).set(localProductData);

        // Show a confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product Uploaded Successfully')),
        );

        // Optionally, navigate back or to another screen
        Navigator.pop(context);
      } catch (e) {
        // Handle any errors that occur during Firestore operations
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload product: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Product')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _productNameController,
                decoration: InputDecoration(labelText: 'Product Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the product name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _productDescriptionController,
                decoration: InputDecoration(labelText: 'Product Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the product description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _productPriceController,
                decoration: InputDecoration(labelText: 'Product Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the product price';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _productCategoryController,
                decoration: InputDecoration(labelText: 'Main Product Category'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the main product category';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _productCategoriesController,
                decoration: InputDecoration(labelText: 'Additional Product Categories (comma-separated)'),
              ),
              TextFormField(
                controller: _productImageUrlsController,
                decoration: InputDecoration(labelText: 'Product Image URLs (comma-separated)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter at least one image URL';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _productRatingController,
                decoration: InputDecoration(labelText: 'Product Rating'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || double.tryParse(value) == null) {
                    return 'Please enter a valid rating';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _productTotalReviewsController,
                decoration: InputDecoration(labelText: 'Total Reviews'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || int.tryParse(value) == null) {
                    return 'Please enter a valid number of reviews';
                  }
                  return null;
                },
              ),
              SwitchListTile(
                title: Text('In Stock'),
                value: _inStock,
                onChanged: (bool value) {
                  setState(() {
                    _inStock = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text('Have Warranty'),
                value: _haveWarranty,
                onChanged: (bool value) {
                  setState(() {
                    _haveWarranty = value;
                  });
                },
              ),
              if (_haveWarranty) // Show warranty time input only if warranty is available
                TextFormField(
                  controller: _warrantyTimeController,
                  decoration: InputDecoration(labelText: 'Warranty Time'),
                ),
              SwitchListTile(
                title: Text('Return Available'),
                value: _returnAvailable,
                onChanged: (bool value) {
                  setState(() {
                    _returnAvailable = value;
                  });
                },
              ),
              if (_returnAvailable) // Show return time input only if return is available
                TextFormField(
                  controller: _returnTimeController,
                  decoration: InputDecoration(labelText: 'Return Time'),
                ),
              DropdownButtonFormField<String>(
                value: _deliveryVehicle,
                decoration: InputDecoration(labelText: 'Delivery Vehicle'),
                items: ['Bike', 'Pickup']
                    .map((vehicle) => DropdownMenuItem(
                  value: vehicle,
                  child: Text(vehicle),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _deliveryVehicle = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadProduct,
                child: Text('Upload Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
