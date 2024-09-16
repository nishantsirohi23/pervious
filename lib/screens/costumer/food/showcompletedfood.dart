import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShowCompletedFood extends StatefulWidget {
  final String orderid;
  const ShowCompletedFood({Key? key,required this.orderid}) : super(key: key);

  @override
  State<ShowCompletedFood> createState() => _ShowCompletedFoodState();
}

class _ShowCompletedFoodState extends State<ShowCompletedFood> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Food Order"),
        ),
        body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance.collection('orders').doc(widget.orderid).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              isLoading = true;
              return Visibility(visible: false,child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              isLoading = false;

              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || !snapshot.data!.exists) {
              isLoading = false;

              return Text('Work not found');
            }
            isLoading = false;


            // Work details






            return Container(
            );
          },
        )
    );
  }
}
