import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ImageSelectorWidget extends StatefulWidget {
  final String collectionName;

  ImageSelectorWidget({required this.collectionName});

  @override
  _ImageSelectorWidgetState createState() => _ImageSelectorWidgetState();
}

class _ImageSelectorWidgetState extends State<ImageSelectorWidget> {
  List<String> imageUrls = [];
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchImagesFromFirestore();
  }

  Future<void> fetchImagesFromFirestore() async {
    // Fetch the images from the specified Firestore collection
    QuerySnapshot snapshot =
    await FirebaseFirestore.instance.collection(widget.collectionName).get();

    List<String> urls = snapshot.docs
        .map((doc) => doc['image'] as String) // Assuming 'image' field contains the image URL
        .toList();

    setState(() {
      imageUrls = urls;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight  = MediaQuery.of(context).size.height;
    double screenWidth  = MediaQuery.of(context).size.width;
    return imageUrls.isEmpty
        ? Center(child: CircularProgressIndicator()) // Loading indicator while fetching images
        : Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Display the selected image
        Container(
          height: screenHeight * 0.37,
          width: screenWidth * 0.9,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(imageUrls[selectedIndex]),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(25), // Optional: add rounded corners
            // You can add more decoration properties like border, boxShadow, etc.
          ),
          // Optional: Add child widgets here if you need to overlay content on the image
        )
        ,
        // Display the thumbnails
        Container(
          height: 80,
          margin: EdgeInsets.only(top: 16.0),
          child: Center(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: imageUrls.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      border: selectedIndex == index
                          ? Border.all(
                        color: Colors.blue, // Border color for selected image
                        width: 2,
                      )
                          : null, // No border for unselected images
                      borderRadius: BorderRadius.circular(15), // Border radius for images and border
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15), // Slightly smaller radius for the image itself
                      child: Padding(
                        padding: const EdgeInsets.all(2.0), // Space between image and border
                        child: Image.network(
                          imageUrls[index],
                          width: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        )
        ,
      ],
    );
  }
}
