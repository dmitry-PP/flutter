import 'package:hive/hive.dart';

part 'music_item.g.dart';

@HiveType(typeId: 1)
class MusicItem extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String url;

  MusicItem({
    required this.title,
    required this.url,
  });
}
