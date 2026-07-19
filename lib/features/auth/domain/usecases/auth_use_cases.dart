import 'package:product_inventory/features/auth/domain/entities/user.dart';
import 'package:product_inventory/features/auth/domain/repositories/auth_repository.dart';

import 'package:product_inventory/core/error/failures.dart';
import 'package:product_inventory/core/utils/either.dart';

class AuthUseCases {
  final AuthRepository repository;

  AuthUseCases(this.repository);

  Future<Either<Failure, void>> login(String email, String password) {
    return repository.login(email, password);
  }

  Future<Either<Failure, void>> logout() {
    return repository.logout();
  }

  Future<Either<Failure, User?>> getSession() {
    return repository.getSession();
  }

  Future<Either<Failure, bool>> isLoggedIn() {
    return repository.isLoggedIn();
  }
}
