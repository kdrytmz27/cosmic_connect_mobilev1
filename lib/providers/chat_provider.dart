// lib/providers/chat_provider.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../services/api_service.dart';
import '../models/message.dart';
import '../models/app_user.dart';
import '../models/user_profile.dart';

class ChatProvider with ChangeNotifier {
  final ApiService _apiService;
  final int _conversationId;
  final int _currentUserId;
  final AppUser _otherParticipant;

  WebSocketChannel? _channel;
  StreamSubscription? _channelSubscription;

  List<Message> _messages = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ChatProvider(this._apiService, this._conversationId, this._currentUserId,
      this._otherParticipant) {
    _init();
  }

  Future<void> _init() async {
    await fetchInitialMessages();
    _connectToWebSocket();
  }

  Future<void> fetchInitialMessages() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final messages = await _apiService.getMessages(_conversationId);
      _messages = messages;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = "Mesajlar yüklenemedi.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _connectToWebSocket() {
    final token = _apiService.getTokenForWebSocket();
    if (token == null) {
      _errorMessage = "WebSocket bağlantısı için yetkilendirme başarısız.";
      notifyListeners();
      return;
    }

    final wsUrl =
        '${ApiService.baseUrl.replaceFirst('http', 'ws')}/ws/chat/$_conversationId/?token=$token';
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    _channelSubscription = _channel!.stream.listen(
      (data) {
        final messageData = json.decode(data);
        final senderId = messageData['sender_id'];

        final currentUserProfile = UserProfile(bio: ''); // Geçici boş profil
        final currentUser = AppUser(
            id: _currentUserId,
            username: "Ben",
            email: "",
            profile: currentUserProfile);

        final sender =
            senderId == _currentUserId ? currentUser : _otherParticipant;

        final newMessage = Message(
            id: DateTime.now().millisecondsSinceEpoch, // Geçici ID
            sender: sender,
            content: messageData['message'],
            timestamp: DateTime.parse(messageData['timestamp']),
            isRead: true);
        _messages.add(newMessage);
        notifyListeners();
      },
      onError: (error) {
        debugPrint("WebSocket Hatası: $error");
        _errorMessage = "Sohbet bağlantısı koptu.";
        notifyListeners();
      },
      onDone: () {
        debugPrint("WebSocket Bağlantısı Kapandı.");
      },
    );
  }

  void sendMessage(String content) {
    if (content.trim().isEmpty || _channel == null) return;
    _channel!.sink.add(json.encode({'message': content}));
  }

  @override
  void dispose() {
    _channelSubscription?.cancel();
    _channel?.sink.close();
    super.dispose();
  }
}
