import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/item_providers.dart';
import '../domain/item.dart';
import '../../auth/presentation/auth_providers.dart';

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo
          Container(
            width: double.infinity,
            height: 250,
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

                // Location info
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: const Text('Ubicación aproximada'),
                    subtitle: Text(
                      '${item.approximateLat.toStringAsFixed(3)}, ${item.approximateLng.toStringAsFixed(3)}',
                    ),
                  ),
                ),
                const SizedBox(height: 24),

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
                  FilledButton.icon(
                    onPressed: () {
                      context.push('/items/${item.id}/reserve');
                    },
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: const Text('Reservar'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Chat navigation
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
                    onPressed: () {
                      // Edit
                    },
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
    );
  }
}
