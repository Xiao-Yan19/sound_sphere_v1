import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../auth/application/auth_controller.dart';

const Color _mint = Color(0xFF82E6D1);
const Color _darkTeal = Color(0xFF173536);
const Color _deepTeal = Color(0xFF203F40);
const Color _lavender = Color(0xFFB6C5FF);

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _deepTeal,
        title: Text('Log out?', style: GoogleFonts.inter(color: Colors.white)),
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
      backgroundColor: _darkTeal,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_darkTeal, _deepTeal, Color(0xFF536F7A)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
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
                          color: Colors.white70,
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
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Your Music',
                    style: GoogleFonts.inter(
                      color: _mint,
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 18, 12, 28),
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text(
                    'Recent Songs',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _songTile('Ocean Eyes', 'Artist Name'),
                    _songTile('Midnight City', 'Artist Name'),
                    _songTile('Golden Hour', 'Artist Name'),
                  ]),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _deepTeal,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _mint.withValues(alpha: 0.2)),
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
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _songTile(String title, String artist) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF414C4B), Color(0xFF1B3B3D)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.music_note, color: _deepTeal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artist,
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 10),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
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
