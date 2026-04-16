import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api_service.dart';

class AuthService {
  static String? lastError;

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: dotenv.get('GOOGLE_SERVER_CLIENT_ID', fallback: ''),
    scopes: [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );

  static Future<bool> signInWithGoogle() async {
    try {
      lastError = null;
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        lastError = "Giriş İptal Edildi veya Beklenmeyen Durum";
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken != null) {
        final response = await ApiService.post('/api/auth/google', data: {
          'id_token': idToken,
        });

        if (response.statusCode == 200) {
          final String token = response.data['access_token'];
          await ApiService.saveToken(token);
          return true;
        } else {
          lastError = "Sunucu Hatası: Hata kodu ${response.statusCode}";
        }
      } else {
        lastError = "ID Token alınamadı. SHA-1 veya Client ID uyuşmazlığı olabilir.";
      }
      return false;
    } catch (e) {
      lastError = "Hata oluştu: $e";
      return false;
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await ApiService.clearToken();
  }

}
