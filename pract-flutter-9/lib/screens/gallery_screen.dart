import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import '../models/media_item.dart';
import '../widgets/feed_card.dart';
import 'media_viewer.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final _mediaBox = Hive.box<MediaItem>('media');
  final _picker = ImagePicker();

  Future<LocationData?> _getLocation() async {
    final location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return null;
    }

    PermissionStatus permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
      if (permission != PermissionStatus.granted) return null;
    }

    return await location.getLocation();
  }

  Future<void> _addMedia(bool isVideo) async {
    final XFile? file;
    if (isVideo) {
      file = await _picker.pickVideo(source: ImageSource.gallery);
    } else {
      file = await _picker.pickImage(source: ImageSource.gallery);
    }

    if (file == null) return;

    double? lat;
    double? lon;

    if (!isVideo) {
      final locData = await _getLocation();
      if (locData != null) {
        lat = locData.latitude;
        lon = locData.longitude;
      }
    }

    final item = MediaItem(
      path: file.path,
      isVideo: isVideo,
      date: DateTime.now(),
      latitude: lat,
      longitude: lon,
    );

    await _mediaBox.add(item);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ValueListenableBuilder(
        valueListenable: _mediaBox.listenable(),
        builder: (context, Box<MediaItem> box, _) {
          if (box.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.filter_none_sharp,
                      size: 48, color: Colors.white.withOpacity(0.1)),
                  const SizedBox(height: 16),
                  Text(
                    'EMPTY GALLERY',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.2),
                      letterSpacing: 2,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }
          final items = box.values.toList().reversed.toList();
          return GridView.builder(
            padding: const EdgeInsets.all(2),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return FeedCard(
                item: item,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MediaViewer(item: item),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'photo',
            onPressed: () => _addMedia(false),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: const RoundedRectangleBorder(),
            child: const Icon(Icons.add_a_photo_sharp),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'video',
            onPressed: () => _addMedia(true),
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
            shape: const RoundedRectangleBorder(),
            child: const Icon(Icons.videocam_sharp),
          ),
        ],
      ),
    );
  }
}
