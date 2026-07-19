import 'package:product_inventory/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<void> login(String email, String password);
  Future<void> logout();
  Future<User?> getSession();
  Future<bool> isLoggedIn();
}
