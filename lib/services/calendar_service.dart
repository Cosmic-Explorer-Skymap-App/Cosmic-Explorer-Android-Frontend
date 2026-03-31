class SpaceEvent {
  final Map<String, String> title;
  final String date; // '2026-08-12'
  final Map<String, String> description;
  final String emoji;

  SpaceEvent({
    required this.title,
    required this.date,
    required this.description,
    this.emoji = '🌟',
  });
}

class CalendarService {
  static final List<SpaceEvent> _events = [
    SpaceEvent(
      title: {
        'tr': "Perseid Meteor Yağmuru",
        'en': "Perseids Meteor Shower",
      },
      date: "2026-08-12",
      description: {
        'tr': "Yılın en görkemli meteor yağmurlarından biri. Saatte 100'e yakın meteor gözlenebilir.",
        'en': "One of the most spectacular meteor showers of the year. Up to 100 meteors per hour.",
      },
      emoji: "🌠",
    ),
    SpaceEvent(
      title: {
        'tr': "Halkalı Güneş Tutulması",
        'en': "Annular Solar Eclipse",
      },
      date: "2026-02-17",
      description: {
        'tr': "Ay'ın Güneş önünden geçerek ateş çemberi oluşturduğu nadir gök olayı.",
        'en': "A rare celestial event where the Moon passes in front of the Sun creating a ring of fire.",
      },
      emoji: "☀️",
    ),
    SpaceEvent(
      title: {
        'tr': "Geminid Meteor Yağmuru",
        'en': "Geminids Meteor Shower",
      },
      date: "2026-12-14",
      description: {
        'tr': "Kış aylarının en aktif göktaşı yağmuru. Zengin ve parlak meteorlar.",
        'en': "The most active meteor shower of winter months. Rich and bright meteors.",
      },
      emoji: "☄️",
    ),
    SpaceEvent(
      title: {
        'tr': "Yaz Gündönümü (Solstice)",
        'en': "Summer Solstice",
      },
      date: "2026-06-21",
      description: {
        'tr': "Kuzey yarımkürede en uzun gündüz, yaz mevsiminin resmi başlangıcı.",
        'en': "Longest day in the northern hemisphere, the official beginning of summer.",
      },
      emoji: "☀️",
    ),
    SpaceEvent(
      title: {
        'tr': "Lunar Eclipse (Ay Tutulması)",
        'en': "Lunar Eclipse",
      },
      date: "2026-03-03",
      description: {
        'tr': "Dünya'nın gölgesinin Ay'ın üzerine düşerek kızıl renk almasını sağlayan olay.",
        'en': "The event that allows the Moon to take a reddish color as Earth's shadow falls on it.",
      },
      emoji: "🌑",
    ),
  ];

  static List<SpaceEvent> getUpcomingEvents() {
    final now = DateTime.now();
    return _events.where((e) {
      final eventDate = DateTime.parse(e.date);
      return eventDate.isAfter(now);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }
}
