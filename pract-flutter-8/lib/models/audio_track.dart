import 'package:hive/hive.dart';

part 'audio_track.g.dart';

@HiveType(typeId: 1)
class AudioTrack extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String url;

  @HiveField(2)
  DateTime addedAt;

  @HiveField(3)
  bool isLocal;

  AudioTrack({
    required this.title,
    required this.url,
    required this.addedAt,
    this.isLocal = false,
  });
}
