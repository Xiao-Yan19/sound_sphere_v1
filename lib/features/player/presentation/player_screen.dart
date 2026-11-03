
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/audio_handler_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final handler = ref.watch(audioHandlerProvider);

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
      body: StreamBuilder(
        stream: handler.mediaItem,
        builder: (context, snapshot) {
          final item = snapshot.data;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Album artwork
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: item?.artUri != null
                      ? Image.network(
                          item!.artUri.toString(),
                          height: 300,
                          width: 300,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              _artworkPlaceholder(),
                        )
                      : _artworkPlaceholder(),
                ),

                const SizedBox(height: 35),

                // Song information
                Text(
                  item?.title ?? 'No Song Playing',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  item?.artist ?? 'Select a song to begin',
                  style: const TextStyle(
                    color: Color(0xFF8FA9A3),
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 30),

                // Playback progress
                StreamBuilder<Duration?>(
                  stream: handler.player.durationStream,
                  initialData: handler.player.duration,
                  builder: (context, durationSnapshot) {
                    final duration =
                        durationSnapshot.data ??
                        item?.duration ??
                        Duration.zero;

                    final maxValue =
                        duration.inMilliseconds > 0
                            ? duration.inMilliseconds.toDouble()
                            : 1.0;

                    return StreamBuilder<Duration>(
                      stream: handler.player.positionStream,
                      initialData: handler.player.position,
                      builder: (context, positionSnapshot) {
                        final position =
                            positionSnapshot.data ?? Duration.zero;

                        final currentValue = _dragValue ??
                            position.inMilliseconds
                                .toDouble()
                                .clamp(0.0, maxValue)
                                .toDouble();

                        return Column(
                          children: [
                            Slider(
                              value: currentValue.clamp(0.0, maxValue),
                              min: 0,
                              max: maxValue,
                              activeColor: const Color(0xFF7DE5D0),
                              inactiveColor: const Color(0xFF34504A),
                              onChanged: duration > Duration.zero
                                  ? (value) {
                                      setState(() {
                                        _dragValue = value;
                                      });
                                    }
                                  : null,
                              onChangeEnd: duration > Duration.zero
                                  ? (value) {
                                      handler.seek(
                                        Duration(
                                          milliseconds: value.round(),
                                        ),
                                      );

                                      setState(() {
                                        _dragValue = null;
                                      });
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

                const SizedBox(height: 25),

                // Playback controls
                StreamBuilder<bool>(
                  stream: handler.player.playingStream,
                  initialData: handler.player.playing,
                  builder: (context, snapshot) {
                    final playing = snapshot.data ?? false;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: handler.skipToPrevious,
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
                            onPressed: playing
                                ? handler.pause
                                : handler.play,
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
                          onPressed: handler.skipToNext,
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
              ],
            ),
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
