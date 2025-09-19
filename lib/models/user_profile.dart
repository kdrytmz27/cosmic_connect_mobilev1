// Lütfen bu kodu kopyalayıp lib/models/user_profile.dart dosyasının içine yapıştırın.

class UserProfile {
  final String? avatar;
  final String bio;
  final int? age;
  final String? gender;
  final String? genderDisplay;

  final DateTime? birthDate;
  final String? birthTime;
  final String? birthCity;

  final bool isBirthChartCalculated;

  final String? sunSign;
  final String? sunSignDisplay;
  final String? moonSign;
  final String? moonSignDisplay;
  final String? risingSign;
  final String? risingSignDisplay;
  final String? mercurySign;
  final String? mercurySignDisplay;
  final String? venusSign;
  final String? venusSignDisplay;
  final String? marsSign;
  final String? marsSignDisplay;

  final String? natalChartPngBase64;
  final Map<String, dynamic>? insightsData;

  UserProfile({
    this.avatar,
    required this.bio,
    this.age,
    this.gender,
    this.genderDisplay,
    this.birthDate,
    this.birthTime,
    this.birthCity,
    required this.isBirthChartCalculated,
    this.sunSign,
    this.sunSignDisplay,
    this.moonSign,
    this.moonSignDisplay,
    this.risingSign,
    this.risingSignDisplay,
    this.mercurySign,
    this.mercurySignDisplay,
    this.venusSign,
    this.venusSignDisplay,
    this.marsSign,
    this.marsSignDisplay,
    this.natalChartPngBase64,
    this.insightsData,
  });

  // --- NİHAİ ZAFER DEĞİŞİKLİĞİ: fromJson METODU DÜZELTİLDİ ---
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      avatar: json["avatar"],
      bio: json["bio"] ?? '',
      age: json["age"],
      // Cinsiyet alanı hala liste formatında gelebilir, bu yüzden kontrolü koruyoruz.
      gender: json["gender"] is List ? json["gender"][0] : json["gender"],
      genderDisplay: json["gender"] is List ? json["gender"][1] : null,
      birthDate: json["birth_date"] == null
          ? null
          : DateTime.tryParse(json["birth_date"]),
      birthTime: json["birth_time"],
      birthCity: json["birth_city"],

      // is_birth_chart_calculated alanını JSON'dan oku, yoksa varsayılan olarak 'false' ata.
      isBirthChartCalculated: json["is_birth_chart_calculated"] ?? false,

      // Artık API'den doğrudan string değerler geldiği için karmaşık fonksiyonlara gerek yok.
      // JSON'daki değeri olduğu gibi alıyoruz.
      sunSign: json["sun_sign"],
      sunSignDisplay: json["sun_sign_display"],
      moonSign: json["moon_sign"],
      moonSignDisplay: json["moon_sign_display"],
      risingSign: json["rising_sign"],
      risingSignDisplay: json["rising_sign_display"],
      mercurySign: json["mercury_sign"],
      mercurySignDisplay: json["mercury_sign_display"],
      venusSign: json["venus_sign"],
      venusSignDisplay: json["venus_sign_display"],
      marsSign: json["mars_sign"],
      marsSignDisplay: json["mars_sign_display"],

      natalChartPngBase64: json["natal_chart_png_base64"],
      insightsData: json["insights_data"],
    );
  }
}
