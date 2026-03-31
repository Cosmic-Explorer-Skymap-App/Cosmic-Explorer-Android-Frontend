import 'package:flutter/material.dart';
import '../theme/space_theme.dart';
import '../services/favorites_service.dart';
import '../data/planets_data.dart';
import '../data/constellations_data.dart';
import 'planet_detail_screen.dart';
import 'constellation_detail_screen.dart';

import 'package:cosmic_explorer/l10n/generated/app_localizations.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<String> _favPlanets = [];
  List<String> _favConstellations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    _favPlanets = await FavoritesService.getFavoritePlanets();
    _favConstellations = await FavoritesService.getFavoriteConstellations();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final localizedPlanets = getPlanetsData(lang);
    final localizedConsts = constellationsData; // Constellations are not yet fully localized in data files, we use IDs for lookup

    final hasFavs = _favPlanets.isNotEmpty || _favConstellations.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: SpaceTheme.gradientBackground,
        ),
      ),
      child: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : !hasFavs
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('💫', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        Text(
                          l10n.favNoFavoritesTitle,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.favNoFavoritesSubtitle,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.favScreenTitle,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 16),

                        if (_favPlanets.isNotEmpty) ...[
                          Text(
                            l10n.planetsScreenTitle.replaceAll('🪐 ', ''),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          ..._favPlanets.map((id) {
                            final planet = localizedPlanets
                                .where((p) => p.id == id)
                                .firstOrNull;
                            if (planet == null) return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          PlanetDetailScreen(planet: planet),
                                    ),
                                  );
                                  _load();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: SpaceTheme.glassCard,
                                  child: Row(
                                    children: [
                                      Text(planet.iconEmoji,
                                          style: const TextStyle(fontSize: 24)),
                                      const SizedBox(width: 12),
                                      Text(
                                        planet.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 16),
                        ],

                        if (_favConstellations.isNotEmpty) ...[
                          Text(
                            l10n.constellationsScreenTitle.replaceAll('✨ ', ''),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          ..._favConstellations.map((id) {
                            final c = localizedConsts
                                .where((c) => c.id == id)
                                .firstOrNull;
                            if (c == null) return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ConstellationDetailScreen(
                                              constellation: c),
                                    ),
                                  );
                                  _load();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: SpaceTheme.glassCard,
                                  child: Row(
                                    children: [
                                      Text(c.emoji,
                                          style: const TextStyle(fontSize: 24)),
                                      const SizedBox(width: 12),
                                      Text(
                                        c.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
      ),
    );
  }
}


