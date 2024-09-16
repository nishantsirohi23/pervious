import 'dart:async';
import 'package:flutter/material.dart';

class DynamicSearchBar extends StatefulWidget {
  final List<String> searchSuggestions;

  DynamicSearchBar({required this.searchSuggestions});

  @override
  _DynamicSearchBarState createState() => _DynamicSearchBarState();
}

class _DynamicSearchBarState extends State<DynamicSearchBar> {
  late Timer _timer;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    // Start a timer to update the index every few seconds
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        currentIndex = (currentIndex + 1) % widget.searchSuggestions.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200,width: 1)
      ),
      padding: EdgeInsets.only(top: 1,bottom: 3,left: 16,right: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for "${widget.searchSuggestions[currentIndex]}"',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Implement search functionality here
            },
          ),
        ],
      ),
    );
  }
}
