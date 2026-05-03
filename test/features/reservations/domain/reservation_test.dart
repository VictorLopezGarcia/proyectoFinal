import 'package:flutter_test/flutter_test.dart';
import 'package:rent_my_stuff/features/reservations/domain/reservation.dart';

void main() {
  group('Reservation domain model', () {
    Reservation buildReservation({
      DateTime? start,
      DateTime? end,
      ReservationStatus status = ReservationStatus.pending,
    }) {
      return Reservation(
        id: 'res_01',
        itemId: 'item_01',
        itemTitle: 'Taladro',
        ownerId: 'user_owner',
        renterId: 'user_renter',
        startDate: start ?? DateTime(2026, 4, 1),
        endDate: end ?? DateTime(2026, 4, 5),
        totalPrice: 32.0,
        status: status,
        createdAt: DateTime(2026, 3, 25),
      );
    }

    test('copyWith updates only specified fields', () {
      final reservation = buildReservation();
      final updated = reservation.copyWith(
        status: ReservationStatus.confirmed,
        totalPrice: 40.0,
      );

      expect(updated.status, ReservationStatus.confirmed);
      expect(updated.totalPrice, 40.0);
      expect(updated.id, reservation.id);
      expect(updated.itemId, reservation.itemId);
    });

    test('toFirestore serializes all required fields', () {
      final reservation = buildReservation();
      final map = reservation.toFirestore();

      expect(map['itemId'], 'item_01');
      expect(map['itemTitle'], 'Taladro');
      expect(map['ownerId'], 'user_owner');
      expect(map['renterId'], 'user_renter');
      expect(map['totalPrice'], 32.0);
      expect(map['status'], 'pending');
    });

    test('overlapsWith detects overlapping reservations', () {
      final a = buildReservation(
        start: DateTime(2026, 4, 1),
        end: DateTime(2026, 4, 5),
      );
      final b = buildReservation(
        start: DateTime(2026, 4, 3),
        end: DateTime(2026, 4, 7),
      );

      expect(a.overlapsWith(b), isTrue);
      expect(b.overlapsWith(a), isTrue);
    });

    test('overlapsWith returns false for non-overlapping reservations', () {
      final a = buildReservation(
        start: DateTime(2026, 4, 1),
        end: DateTime(2026, 4, 5),
      );
      final b = buildReservation(
        start: DateTime(2026, 4, 10),
        end: DateTime(2026, 4, 15),
      );

      expect(a.overlapsWith(b), isFalse);
    });

    test('ReservationStatus has 5 expected values', () {
      expect(ReservationStatus.values.length, 5);
      expect(ReservationStatus.values, contains(ReservationStatus.pending));
      expect(ReservationStatus.values, contains(ReservationStatus.confirmed));
      expect(ReservationStatus.values, contains(ReservationStatus.rejected));
      expect(ReservationStatus.values, contains(ReservationStatus.cancelled));
      expect(ReservationStatus.values, contains(ReservationStatus.completed));
    });
  });
}
