// Lütfen bu kodu kopyalayıp lib/screens/messages_screen.dart dosyasının içine yapıştırın.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/conversation.dart';
import 'chat_room_screen.dart';
// Navigasyon için import

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late Future<List<Conversation>> _conversationsFuture;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  void _loadConversations() {
    _conversationsFuture = context.read<ApiService>().getConversations();
  }

  void _refreshConversations() {
    setState(() {
      _loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesajlar'),
      ),
      body: FutureBuilder<List<Conversation>>(
        future: _conversationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- GÖREV 6 DEĞİŞİKLİĞİ: Geliştirilmiş Boş Ekran ve Hata Durumu ---
          if (snapshot.hasError) {
            return _buildEmptyState(
              icon: Icons.cloud_off,
              message: "Mesajlar yüklenemedi.",
              actionButton: ElevatedButton(
                onPressed: _refreshConversations,
                child: const Text('Tekrar Dene'),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(
              icon: Icons.message_outlined,
              message: "İlk eşleşmeni bul ve sohbet etmeye başla!",
              actionButton: TextButton(
                onPressed: () {
                  // TODO: Bu kısım, MainScreen'deki sekmeyi değiştiren bir yapıya bağlanmalı.
                  // Şimdilik basit bir print ile bırakıyoruz.
                  print("Keşfet sekmesine git");
                },
                child: const Text("Keşfet'te Yeni Kişilerle Tanış"),
              ),
            );
          }

          final conversations = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _refreshConversations(),
            child: ListView.separated(
              itemCount: conversations.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                final participant = conversation.otherParticipant;
                if (participant == null) return const SizedBox.shrink();

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: participant.profile.avatar != null
                        ? NetworkImage(participant.profile.avatar!)
                        : null,
                    child: participant.profile.avatar == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(participant.username,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    conversation.lastMessage?.content ?? 'Sohbeti başlat...',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) => ChatRoomScreen(
                                conversationId: conversation.id,
                                otherParticipant: participant),
                          ),
                        )
                        .then((_) =>
                            _refreshConversations()); // Sohbetten dönünce listeyi yenile
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Yeniden kullanılabilir boş ekran widget'ı
  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required Widget actionButton,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          actionButton,
        ],
      ),
    );
  }
}
