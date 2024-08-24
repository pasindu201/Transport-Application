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

class DriverComing extends StatefulWidget {
  final String driverId;
  final String rideRequestId;

  DriverComing({required this.driverId, required this.rideRequestId});

  @override
  State<DriverComing> createState() => _DriverComingState();
}

class _DriverComingState extends State<DriverComing> {
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

  BitmapDescriptor? _pickupIcon;
  BitmapDescriptor? _driverIcon;

  final Completer<GoogleMapController> _controllerGoogleMap = Completer<GoogleMapController>();
  GoogleMapController? newGoogleMapController;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
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

  void _locatePickUp() {
    if (pickUpLocationLatLng != null && _pickupIcon != null) {
      Marker pickUpMarker = Marker(
        markerId: MarkerId("pickUpMarker"),
        position: pickUpLocationLatLng!,
        infoWindow: InfoWindow(title: "Pickup Location"),
        icon: _pickupIcon!,
      );

      setState(() {
        _markers.removeWhere((marker) => marker.markerId.value == "pickUpMarker");
        _markers.add(pickUpMarker);
      });
    } else {
      print("Pick-up location or icon not initialized.");
    }
  }

  void _loadCustomIcons() async {
    try {
      _pickupIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(48, 48)), 
        'images/destination.png',
      );

      _driverIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(48, 48)), 
        'images/driver_location.png',
      );

      // Locate the pickup marker only after the icons are loaded
      if (pickUpLocationLatLng != null) {
        _locatePickUp();
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

          // After setting the pickup location, add the marker
          _locatePickUp();
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

  void _acceptDriver() {
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
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => Home()));
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
        _drawPolyline(driverPosition, pickUpLocationLatLng!);
        
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

  void _showDriverArrivedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Driver has arrived"),
          content: Text("Your driver has arrived at the pickup location."),
          actions: [
            TextButton(
              child: Text("Start Trip"),
              onPressed: () {
                _acceptDriver();
              },
            ),
            TextButton(
              child: Text("Cancel"),
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

              // Locate the pickup location on map creation
              _locatePickUp();
            },
          ),
        ],
      ),
    );
  }
}
