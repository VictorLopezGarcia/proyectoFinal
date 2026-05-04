import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firebase_constants.dart';
import '../../../core/services/compute_service.dart';
import '../domain/rating.dart';

class FirestoreRatingRepository {
  final FirebaseFirestore _firestore;

  FirestoreRatingRepository(this._firestore);

  Future<void> addRating(Rating rating) async {
    await _firestore
        .collection(FirebaseConstants.ratingsCollection)
        .add(rating.toFirestore());

    // Recalcular averageRating del usuario usando compute() (Isolate)
    await _updateUserAverageRating(rating.toUserId);
  }

  Future<void> _updateUserAverageRating(String userId) async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.ratingsCollection)
        .where('toUserId', isEqualTo: userId)
        .get();

    final scores = snapshot.docs
        .map((doc) => (doc.data()['score'] as num).toDouble())
        .toList();

    // Usar compute() para calcular stats en un Isolate
    final stats = await ComputeService.calculateRatingStats(scores);

    await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(userId)
        .update({
      'averageRating': stats['avg'] ?? 0.0,
      'totalRatings': stats['count']?.toInt() ?? 0,
    });
  }

  Stream<List<Rating>> watchRatingsForUser(String userId) {
    return _firestore
        .collection(FirebaseConstants.ratingsCollection)
        .where('toUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Rating.fromFirestore(doc)).toList());
  }

  Future<bool> hasRated(String fromUserId, String reservationId) async {
    final query = await _firestore
        .collection(FirebaseConstants.ratingsCollection)
        .where('fromUserId', isEqualTo: fromUserId)
        .where('reservationId', isEqualTo: reservationId)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }
}
