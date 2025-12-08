import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class OtpSent extends AuthState {
  final String verificationId;
  final String phoneNumber;
  const OtpSent(this.verificationId, this.phoneNumber);

  @override
  List<Object> get props => [verificationId, phoneNumber];
}

class AuthVerified extends AuthState {
  final String phoneNumber;
  final bool isRegistered;
  const AuthVerified(this.phoneNumber, this.isRegistered);

  @override
  List<Object> get props => [phoneNumber, isRegistered];
}

class AuthAuthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

class NoInternetConnection extends AuthState {}
