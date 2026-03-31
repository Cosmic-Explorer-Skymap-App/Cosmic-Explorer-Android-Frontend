import 'package:flutter/material.dart';
import 'package:cosmic_explorer/l10n/generated/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../theme/space_theme.dart';
import '../services/ad_service.dart';
import 'sky_map_screen.dart';
import 'planets_screen.dart';
import 'constellations_screen.dart';
import 'quiz_screen.dart';
import 'favorites_screen.dart';
import 'messier_screen.dart';
import 'astrology_screen.dart';
import 'gallery_screen.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import '../services/iss_service.dart';
import '../services/calendar_service.dart'; // Added
import '../services/notification_service.dart'; // Added
import 'dart:async'; // Added for Timer

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  int _currentIndex = 0;
  late final AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  BannerAd? _bannerAd;
  UserStatus? _userStatus; // Added

  List<Widget> get _screens => [
    _HomeBody(status: _userStatus), // Added status
    const PlanetsScreen(),
    const ConstellationsScreen(),
    const QuizScreen(),
    const FavoritesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
    _loadBannerAd();
    _loadUserStatus(); // Added
    WidgetsBinding.instance.addObserver(this); // Added
    Timer(const Duration(seconds: 4), () => NotificationService.showNotification(
      title: "🌠 Yaklaşan Gök Olayı",
      body: "Lunar Eclipse (Ay Tutulması) 3 Mart'ta gerçekleşecek!",
    ));
  }

  Future<void> _loadUserStatus() async {
    final status = await AuthService.getUserStatus();
    if (mounted) {
      setState(() {
        _userStatus = status;
      });
    }
  }

  Future<void> _loadBannerAd() async {
    // If ad is already loaded, don't reload unless necessary
    if (_bannerAd != null) return;
    
    final ad = await AdService.createBannerAd();
    if (ad != null) {
      setState(() {
        _bannerAd = ad;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadUserStatus().then((_) => _loadBannerAd());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Added
    _fadeController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _onTabChange(int index) {
    if (index == _currentIndex) return;
    _fadeController.reverse().then((_) {
      setState(() => _currentIndex = index);
      _fadeController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context), // Added Drawer
      body: FadeTransition(
        opacity: _fadeAnim,
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_bannerAd != null)
            Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              color: Colors.black,
              child: AdWidget(ad: _bannerAd!),
            ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: SpaceTheme.dividerColor, width: 0.5),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onTabChange,
              items: [
                BottomNavigationBarItem(icon: const Icon(Icons.home_rounded), label: AppLocalizations.of(context)!.homeTabTitle),
                BottomNavigationBarItem(icon: const Icon(Icons.public_rounded), label: AppLocalizations.of(context)!.planetsTabTitle),
                BottomNavigationBarItem(icon: const Icon(Icons.auto_awesome), label: AppLocalizations.of(context)!.constellationsTabTitle),
                BottomNavigationBarItem(icon: const Icon(Icons.quiz_rounded), label: AppLocalizations.of(context)!.quizTabTitle),
                BottomNavigationBarItem(icon: const Icon(Icons.favorite_rounded), label: AppLocalizations.of(context)!.favoritesTabTitle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
              ),
            ),
            child: Center(
              child: Text(
                "Cosmic Explorer",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
              ),
            ),
          ),
          // Premium Üyelik removed as per user request
          const Divider(color: Colors.white24),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text("Çıkış Yap"),
            onTap: () async {
               await AuthService.signOut();
               if (context.mounted) {
                 Navigator.pushAndRemoveUntil(
                   context,
                   MaterialPageRoute(builder: (_) => const LoginScreen()),
                   (route) => false,
                 );
               }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Home body with hero header and feature cards.
class _HomeBody extends StatelessWidget {
  final UserStatus? status;

  const _HomeBody({this.status});

  // _buildTrialBanner removed as per user request

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: SpaceTheme.gradientBackground,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.homeHeaderTitle,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.homeHeaderSubtitle,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu_rounded, size: 32, color: Colors.white),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const _IssCard(),
              const _CalendarCard(),

              // Sky Map CTA
              _FeatureCard(
                title: l10n.skyMapFeatureTitle,
                subtitle: l10n.skyMapFeatureSubtitle,
                emoji: '🔭',
                gradient: const [Color(0xFF6C63FF), Color(0xFF3D5AFE)],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SkyMapScreen()),
                ),
              ),
              const SizedBox(height: 16),

              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      title: l10n.planetsTabTitle,
                      emoji: '🪐',
                      color: SpaceTheme.nebulaOrange,
                      onTap: () {
                        final homeState = context.findAncestorStateOfType<_HomeScreenState>();
                        homeState?._onTabChange(1);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      title: l10n.constellationsTabTitle,
                      emoji: '⭐',
                      color: SpaceTheme.stellarGold,
                      onTap: () {
                        final homeState = context.findAncestorStateOfType<_HomeScreenState>();
                        homeState?._onTabChange(2);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
              child: _QuickActionCard(
                title: l10n.quizQuickActionTitle,
                emoji: '🧠',
                color: SpaceTheme.marsRed,
                onTap: () {
                  final homeState = context.findAncestorStateOfType<_HomeScreenState>();
                  homeState?._onTabChange(3);
                },
              ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
              child: _QuickActionCard(
                title: l10n.deepSpaceQuickActionTitle,
                emoji: '🌌',
                color: const Color(0xFF00E5FF),
                onTap: () {
                   Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const MessierScreen(),
                          ),
                        );
                },
                  ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      title: l10n.astrologyTabTitle,
                      emoji: '🔮',
                      color: Colors.purpleAccent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AstrologyScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      title: 'Astro Galeri',
                      emoji: '📸',
                      color: Colors.tealAccent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GalleryScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Daily Fact
              _DailyFactCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.startBtn,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            Text(emoji, style: const TextStyle(fontSize: 48)),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String emoji;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.emoji,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: SpaceTheme.glassCard.copyWith(
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}

class _DailyFactCard extends StatelessWidget {
  static const Map<String, List<String>> _factsMap = {
    'tr': [
      'Güneş her saniye 4.6 milyon ton kütle kaybeder — ama bu, toplam kütlesinin sadece milyarda biridir.',
      'Bir çay kaşığı nötron yıldızı maddesi yaklaşık 6 milyar ton ağırlığındadır.',
      'Uzay tamamen sessizdir — ses dalgaları boşlukta yayılamaz.',
      'Evrende gözlemlenebilir yıldız sayısı, Dünya\'daki tüm kumsallarındaki kum tanelerinden fazladır.',
      'Işık Güneş\'ten Dünya\'ya 8 dakika 20 saniyede ulaşır.',
      'Ay her yıl Dünya\'dan 3.8 cm uzaklaşmaktadır.',
      'Bir elmas gezegen keşfedildi — 55 Cancri e, kütlesinin üçte biri saf elmastır.',
      'Voyager 1, Dünya\'dan en uzaktaki insan yapımı nesnedir — 24 milyar km\'den fazla.',
      'Samanyolu ve Andromeda galaksileri yaklaşık 4.5 milyar yıl sonra çarpışacak.',
      'Evrendeki fotonların çoğu yıldızlardan değil, kozmik mikrodalga arka plan ışımasından gelir.',
    ],
    'en': [
      'The Sun loses 4.6 million tons of mass every second — but this is only one billionth of its total mass.',
      'A teaspoon of neutron star matter weighs about 6 billion tons.',
      'Space is completely silent — sound waves cannot propagate in a vacuum.',
      'The number of observable stars in the universe is greater than all the grains of sand on all the beaches on Earth.',
      'Light from the Sun takes 8 minutes and 20 seconds to reach Earth.',
      'The Moon is moving away from Earth by 3.8 cm every year.',
      'A diamond planet has been discovered — one third of the mass of 55 Cancri e is pure diamond.',
      'Voyager 1 is the farthest man-made object from Earth — over 24 billion km.',
      'The Milky Way and Andromeda galaxies will collide in about 4.5 billion years.',
      'Most photons in the universe come from the cosmic microwave background, not from stars.',
    ],
    'de': [
      'Die Sonne verliert jede Sekunde 4,6 Millionen Tonnen an Masse — aber das ist nur ein Milliardstel ihrer Gesamtmasse.',
      'Ein Teelöffel Materie eines Neutronensterns wiegt etwa 6 Milliarden Tonnen.',
      'Im Weltraum herrscht völlige Stille — Schallwellen können sich im Vakuum nicht ausbreiten.',
      'Die Anzahl der beobachtbaren Sterne im Universum ist größer als alle Sandkörner an allen Stränden der Erde.',
      'Das Licht der Sonne braucht 8 Minuten und 20 Sekunden, um die Erde zu erreichen.',
      'Der Mond entfernt sich jedes Jahr um 3,8 cm von der Erde.',
      'Ein Diamantplanet wurde entdeckt — ein Drittel der Masse von 55 Cancri e besteht aus reinem Diamant.',
      'Voyager 1 ist das am weitesten von der Erde entfernte von Menschenhand geschaffene Objekt — über 24 Milliarden km.',
      'Die Milchstraße und die Andromeda-Galaxie werden in etwa 4,5 Milliarden Jahren zusammenstoßen.',
      'Die meisten Photonen im Universum stammen aus der kosmischen Mikrowellenhintergrundstrahlung, nicht von Sternen.',
    ],
    'es': [
      'El Sol pierde 4,6 millones de toneladas de masa cada segundo, pero esto es solo una milmillonésima parte de su masa total.',
      'Una cucharadita de materia de estrella de neutrones pesa unos 6 mil millones de toneladas.',
      'El espacio es completamente silencioso: las ondas sonoras no pueden propagarse en el vacío.',
      'El número de estrellas observables en el universo es mayor que todos los granos de arena de todas las playas de la Tierra.',
      'La luz del Sol tarda 8 minutos y 20 segundos en llegar a la Tierra.',
      'La Luna se aleja de la Tierra 3,8 cm cada año.',
      'Se ha descubierto un planeta de diamantes: un tercio de la masa de 55 Cancri e es diamante puro.',
      'La Voyager 1 es el objeto creado por el ser humano más alejado de la Tierra: más de 24 mil millones de km.',
      'La Vía Láctea y la galaxia de Andrómeda colisionarán en unos 4.500 millones de años.',
      'La mayoría de los fotones en el universo provienen de la radiación de fondo de microondas, no de las estrellas.',
    ],
  };

  const _DailyFactCard();

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final factsList = _factsMap[lang] ?? _factsMap['en']!;
    final dayIndex = DateTime.now().day % factsList.length;
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: SpaceTheme.glassCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                l10n.dailyFactTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: SpaceTheme.stellarGold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            factsList[dayIndex],
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

// _ApodCard class removed as per user request

class _IssCard extends StatefulWidget {
  const _IssCard();

  @override
  State<_IssCard> createState() => _IssCardState();
}

class _IssCardState extends State<_IssCard> {
  Map<String, dynamic>? _iss;
  bool _loading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetch();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _fetch());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetch() async {
    final data = await IssService.getCurrentLocation();
    if (mounted && data != null) {
      setState(() {
        _iss = data;
        _loading = false;
      });
    }
  }

  static const Map<String, Map<String, String>> _issL10n = {
    'tr': {'title': 'ISS Şu An Nerede?', 'lat': 'Enlem', 'lon': 'Boylam', 'vel': 'Hız', 'alt': 'Yükseklik'},
    'en': {'title': 'Where is ISS Now?', 'lat': 'Latitude', 'lon': 'Longitude', 'vel': 'Velocity', 'alt': 'Altitude'},
  };

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox.shrink();
    if (_iss == null) return const SizedBox.shrink();

    final lang = Localizations.localeOf(context).languageCode;
    final l10n = _issL10n[lang] ?? _issL10n['en']!;

    final lat = _iss!['latitude']?.toStringAsFixed(4) ?? '';
    final lon = _iss!['longitude']?.toStringAsFixed(4) ?? '';
    final vel = _iss!['velocity']?.toStringAsFixed(0) ?? '0';
    final alt = _iss!['altitude']?.toStringAsFixed(1) ?? '0';

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: SpaceTheme.glassCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🛰️', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                l10n['title']!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: SpaceTheme.stellarGold, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat(l10n['lat']!, lat),
              _buildStat(l10n['lon']!, lon),
            ],
          ),
          const Divider(color: Colors.white12, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat(l10n['vel']!, "$vel km/s"),
              _buildStat(l10n['alt']!, "$alt km"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard();

  static const Map<String, Map<String, String>> _calendarL10n = {
    'tr': {'title': 'Yaklaşan Gök Olayı', 'date': 'Tarih'},
    'en': {'title': 'Upcoming Cosmic Event', 'date': 'Date'},
  };

  @override
  Widget build(BuildContext context) {
    final events = CalendarService.getUpcomingEvents();
    if (events.isEmpty) return const SizedBox.shrink();

    final nextEvent = events.first;
    final lang = Localizations.localeOf(context).languageCode;
    final l10n = _calendarL10n[lang] ?? _calendarL10n['en']!;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: SpaceTheme.glassCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(nextEvent.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                l10n['title']!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: SpaceTheme.stellarGold, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(nextEvent.title[lang] ?? nextEvent.title['en']!, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            "${l10n['date']!}: ${nextEvent.date}",
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            nextEvent.description[lang] ?? nextEvent.description['en']!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

