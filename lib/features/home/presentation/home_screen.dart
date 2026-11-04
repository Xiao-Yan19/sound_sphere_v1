import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  void toggleLike(int index) {
    setState(() {
      if (likedSongs.contains(index)) {
        likedSongs.remove(index);
      } else {
        likedSongs.add(index);
      }
    });
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
                padding: const EdgeInsets.only(bottom: 135),
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
              Positioned(
                left: 0,
                right: 0,
                bottom: 145,
                child: _buildMiniPlayer(),
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
          return const SizedBox.shrink();
        }

        return Container(
          height: 68,
          margin: const EdgeInsets.symmetric(horizontal: 14),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF29494B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _mint.withOpacity(0.35)),
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
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _miniPlayerIcon(),
                            )
                          : _miniPlayerIcon(),
                    ),
                    const SizedBox(width: 11),
                    SizedBox(
                      width: 155,
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
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.artist ?? 'Unknown Artist',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
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
                      size: 30,
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
        separatorBuilder: (_, _) => const SizedBox(width: 18),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF47766B)
                    : const Color(0xFF294F4C),
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
                    fontSize: 9,
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

            final count = tracks.length > 4 ? 4 : tracks.length;

            return SizedBox(
              height: 195,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 30),
                itemCount: count,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  return _quickPickCard(
                    track: tracks[index],
                    width: index == 0 ? 195 : 53,
                    verticalText: index != 0,
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
  }) {
    return GestureDetector(
      onTap: () => playMusicTrack(track),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: const Color(0xFFA7DCD3),
          borderRadius: BorderRadius.circular(25),
          image: track.imageUrl != null && track.imageUrl!.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(track.imageUrl!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.35),
                    BlendMode.darken,
                  ),
                )
              : null,
        ),
        padding: const EdgeInsets.all(8),
        child: verticalText
            ? Center(
                child: RotatedBox(
                  quarterTurns: 1,
                  child: Text(
                    track.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    track.artistName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 10, color: Colors.white),
                  ),
                ],
              ),
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
                itemCount: tracks.length,
                separatorBuilder: (_, _) => const SizedBox(width: 13),
                itemBuilder: (context, index) {
                  final track = tracks[index];

                  return GestureDetector(
                    onTap: () => playMusicTrack(track),
                    child: Container(
                      width: 92,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF46504F), Color(0xFF1B3D3E)],
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
                    height: 70,
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
                          borderRadius: BorderRadius.circular(26),
                          child:
                              track.imageUrl != null &&
                                  track.imageUrl!.isNotEmpty
                              ? Image.network(
                                  track.imageUrl!,
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const SizedBox(
                                    width: 52,
                                    height: 52,
                                    child: Icon(
                                      Icons.music_note,
                                      color: _mutedTeal,
                                    ),
                                  ),
                                )
                              : const SizedBox(
                                  width: 52,
                                  height: 52,
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
                                  fontSize: 12,
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
                                  fontSize: 11,
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
    return SizedBox(
      height: 145,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          ClipPath(
            clipper: _NavBarClipper(),
            child: Container(
              height: 110,
              color: const Color(0xFF263F47),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(9, 30, 9, 9),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _navItem(Icons.link, 'Connect', 0),
                    _navItem(Icons.search, 'Search', 1),

                    const SizedBox(width: 65),

                    _navItem(Icons.favorite, 'Liked Songs', 3),
                    _navItem(Icons.library_music, 'Library', 4),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 74,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedTab = 2;
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selectedTab == 2
                          ? const Color(0xFF537D72)
                          : const Color(0xFF385B59),
                      border: Border.all(color: _mint.withValues(alpha: 0.3)),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(9),
                      child: Image.asset(
                        'assets/images/Logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.graphic_eq,
                          color: _mint,
                          size: 35,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    'Home',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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

// CUSTOM NAVIGATION BAR CLIPPER

class _NavBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, 35);

    path.quadraticBezierTo(size.width * 0.12, 35, size.width * 0.25, 12);

    path.quadraticBezierTo(size.width * 0.5, -32, size.width * 0.75, 12);

    path.quadraticBezierTo(size.width * 0.88, 35, size.width, 35);

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
