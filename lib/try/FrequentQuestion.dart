import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FrequentQuestionScreen extends StatefulWidget {
  @override
  _FrequentQuestionScreenState createState() => _FrequentQuestionScreenState();
}

class _FrequentQuestionScreenState extends State<FrequentQuestionScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // List of questions and answers
  List<Map<String, dynamic>> faqList = [];

  // Track the index of the currently expanded tile
  int? expandedIndex; // Single expanded index

  // Method to fetch FAQs from Firestore
  Future<void> fetchFAQs() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('Frequent_questions').get();
      setState(() {
        faqList = snapshot.docs.map((doc) {
          return {
            'question': doc['question'],
            'answer': doc['answer'],
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching FAQs: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchFAQs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Frequently Asked Questions', style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: faqList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: faqList.length,
        itemBuilder: (context, index) {
          bool isExpanded = expandedIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                // Toggle expandedIndex to the current index or collapse if already expanded
                if (isExpanded) {
                  expandedIndex = null;
                } else {
                  expandedIndex = index;
                }
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(color: Colors.grey.shade400, width: 1.0),

              ),
              child: Column(
                children: [
                  Container(
                    padding: isExpanded ? EdgeInsets.only(left: 16, right: 16, top: 10) : EdgeInsets.only(left: 16, right: 16, top: 13, bottom: 13),
                    decoration: BoxDecoration(

                    ),
                    child: Text(
                      faqList[index]['question'] as String,
                      style: TextStyle(
                        color: isExpanded ? Colors.blue : Colors.black, // Change color based on expansion state
                        fontWeight: isExpanded ? FontWeight.bold : FontWeight.normal, // Optional: Change font weight
                      ),
                    ),
                  ),
                  if (isExpanded)
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
                      child: Column(
                        children: [
                          Divider(
                            color: Colors.grey,
                          ),
                          Text(
                            faqList[index]['answer'] as String,
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.8), // Change color based on expansion state
                            ),
                          )
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to chatbot screen or trigger chatbot functionality

          // Navigator.push(...); You can add navigation to your chatbot screen here
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.chat),
      ),
    );
  }
}
