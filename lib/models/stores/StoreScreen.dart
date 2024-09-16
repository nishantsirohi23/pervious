import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'StoreDetailsScreen.dart';

class AllStoresScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('All Stores')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('stores').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No stores available.'));
          }

          final stores = snapshot.data!.docs;

          return ListView.builder(
            itemCount: stores.length,
            itemBuilder: (context, index) {
              final store = stores[index].data() as Map<String, dynamic>;

              return ListTile(
                leading: store['imageUrl'] != null
                    ? Image.network(store['imageUrl'], width: 50, height: 50, fit: BoxFit.cover)
                    : SizedBox(width: 50, height: 50), // Default placeholder
                title: Text(store['name']),
                subtitle: Text(store['address']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StoreDetailsScreen(storeId: stores[index].id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
