import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_my_stuff/core/constants/firebase_constants.dart';
import 'package:rent_my_stuff/features/reservations/data/reservation_repository.dart';
import 'package:rent_my_stuff/features/reservations/domain/reservation.dart';

class FirestoreReservationRepository implements ReservationRepository {
  final FirebaseFirestore _firestore;

  FirestoreReservationRepository(this._firestore);

  @override
  Future<String> createReservation(Reservation reservation) async {
    final docRef = await _firestore
        .collection(FirebaseConstants.reservationsCollection)
        .add(reservation.toFirestore());
    return docRef.id;
  }

  @override
  Future<void> updateReservation(String id, Reservation reservation) async {
    await _firestore
        .collection(FirebaseConstants.reservationsCollection)
        .doc(id)
        .update(reservation.toFirestore()..['updatedAt'] = FieldValue.serverTimestamp());
  }

  @override
  Future<Reservation?> getReservation(String id) async {
    final doc = await _firestore
        .collection(FirebaseConstants.reservationsCollection)
        .doc(id)
        .get();
    if (!doc.exists) return null;
    return Reservation.fromFirestore(doc);
  }

  @override
  Future<List<Reservation>> getUserReservations(String userId) async {
    final query = await _firestore
        .collection(FirebaseConstants.reservationsCollection)
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    final renterQuery = await _firestore
        .collection(FirebaseConstants.reservationsCollection)
        .where('renterId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    final ownerReservations = query.docs.map((doc) => Reservation.fromFirestore(doc)).toList();
    final renterReservations = renterQuery.docs.map((doc) => Reservation.fromFirestore(doc)).toList();

    final all = [...ownerReservations, ...renterReservations];
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all;
  }

  @override
  Future<List<Reservation>> getItemReservations(String itemId) async {
    final query = await _firestore
        .collection(FirebaseConstants.reservationsCollection)
        .where('itemId', isEqualTo: itemId)
        .orderBy('startDate')
        .get();

    return query.docs.map((doc) => Reservation.fromFirestore(doc)).toList();
  }

  @override
  Future<bool> checkOverlap(String itemId, DateTime startDate, DateTime endDate) async {
    final reservations = await getItemReservations(itemId);
    final activeReservations = reservations
        .where((r) => r.status == ReservationStatus.confirmed || r.status == ReservationStatus.pending);

    for (final r in activeReservations) {
      if (startDate.isBefore(r.endDate) && endDate.isAfter(r.startDate)) {
        return true;
      }
    }
    return false;
  }
}
