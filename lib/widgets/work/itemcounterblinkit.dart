import 'package:flutter/material.dart';

class ItemCounterBlinkit extends StatefulWidget {
  final void Function(int) onCountChanged;

  const ItemCounterBlinkit({required this.onCountChanged});

  @override
  _ItemCounterState createState() => _ItemCounterState();
}

class _ItemCounterState extends State<ItemCounterBlinkit> {
  int itemCount = 0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (itemCount == 0) {
              itemCount = 1;
              widget.onCountChanged(itemCount);
            }
          });
        },
        child: Container(
          height: 36,
          width: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.pink, // Set the background color to pink
            border: Border.all(color: Colors.white, width: 1), // Add white border
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Visibility(
                visible: itemCount > 0,
                  child: GestureDetector(
                  onTap: (){
                    setState(() {
                      itemCount--;
                      widget.onCountChanged(itemCount);
                    });
                  },
                  child: Icon(Icons.remove,color: Colors.white,)
              )),

              Text(
                itemCount == 0 ? 'ADD' : itemCount.toString(),
                style: TextStyle(
                  color: Colors.white, // Set the color of the text to white
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Visibility(
                visible: itemCount > 0,

                child: GestureDetector(
                  onTap: (){
                    setState(() {
                      itemCount++;
                      widget.onCountChanged(itemCount);
                    });
                  },
                  child: Icon(Icons.add,color: Colors.white,)
              ),)


            ],
          ),
        ),
      ),
    );
  }
}
