import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/user_profile_model.dart';
import '../services/feed_service.dart';
import '../theme/space_theme.dart';

class SetupUsernameScreen extends StatefulWidget {
  final ValueChanged<UserProfile>? onCompleted;

  const SetupUsernameScreen({super.key, this.onCompleted});

  @override
  State<SetupUsernameScreen> createState() => _SetupUsernameScreenState();
}

class _SetupUsernameScreenState extends State<SetupUsernameScreen> {
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  bool _loading = false;
  String? _error;

  static final _usernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,50}$');

  @override
  void dispose() {
    _usernameController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    if (!_usernameRegex.hasMatch(username)) {
      setState(() =>
          _error = 'Kullanıcı adı 3-50 karakter olmalı, sadece harf, rakam ve _ içerebilir.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final profile = await FeedService.setupProfile(
        username: username,
        displayName: _displayNameController.text.trim(),
      );
      if (!mounted) return;
      if (widget.onCompleted != null) {
        widget.onCompleted!(profile);
      } else {
        Navigator.pop<UserProfile>(context, profile);
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.response?.statusCode == 409
              ? 'Bu kullanıcı adı zaten alınmış.'
              : 'Bir hata oluştu. Tekrar dene.';
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Bir hata oluştu. Tekrar dene.';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpaceTheme.deepSpace,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '✦',
                  style: TextStyle(
                      color: SpaceTheme.stellarGold, fontSize: 40),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Cosmic Feed\'e\nHoş Geldin!',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Astro fotoğraflarını dünyayla paylaşmak için bir kullanıcı adı seç.',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 36),

                // Username
                const _Label('Kullanıcı Adı *'),
                const SizedBox(height: 6),
                TextField(
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.white),
                  maxLength: 50,
                  decoration: _inputDecoration('@kullanici_adi'),
                  textInputAction: TextInputAction.next,
                  enabled: !_loading,
                ),
                const SizedBox(height: 14),

                // Display name
                const _Label('Görünen İsim (opsiyonel)'),
                const SizedBox(height: 6),
                TextField(
                  controller: _displayNameController,
                  style: const TextStyle(color: Colors.white),
                  maxLength: 100,
                  decoration: _inputDecoration('Adın veya takma adın'),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  enabled: !_loading,
                ),

                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!,
                      style:
                          const TextStyle(color: Colors.redAccent, fontSize: 13)),
                ],

                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SpaceTheme.nebulaPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Devam Et',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
      filled: true,
      fillColor: SpaceTheme.surfaceCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: SpaceTheme.nebulaPurple),
      ),
      counterStyle: const TextStyle(color: Colors.white30),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
    );
  }
}
