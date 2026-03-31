import 'package:flutter/material.dart';
import '../theme/space_theme.dart';
import '../data/planets_data.dart';
import 'planet_detail_screen.dart';
import 'package:cosmic_explorer/l10n/generated/app_localizations.dart';

class PlanetsScreen extends StatelessWidget {
  const PlanetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final planets = getPlanetsData(Localizations.localeOf(context).languageCode);
    
    return Container(
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
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.planetsScreenTitle,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.planetsScreenSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final planet = planets[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PlanetCard(planet: planet),
                    );
                  },
                  childCount: planets.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanetCard extends StatelessWidget {
  final dynamic planet;

  const _PlanetCard({required this.planet});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PlanetDetailScreen(planet: planet),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: SpaceTheme.glassCard,
        child: Row(
          children: [
            // Planet avatar with gradient
            Container(
              width: 56,
              height: 56,
              decoration: SpaceTheme.gradientCard(planet.colors),
              child: Center(
                child: Text(
                  planet.iconEmoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    planet.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    planet.subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: SpaceTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}


