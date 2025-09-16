// lib/models/app_user.dart

import 'dart:convert';
import 'user_profile.dart'; // <<<--- HATA DÜZELTİLDİ: 'package_profile.dart' -> 'user_profile.dart'

AppUser appUserFromJson(String str) => AppUser.fromJson(json.decode(str));

class AppUser {
  final int id;
  final String username;
  final String email;
  final UserProfile profile;

  AppUser({
    required this.id,
    required this.username,
    required this.email,
    required this.profile,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json["id"],
        username: json["username"],
        email: json["email"],
        profile: UserProfile.fromJson(json["profile"]),
      );
}
