import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sound_sphere_v1/app/theme.dart';

import '../application/liked_songs_provider.dart';
import '../../player/application/audio_handler_provider.dart';
import '../../player/presentation/player_screen.dart';
import '../data/models/music_track.dart';

class LikedSongsScreen extends ConsumerWidget {
  const LikedSongsScreen({super.key, required this.onGoHome});

  final VoidCallback onGoHome;

  Future<void> _playTrack(
    BuildContext context,
    WidgetRef ref,
    MusicTrack track,
  ) async {
    final url = track.audioUrl;

    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio is unavailable for this track.')),
      );
      return;
    }

    try {
      final handler = ref.read(audioHandlerProvider);

      await handler.playUrl(
        url: url,
        title: track.name,
        artist: track.artistName,
        album: track.albumName,
        artworkUrl: track.imageUrl,
      );

      if (!context.mounted) return;

      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const PlayerScreen()));
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Playback failed: $error'),
          backgroundColor: AppColors.textPrimary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedAsync = ref.watch(likedSongsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      child: likedAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryDark),
        ),

        error: (error, stack) => Center(
          child: Text(
            'Could not load liked songs.',
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),

        data: (songs) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.peachPale,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      tooltip: 'Go to Home',
                      onPressed: onGoHome,
                      icon: const Icon(
                        Icons.home_rounded,
                        color: AppColors.primaryDark,
                        size: 25,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      'Liked Songs',
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  '${songs.length} saved songs',
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // EMPTY STATE
              if (songs.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 112,
                          height: 112,
                          decoration: BoxDecoration(
                            color: AppColors.peachPale,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite_border_rounded,
                            color: AppColors.primaryDark,
                            size: 55,
                          ),
                        ),

                        const SizedBox(height: 22),

                        Text(
                          'Your liked songs will appear here',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Tap the heart on any track to save it.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              // LIKED SONGS LIST
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: songs.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 11),
                    itemBuilder: (context, index) {
                      final track = songs[index];

                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: AppColors.border,
                            width: 0.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFA36D58)
                                  .withValues(alpha: 0.07),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),

                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 5,
                          ),

                          onTap: () => _playTrack(context, ref, track),

                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child:
                                track.imageUrl != null &&
                                    track.imageUrl!.isNotEmpty
                                ? Image.network(
                                    track.imageUrl!,
                                    width: 54,
                                    height: 54,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) =>
                                        _artworkPlaceholder(),
                                  )
                                : _artworkPlaceholder(),
                          ),

                          title: Text(
                            track.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),

                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              track.artistName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ),

                          trailing: IconButton(
                            tooltip: 'Remove from liked songs',
                            onPressed: () {
                              ref
                                  .read(likedSongsProvider.notifier)
                                  .remove(track.id);
                            },
                            icon: const Icon(
                              Icons.favorite_rounded,
                              color: AppColors.primaryDark,
                              size: 23,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _artworkPlaceholder() {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.peachPale,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.music_note_rounded,
        color: AppColors.primaryDark,
        size: 25,
      ),
    );
  }
}
