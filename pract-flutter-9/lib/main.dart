import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/media_item.dart';
import 'models/music_item.dart';
import 'screens/gallery_screen.dart';
import 'screens/music_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(MediaItemAdapter());
  Hive.registerAdapter(MusicItemAdapter());
  await Hive.openBox<MediaItem>('media');
  await Hive.openBox<MusicItem>('music');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OLED Media',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.dark,
          surface: Colors.black,
          primary: Colors.amber,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          surfaceTintColor: Colors.transparent,
          title: const Text(
            'STUDIO',
            style: TextStyle(
              letterSpacing: 4,
              fontWeight: FontWeight.w900,
              fontSize: 24,
              color: Colors.amber,
            ),
          ),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.amber,
            labelColor: Colors.amber,
            unselectedLabelColor: Colors.white24,
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: 12,
            ),
            tabs: [
              Tab(text: 'GALLERY', icon: Icon(Icons.grid_3x3_sharp, size: 20)),
              Tab(text: 'AUDIO', icon: Icon(Icons.graphic_eq_sharp, size: 20)),
            ],
          ),
        ),
        body: const TabBarView(children: [GalleryScreen(), MusicScreen()]),
      ),
    );
  }
}
