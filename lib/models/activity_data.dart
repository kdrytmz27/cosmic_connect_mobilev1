// lib/models/activity_data.dart

import 'dart:convert';
import 'app_user.dart';

ActivityData activityDataFromJson(String str) =>
    ActivityData.fromJson(json.decode(str));

class ActivityData {
  final List<AppUser> matches;
  final List<AppUser> likers;
  final List<AppUser> visitors;

  ActivityData({
    required this.matches,
    required this.likers,
    required this.visitors,
  });

  factory ActivityData.fromJson(Map<String, dynamic> json) => ActivityData(
        matches:
            List<AppUser>.from(json["matches"].map((x) => AppUser.fromJson(x))),
        likers:
            List<AppUser>.from(json["likers"].map((x) => AppUser.fromJson(x))),
        visitors: List<AppUser>.from(
            json["visitors"].map((x) => AppUser.fromJson(x))),
      );
}
