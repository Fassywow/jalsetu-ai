import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/localization/localization_manager.dart';
import '../../../../config/di/injection.dart';
import '../../../detection/presentation/pages/home_page.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'registration_page.dart';

class OtpPage extends StatelessWidget {
  final String phoneNumber;
  final String verificationId;

  const OtpPage({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>(),
      child: _OtpForm(phoneNumber: phoneNumber, verificationId: verificationId),
    );
  }
}

class _OtpForm extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const _OtpForm({
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<_OtpForm> createState() => _OtpFormState();
}

class _OtpFormState extends State<_OtpForm> {
  final TextEditingController _otpController = TextEditingController();
  final LocalizationManager _loc = LocalizationManager();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _onVerify() {
    final otp = _otpController.text.trim();
    if (otp.length == 4) {
      // Assuming 4 digit OTP based on typical flows, or 6. Let's assume 4 or 6.
      // Message Central usually sends 4 or 6. Let's just check not empty.
      context.read<AuthBloc>().add(VerifyOtpEvent(
            widget.phoneNumber,
            otp,
            widget.verificationId,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE), // Ocean Mist
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthVerified) {
            if (state.isRegistered) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
                (route) => false,
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      RegistrationPage(phoneNumber: widget.phoneNumber),
                ),
              );
            }
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  IconButton(
                    icon:
                        const Icon(Icons.arrow_back_ios, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _loc.translate('otp_title'),
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(text: '${_loc.translate('otp_desc')} '),
                        TextSpan(
                          text: '+91 ${widget.phoneNumber}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Pinput
                  Center(
                    child: Pinput(
                      controller: _otpController,
                      length: 4,
                      defaultPinTheme: PinTheme(
                        width: 64,
                        height: 64,
                        textStyle: GoogleFonts.poppins(
                          fontSize: 24,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      focusedPinTheme: PinTheme(
                        width: 64,
                        height: 64,
                        textStyle: GoogleFonts.poppins(
                          fontSize: 24,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black87, width: 2),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                      ),
                      onCompleted: (pin) => _onVerify(),
                    ),
                  ),

                  const Spacer(),

                  // Floating Action Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: FloatingActionButton(
                        onPressed: state is AuthLoading ? null : _onVerify,
                        backgroundColor: Colors.black87,
                        elevation: 4,
                        shape: const CircleBorder(),
                        child: state is AuthLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Icon(Icons.arrow_forward_ios_rounded,
                                color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
