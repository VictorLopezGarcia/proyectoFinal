import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rent_my_stuff/features/chat/presentation/chat_providers.dart';
import 'package:rent_my_stuff/features/profile/presentation/profile_providers.dart';
import 'package:rent_my_stuff/core/layout/responsive_container.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: chats.when(
        data: (chatList) {
          if (chatList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes conversaciones',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Contacta a un propietario desde un objeto',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ResponsiveContainer(
            maxWidth: 800,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: chatList.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, indent: 76),
              itemBuilder: (context, index) {
                final chat = chatList[index];
                final otherUserId = chat.participants.firstWhere(
                  (id) => id != user.uid,
                  orElse: () => chat.participants.isNotEmpty
                      ? chat.participants[0]
                      : '',
                );

                return _ChatTile(
                  chatId: chat.id,
                  otherUserId: otherUserId,
                  lastMessage: chat.lastMessage,
                  updatedAt: chat.updatedAt,
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    size: 64, color: colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  'No se pudieron cargar los chats',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatTile extends ConsumerWidget {
  final String chatId;
  final String otherUserId;
  final String lastMessage;
  final DateTime updatedAt;

  const _ChatTile({
    required this.chatId,
    required this.otherUserId,
    required this.lastMessage,
    required this.updatedAt,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final otherUser = ref.watch(currentUserProvider(otherUserId));

    final displayName = otherUser.maybeWhen(
      data: (u) => u?.displayName ?? 'Usuario',
      orElse: () => 'Usuario',
    );

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: GestureDetector(
        onTap: () => context.push('/profile/$otherUserId'),
        child: CircleAvatar(
          radius: 24,
          backgroundColor: colorScheme.primaryContainer,
          child: Text(
            displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
            style: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      title: Text(
        displayName,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        lastMessage.isEmpty ? 'Inicia la conversación' : lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Text(
        DateFormat('HH:mm').format(updatedAt),
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      onTap: () {
        context.push('/chats/$chatId?otherUserId=$otherUserId');
      },
    );
  }
}
