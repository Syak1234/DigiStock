import 'package:product_inventory/features/auth/domain/entities/user.dart';
import 'package:product_inventory/features/auth/domain/repositories/auth_repository.dart';
import 'package:product_inventory/features/auth/data/datasources/auth_local_data_source.dart';

import 'package:product_inventory/core/error/exceptions.dart';
import 'package:product_inventory/core/error/failures.dart';
import 'package:product_inventory/core/utils/either.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, void>> login(String email, String password) async {
    try {
      // Simulate network delay for login
      await Future.delayed(const Duration(seconds: 1));
      
      final user = User(
        email: email,
        token: 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
        loginTime: DateTime.now(),
      );

      await localDataSource.cacheSession(user);
      return const Right(null);
    } on AppException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearSession();
      return const Right(null);
    } on AppException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Failed to logout: $e'));
    }
  }

  @override
  Future<Either<Failure, User?>> getSession() async {
    try {
      final user = await localDataSource.getSession();
      return Right(user);
    } on AppException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to retrieve session: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final session = await localDataSource.getSession();
      return Right(session != null);
    } on AppException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to check login status: $e'));
    }
  }
}
