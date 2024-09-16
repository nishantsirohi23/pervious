import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Petcare extends StatelessWidget {
  const Petcare({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight  = MediaQuery.of(context).size.height;
    double screenWidth  = MediaQuery.of(context).size.width;
    return Container(
      height: screenHeight *0.41,
      margin: EdgeInsets.symmetric(horizontal: 13),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: screenHeight *0.2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Container(
                  width: screenWidth*0.54,
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent,  // Background color if the image doesn't cover the full area
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                    image: DecorationImage(
                      image: NetworkImage(

                        "https://firebasestorage.googleapis.com/v0/b/perwork.appspot.com/o/services%2Fpetcare%2FDog%20Walking%20(4).jpg?alt=media&token=419b1e9c-0656-430c-a269-50f779190afe",
                      ),
                      fit: BoxFit.cover
                    ),
                  ),
                ),
                Container(
                  width: screenWidth * 0.38,
                  height: screenHeight *0.18,
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent,  // Background color if the image doesn't cover the full area
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                    image: DecorationImage(
                      image: NetworkImage(
                        "https://firebasestorage.googleapis.com/v0/b/perwork.appspot.com/o/services%2Fpetcare%2Fgrooming%20(1).jpg?alt=media&token=e2f5de72-368a-4d2f-b3b9-e9a8c83594b0",
                      ),
                      fit: BoxFit.cover,  // Makes sure the image covers the entire container
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            height: screenHeight *0.2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: screenWidth * 0.38,
                  height: screenHeight *0.18,

                  decoration: BoxDecoration(
                    color: Colors.pinkAccent,  // Background color if the image doesn't cover the full area
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                    image: DecorationImage(
                      image: NetworkImage(
                        "https://firebasestorage.googleapis.com/v0/b/perwork.appspot.com/o/services%2Fpetcare%2FPet%20(1).jpg?alt=media&token=554f59cd-3eb6-49c8-a9a3-99f5a3bbebbb",
                      ),
                      fit: BoxFit.cover,  // Makes sure the image covers the entire container
                    ),
                  ),
                ),

                Container(
                  width: screenWidth*0.53,

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(24)),

                    color: Colors.orange,
                  ),
                )

              ],
            ),
          )
        ],
      ),
    );
  }
}
