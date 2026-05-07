import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../presentation/item_providers.dart';
import '../domain/item.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../chat/presentation/chat_providers.dart';
import '../../profile/presentation/profile_providers.dart';
import '../../../core/layout/responsive_container.dart';
import '../../../core/widgets/map_view.dart';

class ItemDetailScreen extends ConsumerWidget {
  final String itemId;
  const ItemDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(itemDetailProvider(itemId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: itemAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (item) {
          if (item == null) {
            return const Center(child: Text('Objeto no encontrado'));
          }
          return _ItemDetailBody(item: item);
        },
      ),
    );
  }
}

class _ItemDetailBody extends ConsumerWidget {
  final Item item;
  const _ItemDetailBody({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentUser = ref.watch(authStateProvider).valueOrNull;
    final isOwner = currentUser?.uid == item.ownerId;

    return SingleChildScrollView(
      child: ResponsiveContainer(
        maxWidth: 900,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo
            Container(
              width: double.infinity,
              height: 280,
              color: colorScheme.surfaceContainerHighest,
              child: item.photos.isNotEmpty
                  ? Image.network(item.photos.first, fit: BoxFit.cover)
                  : Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 80,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category chip
                Chip(
                  label: Text(
                    item.category[0].toUpperCase() + item.category.substring(1),
                  ),
                  avatar: const Icon(Icons.category_outlined, size: 18),
                ),
                const SizedBox(height: 12),

                // Title
                Text(item.title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),

                // Price
                Text(
                  '${item.pricePerDay.toStringAsFixed(2)} €/día',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                Text('Descripción',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 8),
                Text(item.description, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 24),

                // Location
                if (item.locationName != null && item.lat != null && item.lng != null) ...[
                  Text('Ubicación',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 18, color: colorScheme.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.locationName!,
                          style: theme.textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  MapView(lat: item.lat!, lng: item.lng!, height: 220),
                  const SizedBox(height: 24),
                ],

                // Owner summary
                if (!isOwner) _OwnerCard(ownerId: item.ownerId),
                const SizedBox(height: 16),

                // Actions
                if (!isOwner) ...[
                  FilledButton.icon(
                    onPressed: () => context.push('/items/${item.id}/reserve'),
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('Solicitar Reserva'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) return;

                      final participants = [user.uid, item.ownerId]..sort();
                      final chatId = participants.join('_');

                      // Ensure chat exists before navigation
                      await ref
                          .read(chatRepositoryProvider)
                          .createChat(participants);

                      if (context.mounted) {
                        context.push(
                            '/chats/$chatId?otherUserId=${item.ownerId}');
                      }
                    },
                    icon: const Icon(Icons.chat_outlined),
                    label: const Text('Contactar al propietario'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
                if (isOwner) ...[
                  OutlinedButton.icon(
                    onPressed: () => context.push('/items/${item.id}/edit'),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar objeto'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('¿Eliminar objeto?'),
                          content: const Text(
                            'Esta acción no se puede deshacer.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancelar'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Eliminar'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true && context.mounted) {
                        await ref
                            .read(itemRepositoryProvider)
                            .deleteItem(item.id);
                        if (context.mounted) context.pop();
                      }
                    },
                    icon: Icon(Icons.delete_outlined, color: colorScheme.error),
                    label: Text('Eliminar',
                        style: TextStyle(color: colorScheme.error)),
                  ),
                ],
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }
}

class _OwnerCard extends ConsumerWidget {
  final String ownerId;
  const _OwnerCard({required this.ownerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownerAsync = ref.watch(currentUserProvider(ownerId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ownerAsync.when(
      data: (owner) {
        if (owner == null) return const SizedBox.shrink();
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.push('/profile/$ownerId'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: colorScheme.primaryContainer,
                    backgroundImage: owner.photoUrl.isNotEmpty ? NetworkImage(owner.photoUrl) : null,
                    child: owner.photoUrl.isEmpty
                        ? Text(
                            owner.displayName.isNotEmpty ? owner.displayName[0].toUpperCase() : '?',
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          owner.displayName.isEmpty ? 'Propietario' : owner.displayName,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (owner.bio.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            owner.bio,
                            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              owner.averageRating > 0
                                  ? owner.averageRating.toStringAsFixed(1)
                                  : 'Sin valoraciones',
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.handshake_outlined, color: colorScheme.primary, size: 16),
                            const SizedBox(width: 4),
                            Text('${owner.totalRentals} alquileres', style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, st) => const SizedBox.shrink(),
    );
  }
}
