import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_profile_model.dart';
import '../services/feed_service.dart';
import '../theme/space_theme.dart';
import '../widgets/user_avatar.dart';

class SetupAvatarScreen extends StatefulWidget {
  final UserProfile currentProfile;
  final ValueChanged<UserProfile> onCompleted;

  const SetupAvatarScreen({
    super.key,
    required this.currentProfile,
    required this.onCompleted,
  });

  @override
  State<SetupAvatarScreen> createState() => _SetupAvatarScreenState();
}

class _SetupAvatarScreenState extends State<SetupAvatarScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _pickedImage;
  bool _loading = false;
  String? _error;

  Future<void> _pick(ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 88, maxWidth: 1600);
    if (file == null) return;
    setState(() {
      _pickedImage = File(file.path);
      _error = null;
    });
  }

  Future<void> _submit() async {
    if (_pickedImage == null) {
      setState(() => _error = 'Lütfen profil fotoğrafı seç.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final profile = await FeedService.uploadAvatar(_pickedImage!);
      if (!mounted) return;
      widget.onCompleted(profile);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Profil fotoğrafı yüklenemedi. Tekrar dene.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.currentProfile;
    final previewImage = _pickedImage;
    return Scaffold(
      backgroundColor: SpaceTheme.deepSpace,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF111827), Color(0xFF1C1B33), Color(0xFF0B1020)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Profil Fotoğrafı',
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'İlk izlenimi güçlendirmek için bir profil fotoğrafı ekle.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: SpaceTheme.nebulaPurple, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 58,
                          backgroundColor: Colors.white12,
                          child: ClipOval(
                            child: SizedBox(
                              width: 116,
                              height: 116,
                              child: previewImage != null
                                  ? Image.file(previewImage, fit: BoxFit.cover)
                                  : UserAvatar(
                                      username: profile.username,
                                      avatarUrl: profile.avatarUrl,
                                      radius: 58,
                                    ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: SpaceTheme.nebulaPurple,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    profile.displayedName,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${profile.username}',
                    style: const TextStyle(color: Colors.white54),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _loading ? null : () => _pick(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Galeri'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _loading ? null : () => _pick(ImageSource.camera),
                          icon: const Icon(Icons.photo_camera_outlined),
                          label: const Text('Kamera'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SpaceTheme.nebulaPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Profili Tamamla', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
