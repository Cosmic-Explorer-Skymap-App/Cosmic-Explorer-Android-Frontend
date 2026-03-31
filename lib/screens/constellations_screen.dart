import 'package:flutter/material.dart';
import '../theme/space_theme.dart';
import '../data/constellations_data.dart';
import 'constellation_detail_screen.dart';
import '../data/constellations_l10n.dart';
import 'package:cosmic_explorer/l10n/generated/app_localizations.dart';

class ConstellationsScreen extends StatelessWidget {
  const ConstellationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final localizedList = getLocalizedConstellations(lang, constellationsData);

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
                      l10n.constellationsScreenTitle,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.constellationsScreenSubtitle,
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
                    final c = localizedList[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ConstellationDetailScreen(constellation: c),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: SpaceTheme.glassCard,
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: SpaceTheme.gradientCard(c.colors),
                                child: Center(
                                  child: Text(
                                    c.emoji,
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
                                      c.name,
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${c.latinName} • ${c.bestSeason}',
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
                      ),
                    );
                  },
                  childCount: constellationsData.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

