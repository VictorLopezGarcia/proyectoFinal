import 'package:rent_my_stuff/features/profile/domain/app_user.dart';

abstract class UserRepository {
  Future<AppUser?> getUser(String userId);
  Future<void> updateUser(AppUser user);
  Stream<AppUser?> userStream(String userId);
}
