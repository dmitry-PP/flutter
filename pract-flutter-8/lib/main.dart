import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'api_key.dart';
import 'models/media_item.dart';
import 'models/audio_track.dart';
import 'screens/home_screen.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive
  await Hive.initFlutter();
  Hive.registerAdapter(MediaItemAdapter());
  Hive.registerAdapter(AudioTrackAdapter());
  await Hive.openBox<MediaItem>('mediaItems');
  await Hive.openBox<AudioTrack>('audioTracks');

  // Dio
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.api-ninjas.com',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  dio.interceptors.add(AuthInterceptor());
  dio.interceptors.add(PrettyDioLogger(
    requestHeader: true,
    requestBody: true,
    responseBody: true,
    responseHeader: false,
    error: true,
    compact: true,
    maxWidth: 90,
  ));

  getIt.registerSingleton<Dio>(dio);

  runApp(const MyApp());
}

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['X-Api-Key'] = NINJA_API_KEY;
    super.onRequest(options, handler);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animal Facts',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
