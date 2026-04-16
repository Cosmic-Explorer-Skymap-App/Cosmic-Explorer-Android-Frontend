import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../theme/space_theme.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  
  File? _imageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final formData = FormData.fromMap({
        'full_name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'subject': _subjectController.text.trim(),
        'message': _messageController.text.trim(),
      });

      if (_imageFile != null) {
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(_imageFile!.path, filename: 'screenshot.jpg'),
        ));
      }

      await ApiService.postForm('/api/support/', data: formData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mesajınız iletildi. Teşekkürler!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata oluştu: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Destek Ekibi"),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: SpaceTheme.gradientBackground,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Bize Yazın",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Sorunlarınızı veya önerilerinizi aşağıdan iletebilirsiniz.",
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _buildField("Ad Soyad", _nameController, Icons.person_outline),
                const SizedBox(height: 16),
                _buildField("E-posta", _emailController, Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildField("Konu", _subjectController, Icons.subject_rounded),
                const SizedBox(height: 16),
                _buildField("Mesajınız", _messageController, Icons.message_outlined, maxLines: 5),
                const SizedBox(height: 24),
                
                // Image Picker
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12, style: BorderStyle.solid),
                    ),
                    child: _imageFile != null
                        ? Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(_imageFile!, height: 150, width: double.infinity, fit: BoxFit.cover),
                              ),
                              const SizedBox(height: 8),
                              const Text("Görseli Değiştir", style: TextStyle(color: Colors.blueAccent, fontSize: 12)),
                            ],
                          )
                        : const Column(
                            children: [
                              Icon(Icons.add_a_photo_outlined, color: Colors.white38, size: 32),
                              SizedBox(height: 8),
                              Text("Ekran Görüntüsü Ekle (Opsiyonel)", style: TextStyle(color: Colors.white38, fontSize: 13)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 40),
                
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: SpaceTheme.nebulaPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text("Gönder", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
      validator: (value) => (value == null || value.isEmpty) ? "Bu alan boş bırakılamaz" : null,
    );
  }
}
