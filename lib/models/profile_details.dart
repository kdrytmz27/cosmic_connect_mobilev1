// // lib/models/profile_details.dart (GÜNCELLENMİŞ HALİ)

// import 'dart:convert';
// import 'package:cosmic_connect_mobile/models/profile.dart';
// import 'package:cosmic_connect_mobile/models/compatibility_report.dart'; // YENİ IMPORT

// ProfileDetails profileDetailsFromJson(String str) =>
//     ProfileDetails.fromJson(json.decode(str));

// class ProfileDetails {
//   final Profile profile;
//   // GÜNCELLEME: Artık Map yerine tip-güvenli bir nesne kullanıyoruz.
//   final CompatibilityReport details;
//   final bool viewerHasLiked;
//   final bool isMatch;
//   final int? conversationId;

//   ProfileDetails({
//     required this.profile,
//     required this.details,
//     required this.viewerHasLiked,
//     required this.isMatch,
//     this.conversationId,
//   });

//   factory ProfileDetails.fromJson(Map<String, dynamic> json) => ProfileDetails(
//         profile: Profile.fromJson(json["profile"]),
//         // GÜNCELLEME: Gelen 'details' verisini yeni modelimize göre parse ediyoruz.
//         details: CompatibilityReport.fromJson(json["details"] ?? {}),
//         viewerHasLiked: json["viewer_has_liked"] ?? false,
//         isMatch: json["is_a_match"] ?? false,
//         conversationId: json["conversation_id"],
//       );
// }
