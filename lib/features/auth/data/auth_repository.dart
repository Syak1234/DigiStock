import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  static const String _sessionKey = 'auth_session';

  Future<void> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Create a dummy JSON session
    final sessionData = {
      'email': email,
      'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
      'loginTime': DateTime.now().toIso8601String(),
    };

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(sessionData));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  Future<Map<String, dynamic>?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionString = prefs.getString(_sessionKey);
    
    if (sessionString != null) {
      try {
        return jsonDecode(sessionString) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final session = await getSession();
    return session != null;
  }
}
