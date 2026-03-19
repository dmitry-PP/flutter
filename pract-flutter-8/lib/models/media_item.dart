import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'media_item.g.dart';

@HiveType(typeId: 0)
class MediaItem extends HiveObject {
  @HiveField(0)
  String filePath;

  @HiveField(1)
  bool isVideo;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  double? latitude;

  @HiveField(4)
  double? longitude;

  @HiveField(5)
  Uint8List? fileBytes;

  MediaItem({
    required this.filePath,
    required this.isVideo,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.fileBytes,
  });
}
