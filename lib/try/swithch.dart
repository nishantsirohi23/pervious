import 'package:flutter/material.dart';

class PickedUpItemSwitch extends StatefulWidget {
  final String text;
  final Function(bool) onSwitchChanged;

  const PickedUpItemSwitch({Key? key, required this.text, required this.onSwitchChanged}) : super(key: key);

  @override
  _PickedUpItemSwitchState createState() => _PickedUpItemSwitchState();
}

class _PickedUpItemSwitchState extends State<PickedUpItemSwitch> {
  bool _isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.text,
        style: TextStyle(
          color: Colors.black,
          fontSize: 17
        ),),
        Switch(
          value: _isSwitched,
          onChanged: (value) {
            setState(() {
              _isSwitched = true;
            });
            widget.onSwitchChanged(value);
          },
        ),
      ],
    );
  }
}
