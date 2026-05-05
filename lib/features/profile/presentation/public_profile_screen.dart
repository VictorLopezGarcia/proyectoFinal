import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../presentation/profile_providers.dart';
import '../../items/presentation/item_providers.dart';
import '../../chat/presentation/chat_providers.dart';
import '../../../core/layout/responsive_container.dart';

class PublicProfileScreen extends ConsumerWidget {
  final String userId;
  const PublicProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(currentUserProvider(userId));
    final userItems = ref.watch(myItemsStreamProvider(userId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: userData.when(
        data: (appUser) {
          if (appUser == null) {
            return const Center(child: Text('Usuario no encontrado'));
          }

          return ResponsiveContainer(
            maxWidth: 700,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  // Avatar
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: colorScheme.primaryContainer,
                    backgroundImage: appUser.photoUrl.isNotEmpty
                        ? NetworkImage(appUser.photoUrl)
                        : null,
                    child: appUser.photoUrl.isEmpty
                        ? Text(
                            appUser.displayName.isNotEmpty
                                ? appUser.displayName[0].toUpperCase()
                                : '?',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    appUser.displayName.isEmpty ? 'Sin nombre' : appUser.displayName,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  if (appUser.bio.isNotEmpty)
                    Text(
                      appUser.bio,
                      style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 24),
                  // Stats
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.star_rounded,
                          iconColor: Colors.amber,
                          label: 'Valoración',
                          value: appUser.averageRating > 0
                              ? appUser.averageRating.toStringAsFixed(1)
                              : '—',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.handshake_outlined,
                          iconColor: colorScheme.primary,
                          label: 'Alquileres',
                          value: '${appUser.totalRentals}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Contact button (only for other users)
                  if (currentUid != null && currentUid != userId)
                    FilledButton.icon(
                      onPressed: () async {
                        final participants = [currentUid, userId]..sort();
                        final chatId = participants.join('_');
                        await ref.read(chatRepositoryProvider).createChat(participants);
                        if (context.mounted) {
                          context.push('/chats/$chatId?otherUserId=$userId');
                        }
                      },
                      icon: const Icon(Icons.chat_outlined),
                      label: const Text('Enviar mensaje'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  const SizedBox(height: 32),
                  // Items
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Objetos publicados',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  userItems.when(
                    data: (items) {
                      if (items.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'Sin objetos publicados',
                            style: TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: item.photos.isNotEmpty
                                    ? Image.network(item.photos.first, width: 56, height: 56, fit: BoxFit.cover)
                                    : Container(
                                        width: 56, height: 56,
                                        color: colorScheme.surfaceContainerHighest,
                                        child: Icon(Icons.image_outlined, color: colorScheme.onSurfaceVariant),
                                      ),
                              ),
                              title: Text(item.title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                              subtitle: Text(
                                '${item.pricePerDay.toStringAsFixed(2)} €/día',
                                style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => context.push('/items/${item.id}'),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text('Error: $err')),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  const _StatCard({required this.icon, required this.iconColor, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(label, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
