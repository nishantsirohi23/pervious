import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SuccessAlertDialog extends StatelessWidget {
  final String userName;

  const SuccessAlertDialog({Key? key, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            'assets/lottie/success.json',
            width: 100,
            height: 100,
          ),
          SizedBox(height: 20),
          Text(
            "Work has been assigned to $userName",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Perform any actions needed before closing the dialog
            Navigator.pop(context);
          },
          child: Text('Done'),
        ),
      ],
    );
  }
}
