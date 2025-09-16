// lib/models/compatibility.dart

import 'dart:convert';
import 'app_user.dart';

List<Compatibility> compatibilityFromJson(String str) =>
    List<Compatibility>.from(
        json.decode(str).map((x) => Compatibility.fromJson(x)));

class Compatibility {
  final AppUser user;
  final int score;

  Compatibility({
    required this.user,
    required this.score,
  });

  factory Compatibility.fromJson(Map<String, dynamic> json) => Compatibility(
        user: AppUser.fromJson(json["user"]),
        score: json["score"],
      );
}
