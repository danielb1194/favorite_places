import 'package:favorite_places/models/place.dart';

import 'package:favorite_places/views/add_place_view.dart';
import 'package:favorite_places/widgets/place_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlacesListView extends ConsumerStatefulWidget {
  const PlacesListView({super.key});

  @override
  ConsumerState<PlacesListView> createState() => _PlacesListViewState();
}

class _PlacesListViewState extends ConsumerState<PlacesListView> {
  late Future<void> _userPlacesFuture;
  @override
  void initState() {
    super.initState();
    _userPlacesFuture = ref.read(userPlacesProvider.notifier).loadPlaces();
  }

  @override
  Widget build(BuildContext context) {
    // subscribe to changes (rebuilds)
    final userPlaces = ref.watch(userPlacesProvider);

    // select the appropiate content if the list of places if empty
    final Widget content;
    content = FutureBuilder(
      future: _userPlacesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return ListView.builder(
            itemCount: userPlaces.length,
            itemBuilder: (context, index) =>
                PlaceListItem(place: userPlaces[index]),
          );
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Places'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AddPlaceView(),
              ),
            ),
          ),
        ],
      ),
      body: content,
    );
  }
}
