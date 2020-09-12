import 'package:safe_work_together/repository/abstract/abstract_repository.dart';
import 'package:safe_work_together/src/model/models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseUserRepository implements AuthUserRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseUserRepository({FirebaseAuth firebaseAuth, GoogleSignIn googleSignin})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignin ?? GoogleSignIn();

  //create user object based on FirebaseUser object
  Employee _userFromFirebaseUser(FirebaseUser user) {
    return user != null
        ? Employee(
            id: user.uid,
            employeeName: user.displayName,
            email: user.email,
            imageUrl: user.photoUrl,
            mobileNumber: user.phoneNumber)
        : null;
  }

  //auth change user stream
  Stream<Employee> get user {
    return _firebaseAuth.onAuthStateChanged.map(_userFromFirebaseUser);
  }

  @override
  Future<Employee> getUser() async {
    return _userFromFirebaseUser(await _firebaseAuth.currentUser());
  }

  @override
  Future<bool> isSignedIn() async {
    final currentUser = await _firebaseAuth.currentUser();
    return currentUser != null;
  }

  @override
  Future<void> signInWithCredentials(String email, String password) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signInWithMobileNumber(
      String phoneNumber,
      Duration timeOut,
      PhoneVerificationCompleted phoneVerificationSuccess,
      PhoneVerificationFailed phoneVerificationFailed,
      PhoneCodeSent phoneCodeSent,
      PhoneCodeAutoRetrievalTimeout autoRetrievalTimeout) async {
    _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: timeOut,
        verificationCompleted: (AuthCredential authCredential) {
          onVerificationCompleted(authCredential);
          phoneVerificationSuccess(authCredential);
        },
        verificationFailed: phoneVerificationFailed,
        codeSent: phoneCodeSent,
        codeAutoRetrievalTimeout: autoRetrievalTimeout);
  }

  Future<AuthResult> verifyOtp(
      String verificationId, String smsCode) async {
    AuthCredential authCredential = PhoneAuthProvider.getCredential(
        verificationId: verificationId, smsCode: smsCode);
    return   _firebaseAuth.signInWithCredential(authCredential);
  }

  @override
  Future signOut() async {
    try {
      Future.wait([
        _googleSignIn.signOut(),
        _firebaseAuth.signOut(),
      ]);
    } catch (e) {
      print(e);
    }
  }

  @override
  void signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      /*await _firebaseAuth.signInWithCredential(credential);
      FirebaseUser firebaseUser = await _firebaseAuth.currentUser();
      return _userFromFirebaseUser(firebaseUser);*/
      onVerificationCompleted(credential);
    } catch (e) {
      print(e);
    }
  }

  @override
  Future<void> signUp(String email, String password) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  void onVerificationCompleted(AuthCredential authCredential) async {
    await _firebaseAuth.signInWithCredential(authCredential);
    FirebaseUser firebaseUser = await _firebaseAuth.currentUser();
    _userFromFirebaseUser(firebaseUser);
  }
}
