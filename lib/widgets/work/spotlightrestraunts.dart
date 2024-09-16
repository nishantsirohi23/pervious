import 'package:flutter/material.dart';

class ItemCounter extends StatefulWidget {
  final void Function(int) onCountChanged;

  const ItemCounter({required this.onCountChanged});

  @override
  _ItemCounterState createState() => _ItemCounterState();
}

class _ItemCounterState extends State<ItemCounter> {
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
          height: 42,
          width: 125,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.pink, // Set the background color to pink
            border: Border.all(color: Colors.white, width: 1), // Add white border
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (itemCount > 0) ...[
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      itemCount--;
                      widget.onCountChanged(itemCount);
                    });
                  },
                  color: Colors.white, // Set the color of the icon to white
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(), // Remove default button padding
                ),
                SizedBox(width: 3),
              ],
              Text(
                itemCount == 0 ? 'ADD' : itemCount.toString(),
                style: TextStyle(
                  color: Colors.white, // Set the color of the text to white
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 3),
              if (itemCount > 0) ...[
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      itemCount++;
                      widget.onCountChanged(itemCount);
                    });
                  },
                  color: Colors.white, // Set the color of the icon to white
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(), // Remove default button padding
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
