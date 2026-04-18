import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rent_my_stuff/features/chat/presentation/chat_providers.dart';
import 'package:rent_my_stuff/features/chat/presentation/chat_screen.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Debes iniciar sesión')),
      );
    }

    final chats = ref.watch(userChatsProvider(user.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Chats'),
      ),
      body: chats.when(
        data: (chatList) {
          if (chatList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text('No tienes conversaciones'),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: chatList.length,
            itemBuilder: (context, index) {
              final chat = chatList[index];
              final otherUserId = chat.participants.firstWhere(
                (id) => id != user.uid,
                orElse: () => chat.participants[0],
              );

              return ListTile(
                leading: CircleAvatar(
                  child: Text(otherUserId[0].toUpperCase()),
                ),
                title: Text('Usuario $otherUserId'),
                subtitle: Text(
                  chat.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatId: chat.id,
                        otherUserId: otherUserId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
