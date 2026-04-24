import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/auth_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Auth Status Enum — single source of truth for navigation decisions
// ─────────────────────────────────────────────────────────────────────────────

/// Represents the three possible authentication states in the app.
///
/// All navigation decisions flow from this enum:
/// - [unauthenticated] → Sign-In screen
/// - [pendingVerification] → Verify-Email screen
/// - [recoveringPassword] → Update-Password screen
/// - [authenticated] → Home screen
enum AuthStatus {
  unauthenticated,
  pendingVerification,
  recoveringPassword,
  authenticated,
}

// ─────────────────────────────────────────────────────────────────────────────
// Auth Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Manages authentication state for the Storybook app.
///
/// Wraps [AuthRepository] and exposes reactive state via
/// [ChangeNotifier] for the Provider pattern used throughout the project.
///
/// Key design decisions:
/// - Uses server-side `getUser()` to validate sessions (no ghost users).
/// - Tracks [AuthStatus] as the single source of truth.
/// - Guards against unintended OAuth auto-login during email flows.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  // ── State ──────────────────────────────────────────────────────────────
  bool _isLoading = false;
  String? _errorMessage;
  User? _user;
  AuthStatus _status = AuthStatus.unauthenticated;
  StreamSubscription<AuthState>? _authSubscription;

  /// Guard flag: when true, auth state listener ignores `signedIn` events.
  /// This prevents OAuth session-restore from hijacking an email login flow.
  bool _isManualLoginInProgress = false;

  // ── Getters ────────────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get user => _user;
  AuthStatus get status => _status;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // ── Constructor ────────────────────────────────────────────────────────

  AuthProvider() {
    _listenToAuthChanges();
  }

  /// Listens to Supabase auth state changes.
  ///
  /// **Important:** This listener ONLY updates the local user cache.
  /// It does NOT trigger navigation — that's handled explicitly by
  /// each screen or by [verifySession].
  ///
  /// The `_isManualLoginInProgress` flag prevents this listener from
  /// auto-updating state while an email/password login is in progress.
  void _listenToAuthChanges() {
    _authSubscription =
        _authRepository.authStateChanges.listen((authState) async {
      final event = authState.event;
      final session = authState.session;

      if (event == AuthChangeEvent.tokenRefreshed) {
        return;
      }

      if (_isManualLoginInProgress) {
        return;
      }

      if (event == AuthChangeEvent.signedOut) {
        _user = null;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return;
      }

      // Handle Password Recovery with HIGHEST priority
      if (event == AuthChangeEvent.passwordRecovery) {
        _status = AuthStatus.recoveringPassword;
        notifyListeners();
        return; // Don't let signedIn overwrite this
      }

      if (event == AuthChangeEvent.signedIn) {
        // If we are already in recovery mode, don't overwrite it with a generic 'signedIn' event
        if (_status == AuthStatus.recoveringPassword) return;

        final signedInUser = session?.user;
        if (signedInUser == null) return;

        _user = signedInUser;
        _status = _isEmailVerified(signedInUser)
            ? AuthStatus.authenticated
            : AuthStatus.pendingVerification;
        notifyListeners();
      }
    });
  }

  // ── Session Verification (server-side) ─────────────────────────────────

  /// Validates the current session against the Supabase server.
  ///
  /// This is the **only reliable** way to check if a user is still valid
  /// (e.g., not deleted from the dashboard). Should be called on app start.
  ///
  /// Updates [status] based on the result:
  /// - Valid + email verified → [AuthStatus.authenticated]
  /// - Valid + email NOT verified → [AuthStatus.pendingVerification]
  /// - Invalid/expired/deleted → signs out and sets [AuthStatus.unauthenticated]
  Future<AuthStatus> verifySession() async {
    _setLoading(true);

    final localSession = _authRepository.getCurrentSession();
    if (localSession == null) {
      _user = null;
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      return _status;
    }

    try {
      final response = await _authRepository.getUser();
      final serverUser = response.user;

      if (serverUser == null) {
        await _forceLogout();
        _setLoading(false);
        return _status;
      }

      _user = serverUser;

      if (_isEmailVerified(serverUser)) {
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.pendingVerification;
      }

      _setLoading(false);
      return _status;
    } on AuthException {
      // Real auth failure
      await _forceLogout();
      _setLoading(false);
      return _status;
    } catch (e) {
      // Network/server failure: do NOT force logout blindly
      _setLoading(false);
      return _status;
    }
  }

  // ── Sign In with Email ─────────────────────────────────────────────────

  /// Validates inputs then signs in with email/password via Supabase.
  ///
  /// Returns the resulting [AuthStatus]:
  /// - [AuthStatus.authenticated] → user is verified, navigate to home
  /// - [AuthStatus.pendingVerification] → email not confirmed
  /// - [AuthStatus.unauthenticated] → login failed (check [errorMessage])
  Future<AuthStatus> signInWithEmail(String email, String password) async {
    // Client-side validation
    final emailError = validateEmail(email);
    if (emailError != null) {
      _errorMessage = emailError;
      notifyListeners();
      return AuthStatus.unauthenticated;
    }
    if (password.isEmpty) {
      _errorMessage = 'Please enter your password';
      notifyListeners();
      return AuthStatus.unauthenticated;
    }

    _setLoading(true);
    _clearError();
    _isManualLoginInProgress = true;

    try {
      final response =
          await _authRepository.signInWithEmail(email.trim(), password);
      final signedInUser = response.user;

      if (signedInUser == null) {
        _errorMessage = 'Sign-in failed. Please try again.';
        _status = AuthStatus.unauthenticated;
        _setLoading(false);
        _isManualLoginInProgress = false;
        return AuthStatus.unauthenticated;
      }

      _user = signedInUser;

      if (_isEmailVerified(signedInUser)) {
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.pendingVerification;
      }

      _setLoading(false);
      _isManualLoginInProgress = false;
      return _status;
    } on AuthServiceException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      _isManualLoginInProgress = false;
      return AuthStatus.unauthenticated;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      _isManualLoginInProgress = false;
      return AuthStatus.unauthenticated;
    }
  }

  // ── Sign Up with Email ─────────────────────────────────────────────────

  /// Validates inputs then creates a new account via Supabase.
  ///
  /// On success, returns [AuthStatus.pendingVerification] — the user
  /// must confirm their email before they can access the app.
  ///
  /// Does NOT set the user as authenticated.
  Future<AuthStatus> signUpWithEmail(
    String name,
    String email,
    String password,
  ) async {
    // Client-side validation
    final nameError = validateName(name);
    if (nameError != null) {
      _errorMessage = nameError;
      notifyListeners();
      return AuthStatus.unauthenticated;
    }
    final emailError = validateEmail(email);
    if (emailError != null) {
      _errorMessage = emailError;
      notifyListeners();
      return AuthStatus.unauthenticated;
    }
    final passwordError = validatePassword(password);
    if (passwordError != null) {
      _errorMessage = passwordError;
      notifyListeners();
      return AuthStatus.unauthenticated;
    }

    _setLoading(true);
    _clearError();
    _isManualLoginInProgress = true;

    try {
      await _authRepository.signUpWithEmail(
        email.trim(),
        password,
        name: name.trim(),
      );

      // Important: never keep the user authenticated immediately after sign-up
      await _authRepository.signOut();

      _user = null;
      _status = AuthStatus.pendingVerification;
      _setLoading(false);
      _isManualLoginInProgress = false;
      return AuthStatus.pendingVerification;
    } on AuthServiceException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      _isManualLoginInProgress = false;
      return AuthStatus.unauthenticated;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      _isManualLoginInProgress = false;
      return AuthStatus.unauthenticated;
    }
  }

  // ── Google Sign In ─────────────────────────────────────────────────────

  /// Triggers Google OAuth flow via Supabase.
  ///
  /// Navigation is handled by the auth state listener (since OAuth
  /// returns via deep link, the listener is the correct mechanism).
  ///
  /// Returns `true` if the OAuth flow was initiated successfully.
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();
    // Do NOT set _isManualLoginInProgress — OAuth needs the listener.

    try {
      final success = await _authRepository.signInWithGoogle();
      _setLoading(false);
      return success;
    } on AuthServiceException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Google sign-in failed. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  // ── Reset Password ─────────────────────────────────────────────────────

  /// Sends a password reset email via Supabase.
  ///
  /// Returns `true` if the email was sent successfully.
  Future<bool> resetPassword(String email) async {
    final emailError = validateEmail(email);
    if (emailError != null) {
      _errorMessage = emailError;
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: 'io.supabase.storybook://reset-password',
      );
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _errorMessage = 'Password reset failed: ${e.message}';
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  // ── Resend Verification Email ──────────────────────────────────────────

  /// Resends the email confirmation link for the given [email].
  Future<bool> resendVerificationEmail(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: email.trim(),
      );
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _errorMessage = 'Could not resend email: ${e.message}';
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  // ── Sign Out ───────────────────────────────────────────────────────────

  /// Signs out the current user and clears ALL sessions (local + remote).
  ///
  /// Uses global scope to ensure OAuth sessions are also revoked.

  /// Updates profile metadata (e.g. display name and avatar URL).
  ///
  /// Returns `true` on success. On failure, [errorMessage] is populated.
  Future<bool> updateProfile({
    required String name,
    String? avatarUrl,
  }) async {
    final nameError = validateName(name);
    if (nameError != null) {
      _errorMessage = nameError;
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final payload = <String, dynamic>{'name': name.trim()};
      if (avatarUrl != null) {
        payload['avatar_url'] = avatarUrl.trim();
      }

      final response = await _authRepository.updateProfile(payload);
      _user = response.user ?? _user;
      if (_user == null) {
        _status = AuthStatus.unauthenticated;
      } else {
        _status = _isEmailVerified(_user!)
            ? AuthStatus.authenticated
            : AuthStatus.pendingVerification;
      }
      _setLoading(false);
      return true;
    } on AuthServiceException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Could not update profile. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);

    try {
      await _authRepository.signOut();
    } on AuthServiceException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Sign-out failed. Please try again.';
    }

    _user = null;
    _status = AuthStatus.unauthenticated;
    _setLoading(false);
  }

  // ── Error Management ───────────────────────────────────────────────────

  /// Clears the current error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Validation Helpers (static, reusable) ──────────────────────────────

  /// Returns an error string if [name] is invalid, or `null` if valid.
  static String? validateName(String name) {
    if (name.trim().isEmpty) return 'Please enter your name';
    if (name.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  /// Returns an error string if [email] is invalid, or `null` if valid.
  static String? validateEmail(String email) {
    if (email.trim().isEmpty) return 'Please enter your email';
    final regex = RegExp(r'^[\w\.\-\+]+@[\w\-]+\.\w{2,}$');
    if (!regex.hasMatch(email.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Returns an error string if [password] is invalid, or `null` if valid.
  static String? validatePassword(String password) {
    if (password.isEmpty) return 'Please enter a password';
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[a-zA-Z]').hasMatch(password)) {
      return 'Password must contain at least one letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  /// Returns an error string if [confirm] doesn't match [password].
  static String? validateConfirmPassword(String password, String confirm) {
    if (confirm.isEmpty) return 'Please confirm your password';
    if (password != confirm) return 'Passwords do not match';
    return null;
  }

  /// Returns a password strength level (0–3) for UI indicator.
  /// 0 = empty, 1 = weak, 2 = medium, 3 = strong
  static int passwordStrength(String password) {
    if (password.isEmpty) return 0;
    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[a-zA-Z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password)) {
      score++;
    }
    if (password.length >= 12 &&
        RegExp(r'[!@#\$%\^\&\*\(\)_\+\-=\[\]\{\};:,\.\<\>\?]')
            .hasMatch(password)) {
      score++;
    }
    return score;
  }

  // ── Internal helpers ───────────────────────────────────────────────────

  /// Checks whether a user's email has been confirmed.
  bool _isEmailVerified(User user) {
    return user.emailConfirmedAt != null;
  }

  /// Forces a full logout and sets status to unauthenticated.
  Future<void> _forceLogout() async {
    try {
      await _authRepository.signOut();
    } catch (_) {
      // Best-effort — even if sign-out fails, clear local state.
    }
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
