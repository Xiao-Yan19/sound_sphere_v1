import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sound_sphere_v1/app/theme.dart';

import 'package:sound_sphere_v1/features/music/application/music_providers.dart';
import 'package:sound_sphere_v1/features/music/application/liked_songs_provider.dart';
import 'package:sound_sphere_v1/features/music/application/playlists_provider.dart';
import 'package:sound_sphere_v1/features/music/data/models/music_track.dart';
import 'package:sound_sphere_v1/features/player/application/audio_handler_provider.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  double? _dragValue;

  static const Color accent = AppColors.primary;
  static const Color gold = AppColors.primaryDark;
  static const Color background = AppColors.background;
  static const Color surface = AppColors.cardBackground;
  static const Color surfaceHigh = AppColors.peachPale;

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  MusicTrack? _trackFromMediaItem(MediaItem? item) {
    if (item == null) return null;

    final trackId = item.extras?['trackId']?.toString();

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

  SnackBar _snack(String text) {
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: surfaceHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Text(text, style: const TextStyle(color: AppColors.textPrimary)),
    );
  }

  Future<void> _showAddToPlaylistSheet(
    BuildContext context,
    MusicTrack track,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Consumer(
            builder: (context, ref, _) {
              final playlistsAsync = ref.watch(playlistsProvider);

              return Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    const Text(
                      'Add to playlist',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      track.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // CREATE PLAYLIST OPTION
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.add_rounded, color: accent),
                      ),
                      title: const Text(
                        'New playlist',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () async {
                        final name = await showDialog<String>(
                          context: sheetContext,
                          builder: (_) => const _CreatePlaylistDialog(),
                        );

                        if (name == null || name.trim().isEmpty) {
                          return;
                        }

                        await ref
                            .read(playlistsProvider.notifier)
                            .createPlaylist(name.trim());

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(this.context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            _snack(
                              'Playlist "$name" created. Select it to add this song.',
                            ),
                          );
                      },
                    ),

                    const Divider(color: AppColors.divider, height: 24),

                    playlistsAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: CircularProgressIndicator(color: accent),
                        ),
                      ),
                      error: (error, stack) => const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Unable to load your playlists.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      data: (playlists) {
                        if (playlists.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 18),
                            child: Center(
                              child: Text(
                                'No playlists created yet.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }

                        return Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: playlists.length,
                            itemBuilder: (context, index) {
                              final playlist = playlists[index];

                              final alreadyAdded = playlist.tracks.any(
                                (song) => song.id == track.id,
                              );

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: surfaceHigh,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.queue_music_rounded,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                title: Text(
                                  playlist.name,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  alreadyAdded
                                      ? 'Already added'
                                      : '${playlist.tracks.length} songs',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: Icon(
                                  alreadyAdded
                                      ? Icons.check_circle_rounded
                                      : Icons.add_circle_outline_rounded,
                                  color: alreadyAdded
                                      ? accent
                                      : AppColors.textSecondary,
                                ),
                                onTap: alreadyAdded
                                    ? null
                                    : () async {
                                        await ref
                                            .read(playlistsProvider.notifier)
                                            .addTrack(playlist.id, track);

                                        if (!context.mounted) return;

                                        Navigator.of(sheetContext).pop();

                                        ScaffoldMessenger.of(this.context)
                                          ..hideCurrentSnackBar()
                                          ..showSnackBar(
                                            _snack('Added to ${playlist.name}'),
                                          );
                                      },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final handler = ref.watch(audioHandlerProvider);

    final likedTracks =
        ref.watch(likedSongsProvider).asData?.value ?? const <MusicTrack>[];

    return Scaffold(
      backgroundColor: background,
      body: StreamBuilder<MediaItem?>(
        stream: handler.mediaItem,
        builder: (context, snapshot) {
          final item = snapshot.data;
          final currentTrack = _trackFromMediaItem(item);

          final isLiked =
              currentTrack != null &&
              likedTracks.any((track) => track.id == currentTrack.id);

          return Stack(
            children: [
              // ARTWORK-TINTED BACKDROP
              Positioned.fill(
                child: item?.artUri != null
                    ? Image.network(
                        item!.artUri.toString(),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: background),
                      )
                    : Container(color: background),
              ),

              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                  child: Container(color: const Color(0xCCFDF4EC)),
                ),
              ),

              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        background.withOpacity(0.85),
                      ],
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final artworkSize = (constraints.maxWidth - 48).clamp(
                      200.0,
                      360.0,
                    );

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
                          child: Column(
                            children: [
                              // TOP BAR
                              Row(
                                children: [
                                  IconButton(
                                    tooltip: 'Close',
                                    onPressed: () =>
                                        Navigator.of(context).maybePop(),
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: AppColors.textPrimary,
                                      size: 32,
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        const Text(
                                          'Playing from',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item?.album ?? 'SoundSphere Music',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: currentTrack == null
                                        ? null
                                        : () => _showAddToPlaylistSheet(
                                            context,
                                            currentTrack,
                                          ),
                                    tooltip: 'Add to playlist',
                                    icon: const Icon(
                                      Icons.playlist_add_rounded,
                                      color: AppColors.textPrimary,
                                      size: 28,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 28),

                              // ALBUM ARTWORK
                              Container(
                                width: artworkSize,
                                height: artworkSize,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.textPrimary.withOpacity(
                                        0.14,
                                      ),
                                      blurRadius: 40,
                                      offset: const Offset(0, 20),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: item?.artUri != null
                                      ? Image.network(
                                          item!.artUri.toString(),
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _artworkPlaceholder(artworkSize),
                                        )
                                      : _artworkPlaceholder(artworkSize),
                                ),
                              ),

                              const SizedBox(height: 36),

                              // TITLE, ARTIST AND LIKE
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item?.title ?? 'No song playing',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 24,
                                            height: 1.2,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          item?.artist ??
                                              'Select a song to begin',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    tooltip: isLiked
                                        ? 'Unlike song'
                                        : 'Like song',
                                    onPressed: currentTrack == null
                                        ? null
                                        : () async {
                                            await ref
                                                .read(
                                                  likedSongsProvider.notifier,
                                                )
                                                .toggleLike(currentTrack);
                                          },
                                    icon: Icon(
                                      isLiked
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      color: isLiked
                                          ? gold
                                          : AppColors.textSecondary,
                                      size: 28,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 22),

                              // SEEK BAR
                              StreamBuilder<Duration?>(
                                stream: handler.player.durationStream,
                                initialData: handler.player.duration,
                                builder: (context, durationSnapshot) {
                                  final duration =
                                      durationSnapshot.data ??
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
                                          positionSnapshot.data ??
                                          Duration.zero;

                                      final currentValue =
                                          (_dragValue ??
                                                  position.inMilliseconds
                                                      .toDouble())
                                              .clamp(0.0, maxValue)
                                              .toDouble();

                                      final progress = currentValue / maxValue;

                                      return Column(
                                        children: [
                                          _WaveformSeekBar(
                                            progress: progress,
                                            enabled: duration > Duration.zero,
                                            onChanged: (value) {
                                              setState(() {
                                                _dragValue = value * maxValue;
                                              });
                                            },
                                            onChangeEnd: (value) async {
                                              await handler.seek(
                                                Duration(
                                                  milliseconds:
                                                      (value * maxValue)
                                                          .round(),
                                                ),
                                              );

                                              if (mounted) {
                                                setState(() {
                                                  _dragValue = null;
                                                });
                                              }
                                            },
                                          ),

                                          const SizedBox(height: 8),

                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                formatDuration(
                                                  Duration(
                                                    milliseconds: currentValue
                                                        .round(),
                                                  ),
                                                ),
                                                style: const TextStyle(
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Text(
                                                '-${formatDuration(Duration(milliseconds: (maxValue - currentValue).round()))}',
                                                style: const TextStyle(
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),

                              const SizedBox(height: 20),

                              // PLAYBACK CONTROLS
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // SHUFFLE
                                  StreamBuilder<bool>(
                                    stream:
                                        handler.player.shuffleModeEnabledStream,
                                    initialData:
                                        handler.player.shuffleModeEnabled,
                                    builder: (context, snapshot) {
                                      final enabled = snapshot.data ?? false;

                                      return IconButton(
                                        tooltip: 'Shuffle',
                                        onPressed: () {
                                          handler.setShuffle(!enabled);
                                        },
                                        icon: Icon(
                                          Icons.shuffle_rounded,
                                          color: enabled
                                              ? accent
                                              : AppColors.textSecondary,
                                          size: 26,
                                        ),
                                      );
                                    },
                                  ),

                                  // PREVIOUS
                                  IconButton(
                                    tooltip: 'Previous',
                                    onPressed: () => handler.skipToPrevious(),
                                    icon: const Icon(
                                      Icons.skip_previous_rounded,
                                      color: AppColors.textPrimary,
                                      size: 42,
                                    ),
                                  ),

                                  // PLAY / PAUSE
                                  StreamBuilder<bool>(
                                    stream: handler.player.playingStream,
                                    initialData: handler.player.playing,
                                    builder: (context, snapshot) {
                                      final playing = snapshot.data ?? false;

                                      return Container(
                                        width: 72,
                                        height: 72,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          tooltip: playing ? 'Pause' : 'Play',
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
                                            color: background,
                                            size: 44,
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                  // NEXT
                                  IconButton(
                                    tooltip: 'Next',
                                    onPressed: () => handler.skipToNext(),
                                    icon: const Icon(
                                      Icons.skip_next_rounded,
                                      color: AppColors.textPrimary,
                                      size: 42,
                                    ),
                                  ),

                                  // REPEAT ONE
                                  StreamBuilder<LoopMode>(
                                    stream: handler.player.loopModeStream,
                                    initialData: handler.player.loopMode,
                                    builder: (context, snapshot) {
                                      final repeatOne =
                                          snapshot.data == LoopMode.one;

                                      return IconButton(
                                        tooltip: 'Repeat one',
                                        onPressed: () {
                                          handler.toggleRepeatOne();
                                        },
                                        icon: Icon(
                                          Icons.repeat_one_rounded,
                                          color: repeatOne
                                              ? accent
                                              : AppColors.textSecondary,
                                          size: 26,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),
                            ],
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

  Widget _artworkPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      color: AppColors.peachPale,
      child: const Icon(Icons.music_note_rounded, size: 100, color: accent),
    );
  }
}

// WAVEFORM-STYLE SEEK BAR
class _WaveformSeekBar extends StatelessWidget {
  const _WaveformSeekBar({
    required this.progress,
    required this.enabled,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final double progress;
  final bool enabled;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  static const List<double> _heights = [
    0.30,
    0.55,
    0.40,
    0.75,
    0.48,
    0.88,
    0.62,
    0.38,
    0.70,
    0.95,
    0.55,
    0.78,
    0.42,
    0.68,
    0.90,
    0.50,
    0.32,
    0.73,
    0.58,
    0.85,
    0.45,
    0.67,
    0.96,
    0.54,
    0.76,
    0.38,
    0.62,
    0.88,
    0.47,
    0.70,
    0.92,
    0.56,
    0.35,
    0.79,
    0.60,
    0.86,
    0.44,
    0.68,
    0.98,
    0.52,
    0.74,
    0.40,
    0.64,
    0.90,
    0.48,
    0.78,
    0.57,
    0.84,
    0.36,
    0.66,
  ];

  void _updatePosition(Offset localPosition, double width, bool isEnd) {
    if (!enabled || width <= 0) return;

    final value = (localPosition.dx / width).clamp(0.0, 1.0).toDouble();

    if (isEnd) {
      onChangeEnd(value);
    } else {
      onChanged(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled
              ? (details) => _updatePosition(
                  details.localPosition,
                  constraints.maxWidth,
                  true,
                )
              : null,
          onHorizontalDragUpdate: enabled
              ? (details) => _updatePosition(
                  details.localPosition,
                  constraints.maxWidth,
                  false,
                )
              : null,
          onHorizontalDragEnd: enabled ? (_) => onChangeEnd(progress) : null,
          child: SizedBox(
            height: 44,
            width: double.infinity,
            child: CustomPaint(
              painter: _WaveformPainter(progress: progress, heights: _heights),
            ),
          ),
        );
      },
    );
  }
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({required this.progress, required this.heights});

  final double progress;
  final List<double> heights;

  @override
  void paint(Canvas canvas, Size size) {
    const gap = 3.0;

    final barWidth = (size.width - (heights.length - 1) * gap) / heights.length;

    final playedPaint = Paint()
      ..color = AppColors.primaryDark
      ..strokeCap = StrokeCap.round
      ..strokeWidth = barWidth;

    final remainingPaint = Paint()
      ..color = AppColors.border.withOpacity(0.75)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = barWidth;

    for (int i = 0; i < heights.length; i++) {
      final x = i * (barWidth + gap) + barWidth / 2;
      final barHeight = heights[i] * size.height * 0.85;
      final top = (size.height - barHeight) / 2;

      final paint = (i / heights.length) <= progress
          ? playedPaint
          : remainingPaint;

      canvas.drawLine(Offset(x, top), Offset(x, top + barHeight), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _CreatePlaylistDialog extends StatefulWidget {
  const _CreatePlaylistDialog();

  @override
  State<_CreatePlaylistDialog> createState() => _CreatePlaylistDialogState();
}

class _CreatePlaylistDialogState extends State<_CreatePlaylistDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Create playlist',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        style: const TextStyle(color: AppColors.textPrimary),
        cursorColor: AppColors.primaryDark,
        decoration: InputDecoration(
          hintText: 'Enter playlist name',
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primaryDark),
          ),
        ),
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            Navigator.of(context).pop(value.trim());
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _controller.text.trim();

            if (name.isNotEmpty) {
              Navigator.of(context).pop(name);
            }
          },
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Create'),
        ),
      ],
    );
  }
}
