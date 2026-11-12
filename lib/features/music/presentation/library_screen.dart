
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sound_sphere_v1/app/theme.dart';
import '../application/liked_songs_provider.dart';
import '../../player/application/audio_handler_provider.dart';
import '../../player/presentation/player_screen.dart';

import 'liked_songs_screen.dart';


class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({
    super.key,
    required this.onGoHome,
  });

  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedAsync = ref.watch(likedSongsProvider);
    final handler = ref.read(audioHandlerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Home button
          Row(
            children: [
              IconButton(
                tooltip: 'Go to Home',
                onPressed: onGoHome,
                icon: const Icon(
                  Icons.home_rounded,
                  color: AppColors.primary,
                  size: 27,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Your Library',
                style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            'Your music, all in one place.',
            style: GoogleFonts.inter(
              color: Colors.white60,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 25),

          // Liked Songs collection
          likedAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
            error: (_, __) => const Text(
              'Could not load your saved music.',
              style: TextStyle(color: Colors.white70),
            ),
            data: (songs) => GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _LikedSongsRoute(
                      onGoHome: onGoHome,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF287C72),
                      Color(0xFF193C43),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Liked Songs',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${songs.length} songs',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          Text(
            'Now Playing',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          StreamBuilder<MediaItem?>(
            stream: handler.mediaItem,
            builder: (context, snapshot) {
              final item = snapshot.data;

              if (item == null) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Nothing is playing right now.',
                    style: TextStyle(color: Colors.white60),
                  ),
                );
              }

              return ListTile(
                contentPadding: const EdgeInsets.all(10),
                tileColor: AppColors.card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                leading: item.artUri != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: Image.network(
                          item.artUri.toString(),
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _musicIcon(),
                        ),
                      )
                    : _musicIcon(),
                title: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  item.artist ?? 'Unknown Artist',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white60),
                ),
                trailing: const Icon(
                  Icons.graphic_eq_rounded,
                  color: AppColors.primary,
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PlayerScreen(),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _musicIcon() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(9),
      ),
      child: const Icon(
        Icons.music_note_rounded,
        color: AppColors.primary,
      ),
    );
  }
}

// Opens Liked Songs from Library.
class _LikedSongsRoute extends StatelessWidget {
  const _LikedSongsRoute({
    required this.onGoHome,
  });

  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LikedSongsScreen(
          onGoHome: () {
            Navigator.of(context).pop();
            onGoHome();
          },
        ),
      ),
    );
  }
}
