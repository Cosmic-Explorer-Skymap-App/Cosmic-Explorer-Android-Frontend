import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class AstrophotographyItem {
  final String path;
  final DateTime timestamp;

  AstrophotographyItem({required this.path, required this.timestamp});

  Map<String, dynamic> toJson() => {
        'path': path,
        'timestamp': timestamp.toIso8601String(),
      };

  factory AstrophotographyItem.fromJson(Map<String, dynamic> json) {
    return AstrophotographyItem(
      path: json['path'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class GalleryService {
  static const String _metadataFile = 'astrophotos.json';

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _getMetadataFile async {
    final path = await _localPath;
    return File('$path/$_metadataFile');
  }

  static Future<List<AstrophotographyItem>> getPhotos() async {
    try {
      final file = await _getMetadataFile;
      if (!await file.exists()) return [];

      final String content = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(content);

      return jsonList.map((e) => AstrophotographyItem.fromJson(e)).toList();
    } catch (e) {
      print('Gallery loading error: $e');
      return [];
    }
  }

  static Future<void> savePhoto(String originalPath) async {
    try {
      final path = await _localPath;
      final Directory galleryDir = Directory('$path/astrophotography');
      if (!await galleryDir.exists()) {
        await galleryDir.create(recursive: true);
      }

      final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String newPath = '${galleryDir.path}/$fileName';

      // Copy image to local internal storage
      await File(originalPath).copy(newPath);

      // Save metadata
      final List<AstrophotographyItem> photos = await getPhotos();
      photos.add(AstrophotographyItem(
        path: newPath,
        timestamp: DateTime.now(),
      ));

      final file = await _getMetadataFile;
      await file.writeAsString(jsonEncode(photos.map((e) => e.toJson()).toList()));
    } catch (e) {
       print('Gallery save error: $e');
    }
  }

  static Future<void> deletePhoto(AstrophotographyItem item) async {
    try {
      // Delete file
      final file = File(item.path);
      if (await file.exists()) {
        await file.delete();
      }

      // Update metadata
      final List<AstrophotographyItem> photos = await getPhotos();
      photos.removeWhere((e) => e.path == item.path);

      final metaFile = await _getMetadataFile;
      await metaFile.writeAsString(jsonEncode(photos.map((e) => e.toJson()).toList()));
    } catch (e) {
       print('Gallery delete error: $e');
    }
  }

  static Future<void> sharePhoto(AstrophotographyItem item) async {
    final file = XFile(item.path);
    await Share.shareXFiles([file], text: 'Gecenin Büyüsü ✨ #CosmicExplorer');
  }
}
