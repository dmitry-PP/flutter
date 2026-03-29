import 'package:hive/hive.dart';

part 'media_item.g.dart';

@HiveType(typeId: 0)
class MediaItem extends HiveObject {
  @HiveField(0)
  final String path;

  @HiveField(1)
  final bool isVideo;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final double? latitude;

  @HiveField(4)
  final double? longitude;

  MediaItem({
    required this.path,
    required this.isVideo,
    required this.date,
    this.latitude,
    this.longitude,
  });
}
