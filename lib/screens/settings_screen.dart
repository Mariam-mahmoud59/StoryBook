import '../providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/stories_provider.dart';
import '../services/sync_engine_service.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_background.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isSyncingNow = false;

  Widget _settingRow({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        color: AppColors.card,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  Icon(icon, size: 18, color: iconColor ?? AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.foreground,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.mutedForeground),
          ],
        ),
      ),
    );
  }

  Future<void> _syncNow() async {
    setState(() => _isSyncingNow = true);
    final result = await context.read<SyncEngineService>().syncPendingActions();
    if (!mounted) return;
    setState(() => _isSyncingNow = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Sync complete: ${result.synced} synced, ${result.failed} failed',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoriesProvider>();
    final stories = provider.stories;
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.user;
    final userName = currentUser?.userMetadata?['name'] ??
        currentUser?.email?.split('@')[0] ??
        'Story Creator';
    final userEmail = currentUser?.email ?? '';
    final favoriteCount = stories.where((s) => s.isFavorite).length;

    return Scaffold(
      body: GradientBackground(
        variant: GradientVariant.purple,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: AppColors.foreground),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Settings',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.foreground,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Profile card
                    GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/profile'),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.muted,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Center(
                                  child: Text('📚',
                                      style: TextStyle(fontSize: 30)),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.foreground,
                                      ),
                                    ),
                                    if (userEmail.isNotEmpty)
                                      Text(
                                        userEmail,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.mutedForeground,
                                        ),
                                      ),
                                    Text(
                                      '${stories.length} ${stories.length == 1 ? "story" : "stories"} created',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.mutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded,
                                  color: AppColors.mutedForeground),
                            ],
                          ),
                        )),

                    const SizedBox(height: 16),
                    const _SectionLabel(text: 'Quick Actions'),
                    const SizedBox(height: 8),

                    _settingsGroup([
                      _settingRow(
                        icon: Icons.auto_fix_high_rounded,
                        title: 'Create Story',
                        subtitle: 'Start a brand new adventure',
                        onTap: () =>
                            Navigator.pushNamed(context, '/editor/new'),
                      ),
                      const Divider(
                          height: 1, color: AppColors.border, indent: 64),
                      _settingRow(
                        icon: Icons.person_rounded,
                        title: 'Manage Profile',
                        subtitle: 'Edit your name and avatar',
                        onTap: () => Navigator.pushNamed(context, '/profile'),
                      ),
                    ]),

                    const SizedBox(height: 16),
                    const _SectionLabel(text: 'Stories'),
                    const SizedBox(height: 8),

                    _settingsGroup([
                      _settingRow(
                        icon: Icons.menu_book_rounded,
                        title: 'My Stories',
                        subtitle: '${stories.length} total stories',
                        onTap: () => Navigator.pushNamed(context, '/stories'),
                      ),
                      const Divider(
                          height: 1, color: AppColors.border, indent: 64),
                      _settingRow(
                        icon: Icons.star_rounded,
                        title: 'Favorites',
                        subtitle: '$favoriteCount starred',
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/stories',
                          arguments: {'filter': 'favorites'},
                        ),
                        iconColor: AppColors.warning,
                      ),
                    ]),

                    const SizedBox(height: 16),
                    const _SectionLabel(text: 'Sync'),
                    const SizedBox(height: 8),

                    _settingsGroup([
                      FutureBuilder<int>(
                        future:
                            context.read<SyncEngineService>().getPendingCount(),
                        builder: (context, snapshot) {
                          final pending = snapshot.data ?? 0;
                          return _settingRow(
                            icon: Icons.sync_rounded,
                            title: _isSyncingNow ? 'Syncing...' : 'Sync Now',
                            subtitle: pending == 0
                                ? 'Everything is up to date'
                                : '$pending pending change${pending == 1 ? '' : 's'}',
                            onTap: _isSyncingNow ? null : _syncNow,
                            iconColor: AppColors.secondaryForeground,
                          );
                        },
                      ),
                      const Divider(
                          height: 1, color: AppColors.border, indent: 64),
                      _settingRow(
                        icon: Icons.delete_sweep_rounded,
                        title: 'Clear Sync Queue',
                        subtitle: 'Remove stuck/failed sync entries',
                        iconColor: AppColors.warning,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              title: const Text('Clear Sync Queue?'),
                              content: const Text(
                                  'This removes all pending sync entries. '
                                  'Your local stories remain intact, but '
                                  'un-synced changes will be lost.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    final engine =
                                        context.read<SyncEngineService>();
                                    final cleared =
                                        await engine.clearAllSyncEntries();
                                    if (!context.mounted) return;
                                    setState(() {});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Cleared $cleared sync entries'),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                      foregroundColor: AppColors.warning),
                                  child: const Text('Clear'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ]),

                    const SizedBox(height: 16),
                    const _SectionLabel(text: 'About'),
                    const SizedBox(height: 8),

                    _settingsGroup([
                      _settingRow(
                        icon: Icons.info_outline_rounded,
                        title: 'App Version',
                        subtitle: '1.0.0',
                        iconColor: AppColors.gradientPurple,
                      ),
                      const Divider(
                          height: 1, color: AppColors.border, indent: 64),
                      _settingRow(
                        icon: Icons.favorite_rounded,
                        title: 'Made with love',
                        subtitle: 'For young storytellers everywhere',
                        iconColor: AppColors.primary,
                      ),
                    ]),

                    const SizedBox(height: 16),

                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            title: const Text('Clear All Stories'),
                            content: const Text(
                                'This will delete all your stories forever. Are you sure?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  HapticFeedback.heavyImpact();
                                  context
                                      .read<StoriesProvider>()
                                      .clearAllStories();
                                },
                                style: TextButton.styleFrom(
                                    foregroundColor: AppColors.destructive),
                                child: const Text('Delete All'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE5EA),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete_outline_rounded,
                                color: AppColors.destructive, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Clear All Stories',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.destructive,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    GestureDetector(
                      onTap: () async {
                        HapticFeedback.heavyImpact();
                        // Clear local stories before signing out to prevent
                        // data leaking to the next user who logs in.
                        await context.read<StoriesProvider>().clearLocalData();
                        await context.read<AuthProvider>().signOut();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/sign-in', (route) => false);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout_rounded,
                                color: AppColors.primary, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Sign Out',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(children: children),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.mutedForeground,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
