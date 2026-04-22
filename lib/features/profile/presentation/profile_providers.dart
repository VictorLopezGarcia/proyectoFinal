import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rent_my_stuff/features/profile/data/firestore_user_repository.dart';
import 'package:rent_my_stuff/features/profile/data/user_repository.dart';
import 'package:rent_my_stuff/features/profile/domain/app_user.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return FirestoreUserRepository(ref.watch(firestoreProvider));
});

final currentUserProvider = StreamProvider.family<AppUser?, String>((ref, userId) {
  return ref.watch(userRepositoryProvider).userStream(userId);
});
