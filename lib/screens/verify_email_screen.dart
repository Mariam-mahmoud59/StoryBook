import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_background.dart';

/// Screen shown after sign-up to remind the user to confirm their email.
///
/// Features:
/// - Animated mail icon
/// - "Check your inbox" message with the user's email
/// - Resend verification email button
/// - Back to Sign-In link
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _resendSuccess = false;

  Future<void> _resendEmail() async {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final email = args?['email'] as String?;

    if (email == null || email.isEmpty) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.resendVerificationEmail(email);

    if (mounted && success) {
      setState(() => _resendSuccess = true);
      // Reset after 4 seconds so they can resend again
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() => _resendSuccess = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final email = args?['email'] as String? ?? 'your email';
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: GradientBackground(
        variant: GradientVariant.main,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── Animated mail icon ─────────────────────────────────
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 30,
                        spreadRadius: 2,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('✉️', style: TextStyle(fontSize: 56)),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(
                      begin: const Offset(0.7, 0.7),
                      end: const Offset(1.0, 1.0),
                      duration: 600.ms,
                      curve: Curves.elasticOut,
                    )
                    .then()
                    .shimmer(duration: 1200.ms, color: Colors.white38),

                const SizedBox(height: 32),

                // ── Title ──────────────────────────────────────────────
                const Text(
                  'Check Your Inbox!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.foreground,
                    letterSpacing: -0.3,
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(
                      begin: 0.3,
                      curve: Curves.easeOut,
                    ),

                const SizedBox(height: 12),

                // ── Subtitle ───────────────────────────────────────────
                const Text(
                  'We sent a confirmation link to',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.mutedForeground,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                const SizedBox(height: 6),

                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

                const SizedBox(height: 8),

                const Text(
                  'Please click the link in the email to\nverify your account before signing in.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.mutedForeground,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

                const SizedBox(height: 36),

                // ── Resend button ──────────────────────────────────────
                GestureDetector(
                  onTap: authProvider.isLoading || _resendSuccess
                      ? null
                      : _resendEmail,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    decoration: BoxDecoration(
                      color: _resendSuccess
                          ? const Color(0xFF51CF66)
                          : AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (_resendSuccess
                                  ? const Color(0xFF51CF66)
                                  : AppColors.primary)
                              .withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (authProvider.isLoading)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        else
                          Icon(
                            _resendSuccess
                                ? Icons.check_rounded
                                : Icons.refresh_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        const SizedBox(width: 8),
                        Text(
                          _resendSuccess ? 'Email Sent!' : 'Resend Email',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms, duration: 400.ms).slideY(
                      begin: 0.2,
                      curve: Curves.easeOut,
                    ),

                // ── Error banner ───────────────────────────────────────
                if (authProvider.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    authProvider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.destructive,
                    ),
                  ),
                ],

                const Spacer(flex: 1),

                // ── Back to Sign In ────────────────────────────────────
                GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(
                      context, '/sign-in'),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back_rounded,
                            size: 16, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text(
                          'Back to Sign In',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 700.ms),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
