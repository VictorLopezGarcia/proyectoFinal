import 'package:flutter_test/flutter_test.dart';
import 'package:rent_my_stuff/features/profile/domain/app_user.dart';

void main() {
  group('AppUser (profile) domain model', () {
    test('default values for optional fields', () {
      final user = AppUser(
        uid: 'u1',
        displayName: 'María',
        email: 'maria@demo.com',
      );

      expect(user.photoUrl, '');
      expect(user.bio, '');
      expect(user.averageRating, 0.0);
      expect(user.totalRentals, 0);
    });

    test('fromFirestore parses optional fields with defaults', () {
      final user = AppUser.fromFirestore('u1', {
        'displayName': 'Carlos',
        'email': 'carlos@demo.com',
      });

      expect(user.uid, 'u1');
      expect(user.displayName, 'Carlos');
      expect(user.photoUrl, '');
      expect(user.averageRating, 0.0);
      expect(user.totalRentals, 0);
    });

    test('toFirestore serializes all fields', () {
      final user = AppUser(
        uid: 'u1',
        displayName: 'Ana',
        email: 'ana@demo.com',
        bio: 'Hola',
        averageRating: 4.5,
        totalRentals: 7,
      );
      final map = user.toFirestore();

      expect(map['displayName'], 'Ana');
      expect(map['email'], 'ana@demo.com');
      expect(map['bio'], 'Hola');
      expect(map['averageRating'], 4.5);
      expect(map['totalRentals'], 7);
    });

    test('copyWith preserves uid and updates fields', () {
      final user = AppUser(
        uid: 'u1',
        displayName: 'Ana',
        email: 'ana@demo.com',
      );
      final updated = user.copyWith(
        displayName: 'Ana López',
        bio: 'Editado',
      );

      expect(updated.uid, 'u1');
      expect(updated.displayName, 'Ana López');
      expect(updated.bio, 'Editado');
      expect(updated.email, 'ana@demo.com');
    });
  });
}
