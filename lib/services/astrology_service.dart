
enum ZodiacSign {
  aries,
  taurus,
  gemini,
  cancer,
  leo,
  virgo,
  libra,
  scorpio,
  sagittarius,
  capricorn,
  aquarius,
  pisces
}

class AstrologyService {
  static ZodiacSign getSign(DateTime birthDate) {
    final m = birthDate.month;
    final d = birthDate.day;

    if ((m == 3 && d >= 21) || (m == 4 && d <= 19)) return ZodiacSign.aries;
    if ((m == 4 && d >= 20) || (m == 5 && d <= 20)) return ZodiacSign.taurus;
    if ((m == 5 && d >= 21) || (m == 6 && d <= 20)) return ZodiacSign.gemini;
    if ((m == 6 && d >= 21) || (m == 7 && d <= 22)) return ZodiacSign.cancer;
    if ((m == 7 && d >= 23) || (m == 8 && d <= 22)) return ZodiacSign.leo;
    if ((m == 8 && d >= 23) || (m == 9 && d <= 22)) return ZodiacSign.virgo;
    if ((m == 9 && d >= 23) || (m == 10 && d <= 22)) return ZodiacSign.libra;
    if ((m == 10 && d >= 23) || (m == 11 && d <= 21)) return ZodiacSign.scorpio;
    if ((m == 11 && d >= 22) || (m == 12 && d <= 21)) return ZodiacSign.sagittarius;
    if ((m == 12 && d >= 22) || (m == 1 && d <= 19)) return ZodiacSign.capricorn;
    if ((m == 1 && d >= 20) || (m == 2 && d <= 18)) return ZodiacSign.aquarius;
    return ZodiacSign.pisces;
  }

  static String getSignName(ZodiacSign sign, String langCode) {
    switch (sign) {
      case ZodiacSign.aries: return langCode == 'tr' ? 'Koç' : 'Aries';
      case ZodiacSign.taurus: return langCode == 'tr' ? 'Boğa' : 'Taurus';
      case ZodiacSign.gemini: return langCode == 'tr' ? 'İkizler' : 'Gemini';
      case ZodiacSign.cancer: return langCode == 'tr' ? 'Yengeç' : 'Cancer';
      case ZodiacSign.leo: return langCode == 'tr' ? 'Aslan' : 'Leo';
      case ZodiacSign.virgo: return langCode == 'tr' ? 'Başak' : 'Virgo';
      case ZodiacSign.libra: return langCode == 'tr' ? 'Terazi' : 'Libra';
      case ZodiacSign.scorpio: return langCode == 'tr' ? 'Akrep' : 'Scorpio';
      case ZodiacSign.sagittarius: return langCode == 'tr' ? 'Yay' : 'Sagittarius';
      case ZodiacSign.capricorn: return langCode == 'tr' ? 'Oğlak' : 'Capricorn';
      case ZodiacSign.aquarius: return langCode == 'tr' ? 'Kova' : 'Aquarius';
      case ZodiacSign.pisces: return langCode == 'tr' ? 'Balık' : 'Pisces';
    }
  }

  static String getSignEmoji(ZodiacSign sign) {
    switch (sign) {
      case ZodiacSign.aries: return '♈';
      case ZodiacSign.taurus: return '♉';
      case ZodiacSign.gemini: return '♊';
      case ZodiacSign.cancer: return '♋';
      case ZodiacSign.leo: return '♌';
      case ZodiacSign.virgo: return '♍';
      case ZodiacSign.libra: return '♎';
      case ZodiacSign.scorpio: return '♏';
      case ZodiacSign.sagittarius: return '♐';
      case ZodiacSign.capricorn: return '♑';
      case ZodiacSign.aquarius: return '♒';
      case ZodiacSign.pisces: return '♓';
    }
  }

  /// Generates a pseudo-random index based on a seed string so it is deterministic
  static int _getSeededIndex(String seed, int max) {
    int hash = 0;
    for (int i = 0; i < seed.length; i++) {
      hash = (31 * hash + seed.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return hash % max;
  }

  static String getDailyPrediction(ZodiacSign sign, String langCode) {
    final now = DateTime.now();
    final seed = '${sign.name}_daily_${now.year}_${now.month}_${now.day}';
    final items = langCode == 'tr' ? _dailyTr : _dailyEn;
    return items[_getSeededIndex(seed, items.length)];
  }

  static String getMonthlyPrediction(ZodiacSign sign, String langCode) {
    final now = DateTime.now();
    final seed = '${sign.name}_monthly_${now.year}_${now.month}';
    final items = langCode == 'tr' ? _monthlyTr : _monthlyEn;
    return items[_getSeededIndex(seed, items.length)];
  }

  static String getYearlyPrediction(ZodiacSign sign, String langCode) {
    final now = DateTime.now();
    final seed = '${sign.name}_yearly_${now.year}';
    final items = langCode == 'tr' ? _yearlyTr : _yearlyEn;
    return items[_getSeededIndex(seed, items.length)];
  }

  static const _dailyTr = [
    'Bugün yıldızlar senin için parlıyor! Yeni bir projeye başlamak veya ertelediğin bir işi bitirmek için harika bir gün.',
    'Beklenmedik bir sürprize hazır ol. Eski bir dosttan haber alabilir veya küçük bir şans yakalayabilirsin.',
    'Bugün içsel huzuruna odaklanma zamanı. Biraz dinlen, meditasyon yap, kendine zaman ayır.',
    'Karşına çıkan fırsatları iyi değerlendir! Evren bugün sana cesaret veriyor, adım atmaktan korkma.',
    'İletişim becerilerinin ön planda olacağı bir gün. Önemli bir konuşma yapacaksan bugün tam zamanı.',
    'Dikkatini dağıtan şeylerden uzak durup işlerine odaklanmalısın. Çabalarının meyvesini çok yakında alacaksın.',
    'Aşk ve ilişkilerde pozitif bir enerji var. Sevdiğin insanlara zaman ayırarak bağlarınızı güçlendirebilirsin.',
    'Bugün sezgilerine güven. İçinden gelen ses sana doğru yolu gösterecek.',
  ];

  static const _dailyEn = [
    'The stars are shining for you today! It\'s a great day to start a new project or finish a delayed task.',
    'Get ready for an unexpected surprise. You might hear from an old friend or catch a small stroke of luck.',
    'Today is the time to focus on your inner peace. Rest a bit, meditate, and take some time for yourself.',
    'Make good use of the opportunities that come your way! The universe is giving you courage today, don\'t be afraid to take a step.',
    'A day where your communication skills will shine. If you have an important conversation, today is the perfect time.',
    'You should stay away from distractions and focus on your tasks. You will soon reap the rewards of your efforts.',
    'There is a positive energy in love and relationships. You can strengthen your bonds by spending time with loved ones.',
    'Trust your intuition today. Your inner voice will show you the right path.',
  ];

  static const _monthlyTr = [
    'Bu ay kariyerinde ve kişisel hedeflerinde büyük ilerlemeler kaydedebilirsin. Sıkı çalışmanın ödüllerini toplama vakti geldi!',
    'Finansal anlamda bereketli bir döneme giriyorsun. Ancak harcamalarına dikkat etmen ve yatırımlarını gözden geçirmen gerekebilir.',
    'Sosyal çevrenin genişleyeceği, yeni insanlarla tanışıp ufkunun açılacağı bir ay olacak. Seyahat fırsatları karşına çıkabilir.',
    'Bu ay tamamen kendine odaklanmalısın. Sağlığına, hobilerine ve kişisel gelişimine yatırım yap. Yepyeni bir sen doğuyor.',
    'Romantizm rüzgarları esiyor! İlişkisi olanlar için bağların derinleşeceği, yalnızlar içinse kalplerinin çarpacağı bir dönem.',
  ];

  static const _monthlyEn = [
    'You can make great progress in your career and personal goals this month. It\'s time to reap the rewards of your hard work!',
    'You are entering a prosperous period financially. However, you may need to watch your spending and review your investments.',
    'It will be a month where your social circle expands, you meet new people, and your horizons open up. Travel opportunities may arise.',
    'You should focus entirely on yourself this month. Invest in your health, hobbies, and personal development. A brand new you is emerging.',
    'The winds of romance are blowing! A period where bonds will deepen for those in relationships, and hearts will flutter for singles.',
  ];

  static const _yearlyTr = [
    'Bu yıl senin yılın olacak! Jüpiter\'in olumlu etkileriyle hayatında büyük bir sıçrama yaşayacaksın. Risk almaktan çekinme.',
    'Kök salma ve sağlam temeller inşa etme yılı. Evlilik, yeni bir ev veya uzun vadeli büyük bir kariyer adımı atabilirsin.',
    'Değişim ve dönüşüm kapıda! Eski alışkanlıklarını geride bırakıp, yepyeni bir hayata adım atacağın macera dolu bir yıl seni bekliyor.',
    'Karmaşık sorunların çözüleceği, ruhsal olarak aydınlanacağın huzur dolu bir yıl. Affetmeyi ve hafiflemeyi öğreneceksin.',
  ];

  static const _yearlyEn = [
    'This will be your year! With Jupiter\'s positive influences, you will experience a big leap in your life. Don\'t hesitate to take risks.',
    'A year of putting down roots and building solid foundations. You might step into marriage, a new home, or a major long-term career move.',
    'Change and transformation are at the door! An adventurous year awaits you where you leave old habits behind and step into a brand new life.',
    'A peaceful year where complex problems will be solved and you will become spiritually enlightened. You will learn to forgive and lighten up.',
  ];
}
