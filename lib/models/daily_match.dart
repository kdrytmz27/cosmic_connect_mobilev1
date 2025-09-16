// lib/models/daily_match.dart

import 'dart:convert';
import 'app_user.dart';

DailyMatch dailyMatchFromJson(String str) =>
    DailyMatch.fromJson(json.decode(str));

class DailyMatch {
  final DateTime date;
  final AppUser matchedUser;

  DailyMatch({
    required this.date,
    required this.matchedUser,
  });

  factory DailyMatch.fromJson(Map<String, dynamic> json) => DailyMatch(
        date: DateTime.parse(json["date"]),
        matchedUser: AppUser.fromJson(json["matched_user"]),
      );
}
