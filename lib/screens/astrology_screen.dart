import 'package:flutter/material.dart';
import 'package:cosmic_explorer/l10n/generated/app_localizations.dart';
import '../services/astrology_service.dart';
import '../services/user_data_service.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../theme/space_theme.dart';

class AstrologyScreen extends StatefulWidget {
  const AstrologyScreen({super.key});

  @override
  State<AstrologyScreen> createState() => _AstrologyScreenState();
}

class _AstrologyScreenState extends State<AstrologyScreen> {
  DateTime? _birthDate;
  bool _isLoading = true;
  bool _isPremiumOrTrial = false;
  bool _isAiLoading = false;
  String? _aiPrediction;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final date = UserDataService.getBirthDate();
    final status = await AuthService.checkUserStatus();

    setState(() {
      _birthDate = date;
      _isPremiumOrTrial = status;
      _isLoading = false;
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: SpaceTheme.nebulaPurple,
              onPrimary: Colors.white,
              surface: SpaceTheme.deepSpace,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      await UserDataService.saveBirthDate(picked);
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _resetDate() async {
    await UserDataService.clearBirthDate();
    setState(() {
      _birthDate = null;
    });
  }

  Future<void> _getAiReading() async {
    setState(() => _isAiLoading = true);
    try {
      final sign = AstrologyService.getSign(_birthDate!);
      final response = await ApiService.post('/api/ai/astrology', data: {
        'sign': sign.name.split('.').last, // Name string
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _aiPrediction = response.data['prediction'];
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.data['detail'] ?? response.data['message'] ?? 'AI Hatası.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('AI yüklenirken hata oluştu veya günlük limit doldu.')),
         );
      }
    } finally {
      if (mounted) {
         setState(() => _isAiLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: SpaceTheme.deepSpace,
        body: Center(child: CircularProgressIndicator(color: SpaceTheme.nebulaPurple)),
      );
    }

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: SpaceTheme.deepSpace,
      appBar: AppBar(
        title: Text(l10n.astrologyScreenTitle),
        actions: [
          if (_birthDate != null && _isPremiumOrTrial)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: l10n.astrologyResetDate,
              onPressed: _resetDate,
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: SpaceTheme.gradientBackground,
          ),
        ),
        child: SafeArea(
          child: _birthDate == null ? _buildInputState(l10n) : _buildAstrologyState(l10n),
        ),
      ),
    );
  }

  // _buildLockState removed as per user request

  Widget _buildInputState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, size: 80, color: SpaceTheme.stellarGold),
            const SizedBox(height: 24),
            Text(
              l10n.astrologyEnterBirthDate,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.astrologyEnterBirthDateDesc,
              style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _selectDate,
              style: ElevatedButton.styleFrom(
                backgroundColor: SpaceTheme.nebulaPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(
                l10n.astrologySelectDateBtn,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAstrologyState(AppLocalizations l10n) {
    final langCode = Localizations.localeOf(context).languageCode;
    final sign = AstrologyService.getSign(_birthDate!);
    final signName = AstrologyService.getSignName(sign, langCode);
    final signEmoji = AstrologyService.getSignEmoji(sign);

    final monthly = AstrologyService.getMonthlyPrediction(sign, langCode);
    final yearly = AstrologyService.getYearlyPrediction(sign, langCode);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SpaceTheme.nebulaPurple.withValues(alpha: 0.2),
              border: Border.all(color: SpaceTheme.nebulaPurple.withValues(alpha: 0.5), width: 2),
            ),
            child: Text(signEmoji, style: const TextStyle(fontSize: 64)),
          ),
          const SizedBox(height: 16),
          Text(
            signName,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: SpaceTheme.stellarGold,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_birthDate!.day}.${_birthDate!.month}.${_birthDate!.year}',
            style: const TextStyle(color: Colors.white54, fontSize: 16),
          ),
          const SizedBox(height: 40),
          
          // AI Predicition Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: SpaceTheme.glassCard.copyWith(
              border: Border.all(color: SpaceTheme.stellarGold.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Icon(Icons.auto_awesome, color: SpaceTheme.stellarGold, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Astroloji AI',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Yapay zeka asistanımız çok yakında sizlerle! ✨',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          _PredictionCard(
            title: l10n.astrologyMonthly,
            content: monthly,
            icon: Icons.calendar_month,
            color: Colors.blueAccent,
          ),
          const SizedBox(height: 16),
          _PredictionCard(
            title: l10n.astrologyYearly,
            content: yearly,
            icon: Icons.auto_graph,
            color: Colors.orangeAccent,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _PredictionCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color color;

  const _PredictionCard({
    required this.title,
    required this.content,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: SpaceTheme.glassCard.copyWith(
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.6,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
