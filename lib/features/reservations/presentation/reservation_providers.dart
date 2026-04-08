import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rent_my_stuff/features/reservations/data/firestore_reservation_repository.dart';
import 'package:rent_my_stuff/features/reservations/data/reservation_repository.dart';
import 'package:rent_my_stuff/features/reservations/domain/reservation.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  return FirestoreReservationRepository(ref.watch(firestoreProvider));
});

final userReservationsProvider = FutureProvider.family<List<Reservation>, String>((ref, userId) async {
  return ref.watch(reservationRepositoryProvider).getUserReservations(userId);
});

final itemReservationsProvider = FutureProvider.family<List<Reservation>, String>((ref, itemId) async {
  return ref.watch(reservationRepositoryProvider).getItemReservations(itemId);
});

final reservationProvider = FutureProvider.family<Reservation?, String>((ref, id) async {
  return ref.watch(reservationRepositoryProvider).getReservation(id);
});
