import 'package:flutter/material.dart';

class CleaningWidget extends StatelessWidget {
  const CleaningWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight  = MediaQuery.of(context).size.height;
    double screenWidth  = MediaQuery.of(context).size.width;

    return Container(
      height: screenHeight*0.41,
      margin: EdgeInsets.only(
        left: 13,right: 13
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: MediaQuery.of(context).size.width*0.66,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    border: Border.all(color: Colors.grey.shade300)
                  ),
                  child: GestureDetector(
                    onTap: () {
                      // Add your tap action here
                      print('Cleaning service selected');
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20), // Border radius for the image
                      child: Image.network(
                        "https://firebasestorage.googleapis.com/v0/b/perwork.appspot.com/o/services%2Fcleaning%2FGet%20everything%20cleaned.png?alt=media&token=9edf61a1-9efb-4c88-8eca-5135ef00d1dd",
                        height: screenHeight*0.25,
                        width: screenWidth*0.6,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 6,),
                Container(
                  margin: EdgeInsets.only(left: 5,right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18), // Optional: clip the image to match rounded corners
                        child: Image.network(
                          "https://firebasestorage.googleapis.com/v0/b/perwork.appspot.com/o/services%2Fcleaning%2FSofa%20Cleaning%20(1).png?alt=media&token=73212d37-0112-4999-8e48-82692798fb98",
                          height: screenWidth*0.27,
                          width: screenWidth*0.26,
                          fit: BoxFit.cover,
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20), // Optional: clip the image to match rounded corners
                        child: Image.network(
                          "https://firebasestorage.googleapis.com/v0/b/perwork.appspot.com/o/services%2Fcleaning%2FSofa%20Cleaning%20(2).png?alt=media&token=0de25f66-74d0-4691-b73c-a08494135ce8",
                          height: screenWidth*0.27,
                          width: screenWidth*0.26,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                )


              ],
            ),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20), // Optional: clip the image to match rounded corners
                child: Image.network(
                  "https://firebasestorage.googleapis.com/v0/b/perwork.appspot.com/o/services%2Fcleaning%2FSofa%20Cleaning.png?alt=media&token=18c68a52-ab71-4784-b467-d7f700b12703",
                  height: screenWidth*0.27,
                  width: screenWidth*0.26,
                  fit: BoxFit.cover,
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(20), // Optional: clip the image to match rounded corners
                child: Image.network(
                  "https://firebasestorage.googleapis.com/v0/b/perwork.appspot.com/o/services%2Fcleaning%2FSofa%20Cleaning%20(3).png?alt=media&token=cba722e5-8ba4-4e64-abdb-12d20f8b710e",
                  height: screenWidth*0.27,
                  width: screenWidth*0.26,
                  fit: BoxFit.cover,
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(20), // Optional: clip the image to match rounded corners
                child: Image.network(
                  "https://firebasestorage.googleapis.com/v0/b/perwork.appspot.com/o/services%2Fcleaning%2FSofa%20Cleaning%20(4).png?alt=media&token=b880bc20-908d-4194-85fe-b85a48347635",
                  height: screenWidth*0.27,
                  width: screenWidth*0.26,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
