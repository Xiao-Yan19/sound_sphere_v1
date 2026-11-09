import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/music_providers.dart';
import '../data/models/music_track.dart';
import '../../player/application/audio_handler_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounceTimer;

  String _input = '';
  String _query = '';

  static const Color _mint = Color(0xFF82E6D1);
  static const Color _cardColor = Color(0xFF173536);
  static const Color _secondaryText = Color(0xFF9AAEAB);

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
          const SizedBox(height: 24),

          const Text(
            'Discover Music',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Find your next favourite track',
            style: TextStyle(fontSize: 13, color: _secondaryText),
          ),

          const SizedBox(height: 22),

          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search songs or artists...',
              prefixIcon: const Icon(Icons.search, color: _mint),
              suffixIcon: _input.isNotEmpty
                  ? IconButton(
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.close, color: _secondaryText),
                    )
                  : null,
              filled: true,
              fillColor: _cardColor,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.music_note_rounded, size: 52, color: _mint),
            SizedBox(height: 12),
            Text(
              'What do you want to listen to?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Search for songs or artists',
              style: TextStyle(color: _secondaryText, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (_input.trim().length < 2) {
      return const Center(
        child: Text(
          'Type at least 2 characters to search',
          style: TextStyle(color: _secondaryText),
        ),
      );
    }

    if (_query.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: _mint));
    }

    final searchAsync = ref.watch(musicSearchProvider(_query));

    return searchAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: _mint)),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 36),
            const SizedBox(height: 10),
            Text(
              'Could not search for music.\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _secondaryText),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                ref.invalidate(musicSearchProvider(_query));
              },
              child: const Text('Try again', style: TextStyle(color: _mint)),
            ),
          ],
        ),
      ),
      data: (tracks) {
        if (tracks.isEmpty) {
          return const Center(
            child: Text(
              'No tracks found. Try another search.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _secondaryText),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 20),
          itemCount: tracks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final track = tracks[index];
            return _buildTrackTile(track);
          },
        );
      },
    );
  }

  Widget _buildTrackTile(MusicTrack track) {
    return InkWell(
      onTap: () => _playTrack(track),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: track.imageUrl != null && track.imageUrl!.isNotEmpty
                  ? Image.network(
                      track.imageUrl!,
                      width: 54,
                      height: 54,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildArtworkPlaceholder(),
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
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    track.artistName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _secondaryText, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            const Icon(Icons.play_circle_fill_rounded, color: _mint, size: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildArtworkPlaceholder() {
    return Container(
      width: 54,
      height: 54,
      color: const Color(0xFF203F40),
      child: const Icon(Icons.music_note_rounded, color: _mint, size: 26),
    );
  }
}
