class IAPProducts {
  // Ana kategoriler
  static const String animals   = 'com.yourapp.category.animals';
  static const String sports    = 'com.yourapp.category.sports';
  static const String countries = 'com.yourapp.category.countries';
  static const String singers   = 'com.yourapp.category.singers';
  static const String actors    = 'com.yourapp.category.actors';
  static const String streamers = 'com.yourapp.category.streamers';
  static const String youtubers = 'com.yourapp.category.youtubers';

  // Sporcular alt kategorileri (₺10)
  static const String athletesFootballDomestic = 'com.yourapp.sub.athletes_active_football_domestic';
  static const String athletesFootballForeign  = 'com.yourapp.sub.athletes_active_football_foreign';
  static const String athletesLegendsDomestic  = 'com.yourapp.sub.athletes_retired_football_domestic';
  static const String athletesLegendsForeign   = 'com.yourapp.sub.athletes_retired_football_foreign';
  static const String athletesNba              = 'com.yourapp.sub.athletes_basketball_nba';
  static const String athletesEuroleague       = 'com.yourapp.sub.athletes_basketball_euroleague';
  static const String athletesBasketballLeg    = 'com.yourapp.sub.athletes_basketball_legends';
  static const String athletesVolleyball       = 'com.yourapp.sub.athletes_volleyball_female';
  static const String athletesUfc             = 'com.yourapp.sub.athletes_ufc';
  static const String athletesBoxing          = 'com.yourapp.sub.athletes_boxing';
  static const String athletesF1              = 'com.yourapp.sub.athletes_f1';

  // Tüm product ID'leri (queryProductDetails için)
  static Set<String> get all => {
    animals, sports, countries, singers, actors, streamers, youtubers,
    athletesFootballDomestic, athletesFootballForeign,
    athletesLegendsDomestic, athletesLegendsForeign,
    athletesNba, athletesEuroleague, athletesBasketballLeg,
    athletesVolleyball, athletesUfc, athletesBoxing, athletesF1,
  };

  // JSON'daki category.id → product ID eşleştirmesi
  static String? productIdForCategory(String categoryId) {
    const map = {
      'animals':   animals,
      'sports':    sports,
      'countries': countries,
      'singers':   singers,
      'actors':    actors,
      'streamers': streamers,
      'youtubers': youtubers,
    };
    return map[categoryId];
  }

  // JSON'daki subcategory.id → product ID eşleştirmesi
  static String? productIdForSubcategory(String subcategoryId) {
    const map = {
      'athletes_active_football_domestic':   athletesFootballDomestic,
      'athletes_active_football_foreign':    athletesFootballForeign,
      'athletes_retired_football_domestic':  athletesLegendsDomestic,
      'athletes_retired_football_foreign':   athletesLegendsForeign,
      'athletes_basketball_nba':             athletesNba,
      'athletes_basketball_euroleague':      athletesEuroleague,
      'athletes_basketball_legends':         athletesBasketballLeg,
      'athletes_volleyball_female':          athletesVolleyball,
      'athletes_ufc':                        athletesUfc,
      'athletes_boxing':                     athletesBoxing,
      'athletes_f1':                         athletesF1,
    };
    return map[subcategoryId];
  }
}