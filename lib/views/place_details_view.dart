import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:favorite_places/models/place.dart';
import 'package:favorite_places/views/map_view.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceDetailsView extends StatelessWidget {
  const PlaceDetailsView({super.key, required this.place});

  final PlaceModel place;

  String get staticMapUrl =>
      'https://maps.googleapis.com/maps/api/staticmap?center=${place.location.location.latitude},${place.location.location.longitude}&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C${place.location.location.latitude},${place.location.location.longitude}&key=${dotenv.env['MAPS_API_KEY']}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(place.title),
      ),
      body: Stack(
        children: [
          Image.file(
            place.image,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MapView(
                        latLng: LatLng(
                          place.location.location.latitude!,
                          place.location.location.longitude!,
                        ),
                      ),
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(staticMapUrl),
                    radius: 50,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 15),
                  color: Colors.black54,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    place.location.address,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
