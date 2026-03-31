import '../models/quiz_question.dart';

List<QuizQuestion> getLocalizedQuiz(String lang, List<QuizQuestion> baseList) {
  if (lang == 'tr') return baseList;
  
  return baseList.map((q) {
    final localized = _getLocalizedQData(lang, q.id);
    if (localized != null) {
      return q.copyWith(
        question: localized['question'],
        options: localized['options'],
        explanation: localized['explanation'],
      );
    }
    return q; // Fallback to TR for now if not localized
  }).toList();
}

Map<String, dynamic>? _getLocalizedQData(String lang, String id) {
  final data = {
    'q1': {
      'en': {
        'question': 'Which is the largest planet in the Solar System?',
        'options': ['Saturn', 'Jupiter', 'Uranus', 'Neptune'],
        'explanation': 'Jupiter is the largest planet in the Solar System. More than 1,300 Earths could fit inside it!',
      },
      'de': {
        'question': 'Welcher ist der größte Planet im Sonnensystem?',
        'options': ['Saturn', 'Jupiter', 'Uranus', 'Neptun'],
        'explanation': 'Jupiter ist der größte Planet im Sonnensystem. Mehr als 1.300 Erden könnten hineinpassen!',
      },
      'es': {
        'question': '¿Cuál es el planeta más grande del Sistema Solar?',
        'options': ['Saturno', 'Júpiter', 'Urano', 'Neptuno'],
        'explanation': 'Júpiter es el planeta más grande del Sistema Solar. ¡Más de 1.300 Tierras podrían caber en su interior!',
      }
    },
    'q2': {
      'en': {
        'question': 'Which is the brightest star in the night sky?',
        'options': ['Vega', 'Arcturus', 'Sirius', 'Canopus'],
        'explanation': 'Sirius (in the constellation Canis Major) is the brightest star in the night sky with a magnitude of -1.46.',
      },
      'de': {
        'question': 'Welcher ist der hellste Stern am Nachthimmel?',
        'options': ['Wega', 'Arktur', 'Sirius', 'Canopus'],
        'explanation': 'Sirius (im Sternbild Großer Hund) ist mit einer Helligkeit von -1,46 der hellste Stern am Nachthimmel.',
      },
      'es': {
        'question': '¿Cuál es la estrella más brillante del cielo nocturno?',
        'options': ['Vega', 'Arcturus', 'Sirio', 'Canopus'],
        'explanation': 'Sirio (en la constelación de Canis Major) es la estrella más brillante del cielo nocturno con una magnitud de -1,46.',
      }
    },
    'q3': {
      'en': {
        'question': 'About how many days does it take for the Moon to complete one orbit around the Earth?',
        'options': ['14 days', '27.3 days', '30 days', '365 days'],
        'explanation': 'The Moon\'s orbital period is about 27.3 days (sidereal month).',
      },
      'es': {
        'question': '¿Aproximadamente cuántos días le toma a la Luna completar una órbita alrededor de la Tierra?',
        'options': ['14 días', '27.3 días', '30 días', '365 días'],
        'explanation': 'El período orbital de la Luna es de unos 27,3 días (mes sidéreo).',
      }
    }
  };
  
  return data[id]?[lang];
}
