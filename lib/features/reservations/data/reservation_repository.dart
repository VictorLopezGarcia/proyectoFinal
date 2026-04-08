import 'package:rent_my_stuff/features/reservations/domain/reservation.dart';

abstract class ReservationRepository {
  Future<String> createReservation(Reservation reservation);
  Future<void> updateReservation(String id, Reservation reservation);
  Future<Reservation?> getReservation(String id);
  Future<List<Reservation>> getUserReservations(String userId);
  Future<List<Reservation>> getItemReservations(String itemId);
  Future<bool> checkOverlap(String itemId, DateTime startDate, DateTime endDate);
}
