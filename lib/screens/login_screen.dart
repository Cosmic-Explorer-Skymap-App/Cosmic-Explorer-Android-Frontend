import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../app.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    
    final success = await AuthService.signInWithGoogle();
    
    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
         // Navigate to app/home refreshed route
         Navigator.of(context).pushReplacement(
           MaterialPageRoute(builder: (context) => const CosmicExplorerApp()),
         );
      }
    } else {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('Giriş başarısız: ${AuthService.lastError ?? "Bilinmeyen Hata"}'),
             duration: const Duration(seconds: 5), // Süreyi uzatalım ki rahat okunsun
           ),
         );
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background space theme or color
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF03001e), Color(0xFF7303c0), Color(0xFFec38bc)],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.blur_on, size: 100, color: Colors.white),
                  const SizedBox(height: 24),
                  const Text(
                    'Cosmic Explorer',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Evreni Keşfetmeye Hazır Mısın?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 48),
                  if (_isLoading)
                    const CircularProgressIndicator(color: Colors.white)
                  else
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: Image.network(
                        'https://rotatortools.com/images/google.png', // Fallback icon, better to include asset
                        height: 24,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.account_circle),
                      ),
                      label: const Text(
                        'Google ile Giriş Yap',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _handleGoogleSignIn,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
