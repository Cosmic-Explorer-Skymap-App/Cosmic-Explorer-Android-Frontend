import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static String get _baseUrl {
    final url = dotenv.get('API_URL', fallback: '');
    if (url.isEmpty) {
      throw StateError('API_URL is not configured in .env file');
    }
    return url;
  }

  static final Dio _dio = Dio();
  static const _storage = FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';

  static Future<void> init() async {
    _dio.options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          await clearToken();
        }
        return handler.next(e);
      },
    ));
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    if (token == null) return false;

    try {
      final response = await _dio.get('/api/auth/session');
      final data = response.data;
      if (response.statusCode == 200 && data is Map && data['authenticated'] == true) {
        return true;
      }
    } on DioException {
      // Token invalid or backend unreachable. In both cases we should not assume auth.
    }

    await clearToken();
    return false;
  }

  // GET Wrapper
  static Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  // POST Wrapper
  static Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  // POST with FormData (multipart)
  static Future<Response> postForm(String path, {required FormData data}) async {
    return await _dio.post(
      path,
      data: data,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  // PUT Wrapper
  static Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  // DELETE Wrapper
  static Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}
