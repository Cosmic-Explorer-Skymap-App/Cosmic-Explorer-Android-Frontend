import '../models/constellation.dart';

List<Constellation> getLocalizedConstellations(String lang, List<Constellation> baseList) {
  return baseList.map((c) {
    return c.copyWith(
      name: _getConstName(lang, c.id, c.name),
      bestSeason: _translateSeason(lang, c.bestSeason),
      story: _getConstStory(lang, c.id, c.story),
      mythology: _getConstMyth(lang, c.id, c.mythology),
    );
  }).toList();
}

String _translateSeason(String lang, String season) {
  if (lang == 'tr') return season;
  final seasons = {
    'Bahar': {'en': 'Spring', 'de': 'Frühling', 'es': 'Primavera'},
    'Yaz': {'en': 'Summer', 'de': 'Sommer', 'es': 'Verano'},
    'Sonbahar': {'en': 'Autumn', 'de': 'Herbst', 'es': 'Otoño'},
    'Kış': {'en': 'Winter', 'de': 'Winter', 'es': 'Invierno'},
    'İlkbahar': {'en': 'Spring', 'de': 'Frühling', 'es': 'Primavera'},
  };
  return seasons[season]?[lang] ?? season;
}

String _getConstName(String lang, String id, String defaultName) {
  if (lang == 'tr') return defaultName;
  final names = {
    'andromeda': {'en': 'Andromeda', 'de': 'Andromeda', 'es': 'Andrómeda'},
    'antlia': {'en': 'Air Pump', 'de': 'Luftpumpe', 'es': 'Máquina Neumática'},
    'apus': {'en': 'Bird of Paradise', 'de': 'Paradiesvogel', 'es': 'Ave del Paraíso'},
    'aquarius': {'en': 'Water Bearer', 'de': 'Wassermann', 'es': 'Acuario'},
    'aquila': {'en': 'Eagle', 'de': 'Adler', 'es': 'Águila'},
    'ara': {'en': 'Altar', 'de': 'Altar', 'es': 'Altar'},
    'aries': {'en': 'Ram', 'de': 'Widder', 'es': 'Aries'},
    'auriga': {'en': 'Charioteer', 'de': 'Fuhrmann', 'es': 'Cochero'},
    'bootes': {'en': 'Herdsman', 'de': 'Bärenhüter', 'es': 'Boyero'},
    'caelum': {'en': 'Chisel', 'de': 'Grabstichel', 'es': 'Cincel'},
    'camelopardalis': {'en': 'Giraffe', 'de': 'Giraffe', 'es': 'Jirafa'},
    'cancer': {'en': 'Crab', 'de': 'Krebs', 'es': 'Cáncer'},
    'canes_venatici': {'en': 'Hunting Dogs', 'de': 'Jagdhunde', 'es': 'Lebreles'},
    'canis_major': {'en': 'Greater Dog', 'de': 'Großer Hund', 'es': 'Can Mayor'},
    'canis_minor': {'en': 'Lesser Dog', 'de': 'Kleiner Hund', 'es': 'Can Menor'},
    'capricornus': {'en': 'Sea Goat', 'de': 'Steinbock', 'es': 'Capricornio'},
    'carina': {'en': 'Keel', 'de': 'Kiel des Schiffes', 'es': 'Quilla'},
    'cassiopeia': {'en': 'Cassiopeia', 'de': 'Kassiopeia', 'es': 'Casiopea'},
    'centaurus': {'en': 'Centaur', 'de': 'Zentaur', 'es': 'Centauro'},
    'cepheus': {'en': 'Cepheus', 'de': 'Kepheus', 'es': 'Cefeo'},
    'cetus': {'en': 'Whale', 'de': 'Walfisch', 'es': 'Cetus'},
    'columba': {'en': 'Dove', 'de': 'Taube', 'es': 'Paloma'},
    // Fallback for others - use Latin name for non-TR if not found
  };
  return names[id]?[lang] ?? defaultName;
}

String _getConstStory(String lang, String id, String trStory) {
  if (lang == 'tr') return trStory;
  // Detailed stories only for a few key ones to save space, others get a generic or English placeholder
  if (id == 'andromeda' && lang == 'en') return "Andromeda is the daughter of the Ethiopian King Cepheus and Queen Cassiopeia. When her mother bragged about being more beautiful than sea nymphs, Poseidon sent a sea monster. Andromeda was saved by Perseus.";
  // For others, just return TR story or empty for now if overwhelming
  return trStory; 
}

String _getConstMyth(String lang, String id, String trMyth) {
  if (lang == 'tr') return trMyth;
  return trMyth;
}
