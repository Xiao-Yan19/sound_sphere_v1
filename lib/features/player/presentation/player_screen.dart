import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme.dart';
import '../../auth/application/auth_controller.dart';

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

      // Return to the Home screen, which remains available to guests.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not log out. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final isAuthenticated = auth.status == AuthStatus.authenticated;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ---------- top bar ----------
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
                      tooltip: 'Log out',
                      onPressed: isAuthenticated
                          ? () => _logout(context, ref)
                          : null,
                      icon: const Icon(Icons.logout_rounded, color: _mint),
                    ),
                  ],
                ),
              ),
            ),

            // ---------- avatar + name ----------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 26),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: _mint, width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 49,
                        backgroundColor: Color(0xFFE8ECEB),
                        child: Icon(
                          Icons.person,
                          size: 58,
                          color: Color(0xFF7B8584),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      isAuthenticated
                          ? (auth.user?.displayName ?? 'User')
                          : 'Guest User',
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
                        onPressed: () {
                          Navigator.of(context).pop();
                          // The Home header contains the Log in button.
                        },
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

            // ---------- Your Music ----------
            SliverToBoxAdapter(child: _sectionTitle('Your Music')),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 26),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppGradients.card,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      _stat(Icons.favorite, '0', 'Liked Songs'),
                      _stat(Icons.queue_music, '5', 'Playlists'),
                      _stat(Icons.people, '4', 'Connections'),
                      _stat(Icons.history, '7', 'Recently Played'),
                    ],
                  ),
                ),
              ),
            ),

            // ---------- Recent Songs ----------
            SliverToBoxAdapter(child: _sectionTitle('Recent Songs')),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _songTile('Ocean Eyes', 'Artist Name'),
                  _songTile('Midnight City', 'Artist Name'),
                  _songTile('Golden Hour', 'Artist Name'),
                ]),
              ),
            ),

            // ---------- Account Settings ----------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 30),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppGradients.card,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.settings_outlined,
                        color: _mint,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Account Settings',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white70),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Same big mint heading style as Home's section titles.
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

  Widget _stat(IconData icon, String count, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: _mint, size: 25),
          const SizedBox(height: 6),
          Text(
            count,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  /// Same row design as Home's "Popular Picks" (title first, artist below).
  Widget _songTile(String title, String artist) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppGradients.card,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            child: Icon(Icons.music_note, color: AppColors.cardBackground),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.play_circle_outline, color: _mint),
        ],
      ),
    );
  }
}