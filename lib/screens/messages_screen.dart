// lib/screens/messages_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/conversation.dart';
import 'chat_room_screen.dart'; // Bir sonraki adımda oluşturacağız

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
    _conversationsFuture = context.read<ApiService>().getConversations();
  }

  void _refreshConversations() {
    setState(() {
      _conversationsFuture = context.read<ApiService>().getConversations();
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
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Henüz bir sohbetiniz yok.'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                      onPressed: _refreshConversations,
                      child: const Text('Yenile'))
                ],
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
}
