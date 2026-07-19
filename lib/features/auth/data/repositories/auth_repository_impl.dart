import 'package:product_inventory/features/auth/domain/entities/user.dart';
import 'package:product_inventory/features/auth/domain/repositories/auth_repository.dart';
import 'package:product_inventory/features/auth/data/datasources/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl(this.localDataSource);

  @override
  Future<void> login(String email, String password) async {
    // Simulate network delay for login
    await Future.delayed(const Duration(seconds: 1));
    
    final user = User(
      email: email,
      token: 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
      loginTime: DateTime.now(),
    );

    await localDataSource.cacheSession(user);
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearSession();
  }

  @override
  Future<User?> getSession() async {
    return localDataSource.getSession();
  }

  @override
  Future<bool> isLoggedIn() async {
    final session = await getSession();
    return session != null;
  }
}
