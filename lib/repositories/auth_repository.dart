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

  /// Retrieves the locally cached user (NOT server-validated).
  User? getCurrentUser() => _authService.getCurrentUser();

  /// Retrieves the locally cached session.
  Session? getCurrentSession() => _authService.getCurrentSession();

  /// Validates the session against the Supabase server.
  ///
  /// This is the **only reliable** auth check — catches deleted/banned users.
  Future<UserResponse> getUser() => _authService.getUser();

  /// Signs in a user with email and password.
  Future<AuthResponse> signInWithEmail(String email, String password) {
    return _authService.signInWithEmail(email, password);
  }

  /// Signs up a new user with email, password, and optional display name.
  Future<AuthResponse> signUpWithEmail(
    String email,
    String password, {
    String? name,
  }) {
    return _authService.signUpWithEmail(email, password, name: name);
  }

  /// Triggers the Google OAuth flow.
  Future<bool> signInWithGoogle() {
    return _authService.signInWithGoogle();
  }

  /// Updates current user metadata.
  Future<UserResponse> updateProfile(Map<String, dynamic> data) {
    return _authService.updateProfile(data);
  }

  /// Clears ALL user sessions (local + remote, including OAuth).
  Future<void> signOut() {
    return _authService.signOut();
  }
}
