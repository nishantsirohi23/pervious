import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screens/costumer/showmywork.dart';
import '../screens/maps/directionScreen.dart';

void workTreeNavigator(BuildContext context, Map<String, dynamic> data) {
  // Check if the required fields exist and have valid values
  String status = data['status'] ?? '';
  String toAddress = data['toaddress'] ?? '';
  String fromAddress = data['fromaddress'] ?? '';

  // First condition: status is 'track' and both addresses are valid
  if (status == "track" && toAddress != "Pick To Location" && fromAddress.isNotEmpty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Navigation(
          workid: data['id'],
          destlat: data['tolatitude'],
          destlong: data['tolongitude'],
          sourcelat: data['fromlatitude'],
          sourcelong: data['fromlongitude'],
          profid: data['assigned'],
        ),
      ),
    );
  }
  // Second condition: status is NOT 'track' and both addresses are valid
  else if (status != "track" && toAddress != "Pick To Location" && fromAddress.isNotEmpty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShowMyWork(workid: data['id']),
      ),
    );
  }
  // Default case: ShowMyWork for all other conditions
  else {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShowMyWork(workid: data['id']),
      ),
    );
  }
}
