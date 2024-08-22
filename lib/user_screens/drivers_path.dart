import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import './../driver_global/map_key.dart';
import 'rating_page.dart';

class DriverPath extends StatefulWidget {
  final String driverId;
  final String driverName;
  final String driverPhone;
  final String vehicleNumber;

  final String pickUpLocationAddress;
  final String destinationLocationAddress;

  LatLng? pickUpLatLng;
  LatLng? destinationLatLng;

  DriverPath({
    required this.driverId,
    required this.driverName,
    required this.driverPhone,
    required this.vehicleNumber,
    required this.pickUpLocationAddress,
    required this.destinationLocationAddress,
    this.pickUpLatLng,
    this.destinationLatLng,
  });

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
    destinationLatLng = widget.destinationLatLng!;
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
    print("Driver is within 100 meters of the destination!");

    // Show dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Near Destination"),
          content: Text("Driver Came Near Destination"),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RatingPage(driverId: widget.driverId, pickUpAddress: widget.pickUpLocationAddress, destinationAddress: widget.destinationLocationAddress,),
                ),
              );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _driverLocationSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.destinationLocationAddress),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Trip Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Driver Name'),
              subtitle: Text(widget.driverName),
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('Driver Phone'),
              subtitle: Text(widget.driverPhone),
            ),
            ListTile(
              leading: Icon(Icons.directions_car),
              title: Text('Vehicle Number'),
              subtitle: Text(widget.vehicleNumber),
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text('Pickup Location'),
              subtitle: Text(widget.pickUpLocationAddress),
            ),
            ListTile(
              leading: Icon(Icons.flag),
              title: Text('Destination'),
              subtitle: Text(widget.destinationLocationAddress),
            ),
          ],
        ),
      ),
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
                "Distance: ${distanceToDestination.toStringAsFixed(2)} km",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
