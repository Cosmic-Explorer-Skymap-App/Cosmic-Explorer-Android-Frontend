import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/gallery_service.dart';
import '../theme/space_theme.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<AstrophotographyItem> _photos = [];
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final photos = await GalleryService.getPhotos();
    setState(() {
      _photos = photos;
      _isLoading = false;
    });
  }

  Future<void> _takePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      await GalleryService.savePhoto(image.path);
      _loadPhotos(); // Refresh
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Fotoğraf başarıyla galeriye kaydedildi!')),
         );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await GalleryService.savePhoto(image.path);
      _loadPhotos(); // Refresh
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Fotoğraf başarıyla içe aktarıldı!')),
         );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpaceTheme.deepSpace,
      appBar: AppBar(
        title: const Text('Astrofotoğrafçılık Galerisi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate),
            onPressed: _pickFromGallery,
            tooltip: 'Galeriden Seç',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: SpaceTheme.nebulaPurple))
          : _photos.isEmpty
              ? _buildEmptyState()
              : _buildGridState(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: SpaceTheme.stellarGold,
        foregroundColor: Colors.black,
        onPressed: _takePhoto,
        tooltip: 'Fotoğraf Çek',
        child: const Icon(Icons.camera_enhance),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.photo_library_outlined, size: 80, color: Colors.white54),
            const SizedBox(height: 24),
            const Text(
              'Henüz fotoğraf yok.',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Gökyüzünün büyüleyici anlarını yakalamak için hemen bir fotoğraf çekin.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridState() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: _photos.length,
      itemBuilder: (context, index) {
        final item = _photos[index];
        final formattedDate = '${item.timestamp.day}.${item.timestamp.month}.${item.timestamp.year} ${item.timestamp.hour}:${item.timestamp.minute.toString().padLeft(2, '0')}';

        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: SpaceTheme.glassCard,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.file(
                    File(item.path),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.broken_image, color: Colors.white24),
                    ),
                  ),
                ),
                // Bottom Gradient overlay for text Contrast
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formattedDate,
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
                // Actions Overlays top right
                Positioned(
                  top: 4,
                  right: 4,
                  child: Row(
                    children: [
                      _CircleActionBtn(
                        icon: Icons.share,
                        color: Colors.blueAccent,
                        onPressed: () => GalleryService.sharePhoto(item),
                      ),
                      const SizedBox(width: 4),
                      _CircleActionBtn(
                        icon: Icons.delete,
                        color: Colors.redAccent,
                        onPressed: () => _confirmDelete(item),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(AstrophotographyItem item) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SpaceTheme.deepSpace,
        title: const Text('Silme Onayı', style: TextStyle(color: Colors.white)),
        content: const Text('Bu fotoğrafı silmek istediğinize emin misiniz?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await GalleryService.deletePhoto(item);
      _loadPhotos();
    }
  }
}

class _CircleActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _CircleActionBtn({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 18),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        onPressed: onPressed,
      ),
    );
  }
}
