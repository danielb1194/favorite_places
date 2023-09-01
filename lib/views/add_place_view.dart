import 'package:favorite_places/widgets/image_input.dart';
import 'package:favorite_places/widgets/location_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:favorite_places/models/place.dart';

class AddPlaceView extends ConsumerStatefulWidget {
  const AddPlaceView({super.key});

  @override
  ConsumerState<AddPlaceView> createState() => _AddPlaceViewState();
}

class _AddPlaceViewState extends ConsumerState<AddPlaceView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final Map<String, dynamic> _formData = {
    'title': null,
    'image': null,
    'location': null,
  };

  void _savePlace() {
    if (_formKey.currentState!.validate() == false) {
      return;
    }
    _formKey.currentState!.save();

    // no null elements in form data
    if (_formData.values.any((element) => element == null)) {
      return;
    }

    PlaceModel newPlace = PlaceModel(
      title: _formData['title'],
      image: _formData['image'],
      location: _formData['location'],
    );
    ref.read(userPlacesProvider.notifier).addPlace(newPlace);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Place'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(label: Text('Title')),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                    onSaved: (v) => _formData['title'] = v,
                  ),
                  const SizedBox(height: 20),
                  ImageInput(
                      onSelectImage: (image) => _formData['image'] = image),
                  const SizedBox(height: 20),
                  LocationInput(
                    onSelectLocation: (locationData) =>
                        _formData['location'] = locationData,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    onPressed: _savePlace,
                    label: const Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
