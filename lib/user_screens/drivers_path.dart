import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import './../driver_global/map_key.dart';
import 'home_screen.dart';
import 'rating_page.dart';

class DriverPath extends StatefulWidget {
  final String driverId;
  final String rideRequestId;

  DriverPath({
    required this.driverId,
    required this.rideRequestId,
  });

  @override
  State<DriverPath> createState() => _DriverPathState();
}

class _DriverPathState extends State<DriverPath> {
  Position? userCurrentPosition;
  LatLng? driverCurrentPosition;

  String? pickUpAddress;
  String? destinationAddress;

  LatLng? driverCurrentPositionLatLng;
  LatLng? pickUpLocationLatLng;
  LatLng? destinationLocationLatLng;

  String? driverName;
  String? driverPhone;
  String? driverVehicleNumber;
  String? vehicleType;

  String? capacity;
  String? weight;
  String? serviceType;
  String? time;

  BitmapDescriptor? _destinationIcon;
  BitmapDescriptor? _driverIcon;

  final Completer<GoogleMapController> _controllerGoogleMap = Completer<GoogleMapController>();
  GoogleMapController? newGoogleMapController;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); 

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(6.927079, 79.861244),
    zoom: 14,
  );

  Set<Marker> _markers = {};
  Set<Polyline> polylineSet = {};

  @override
  void initState() {
    super.initState();
    locateUserPosition();
    getTripDetails(widget.rideRequestId);
    _fetchDriverLocation();   
    _fetchDriverInformation();
    _loadCustomIcons();
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

  void _locateDestination() {
    Marker destinationMarker = Marker(
      markerId: MarkerId("destinationMarker"),
      position: destinationLocationLatLng!,
      infoWindow: InfoWindow(title: "destination Location"),
      icon: _destinationIcon!,
    );

    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value == "destinationMarker");
      _markers.add(destinationMarker);
    });
  }

  void _loadCustomIcons() async {
    try {
      _destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(48, 48)), 
        'images/destination.png',
      );

      _driverIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(48, 48)), 
        'images/driver_location.png',
      );

      // Locate the pickup marker only after the icons are loaded
      if (pickUpLocationLatLng != null) {
        _locateDestination();
      }
    } catch (e) {
      print("Error loading icons: $e");
    }
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

          _locateDestination();
        });
      }
    }).catchError((error) {
      print("Error in fetching trip details: $error");
    });
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
          driverVehicleNumber = data["vehicle_details"]["number"];
          vehicleType = data["vehicle_details"]["type"];
        });
      }
    }).catchError((error) {
      print("Error in fetching driver information: $error");
    });
  }

  void _rateDriver() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DriverPath(
          driverId: widget.driverId,
          rideRequestId: widget.rideRequestId,
        ),
      ),
    );
   
  }

  void _cancelRide() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => UserHomePage()));
    print("Ride canceled");
  }

  void _fetchDriverLocation() {
    DatabaseReference driverLocationRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(widget.driverId)
        .child("location");

    driverLocationRef.onValue.listen((event) async {
      if (event.snapshot.value != null) {
        Map data = event.snapshot.value as Map;
        double driverLat = double.parse(data['latitude'].toString());
        double driverLng = double.parse(data['longitude'].toString());

        LatLng driverPosition = LatLng(driverLat, driverLng);
        driverCurrentPosition = driverPosition;

        _updateDriverMarker(driverPosition);
        _drawPolyline(driverPosition, destinationLocationLatLng!);
        
        if (pickUpLocationLatLng != null) {
          double distanceToDestination = Geolocator.distanceBetween(
            driverPosition.latitude,
            driverPosition.longitude,
            destinationLocationLatLng!.latitude,
            destinationLocationLatLng!.longitude,
          );

          // Check if the driver is within 100 meters of the pickup location
          if (distanceToDestination <= 100) {
            _showTripComplete();
          }

          if (newGoogleMapController != null) {
            CameraPosition cameraPosition = CameraPosition(
              target: driverPosition,       
              zoom:14.0   
            );

            newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition)); 
          }
        }
      }
    });
  }

  void _updateDriverMarker(LatLng driverPosition) {
    if (_driverIcon != null) {
      Marker driverMarker = Marker(
        markerId: MarkerId("driverMarker"),
        position: driverPosition,
        infoWindow: InfoWindow(title: "Driver Location"),
        icon: _driverIcon!,
      );

      setState(() {
        _markers.removeWhere((marker) => marker.markerId.value == "driverMarker");
        _markers.add(driverMarker);
      });
    } else {
      print("Driver icon not initialized.");
    }
  }

  void _showTripComplete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delivery completed"),
          content: Text("Your driver has arrived at the destination location."),
          actions: [
            TextButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.pop(context);Navigator.pop(context);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => RatingsPage(
                  driverId: widget.driverId,
                  pickUpAddress: pickUpAddress,
                  destinationAddress: destinationAddress,
                )));
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
      key: _scaffoldKey, 
      appBar: AppBar(
          title: Text(
            "On the way to destination",
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
              subtitle: Text(driverVehicleNumber ?? 'No Number'),
            ),
            ListTile(
              leading: Icon(Icons.car_repair),
              title: Text('Vehicle Type'),
              subtitle: Text(vehicleType ?? 'No type'),
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
            initialCameraPosition: _kGooglePlex,
            polylines: polylineSet,
            myLocationEnabled: true,
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              _locateDestination();
            },
          ),
        ],
      ),
    );
  }
}
