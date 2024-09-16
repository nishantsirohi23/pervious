import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

import '../../../widgets/dashedline.dart';
import '../restrauntscreen.dart';

class DishRestraunt extends StatefulWidget {
  final String dishname;
  final String dishId; // Parameter for dish ID

  const DishRestraunt({Key? key, required this.dishId,required this.dishname}) : super(key: key);

  @override
  State<DishRestraunt> createState() => _DishRestrauntState();
}

class _DishRestrauntState extends State<DishRestraunt> {

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final Stream<QuerySnapshot> _usersStream =
    FirebaseFirestore.instance.collection('dishes').doc(widget.dishId).collection('restraunts').snapshots();

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: widget.dishname==""?Text("Dish"):Text(widget.dishname),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _usersStream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading");
            }

            var documents = snapshot.data!.docs.toList();


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


                child: ListView.builder(
                  padding: EdgeInsets.only(top: 5),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data = documents[index].data()! as Map<String, dynamic>;





// At this point, wo


                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('restraunts').doc(data['id']).get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return Center(
                            child: Text('Restaurant not found!'),
                          );
                        }
                        var restaurantData = snapshot.data!.data() as Map<String, dynamic>; // Explicit cast to Map<String, dynamic>
                        return GestureDetector(
                          onTap: (){
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) =>   RestrauntScreen(id: restaurantData['id']

                              )),
                            );
                          },
                          child: ClipRect(
                            clipBehavior: Clip.hardEdge,
                            child: Container(
                              margin: EdgeInsets.only(left: 12,right: 12),
                              width: screenWidth,
                              height: screenHeight*0.36,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(20))
                              ),
                              child: Stack(
                                children: [

                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: screenWidth,
                                        height: screenHeight*0.22 ,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),

                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(20),
                                              topLeft: Radius.circular(20),
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(20),
                                              topLeft: Radius.circular(20),
                                            ),
                                            child: CachedNetworkImage(
                                              fit: BoxFit.cover,
                                              imageUrl: restaurantData['image'], // URL of the image
                                              width: screenWidth, // Double the radius to fit the CircleAvatar
                                              height: screenHeight*0.22, // Double the radius to fit the CircleAvatar
                                              placeholder: (context, url) => Shimmer.fromColors(
                                                baseColor: Colors.grey[300]!,
                                                highlightColor: Colors.grey[100]!,
                                                child: Container(
                                                  width: 84, // Double the radius to fit the CircleAvatar
                                                  height: 84, // Double the radius to fit the CircleAvatar
                                                  color: Colors.white,
                                                ),
                                              ),
                                              errorWidget: (context, url, error) => Icon(Icons.error),
                                            ),

                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(bottomRight: Radius.circular(20),bottomLeft: Radius.circular(20)),
                                          color: Colors.white, // Background color of the container
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.shade300.withOpacity(0.8), // Color of the shadow
                                              spreadRadius: 3, // Spread radius
                                              blurRadius: 4, // Blur radius
                                              offset: Offset(0, 3), // Offset of the shadow
                                            ),
                                          ],
                                          border: Border(
                                            left: BorderSide(
                                              color: Colors.grey.shade300, // Color of the left border
                                              width: 1, // Width of the left border
                                            ),
                                            bottom: BorderSide(
                                              color: Colors.grey.shade300, // Color of the bottom border
                                              width: 1, // Width of the bottom border
                                            ),
                                            right: BorderSide(
                                              color: Colors.grey.shade300, // Color of the right border
                                              width: 1, // Width of the right border
                                            ),
                                          ),
                                        ),

                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  width: screenWidth*0.75,
                                                  child:  Text(restaurantData['name'],
                                                    maxLines: 1,
                                                    overflow: TextOverflow.clip,
                                                    style: TextStyle(
                                                        color: Colors.pink,
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 23
                                                    ),),

                                                ),
                                                Container(
                                                  height: 30,
                                                  width: 50,
                                                  decoration: BoxDecoration(
                                                      color: Colors.pink,
                                                      borderRadius: BorderRadius.all(Radius.circular(10))
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text(restaurantData['rating'],
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.w500
                                                        ),),
                                                      Icon(Icons.star,color: Colors.white,size: 18,)
                                                    ],
                                                  ),
                                                )

                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    restaurantData['specs'],
                                                    maxLines: 1,
                                                    overflow: TextOverflow.clip,
                                                    style: TextStyle(
                                                      color: Colors.black.withOpacity(0.8),

                                                    ),
                                                  ),
                                                ),

                                                SizedBox(width: 5,),
                                                Container(
                                                  width: 4, // Adjust width and height to change the size of the dot
                                                  height: 4,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle, // Shape of the container
                                                    color: Colors.black87, // Color of the dot
                                                  ),
                                                ),
                                                SizedBox(width: 5,),

                                                Expanded(
                                                  child: Text(
                                                    restaurantData['address'],
                                                    maxLines: 1,
                                                    overflow: TextOverflow.clip,
                                                    style: TextStyle(
                                                      color: Colors.black.withOpacity(0.8),

                                                    ),
                                                  ),
                                                ),





                                              ],
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(left: 7,right: 7,top: 4),
                                              child:
                                              DashedLine(
                                                width: screenWidth,
                                                height: 1,
                                                color: Colors.grey.shade300,
                                                strokeWidth: 1,
                                                dashLength: 4,
                                                dashSpace: 7,
                                              ),
                                            ),
                                            Text('Customization Available',
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.w500
                                              ),),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(bottom: 20),
                                    width: screenHeight*0.48,
                                    padding: EdgeInsets.only(top: 8,bottom: 8),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft:Radius.circular(20),bottomLeft: Radius.circular(10) ,bottomRight: Radius.circular(10)),
                                        color: Colors.pink.withOpacity(1)
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.asset('assets/clockwhite.png',height: 18,width: 18,),
                                        SizedBox(width: 4,),
                                        Text(restaurantData['time']+" mins",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500
                                          ),),
                                        SizedBox(width: 5,),
                                        Container(
                                          width: 7, // Adjust width and height to change the size of the dot
                                          height: 7,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle, // Shape of the container
                                            color: Colors.white, // Color of the dot
                                          ),
                                        ),
                                        SizedBox(width: 5,),

                                        Text(restaurantData['distance']+" kms",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500
                                          ),),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                        ;
                      },
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
