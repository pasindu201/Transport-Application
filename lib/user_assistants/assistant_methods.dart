import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'request_assistant.dart';
import '../user_global/global.dart';
import 'package:firebase_database/firebase_database.dart';
import '../user_global/map_key.dart';
import 'package:geolocator/geolocator.dart';
import '../user_models/directions.dart';
import '../user_infoHandler/app_info.dart';
import '../user_models/direction_details_info.dart';
import '../user_models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_directions_api/google_directions_api.dart';
import 'dart:async';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;

class AssistantMethods {
  static Future<void> readCurrentOnlineUserInfo() async {
    currentUser = firebaseAuth.currentUser;
    if (currentUser == null) {
      print("No user is currently logged in.");
      return;
    }

    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(currentUser!.uid);

    try {
      DatabaseEvent event = await userRef.once();
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        userModelCurrentinfo = UserModel.fromSnapshot(snapshot);
        print("User info loaded: ${userModelCurrentinfo.toString()}");
      } else {
        print("User data not found in database for UID: ${currentUser!.uid}");
      }
    } catch (error) {
      print("Failed to load user info: $error");
    }
  }

  static Future<String> searchAddressForGeographicCoordinates(Position position, context) async {
    String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapkey";
    String humanReadableAddress = "";

    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    if (requestResponse != "Error occurred. Failed. No Response") {
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];

      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
    }
    return humanReadableAddress;
  }

  static Future<List<PointLatLng>?> obtainOriginToDestinationDirectionDetails(LatLng originPosition, LatLng destinationPosition) async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      mapkey,
      PointLatLng(originPosition.latitude, originPosition.longitude),
      PointLatLng(destinationPosition.latitude, destinationPosition.longitude)
    );
    return result.points;
  }

  static double calculateFareAmountFromOriginToDestination(DirectionDetailsInfo directionDetailsInfo) {
    double distanceTravelledFareAmountPerKilometer = (directionDetailsInfo.distance_value! / 1000) * 0.1;
    return distanceTravelledFareAmountPerKilometer;
  }

  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "trippo-ef847",
      "private_key_id": "16b9c8855c34ded907587bdcc005cabb8fcde022",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDLyAXE2PldMs0N\ng+pP4Py/g8ZgdIAa4RVYFsmlA/sd9nafBacaF56OaQBmFI+ggwysr36ZewhPakQQ\n9TuhIN/9B1evqfAMWhfOkdVx7YwN6iS4SxGHlotZIzKP/5ShB9PE5flFGH85sLl0\ngzBcaDuHywQvWnvh7/h5a8v4ESy7tgFNI3/pkzoa/psXi4FSrKjHS7Sl/ejy867E\ncExEfUNB2iZGPJe+riMa0GQFUzE63rvumQvPKH1k38tRRgy2BC3NY58YHo5ad4Oo\nNt/qLsCJuiEY9oKJgSB8D2NSeJHhgYz6U4HqPKGRyfQOX8f5BV3Dzo3SX62BJAct\ngbYqJkZbAgMBAAECggEAEe3rOrAVH0hBIV90u2AiF3RFJ9G9lF/Zwb0ziFN1gePg\nTkqFiCFW39RzkV0IFrPLvC/ZVYYCgQDqXzbsbwIA+HbFFh1qE57OTxb8BCubMdLi\n4Id+UdiC3INhHKlR5D8s4zs8DNfEbd4o2wxQh3jbmq2ClJYDUKmNSkWb6xtmZ6zK\nGYLOgG45oUPLrUTDPhUW0r7NWHtBiLoSRxHpMJTp24WuEsobdCKIaLY5HtUVCrxa\nF86aoxbtOZGU8roKxnUxqXRw8dK3PClN3PcLD4Yj0GYSx5AiU1dOQ2S9+CAXgRly\nJb8eMlM0QP8V8TW3AzlT6pDvErNw2bmWJK/M4sYf/QKBgQDttBwApdW2uGOrbqwj\nVrc7TAV57axMb/oSgUC6G75S7nJblQ3tRTarAyLeMF0aONZUpdE6ONmELPQrMT3n\nq/Xia3/ERr2dAqIpmpqTjv0eX9CXJrVjb2LSKK1ojdV4DgIBTzYLT5OleInbXPUB\nFgfN24QM/dGTjp4nvzXi/253zQKBgQDbd3vzHX9AUvdMlF0koVohpszI9IJUMnx0\njtRtZhruj2f8wEEhsvQxYSnktKOEZxHy8UmlKNDC5iZeh6AC+r2CS3Un0AZc8ckN\ngD15BDvOuqa0yISJJw3jpz2pXWd4VrVG7vbIBAxISEBq2ANjiVhr7atx84sjp9Ap\nfNEFENG+xwKBgFEmmiDGfO3CiZRvVilCY4/E5mG3+Iin+fHzWouvCQz7BuOpQXXt\nmTpM+cxtKnvXR6Tib0m3OttbFYjhaMb8+BbyqE3z8Kv3yDD37SnPOS7zexz/RBHM\nZypkZL87HNO9xIV563N1GWz2d+oCFErooIVxGeXtiW0c1XWwW89BcQ9JAoGAFM1q\njkzJdwtmLXgSrBovNOlel921TM3MRjATqpr3Co3FSYvfoJYZ12RiWC9XIIG0jdaZ\nKHKJ9y9hi6xHWoDx3ZvRawio0b6JVCJHsWTZVmsSyigHiAiPpHiBu8ACwsFVRXf5\nJFRd5awTjw0SpSirnO9WROLU2XhantQZ6+UAPJkCgYByl0TuK6jb9aq264fwfppB\n91L1uQmgar99f6EeWkESGAr6PpEfyKk52H0tDAWtwUi/DhPRQ/Ly+OZf9buo0pRj\n7vod4kByicHcNeMTpGKBoloC6u1y+WLquCg54at6m2lIyH386+HF0hHI/lBprBmY\nyYRTEP0JHzU5rkRuHQjpoA==\n-----END PRIVATE KEY-----\n",
      "client_email": "trippo-pasindu-sandeep@trippo-ef847.iam.gserviceaccount.com",
      "client_id": "113279006670683948814",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/trippo-pasindu-sandeep%40trippo-ef847.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.messaging",  
      "https://www.googleapis.com/auth/firebase.database"
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes
    );

    // Get the access token
    auth.AccessCredentials credentials = await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson), 
      scopes, 
      client
    );

    client.close();
    return credentials.accessToken.data;
  }

  static Future<void> sendNotificationToSelectedDriver(String deviceToken, BuildContext context, String tripId) async {
    // Fetching necessary details
    String dropOffLocationLat = Provider.of<AppInfo>(context, listen: false).userDropOffLocation!.locationLatitude.toString();
    String dropOffLocationLng = Provider.of<AppInfo>(context, listen: false).userDropOffLocation!.locationLongitude.toString();
    String pickUpLocationLat = Provider.of<AppInfo>(context, listen: false).userPickUpLocation!.locationLatitude.toString();
    String pickUpLocationLng = Provider.of<AppInfo>(context, listen: false).userPickUpLocation!.locationLongitude.toString();
    
    // Get the FCM server key from your function
    final String serverKey = await getAccessToken();

    // FCM API endpoint
    String endPointFirebaseCloudMessaging = "https://fcm.googleapis.com/v1/projects/trippo-ef847/messages:send";

    final Map<String, dynamic> message = {
      "message": {
        "token":deviceToken,
        "notification": {
          "title": "Notification form ${userModelCurrentinfo!.name}",
        },
        "data":{
          "tripID": tripId,
          "name": userModelCurrentinfo!.name,
          "pickUpLocationLat": pickUpLocationLat,
          "pickUpLocationLng": pickUpLocationLng,
          "dropOffLocationLat": dropOffLocationLat,
          "dropOffLocationLng": dropOffLocationLng,
          "userPhone": userModelCurrentinfo!.phone,
          "originAddress": Provider.of<AppInfo>(context, listen: false).userPickUpLocation!.locationName,
          "destinationAddress": Provider.of<AppInfo>(context, listen: false).userDropOffLocation!.locationName
        }
      }
    };

    // Sending the notification via HTTP POST
    final http.Response response = await http.post(
      Uri.parse(endPointFirebaseCloudMessaging),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey'
      },
      body: jsonEncode(message),  
    );

    // Handling the response
    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Notification sent successfully to driver");
    } else {
      Fluttertoast.showToast(msg: "Failed to send notification to driver.");
    }
  }
}
