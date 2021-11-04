import 'package:location/location.dart';

class GPSTracker {
  Location location = new Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;

  Future<LocationData?> getLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if(!_serviceEnabled){
      _serviceEnabled = await location.requestService();
      if(!_serviceEnabled){
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if(_permissionGranted == PermissionStatus.denied){
      _permissionGranted = await location.requestPermission();
      if(_permissionGranted != PermissionStatus.granted){
        return null;
      }
    }

    return location.getLocation();
  }

  Future<LocationData?> locationTracker() async {
    LocationData? locationData;
    _serviceEnabled = await location.serviceEnabled();
    if(!_serviceEnabled){
      _serviceEnabled = await location.requestService();
      if(!_serviceEnabled){
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if(_permissionGranted == PermissionStatus.denied){
      _permissionGranted = await location.requestPermission();
      if(_permissionGranted != PermissionStatus.granted){
        return null;
      }
    }
    location.onLocationChanged.listen((LocationData currentlocation) {
      locationData = currentlocation;
    });

    return locationData;
  }


}
