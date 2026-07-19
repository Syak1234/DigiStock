import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String email;
  final String token;
  final DateTime loginTime;

  const User({
    required this.email,
    required this.token,
    required this.loginTime,
  });

  @override
  List<Object?> get props => [email, token, loginTime];
}
