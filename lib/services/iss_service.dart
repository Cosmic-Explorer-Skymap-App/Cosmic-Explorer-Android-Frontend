import 'package:dio/dio.dart';

class IssService {
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  /// Fetches current latitude, longitude, velocity and altitude of ISS
  static Future<Map<String, dynamic>?> getCurrentLocation() async {
    try {
      final response = await _dio.get('https://api.wheretheiss.at/v1/satellites/25544');
      if (response.statusCode == 200) {
        return response.data; // contains: latitude, longitude, velocity, altitude
      }
    } catch (e) {
      print('ISS Fetch Error: $e');
    }
    return null;
  }
}
