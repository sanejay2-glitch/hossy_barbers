import 'package:firebase_auth/firebase_auth.dart';

class AdminAuthService {
  AdminAuthService(this._auth);

  final FirebaseAuth _auth;

  Stream<User?> get authChanges => _auth.authStateChanges();

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();
}
