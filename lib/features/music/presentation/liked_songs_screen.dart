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

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Playback failed: $error')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedAsync = ref.watch(likedSongsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
      child: likedAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Could not load liked songs.',
            style: GoogleFonts.inter(color: Colors.white70),
          ),
        ),
        data: (songs) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    'Liked Songs',
                    style: GoogleFonts.inter(
                      color: AppColors.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Text(
                '${songs.length} saved songs',
                style: GoogleFonts.inter(color: Colors.white60, fontSize: 13),
              ),

              const SizedBox(height: 22),

              // Keep the rest of your existing empty state
              // and ListView code here.
              if (songs.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.favorite_border_rounded,
                          color: AppColors.primary,
                          size: 65,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Your liked songs will appear here',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          'Tap the heart on any track to save it.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: songs.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final track = songs[index];

                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          onTap: () => _playTrack(context, ref, track),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child:
                                track.imageUrl != null &&
                                    track.imageUrl!.isNotEmpty
                                ? Image.network(
                                    track.imageUrl!,
                                    width: 52,
                                    height: 52,
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
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          subtitle: Text(
                            track.artistName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: Colors.white60,
                              fontSize: 11,
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
                              Icons.favorite,
                              color: AppColors.primary,
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
      width: 52,
      height: 52,
      color: AppColors.cardBackground,
      child: const Icon(Icons.music_note_rounded, color: AppColors.primary),
    );
  }
}
