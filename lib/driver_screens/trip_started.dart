import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import './../driver_models/user_ride_request_information.dart';
import './../driver_global/map_key.dart';
import 'package:firebase_database/firebase_database.dart';

class DriverLocationService {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();

  void updateDriverLocation(String driverId, Position position) {
    _databaseReference.child('arriving_drivers').child(driverId).update({
      'latitude': position.latitude,
      'longitude': position.longitude,
    }).then((_) {
      print('Driver location updated successfully');
    }).catchError((error) {
      print('Failed to update driver location: $error');
    });
  }
}

class TripStarted extends StatefulWidget {
  final UserRideRequestInformation? userRideRequestDetails;

  TripStarted({this.userRideRequestDetails});

  @override
  State<TripStarted> createState() => _TripStartedState();
}

class _TripStartedState extends State<TripStarted> {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;

  Set<Polyline> polylineSet = {};
  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};
  double bottomPaddingOfMap = 0;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  late StreamSubscription<Position> _positionStreamSubscription;

  // Hardcoded destination latitude and longitude for Colombo
  static final LatLng destinationLatLng = LatLng(6.9271, 79.8612); // Colombo, Sri Lanka

  // To store the distance
  double distanceToDestination = 0;

  final String driverId = 'your_driver_id'; 
  final DriverLocationService _locationService = DriverLocationService();

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    _positionStreamSubscription = Geolocator.getPositionStream(
    ).listen((Position position) {
      LatLng userLatLng = LatLng(position.latitude, position.longitude);
      print("User Location: ${userLatLng.latitude}, ${userLatLng.longitude}"); // Debugging line
      _updateMap(userLatLng);
      _drawPolyline(userLatLng, destinationLatLng);
      _calculateDistance(userLatLng, destinationLatLng);
      _locationService.updateDriverLocation(driverId, position);
    });
  }

  void _updateMap(LatLng userLatLng) async {
    CameraPosition cameraPosition = CameraPosition(
      target: userLatLng,
      zoom: 12,
    );

    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    Marker currentLocationMarker = Marker(
      markerId: MarkerId("currentLocation"),
      position: userLatLng,
      infoWindow: InfoWindow(title: "Current Location"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );

    setState(() {
      markerSet.removeWhere((marker) => marker.markerId.value == "currentLocation");
      markerSet.add(currentLocationMarker);
    });
  }

  void _drawPolyline(LatLng startLatLng, LatLng endLatLng) async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      mapkey, 
      PointLatLng(startLatLng.latitude, startLatLng.longitude),
      PointLatLng(endLatLng.latitude, endLatLng.longitude),
    );

    if (result.points.isNotEmpty) {
      List<LatLng> polylineCoordinates = [];
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      setState(() {
        polylineSet.add(Polyline(
          polylineId: PolylineId("polyline"),
          color: Colors.blue,
          width: 5,
          points: polylineCoordinates,
        ));
      });
    }
  }

  void _calculateDistance(LatLng userLatLng, LatLng destinationLatLng) {
    double distanceInMeters = Geolocator.distanceBetween(
      userLatLng.latitude,
      userLatLng.longitude,
      destinationLatLng.latitude,
      destinationLatLng.longitude,
    );

    setState(() {
      distanceToDestination = distanceInMeters/1000;
    });

    if (distanceInMeters <= 100) {
      _onNearDestination();
    }
  }

  void _onNearDestination() {
    // Trigger your function here
    print("You are within 100 meters of the destination!");
  }

  @override
  void dispose() {
    _positionStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              myLocationEnabled: true,
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
              initialCameraPosition: _kGooglePlex,
              polylines: polylineSet,
              markers: markerSet,
              circles: circleSet,
              onMapCreated: (GoogleMapController controller) {
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;

                setState(() {
                  bottomPaddingOfMap = 20;
                });
              },
            ),
            Positioned(
              bottom: 10 + bottomPaddingOfMap,
              left: 10,
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(10),
                child: Text(
                  "Distance : ${distanceToDestination.toStringAsFixed(2)} km",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
