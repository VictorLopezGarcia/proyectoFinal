import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/app_user.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/errors/app_exceptions.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthRepository({
    fb.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? fb.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Stream<AppUser?> get authStateChanges {
    return _auth.authStateChanges().map(_mapFirebaseUser);
  }

  @override
  Future<AppUser?> get currentUser async {
    return _mapFirebaseUser(_auth.currentUser);
  }

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _mapFirebaseUser(credential.user)!;
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthErrorMessage(e.code), code: e.code);
    }
  }

  @override
  Future<AppUser> registerWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(displayName);

      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(credential.user!.uid)
          .set({
        'displayName': displayName,
        'email': email,
        'photoUrl': '',
        'bio': '',
        'averageRating': 0.0,
        'totalRentals': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return AppUser(
        uid: credential.user!.uid,
        email: email,
        displayName: displayName,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthErrorMessage(e.code), code: e.code);
    }
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('Inicio de sesión cancelado', code: 'cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      // Create Firestore profile if first login
      final doc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        await _firestore
            .collection(FirebaseConstants.usersCollection)
            .doc(user.uid)
            .set({
          'displayName': user.displayName ?? '',
          'email': user.email ?? '',
          'photoUrl': user.photoURL ?? '',
          'bio': '',
          'averageRating': 0.0,
          'totalRentals': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return _mapFirebaseUser(user)!;
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthErrorMessage(e.code), code: e.code);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthErrorMessage(e.code), code: e.code);
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  AppUser? _mapFirebaseUser(fb.User? user) {
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  String _mapAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No existe una cuenta con este email';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este email';
      case 'weak-password':
        return 'La contraseña es demasiado débil';
      case 'invalid-email':
        return 'Email no válido';
      case 'too-many-requests':
        return 'Demasiados intentos. Inténtalo más tarde';
      default:
        return 'Error de autenticación';
    }
  }
}
