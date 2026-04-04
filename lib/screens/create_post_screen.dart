import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/feed_service.dart';
import '../services/gallery_service.dart';
import '../theme/space_theme.dart';

class CreatePostScreen extends StatefulWidget {
  /// Optionally pre-fill with an existing gallery item.
  final AstrophotographyItem? galleryItem;

  const CreatePostScreen({super.key, this.galleryItem});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _titleController = TextEditingController();
  final _captionController = TextEditingController();
  File? _image;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.galleryItem != null) {
      _image = File(widget.galleryItem!.path);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null && mounted) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<void> _share() async {
    final title = _titleController.text.trim();
    if (_image == null) {
      _snack('Lütfen bir fotoğraf seç.');
      return;
    }
    if (title.isEmpty) {
      _snack('Başlık boş olamaz.');
      return;
    }

    setState(() => _uploading = true);
    try {
      await FeedService.createPost(
        image: _image!,
        title: title,
        caption: _captionController.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context, true); // true → refresh feed
      }
    } catch (e) {
      if (mounted) {
        _snack('Paylaşım başarısız: $e');
        setState(() => _uploading = false);
      }
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpaceTheme.deepSpace,
      appBar: AppBar(
        title: const Text('Yeni Paylaşım'),
        actions: [
          if (!_uploading)
            TextButton(
              onPressed: _share,
              child: const Text(
                'Paylaş',
                style: TextStyle(
                    color: SpaceTheme.nebulaPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
          if (_uploading)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: SpaceTheme.nebulaPurple)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image picker area
            GestureDetector(
              onTap: _uploading ? null : _pickImage,
              child: Container(
                width: double.infinity,
                height: 260,
                decoration: BoxDecoration(
                  color: SpaceTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _image == null
                        ? SpaceTheme.nebulaPurple.withValues(alpha: 0.4)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: _image == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              size: 56, color: SpaceTheme.nebulaPurple),
                          SizedBox(height: 12),
                          Text('Galeriden fotoğraf seç',
                              style: TextStyle(color: Colors.white54, fontSize: 15)),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(_image!, fit: BoxFit.cover),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.edit,
                                      color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            const _Label('Başlık *'),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              maxLength: 120,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Fotoğrafına bir başlık ver...'),
              enabled: !_uploading,
            ),
            const SizedBox(height: 14),

            // Caption
            const _Label('Açıklama'),
            const SizedBox(height: 6),
            TextField(
              controller: _captionController,
              maxLength: 1000,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(
                  'Bu fotoğrafı çekerken neler yaşandı? Hangi ekipmanı kullandın?'),
              enabled: !_uploading,
            ),
          ],
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
