import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'api_service.dart';

class AuthService {
  static String? lastError;

  static GoogleSignIn _buildGoogleSignIn() {
    final serverClientId =
        (dotenv.env['GOOGLE_SERVER_CLIENT_ID'] ?? '').trim();
    final androidClientId =
        (dotenv.env['GOOGLE_ANDROID_CLIENT_ID'] ?? '').trim();

    // Prefer server client id for backend-verifiable ID tokens.
    final effectiveClientId =
        serverClientId.isNotEmpty ? serverClientId : androidClientId;

    return GoogleSignIn(
      serverClientId: effectiveClientId.isEmpty ? null : effectiveClientId,
      scopes: [
        'email',
        'https://www.googleapis.com/auth/userinfo.profile',
      ],
    );
  }

  static final GoogleSignIn _googleSignIn = _buildGoogleSignIn();

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
          final tokenValue = response.data['access_token'];
          if (tokenValue is! String || tokenValue.isEmpty) {
            lastError = "Giriş yanıtı geçersiz. Lütfen tekrar deneyin.";
            return false;
          }
          final String token = tokenValue;
          await ApiService.saveToken(token);
          return true;
        } else {
          lastError = "Sunucu Hatası: Hata kodu ${response.statusCode}";
        }
      } else {
        lastError = "ID Token alınamadı. SHA-1 veya Client ID uyuşmazlığı olabilir.";
      }
      return false;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401) {
        lastError = "Kimlik doğrulama başarısız. Google hesabınla tekrar giriş yap.";
      } else if (status == 429) {
        lastError = "Çok fazla istek gönderildi. Lütfen kısa süre sonra tekrar dene.";
      } else if (status != null) {
        lastError = "Sunucu hatası ($status). Lütfen tekrar dene.";
      } else {
        lastError = "Ağ hatası. İnternet bağlantını kontrol edip tekrar dene.";
      }
      return false;
    } on PlatformException catch (e) {
      final message = (e.message ?? '').toLowerCase();
      final code = e.code.toLowerCase();
      if (message.contains('10') ||
          message.contains('developer_error') ||
          code.contains('sign_in_failed')) {
        lastError =
            "Google giriş yapılandırması hatalı (SHA-1 / Client ID). Geliştiriciye bildir.";
      } else {
        lastError = "Google giriş hatası: ${e.message ?? e.code}";
      }
      return false;
    } catch (_) {
      lastError = "Beklenmeyen bir hata oluştu. Lütfen tekrar dene.";
      return false;
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await ApiService.clearToken();
  }

}
