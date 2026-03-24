import 'package:flutter_test/flutter_test.dart';
import 'package:rent_my_stuff/features/auth/domain/app_user.dart';

void main() {
  group('AppUser', () {
    test('two users with same uid are equal', () {
      const user1 = AppUser(uid: '123', email: 'a@b.com');
      const user2 = AppUser(uid: '123', email: 'a@b.com');
      expect(user1, equals(user2));
    });

    test('users with different uids are not equal', () {
      const user1 = AppUser(uid: '123', email: 'a@b.com');
      const user2 = AppUser(uid: '456', email: 'a@b.com');
      expect(user1, isNot(equals(user2)));
    });
  });
}
