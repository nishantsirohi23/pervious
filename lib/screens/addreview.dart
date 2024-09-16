import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:perwork/screens/profilescreen.dart';

import '../api/apis.dart';

class AddReviewScreen extends StatefulWidget {
  final String profId;
  final String type;
  final String firebaseid;

  const AddReviewScreen({Key? key, required this.profId, required this.type, required this.firebaseid}) : super(key: key);

  @override
  _AddReviewScreenState createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  int _rating = 0;
  String _subject = '';
  bool _submittingReview = false; // Track whether the review is being submitted

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Add Review'),
      ),
      body: _submittingReview ? Center(child: CircularProgressIndicator()) : buildReviewForm(),
    );
  }

  Widget buildReviewForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rating:',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 10.0),
              RatingBar.builder(
                initialRating: 5,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating.toInt();
                  });
                },
              ),
              SizedBox(height: 20.0),
              Text(
                'Enter the review:',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 20.0),
              Container(
                height: 140,
                width: MediaQuery.of(context).size.width * 0.9,
                padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: TextFormField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintMaxLines: 2,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 15.0),
                    hintText: 'Write your feedback and review of the worker (Min 40 Words)',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a subject';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _subject = value;
                    });
                  },
                ),
              ),
              SizedBox(height: 20.0),
              GestureDetector(
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _submittingReview = true; // Set submittingReview to true when review is being submitted
                    });
                    _submitReview(context);
                  }
                },
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(left: 20, right: 20),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/backofwork.png"),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Center(
                    child: Text(
                      'Add Review',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 21,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Container(
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reward Points System',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Row(
                      children: [
                        Image.asset("assets/reward.png",height: 30,width: 30,),
                        Text(
                          '1 Review = 100 Super Points',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4,),
                    Row(
                      children: [
                        Image.asset("assets/super.png",height: 30,width: 30,),
                        Container(
                          width: MediaQuery.of(context).size.width*0.7,
                          child: Text(
                            '100 Super Points = ₹1 off on buying Super Genie',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black54,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )

            ],
          ),
        ),
      ),
    );
  }

  void _submitReview(BuildContext context) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final reviewData = {
          'userId': currentUser.uid,
          'star': _rating,
          'date': DateTime.now(),
          'subject': _subject,
          'profId': widget.profId,
        };
        CollectionReference users = FirebaseFirestore.instance.collection(
            'users');

        // Update data in Firestore
        await users.doc(APIs.me.id).update({
          'points': FieldValue.increment(100),
        });

        // Add review to the prof collection
        await FirebaseFirestore.instance
            .collection('prof')
            .doc(widget.profId)
            .collection('reviews')
            .add(reviewData);

        // Add review to the user collection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('reviews')
            .add(reviewData);
        if(widget.type=='work'){
          CollectionReference profCollection = FirebaseFirestore.instance
              .collection('work');

          await profCollection
              .doc(widget.firebaseid)
              .update({
            'reviewdone': true,

          });
        }
        else if(widget.type=='food'){
          CollectionReference profCollection = FirebaseFirestore.instance
              .collection('orders');

          await profCollection
              .doc(widget.firebaseid)
              .update({
            'reviewdone': true,

          });
        }
        else{
          CollectionReference profCollection = FirebaseFirestore.instance
              .collection('bookings');

          await profCollection
              .doc(widget.firebaseid)
              .update({
            'reviewdone': true,

          });
        }

        // Update totalRating in prof document
        final profDocRef = FirebaseFirestore.instance.collection('prof').doc(widget.profId);
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final profDoc = await transaction.get(profDocRef);
          if (profDoc.exists) {
            final currentTotalRating = int.tryParse(profDoc.data()?['totalrating'] ?? '0') ?? 0;
            final newTotalRating = currentTotalRating + 1;
            transaction.update(profDocRef, {'totalrating': newTotalRating.toString()});
          }
        });
        MotionToast.success(
          title:  Text("Review Added"),
          description:  const Text("Successfully added review for the worker"),
        ).show(context);
        APIs.getSelfInfo();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );

      } else {
        // Handle case when user is not authenticated
        print('User not authenticated');
      }
    } catch (e) {
      MotionToast.success(
        title:  Text("Failed"),
        description:  const Text("Error Submitting Review"),
      ).show(context);

      print('Error submitting review: $e');
      // Handle error submitting review
    } finally {
      setState(() {
        _submittingReview = false; // Reset submittingReview to false after review submission is complete
      });
    }
  }
}
