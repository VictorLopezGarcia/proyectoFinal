import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../domain/reservation.dart';
import 'reservation_providers.dart';
import '../../ratings/presentation/rating_providers.dart';
import '../../profile/presentation/profile_providers.dart';
import '../../items/presentation/item_providers.dart';
import '../../../core/layout/responsive_container.dart';

class ReservationDetailScreen extends ConsumerWidget {
  final String reservationId;
  const ReservationDetailScreen({super.key, required this.reservationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservationAsync = ref.watch(reservationProvider(reservationId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de reserva'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: reservationAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (reservation) {
          if (reservation == null) {
            return const Center(child: Text('Reserva no encontrada'));
          }
          return _Body(reservation: reservation);
        },
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  final Reservation reservation;
  const _Body({required this.reservation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text('Sesión requerida'));

    final isOwner = reservation.ownerId == user.uid;
    final isRenter = reservation.renterId == user.uid;
    final otherUserId = isOwner ? reservation.renterId : reservation.ownerId;
    final otherUserAsync = ref.watch(currentUserProvider(otherUserId));
    final itemAsync = ref.watch(itemDetailProvider(reservation.itemId));

    final days = reservation.endDate
            .difference(reservation.startDate)
            .inDays +
        1;

    return ResponsiveContainer(
      maxWidth: 700,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status header
            Card(
              color: _statusColor(reservation.status, colorScheme).withAlpha(30),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(_statusIcon(reservation.status),
                        color: _statusColor(reservation.status, colorScheme), size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Estado',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              )),
                          Text(_statusLabel(reservation.status),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _statusColor(reservation.status, colorScheme),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Item card
            itemAsync.when(
              data: (item) => Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context.push('/items/${reservation.itemId}'),
                  child: Row(
                    children: [
                      Container(
                        width: 100, height: 100,
                        color: colorScheme.surfaceContainerHighest,
                        child: item != null && item.photos.isNotEmpty
                            ? Image.network(item.photos.first, fit: BoxFit.cover)
                            : Icon(Icons.inventory_2_outlined,
                                size: 40, color: colorScheme.onSurfaceVariant),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(reservation.itemTitle,
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                '${(reservation.totalPrice / days).toStringAsFixed(2)} €/día',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
              loading: () => const Card(child: SizedBox(height: 100)),
              error: (e, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),

            // Details card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailRow(
                      icon: Icons.calendar_today,
                      label: 'Inicio',
                      value: DateFormat('EEEE dd MMMM yyyy', 'es')
                          .format(reservation.startDate),
                    ),
                    const Divider(height: 24),
                    _DetailRow(
                      icon: Icons.event,
                      label: 'Fin',
                      value: DateFormat('EEEE dd MMMM yyyy', 'es')
                          .format(reservation.endDate),
                    ),
                    const Divider(height: 24),
                    _DetailRow(
                      icon: Icons.timelapse,
                      label: 'Duración',
                      value: '$days día${days == 1 ? '' : 's'}',
                    ),
                    const Divider(height: 24),
                    _DetailRow(
                      icon: Icons.euro,
                      label: 'Precio total',
                      value: '${reservation.totalPrice.toStringAsFixed(2)} €',
                      bold: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Other user card
            otherUserAsync.when(
              data: (other) {
                if (other == null) return const SizedBox.shrink();
                return Card(
                  child: InkWell(
                    onTap: () => context.push('/profile/$otherUserId'),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: colorScheme.primaryContainer,
                            backgroundImage: other.photoUrl.isNotEmpty
                                ? NetworkImage(other.photoUrl)
                                : null,
                            child: other.photoUrl.isEmpty
                                ? Text(
                                    other.displayName.isNotEmpty
                                        ? other.displayName[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      color: colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(isOwner ? 'Inquilino' : 'Propietario',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant)),
                                Text(other.displayName,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right,
                              color: colorScheme.onSurfaceVariant),
                        ],
                      ),
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (e, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // Action buttons
            ..._actions(context, ref, isOwner: isOwner, isRenter: isRenter),
          ],
        ),
      ),
    );
  }

  List<Widget> _actions(BuildContext context, WidgetRef ref,
      {required bool isOwner, required bool isRenter}) {
    final widgets = <Widget>[];
    final status = reservation.status;

    // Pending: owner approves/rejects, renter cancels
    if (status == ReservationStatus.pending && isOwner) {
      widgets.addAll([
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _update(context, ref, ReservationStatus.rejected),
                icon: const Icon(Icons.close),
                label: const Text('Rechazar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  side: BorderSide(color: Theme.of(context).colorScheme.error),
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _update(context, ref, ReservationStatus.confirmed),
                icon: const Icon(Icons.check),
                label: const Text('Aprobar'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ),
          ],
        ),
      ]);
    }

    if (status == ReservationStatus.pending && isRenter) {
      widgets.add(OutlinedButton.icon(
        onPressed: () => _update(context, ref, ReservationStatus.cancelled),
        icon: const Icon(Icons.cancel_outlined),
        label: const Text('Cancelar reserva'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
        ),
      ));
    }

    // Confirmed: owner can complete at ANY time, renter can cancel
    if (status == ReservationStatus.confirmed && isOwner) {
      widgets.add(FilledButton.icon(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('¿Marcar como completada?'),
              content: const Text(
                  'Confirma que el alquiler ha terminado y el objeto fue devuelto. El inquilino podrá valorarte.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancelar')),
                FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Completar')),
              ],
            ),
          );
          if (confirmed == true && context.mounted) {
            await _update(context, ref, ReservationStatus.completed);
          }
        },
        icon: const Icon(Icons.check_circle_outline),
        label: const Text('Marcar como completada'),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
        ),
      ));
    }

    if (status == ReservationStatus.confirmed && isRenter) {
      widgets.add(OutlinedButton.icon(
        onPressed: () => _update(context, ref, ReservationStatus.cancelled),
        icon: const Icon(Icons.cancel_outlined),
        label: const Text('Cancelar reserva'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
        ),
      ));
    }

    // Completed + renter: rate owner
    if (status == ReservationStatus.completed && isRenter) {
      widgets.add(_RateRow(reservation: reservation));
    }

    // Insert spacing between widgets
    final spaced = <Widget>[];
    for (var i = 0; i < widgets.length; i++) {
      if (i > 0) spaced.add(const SizedBox(height: 12));
      spaced.add(widgets[i]);
    }
    return spaced;
  }

  Future<void> _update(BuildContext context, WidgetRef ref,
      ReservationStatus status) async {
    try {
      await ref
          .read(reservationRepositoryProvider)
          .updateStatus(reservation.id, status);
      ref.invalidate(reservationProvider);
      ref.invalidate(userReservationsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_statusUpdateMessage(status))),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String _statusUpdateMessage(ReservationStatus s) => switch (s) {
        ReservationStatus.confirmed => 'Reserva aprobada',
        ReservationStatus.rejected => 'Reserva rechazada',
        ReservationStatus.cancelled => 'Reserva cancelada',
        ReservationStatus.completed => 'Reserva marcada como completada',
        _ => 'Reserva actualizada',
      };

  String _statusLabel(ReservationStatus s) => switch (s) {
        ReservationStatus.pending => 'Pendiente de aprobación',
        ReservationStatus.confirmed => 'Confirmada',
        ReservationStatus.rejected => 'Rechazada',
        ReservationStatus.cancelled => 'Cancelada',
        ReservationStatus.completed => 'Completada',
      };

  IconData _statusIcon(ReservationStatus s) => switch (s) {
        ReservationStatus.pending => Icons.hourglass_empty,
        ReservationStatus.confirmed => Icons.check_circle_outline,
        ReservationStatus.rejected => Icons.cancel_outlined,
        ReservationStatus.cancelled => Icons.block,
        ReservationStatus.completed => Icons.task_alt,
      };

  Color _statusColor(ReservationStatus s, ColorScheme c) => switch (s) {
        ReservationStatus.pending => c.primary,
        ReservationStatus.confirmed => c.tertiary,
        ReservationStatus.rejected => c.error,
        ReservationStatus.cancelled => c.onSurfaceVariant,
        ReservationStatus.completed => c.secondary,
      };
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool bold;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 12),
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _RateRow extends ConsumerWidget {
  final Reservation reservation;
  const _RateRow({required this.reservation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasRated = ref.watch(hasRatedProvider((
      fromUserId: reservation.renterId,
      reservationId: reservation.id,
    )));
    final colorScheme = Theme.of(context).colorScheme;

    return hasRated.when(
      data: (already) {
        if (already) {
          return Card(
            color: colorScheme.primaryContainer.withAlpha(60),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Text('Ya has valorado al propietario',
                      style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          );
        }
        return FilledButton.icon(
          onPressed: () {
            context.push(
              '/rate/${reservation.id}?toUserId=${reservation.ownerId}&fromUserId=${reservation.renterId}',
            );
          },
          icon: const Icon(Icons.star_outline),
          label: const Text('Valorar al propietario'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const SizedBox.shrink(),
    );
  }
}
