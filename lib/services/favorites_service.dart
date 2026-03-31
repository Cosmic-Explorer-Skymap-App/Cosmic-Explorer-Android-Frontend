import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _planetsKey = 'fav_planets';
  static const String _constellationsKey = 'fav_constellations';

  static Future<List<String>> getFavoritePlanets() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_planetsKey) ?? [];
  }

  static Future<List<String>> getFavoriteConstellations() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_constellationsKey) ?? [];
  }

  static Future<void> togglePlanet(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_planetsKey) ?? [];
    if (list.contains(id)) {
      list.remove(id);
    } else {
      list.add(id);
    }
    await prefs.setStringList(_planetsKey, list);
  }

  static Future<void> toggleConstellation(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_constellationsKey) ?? [];
    if (list.contains(id)) {
      list.remove(id);
    } else {
      list.add(id);
    }
    await prefs.setStringList(_constellationsKey, list);
  }

  static Future<bool> isPlanetFav(String id) async {
    final list = await getFavoritePlanets();
    return list.contains(id);
  }

  static Future<bool> isConstellationFav(String id) async {
    final list = await getFavoriteConstellations();
    return list.contains(id);
  }
}
