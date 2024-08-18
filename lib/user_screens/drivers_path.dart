import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import './../driver_models/user_ride_request_information.dart';
import './../driver_global/map_key.dart';

class DriverPath extends StatefulWidget {
  final String driverId;
  
  DriverPath({required this.driverId});

  @override
  State<DriverPath> createState() => _DriverPathState();
}

class _DriverPathState extends State<DriverPath> {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;

  Set<Polyline> polylineSet = {};
  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};
  double bottomPaddingOfMap = 0;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(6.9271, 79.8612), // Default position
    zoom: 14,
  );

  late LatLng destinationLatLng;
  late StreamSubscription<DatabaseEvent> _driverLocationSubscription;
  late DatabaseReference _driverLocationRef;
  double distanceToDestination = 0;

  @override
  void initState() {
    super.initState();
    destinationLatLng = LatLng(6.9271, 79.8612); // Set your actual destination coordinates here
    _startTrackingDriverLocation();
  }

  void _startTrackingDriverLocation() {
    _driverLocationRef = FirebaseDatabase.instance
        .ref()
        .child("accepted_drivers")
        .child(widget.driverId);

    _driverLocationSubscription = _driverLocationRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map data = event.snapshot.value as Map;
        double driverLat = double.parse(data['latitude'].toString());
        double driverLng = double.parse(data['longitude'].toString());

        LatLng driverLatLng = LatLng(driverLat, driverLng);

        _updateMap(driverLatLng);
        _drawPolyline(driverLatLng, destinationLatLng);
        _calculateDistance(driverLatLng, destinationLatLng);
      }
    });
  }

  void _updateMap(LatLng driverLatLng) async {
    CameraPosition cameraPosition = CameraPosition(
      target: driverLatLng,
      zoom: 12,
    );

    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    Marker driverMarker = Marker(
      markerId: MarkerId("driverMarker"),
      position: driverLatLng,
      infoWindow: InfoWindow(title: "Driver Location"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    setState(() {
      markerSet.removeWhere((marker) => marker.markerId.value == "driverMarker");
      markerSet.add(driverMarker);
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

  void _calculateDistance(LatLng driverLatLng, LatLng destinationLatLng) {
    double distanceInMeters = Geolocator.distanceBetween(
      driverLatLng.latitude,
      driverLatLng.longitude,
      destinationLatLng.latitude,
      destinationLatLng.longitude,
    );

    setState(() {
      distanceToDestination = distanceInMeters / 1000;
    });

    if (distanceInMeters <= 100) {
      _onNearDestination();
    }
  }

  void _onNearDestination() {
    // Trigger your function here
    print("Driver is within 100 meters of the destination!");
    // Add any additional logic here, e.g., navigating to another screen or displaying a dialog.
  }

  @override
  void dispose() {
    _driverLocationSubscription.cancel();
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
