import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

import '../showmywork.dart';
import 'dishrestraunt.dart';

class DinnerLunch extends StatefulWidget {
  final String type;
  const DinnerLunch({Key? key,required this.type}) : super(key: key);

  @override
  State<DinnerLunch> createState() => _DinnerLunchState();
}

class _DinnerLunchState extends State<DinnerLunch> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.type),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection(widget.type).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading");
            }

            var documents = snapshot.data!.docs;


            if (documents.isEmpty) {
              return Center(
                child: Container(
                  margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.1),


                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Lottie.asset('assets/lottie/empty.json'),

                    ],
                  ),
                ),
              );
            } else {
              return Container(
                height: screenHeight*0.74,


                child: ListView.builder(
                  padding: EdgeInsets.only(top: 5),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data = documents[index].data()! as Map<String, dynamic>;

                    // Determine background color based on priority
                    Color backgroundColor;
                    switch (data['priority']) {
                      case 'Urgent':
                        backgroundColor = Colors.white;
                        break;
                      case 'High':
                        backgroundColor = Colors.white;
                        break;
                      case 'Normal':
                      default:
                        backgroundColor = Colors.white;
                    }
                    String status = data['status'] ?? '';
                    bool isNego = data['negotiable'] ?? '';
                    String type = "Fixed";
                    if (isNego==true){
                      type = "Negotiable";

                    }
                    String workImage = "";
                    List<Map<String, dynamic>> fileData = (data['fileData'] ?? [])?.cast<Map<String, dynamic>>() ?? [];

                    if (fileData.isEmpty) {
                      workImage = "https://cdn.dribbble.com/userupload/3640939/file/original-669699737952c579e1adf2dfa11652fa.jpeg?resize=2048x1152";
                    } else {
                      for (var file in fileData) {
                        String type = file['type']; // Assuming 'type' holds the file type information
                        if (type == 'jpeg' || type == 'png' || type == 'jpg') {
                          workImage = file['url']; // Assuming 'url' holds the URL of the image
                          break; // Break once the first image is found
                        }
                      }
                    }


// At this point, workImage will either be set to the default URL or the URL of the first image of type jpeg, png, or jpg.
                    double loadwidth = 0.0;
                    if (status=="process"){
                      loadwidth = screenWidth*0.2;
                    }
                    if (status=="track"){
                      loadwidth = screenWidth*0.6;
                    }
                    if (status=="posted"){
                      loadwidth = screenWidth*0.4;
                    }
                    if (status == "paydone") {
                      return SizedBox.shrink(); // Skip rendering the container if status is "paydone"
                    }


                    return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>   DishRestraunt(dishId: data['id'],dishname: data['name'],)),
                          );
                        },
                        child: Container(
                          height: 80, // Increased height to accommodate content without overflow
                          padding: EdgeInsets.all(8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,// Align children to the top
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: data['image'], // URL of the image
                                  width: 55,
                                  height: 60,
                                  placeholder: (context, url) => Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      width: 55,
                                      height: 60,
                                      color: Colors.white,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['name'],
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 19,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 2, // Limit text to 2 lines to prevent overflow
                                      overflow: TextOverflow.ellipsis, // Add ellipsis when exceeding 2 lines
                                    ),
                                    SizedBox(height: 3), // Add some space between name and rating
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "See in all restraunts",
                                          style: TextStyle(
                                            color: Colors.pink.withOpacity(0.9),
                                            fontSize: 15,
                                          ),
                                        ),
                                        Icon(Icons.arrow_forward_ios,color: Colors.pink.withOpacity(0.9),size: 13,)
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                    );
                  },
                ),
              );
            }
          },
        )
    );
  }
}
