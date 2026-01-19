import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc({required this.repository}) : super(AuthInitial()) {
    on<CheckConnectivityEvent>(_onCheckConnectivity);
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<RegisterUserEvent>(_onRegisterUser);
  }

  Future<void> _onCheckConnectivity(
    CheckConnectivityEvent event,
    Emitter<AuthState> emit,
  ) async {
    final hasInternet = await repository.checkConnectivity();
    if (!hasInternet) {
      emit(NoInternetConnection());
    }
  }

  Future<void> _onSendOtp(
    SendOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final hasInternet = await repository.checkConnectivity();
      if (!hasInternet) {
        emit(NoInternetConnection());
        return;
      }

      final verificationId = await repository.sendOtp(event.phoneNumber);
      emit(OtpSent(verificationId, event.phoneNumber));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final isVerified = await repository.verifyOtp(
        event.phoneNumber,
        event.otp,
        event.verificationId,
      );

      if (isVerified) {
        final isRegistered =
            await repository.isUserRegistered(event.phoneNumber);
        if (isRegistered) {
          await repository.login(event.phoneNumber);
          await repository.clearVerifiedPhone(); // Clear if already registered
        } else {
          await repository
              .saveVerifiedPhone(event.phoneNumber); // Save if not registered
        }
        emit(AuthVerified(event.phoneNumber, isRegistered));
      } else {
        emit(const AuthError("Invalid OTP"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegisterUser(
    RegisterUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await repository.registerUser(
        phoneNumber: event.phoneNumber,
        name: event.name,
        age: event.age,
        experience: event.experience,
        location: event.location,
      );
      await repository.login(event.phoneNumber);
      await repository.clearVerifiedPhone();
      emit(AuthAuthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
