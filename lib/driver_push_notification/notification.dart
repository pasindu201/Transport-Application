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
        title: Text(
          "Ride Request Details",
          style: TextStyle(
            color: darkTheme ? Colors.amber.shade400 : Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min, 
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: darkTheme ? Colors.amber.shade400 : Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "User Name: ${userRideRequestDetails.userName}",
                    style: TextStyle(color: darkTheme ? Colors.white70 : Colors.black),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, color: darkTheme ? Colors.amber.shade400 : Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "User Phone: ${userRideRequestDetails.userPhone}",
                    style: TextStyle(color: darkTheme ? Colors.white70 : Colors.black),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, color: darkTheme ? Colors.amber.shade400 : Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Origin: ${userRideRequestDetails.originAddress}",
                    style: TextStyle(color: darkTheme ? Colors.white70 : Colors.black),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on_outlined, color: darkTheme ? Colors.amber.shade400 : Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Destination: ${userRideRequestDetails.destinationAddress}",
                    style: TextStyle(color: darkTheme ? Colors.white70 : Colors.black),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              acceptRideRequest(userRideRequestDetails, context);
            },
            style: TextButton.styleFrom(
              foregroundColor: darkTheme ? Colors.amber.shade400 : Colors.blue,
            ),
            child: Text("Accept"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); 
            },
            style: TextButton.styleFrom(
              foregroundColor: darkTheme ? Colors.grey : Colors.red,
            ),
            child: Text("Close"),
          ),
        ],
        backgroundColor: darkTheme ? Colors.grey[850] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      );
    },
  );
}
