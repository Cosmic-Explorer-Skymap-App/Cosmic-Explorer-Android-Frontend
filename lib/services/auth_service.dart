import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api_service.dart';

class AuthService {
  static String? lastError;

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: dotenv.get('GOOGLE_API_CLIENT_ID', fallback: ''),
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

  static Future<bool> checkUserStatus() async {
    // All users have access to all features now.
    return true;
  }

  static Future<bool> shouldShowAds() async {
    // Ads are mandatory for everyone.
    return true;
  }

  static Future<bool> upgradeToPremium() async {
    // Premium upgrade is disabled.
    return false;
  }

  static Future<UserStatus?> getUserStatus() async {
    try {
      final response = await ApiService.get('/api/user/status');
      if (response.statusCode == 200) {
        return UserStatus.fromJson(response.data);
      }
    } catch (e) {
      // Silently fail - user status is non-critical
    }
    return null;
  }
}

class UserStatus {
  final bool isPremium;
  final bool isTrialActive;
  final bool showAds;
  final DateTime? premiumUntil;
  final DateTime? trialEndsAt;

  UserStatus({
    required this.isPremium,
    required this.isTrialActive,
    required this.showAds,
    this.premiumUntil,
    this.trialEndsAt,
  });

  factory UserStatus.fromJson(Map<String, dynamic> json) {
    return UserStatus(
      isPremium: json['is_premium'] == true,
      isTrialActive: json['is_trial_active'] == true,
      showAds: json['show_ads'] == true,
      premiumUntil: json['premium_until'] != null ? DateTime.parse(json['premium_until']) : null,
      trialEndsAt: json['trial_ends_at'] != null ? DateTime.parse(json['trial_ends_at']) : null,
    );
  }

  int get trialDaysLeft {
    if (trialEndsAt == null) return 0;
    final now = DateTime.now().toUtc();
    final diff = trialEndsAt!.difference(now);
    return diff.isNegative ? 0 : diff.inDays;
  }

  int get trialHoursLeft {
    if (trialEndsAt == null) return 0;
    final now = DateTime.now().toUtc();
    final diff = trialEndsAt!.difference(now);
    return diff.isNegative ? 0 : diff.inHours % 24;
  }
}
