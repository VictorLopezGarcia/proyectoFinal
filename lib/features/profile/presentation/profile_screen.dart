import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:rent_my_stuff/features/profile/presentation/profile_providers.dart';
import 'package:rent_my_stuff/features/profile/domain/app_user.dart';
import 'package:rent_my_stuff/features/auth/presentation/auth_providers.dart';
import 'package:rent_my_stuff/core/layout/responsive_container.dart';
import 'package:rent_my_stuff/features/ratings/presentation/rating_providers.dart';
import 'package:rent_my_stuff/features/items/presentation/item_providers.dart';
import 'package:rent_my_stuff/features/items/domain/item.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showEditSheet(BuildContext context, WidgetRef ref, AppUser appUser) {
    final nameCtrl = TextEditingController(text: appUser.displayName);
    final bioCtrl = TextEditingController(text: appUser.bio);
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Editar perfil',
                      style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bioCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Biografía',
                  prefixIcon: Icon(Icons.notes_outlined),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: saving
                      ? null
                      : () async {
                          setState(() => saving = true);
                          final updated = appUser.copyWith(
                            displayName: nameCtrl.text.trim(),
                            bio: bioCtrl.text.trim(),
                          );
                          await ref.read(userRepositoryProvider).updateUser(updated);
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                  child: saving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Guardar cambios'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Debes iniciar sesión')));
    }

    final userData = ref.watch(currentUserProvider(user.uid));
    final ratingsAsync = ref.watch(userRatingsProvider(user.uid));
    final myItems = ref.watch(myItemsStreamProvider(user.uid));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: userData.when(
        data: (appUser) {
          if (appUser == null) return const Center(child: CircularProgressIndicator());

          return ResponsiveContainer(
            maxWidth: 700,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  // Avatar
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: colorScheme.primaryContainer,
                    backgroundImage: appUser.photoUrl.isNotEmpty ? NetworkImage(appUser.photoUrl) : null,
                    child: appUser.photoUrl.isEmpty
                        ? Text(
                            appUser.displayName.isNotEmpty ? appUser.displayName[0].toUpperCase() : '?',
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
                  Text(
                    appUser.email,
                    style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  if (appUser.bio.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      appUser.bio,
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Stats row
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
                  // Edit profile + Create item buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showEditSheet(context, ref, appUser),
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Editar perfil'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(44),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => context.push('/items/create'),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Publicar objeto'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(44),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // My items
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Mis publicaciones',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  myItems.when(
                    data: (items) {
                      if (items.isEmpty) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Icon(Icons.inventory_2_outlined, size: 48, color: colorScheme.onSurfaceVariant.withAlpha(120)),
                                const SizedBox(height: 12),
                                Text('No has publicado ningún objeto', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                                const SizedBox(height: 12),
                                FilledButton.tonal(
                                  onPressed: () => context.push('/items/create'),
                                  child: const Text('Publicar ahora'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        itemBuilder: (context, index) => _MyItemTile(
                          item: items[index],
                        ),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Text('Error: $e'),
                  ),

                  const SizedBox(height: 32),
                  // Ratings
                  ratingsAsync.when(
                    data: (ratings) {
                      if (ratings.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Valoraciones recibidas',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          ...ratings.take(5).map((r) => _RatingTile(rating: r)),
                        ],
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (e, st) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar sesión'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.error,
                      side: BorderSide(color: colorScheme.error),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _MyItemTile extends ConsumerWidget {
  final Item item;
  const _MyItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                  child: Icon(Icons.inventory_2_outlined, color: colorScheme.onSurfaceVariant),
                ),
        ),
        title: Text(item.title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${item.pricePerDay.toStringAsFixed(2)} €/día',
          style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) async {
            switch (action) {
              case 'view':
                context.push('/items/${item.id}');
                break;
              case 'edit':
                context.push('/items/${item.id}/edit');
                break;
              case 'delete':
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('¿Eliminar objeto?'),
                    content: const Text('Esta acción no se puede deshacer.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                      FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  await ref.read(itemRepositoryProvider).deleteItem(item.id);
                }
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'view', child: ListTile(leading: Icon(Icons.visibility_outlined), title: Text('Ver'), dense: true, contentPadding: EdgeInsets.zero)),
            const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Editar'), dense: true, contentPadding: EdgeInsets.zero)),
            PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outlined, color: colorScheme.error), title: Text('Eliminar', style: TextStyle(color: colorScheme.error)), dense: true, contentPadding: EdgeInsets.zero)),
          ],
        ),
        onTap: () => context.push('/items/${item.id}'),
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

class _RatingTile extends StatelessWidget {
  final dynamic rating;
  const _RatingTile({required this.rating});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(5, (i) => Icon(
                i < rating.score ? Icons.star_rounded : Icons.star_outline_rounded,
                color: Colors.amber, size: 18,
              )),
            ),
            if (rating.comment.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(rating.comment, style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}
