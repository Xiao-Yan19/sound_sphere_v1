
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import 'package:sound_sphere_v1/features/music/application/music_providers.dart';
import 'package:sound_sphere_v1/features/music/data/models/music_track.dart';
import 'package:sound_sphere_v1/features/player/application/audio_handler_provider.dart';
import 'package:sound_sphere_v1/features/music/application/liked_songs_provider.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  double? _dragValue;

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  MusicTrack? _trackFromMediaItem(MediaItem? item) {
    if (item == null) return null;

    final trackId = item.extras?['trackId']?.toString();

    // A real Jamendo ID is required to save the track correctly.
    if (trackId == null || trackId.isEmpty) return null;

    return MusicTrack(
      id: trackId,
      name: item.title,
      artistName: item.artist ?? 'Unknown Artist',
      albumName: item.album,
      audioUrl: item.id,
      imageUrl: item.artUri?.toString(),
      duration: item.duration?.inSeconds.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final handler = ref.watch(audioHandlerProvider);
    final likedTracks =
        ref.watch(likedSongsProvider).asData?.value ?? const <MusicTrack>[];

    return Scaffold(
      backgroundColor: const Color(0xFF101A19),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'NOW PLAYING',
          style: TextStyle(
            fontSize: 13,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<MediaItem?>(
        stream: handler.mediaItem,
        builder: (context, snapshot) {
          final item = snapshot.data;
          final currentTrack = _trackFromMediaItem(item);

          final isLiked = currentTrack != null &&
              likedTracks.any((track) => track.id == currentTrack.id);

          return LayoutBuilder(
            builder: (context, constraints) {
              final artworkSize =
                  (constraints.maxWidth - 48).clamp(180.0, 320.0);

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ALBUM ARTWORK
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: item?.artUri != null
                              ? Image.network(
                                  item!.artUri.toString(),
                                  height: artworkSize,
                                  width: artworkSize,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _artworkPlaceholder(),
                                )
                              : _artworkPlaceholder(),
                        ),

                        const SizedBox(height: 30),

                        // SONG INFORMATION
                        Text(
                          item?.title ?? 'No Song Playing',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          item?.artist ?? 'Select a song to begin',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF8FA9A3),
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // LIKE / UNLIKE
                        IconButton(
                          tooltip: currentTrack == null
                              ? 'Track information unavailable'
                              : isLiked
                                  ? 'Unlike song'
                                  : 'Like song',
                          onPressed: currentTrack == null
                              ? null
                              : () async {
                                  await ref
                                      .read(likedSongsProvider.notifier)
                                      .toggleLike(currentTrack);
                                },
                          icon: Icon(
                            isLiked
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: currentTrack == null
                                ? Colors.white24
                                : const Color(0xFF7DE5D0),
                            size: 28,
                          ),
                        ),

                        const SizedBox(height: 22),

                        // PLAYBACK PROGRESS
                        StreamBuilder<Duration?>(
                          stream: handler.player.durationStream,
                          initialData: handler.player.duration,
                          builder: (context, durationSnapshot) {
                            final duration = durationSnapshot.data ??
                                item?.duration ??
                                Duration.zero;

                            final maxValue = duration.inMilliseconds > 0
                                ? duration.inMilliseconds.toDouble()
                                : 1.0;

                            return StreamBuilder<Duration>(
                              stream: handler.player.positionStream,
                              initialData: handler.player.position,
                              builder: (context, positionSnapshot) {
                                final position =
                                    positionSnapshot.data ?? Duration.zero;

                                final currentValue = (_dragValue ??
                                        position.inMilliseconds.toDouble())
                                    .clamp(0.0, maxValue)
                                    .toDouble();

                                return Column(
                                  children: [
                                    Slider(
                                      value: currentValue,
                                      min: 0,
                                      max: maxValue,
                                      activeColor:
                                          const Color(0xFF7DE5D0),
                                      inactiveColor:
                                          const Color(0xFF34504A),
                                      onChanged: duration > Duration.zero
                                          ? (value) {
                                              setState(() {
                                                _dragValue = value;
                                              });
                                            }
                                          : null,
                                      onChangeEnd: duration > Duration.zero
                                          ? (value) async {
                                              await handler.seek(
                                                Duration(
                                                  milliseconds:
                                                      value.round(),
                                                ),
                                              );

                                              if (mounted) {
                                                setState(() {
                                                  _dragValue = null;
                                                });
                                              }
                                            }
                                          : null,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            formatDuration(
                                              Duration(
                                                milliseconds:
                                                    currentValue.round(),
                                              ),
                                            ),
                                            style: const TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),
                                          Text(
                                            formatDuration(duration),
                                            style: const TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // SHUFFLE AND REPEAT
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            StreamBuilder<bool>(
                              stream:
                                  handler.player.shuffleModeEnabledStream,
                              initialData:
                                  handler.player.shuffleModeEnabled,
                              builder: (context, snapshot) {
                                final shuffleEnabled =
                                    snapshot.data ?? false;

                                return IconButton(
                                  tooltip: shuffleEnabled
                                      ? 'Turn shuffle off'
                                      : 'Turn shuffle on',
                                  onPressed: () {
                                    handler.setShuffle(!shuffleEnabled);
                                  },
                                  icon: Icon(
                                    Icons.shuffle_rounded,
                                    color: shuffleEnabled
                                        ? const Color(0xFF7DE5D0)
                                        : Colors.white54,
                                    size: 25,
                                  ),
                                );
                              },
                            ),
                            StreamBuilder<LoopMode>(
                              stream: handler.player.loopModeStream,
                              initialData: handler.player.loopMode,
                              builder: (context, snapshot) {
                                final repeatOne =
                                    snapshot.data == LoopMode.one;

                                return IconButton(
                                  tooltip: repeatOne
                                      ? 'Turn repeat one off'
                                      : 'Repeat current song',
                                  onPressed: () {
                                    handler.toggleRepeatOne();
                                  },
                                  icon: Icon(
                                    Icons.repeat_one_rounded,
                                    color: repeatOne
                                        ? const Color(0xFF7DE5D0)
                                        : Colors.white54,
                                    size: 25,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // PLAYBACK CONTROLS
                        StreamBuilder<bool>(
                          stream: handler.player.playingStream,
                          initialData: handler.player.playing,
                          builder: (context, playingSnapshot) {
                            final playing =
                                playingSnapshot.data ?? false;

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  tooltip: 'Previous',
                                  onPressed: () =>
                                      handler.skipToPrevious(),
                                  icon: const Icon(
                                    Icons.skip_previous_rounded,
                                    color: Colors.white,
                                    size: 38,
                                  ),
                                ),

                                const SizedBox(width: 25),

                                Container(
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF7DE5D0),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    onPressed: () async {
                                      if (playing) {
                                        await handler.pause();
                                      } else {
                                        await handler.play();
                                      }
                                    },
                                    icon: Icon(
                                      playing
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      color: const Color(0xFF173F3E),
                                      size: 42,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 25),

                                IconButton(
                                  tooltip: 'Next',
                                  onPressed: () => handler.skipToNext(),
                                  icon: const Icon(
                                    Icons.skip_next_rounded,
                                    color: Colors.white,
                                    size: 38,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _artworkPlaceholder() {
    return Container(
      height: 300,
      width: 300,
      decoration: BoxDecoration(
        color: const Color(0xFF234440),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(
        Icons.music_note_rounded,
        size: 100,
        color: Color(0xFF7DE5D0),
      ),
    );
  }
}
