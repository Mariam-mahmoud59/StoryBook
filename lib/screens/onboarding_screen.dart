import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_colors.dart';

/// Data model for a single onboarding page.
class _OnboardingPage {
  final String imagePath;
  final String emoji;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;

  const _OnboardingPage({
    required this.imagePath,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _pages = <_OnboardingPage>[
    _OnboardingPage(
      imagePath: 'assets/images/onboarding_create.png',
      emoji: '✨',
      title: 'Create Magical Stories',
      subtitle:
          'Let your imagination soar! Write and illustrate your very own storybooks with our easy-to-use editor.',
      gradientColors: [Color(0xFFFFD6E8), Color(0xFFFFECF3), Color(0xFFFFF9F5)],
    ),
    _OnboardingPage(
      imagePath: 'assets/images/onboarding_illustrate.png',
      emoji: '🎨',
      title: 'Bring Stories to Life',
      subtitle:
          'Add beautiful images to every page. Upload your own drawings or photos to make your stories shine!',
      gradientColors: [Color(0xFFC0E5FF), Color(0xFFE4F3FF), Color(0xFFFFF9F5)],
    ),
    _OnboardingPage(
      imagePath: 'assets/images/onboarding_share.png',
      emoji: '📖',
      title: 'Your Personal Library',
      subtitle:
          'Build your collection of stories. Read, edit, and revisit your creations anytime, anywhere!',
      gradientColors: [Color(0xFFC2F5E9), Color(0xFFE5FFF7), Color(0xFFFFF9F5)],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/welcome');
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Page View ───────────────────────────────────────────────
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) =>
                _buildPage(_pages[index], index),
          ),

          // ── Skip Button (top-right) ────────────────────────────────
          if (_currentPage < _pages.length - 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 20,
              child: TextButton(
                onPressed: _completeOnboarding,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.mutedForeground,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms),

          // ── Bottom Controls ────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  28, 20, 28, MediaQuery.of(context).padding.bottom + 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.0),
                    Colors.white.withValues(alpha: 0.95),
                    Colors.white,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dot Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: _currentPage == i ? 28 : 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.primaryForeground,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        shadowColor:
                            AppColors.primary.withValues(alpha: 0.35),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Text(
                          _currentPage == _pages.length - 1
                              ? "Let's Go! 🚀"
                              : 'Next',
                          key: ValueKey(_currentPage),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page, int index) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: page.gradientColors,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // ── Illustration ─────────────────────────────────────
              Container(
                constraints: const BoxConstraints(maxHeight: 320, maxWidth: 320),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: page.gradientColors.first.withValues(alpha: 0.5),
                      blurRadius: 40,
                      spreadRadius: 5,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Image.asset(
                    page.imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 100.ms)
                  .slideY(begin: 0.15, curve: Curves.easeOut, duration: 500.ms)
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.0, 1.0),
                    duration: 500.ms,
                    curve: Curves.easeOut,
                  ),

              const SizedBox(height: 12),

              // ── Emoji accent ─────────────────────────────────────
              Text(
                page.emoji,
                style: const TextStyle(fontSize: 44),
              )
                  .animate()
                  .fadeIn(delay: 350.ms, duration: 400.ms)
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0),
                    curve: Curves.elasticOut,
                    duration: 600.ms,
                    delay: 350.ms,
                  ),

              const SizedBox(height: 12),

              // ── Title ────────────────────────────────────────────
              Text(
                page.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.foreground,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              )
                  .animate()
                  .fadeIn(delay: 250.ms, duration: 450.ms)
                  .slideY(begin: 0.3, curve: Curves.easeOut, duration: 450.ms),

              const SizedBox(height: 14),

              // ── Subtitle ─────────────────────────────────────────
              Text(
                page.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.mutedForeground,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 450.ms)
                  .slideY(begin: 0.3, curve: Curves.easeOut, duration: 450.ms),

              // Space for bottom controls
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
