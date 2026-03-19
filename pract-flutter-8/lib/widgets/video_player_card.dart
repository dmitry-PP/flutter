import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'video_player_io.dart' if (dart.library.html) 'video_player_stub.dart' as vp;

class VideoPlayerCard extends StatefulWidget {
  final String filePath;
  final Uint8List? fileBytes;

  const VideoPlayerCard({super.key, required this.filePath, this.fileBytes});

  @override
  State<VideoPlayerCard> createState() => _VideoPlayerCardState();
}

class _VideoPlayerCardState extends State<VideoPlayerCard> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      final controller = await vp.createController(widget.filePath, widget.fileBytes);
      if (!mounted) {
        controller.dispose();
        return;
      }
      _controller = controller;
      await _controller!.initialize();
      if (mounted) setState(() => _initialized = true);
      _controller!.addListener(() {
        if (mounted) setState(() {});
      });
    } catch (e) {
      if (mounted) setState(() => _error = 'Не удалось загрузить видео');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return SizedBox(
        height: 200,
        child: Center(child: Text(_error!, style: const TextStyle(color: Colors.red))),
      );
    }

    if (!_initialized || _controller == null) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final ctrl = _controller!;
    return Column(
      children: [
        AspectRatio(
          aspectRatio: ctrl.value.aspectRatio,
          child: VideoPlayer(ctrl),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  ctrl.value.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
                onPressed: () {
                  ctrl.value.isPlaying ? ctrl.pause() : ctrl.play();
                },
              ),
              Text(
                _formatDuration(ctrl.value.position),
                style: const TextStyle(fontSize: 12),
              ),
              Expanded(
                child: Slider(
                  value: ctrl.value.position.inMilliseconds
                      .toDouble()
                      .clamp(0, ctrl.value.duration.inMilliseconds.toDouble()),
                  max: ctrl.value.duration.inMilliseconds.toDouble().clamp(1, double.infinity),
                  onChanged: (value) {
                    ctrl.seekTo(Duration(milliseconds: value.toInt()));
                  },
                ),
              ),
              Text(
                _formatDuration(ctrl.value.duration),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
