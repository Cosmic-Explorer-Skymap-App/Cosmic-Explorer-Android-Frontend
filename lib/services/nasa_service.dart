import 'package:dio/dio.dart';

class NasaService {
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  /// Fetches Astronomy Picture of the Day (APOD)
  static Future<Map<String, dynamic>?> getApod() async {
    try {
      final response = await _dio.get('https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY');
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      print('NASA APOD Fetch Error: $e');
    }
    return null;
  }
}
