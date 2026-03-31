import 'package:flutter/material.dart';
import '../theme/space_theme.dart';
import '../models/planet.dart';
import '../services/favorites_service.dart';
import 'package:cosmic_explorer/l10n/generated/app_localizations.dart';

class PlanetDetailScreen extends StatefulWidget {
  final Planet planet;

  const PlanetDetailScreen({super.key, required this.planet});

  @override
  State<PlanetDetailScreen> createState() => _PlanetDetailScreenState();
}

class _PlanetDetailScreenState extends State<PlanetDetailScreen> {
  bool _isFav = false;

  @override
  void initState() {
    super.initState();
    _loadFav();
  }

  Future<void> _loadFav() async {
    final fav = await FavoritesService.isPlanetFav(widget.planet.id);
    if (mounted) setState(() => _isFav = fav);
  }

  Future<void> _toggleFav() async {
    await FavoritesService.togglePlanet(widget.planet.id);
    if (mounted) setState(() => _isFav = !_isFav);
  }
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = widget.planet;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: SpaceTheme.gradientBackground,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top bar
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(
                              _isFav ? Icons.favorite : Icons.favorite_border,
                              color: _isFav ? SpaceTheme.marsRed : null,
                            ),
                            onPressed: _toggleFav,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Hero card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: SpaceTheme.gradientCard(p.colors),
                        child: Column(
                          children: [
                            Text(p.iconEmoji, style: const TextStyle(fontSize: 64)),
                            const SizedBox(height: 12),
                            Text(
                              p.name,
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              p.subtitle,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white70,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Stats
                      Row(
                        children: [
                          _StatChip(label: l10n.planetStatDistance, value: p.getDistanceDisplay(l10n.unitAU, l10n.unitMkm)),
                          const SizedBox(width: 8),
                          _StatChip(label: l10n.planetStatRadius, value: p.getRadiusDisplay(l10n.unitKm)),
                          const SizedBox(width: 8),
                          _StatChip(label: l10n.planetStatMoons, value: '${p.moons}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _StatChip(label: l10n.planetStatOrbitalPeriod, value: p.getOrbitalPeriodDisplay(l10n.unitDay, l10n.unitYear)),
                          const SizedBox(width: 8),
                          _StatChip(label: l10n.planetStatGravity, value: '${p.gravity} m/s²'),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Story
                      Text(
                        l10n.planetStoryHeader,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      ...p.story.split('\n\n').map(
                            (paragraph) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                paragraph.trim(),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ),
                      const SizedBox(height: 16),


                      // Fun fact
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: SpaceTheme.glassCard.copyWith(
                          border: Border.all(
                            color: SpaceTheme.stellarGold.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('💡', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                p.funFact,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: SpaceTheme.stellarGold,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: SpaceTheme.glassCard,
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: SpaceTheme.nebulaPurple,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


