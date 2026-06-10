import 'package:booking_slot_app/bloc/auth/auth_state.dart';
import 'package:booking_slot_app/data/services/api/auth_service.dart';
import 'package:booking_slot_app/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Handles sign in / sign up / sign out via Supabase Auth
class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit(this._authService) : super(AuthInitial());

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      final res = await _authService.signIn(email.trim(), password);
      if (res.user != null) {
        emit(AuthSuccess(res.user!.id));
      } else {
        emit(const AuthError('Sign in failed. Please try again.'));
      }
    } catch (e) {
      Log.e('signIn: $e');
      emit(AuthError(_parseError(e)));
    }
  }

  Future<void> signUp(String email, String password) async {
    emit(AuthLoading());
    try {
      final res = await _authService.signUp(email.trim(), password);
      if (res.user == null) {
        emit(const AuthError('Sign up failed. Please try again.'));
        return;
      }

      // If session exists, email confirmation is disabled — user is signed in directly
      if (res.session != null) {
        emit(AuthSuccess(res.user!.id));
        return;
      }

      // Session is null → email confirmation is enabled in Supabase.
      // Try signing in immediately (works if project has confirmation disabled at DB level).
      try {
        final signInRes = await _authService.signIn(email.trim(), password);
        if (signInRes.user != null) {
          emit(AuthSuccess(signInRes.user!.id));
        } else {
          emit(const AuthError(
            'Account created! Check your email to confirm, then sign in.',
          ));
        }
      } catch (_) {
        emit(const AuthError(
          'Account created! Check your email to confirm your account, then sign in.',
        ));
      }
    } catch (e) {
      Log.e('signUp: $e');
      emit(AuthError(_parseError(e)));
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    emit(AuthInitial());
  }

  String _parseError(dynamic e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('invalid login credentials')) return 'Invalid email or password.';
    if (msg.contains('already registered')) return 'Email is already registered. Try signing in.';
    if (msg.contains('user already registered')) return 'Email is already registered. Try signing in.';
    if (msg.contains('password should be at least')) return 'Password must be at least 6 characters.';
    if (msg.contains('email not confirmed')) return 'Please confirm your email first, then sign in.';
    if (msg.contains('network')) return 'Network error. Check your connection.';
    return 'Something went wrong. Please try again.';
  }
}
