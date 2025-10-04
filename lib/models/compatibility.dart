// lib/models/compatibility.dart

import 'dart:convert';
import 'app_user.dart';

List<Compatibility> compatibilityFromJson(String str) =>
    List<Compatibility>.from(
        json.decode(str).map((x) => Compatibility.fromJson(x)));

class Compatibility {
  final AppUser user;
  final int score;
  // --- FAZ 2 DEĞİŞİKLİĞİ: 'breakdown' alanı eklendi ---
  // API'den gelen {"Aşk Uyumu": 90, "İletişim Uyumu": 75} gibi
  // bir JSON nesnesini tutmak için Map<String, dynamic> kullanıyoruz.
  final Map<String, dynamic> breakdown;

  Compatibility({
    required this.user,
    required this.score,
    required this.breakdown,
  });

  factory Compatibility.fromJson(Map<String, dynamic> json) => Compatibility(
        user: AppUser.fromJson(json["user"]),
        score: json["score"],
        // --- FAZ 2 DEĞİŞİKLİĞİ: 'breakdown' alanı parse ediliyor ---
        // Eğer API'den 'breakdown' gelmezse veya null ise,
        // hata almamak için varsayılan olarak boş bir map atıyoruz.
        breakdown: json["breakdown"] as Map<String, dynamic>? ?? {},
      );
}
