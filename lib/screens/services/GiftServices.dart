import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GiftServices extends StatelessWidget {
  const GiftServices({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight  = MediaQuery.of(context).size.height;
    double screenWidth  = MediaQuery.of(context).size.width;
    return Container(
      height: screenHeight *0.48,
      margin: EdgeInsets.symmetric(horizontal: 13),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Container(
                    height: 180,
                    width: screenWidth * 0.46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0), // Adjust the radius as needed
                      border: Border.all(
                        color: Colors.pink, // Adjust the border color as needed
                        width: 1.0, // Adjust the border width as needed
                      ),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage('https://firebasestorage.googleapis.com/v0/b/perwork.appspot.com/o/services%2Fgifts%2FRoses.jpg?alt=media&token=7b8b3e93-8274-4be2-83be-f7efb80b155b'),
                      ),
                    ),
                  ),
                  SizedBox(height: 13,),
                  Container(
                    height: 90,
                    width: screenWidth * 0.46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0), // Adjust the radius as needed
                      border: Border.all(
                        color: Colors.cyanAccent, // Adjust the border color as needed
                        width: 1.0, // Adjust the border width as needed
                      ),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage('https://firebasestorage.googleapis.com/v0/b/perwork.appspot.com/o/services%2Fgifts%2FRoses%20(3).jpg?alt=media&token=f51f1b51-4df4-498b-9adb-5b454a7d186c'),
                      ),
                    ),
                  ),
                  SizedBox(height: 13,),
                  Container(
                    height: 90,
                    width: screenWidth * 0.46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0), // Adjust the radius as needed
                      border: Border.all(
                        color: Colors.purple, // Adjust the border color as needed
                        width: 1.0, // Adjust the border width as needed
                      ),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage('https://firebasestorage.googleapis.com/v0/b/perwork.appspot.com/o/services%2Fgifts%2FRoses%20(4).jpg?alt=media&token=84823aa0-c8a5-4693-8e2a-ee2fed5b25c4'),
                      ),
                    ),
                  )


                ],
              ),
              Column(
                children: [
                  Container(
                  height: 90,
                  width: screenWidth * 0.46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0), // Adjust the radius as needed
                    border: Border.all(
                      color: Colors.green, // Adjust the border color as needed
                      width: 1.0, // Adjust the border width as needed
                    ),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage('https://firebasestorage.googleapis.com/v0/b/perwork.appspot.com/o/services%2Fgifts%2FRoses%20(5).jpg?alt=media&token=d4155467-0f66-4911-a7b2-a4ac05162208'),
                    ),
                  ),
                ),
                  SizedBox(height: 13,),
                  Container(
                    height: 90,
                    width: screenWidth * 0.46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0), // Adjust the radius as needed
                      border: Border.all(
                        color: Colors.pinkAccent, // Adjust the border color as needed
                        width: 1.0, // Adjust the border width as needed
                      ),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage('https://firebasestorage.googleapis.com/v0/b/perwork.appspot.com/o/services%2Fgifts%2FRoses%20(2).jpg?alt=media&token=b6cb13f1-9f14-4009-b7d0-3916978c14cb'),
                      ),
                    ),
                  ),
                  SizedBox(height: 13,),
                  Container(
                    height: 180,
                    width: screenWidth * 0.46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0), // Adjust the radius as needed
                      border: Border.all(
                        color: Colors.orange, // Adjust the border color as needed
                        width: 1.0, // Adjust the border width as needed
                      ),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage('https://firebasestorage.googleapis.com/v0/b/perwork.appspot.com/o/services%2Fgifts%2FRoses%20(1).jpg?alt=media&token=bde98d41-fca0-476a-9ab2-ac46c5d1c2ce'),
                      ),
                    ),
                  ),


                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
