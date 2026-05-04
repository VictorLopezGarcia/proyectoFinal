import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/firestore_rating_repository.dart';
import '../domain/rating.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final ratingRepositoryProvider = Provider<FirestoreRatingRepository>((ref) {
  return FirestoreRatingRepository(ref.watch(firestoreProvider));
});

final userRatingsProvider = StreamProvider.family<List<Rating>, String>((ref, userId) {
  return ref.watch(ratingRepositoryProvider).watchRatingsForUser(userId);
});

final hasRatedProvider = FutureProvider.family<bool, ({String fromUserId, String reservationId})>((ref, params) async {
  return ref.watch(ratingRepositoryProvider).hasRated(params.fromUserId, params.reservationId);
});
