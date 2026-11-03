import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/login_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../auth/application/auth_controller.dart';

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

  final List<Map<String, String>> songs = [
    {'title': 'Ocean Eyes', 'genre': 'Dream Pop'},
    {'title': 'Midnight City', 'genre': 'Electronic'},
    {'title': 'Golden Hour', 'genre': 'Indie Pop'},
    {'title': 'Soft Lights', 'genre': 'Ambient'},
    {'title': 'Afterglow', 'genre': 'Chill'},
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

  // Plays a temporary test audio track.
  Future<void> playTestSong({
    required String title,
    required String artist,
  }) async {
    try {
      final handler = ref.read(audioHandlerProvider);

      await handler.playUrl(
        url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        title: title,
        artist: artist,
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
    return SizedBox(
      height: 195,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        children: [
          _quickPickCard(index: 0, width: 195, verticalText: false),

          const SizedBox(width: 10),

          _quickPickCard(index: 1, width: 53, verticalText: true),

          const SizedBox(width: 10),

          _quickPickCard(index: 2, width: 53, verticalText: true),

          const SizedBox(width: 10),

          _quickPickCard(index: 3, width: 53, verticalText: true),
        ],
      ),
    );
  }

  Widget _quickPickCard({
    required int index,
    required double width,
    required bool verticalText,
  }) {
    final song = songs[index % songs.length];

    return GestureDetector(
      onTap: () {
        playTestSong(title: song['title']!, artist: song['genre']!);
      },
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: [
            const Color(0xFFD8F8EE),
            const Color(0xFFA7DCD3),
            const Color(0xFF91EBD5),
            const Color(0xFFB7C9F4),
          ][index % 4],
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.all(8),
        child: verticalText
            ? Center(
                child: RotatedBox(
                  quarterTurns: 1,
                  child: Text(
                    song['title']!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: _darkTeal,
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
                    song['title']!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: _darkTeal,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    song['genre']!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 10, color: _darkTeal),
                  ),
                ],
              ),
      ),
    );
  }

  // HOT & TRENDING

  Widget _buildTrending() {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        separatorBuilder: (_, _) => const SizedBox(width: 13),
        itemBuilder: (context, index) {
          final song = songs[index % songs.length];

          return Container(
            width: 92,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF46504F), Color(0xFF1B3D3E)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(7),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song['title']!,
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
                  song['genre']!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 8, color: Colors.white70),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // POPULAR PICKS

  Widget _buildPopular() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final song = songs[index % songs.length];

        return GestureDetector(
          onTap: () {
            playTestSong(title: song['title']!, artist: song['genre']!);
          },
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
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.music_note,
                    color: _mutedTeal,
                    size: 27,
                  ),
                ),

                const SizedBox(width: 11),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song['title']!,
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
                        song['genre']!,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.white,
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
                    color: likedSongs.contains(index) ? _mint : Colors.white70,
                  ),
                ),
              ],
            ),
          ),
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
