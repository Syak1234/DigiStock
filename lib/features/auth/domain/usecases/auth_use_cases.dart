import 'package:product_inventory/features/auth/domain/entities/user.dart';
import 'package:product_inventory/features/auth/domain/repositories/auth_repository.dart';

class AuthUseCases {
  final AuthRepository repository;

  AuthUseCases(this.repository);

  Future<void> login(String email, String password) {
    return repository.login(email, password);
  }

  Future<void> logout() {
    return repository.logout();
  }

  Future<User?> getSession() {
    return repository.getSession();
  }

  Future<bool> isLoggedIn() {
    return repository.isLoggedIn();
  }
}
