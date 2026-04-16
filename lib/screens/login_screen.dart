import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../app.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/// Pure Flutter Google "G" icon — no external dependencies or network calls.
class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final center = rect.center;
    final radius = size.width / 2;

    // Red arc (top-right to bottom-left)
    final paintRed = Paint()..color = const Color(0xFFEA4335)..style = PaintingStyle.stroke..strokeWidth = size.width * 0.18..strokeCap = StrokeCap.butt;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius * 0.78), -0.52, 1.57, false, paintRed);

    // Yellow arc
    final paintYellow = Paint()..color = const Color(0xFFFBBC05)..style = PaintingStyle.stroke..strokeWidth = size.width * 0.18..strokeCap = StrokeCap.butt;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius * 0.78), 1.05, 1.05, false, paintYellow);

    // Green arc
    final paintGreen = Paint()..color = const Color(0xFF34A853)..style = PaintingStyle.stroke..strokeWidth = size.width * 0.18..strokeCap = StrokeCap.butt;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius * 0.78), 2.1, 1.05, false, paintGreen);

    // Blue arc
    final paintBlue = Paint()..color = const Color(0xFF4285F4)..style = PaintingStyle.stroke..strokeWidth = size.width * 0.18..strokeCap = StrokeCap.butt;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius * 0.78), 3.15, 1.09, false, paintBlue);

    // Blue horizontal bar (right side of G)
    final barPaint = Paint()..color = const Color(0xFF4285F4)..style = PaintingStyle.fill;
    final barRight = center.dx + radius * 0.78;
    final barLeft = center.dx + radius * 0.10;
    final barTop = center.dy - size.height * 0.09;
    final barBottom = center.dy + size.height * 0.09;
    canvas.drawRect(Rect.fromLTRB(barLeft, barTop, barRight, barBottom), barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
                      icon: _GoogleIcon(),
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
