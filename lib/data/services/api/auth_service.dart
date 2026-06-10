import 'package:supabase_flutter/supabase_flutter.dart';

// Wraps Supabase auth — sign in, sign up, sign out, current user
class AuthService {
  final _auth = Supabase.instance.client.auth;

  Future<AuthResponse> signIn(String email, String password) {
    return _auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp(String email, String password) {
    return _auth.signUp(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  User? get currentUser => _auth.currentUser;

  bool get isSignedIn => currentUser != null;
}
