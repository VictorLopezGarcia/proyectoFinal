import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:rent_my_stuff/features/reservations/domain/reservation.dart';
import 'package:rent_my_stuff/features/reservations/presentation/reservation_providers.dart';
import 'package:rent_my_stuff/core/layout/responsive_container.dart';

class MyReservationsScreen extends ConsumerStatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  ConsumerState<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends ConsumerState<MyReservationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Debes iniciar sesión')),
      );
    }

    final reservations = ref.watch(userReservationsProvider(user.uid));

    return Scaffold(
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Alquilado'),
              Tab(text: 'Prestado'),
            ],
          ),
          Expanded(
            child: reservations.when(
              data: (allReservations) {
                final rented = allReservations
                    .where((r) => r.renterId == user.uid)
                    .toList();
                final lent = allReservations
                    .where((r) => r.ownerId == user.uid)
                    .toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _ReservationsList(reservations: rented, userRole: 'renter'),
                    _ReservationsList(reservations: lent, userRole: 'owner'),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReservationsList extends ConsumerWidget {
  final List<Reservation> reservations;
  final String userRole;

  const _ReservationsList({
    required this.reservations,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    if (reservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              'No tienes reservas',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: reservations.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final reservation = reservations[index];
        final isOwner = userRole == 'owner';
        final actionable = (isOwner &&
                reservation.status == ReservationStatus.pending) ||
            (isOwner && reservation.status == ReservationStatus.confirmed) ||
            (!isOwner && reservation.status == ReservationStatus.completed);

        return ResponsiveContainer(
          maxWidth: 800,
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => context.push('/reservations/${reservation.id}'),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reservation.itemTitle,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${DateFormat('dd/MM/yyyy').format(reservation.startDate)} - ${DateFormat('dd/MM/yyyy').format(reservation.endDate)}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${reservation.totalPrice.toStringAsFixed(2)} €',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        _buildStatusChip(context, reservation.status),
                      ],
                    ),
                    if (actionable) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.touch_app,
                              size: 14,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 6),
                          Text(
                            isOwner
                                ? (reservation.status == ReservationStatus.pending
                                    ? 'Toca para aprobar/rechazar'
                                    : 'Toca para gestionar')
                                : 'Toca para valorar',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(BuildContext context, ReservationStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    String label;
    Color color;

    switch (status) {
      case ReservationStatus.pending:
        color = colorScheme.primary;
        label = 'Pendiente';
        break;
      case ReservationStatus.confirmed:
        color = colorScheme.tertiary;
        label = 'Confirmada';
        break;
      case ReservationStatus.rejected:
        color = colorScheme.error;
        label = 'Rechazada';
        break;
      case ReservationStatus.cancelled:
        color = colorScheme.onSurfaceVariant;
        label = 'Cancelada';
        break;
      case ReservationStatus.completed:
        color = colorScheme.secondary;
        label = 'Completada';
        break;
    }

    return Chip(
      label: Text(label),
      backgroundColor: color.withAlpha(25),
      side: BorderSide(color: color.withAlpha(128)),
    );
  }
}

