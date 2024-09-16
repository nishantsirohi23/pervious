import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RepairsWidget extends StatelessWidget {
  const RepairsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      margin: EdgeInsets.symmetric(horizontal: 13),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('repairs').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No repairs available'));
          }

          // Splitting the data based on the number of words in the name
          List<DocumentSnapshot> lessThanOrEqualTwoWords = [];
          List<DocumentSnapshot> moreThanTwoWords = [];

          snapshot.data!.docs.forEach((doc) {
            String name = (doc.data()! as Map<String, dynamic>)['name'];
            if (name.split(' ').length > 2) {
              moreThanTwoWords.add(doc);
            } else {
              lessThanOrEqualTwoWords.add(doc);
            }
          });

          // Display different lists based on word count
          return Column(
            children: [
              // Display for names with more than two words (placed above)
              Container(
                height: 120,


                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: moreThanTwoWords.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot document = moreThanTwoWords[index];
                    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,

                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.network(data['image'], width: 180, height: 110),

                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              // Display for names with less than or equal to two words (placed below)
              Container(
                height: 92,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: lessThanOrEqualTwoWords.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot document = lessThanOrEqualTwoWords[index];
                    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(data['image'], width: 130, height: 90),
                          ],
                        ),
                      ),
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
