import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/gradient_background.dart';
import '../widgets/kid_button.dart';

/// Update Password screen — shown after the user clicks the password reset
/// link from their email. Allows them to set a new password.
class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _passwordError;
  String? _confirmError;
  bool _success = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ── Update password ─────────────────────────────────────────────────────

  Future<void> _handleUpdatePassword() async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    // Client-side validation
    final passwordError = AuthProvider.validatePassword(password);
    final confirmError =
        AuthProvider.validateConfirmPassword(password, confirm);

    if (passwordError != null || confirmError != null) {
      setState(() {
        _passwordError = passwordError;
        _confirmError = confirmError;
      });
      return;
    }

    setState(() {
      _passwordError = null;
      _confirmError = null;
      _isLoading = true;
    });

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: password),
      );

      if (mounted) {
        setState(() => _success = true);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password updated successfully!'),
            backgroundColor: Color(0xFF51CF66),
          ),
        );

        // Navigate to sign-in after a short delay
        Future.delayed(const Duration(milliseconds: 2000), () {
          if (mounted) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/sign-in', (route) => false);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _passwordError = 'Failed to update password. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: GradientBackground(
        variant: GradientVariant.purple,
        child: SafeArea(
          child: Column(
            children: [
              // ── Header bar ────────────────────────────────────────
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Row(
                  children: [
                    SizedBox(width: 40), // Spacer for centering
                    Expanded(
                      child: Text(
                        'New Password',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.foreground,
                        ),
                      ),
                    ),
                    SizedBox(width: 40), // Spacer for centering
                  ],
                ),
              ),

              // ── Content ───────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                  child: _success
                      ? _buildSuccessState()
                      : _buildFormState(authProvider),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Form state ──────────────────────────────────────────────────────────

  Widget _buildFormState(AuthProvider authProvider) {
    final strength = AuthProvider.passwordStrength(_passwordController.text);

    return Column(
      children: [
        // Icon
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 24,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Text('🔒', style: TextStyle(fontSize: 48)),
          ),
        ).animate().fadeIn(duration: 500.ms).scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.0, 1.0),
              duration: 500.ms,
              curve: Curves.elasticOut,
            ),

        const SizedBox(height: 24),

        const Text(
          'Set New Password',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppColors.foreground,
            letterSpacing: -0.3,
          ),
        ).animate().fadeIn(delay: 150.ms, duration: 400.ms).slideY(
              begin: 0.3,
              curve: Curves.easeOut,
            ),

        const SizedBox(height: 8),

        const Text(
          'Enter your new password below.\nMake sure it\'s strong and secure!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.mutedForeground,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ).animate().fadeIn(delay: 250.ms, duration: 400.ms),

        const SizedBox(height: 36),

        // ── Error banner ──────────────────────────────────────────
        if (_passwordError != null && _passwordError!.startsWith('Failed'))
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.destructive.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.destructive.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.destructive, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _passwordError!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.destructive,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

        // ── New Password field ────────────────────────────────────
        AuthTextField(
          label: 'New Password',
          hint: 'Enter your new password',
          icon: Icons.lock_outline_rounded,
          iconColor: AppColors.primary,
          controller: _passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          errorText: _passwordError != null && !_passwordError!.startsWith('Failed') ? _passwordError : null,
          onChanged: (_) {
            if (_passwordError != null) {
              setState(() => _passwordError = null);
            }
            setState(() {}); // Rebuild for strength indicator
          },
          suffixWidget: GestureDetector(
            onTap: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            child: Icon(
              _obscurePassword
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: AppColors.mutedForeground,
              size: 20,
            ),
          ),
        ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(
              begin: 0.2,
              curve: Curves.easeOut,
            ),

        // ── Password strength indicator ───────────────────────────
        if (_passwordController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 8, right: 4),
            child: Row(
              children: [
                _strengthSegment(strength >= 1,
                    strength == 1 ? Colors.red : Colors.red),
                const SizedBox(width: 6),
                _strengthSegment(strength >= 2, Colors.amber),
                const SizedBox(width: 6),
                _strengthSegment(strength >= 3, const Color(0xFF51CF66)),
                const SizedBox(width: 10),
                Text(
                  strength <= 1
                      ? 'Weak'
                      : strength == 2
                          ? 'Medium'
                          : 'Strong',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: strength <= 1
                        ? Colors.red
                        : strength == 2
                            ? Colors.amber.shade700
                            : const Color(0xFF51CF66),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

        const SizedBox(height: 16),

        // ── Confirm Password field ────────────────────────────────
        AuthTextField(
          label: 'Confirm Password',
          hint: 'Re-enter your new password',
          icon: Icons.lock_outline_rounded,
          iconColor: const Color(0xFF51CF66),
          controller: _confirmController,
          obscureText: _obscureConfirm,
          textInputAction: TextInputAction.done,
          errorText: _confirmError,
          onChanged: (_) {
            if (_confirmError != null) {
              setState(() => _confirmError = null);
            }
          },
          suffixWidget: GestureDetector(
            onTap: () =>
                setState(() => _obscureConfirm = !_obscureConfirm),
            child: Icon(
              _obscureConfirm
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: AppColors.mutedForeground,
              size: 20,
            ),
          ),
        ).animate().fadeIn(delay: 380.ms, duration: 400.ms).slideY(
              begin: 0.2,
              curve: Curves.easeOut,
            ),

        const SizedBox(height: 28),

        // ── Update button ─────────────────────────────────────────
        KidButton(
          label: 'Update Password',
          icon: Icons.check_circle_outline_rounded,
          isLoading: _isLoading,
          variant: KidButtonVariant.primary,
          onPressed: _handleUpdatePassword,
        ).animate().fadeIn(delay: 440.ms, duration: 400.ms).slideY(
              begin: 0.2,
              curve: Curves.easeOut,
            ),
      ],
    );
  }

  // ── Strength bar segment ────────────────────────────────────────────────

  Widget _strengthSegment(bool active, Color color) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 5,
        decoration: BoxDecoration(
          color: active ? color : AppColors.border,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  // ── Success state ───────────────────────────────────────────────────────

  Widget _buildSuccessState() {
    return Column(
      children: [
        const SizedBox(height: 40),

        // Success icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF51CF66).withValues(alpha: 0.3),
                blurRadius: 24,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Text('✅', style: TextStyle(fontSize: 52)),
          ),
        ).animate().fadeIn(duration: 500.ms).scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1.0, 1.0),
              duration: 600.ms,
              curve: Curves.elasticOut,
            ),

        const SizedBox(height: 28),

        const Text(
          'Password Updated!',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: AppColors.foreground,
            letterSpacing: -0.3,
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(
              begin: 0.3,
              curve: Curves.easeOut,
            ),

        const SizedBox(height: 10),

        const Text(
          'Your password has been changed successfully.\nRedirecting you to sign in...', // updated
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.mutedForeground,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ).animate().fadeIn(delay: 350.ms, duration: 400.ms),

        const SizedBox(height: 32),

        const SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ).animate().fadeIn(delay: 500.ms),
      ],
    );
  }
}
