import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show File;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Hive.initFlutter();
    
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MovieAdapter());
    }
    
    await Hive.openBox<Movie>('movies');
    
    runApp(const MyApp());
  } catch (e) {
    print('Ошибка инициализации: $e');
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Ошибка: $e'),
        ),
      ),
    ));
  }
}

@HiveType(typeId: 0)
class Movie extends HiveObject {
  @HiveField(0)
  String title;
  
  @HiveField(1)
  int? year;
  
  @HiveField(2)
  String? genre;
  
  @HiveField(3)
  Uint8List? imageBytes;
  
  Movie({
    required this.title, 
    this.year, 
    this.genre, 
    this.imageBytes
  });
}

class MovieAdapter extends TypeAdapter<Movie> {
  @override
  final int typeId = 0;

  @override
  Movie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    
    return Movie(
      title: fields[0] as String,
      year: fields[1] as int?,
      genre: fields[2] as String?,
      imageBytes: fields[3] as Uint8List?,
    );
  }

  @override
  void write(BinaryWriter writer, Movie obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.year)
      ..writeByte(2)
      ..write(obj.genre)
      ..writeByte(3)
      ..write(obj.imageBytes);
  }
}

class AppColors {
  static const lightPrimary = Color(0xFF6200EE);
  static const lightSecondary = Color(0xFF03DAC6);
  static const lightBackground = Color(0xFFF5F5F5);
  static const lightSurface = Colors.white;
  static const lightError = Color(0xFFB00020);
  static const lightCardBackground = Colors.white;
  static const lightText = Color(0xFF1E1E1E);
  static const lightSubtext = Color(0xFF757575);
  
  static const darkPrimary = Color(0xFFBB86FC);
  static const darkSecondary = Color(0xFF03DAC6);
  static const darkBackground = Color(0xFF121212);
  static const darkSurface = Color(0xFF1E1E1E);
  static const darkError = Color(0xFFCF6679);
  static const darkCardBackground = Color(0xFF2C2C2C);
  static const darkText = Colors.white;
  static const darkSubtext = Color(0xFFB0B0B0);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDark = false;
  
  @override
  void initState() {
    super.initState();
    _loadTheme();
  }
  
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDark = prefs.getBool('darkMode') ?? false;
    });
  }
  
  void _toggleTheme(bool value) {
    setState(() => _isDark = value);
  }
  
  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.lightPrimary,
      scaffoldBackgroundColor: AppColors.lightBackground,
      cardColor: AppColors.lightCardBackground,
      
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightPrimary,
        secondary: AppColors.lightSecondary,
        surface: AppColors.lightSurface,
        error: AppColors.lightError,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: AppColors.lightText,
        onError: Colors.white,
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      
      cardTheme: CardThemeData(
        color: AppColors.lightCardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.lightText),
        bodyMedium: TextStyle(color: AppColors.lightText),
        titleLarge: TextStyle(color: AppColors.lightText, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: AppColors.lightText),
        labelLarge: TextStyle(color: AppColors.lightPrimary),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.lightSecondary,
        foregroundColor: Colors.black,
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.lightPrimary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.lightPrimary, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.lightPrimary),
      ),
      
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.lightPrimary;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.lightPrimary.withOpacity(0.5);
          }
          return null;
        }),
      ),
    );
  }
  
  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.darkPrimary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      cardColor: AppColors.darkCardBackground,
      
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        secondary: AppColors.darkSecondary,
        surface: AppColors.darkSurface,
        error: AppColors.darkError,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: AppColors.darkText,
        onError: Colors.black,
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkText,
        elevation: 4,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.darkText,
        ),
      ),
      
      cardTheme: CardThemeData(
        color: AppColors.darkCardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.darkText),
        bodyMedium: TextStyle(color: AppColors.darkSubtext),
        titleLarge: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: AppColors.darkText),
        labelLarge: TextStyle(color: AppColors.darkPrimary),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkSecondary,
        foregroundColor: Colors.black,
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.darkPrimary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.darkPrimary),
      ),
      
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.darkPrimary;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.darkPrimary.withOpacity(0.5);
          }
          return null;
        }),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Мини Кинопоиск',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: MovieListScreen(
        isDark: _isDark, 
        onThemeChanged: _toggleTheme,
      ),
    );
  }
}

class MovieListScreen extends StatefulWidget {
  final bool isDark;
  final void Function(bool) onThemeChanged;
  
  const MovieListScreen({
    super.key, 
    required this.isDark, 
    required this.onThemeChanged
  });
  
  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  late final Box<Movie> _box;
  
  @override
  void initState() {
    super.initState();
    _box = Hive.box<Movie>('movies');
  }

  void _showMovieDialog({Movie? existing}) {
    showDialog(
      context: context,
      builder: (context) => MovieDialog(
        existingMovie: existing,
        box: _box,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Любимые фильмы'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (context) => SettingsScreen(
                  isDark: widget.isDark, 
                  onChanged: widget.onThemeChanged,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<Movie>>(
        valueListenable: _box.listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.movie, 
                    size: 64, 
                    color: widget.isDark ? AppColors.darkSubtext : Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Список пуст',
                    style: TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold,
                      color: widget.isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Нажмите кнопку + чтобы добавить фильм',
                    style: TextStyle(
                      fontSize: 16, 
                      color: widget.isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                    ),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final movie = box.getAt(index);
              if (movie == null) return const SizedBox();
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: movie.imageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6), 
                          child: Image.memory(
                            movie.imageBytes!, 
                            width: 52, 
                            height: 72, 
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          width: 52,
                          height: 72,
                          decoration: BoxDecoration(
                            color: widget.isDark ? AppColors.darkSurface : Colors.grey[300],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.movie, 
                            size: 32,
                            color: widget.isDark ? AppColors.darkSubtext : Colors.grey[600],
                          ),
                        ),
                  title: Text(
                    movie.title, 
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: widget.isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                  subtitle: Text(
                    '${movie.year ?? "—"} • ${movie.genre ?? "жанр не указан"}',
                    style: TextStyle(
                      color: widget.isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit_outlined,
                          color: widget.isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                        ), 
                        onPressed: () => _showMovieDialog(existing: movie),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red), 
                        onPressed: () => movie.delete(),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMovieDialog(), 
        child: const Icon(Icons.add),
      ),
    );
  }
  
  @override
  void dispose() {
    super.dispose();
  }
}

class MovieDialog extends StatefulWidget {
  final Movie? existingMovie;
  final Box<Movie> box;
  
  const MovieDialog({
    super.key,
    this.existingMovie,
    required this.box,
  });

  @override
  State<MovieDialog> createState() => _MovieDialogState();
}

class _MovieDialogState extends State<MovieDialog> {
  final _titleCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _genreCtrl = TextEditingController();
  Uint8List? _currentImageBytes;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingMovie != null) {
      _titleCtrl.text = widget.existingMovie!.title;
      _yearCtrl.text = widget.existingMovie!.year?.toString() ?? '';
      _genreCtrl.text = widget.existingMovie!.genre ?? '';
      _currentImageBytes = widget.existingMovie!.imageBytes;
    }
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      
      if (result != null) {
        if (kIsWeb) {
          final bytes = result.files.first.bytes;
          if (bytes != null && mounted) {
            setState(() {
              _currentImageBytes = bytes;
            });
          }
        } else {
          final path = result.files.first.path;
          if (path != null) {
            final file = File(path);
            final bytes = await file.readAsBytes();
            if (mounted) {
              setState(() {
                _currentImageBytes = bytes;
              });
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка выбора изображения: $e')),
        );
      }
    }
  }

  void _handleDrop(DropDoneDetails details) async {
    final files = details.files;
    if (files.isNotEmpty) {
      if (kIsWeb) {
        _pickImage();
      } else {
        final path = files.first.path;
        if (path != null) {
          try {
            final file = File(path);
            final bytes = await file.readAsBytes();
            if (mounted) {
              setState(() {
                _currentImageBytes = bytes;
              });
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Ошибка загрузки изображения: $e')),
              );
            }
          }
        }
      }
    }
  }

  void _saveMovie() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название фильма')),
      );
      return;
    }

    final movie = Movie(
      title: title,
      year: int.tryParse(_yearCtrl.text.trim()),
      genre: _genreCtrl.text.trim().isNotEmpty ? _genreCtrl.text.trim() : null,
      imageBytes: _currentImageBytes,
    );

    if (widget.existingMovie != null) {
      widget.existingMovie!.title = movie.title;
      widget.existingMovie!.year = movie.year;
      widget.existingMovie!.genre = movie.genre;
      widget.existingMovie!.imageBytes = movie.imageBytes;
      widget.existingMovie!.save();
    } else {
      widget.box.add(movie);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingMovie != null;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AlertDialog(
      title: Text(
        isEdit ? 'Редактировать фильм' : 'Новый фильм',
        style: TextStyle(
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
      ),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: 'Название *',
                labelStyle: TextStyle(
                  color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    width: 2,
                  ),
                ),
              ),
              style: TextStyle(
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _yearCtrl,
              decoration: InputDecoration(
                labelText: 'Год',
                labelStyle: TextStyle(
                  color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    width: 2,
                  ),
                ),
              ),
              style: TextStyle(
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _genreCtrl,
              decoration: InputDecoration(
                labelText: 'Жанр',
                labelStyle: TextStyle(
                  color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    width: 2,
                  ),
                ),
              ),
              style: TextStyle(
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 20),
            
            if (!kIsWeb) 
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _isDragging 
                      ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                      : (isDark ? Colors.grey[700]! : Colors.grey),
                    width: _isDragging ? 3 : 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropTarget(
                  onDragDone: _handleDrop,
                  onDragEntered: (_) {
                    if (mounted) {
                      setState(() => _isDragging = true);
                    }
                  },
                  onDragExited: (_) {
                    if (mounted) {
                      setState(() => _isDragging = false);
                    }
                  },
                  child: _buildImageContent(isDark),
                ),
              )
            else
              Column(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? Colors.grey[700]! : Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: isDark ? AppColors.darkSurface : AppColors.lightBackground,
                    ),
                    child: _buildImageContent(isDark),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Выбрать изображение'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 45),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Отмена',
            style: TextStyle(
              color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _saveMovie,
          child: Text(isEdit ? 'Сохранить' : 'Добавить'),
        ),
      ],
    );
  }

  Widget _buildImageContent(bool isDark) {
    if (_currentImageBytes != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.memory(
              _currentImageBytes!,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
                padding: const EdgeInsets.all(4),
              ),
              onPressed: () {
                setState(() {
                  _currentImageBytes = null;
                });
              },
            ),
          ),
        ],
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload, 
              size: 64, 
              color: isDark ? AppColors.darkSubtext : Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              'Перетащите фото сюда\nили нажмите кнопку ниже',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.darkSubtext : Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _yearCtrl.dispose();
    _genreCtrl.dispose();
    super.dispose();
  }
}

class SettingsScreen extends StatelessWidget {
  final bool isDark;
  final void Function(bool) onChanged;
  
  const SettingsScreen({
    super.key, 
    required this.isDark, 
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(
              'Тёмная тема',
              style: TextStyle(
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            subtitle: Text(
              'Включить темный режим оформления',
              style: TextStyle(
                color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
              ),
            ),
            value: isDark,
            activeColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
            onChanged: (value) async {
              onChanged(value);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('darkMode', value);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}