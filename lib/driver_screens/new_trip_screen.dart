import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:users/driver_global/global.dart';
import 'package:users/driver_screens/pick_up.dart';
import './../driver_models/user_ride_request_information.dart';
import './../driver_global/map_key.dart';
import 'trip_started.dart';
import 'package:firebase_database/firebase_database.dart';

class NewTripScreen extends StatefulWidget {
  final UserRideRequestInformation? userRideRequestDetails;

  NewTripScreen({required this.userRideRequestDetails});

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;

  Set<Polyline> polylineSet = {};
  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};
  double bottomPaddingOfMap = 0;

  late BitmapDescriptor customIcon;  
  late BitmapDescriptor flagIcon;   

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(6.9271, 79.8612),
    zoom: 14,
  );

  late StreamSubscription<Position> _positionStreamSubscription;

  // To store the distance
  double distanceToDestination = 0;

  bool hasTriggeredNearDestination = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); 
  LatLng? pickupLatLng;

  @override
  void initState() {
    super.initState();
    _loadCustomIcons(); 
    _startLocationUpdates();
    pickupLatLng = widget.userRideRequestDetails?.originLatLng;
  }

  void _addDestinationMarker() {
    Marker destinationMarker = Marker(
      markerId: MarkerId("destination"),
      position: pickupLatLng!,
      infoWindow: InfoWindow(title: "Destination"),
      icon: flagIcon, // Use the flag icon
    );

    setState(() {
      markerSet.add(destinationMarker);
    });
  }

  // Function to load the custom icons
  void _loadCustomIcons() async {
    customIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(30, 30)),
      'images/driver_location.png',
    );

    flagIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(30, 30)),
      'images/destination.png',
    );

    _addDestinationMarker(); 
  }

  void _startLocationUpdates() {
    _positionStreamSubscription = Geolocator.getPositionStream().listen((Position position) {
      LatLng userLatLng = LatLng(position.latitude, position.longitude);
      print("User Location: ${userLatLng.latitude}, ${userLatLng.longitude}"); 
      _updateMap(userLatLng);
      _drawPolyline(userLatLng, pickupLatLng!);
      _calculateDistance(userLatLng, pickupLatLng!);
      _updateDriverLocationInDatabase(userLatLng);
    });
  }

  void _updateMap(LatLng userLatLng) async {
    if (newGoogleMapController != null) {
      CameraPosition cameraPosition = CameraPosition(
        target: userLatLng,
        zoom: 12,
      );

      newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      Marker currentLocationMarker = Marker(
        markerId: MarkerId("currentLocation"),
        position: userLatLng,
        infoWindow: InfoWindow(title: "Current Location"),
        icon: customIcon, // Use the custom icon for the current location
      );

      setState(() {
        markerSet.removeWhere((marker) => marker.markerId.value == "currentLocation");
        markerSet.add(currentLocationMarker);
      });
    }
  }

  void _updateDriverLocationInDatabase(LatLng driverLatLng) async {
    String driverId = currentUser!.uid;
    DatabaseReference driverLocationRef = FirebaseDatabase.instance
        .ref()
        .child('drivers')
        .child(driverId)
        .child('location');

    await driverLocationRef.set({
      'latitude': driverLatLng.latitude,
      'longitude': driverLatLng.longitude,
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
      distanceToDestination = distanceInMeters / 1000;
    });

    if (distanceInMeters <= 100 && !hasTriggeredNearDestination) {
      hasTriggeredNearDestination = true;
      _onNearDestination();
    }
  }

  void _onNearDestination() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => PickUpPage(userRideRequestDetails: widget.userRideRequestDetails!)));
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
        key: _scaffoldKey,  
        appBar: AppBar(
          title: Text(
            "On the way to pick up",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          
          backgroundColor: Colors.blueAccent,
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState!.openDrawer(); // Open drawer
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () {
                // Handle info icon tap
              },
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  'Ride Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                title: Text('User Name: ${widget.userRideRequestDetails?.userName ?? "N/A"}'),
              ),
              ListTile(
                title: Text('User Phone: ${widget.userRideRequestDetails?.userPhone ?? "N/A"}'),
              ),
              ListTile(
                title: Text('Origin Address: ${widget.userRideRequestDetails?.originAddress ?? "N/A"}'),
              ),
              ListTile(
                title: Text('Destination Address: ${widget.userRideRequestDetails?.destinationAddress ?? "N/A"}'),
              ),
              ListTile(
                title: Text('Service Type: ${widget.userRideRequestDetails?.serviceType ?? "N/A"}'),
              ),
              ListTile(
                title: Text('Capacity: ${widget.userRideRequestDetails?.capacity ?? "N/A"}'),
              ),
              ListTile(
                title: Text('Weight: ${widget.userRideRequestDetails?.weight ?? "N/A"}'),
              ),
              ListTile(
                title: Text('Instructions: ${widget.userRideRequestDetails?.instructions ?? "N/A"}'),
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
                if (!_controllerGoogleMap.isCompleted) {
                  _controllerGoogleMap.complete(controller);
                }
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
                  "Distance to PickUp : ${distanceToDestination.toStringAsFixed(2)} km",
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
