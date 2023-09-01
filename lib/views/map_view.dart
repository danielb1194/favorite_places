import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatefulWidget {
  const MapView(
      {super.key,
      this.latLng = const LatLng(37.422, -122.084),
      this.isSelecting = false});

  final LatLng latLng;
  final bool isSelecting;

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  LatLng? _pickedLocation;

  void _returnPickedLocation() {
    Navigator.of(context).pop(_pickedLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _returnPickedLocation,
          ),
        ],
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: GoogleMap(
            onTap: widget.isSelecting
                ? (argument) => setState(() => _pickedLocation = argument)
                : null,
            initialCameraPosition: CameraPosition(
              target: widget.latLng,
              zoom: 16,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('position'),
                position: _pickedLocation ?? widget.latLng,
              )
            },
          ),
        ),
      ),
    );
  }
}
