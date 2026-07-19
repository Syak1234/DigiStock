import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:product_inventory/features/auth/domain/entities/user.dart';

class AuthLocalDataSource {
  static const String _sessionKey = 'auth_session';

  Future<void> cacheSession(User user) async {
    final sessionData = {
      'email': user.email,
      'token': user.token,
      'loginTime': user.loginTime.toIso8601String(),
    };

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(sessionData));
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  Future<User?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionString = prefs.getString(_sessionKey);
    
    if (sessionString != null) {
      try {
        final data = jsonDecode(sessionString) as Map<String, dynamic>;
        return User(
          email: data['email'] as String,
          token: data['token'] as String,
          loginTime: DateTime.parse(data['loginTime'] as String),
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
