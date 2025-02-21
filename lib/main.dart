import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(LocationApp());
}

class LocationApp extends StatefulWidget {
  @override
  _LocationAppState createState() => _LocationAppState();
}

class _LocationAppState extends State<LocationApp> {
  List<String> locations = [];

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    String location = "Lat: ${position.latitude}, Lng: ${position.longitude}";
    setState(() {
      locations.add(location);
    });
    _saveLocations();
  }

  Future<void> _saveLocations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('saved_locations', locations);
  }

  Future<void> _loadLocations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      locations = prefs.getStringList('saved_locations') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Location Saver')),
        body: Column(
          children: [
            ElevatedButton(
              onPressed: _getCurrentLocation,
              child: Text('Get and Save Location'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(locations[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}