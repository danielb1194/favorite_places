import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:location/location.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

class LocationAndAddress {
  final LocationData location;
  final String address;

  LocationAndAddress({required this.location, required this.address});
}

class PlaceModel {
  PlaceModel(
      {required this.title,
      required this.image,
      required this.location,
      String? id})
      : id = id ?? UniqueKey().toString();

  final String id;
  final String title;
  final File image;
  final LocationAndAddress location;
}

Future<Database> _getDatabase() async {
  final dbpath = path.join(
    await sql.getDatabasesPath(),
    'places.db',
  );
  return sql.openDatabase(
    dbpath,
    onCreate: (db, version) {
      db.execute(
        'CREATE TABLE user_places(id TEXT PRIMARY KEY, title TEXT, image TEXT, latitude REAL, longitude REAL, address TEXT)',
      );
    },
    version: 1,
  );
}

class UserPlacesNotifier extends StateNotifier<List<PlaceModel>> {
  UserPlacesNotifier() : super(const []); // initial state

  Future<void> loadPlaces() async {
    _getDatabase().then((db) => db.query('user_places')).then((places) {
      state = places.map((row) {
        return PlaceModel(
          id: row['id'] as String,
          title: row['title'] as String,
          image: File(row['image'] as String),
          location: LocationAndAddress(
            location: LocationData.fromMap({
              'latitude': row['latitude'] as double,
              'longitude': row['longitude'] as double,
            }),
            address: row['address'] as String,
          ),
        );
      }).toList();
    });
  }

  void addPlace(PlaceModel place) async {
    final storagePath = await syspaths.getApplicationDocumentsDirectory();

    final newImage =
        await place.image.copy('${storagePath.path}/${place.id}.png');

    final newPlace = PlaceModel(
      title: place.title,
      image: newImage,
      location: place.location,
    );
    final db = await _getDatabase();
    db.insert(
      'user_places',
      {
        'id': newPlace.id,
        'title': newPlace.title,
        'image': newPlace.image.path,
        'latitude': newPlace.location.location.latitude,
        'longitude': newPlace.location.location.longitude,
        'address': newPlace.location.address,
      },
    );

    state = [...state, newPlace];
  }

  void removePlace(PlaceModel place) {
    state = state.where((p) => p.id != place.id).toList();
  }
}

final userPlacesProvider =
    StateNotifierProvider<UserPlacesNotifier, List<PlaceModel>>(
        (ref) => UserPlacesNotifier());
