import 'package:flutter/material.dart';
import '../theme/space_theme.dart';
import '../models/constellation.dart';
import '../services/favorites_service.dart';
import 'package:cosmic_explorer/l10n/generated/app_localizations.dart';

class ConstellationDetailScreen extends StatefulWidget {
  final Constellation constellation;

  const ConstellationDetailScreen({super.key, required this.constellation});

  @override
  State<ConstellationDetailScreen> createState() =>
      _ConstellationDetailScreenState();
}

class _ConstellationDetailScreenState extends State<ConstellationDetailScreen> {
  bool _isFav = false;

  @override
  void initState() {
    super.initState();
    _loadFav();
  }

  Future<void> _loadFav() async {
    final fav =
        await FavoritesService.isConstellationFav(widget.constellation.id);
    if (mounted) setState(() => _isFav = fav);
  }

  Future<void> _toggleFav() async {
    await FavoritesService.toggleConstellation(widget.constellation.id);
    if (mounted) setState(() => _isFav = !_isFav);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = widget.constellation;
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

                      // Hero
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: SpaceTheme.gradientCard(c.colors),
                        child: Column(
                          children: [
                            Text(c.emoji, style: const TextStyle(fontSize: 64)),
                            const SizedBox(height: 12),
                            Text(
                              c.name,
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${c.latinName} • ${l10n.constellationBestSeasonPrefix}: ${c.bestSeason}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Stars info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: SpaceTheme.glassCard,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${l10n.constellationStarsHeader} (${c.stars.length})',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            ...c.stars.map(
                              (s) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 14,
                                      color: s.magnitude < 1.5
                                          ? SpaceTheme.stellarGold
                                          : SpaceTheme.textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      s.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge,
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${l10n.starMagnitudeLabel}: ${s.magnitude.toStringAsFixed(1)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Story section
                      Text(
                        l10n.constellationStoryHeader,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      ...c.story.split('\n\n').map(
                            (p) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                p.trim(),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ),
                      const SizedBox(height: 16),

                      // Mythology section
                      Text(
                        l10n.constellationMythologyHeader,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      ...c.mythology.split('\n\n').map(
                            (p) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 16),
                              child: Text(
                                p.trim(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge,
                              ),
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

