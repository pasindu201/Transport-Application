import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:users/user_screens/main_screen.dart';
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

  String? driverName;
  String? driverPhone;
  String? driverCarModel;
  String? driverCarColor;
  String? driverCarNumber;

  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();
  GoogleMapController? newGoogleMapController;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14,
  );

  Set<Marker> _markers = {};

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
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => UserMainScreen()));
    print("Ride canceled");
  }

  void _fetchDriverLocation() {
    DatabaseReference driverLocationRef = FirebaseDatabase.instance
        .ref()
        .child("accepted_drivers")
        .child(widget.driverId);

    driverLocationRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map data = event.snapshot.value as Map;
        double driverLat = double.parse(data['latitude'].toString());
        double driverLng = double.parse(data['longitude'].toString());

        LatLng driverPosition = LatLng(driverLat, driverLng);

        _updateDriverMarker(driverPosition);
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
      _markers.add(driverMarker);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
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
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;
                locateUserPosition();
              },
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  color: darkTheme ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text(
                        "Driver Status",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Divider(
                        thickness: 1,
                        color: darkTheme
                            ? Colors.amber.shade400
                            : Colors.blue,
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: darkTheme
                                      ? Colors.amber.shade400
                                      : Colors.lightBlue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Driver Name",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    driverName ?? "No Name",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      ),

                      SizedBox(height: 5),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: darkTheme
                                      ? Colors.amber.shade400
                                      : Colors.lightBlue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.phone,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Driver Phone",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    driverPhone ?? "No Phone",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      ),

                      SizedBox(height: 5),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: darkTheme
                                      ? Colors.amber.shade400
                                      : Colors.lightBlue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.phone,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Vehicle Number",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    driverCarNumber ?? "No Number",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      ),

                      SizedBox(height: 5),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: darkTheme
                                      ? Colors.amber.shade400
                                      : Colors.lightBlue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.car_rental,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Vehicle Color",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    driverCarColor ?? "Can not found",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: _acceptDriver,
                            child: Text("Accept Driver"),
                          ),
                          ElevatedButton(
                            onPressed: _cancelRide,
                            child: Text("Cancel Ride"),
                            style: ElevatedButton.styleFrom(
                            ),
                          ),
                        ],
                      ),
                    ],
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
