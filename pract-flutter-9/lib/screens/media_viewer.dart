import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/media_item.dart';

class MediaViewer extends StatefulWidget {
  final MediaItem item;

  const MediaViewer({super.key, required this.item});

  @override
  State<MediaViewer> createState() => _MediaViewerState();
}

class _MediaViewerState extends State<MediaViewer> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    if (widget.item.isVideo) {
      _videoController = VideoPlayerController.file(File(widget.item.path))
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.isVideo ? 'Видео' : 'Фото'),
      ),
      body: widget.item.isVideo ? _buildVideoPlayer() : _buildPhoto(),
    );
  }

  Widget _buildPhoto() {
    return InteractiveViewer(
      child: Center(
        child: Image.file(File(widget.item.path)),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        ),
        const SizedBox(height: 16),
        ValueListenableBuilder(
          valueListenable: _videoController!,
          builder: (context, VideoPlayerValue value, _) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Slider(
                    value: value.position.inMilliseconds.toDouble(),
                    min: 0,
                    max: value.duration.inMilliseconds.toDouble(),
                    onChanged: (v) {
                      _videoController!
                          .seekTo(Duration(milliseconds: v.toInt()));
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(value.position)),
                      Text(_formatDuration(value.duration)),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.replay_10),
              onPressed: () {
                final pos = _videoController!.value.position;
                _videoController!
                    .seekTo(pos - const Duration(seconds: 10));
              },
            ),
            IconButton(
              iconSize: 48,
              icon: Icon(
                _videoController!.value.isPlaying
                    ? Icons.pause_circle
                    : Icons.play_circle,
              ),
              onPressed: () {
                setState(() {
                  if (_videoController!.value.isPlaying) {
                    _videoController!.pause();
                  } else {
                    _videoController!.play();
                  }
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.forward_10),
              onPressed: () {
                final pos = _videoController!.value.position;
                _videoController!
                    .seekTo(pos + const Duration(seconds: 10));
              },
            ),
          ],
        ),
      ],
    );
  }
}
