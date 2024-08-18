import 'package:flutter/material.dart';
import '../driver_assistants/assistant_methods.dart';
import '../driver_global/global.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import '../driver_models/user_ride_request_information.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../driver_screens/new_trip_screen.dart';

void updateDriverLocation(String driverId) {
  FirebaseDatabase.instance.ref().child("accepted_drivers").child(driverId).set({
    "latitude": driverCurrentPosition!.latitude,
    "longitude": driverCurrentPosition!.longitude,
  });
}

acceptRideRequest(UserRideRequestInformation userRideRequestDetails, BuildContext context){
  updateDriverLocation(firebaseAuth.currentUser!.uid);
  FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("newRideStatus").set("accepted");
  FirebaseDatabase.instance.ref().child("All Ride Requests").child(userRideRequestDetails.rideRequestId!).child("driverId").set(firebaseAuth.currentUser!.uid);
  AssistantMethods.pauseLiveLocationUpdate();
  Navigator.push(context, MaterialPageRoute(builder: (c) => NewTripScreen(
    userRideRequestDetails: userRideRequestDetails,
    )
    )
  );           
}

void showSimpleDialog(UserRideRequestInformation userRideRequestDetails, BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
      return AlertDialog(
        title: Text("Dialog Title"),
        content: Column(
          children: [
            Text("User Name: ${userRideRequestDetails.userName}"),
            Text("User Phone: ${userRideRequestDetails.userPhone}"),
            Text("Origin Address: ${userRideRequestDetails.originAddress}"),
            Text("Destination Address: ${userRideRequestDetails.destinationAddress}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              acceptRideRequest(userRideRequestDetails, context);
            },
            child: Text("Accept"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Closes the dialog
            },
            child: Text("Close"),
          ),
        ],
      );
    },
  );


}