import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class SendOtpEvent extends AuthEvent {
  final String phoneNumber;
  const SendOtpEvent(this.phoneNumber);

  @override
  List<Object> get props => [phoneNumber];
}

class VerifyOtpEvent extends AuthEvent {
  final String phoneNumber;
  final String otp;
  final String verificationId;
  const VerifyOtpEvent(this.phoneNumber, this.otp, this.verificationId);

  @override
  List<Object> get props => [phoneNumber, otp, verificationId];
}

class RegisterUserEvent extends AuthEvent {
  final String phoneNumber;
  final String name;
  final int age;
  final int experience;
  final String location;

  const RegisterUserEvent({
    required this.phoneNumber,
    required this.name,
    required this.age,
    required this.experience,
    required this.location,
  });

  @override
  List<Object> get props => [phoneNumber, name, age, experience, location];
}

class CheckConnectivityEvent extends AuthEvent {}
