import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_my_stuff/core/constants/firebase_constants.dart';
import 'package:rent_my_stuff/features/profile/data/user_repository.dart';
import 'package:rent_my_stuff/features/profile/domain/app_user.dart';

class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;

  FirestoreUserRepository(this._firestore);

  @override
  Future<AppUser?> getUser(String userId) async {
    final doc = await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(userId)
        .get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc.id, doc.data()!);
  }

  @override
  Future<void> updateUser(AppUser user) async {
    await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(user.uid)
        .update(user.toFirestore());
  }

  @override
  Stream<AppUser?> userStream(String userId) {
    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists
            ? AppUser.fromFirestore(doc.id, doc.data()!)
            : null);
  }
}
