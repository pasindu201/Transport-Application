import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import '../user_tab_pages/home.dart';
import './../driver_models/user_ride_request_information.dart';
import './../driver_global/map_key.dart';
import 'drivers_path.dart';

class DriverComming extends StatefulWidget {
  final String driverId;
  final String rideRequestId;

  DriverComming({required this.driverId, required this.rideRequestId});

  @override
  State<DriverComming> createState() => _DriverCommingState();
}

class _DriverCommingState extends State<DriverComming> {
  Position? userCurrentPosition;
  LatLng? driverCurrentPosition;

  String? pickUpAddress;
  String? destinationAddress;

  LatLng? driverCurrentPositionLatLng;
  LatLng? pickUpLocationLatLng;
  LatLng? destinationLocationLatLng;

  String? driverName;
  String? driverPhone;
  String? driverCarNumber;

  String? capacity;
  String? weight;
  String? serviceType;
  String? time;

  final Completer<GoogleMapController> _controllerGoogleMap = Completer<GoogleMapController>();
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
    getTripDetails(widget.rideRequestId);
    _fetchDriverLocation();
  }

  void getTripDetails(String tripId) async {
    DatabaseReference rideRequestRef = FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(tripId);

    rideRequestRef.once().then((DatabaseEvent event) {
        if (event.snapshot.value != null) {
          Map data = event.snapshot.value as Map;
          setState(() {
            pickUpAddress = data['originAddress'];
            destinationAddress = data['destinationAddress'];
            
            capacity = data['capacity'];
            weight = data['weight'];
            serviceType = data['serviceType'];
            time = data['time'];

            pickUpLocationLatLng = LatLng(
              double.parse(data['origin']['latitude'].toString()),
              double.parse(data['origin']['longitude'].toString())
            );

            destinationLocationLatLng = LatLng(
              double.parse(data['destination']['latitude'].toString()),
              double.parse(data['destination']['longitude'].toString())
            );
          });
        }
      }).catchError((error) {
        print("Error in fetching trip details: $error");
      }
    );
  }

  Future<void> locateUserPosition() async {
    try {
      Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      userCurrentPosition = cPosition;

      LatLng latLngPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
      CameraPosition cameraPosition = CameraPosition(target: latLngPosition, zoom: 15);

      if (newGoogleMapController != null) {
        newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      }

      _fetchDriverInformation();
    } catch (e) {
      print("Error in locating user position: $e");
    }
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
          driverCarNumber = data["vehicle_details"]["number"];
        });
      }
    }).catchError((error) {
      print("Error in fetching driver information: $error");
    });
  }

  void _acceptDriver() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DriverPath(
          driverId: widget.driverId,
          driverName: driverName!,
          driverPhone: driverPhone!,
          vehicleNumber: driverCarNumber!,
          pickUpLocationAddress: pickUpAddress!,
          destinationLocationAddress: destinationAddress!,
          pickUpLatLng: pickUpLocationLatLng!,
          destinationLatLng: destinationLocationLatLng!,
        ),
      ),
    );
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
        
        if (pickUpLocationLatLng != null) {
          double distanceToPickUp = Geolocator.distanceBetween(
            driverPosition.latitude,
            driverPosition.longitude,
            pickUpLocationLatLng!.latitude,
            pickUpLocationLatLng!.longitude,
          );

          // Check if the driver is within 100 meters of the pickup location
          if (distanceToPickUp <= 100) {
            _showDriverArrivedDialog();
          }

          if (newGoogleMapController != null) {
            CameraPosition cameraPosition = CameraPosition(
              target: driverPosition, 
              zoom: 14.0,             
            );

            newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition)); 
          }
        }
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

  void _showDriverArrivedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Driver has arrived"),
          content: Text("Your driver has arrived at the pickup location."),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
              leading: Icon(Icons.directions_car),
              title: Text('Car Number'),
              subtitle: Text(driverCarNumber ?? 'No Car Number'),
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text('Pickup Address'),
              subtitle: Text(pickUpAddress ?? 'No Pickup Address'),
            ),
            ListTile(
              leading: Icon(Icons.location_city),
              title: Text('Destination Address'),
              subtitle: Text(destinationAddress ?? 'No Destination Address'),
            ),
            ElevatedButton(
              child: Text("Cancel Ride"),
              onPressed: _cancelRide,
            ),
          ],
        ),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        myLocationEnabled: true,
        initialCameraPosition: _kGooglePlex,
        markers: _markers,
        polylines: _polylines,
        onMapCreated: (GoogleMapController controller) {
          _controllerGoogleMap.complete(controller);
          newGoogleMapController = controller;
        },
      ),
    );
  }
}
