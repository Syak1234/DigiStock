import 'package:product_inventory/features/auth/domain/entities/user.dart';

import 'package:product_inventory/core/error/failures.dart';
import 'package:product_inventory/core/utils/either.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> login(String email, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User?>> getSession();
  Future<Either<Failure, bool>> isLoggedIn();
}
