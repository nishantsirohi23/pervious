import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackProfLocation extends StatefulWidget {
  final String profId;

  const TrackProfLocation({Key? key, required this.profId}) : super(key: key);

  @override
  State<TrackProfLocation> createState() => _TrackProfLocationState();
}

class _TrackProfLocationState extends State<TrackProfLocation> {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _userDataStream;

  GoogleMapController? _mapController;
  late LatLng _currentPosition;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _userDataStream = FirebaseFirestore.instance.collection('prof').doc(widget.profId).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track Prof Location'),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _userDataStream,
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
          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return Center(
              child: Text('No data found for the provided prof ID.'),
            );
          }

          var userData = snapshot.data!.data()!;
          var latitude = userData['latitude'];
          var longitude = userData['longitude'];

          _currentPosition = LatLng(latitude, longitude);

          _updateCameraPosition(); // Update camera position here

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(target: _currentPosition, zoom: 15),
                onMapCreated: _onMapCreated,
                markers: {
                  Marker(
                    markerId: MarkerId('prof_location'),
                    position: _currentPosition,
                  ),
                },
              ),
              if (!_isMapReady)
                Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          );
        },
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      _isMapReady = true;
    });
  }

  void _updateCameraPosition() {
    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLng(_currentPosition));
    }
  }
}
