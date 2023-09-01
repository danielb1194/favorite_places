import 'package:favorite_places/models/place.dart';
import 'package:favorite_places/views/place_details_view.dart';
// import 'package:favorite_places/widgets/favorite_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlaceListItem extends ConsumerWidget {
  const PlaceListItem({super.key, required this.place});

  final PlaceModel place;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(place.id),
      onDismissed: (_) =>
          ref.read(userPlacesProvider.notifier).removePlace(place),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: FileImage(place.image),
        ),
        title:
            Text(place.title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(place.location.address),
        // trailing: FavoritesIcon(
        //     isFavorite: ref.watch(userPlacesProvider).contains(place),
        //     place: place),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) {
              return PlaceDetailsView(place: place);
            },
          ),
        ),
      ),
    );
  }
}
