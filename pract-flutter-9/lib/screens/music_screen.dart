import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/music_item.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final _musicBox = Hive.box<MusicItem>('music');
  final _player = AudioPlayer();

  int? _currentIndex;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player.onPositionChanged.listen((pos) {
      setState(() => _position = pos);
    });
    _player.onDurationChanged.listen((dur) {
      setState(() => _duration = dur);
    });
    _player.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playTrack(int index) async {
    final items = _musicBox.values.toList();
    final item = items[index];
    await _player.play(UrlSource(item.url));
    setState(() {
      _currentIndex = index;
      _isPlaying = true;
    });
  }

  void _showAddDialog() {
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
              decoration: const InputDecoration(labelText: 'Название'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(labelText: 'URL аудио'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  urlController.text.isNotEmpty) {
                _musicBox.add(
                  MusicItem(
                    title: titleController.text,
                    url: urlController.text,
                  ),
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _musicBox.listenable(),
              builder: (context, Box<MusicItem> box, _) {
                if (box.isEmpty) {
                  return Center(
                    child: Text(
                      'NO TRACKS',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.1),
                        letterSpacing: 4,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                final items = box.values.toList();
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isActive = _currentIndex == index;
                    return _buildMinimalTrack(item, index, isActive, box);
                  },
                );
              },
            ),
          ),
          if (_currentIndex != null) _buildDockedPlayer(),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: _showAddDialog,
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        shape: const RoundedRectangleBorder(),
        child: const Icon(Icons.add_sharp),
      ),
    );
  }

  Widget _buildMinimalTrack(MusicItem item, int index, bool isActive, Box<MusicItem> box) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      title: Text(
        item.title.toUpperCase(),
        style: TextStyle(
          color: isActive ? Colors.amber : Colors.white,
          letterSpacing: 1.5,
          fontSize: 13,
          fontWeight: isActive ? FontWeight.w900 : FontWeight.w300,
          shadows: isActive
              ? [
                  Shadow(
                      color: Colors.amber.withOpacity(0.5),
                      blurRadius: 10)
                ]
              : null,
        ),
      ),
      subtitle: Text(
        'SOURCE: ${item.url.split('/').last.toUpperCase()}',
        style: TextStyle(
          color: Colors.white24,
          fontSize: 8,
          letterSpacing: 1,
        ),
      ),
      trailing: isActive
          ? Icon(Icons.volume_up_sharp, color: Colors.amber, size: 16)
          : IconButton(
              icon: const Icon(Icons.close_sharp, color: Colors.white10, size: 16),
              onPressed: () => box.deleteAt(index),
            ),
      onTap: () {
        if (isActive && _isPlaying) {
          _player.pause();
          setState(() => _isPlaying = false);
        } else if (isActive) {
          _player.resume();
          setState(() => _isPlaying = true);
        } else {
          _playTrack(index);
        }
      },
    );
  }

  Widget _buildDockedPlayer() {
    final items = _musicBox.values.toList();
    if (_currentIndex == null || _currentIndex! >= items.length) {
      return const SizedBox.shrink();
    }
    final current = items[_currentIndex!];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      current.title.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 2,
                        color: Colors.amber,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                      style: const TextStyle(
                        fontSize: 9,
                        fontFamily: 'monospace',
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause_sharp : Icons.play_arrow_sharp),
                color: Colors.white,
                onPressed: () {
                  if (_isPlaying) {
                    _player.pause();
                    setState(() => _isPlaying = false);
                  } else {
                    _player.resume();
                    setState(() => _isPlaying = true);
                  }
                },
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 1,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
              activeTrackColor: Colors.amber,
              inactiveTrackColor: Colors.white10,
              thumbColor: Colors.amber,
            ),
            child: Slider(
              value: _position.inSeconds.toDouble(),
              max: _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1.0,
              onChanged: (value) => _player.seek(Duration(seconds: value.toInt())),
            ),
          ),
        ],
      ),
    );
  }
}
