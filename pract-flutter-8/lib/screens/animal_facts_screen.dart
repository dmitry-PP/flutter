import 'dart:math';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

final _getIt = GetIt.instance;

class AnimalFactsScreen extends StatefulWidget {
  const AnimalFactsScreen({super.key});

  @override
  State<AnimalFactsScreen> createState() => _AnimalFactsScreenState();
}

class _AnimalFactsScreenState extends State<AnimalFactsScreen> {
  final _searchController = TextEditingController();
  List<dynamic> _animals = [];
  bool _isLoading = false;
  String? _error;
  final List<String> _history = [];
  final Set<String> _favorites = {};

  final List<String> _popularAnimals = [
    'cat', 'dog', 'lion', 'tiger', 'elephant', 'panda', 'shark', 'wolf', 'fox', 'bear',
    'cheetah', 'eagle', 'owl', 'snake', 'frog', 'giraffe', 'zebra', 'monkey', 'horse', 'cow',
    'rabbit', 'deer', 'kangaroo', 'koala', 'penguin'
  ];

  Future<void> _fetchAnimals(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _animals = [];
    });

    try {
      final dio = _getIt<Dio>();
      final response = await dio.get(
        '/v1/animals',
        queryParameters: {'name': trimmed},
      );

      if (response.statusCode == 200) {
        setState(() {
          _animals = response.data as List<dynamic>;
          final lower = trimmed.toLowerCase();
          if (!_history.contains(lower)) {
            _history.add(lower);
          }
        });
      } else {
        setState(() => _error = 'Ошибка сервера: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _error = 'Не удалось загрузить: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _getRandomAnimal() {
    final randomIndex = Random().nextInt(_popularAnimals.length);
    final animal = _popularAnimals[randomIndex];
    _searchController.text = animal;
    _fetchAnimals(animal);
  }

  void _toggleFavorite(String name) {
    setState(() {
      final lower = name.toLowerCase();
      if (_favorites.contains(lower)) {
        _favorites.remove(lower);
      } else {
        _favorites.add(lower);
      }
    });
  }

  void _showFavoritesDialog() {
    if (_favorites.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Избранное пусто')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Избранные животные'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: _favorites.map((name) => ListTile(
              title: Text(name),
              onTap: () {
                _searchController.text = name;
                _fetchAnimals(name);
                Navigator.pop(context);
              },
            )).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Факты о животных'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Избранное',
            onPressed: _showFavoritesDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Название животного (на английском)',
                hintText: 'например: lion, panda, shark',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _fetchAnimals(_searchController.text),
                ),
              ),
              onSubmitted: _fetchAnimals,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.shuffle),
                  label: const Text('Случайное животное'),
                  onPressed: _getRandomAnimal,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete_sweep),
                  label: const Text('Очистить историю'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  onPressed: () => setState(() => _history.clear()),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_isLoading) const CircularProgressIndicator(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(
              child: _animals.isEmpty
                  ? const Center(child: Text('Введите название животного'))
                  : ListView.builder(
                      itemCount: _animals.length,
                      itemBuilder: (context, index) {
                        final animal = _animals[index];
                        final name = animal['name'] ?? '—';
                        final taxonomy = animal['taxonomy'] ?? {};
                        final characteristics = animal['characteristics'] ?? {};
                        final locations = (animal['locations'] as List<dynamic>?)?.join(', ') ?? '—';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        _favorites.contains(name.toLowerCase())
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: _favorites.contains(name.toLowerCase()) ? Colors.red : null,
                                      ),
                                      onPressed: () => _toggleFavorite(name),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                _buildRow('Scientific name', taxonomy['scientific_name'] ?? '—'),
                                _buildRow('Class', taxonomy['class'] ?? '—'),
                                _buildRow('Habitat', characteristics['habitat'] ?? '—'),
                                _buildRow('Diet', characteristics['diet'] ?? '—'),
                                _buildRow('Prey', characteristics['prey'] ?? '—'),
                                _buildRow('Top speed', characteristics['top_speed'] ?? '—'),
                                _buildRow('Lifespan', characteristics['lifespan'] ?? '—'),
                                _buildRow('Weight', characteristics['weight'] ?? '—'),
                                _buildRow('Locations', locations),
                                if (characteristics['slogan'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Text(
                                      characteristics['slogan'],
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.blueGrey[700],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (_history.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'История поиска:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _history.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text(item),
                        onPressed: () {
                          _searchController.text = item;
                          _fetchAnimals(item);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
