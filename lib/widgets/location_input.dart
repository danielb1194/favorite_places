import 'dart:convert';

import 'package:favorite_places/models/place.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../views/map_view.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onSelectLocation});

  final Function(LocationAndAddress) onSelectLocation;

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  bool _isGettingLocation = false;
  LocationAndAddress? _currentLocation;

  Future<String?> _getLocationAddress(double lat, double lng) async {
    final Uri url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=${dotenv.env['MAPS_API_KEY']}',
    );
    // print(url);
    final response = await http.get(url);
    final responseData = json.decode(response.body);

    if (responseData['results'].length == 0) {
      return null;
    }

    return responseData['results'][0]['formatted_address'];
  }

  void _pickCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _isGettingLocation = true;
    });
    locationData = await location.getLocation();
    setState(() {
      _isGettingLocation = false;
    });

    final address = await _getLocationAddress(
      locationData.latitude!,
      locationData.longitude!,
    );

    setState(() {
      _currentLocation = LocationAndAddress(
        location: locationData,
        address: address ?? 'No address found',
      );
    });

    widget.onSelectLocation(_currentLocation!);
  }

  String get staticMapUrl =>
      'https://maps.googleapis.com/maps/api/staticmap?center=${_currentLocation!.location.latitude},${_currentLocation!.location.longitude}&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C${_currentLocation!.location.latitude},${_currentLocation!.location.longitude}&key=${dotenv.env['MAPS_API_KEY']}';

  Future<void> _pickLocationOnMap() async {
    final LatLng? pickedLocation = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _currentLocation != null
            ? MapView(
                latLng: LatLng(
                  _currentLocation!.location.latitude!,
                  _currentLocation!.location.longitude!,
                ),
                isSelecting: true,
              )
            : const MapView(isSelecting: true),
      ),
    );
    if (pickedLocation != null) {
      final address = await _getLocationAddress(
        pickedLocation.latitude,
        pickedLocation.longitude,
      );

      setState(() {
        _currentLocation = LocationAndAddress(
          location: LocationData.fromMap({
            'latitude': pickedLocation.latitude,
            'longitude': pickedLocation.longitude,
          }),
          address: address ?? 'No address found',
        );
      });

      widget.onSelectLocation(_currentLocation!);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text('No Location Chosen'));
    if (_isGettingLocation) {
      content = const CircularProgressIndicator();
    }
    if (_currentLocation != null) {
      content = Image.network(
        staticMapUrl,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 170,
            decoration: BoxDecoration(
              border:
                  Border.all(width: 1, color: Theme.of(context).primaryColor),
            ),
            child: content,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: _pickCurrentLocation,
                icon: const Icon(Icons.location_on),
                label: const Text('Current Location'),
              ),
              TextButton.icon(
                onPressed: _pickLocationOnMap,
                icon: const Icon(Icons.map),
                label: const Text('Select on Map'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
