import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audio_service/audio_service.dart';

import '../../../app/theme.dart';
import '../../auth/application/auth_controller.dart';
import '../../player/application/audio_handler_provider.dart';
import '../../player/presentation/player_screen.dart';

const Color _mint = AppColors.primary;

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'Log out?',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'You can continue browsing SoundSphere as a guest.',
          style: GoogleFonts.inter(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel', style: TextStyle(color: _mint)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Log out', style: TextStyle(color: _mint)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(authControllerProvider.notifier).logout();

      if (!context.mounted) return;

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not log out. Please try again.')),
      );
    }
  }

  void _showAccountSettings(
    BuildContext context,
    WidgetRef ref,
    bool isAuthenticated,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Account Settings',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.verified_user_outlined,
                    color: _mint,
                  ),
                  title: const Text(
                    'Account status',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    isAuthenticated ? 'Logged in' : 'Browsing as a guest',
                    style: const TextStyle(color: Colors.white60),
                  ),
                ),
                const Divider(color: Colors.white12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.music_note_rounded, color: _mint),
                  title: const Text(
                    'Music playback',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Control playback from your player screen.',
                    style: TextStyle(color: Colors.white60),
                  ),
                ),
                if (isAuthenticated) ...[
                  const Divider(color: Colors.white12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.logout_rounded,
                      color: Colors.redAccent,
                    ),
                    title: const Text(
                      'Log out',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _logout(context, ref);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final isAuthenticated = auth.status == AuthStatus.authenticated;

    final displayName = isAuthenticated
        ? (auth.user?.displayName ?? 'User')
        : 'Guest User';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // TOP BAR
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 12, 16),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Back',
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back, color: _mint),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'My Profile',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Account settings',
                      onPressed: () =>
                          _showAccountSettings(context, ref, isAuthenticated),
                      icon: const Icon(Icons.settings_outlined, color: _mint),
                    ),
                  ],
                ),
              ),
            ),

            // PROFILE HEADER
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: _mint, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 49,
                        backgroundColor: const Color(0xFFE8ECEB),
                        child: Text(
                          displayName.isNotEmpty
                              ? displayName[0].toUpperCase()
                              : 'U',
                          style: GoogleFonts.inter(
                            color: AppColors.cardBackground,
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      displayName,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isAuthenticated
                          ? 'Your music, your world.'
                          : 'Log in to access your account.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    if (!isAuthenticated) ...[
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Back to Home to log in'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _mint,
                          side: const BorderSide(color: _mint),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // YOUR MUSIC
            SliverToBoxAdapter(child: _sectionTitle('Your Music')),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 26),
                child: _buildNowPlaying(context, ref),
              ),
            ),

            // ACCOUNT SETTINGS
            SliverToBoxAdapter(child: _sectionTitle('Account')),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 30),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppGradients.card,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: const Icon(
                      Icons.settings_outlined,
                      color: _mint,
                      size: 28,
                    ),
                    title: Text(
                      'Account Settings',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      isAuthenticated
                          ? 'Manage your account'
                          : 'You are browsing as a guest',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.white70,
                    ),
                    onTap: () =>
                        _showAccountSettings(context, ref, isAuthenticated),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // LIVE NOW PLAYING CARD
  Widget _buildNowPlaying(BuildContext context, WidgetRef ref) {
    final handler = ref.read(audioHandlerProvider);

    return StreamBuilder<MediaItem?>(
      stream: handler.mediaItem,
      builder: (context, snapshot) {
        final item = snapshot.data;

        if (item == null) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppGradients.card,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                const Icon(Icons.music_off_rounded, color: _mint, size: 38),
                const SizedBox(height: 12),
                Text(
                  'Nothing playing right now',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Choose a track from Home or Search to start listening.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            gradient: AppGradients.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _mint.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.graphic_eq_rounded, color: _mint, size: 19),
                  const SizedBox(width: 8),
                  Text(
                    'NOW PLAYING',
                    style: GoogleFonts.inter(
                      color: _mint,
                      fontSize: 11,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.circle, color: _mint, size: 7),
                  const SizedBox(width: 5),
                  const Text(
                    'LIVE',
                    style: TextStyle(color: Colors.white60, fontSize: 10),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: item.artUri != null
                        ? Image.network(
                            item.artUri.toString(),
                            width: 66,
                            height: 66,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _musicPlaceholder(),
                          )
                        : _musicPlaceholder(),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item.artist ?? 'Unknown Artist',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 7),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const PlayerScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Open full player  →',
                            style: TextStyle(
                              color: _mint,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  StreamBuilder<PlaybackState>(
                    stream: handler.playbackState,
                    builder: (context, playbackSnapshot) {
                      final isPlaying = playbackSnapshot.data?.playing ?? false;

                      return Container(
                        decoration: const BoxDecoration(
                          color: _mint,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () async {
                            if (isPlaying) {
                              await handler.pause();
                            } else {
                              await handler.play();
                            }
                          },
                          icon: Icon(
                            isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: AppColors.background,
                            size: 27,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _musicPlaceholder() {
    return Container(
      width: 66,
      height: 66,
      color: AppColors.background,
      child: const Icon(Icons.music_note_rounded, color: _mint, size: 30),
    );
  }

  Widget _sectionTitle(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 34,
              height: 1.05,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.2,
              color: _mint,
            ),
          ),
        ),
      ),
    );
  }
}
