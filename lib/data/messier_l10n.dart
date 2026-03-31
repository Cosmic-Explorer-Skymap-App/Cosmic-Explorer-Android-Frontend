import '../models/messier_object.dart';

List<MessierObject> getLocalizedMessier(String lang, List<MessierObject> baseList) {
  return baseList.map((m) {
    return m.copyWith(
      name: _localizeMessierName(lang, m.id, m.name),
      type: _localizeMessierType(lang, m.type),
    );
  }).toList();
}

String _localizeMessierName(String lang, String id, String trName) {
  if (lang == 'tr') return trName;
  // Many names are identical or have standard English equivalents.
  // For simplicity, we'll map a few common ones. 
  final names = {
    'M1': {'en': 'Crab Nebula', 'de': 'Krebsnebel', 'es': 'Nebulosa del Cangrejo'},
    'M8': {'en': 'Lagoon Nebula', 'de': 'Lagunennebel', 'es': 'Nebulosa de la Laguna'},
    'M13': {'en': 'Hercules Cluster', 'de': 'Herkuleshaufen', 'es': 'Cúmulo de Hércules'},
    'M16': {'en': 'Eagle Nebula', 'de': 'Adlernebel', 'es': 'Nebulosa del Águila'},
    'M31': {'en': 'Andromeda Galaxy', 'de': 'Andromedagalaxie', 'es': 'Galaxia de Andrómeda'},
    'M42': {'en': 'Orion Nebula', 'de': 'Orionnebel', 'es': 'Nebulosa de Orión'},
    'M45': {'en': 'Pleiades', 'de': 'Plejaden', 'es': 'Pléyades'},
    'M51': {'en': 'Whirlpool Galaxy', 'de': 'Whirlpool-Galaxie', 'es': 'Galaxia del Remolino'},
    'M57': {'en': 'Ring Nebula', 'de': 'Ringnebel', 'es': 'Nebulosa del Anillo'},
  };
  return names[id]?[lang] ?? trName;
}

String _localizeMessierType(String lang, String type) {
  if (lang == 'tr') return type;
  final types = {
    'Supernova remnant': {'tr': 'Süpernova Kalıntısı', 'en': 'Supernova Remnant', 'de': 'Supernova-Überrest', 'es': 'Remanente de Supernova'},
    'Globular cluster': {'tr': 'Küresel Küme', 'en': 'Globular Cluster', 'de': 'Kugelsternhaufen', 'es': 'Cúmulo Globular'},
    'Open cluster': {'tr': 'Açık Küme', 'en': 'Open Cluster', 'de': 'Offener Sternhaufen', 'es': 'Cúmulo Abierto'},
    'Spiral galaxy': {'tr': 'Sarmal Galaksi', 'en': 'Spiral Galaxy', 'de': 'Spiralgalaxie', 'es': 'Galaxia Espiral'},
    'Nebula': {'tr': 'Bulutsu', 'en': 'Nebula', 'de': 'Nebel', 'es': 'Nebulosa'},
    'Planetary nebula': {'tr': 'Gezegenimsi Bulutsu', 'en': 'Planetary Nebula', 'de': 'Planetarischer Nebel', 'es': 'Nebulosa Planetaria'},
    'Elliptical galaxy': {'tr': 'Eliptik Galaksi', 'en': 'Elliptical Galaxy', 'de': 'Elliptische Galaxie', 'es': 'Galaxia Elíptica'},
  };
  
  // Try to find the TR type in our map and return the localized version
  for (var entry in types.values) {
    if (entry['tr'] == type || entry['en'] == type) {
      return entry[lang] ?? type;
    }
  }
  return type;
}
