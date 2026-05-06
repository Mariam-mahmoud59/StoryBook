import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/stories_provider.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_background.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _avatarController;
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(
      text: user?.userMetadata?['name'] ?? user?.email?.split('@')[0] ?? '',
    );
    _avatarController = TextEditingController(
      text: user?.userMetadata?['avatar_url'] ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (!mounted || picked == null) return;

    setState(() => _isUploadingAvatar = true);
    try {
      final storage = SupabaseStorageService();
      final url = await storage.uploadProfilePicture(
        userId: user.id,
        imageFile: File(picked.path),
      );
      _avatarController.text = url;
      setState(() {});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo uploaded. Tap Save Changes.')),
      );
    } on StorageServiceException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Could not upload photo. Please try again.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final stories = context.watch<StoriesProvider>().stories;
    final user = auth.user;

    final displayName = _nameController.text.trim().isEmpty
        ? 'Story Creator'
        : _nameController.text.trim();
    final email = user?.email ?? '';
    final avatarUrl = _avatarController.text.trim();

    return Scaffold(
      body: GradientBackground(
        variant: GradientVariant.purple,
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
              children: [
                Row(
                  children: [
                    _iconBtn(
                      Icons.arrow_back_rounded,
                      Colors.white.withOpacity(0.8),
                      AppColors.foreground,
                      () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'My Profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.foreground,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 46),
                  ],
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
                const SizedBox(height: 28),
                _profileHeaderCard(
                  displayName: displayName,
                  email: email,
                  avatarUrl: avatarUrl,
                  storyCount: stories.length,
                  onPickAvatar:
                      _isUploadingAvatar ? null : _pickAndUploadAvatar,
                  isUploadingAvatar: _isUploadingAvatar,
                )
                    .animate()
                    .fadeIn(delay: 100.ms)
                    .scale(begin: const Offset(0.95, 0.95)),
                const SizedBox(height: 24),
                _sectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 16,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'PROFILE DETAILS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.mutedForeground,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _label('Display Name'),
                      const SizedBox(height: 8),
                      _input(
                        controller: _nameController,
                        hintText: 'Your name',
                        validator: (value) =>
                            AuthProvider.validateName(value ?? ''),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 20),
                      _label('Avatar URL (Optional)'),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed:
                              _isUploadingAvatar ? null : _pickAndUploadAvatar,
                          icon: _isUploadingAvatar
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.photo_library_rounded),
                          label: Text(
                            _isUploadingAvatar
                                ? 'Uploading...'
                                : 'Choose From Gallery',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.foreground,
                            side: BorderSide(
                                color: AppColors.border.withOpacity(0.5)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _input(
                        controller: _avatarController,
                        hintText: 'https://example.com/avatar.png',
                        keyboardType: TextInputType.url,
                        onChanged: (_) => setState(() {}),
                        validator: (value) {
                          final text = (value ?? '').trim();
                          if (text.isEmpty) return null;
                          if (Uri.tryParse(text)?.hasAbsolutePath != true ||
                              !(text.startsWith('http://') ||
                                  text.startsWith('https://'))) {
                            return 'Enter a valid URL starting with http:// or https://';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: auth.isLoading || _isUploadingAvatar
                              ? null
                              : () async {
                                  HapticFeedback.mediumImpact();
                                  final formOk =
                                      _formKey.currentState?.validate() ??
                                          false;
                                  if (!formOk) return;

                                  final ok = await context
                                      .read<AuthProvider>()
                                      .updateProfile(
                                        name: _nameController.text.trim(),
                                        avatarUrl: _avatarController.text
                                                .trim()
                                                .isEmpty
                                            ? null
                                            : _avatarController.text.trim(),
                                      );
                                  if (!context.mounted) return;

                                  final messenger =
                                      ScaffoldMessenger.of(context);
                                  if (ok) {
                                    messenger.showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Profile updated successfully')),
                                    );
                                  } else {
                                    messenger.showSnackBar(
                                      SnackBar(
                                          content: Text(context
                                                  .read<AuthProvider>()
                                                  .errorMessage ??
                                              'Could not update profile')),
                                    );
                                  }
                                },
                          icon: auth.isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5, color: Colors.white),
                                )
                              : const Icon(Icons.check_circle_rounded,
                                  size: 20),
                          label: Text(
                              auth.isLoading
                                  ? 'Saving...'
                                  : _isUploadingAvatar
                                      ? 'Uploading photo...'
                                      : 'Save Changes',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w800)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 8,
                            shadowColor: AppColors.primary.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05),
                const SizedBox(height: 20),
                _sectionCard(
                  child: Column(
                    children: [
                      _tile(
                        icon: Icons.settings_rounded,
                        title: 'Open Settings',
                        subtitle: 'Manage app preferences and stories',
                        onTap: () => Navigator.pushNamed(context, '/settings'),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(
                            height: 1,
                            color: AppColors.border.withOpacity(0.3),
                            indent: 48),
                      ),
                      _tile(
                        icon: Icons.logout_rounded,
                        title: 'Sign Out',
                        subtitle: 'Log out from this account',
                        iconColor: AppColors.destructive,
                        onTap: () async {
                          HapticFeedback.heavyImpact();
                          // Clear local stories before signing out to prevent
                          // data leaking to the next user who logs in.
                          await context.read<StoriesProvider>().clearLocalData();
                          await context.read<AuthProvider>().signOut();
                          if (!context.mounted) return;
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/sign-in', (route) => false);
                        },
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileHeaderCard({
    required String displayName,
    required String email,
    required String avatarUrl,
    required int storyCount,
    required VoidCallback? onPickAvatar,
    required bool isUploadingAvatar,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            blurRadius: 0,
            offset: const Offset(0, 0),
            spreadRadius: -2,
          ),
        ],
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Row(
        children: [
          Hero(
            tag: 'user_avatar',
            child: GestureDetector(
              onTap: onPickAvatar,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.2), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.muted,
                      backgroundImage: _isHttpUrl(avatarUrl)
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: _isHttpUrl(avatarUrl)
                          ? null
                          : const Icon(Icons.person_rounded,
                              color: AppColors.foreground, size: 32),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: isUploadingAvatar
                            ? const Padding(
                                padding: EdgeInsets.all(5),
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(
                                Icons.camera_alt_rounded,
                                size: 13,
                                color: AppColors.primary,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.foreground,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.mutedForeground.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_stories_rounded,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        '$storyCount Stories Created',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: child,
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        color: AppColors.mutedForeground,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      style: const TextStyle(
          fontSize: 16,
          color: AppColors.foreground,
          fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
            color: AppColors.mutedForeground.withOpacity(0.5),
            fontSize: 15,
            fontWeight: FontWeight.w500),
        filled: true,
        fillColor: AppColors.input.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide:
              BorderSide(color: AppColors.border.withOpacity(0.3), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide:
              BorderSide(color: AppColors.border.withOpacity(0.3), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.foreground,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: AppColors.mutedForeground.withOpacity(0.8),
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded,
          color: AppColors.mutedForeground.withOpacity(0.5)),
    );
  }

  Widget _iconBtn(IconData icon, Color bg, Color fg, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: fg, size: 22),
      ),
    );
  }

  bool _isHttpUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }
}
