import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  Future<String> getCurrentAddress() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return "Location services are disabled.";
    }

    // Check permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return "Location permissions are denied.";
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return "Location permissions are permanently denied.";
    }

    // Get position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Reverse geocode into an address
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      return "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
    }

    return "Unable to get address.";
  }
}
