abstract class AuthRepository {
  Future<String> sendOtp(String phoneNumber);
  Future<bool> verifyOtp(String phoneNumber, String otp, String verificationId);
  Future<void> registerUser({
    required String phoneNumber,
    required String name,
    required int age,
    required int experience,
    required String location,
  });
  Future<bool> checkConnectivity();
  Future<bool> isUserRegistered(String phoneNumber);
  Future<void> login(String phoneNumber);
  Future<void> logout();
  Future<String?> getLoggedInUser();
  Future<void> saveVerifiedPhone(String phoneNumber);
  Future<String?> getVerifiedPhone();
  Future<void> clearVerifiedPhone();
}
