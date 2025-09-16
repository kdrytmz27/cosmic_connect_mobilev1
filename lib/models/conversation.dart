// lib/models/conversation.dart

import 'dart:convert';
import 'app_user.dart';
import 'message.dart'; // <<<--- HATA DÜZELTİLDİ: Tam dosya yolu yerine sadece dosya adı

List<Conversation> conversationFromJson(String str) => List<Conversation>.from(
    json.decode(str).map((x) => Conversation.fromJson(x)));

class Conversation {
  final int id;
  final AppUser? otherParticipant;
  final Message? lastMessage;
  final DateTime updatedAt;

  Conversation({
    required this.id,
    this.otherParticipant,
    this.lastMessage,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        id: json["id"],
        otherParticipant: json["other_participant"] == null
            ? null
            : AppUser.fromJson(json["other_participant"]),
        lastMessage: json["last_message"] == null
            ? null
            : Message.fromJson(json["last_message"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );
}
