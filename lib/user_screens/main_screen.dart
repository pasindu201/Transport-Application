import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:geolocator/geolocator.dart';
import '../user_assistants/assistant_methods.dart';
import '../user_global/global.dart';
import '../user_infoHandler/app_info.dart';
import 'package:provider/provider.dart';
import '../user_models/active_nearby_available_drivers.dart';
import 'drawer_screen.dart';
import 'driver_comming.dart';
import 'precise_pickup_location.dart';
import 'search_places-screen.dart';
import '../splash_screen/splash_screen.dart';
import '../user_widgets/progress_dialog.dart';
import '../user_assistants/grofire_assistant.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_database/firebase_database.dart';

import '../user_widgets/pay_fare_amount_dialog.dart';

class UserMainScreen extends StatefulWidget {
  String? serviceType;
  String? capacity;
  String? weight;
  String? instructions;
  
  UserMainScreen({required this.serviceType, required this.capacity, required this.weight, required this.instructions});

  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  LatLng? pickLocation;
  loc.Location location = loc.Location();

  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  double searchLocationContainerHeight = 220;
  double waitingResponsefromDriverContainerHeight = 0;
  double assignedDriverContainerHeight = 0;

  Position? userCurrentPosition;
  var geoLocation = Geolocator();

  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;

  List<LatLng> pLineCoordinatedList = [];
  Set<Polyline> polylineSet = {};

  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};

  String userName = "";
  String userEmail = "";
  String selectedVehicleType = "";

  String userRideRequestStatus = "";

  String driverRideStatus = "Driver is coming";
  StreamSubscription<DatabaseEvent>? tripRideRequestInfoStreamSubscription;

  bool openNavigationDrawer = true;
  bool requestPositionInfo = true;
  bool activeNearbyDriverKeysLoaded = false;

  BitmapDescriptor? activeNearbyIcon;
  DatabaseReference? referenceRideRequest;

  double suggestedRidesContainerHeight = 0;
  double showSearchingForDriversContainerHeight = 0;

  final geo = GeoFlutterFire();
  late Stream<List<DocumentSnapshot>> stream;

  List<ActiveNearbyAvailableDrivers> onlineNearByAvailableDriversList = [];

  locateUserPossion() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    CameraPosition cameraPosition = CameraPosition(target: latLngPosition, zoom: 15);

    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress =
        await AssistantMethods.searchAddressForGeographicCoordinates(
            userCurrentPosition!, context);
    print("This is our address = $humanReadableAddress");

    userName = userModelCurrentinfo!.name!;
    userEmail = userModelCurrentinfo!.email!;

    initializeGeoFireListener();
    //
    // AssistantMethods.readTripskeysForOnlineUser(context);
  }

  void initializeGeoFireListener() {
    Geofire.initialize("activeDrivers");

    Geofire.queryAtLocation(
            userCurrentPosition!.latitude, userCurrentPosition!.longitude, 20)!
        .listen((map) {
      print(map);

      if (map != null) {
        var callBack = map['callBack'];
        switch (callBack) {
          case Geofire.onKeyEntered:
            ActiveNearbyAvailableDrivers activeNearbyAvailableDrivers = ActiveNearbyAvailableDrivers();
            activeNearbyAvailableDrivers.driverId = map['key'];
            activeNearbyAvailableDrivers.locationLatitude = map['latitude'];
            activeNearbyAvailableDrivers.locationLongitude = map['longitude'];
            GeofireAssistant.activeNearbyDriverList
                .add(activeNearbyAvailableDrivers);

            if (activeNearbyDriverKeysLoaded) {
              updateAvailableDriversOnMap();
            }
            break;

          case Geofire.onKeyExited:
            GeofireAssistant.deleteOfflineDrivers(map['key']);
            updateAvailableDriversOnMap();
            break;

          case Geofire.onKeyMoved:
            ActiveNearbyAvailableDrivers activeNearbyAvailableDrivers =
                ActiveNearbyAvailableDrivers();
            activeNearbyAvailableDrivers.driverId = map['key'];
            activeNearbyAvailableDrivers.locationLatitude = map['latitude'];
            activeNearbyAvailableDrivers.locationLongitude = map['longitude'];
            GeofireAssistant.updateDriverLocation(activeNearbyAvailableDrivers);
            updateAvailableDriversOnMap();
            break;

          case Geofire.onGeoQueryReady:
            activeNearbyDriverKeysLoaded = true;
            updateAvailableDriversOnMap();
            break;
        }
      }
    });
  }

  updateAvailableDriversOnMap() {
    setState(() {
      markerSet.clear();
      circleSet.clear();

      Set<Marker> driverMarkerSet = Set<Marker>();

      for (ActiveNearbyAvailableDrivers driver in GeofireAssistant.activeNearbyDriverList) {
        LatLng driverAvailablePosition = LatLng(driver.locationLatitude!, driver.locationLongitude!);

        Marker driverMarker = Marker(
          markerId: MarkerId("driver${driver.driverId}"),
          position: driverAvailablePosition,
          icon: activeNearbyIcon!,
          rotation: 360,
        );

        driverMarkerSet.add(driverMarker);
      }

      setState(() {
        markerSet.addAll(driverMarkerSet);
      });
    });
  }

  createActiveNearbyDriverIconMarker() {
    if (activeNearbyIcon == null) {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car.png")
          .then((value) => activeNearbyIcon = value);
    }
  }

  Future<void> drawPolyLineFromOriginToDestination(bool darkTheme) async {
    var originPosition =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationPosition =
        Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    if (originPosition == null || destinationPosition == null) {
      // Handle the error case where positions are not available
      return;
    }

    var originLatLng = LatLng(
        originPosition.locationLatitude!, originPosition.locationLongitude!);
    var destinationLatLng = LatLng(destinationPosition.locationLatitude!,
        destinationPosition.locationLongitude!);

    showDialog(
      context: context,
      builder: (BuildContext context) =>
          ProgressDialog(message: "Please wait..."),
    );

    var directionDetailedInfo =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            originLatLng, destinationLatLng);

    Navigator.pop(context); // Close the progress dialog

    if (directionDetailedInfo == null) {
      // Handle the error case where direction details are not available
      return;
    }

    List<PointLatLng> decodedPolyLinePoints = directionDetailedInfo;
    List<LatLng> polylineCoordinates = decodedPolyLinePoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();

    setState(() {
      pLineCoordinatedList.clear();
      pLineCoordinatedList.addAll(polylineCoordinates);

      Polyline polyline = Polyline(
        color: darkTheme ? Colors.amberAccent : Colors.blue,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoordinatedList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5,
      );

      polylineSet.clear();
      polylineSet.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if (originLatLng.latitude > destinationLatLng.latitude &&
        originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng =
          LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    } else if (originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    } else {
      boundsLatLng = LatLngBounds(
        southwest: originLatLng,
        northeast: destinationLatLng,
      );
    }

    newGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
        markerId: MarkerId("originID"),
        infoWindow:
            InfoWindow(title: originPosition.locationName, snippet: "Origin"),
        position: originLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen));

    Marker destinationMarker = Marker(
        markerId: MarkerId("destinationID"),
        infoWindow: InfoWindow(
            title: destinationPosition.locationName, snippet: "Destination"),
        position: destinationLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));

    setState(() {
      markerSet.add(originMarker);
      markerSet.add(destinationMarker);
    });

    Circle originCircle = Circle(
        circleId: CircleId("originID"),
        fillColor: Colors.green,
        radius: 12,
        strokeWidth: 3,
        strokeColor: Colors.white,
        center: originLatLng);

    Circle destinationCircle = Circle(
        circleId: CircleId("destinationID"),
        fillColor: Colors.red,
        radius: 12,
        strokeWidth: 3,
        strokeColor: Colors.white,
        center: destinationLatLng);

    setState(() {
      circleSet.add(originCircle);
      circleSet.add(destinationCircle);
    });
  }

  void  showSuggestedRideContainer(){
    setState(() {
      suggestedRidesContainerHeight = 400;
      bottomPaddingOfMap = 400;
    });
  }

  updateArrivalTimeToUserPickUpLocation(driverCurrentPositionLatLng) async{
    if(requestPositionInfo){
      requestPositionInfo = false;
      LatLng userPickUpPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

      var directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(driverCurrentPositionLatLng, userPickUpPosition);

      if(directionDetailsInfo == null){
        return;
      }
      setState(() {
        driverRideStatus = "Driver is coming....";
      });
    }
  }

  saveRideRequestInformation(){
    referenceRideRequest = FirebaseDatabase.instance.ref().child("All Ride Requests").push();

    var originLocation = Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationLocation = Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    Map originLocationMap = {
      "latitude":originLocation!.locationLatitude.toString(),
      "longitude":originLocation.locationLongitude.toString()
    };

    Map destinationLocationMap = {
      "latitude":destinationLocation!.locationLatitude.toString(),
      "longitude":destinationLocation.locationLongitude.toString()
    };

    Map userInformationMap = {
      "origin":originLocationMap,
      "destination":destinationLocationMap,
      "time":DateTime.now().toString(),
      "userName":userModelCurrentinfo!.name,
      "userPhone":userModelCurrentinfo!.phone,
      "originAddress":originLocation.locationName,
      "destinationAddress":destinationLocation!.locationName,
      "driverId":"waiting",
      "serviceType":widget.serviceType,
      "capacity":widget.capacity,
      "weight":widget.weight,
      "instructions":widget.instructions,
    };

    referenceRideRequest!.set(userInformationMap);

    onlineNearByAvailableDriversList = GeofireAssistant.activeNearbyDriverList;
    searchNearestOnlineDrivers();

  }

  showSearchingForDriversContainer(){
      setState(() {
         showSearchingForDriversContainerHeight = 200;
      });
   
  }

  searchNearestOnlineDrivers() async{
    if(onlineNearByAvailableDriversList.length == 0) {
      //cancel/delete the ride request information.
      referenceRideRequest!.remove();

      setState(() {
        polylineSet.clear();
        markerSet.clear();
        circleSet.clear();
        pLineCoordinatedList.clear();
      });

      Fluttertoast.showToast(msg: "No online nearest drivers avalibale...");
      Fluttertoast.showToast(msg: "Search again...\n Restarting App");

      Future.delayed(Duration(seconds: 4), (){
        referenceRideRequest!.remove();
        Navigator.push(context, MaterialPageRoute(builder: (c) => SplashScreen()));
      });
      return;
    }

    await retriveOnlineDriversInformation(onlineNearByAvailableDriversList);

    print("driversList: " + driversList.toString());

    for (int i = 0; i < driversList.length; i++) {
        if (referenceRideRequest?.key != null) {
          AssistantMethods.sendNotificationToSelectedDriver(
            driversList[i]["token"], 
            context,
            referenceRideRequest!.key!
          );
        }
    }

    Fluttertoast.showToast(msg: "Notification sent Successfully...");

    showSearchingForDriversContainer();

    await FirebaseDatabase.instance.ref().child("All Ride Requests").child(referenceRideRequest!.key!).child("driverId").onValue.listen((eventRideRequestSnapShot) {
      print("EventSnapshot: + ${eventRideRequestSnapShot.snapshot.value}");
      if (eventRideRequestSnapShot.snapshot.value != "waiting") {
        // Navigate to the DriverComming page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DriverComing(
              driverId: eventRideRequestSnapShot.snapshot.value.toString(),
              rideRequestId: referenceRideRequest!.key!
            ),
          ),
        );
      }
    });  
  }

  retriveOnlineDriversInformation(List onlineNearestDriversList) async{
    driversList.clear();
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers");

    for(int i=0; i<onlineNearestDriversList.length; i++){
      await ref.child(onlineNearestDriversList[i].driverId.toString()).once().then((dataSnapshot){
        var driverKeyInfo = dataSnapshot.snapshot.value;

        driversList.add(driverKeyInfo);
        print("Driver key information = ${driversList.toString()}");
      });
    }
  }

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  @override
  void initState() {
    super.initState();
    checkIfLocationPermissionAllowed();
  }

  @override
  Widget build(BuildContext context) {

    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    createActiveNearbyDriverIconMarker();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _scaffoldState,
        drawer: DrawerScreen(),
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
                  bottomPaddingOfMap = 200;
                });
                locateUserPossion();
              },
            ),
            Positioned(
                top: 50,
                left: 20,
                child: Container(
                  child: GestureDetector(
                    onTap: () {
                      _scaffoldState.currentState!.openDrawer();
                    },
                    child: CircleAvatar(
                      backgroundColor:
                          darkTheme ? Colors.amber.shade400 : Colors.white,
                      child: Icon(
                        Icons.menu,
                        color: darkTheme ? Colors.black : Colors.lightBlue,
                      ),
                    ),
                  ),
                )),

            // Ui for searching location
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 50, 10, 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: darkTheme ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  color: darkTheme
                                      ? Colors.grey.shade900
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          color: darkTheme
                                              ? Colors.amber.shade400
                                              : Colors.blue,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("From",
                                                style: TextStyle(
                                                    color: darkTheme
                                                        ? Colors.amber.shade400
                                                        : Colors.blue,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(
                                              Provider.of<AppInfo>(context)
                                                          .userPickUpLocation !=
                                                      null
                                                  ? (Provider.of<AppInfo>(
                                                                  context)
                                                              .userPickUpLocation!
                                                              .locationName!)
                                                          .substring(0, 24) +
                                                      "..."
                                                  : "Not getting Address",
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Divider(
                                    height: 1,
                                    thickness: 2,
                                    color: darkTheme
                                        ? Colors.amber.shade400
                                        : Colors.blue,
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(5),
                                    child: GestureDetector(
                                      onTap: () async {
                                        //go to search places screen
                                        var responceFromSearchScreen =
                                            await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (c) =>
                                                        SearchPlacesScreen()));

                                        if (responceFromSearchScreen ==
                                            "obtainedDropoff") {
                                          setState(() {
                                            openNavigationDrawer = false;
                                          });
                                        }

                                        await drawPolyLineFromOriginToDestination(
                                            darkTheme);
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.location_on_outlined,
                                            color: darkTheme
                                                ? Colors.amber.shade400
                                                : Colors.blue,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("To",
                                                  style: TextStyle(
                                                      color: darkTheme
                                                          ? Colors
                                                              .amber.shade400
                                                          : Colors.blue,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text(
                                                Provider.of<AppInfo>(context)
                                                                .userDropOffLocation !=
                                                            null &&
                                                        Provider.of<AppInfo>(
                                                                    context)
                                                                .userDropOffLocation!
                                                                .locationName !=
                                                            null
                                                    ? Provider.of<AppInfo>(
                                                                    context)
                                                                .userDropOffLocation!
                                                                .locationName!
                                                                .length >
                                                            24
                                                        ? Provider.of<AppInfo>(
                                                                    context)
                                                                .userDropOffLocation!
                                                                .locationName!
                                                                .substring(
                                                                    0, 24) +
                                                            "..."
                                                        : Provider.of<AppInfo>(
                                                                context)
                                                            .userDropOffLocation!
                                                            .locationName!
                                                    : "Where to?",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14,
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (c) =>
                                                PrecisePickupScreen()));
                                  },
                                  child: Text(
                                    "Change Pick Up",
                                    style: TextStyle(
                                      color: darkTheme
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: darkTheme
                                          ? Colors.amber.shade400
                                          : Colors.blue,
                                      textStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      )),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if(Provider.of<AppInfo>(context, listen: false).userDropOffLocation != null){
                                      saveRideRequestInformation();
                                    }
                                    else{
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select Destination location"),));
                                    }
                                  },
                                  child: Text(
                                    "Find a Driver",
                                    style: TextStyle(
                                      color: darkTheme
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: darkTheme
                                          ? Colors.amber.shade400
                                          : Colors.blue,
                                      textStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      )),
                                )
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: showSearchingForDriversContainerHeight,
                decoration: BoxDecoration(
                  color: darkTheme? Colors.black : Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        LinearProgressIndicator(
                          color: darkTheme? Colors.amber.shade400 : Colors.blue,
                        ),

                        SizedBox(height: 10,),

                        Center(
                          child: Text(
                            "Searching for Drivers...",
                             style: TextStyle(
                              color: Colors.grey,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                             ),
                          ),
                        ),

                        SizedBox(height: 10,),

                        GestureDetector(
                          onTap: (){
                            referenceRideRequest!.remove();
                            setState(() {
                              showSearchingForDriversContainerHeight = 0;
                              suggestedRidesContainerHeight = 0;
                            });
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: darkTheme? Colors.amber.shade400 : Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(width: 1, color: Colors.grey)
                            ),
                            child: Icon(Icons.close, size: 25,),
                          ),
                        ),

                        SizedBox(height: 10,),

                        Container(
                          width: double.infinity,
                          child: Text(
                            "Cancel",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              ),
                          )
                        )
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
