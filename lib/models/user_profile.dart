// lib/models/user_profile.dart

class UserProfile {
  final String? avatar;
  final String bio;
  final int? age;
  final String? gender;
  final String? genderDisplay;

  final DateTime? birthDate;
  final String? birthTime;
  final String? birthCity;

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

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // Django'daki 'depth=1' ayarı sayesinde 'choices' alanları liste olarak gelir: [key, display_value]
    // Bu yardımcı fonksiyon, bu listeden istediğimiz değeri güvenli bir şekilde alır.
    String? getChoiceKey(dynamic data) => data is List ? data[0] : data;
    String? getChoiceDisplay(dynamic data) => data is List ? data[1] : null;

    return UserProfile(
      avatar: json["avatar"],
      bio: json["bio"] ?? '',
      age: json["age"],
      gender: getChoiceKey(json["gender"]),
      genderDisplay: getChoiceDisplay(json["gender"]),
      birthDate: json["birth_date"] == null
          ? null
          : DateTime.tryParse(json["birth_date"]),
      birthTime: json["birth_time"],
      birthCity: json["birth_city"],
      sunSign: getChoiceKey(json["sun_sign"]),
      sunSignDisplay: getChoiceDisplay(json["sun_sign"]),
      moonSign: getChoiceKey(json["moon_sign"]),
      moonSignDisplay: getChoiceDisplay(json["moon_sign"]),
      risingSign: getChoiceKey(json["rising_sign"]),
      risingSignDisplay: getChoiceDisplay(json["rising_sign"]),
      mercurySign: getChoiceKey(json["mercury_sign"]),
      mercurySignDisplay: getChoiceDisplay(json["mercury_sign"]),
      venusSign: getChoiceKey(json["venus_sign"]),
      venusSignDisplay: getChoiceDisplay(json["venus_sign"]),
      marsSign: getChoiceKey(json["mars_sign"]),
      marsSignDisplay: getChoiceDisplay(json["mars_sign"]),
      natalChartPngBase64: json["natal_chart_png_base64"],
      insightsData: json["insights_data"],
    );
  }
}
