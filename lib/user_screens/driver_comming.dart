import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:users/user_screens/main_screen.dart';
import '../user_tab_pages/home.dart';
import './../driver_models/user_ride_request_information.dart';
import './../driver_global/map_key.dart';
import 'drivers_path.dart';

class DriverComming extends StatefulWidget {
  final String driverId;

  DriverComming({required this.driverId});

  @override
  State<DriverComming> createState() => _DriverCommingState();
}

class _DriverCommingState extends State<DriverComming> {
  Position? userCurrentPosition;
  LatLng? driverCurrentPosition;

  String? driverName;
  String? driverPhone;
  String? driverCarNumber;
  String? driverCarColor;

  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();
  GoogleMapController? newGoogleMapController;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14,
  );

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  
  final PolylinePoints _polylinePoints = PolylinePoints();
  List<LatLng> polylineCoordinates = [];

  @override
  void initState() {
    super.initState();
    locateUserPosition();
    _fetchDriverLocation();
  }

  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;

    LatLng latLngPosition =
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 15);

    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    _fetchDriverInformation();
  }

  void _fetchDriverInformation() {
    DatabaseReference driverInfoRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(widget.driverId);

    driverInfoRef.once().then((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        Map data = event.snapshot.value as Map;
        setState(() {
          driverName = data['name'];
          driverPhone = data['phone'];
          driverCarNumber = data["car_details"]["car_number"];
          driverCarColor = data["car_details"]["car_color"];
        });
      }
    });
  }

  void _acceptDriver() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => DriverPath(driverId: widget.driverId,)));
    print("Driver accepted");
  }

  void _cancelRide() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => Home()));
    print("Ride canceled");
  }

  void _fetchDriverLocation() {
    DatabaseReference driverLocationRef = FirebaseDatabase.instance
        .ref()
        .child("accepted_drivers")
        .child(widget.driverId);

    driverLocationRef.onValue.listen((event) async {
      if (event.snapshot.value != null) {
        Map data = event.snapshot.value as Map;
        double driverLat = double.parse(data['latitude'].toString());
        double driverLng = double.parse(data['longitude'].toString());

        LatLng driverPosition = LatLng(driverLat, driverLng);
        driverCurrentPosition = driverPosition;

        _updateDriverMarker(driverPosition);
        await _updatePolyline();  
      }
    });
  }

  void _updateDriverMarker(LatLng driverPosition) {
    Marker driverMarker = Marker(
      markerId: MarkerId("driverMarker"),
      position: driverPosition,
      infoWindow: InfoWindow(title: "Driver Location"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value == "driverMarker");
      _markers.add(driverMarker);
    });
  }

  Future<void> _updatePolyline() async {
    if (userCurrentPosition != null && driverCurrentPosition != null) {
      PolylineResult result = await _polylinePoints.getRouteBetweenCoordinates(
        mapkey, 
        PointLatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude),
        PointLatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude),
      );

      if (result.points.isNotEmpty) {
        polylineCoordinates.clear();  // Clear previous coordinates
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }

        setState(() {
          _polylines.add(Polyline(
            polylineId: PolylineId("polyline"),
            color: Colors.blue,
            width: 5,
            points: polylineCoordinates,
          ));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Coming'),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
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
                color: darkTheme ? Colors.black : Colors.blue,
              ),
              child: Text(
                'Driver Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Name'),
              subtitle: Text(driverName ?? 'No Name'),
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('Phone'),
              subtitle: Text(driverPhone ?? 'No Phone'),
            ),
            ListTile(
              leading: Icon(Icons.car_repair),
              title: Text('Vehicle Number'),
              subtitle: Text(driverCarNumber ?? 'No Number'),
            ),
            ListTile(
              leading: Icon(Icons.color_lens),
              title: Text('Vehicle Color'),
              subtitle: Text(driverCarColor ?? 'Not Found'),
            ),
            SizedBox(height: 20),
            ListTile(
              title: ElevatedButton(
                onPressed: _cancelRide,
                child: Text('Cancel Ride'),
              ),
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
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;
              locateUserPosition();
            },
          ),
        ],
      ),
    );
  }
}
