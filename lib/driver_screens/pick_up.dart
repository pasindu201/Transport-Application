import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:users/driver_screens/trip_started.dart';

import '../driver_models/user_ride_request_information.dart';

class PickUpPage extends StatefulWidget {
  final UserRideRequestInformation userRideRequestDetails;

  const PickUpPage({required this.userRideRequestDetails, Key? key}) : super(key: key);

  @override
  State<PickUpPage> createState() => _PickUpPageState();
}

class _PickUpPageState extends State<PickUpPage> {
  double? distance;

  @override
  void initState() {
    super.initState();
    calculateDistance();
  }

  void calculateDistance() async {
    if (widget.userRideRequestDetails.originLatLng != null &&
        widget.userRideRequestDetails.destinationLatLng != null) {
      double calculatedDistance = Geolocator.distanceBetween(
        widget.userRideRequestDetails.originLatLng!.latitude,
        widget.userRideRequestDetails.originLatLng!.longitude,
        widget.userRideRequestDetails.destinationLatLng!.latitude,
        widget.userRideRequestDetails.destinationLatLng!.longitude,
      );

      setState(() {
        distance = calculatedDistance / 1000; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pick-Up Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "User: ${widget.userRideRequestDetails.userName}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text("Phone: ${widget.userRideRequestDetails.userPhone}"),
            SizedBox(height: 10),
            Text("Pick-Up Location: ${widget.userRideRequestDetails.originAddress}"),
            SizedBox(height: 10),
            Text("Destination: ${widget.userRideRequestDetails.destinationAddress}"),
            SizedBox(height: 10),
            if (distance != null)
              Text("Distance: ${distance!.toStringAsFixed(2)} km"),
            SizedBox(height: 20),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => TripStarted(userRideRequestDetails: widget.userRideRequestDetails!)));
                },
                child: Text("Start Trip"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
