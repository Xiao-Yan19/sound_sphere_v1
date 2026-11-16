import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sound_sphere_v1/app/theme.dart';

import '../application/music_providers.dart';
import '../data/models/music_track.dart';
import '../../player/application/audio_handler_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, required this.onGoHome});

  final VoidCallback onGoHome;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounceTimer;

  String _input = '';
  String _query = '';

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();

    setState(() {
      _input = value;
      _query = '';
    });

    if (value.trim().isEmpty) return;

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;

      setState(() {
        _query = _input.trim();
      });
    });
  }

  void _clearSearch() {
    _debounceTimer?.cancel();
    _searchController.clear();

    setState(() {
      _input = '';
      _query = '';
    });
  }

  Future<void> _playTrack(MusicTrack track) async {
    final audioUrl = track.audioUrl;

    if (audioUrl == null || audioUrl.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio is not available for this track.')),
      );
      return;
    }

    try {
      final handler = ref.read(audioHandlerProvider);

      await handler.playUrl(
        url: audioUrl,
        title: track.name,
        artist: track.artistName,
        album: track.albumName,
        artworkUrl: track.imageUrl,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not play this track: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // Header
          Row(
            children: [
              Material(
                color: AppColors.peachPale,
                borderRadius: BorderRadius.circular(13),
                child: IconButton(
                  tooltip: 'Go to Home',
                  onPressed: widget.onGoHome,
                  icon: const Icon(
                    Icons.home_rounded,
                    color: AppColors.primaryDark,
                    size: 25,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Discover Music',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              'Find your next favourite track',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),

          const SizedBox(height: 22),

          // Search field
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search songs or artists...',
              hintStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.primaryDark,
              ),
              suffixIcon: _input.isNotEmpty
                  ? IconButton(
                      onPressed: _clearSearch,
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary,
                      ),
                    )
                  : null,
              filled: true,
              fillColor: AppColors.cardBackground,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: AppColors.border, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: AppColors.primaryDark,
                  width: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          _buildSearchContent(),
        ],
      ),
    );
  }

  Widget _buildSearchContent() {
    if (_input.trim().isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.music_note_rounded,
                size: 54,
                color: AppColors.primary,
              ),
              SizedBox(height: 14),
              Text(
                'What do you want to listen to?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Search for songs or artists',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    if (_input.trim().length < 2) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Type at least 2 characters to search',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    if (_query.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryDark),
      );
    }

    final searchAsync = ref.watch(musicSearchProvider(_query));

    return searchAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryDark),
      ),

      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.primaryDark,
              size: 36,
            ),
            const SizedBox(height: 10),
            Text(
              'Could not search for music.\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                ref.invalidate(musicSearchProvider(_query));
              },
              child: const Text(
                'Try again',
                style: TextStyle(color: AppColors.primaryDark),
              ),
            ),
          ],
        ),
      ),

      data: (tracks) {
        if (tracks.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'No tracks found. Try another search.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 20),
          itemCount: tracks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 11),
          itemBuilder: (context, index) {
            final track = tracks[index];
            return _buildTrackTile(track);
          },
        );
      },
    );
  }

  Widget _buildTrackTile(MusicTrack track) {
    return Material(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: () => _playTrack(track),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.border, width: 0.7),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: track.imageUrl != null && track.imageUrl!.isNotEmpty
                    ? Image.network(
                        track.imageUrl!,
                        width: 55,
                        height: 55,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildArtworkPlaceholder(),
                      )
                    : _buildArtworkPlaceholder(),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      track.artistName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.play_circle_fill_rounded,
                color: AppColors.primaryDark,
                size: 31,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArtworkPlaceholder() {
    return Container(
      width: 55,
      height: 55,
      color: AppColors.peachPale,
      child: const Icon(
        Icons.music_note_rounded,
        color: AppColors.primaryDark,
        size: 27,
      ),
    );
  }
}
