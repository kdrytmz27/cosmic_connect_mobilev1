// lib/models/message.dart

import 'dart:convert';
import 'app_user.dart';

List<Message> messageFromJson(String str) =>
    List<Message>.from(json.decode(str).map((x) => Message.fromJson(x)));

class Message {
  final int id;
  final AppUser sender;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  Message({
    required this.id,
    required this.sender,
    required this.content,
    required this.timestamp,
    required this.isRead,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json["id"],
        sender: AppUser.fromJson(json["sender"]),
        content: json["content"],
        timestamp: DateTime.parse(json["timestamp"]),
        isRead: json["is_read"],
      );
}
