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
      "private_key_id": "2935a9e1f2c4e1e4bfe14c96c1d87a46d3b90e4a",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDe9IE5Nv8hIy0r\n68AToXVsLLPjTnWXVW0aw3UK9YUQ6u63zwI2/iLqjNFOFshgKko3sExv81mzPghL\nBE9lOEpzDfVYHbA5out4xvuPFLwYTSsGaOgOsv1sHQQXXWzMfUbyVutfIdtBmXCJ\nZDwS+awykoI5duDYDk81uyJ3ktjh1dtqIm1USeUcAs0retg4s1wWRHsAr/PiVVPo\n5gzUwzOUFHmuF0a88QzfboC890Zkx8x/ABiPir7yydABEnEKjsaH9nzrIOiUmcze\nSiTpo3ItSkPnsxCn9iQCa4EQfKK89EcTpWpax1u7KJM9cFhLCozM/cNFCdo1F1ln\n1vapq7l3AgMBAAECggEAAl8FVM9x7S9LlrD+LPdFoW3kR+GYvJBLBcLYZtJvpNtq\nyIeqFV2kj2wJ+dOiM+ufOHJmjbY/2Pkq62lTUtdDa2/VkSdXrXU/Hdy35jCpQ3Tm\npT3OYgGjUlgIqBr1QkN+0qr7+9oHU+5G1R88yFLhcvQ98FCEWaflTcP8vNrR9azk\ngBa8UtqdegOceKjpcbJsxDuWWEVI7otxJXIsJmMiKPfCGjdvcotJ9qALGgN6fxOM\nMfl/pj/KPUjQAlIX1Aqb4j65a/Her4q4UP/uvgSIoV8ZQaeIBqAEd34pJPscS+dv\n1iByJC60ZjFEFUM30JOxPPpBhnn5gZ8DJ6su4w2/YQKBgQD1h6Z11PPywJ4TkeRP\noNv7Jo1sbke3YG7djdQrLDwbhswAj967uhq0S2mD7tFeWrcLRP+a4/RuatfvDdnF\nS0bQlM3euzZ2e5AYTMzoYZsqLAW4bdMUVX8P8d/uvBy43PHNxIS/9r4/u8Bbk2I/\nfntNc77bZU0Lq0YtUMwoqw7XEQKBgQDodmovedlQhN1ic/vd8pwTMm59LYnz2M9v\nySOo4+yhv3KvfGqeHh0L2LMuvE4e7cSgWJlrxAi6pmkjv2Vs5Dd10eEefgqJFfNa\nUX1UymkB4z/oH5mVbIbWikElMWN8DOqyCCMjXXsfV0/gDjbWZSpPoWuHviFzO2Tn\nhjTWuPZYBwKBgFk9cJcrS29T6yCZyi3W/Z2PKZ/bhV11Q1Zrkk4OydoHaGZb5Ey/\nG62kKzm0t4xf1F/YOD8H03O+ibVth1VaQubU7u6hhO4TgxAR+fgMYeU2Eu4xnKKr\nYH9fHlEbNiVKyOhNISLUf9mSWBvwuajyQ8am5xu++f3fxqX50/qEEeTBAoGAF9Jq\nt0rJVlMHTNuN6ATAscbtQ66zAGYre80k9l3FFh5EZm9dja6QU3J1ikiJyOmcyMHL\nlxuTuWzsQVmPz0Tj2hMT+sf31GyHb64CJfpIIIVlOyhh2MoyVzH70w/ongHE21Gy\nKCGgSGnuKYvLWtUrLNXh6xs02lYv1PoP2CFEPWkCgYEA5ZFqYxEqND/BI9yf98kR\n8TDivpvDL7o0F4gZsYLyEmAqjeLd2WZ6HWbYFU3I0naFqmsXh8n/R8OSbL3sG6vQ\nK4/SskVOhjj+v8q8s8aVuY5JYH/8zL0s0M8oZODeS96ZW7spAJmUxP4HVsrbIyMR\nw25qfSnTFrPFI3HZ0xfoGWQ=\n-----END PRIVATE KEY-----\n",
      "client_email": "trippo-pasindu@trippo-ef847.iam.gserviceaccount.com",
      "client_id": "112192815867132864589",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/trippo-pasindu%40trippo-ef847.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/firebase.messaging",
      "https://www.googleapis.com/auth/firebase.email",
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

  static Future<void> sendNotificationToDriversNow(String deviceRegistrationToken, String userRideRequestId, context) async {
    String accessToken = await getAccessToken();
    String destinationAddress = userDropOffAddress;

    Map<String, String> headerNotification = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    Map bodyNotification = {
      "body": "Destination Address: $destinationAddress",
      "title": "New Ride Request"
    };

    Map dataMap = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "userRideRequestId": userRideRequestId
    };

    Map officialNotificationFormat = {
      "notification": bodyNotification,
      "priority": "high",
      "data": dataMap,
      "to": deviceRegistrationToken
    };

    try {
      var responseNotification = await http.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: headerNotification,
        body: jsonEncode(officialNotificationFormat)
      );

      if (responseNotification.statusCode == 200) {
        print("Notification sent successfully.");
      } else {
        print("Failed to send notification: ${responseNotification.body}");
      }
    } catch (e) {
      print("Error sending notification: $e");
    }
  }
}
