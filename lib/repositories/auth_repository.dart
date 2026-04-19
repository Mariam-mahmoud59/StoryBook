import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

export '../services/auth_service.dart' show AuthServiceException;

/// Repository that acts as an abstraction over the raw Supabase Auth API
/// to cleanly separate UI providers from the remote backend.
class AuthRepository {
  final SupabaseAuthService _authService;

  AuthRepository({SupabaseAuthService? authService})
      : _authService = authService ?? SupabaseAuthService();

  /// Exposes the real-time stream of auth state changes.
  Stream<AuthState> get authStateChanges => _authService.authStateChanges;

  /// Retrieves the currently authenticated user.
  User? getCurrentUser() => _authService.getCurrentUser();

  /// Signs in a user with email and password.
  Future<AuthResponse> signInWithEmail(String email, String password) {
    return _authService.signInWithEmail(email, password);
  }

  /// Signs up a new user with email and password.
  Future<AuthResponse> signUpWithEmail(String email, String password) {
    return _authService.signUpWithEmail(email, password);
  }

  /// Triggers the Google OAuth flow.
  Future<bool> signInWithGoogle() {
    return _authService.signInWithGoogle();
  }

  /// Clears the current user's session.
  Future<void> signOut() {
    return _authService.signOut();
  }
}
