import 'star.dart';

class Constellation {
  final String id;
  final String name;
  final String latinName;
  final String story;
  final String mythology;
  final String bestSeason;
  final String emoji;
  final List<Star> stars;
  final List<List<int>> lines; 
  final List<int> colors; 

  const Constellation({
    required this.id,
    required this.name,
    required this.latinName,
    required this.story,
    required this.mythology,
    required this.bestSeason,
    required this.emoji,
    required this.stars,
    required this.lines,
    required this.colors,
  });

  Constellation copyWith({
    String? name,
    String? story,
    String? mythology,
    String? bestSeason,
  }) {
    return Constellation(
      id: id,
      name: name ?? this.name,
      latinName: latinName,
      story: story ?? this.story,
      mythology: mythology ?? this.mythology,
      bestSeason: bestSeason ?? this.bestSeason,
      emoji: emoji,
      stars: stars,
      lines: lines,
      colors: colors,
    );
  }
}
