import '../user_models/active_nearby_available_drivers.dart';

class GeofireAssistant {
  static List<ActiveNearbyAvailableDrivers> activeNearbyDriverList = [];

  static void deleteOfflineDrivers(String driverId) {
    int index = 0;
    int seq = 0;
    activeNearbyDriverList.forEach((element) {
      if (element.driverId == driverId) {
        seq = index;
      }
      index++;
    });
    activeNearbyDriverList.removeAt(seq);
  }

  static void updateDriverLocation(ActiveNearbyAvailableDrivers driver) {
    int index = 0;
    int seq = 0;
    activeNearbyDriverList.forEach((element) {
      if (element.driverId == driver.driverId) {
        seq = index;
      }
      index++;
    });
    activeNearbyDriverList[seq].locationLatitude = driver.locationLatitude;
    activeNearbyDriverList[seq].locationLongitude = driver.locationLongitude;
  }
}
