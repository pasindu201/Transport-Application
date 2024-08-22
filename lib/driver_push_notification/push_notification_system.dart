import 'package:users/driver_push_notification/notification.dart';
import '../driver_global/global.dart';
import '../driver_models/user_ride_request_information.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PushNotificationSystem{
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String userRideRequestId = "";

  Future initializeCloudMessaging(BuildContext context) async {
    //1.Terminated.
    //When the app is terminated and the user taps on the push notification.
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      userRideRequestId = message!.data["tripID"];
      Fluttertoast.showToast(msg: "Notification opened in background");
      if (userRideRequestId != "") {
        readUserRideRequestInformation(userRideRequestId, context);
      }
    });

    //2.Foreground.
    //When the app is in the foreground and the user receives a push notification.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      userRideRequestId = message!.data["tripID"];
      Fluttertoast.showToast(msg: "Notification opened in background");
      if (userRideRequestId != "") {
        readUserRideRequestInformation(userRideRequestId, context);
      }
    });

    //3.background.
    //When the app is in the background and the user receives a push notification.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      userRideRequestId = message!.data["tripID"];
      Fluttertoast.showToast(msg: "Notification opened in background");
      readUserRideRequestInformation(userRideRequestId, context);
    });
  }

  readUserRideRequestInformation(String userRideRequestId, BuildContext context) {
    FirebaseDatabase.instance.ref().child("All Ride Requests").child(userRideRequestId).child("driverId").onValue.listen((event){
      if(event.snapshot.value == "waiting" || event.snapshot.value == firebaseAuth.currentUser!.uid){
        FirebaseDatabase.instance.ref().child("All Ride Requests").child(userRideRequestId).once().then((snapData){
          if(snapData.snapshot.value != null){

            double originLat = double.parse((snapData.snapshot.value! as Map)["origin"]["latitude"]);
            double originLng = double.parse((snapData.snapshot.value! as Map)["origin"]["longitude"]);
            String originAddress = (snapData.snapshot.value! as Map)["originAddress"];

            double destinationLat = double.parse((snapData.snapshot.value! as Map)["destination"]["latitude"]);
            double destinationLng = double.parse((snapData.snapshot.value! as Map)["destination"]["longitude"]);
            String destinationAddress = (snapData.snapshot.value! as Map)["destinationAddress"];

            String userName = (snapData.snapshot.value! as Map)["userName"];
            String userPhone = (snapData.snapshot.value! as Map)["userPhone"];
            String catogory = (snapData.snapshot.value! as Map)["serviceType"];
            String capacity = (snapData.snapshot.value! as Map)["capacity"];
            String weight = (snapData.snapshot.value! as Map)["weight"];
            String instructions = (snapData.snapshot.value! as Map)["instructions"];

            String? rideRequestId = snapData.snapshot.key;

            UserRideRequestInformation userRideRequestDetails = UserRideRequestInformation();
            userRideRequestDetails.originLatLng = LatLng(originLat, originLng);
            userRideRequestDetails.originAddress = originAddress;
            userRideRequestDetails.destinationLatLng = LatLng(destinationLat, destinationLng);
            userRideRequestDetails.destinationAddress = destinationAddress;
            userRideRequestDetails.userName = userName;
            userRideRequestDetails.userPhone = userPhone;
            userRideRequestDetails.serviceType = catogory;
            userRideRequestDetails.capacity = capacity;
            userRideRequestDetails.weight = weight;
            userRideRequestDetails.instructions = instructions;

            userRideRequestDetails.rideRequestId = rideRequestId;

            showSimpleDialog(userRideRequestDetails, context);
          }
          else {
            Fluttertoast.showToast(msg: "This Ride request do not exist");
          }
        });
      }
      else{
        Fluttertoast.showToast(msg: "This Ride has been cancelled.");
        Navigator.pop(context);
      }
    });
  }

  Future generateAndGetToken() async {
    String? registrationToken = await messaging.getToken();
    print("FCM registraion Token: $registrationToken");

    FirebaseDatabase.instance.ref()
      .child("drivers")
      .child(firebaseAuth.currentUser!.uid)
      .child("token")
      .set(registrationToken);

    messaging.subscribeToTopic("alldrivers");
    messaging.subscribeToTopic("allusers");  
  }
}