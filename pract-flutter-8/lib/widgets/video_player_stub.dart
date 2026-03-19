import 'dart:typed_data';

import 'package:video_player/video_player.dart';

Future<VideoPlayerController> createController(String filePath, Uint8List? fileBytes) async {
  return VideoPlayerController.networkUrl(Uri.parse(filePath));
}
