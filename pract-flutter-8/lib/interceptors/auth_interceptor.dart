import 'package:dio/dio.dart';
import '../api_key.dart'; 

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['X-Api-Key'] = NINJA_API_KEY;
    super.onRequest(options, handler);
  }
}