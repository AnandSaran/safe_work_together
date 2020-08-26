import 'package:safe_work_together/src/model/models.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthUserRepository {
  void signInWithGoogle();

  Future<void> signInWithCredentials(String email, String password);

  Future<void> signInWithMobileNumber(
      String phoneNumber,
      Duration timeOut,
      PhoneVerificationCompleted phoneVerificationSuccess,
      PhoneVerificationFailed phoneVerificationFailed,
      PhoneCodeSent phoneCodeSent,
      PhoneCodeAutoRetrievalTimeout autoRetrievalTimeout);

  Future<void> signUp(String email, String password);

  Future signOut();

  Future<bool> isSignedIn();

  Future<Employee> getUser();
}
