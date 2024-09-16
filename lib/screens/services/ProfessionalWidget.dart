import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfessionalWidget extends StatelessWidget {
  const ProfessionalWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight  = MediaQuery.of(context).size.height;
    double screenWidth  = MediaQuery.of(context).size.width;
    return Container(
      height: screenHeight *0.47,
      margin: EdgeInsets.symmetric(horizontal: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: screenHeight*0.45,
            child: Column(

              children: [
                Container(
                  width: screenWidth*0.45,
                  height: 200,

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),

                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage('https://firebasestorage.googleapis.com/v0/b/perwork.appspot.com/o/services%2F4_prof%2FPlumber.jpg?alt=media&token=46122789-493d-4864-8823-6dcbe3d62e47'),
                    ),
                  ),
                ),
                SizedBox(height: 12,),

                Container(
                  width: screenWidth*0.45,
                  height: 200,

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),

                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage('https://firebasestorage.googleapis.com/v0/b/perwork.appspot.com/o/services%2F4_prof%2FPlumber%20(2).jpg?alt=media&token=7bd0b2a6-8a45-49e0-83bb-14264b071174'),
                    ),
                  ),
                )
              ],
            ),
          ),
          Column(


            children: [
              SizedBox(height: 25,),
              Container(
                width: screenWidth*0.45,
                height: 200,

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),

                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage('https://firebasestorage.googleapis.com/v0/b/perwork.appspot.com/o/services%2F4_prof%2FPlumber%20(3).jpg?alt=media&token=a83c5165-2545-4791-a241-1676a829d889'),
                  ),
                ),
              ),
              SizedBox(height: 12,),

              Container(
                width: screenWidth*0.45,
                height: 200,

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),

                  image: DecorationImage(
                    fit: BoxFit.cover,

                    image: NetworkImage('https://firebasestorage.googleapis.com/v0/b/perwork.appspot.com/o/services%2F4_prof%2FPlumber%20(1).jpg?alt=media&token=d36fcbc1-adbe-4065-8a47-704a94c18c5c'),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
