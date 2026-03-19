import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../models/audio_track.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  late Box<AudioTrack> _trackBox;
  List<AudioTrack> _tracks = [];

  final AudioPlayer _player = AudioPlayer();
  int? _playingIndex;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _trackBox = Hive.box<AudioTrack>('audioTracks');
    _loadTracks();

    _player.positionStream.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });
    _player.durationStream.listen((dur) {
      if (mounted && dur != null) setState(() => _duration = dur);
    });
    _player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state.playing;
        if (state.processingState == ProcessingState.completed) {
          _isPlaying = false;
          _position = Duration.zero;
        }
      });
    });
  }

  void _loadTracks() {
    setState(() {
      _tracks = _trackBox.values.toList()
        ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
    });
  }

  Future<void> _playTrack(int index) async {
    final track = _tracks[index];
    if (_playingIndex == index && _isPlaying) {
      await _player.pause();
    } else if (_playingIndex == index && !_isPlaying) {
      await _player.play();
    } else {
      try {
        await _player.stop();
        if (track.isLocal) {
          await _player.setFilePath(track.url);
        } else {
          await _player.setUrl(track.url);
        }
        setState(() {
          _playingIndex = index;
          _position = Duration.zero;
        });
        await _player.play();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(track.isLocal
                  ? 'Ошибка: не удалось воспроизвести файл.'
                  : 'Ошибка: не удалось загрузить аудио.\nПроверьте URL.'),
            ),
          );
        }
      }
    }
  }

  Future<void> _seekTo(Duration position) async {
    await _player.seek(position);
  }

  void _showAddTrackDialog() {
    final titleController = TextEditingController();
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Добавить аудио'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Название',
                hintText: 'Моя песня',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'URL аудио',
                hintText: 'https://example.com/song.mp3',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final url = urlController.text.trim();
              if (title.isEmpty || url.isEmpty) return;

              final track = AudioTrack(
                title: title,
                url: url,
                addedAt: DateTime.now(),
              );
              await _trackBox.add(track);
              _loadTracks();
              if (ctx.mounted) Navigator.pop(ctx);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Трек сохранён в Hive БД (записей: ${_trackBox.length})'),
                  ),
                );
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromDevice() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'aac', 'flac', 'ogg', 'm4a', 'wma'],
      );
      if (result == null || result.files.isEmpty) return;
      final pickedFile = result.files.first;
      final path = pickedFile.path;
      if (path == null || path.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Не удалось получить путь к файлу')),
          );
        }
        return;
      }

      // Копируем в директорию приложения (macOS sandbox)
      final appDir = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${appDir.path}/music');
      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }
      final ext = path.split('.').last;
      final destPath = '${audioDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.$ext';
      await File(path).copy(destPath);

      final title = pickedFile.name.replaceAll(RegExp(r'\.[^.]+$'), '');
      final track = AudioTrack(
        title: title,
        url: destPath,
        addedAt: DateTime.now(),
        isLocal: true,
      );
      await _trackBox.add(track);
      _loadTracks();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Трек "$title" импортирован в Hive БД (записей: ${_trackBox.length})'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при импорте аудио')),
        );
      }
    }
  }

  Future<void> _deleteTrack(int index) async {
    final track = _tracks[index];
    if (_playingIndex == index) {
      await _player.stop();
      setState(() {
        _playingIndex = null;
        _isPlaying = false;
      });
    }
    // Удаляем скопированный файл для локальных треков
    if (track.isLocal && !kIsWeb) {
      try {
        final file = File(track.url);
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
    await track.delete();
    _loadTracks();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Удалено из Hive БД (осталось записей: ${_trackBox.length})'),
        ),
      );
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Музыка'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Chip(
                avatar: const Icon(Icons.storage, size: 18),
                label: Text('Hive: ${_trackBox.length}'),
              ),
            ),
          ),
        ],
      ),
      body: _tracks.isEmpty
          ? const Center(
              child: Text('Нет треков. Нажмите + чтобы добавить.'),
            )
          : ListView.builder(
              itemCount: _tracks.length,
              itemBuilder: (context, index) {
                final track = _tracks[index];
                final isActive = _playingIndex == index;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                isActive && _isPlaying
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_filled,
                                size: 40,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              onPressed: () => _playTrack(index),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    track.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        track.isLocal ? Icons.folder : Icons.language,
                                        size: 12,
                                        color: Colors.grey[500],
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          track.isLocal
                                              ? 'Локальный файл'
                                              : track.url,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _deleteTrack(index),
                            ),
                          ],
                        ),
                        if (isActive) ...[
                          Slider(
                            value: _position.inMilliseconds
                                .toDouble()
                                .clamp(0, _duration.inMilliseconds.toDouble()),
                            max: _duration.inMilliseconds.toDouble().clamp(1, double.infinity),
                            onChanged: (v) => _seekTo(Duration(milliseconds: v.toInt())),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_formatDuration(_position)),
                                Text(_formatDuration(_duration)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'import',
            onPressed: _pickFromDevice,
            tooltip: 'Импорт с устройства',
            child: const Icon(Icons.folder_open),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'url',
            onPressed: _showAddTrackDialog,
            tooltip: 'Добавить по URL',
            child: const Icon(Icons.link),
          ),
        ],
      ),
    );
  }
}
