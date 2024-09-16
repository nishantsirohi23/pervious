import 'package:flutter/material.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';

class PickLocation extends StatefulWidget {
  final Function(double, double, String) onLocationPicked;

  const PickLocation({Key? key, required this.onLocationPicked}) : super(key: key);

  @override
  State<PickLocation> createState() => _PickLocationState();
}

class _PickLocationState extends State<PickLocation> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Location Picker',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Pick Location'),
        ),
        body: FlutterLocationPicker(
          initZoom: 11,
          minZoomLevel: 5,
          maxZoomLevel: 20,
          trackMyPosition: true,
          searchBarBackgroundColor: Colors.white,
          selectedLocationButtonTextstyle: const TextStyle(fontSize: 18),
          mapLanguage: 'en',
          onError: (e) => print(e),
          selectLocationButtonLeadingIcon: const Icon(Icons.check),
          onPicked: (pickedData) {
            double longitude = pickedData.latLong.longitude;
            double latitude = pickedData.latLong.latitude;
            String address = pickedData.address;
            widget.onLocationPicked(longitude, latitude, address);
            Navigator.pop(context);
          },
          onChanged: (pickedData) {
            // Optional: Handle onChanged event
          },
          showContributorBadgeForOSM: true,
        ),
      ),
    );
  }
}
