import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:async';

import 'package:sound_sphere_v1/features/music/data/models/music_track.dart';
import 'package:sound_sphere_v1/features/music/application/music_providers.dart';

import '../../auth/presentation/login_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../auth/application/auth_controller.dart';

import 'package:audio_service/audio_service.dart';

import '../../player/application/audio_handler_provider.dart';
import '../../player/presentation/player_screen.dart';

const Color _mint = Color(0xFF82E6D1);
const Color _darkTeal = Color(0xFF173536);
const Color _deepTeal = Color(0xFF203F40);
const Color _mutedTeal = Color(0xFF365B5C);
const Color _lavender = Color(0xFFB6C5FF);

class HomeScreen extends ConsumerStatefulWidget {
  final bool isAuthenticated;

  const HomeScreen({super.key, this.isAuthenticated = false});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String selectedMood = 'Relax';
  int selectedTab = 2;

  final Set<int> likedSongs = {1};

  final List<String> moods = [
    'Relax',
    'Romance',
    'Workout',
    'FeelGood',
    'Sleep',
  ];
  final PageController _quickPickController = PageController();

  Timer? _quickPickTimer;
  int _quickPickCount = 0;
  int _quickPickIndex = 0;

  @override
  void initState() {
    super.initState();

    _quickPickTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_quickPickController.hasClients || _quickPickCount < 2) {
        return;
      }

      final nextIndex = (_quickPickIndex + 1) % _quickPickCount;

      _quickPickController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _quickPickTimer?.cancel();
    _quickPickController.dispose();
    super.dispose();
  }

  void toggleLike(int index) {
    setState(() {
      if (likedSongs.contains(index)) {
        likedSongs.remove(index);
      } else {
        likedSongs.add(index);
      }
    });
  }

  Widget _buildCenterMiniPlayer() {
    final handler = ref.read(audioHandlerProvider);

    return StreamBuilder<MediaItem?>(
      stream: handler.mediaItem,
      builder: (context, snapshot) {
        final item = snapshot.data;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _deepTeal,
                border: Border.all(
                  color: _mint.withValues(alpha: 0.35),
                  width: 2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
                image: item?.artUri != null
                    ? DecorationImage(
                        image: NetworkImage(item!.artUri.toString()),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: item?.artUri == null
                  ? const Icon(Icons.graphic_eq_rounded, color: _mint, size: 39)
                  : null,
            ),

            const SizedBox(height: 5),

            GestureDetector(
              onTap: item == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PlayerScreen()),
                      );
                    },
              child: Column(
                children: [
                  Text(
                    item?.title ?? 'Home',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    item?.artist ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDockPlaybackControls() {
    final handler = ref.read(audioHandlerProvider);

    return StreamBuilder<PlaybackState>(
      stream: handler.playbackState,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data?.playing ?? false;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => handler.skipToPrevious(),
              icon: const Icon(
                Icons.skip_previous_rounded,
                color: Colors.white70,
                size: 25,
              ),
            ),

            const SizedBox(width: 8),

            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _mint.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () {
                  if (isPlaying) {
                    handler.pause();
                  } else {
                    handler.play();
                  }
                },
                icon: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 29,
                ),
              ),
            ),

            const SizedBox(width: 8),

            IconButton(
              onPressed: () => handler.skipToNext(),
              icon: const Icon(
                Icons.skip_next_rounded,
                color: Colors.white70,
                size: 25,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> playMusicTrack(MusicTrack track) async {
    if (track.audioUrl == null || track.audioUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio is unavailable for this track.')),
      );
      return;
    }

    final handler = ref.read(audioHandlerProvider);

    try {
      await handler.playUrl(
        url: track.audioUrl!,
        title: track.name,
        artist: track.artistName,
        album: track.albumName,
        artworkUrl: track.imageUrl,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PlayerScreen()),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Playback failed: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkTeal,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF173536), Color(0xFF284A4C), Color(0xFF536F7A)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildMoodFilters(),

                    const SizedBox(height: 28),

                    _buildSectionTitle('Quick Picks'),
                    const SizedBox(height: 10),
                    _buildQuickPicks(),

                    const SizedBox(height: 18),

                    _buildSectionTitle('Hot & Trending'),
                    const SizedBox(height: 10),
                    _buildTrending(),

                    const SizedBox(height: 18),

                    _buildSectionTitle('Popular Picks'),
                    const SizedBox(height: 10),
                    _buildPopular(),
                  ],
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: _buildBottomNavigation(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniPlayer() {
    final handler = ref.read(audioHandlerProvider);

    return StreamBuilder<MediaItem?>(
      stream: handler.mediaItem,
      builder: (context, snapshot) {
        final item = snapshot.data;

        if (item == null) {
          return const SizedBox(height: 5);
        }

        return Container(
          height: 62,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.symmetric(horizontal: 9),
          decoration: BoxDecoration(
            color: const Color(0xFF29494B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _mint.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PlayerScreen()),
                  );
                },
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: item.artUri != null
                          ? Image.network(
                              item.artUri.toString(),
                              width: 42,
                              height: 42,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _miniPlayerIcon(),
                            )
                          : _miniPlayerIcon(),
                    ),
                    const SizedBox(width: 9),
                    SizedBox(
                      width: 125,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.artist ?? 'Unknown Artist',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              StreamBuilder<PlaybackState>(
                stream: handler.playbackState,
                builder: (context, stateSnapshot) {
                  final isPlaying = stateSnapshot.data?.playing ?? false;

                  return IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      if (isPlaying) {
                        handler.pause();
                      } else {
                        handler.play();
                      }
                    },
                    icon: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: _mint,
                      size: 28,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _miniPlayerIcon() {
    return Container(
      width: 44,
      height: 44,
      color: _darkTeal,
      child: const Icon(Icons.music_note_rounded, color: _mint, size: 25),
    );
  }

  // HEADER

  Widget _buildHeader() {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 18, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
            child: const CircleAvatar(
              radius: 19,
              backgroundColor: Color(0xFFE8ECEB),
              child: Icon(Icons.person, color: Color(0xFF7B8584), size: 29),
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Text(
              authState.status == AuthStatus.authenticated
                  ? 'Welcome, ${user?.displayName ?? 'User'}'
                  : 'Welcome, Guest',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          if (!widget.isAuthenticated)
            TextButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              style: TextButton.styleFrom(
                foregroundColor: _mint,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: Text(
                'Log in',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          IconButton(
            tooltip: 'Listening history',
            onPressed: () {},
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.access_time, color: _mint, size: 24),
          ),

          IconButton(
            tooltip: 'Settings',
            onPressed: () {},
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.settings, color: _mint, size: 24),
          ),
        ],
      ),
    );
  }

  // MOOD FILTERS

  Widget _buildMoodFilters() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
        scrollDirection: Axis.horizontal,
        itemCount: moods.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final mood = moods[index];
          final isSelected = mood == selectedMood;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedMood = mood;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF3E6A60)
                    : const Color(0xFF25423F),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? _mint.withValues(alpha: 0.5)
                      : Colors.transparent,
                ),
              ),
              child: Center(
                child: Text(
                  mood,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // SECTION TITLES

  Widget _buildSectionTitle(String title) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 38,
              height: 1.05,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.3,
              color: _lavender,
              shadows: const [
                Shadow(
                  color: Color(0x553F4D85),
                  offset: Offset(0, 3),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // QUICK PICKS

  static const double _qpLeftPad = 16;
  static const double _qpNarrow = 56;
  static const double _qpGap = 10;

  // Works out where every Quick Pick card sits for a given (fractional) page.
  // The focused card is wide, the following cards are narrow pills.
  List<_QuickSlot> _quickPickSlots(double page, double width, int count) {
    final big = (width - (_qpLeftPad * 2) - 2 * (_qpNarrow + _qpGap))
        .clamp(120.0, 600.0)
        .toDouble();

    final i0 = page.floor().clamp(0, count - 1);
    final f = page - i0;

    double left = _qpLeftPad - f * (_qpNarrow + _qpGap);
    int start = i0;

    if (i0 > 0) {
      start = i0 - 1;
      left -= (_qpNarrow + _qpGap);
    }

    final slots = <_QuickSlot>[];

    for (int i = start; i < count; i++) {
      final t = (i - page).abs().clamp(0.0, 1.0).toDouble();
      final w = _qpNarrow + (big - _qpNarrow) * (1 - t);

      slots.add(_QuickSlot(index: i, left: left, width: w, t: t));

      left += w + _qpGap;
      if (left > width) break;
    }

    return slots;
  }

  Widget _buildQuickPicks() {
    return ref
        .watch(trendingTracksProvider)
        .when(
          loading: () => const SizedBox(
            height: 195,
            child: Center(child: CircularProgressIndicator(color: _mint)),
          ),
          error: (error, stack) => const SizedBox(
            height: 100,
            child: Center(
              child: Text(
                'Could not load tracks.',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
          data: (tracks) {
            if (tracks.isEmpty) {
              return const SizedBox(
                height: 100,
                child: Center(
                  child: Text(
                    'No tracks available.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              );
            }

            _quickPickCount = tracks.length;

            double currentPage() {
              if (_quickPickController.hasClients &&
                  _quickPickController.position.hasContentDimensions) {
                return (_quickPickController.page ??
                        _quickPickController.initialPage.toDouble())
                    .clamp(0.0, (tracks.length - 1).toDouble())
                    .toDouble();
              }
              return _quickPickController.initialPage.toDouble();
            }

            return SizedBox(
              height: 195,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;

                  return Stack(
                    children: [
                      // Visual layer: cards positioned from the page value.
                      Positioned.fill(
                        child: ClipRect(
                          child: AnimatedBuilder(
                            animation: _quickPickController,
                            builder: (context, _) {
                              final slots = _quickPickSlots(
                                currentPage(),
                                width,
                                tracks.length,
                              );

                              return Stack(
                                children: [
                                  for (final s in slots)
                                    Positioned(
                                      left: s.left,
                                      top: 0,
                                      bottom: 0,
                                      width: s.width,
                                      child: _quickPickCard(
                                        track: tracks[s.index],
                                        width: s.width,
                                        verticalText: s.t > 0.8,
                                        color: Color.lerp(
                                          const Color(0xFFD9F7EA),
                                          s.index.isEven
                                              ? const Color(0xFFA0D6CE)
                                              : const Color(0xFF8DEBD0),
                                          s.t,
                                        )!,
                                        radius: 25 + 10 * s.t,
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),

                      // Gesture layer: swipe changes the page, tap plays the card.
                      Positioned.fill(
                        child: PageView.builder(
                          controller: _quickPickController,
                          itemCount: tracks.length,
                          onPageChanged: (index) => _quickPickIndex = index,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTapUp: (details) {
                                final dx = details.localPosition.dx;
                                final slots = _quickPickSlots(
                                  currentPage(),
                                  width,
                                  tracks.length,
                                );

                                for (final s in slots) {
                                  if (dx >= s.left && dx <= s.left + s.width) {
                                    playMusicTrack(tracks[s.index]);
                                    break;
                                  }
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
  }

  Widget _quickPickCard({
    required MusicTrack track,
    required double width,
    required bool verticalText,
    Color color = const Color(0xFFD9F7EA),
    double radius = 25,
  }) {
    final hasImage = track.imageUrl != null && track.imageUrl!.isNotEmpty;
    final textColor = hasImage ? Colors.white : Colors.black87;

    return Container(
      width: width,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        image: hasImage
            ? DecorationImage(
                image: NetworkImage(track.imageUrl!),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.25),
                  BlendMode.darken,
                ),
              )
            : null,
      ),
      padding: const EdgeInsets.all(12),
      child: verticalText
          ? Align(
              alignment: Alignment.topCenter,
              child: RotatedBox(
                quarterTurns: 1,
                child: Text(
                  track.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  track.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  track.artistName, // shown where the mock says "Genre"
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 11, color: textColor),
                ),
              ],
            ),
    );
  }

  // HOT & TRENDING

  Widget _buildTrending() {
    return ref
        .watch(trendingTracksProvider)
        .when(
          loading: () => const SizedBox(
            height: 110,
            child: Center(child: CircularProgressIndicator(color: _mint)),
          ),
          error: (error, stack) => const SizedBox(
            height: 100,
            child: Center(
              child: Text(
                'Could not load trending tracks.',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
          data: (tracks) {
            if (tracks.isEmpty) {
              return const SizedBox(
                height: 100,
                child: Center(
                  child: Text(
                    'No trending tracks available.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              );
            }

            return SizedBox(
              height: 110,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                scrollDirection: Axis.horizontal,
                itemCount: tracks.length + 1,
                separatorBuilder: (_, _) => const SizedBox(width: 13),
                itemBuilder: (context, index) {
                  if (index == tracks.length) {
                    return Container(
                      width: 26,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 14,
                      ),
                    );
                  }

                  final track = tracks[index];

                  return GestureDetector(
                    onTap: () => playMusicTrack(track),
                    child: Container(
                      width: 92,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF4A5655), Color(0xFF2A4547)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        image:
                            track.imageUrl != null && track.imageUrl!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(track.imageUrl!),
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                  Colors.black.withValues(alpha: 0.4),
                                  BlendMode.darken,
                                ),
                              )
                            : null,
                      ),
                      padding: const EdgeInsets.all(7),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            track.artistName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 8,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
  }

  // POPULAR PICKS

  Widget _buildPopular() {
    return ref
        .watch(trendingTracksProvider)
        .when(
          loading: () => const Padding(
            padding: EdgeInsets.all(25),
            child: Center(child: CircularProgressIndicator(color: _mint)),
          ),
          error: (error, stack) => const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text(
                'Could not load popular tracks.',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
          data: (tracks) {
            if (tracks.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'No popular tracks available.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tracks.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final track = tracks[index];

                return GestureDetector(
                  onTap: () => playMusicTrack(track),
                  child: Container(
                    height: 74,
                    padding: const EdgeInsets.symmetric(horizontal: 9),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF414C4B), Color(0xFF1B3B3D)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(29),
                          child:
                              track.imageUrl != null &&
                                  track.imageUrl!.isNotEmpty
                              ? Image.network(
                                  track.imageUrl!,
                                  width: 58,
                                  height: 58,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const SizedBox(
                                    width: 58,
                                    height: 58,
                                    child: Icon(
                                      Icons.music_note,
                                      color: _mutedTeal,
                                    ),
                                  ),
                                )
                              : const SizedBox(
                                  width: 58,
                                  height: 58,
                                  child: Icon(
                                    Icons.music_note,
                                    color: _mutedTeal,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                track.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                track.artistName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: likedSongs.contains(index)
                              ? 'Unlike song'
                              : 'Like song',
                          onPressed: () => toggleLike(index),
                          icon: Icon(
                            likedSongs.contains(index)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: likedSongs.contains(index)
                                ? _mint
                                : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
  }

  // BOTTOM NAVIGATION

  Widget _buildBottomNavigation() {
    const double domeTop = 30;

    return SizedBox(
      height: 215,
      width: double.infinity,
      child: Center(
        child: SizedBox(
          width: 300,
          height: 215,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Outer dome (smooth half-ellipse)
              Positioned(
                left: -10,
                right: -10,
                top: domeTop + 15,
                bottom: 0,
                child: ClipPath(
                  clipper: _DomeClipper(),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF3A5254), Color(0xFF2A4345)],
                      ),
                    ),
                  ),
                ),
              ),

              // Inner dome behind the playback controls
              Positioned(
                left: 65,
                right: 65,
                bottom: 0,
                height: 84,
                child: ClipPath(
                  clipper: _DomeClipper(),
                  child: Container(color: const Color(0xFF3B5A5F)),
                ),
              ),

              // Search
              Positioned(
                left: 24,
                top: domeTop + 74,
                width: 80,
                child: _navItem(Icons.search, 'Search', 1),
              ),

              // Liked Songs
              Positioned(
                right: 24,
                top: domeTop + 74,
                width: 80,
                child: _navItem(Icons.favorite, 'Liked Songs', 3),
              ),

              // Connect
              Positioned(
                left: -5,
                bottom: 12,
                width: 80,
                child: _navItem(Icons.link, 'Connect', 0),
              ),

              // Library
              Positioned(
                right: -5,
                bottom: 12,
                width: 80,
                child: _navItem(Icons.library_music, 'Library', 4),
              ),

              // Center artwork and track information
              Positioned(
                top: 6,
                left: 90,
                right: 90,
                child: _buildCenterMiniPlayer(),
              ),

              // Playback controls
              Positioned(
                bottom: 20,
                left: 55,
                right: 55,
                child: _buildDockPlaybackControls(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // NAVIGATION ITEM

  Widget _navItem(IconData icon, String label, int index) {
    final isSelected = selectedTab == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: SizedBox(
        width: 59,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 25, color: isSelected ? Colors.white : _mint),

              const SizedBox(height: 4),

              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// QUICK PICK LAYOUT DATA

class _QuickSlot {
  final int index;
  final double left;
  final double width;
  final double t; // 0 = focused (wide), 1 = narrow

  const _QuickSlot({
    required this.index,
    required this.left,
    required this.width,
    required this.t,
  });
}

// SMOOTH DOME CLIPPER (true half-ellipse, used for both domes)

class _DomeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, size.height)
      ..arcToPoint(
        Offset(size.width, size.height),
        radius: Radius.elliptical(size.width / 2, size.height),
        clockwise: true,
      )
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
