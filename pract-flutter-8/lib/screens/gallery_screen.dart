import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:location/location.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../models/media_item.dart';
import '../widgets/video_player_card.dart';

import 'gallery_screen_io.dart' if (dart.library.html) 'gallery_screen_stub.dart' as platform;

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final Location _location = Location();
  late Box<MediaItem> _mediaBox;
  List<MediaItem> _items = [];

  @override
  void initState() {
    super.initState();
    _mediaBox = Hive.box<MediaItem>('mediaItems');
    _loadItems();
  }

  void _loadItems() {
    setState(() {
      _items = _mediaBox.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  Future<LocationData?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) return null;
      }

      PermissionStatus permission = await _location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await _location.requestPermission();
        if (permission != PermissionStatus.granted) return null;
      }

      return await _location.getLocation();
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickMedia(bool isVideo) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: isVideo
            ? ['mp4', 'mov', 'avi', 'mkv', 'webm']
            : ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'heic'],
        withData: !isVideo, // Байты только для фото, видео — по пути
      );

      if (result == null || result.files.isEmpty) return;
      final pickedFile = result.files.first;

      // Для фото — сохраняем байты в Hive
      // Для видео — сохраняем путь к файлу (байты слишком большие)
      Uint8List? bytes;
      String filePath;

      if (isVideo) {
        // Видео: копируем файл в директорию приложения (macOS sandbox)
        final path = pickedFile.path;
        if (path == null || path.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Не удалось получить путь к видео')),
            );
          }
          return;
        }
        final appDir = await getApplicationDocumentsDirectory();
        final videoDir = Directory('${appDir.path}/gallery_videos');
        if (!await videoDir.exists()) {
          await videoDir.create(recursive: true);
        }
        final ext = path.split('.').last;
        final destPath = '${videoDir.path}/video_${DateTime.now().millisecondsSinceEpoch}.$ext';
        await File(path).copy(destPath);
        filePath = destPath;
        bytes = null;
      } else {
        // Фото: сохраняем байты
        bytes = pickedFile.bytes;
        if (bytes == null || bytes.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Не удалось прочитать файл')),
            );
          }
          return;
        }
        filePath = pickedFile.name;
      }

      // Геолокация при сохранении фото (пакет location)
      double? latitude;
      double? longitude;
      if (!isVideo) {
        final loc = await _getCurrentLocation();
        if (loc != null) {
          latitude = loc.latitude;
          longitude = loc.longitude;
        }
      }

      final item = MediaItem(
        filePath: filePath,
        isVideo: isVideo,
        createdAt: DateTime.now(),
        latitude: latitude,
        longitude: longitude,
        fileBytes: bytes,
      );

      await _mediaBox.add(item);
      _loadItems();

      if (mounted) {
        final type = isVideo ? 'Видео' : 'Фото';
        final locInfo = (latitude != null)
            ? ' | Геопозиция: ${latitude.toStringAsFixed(2)}, ${longitude!.toStringAsFixed(2)}'
            : '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$type сохранено в Hive БД (записей: ${_mediaBox.length})$locInfo'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  Future<void> _deleteItem(int index) async {
    final item = _items[index];
    // Удаляем скопированный видео-файл из директории приложения
    if (item.isVideo && !kIsWeb) {
      try {
        final file = File(item.filePath);
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
    await item.delete();
    _loadItems();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Удалено из Hive БД (осталось записей: ${_mediaBox.length})'),
        ),
      );
    }
  }

  void _showPickerSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Выбрать фото'),
              onTap: () {
                Navigator.pop(ctx);
                _pickMedia(false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Выбрать видео'),
              onTap: () {
                Navigator.pop(ctx);
                _pickMedia(true);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildImage(MediaItem item) {
    if (item.fileBytes != null) {
      return Image.memory(
        item.fileBytes!,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox(
          height: 200,
          child: Center(child: Icon(Icons.broken_image, size: 48)),
        ),
      );
    }
    if (!kIsWeb) {
      return platform.buildFileImage(item.filePath);
    }
    return const SizedBox(
      height: 200,
      child: Center(child: Icon(Icons.broken_image, size: 48)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Галерея'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Chip(
                avatar: const Icon(Icons.storage, size: 18),
                label: Text('Hive: ${_mediaBox.length}'),
              ),
            ),
          ),
        ],
      ),
      body: _items.isEmpty
          ? const Center(
              child: Text('Нет медиа. Нажмите + чтобы добавить.'),
            )
          : ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Шапка поста
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            child: Icon(
                              item.isVideo ? Icons.videocam : Icons.photo_camera,
                              size: 18,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.filePath.split('/').last,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  _formatDate(item.createdAt),
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            onPressed: () => _deleteItem(index),
                          ),
                        ],
                      ),
                    ),
                    // Медиа контент
                    if (!item.isVideo)
                      _buildImage(item)
                    else
                      VideoPlayerCard(filePath: item.filePath, fileBytes: item.fileBytes),
                    // Нижняя часть поста
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                      child: Row(
                        children: [
                          Icon(
                            item.isVideo ? Icons.videocam : Icons.photo,
                            size: 18,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item.isVideo ? 'Видео' : 'Фото',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (item.latitude != null && item.longitude != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                        child: Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: Colors.red[400]),
                            const SizedBox(width: 4),
                            Text(
                              '${item.latitude!.toStringAsFixed(4)}, ${item.longitude!.toStringAsFixed(4)}',
                              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    const Divider(height: 24),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showPickerSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}
