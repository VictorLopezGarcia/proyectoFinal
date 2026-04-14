import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rent_my_stuff/features/reservations/domain/reservation.dart';
import 'package:rent_my_stuff/features/reservations/presentation/reservation_providers.dart';

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
      appBar: AppBar(
        title: const Text('Mis Reservas'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Alquilado'),
            Tab(text: 'Prestado'),
          ],
        ),
      ),
      body: reservations.when(
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
    );
  }
}

class _ReservationsList extends StatelessWidget {
  final List<Reservation> reservations;
  final String userRole;

  const _ReservationsList({
    required this.reservations,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    if (reservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text('No tienes reservas'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        final reservation = reservations[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(reservation.itemTitle),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${DateFormat('dd/MM/yyyy').format(reservation.startDate)} - ${DateFormat('dd/MM/yyyy').format(reservation.endDate)}',
                ),
                Text(
                  '${reservation.totalPrice.toStringAsFixed(2)} €',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            trailing: _buildStatusChip(reservation.status),
            onTap: () {
              // TODO: navigate to reservation detail
            },
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(ReservationStatus status) {
    Color color;
    String label;

    switch (status) {
      case ReservationStatus.pending:
        color = Colors.orange;
        label = 'Pendiente';
        break;
      case ReservationStatus.confirmed:
        color = Colors.green;
        label = 'Confirmada';
        break;
      case ReservationStatus.rejected:
        color = Colors.red;
        label = 'Rechazada';
        break;
      case ReservationStatus.cancelled:
        color = Colors.grey;
        label = 'Cancelada';
        break;
      case ReservationStatus.completed:
        color = Colors.blue;
        label = 'Completada';
        break;
    }

    return Chip(
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.2),
      side: BorderSide(color: color),
    );
  }
}
