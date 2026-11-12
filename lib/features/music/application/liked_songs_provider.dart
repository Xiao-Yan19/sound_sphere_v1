
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../data/models/music_track.dart';

final likedSongsProvider =
    AsyncNotifierProvider<LikedSongsNotifier, List<MusicTrack>>(
  LikedSongsNotifier.new,
);

class LikedSongsNotifier extends AsyncNotifier<List<MusicTrack>> {
  static const String _storageKey = 'sound_sphere_liked_songs';

  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  @override
  Future<List<MusicTrack>> build() async {
    try {
      final saved = await _storage.read(key: _storageKey);

      if (saved == null || saved.isEmpty) {
        return <MusicTrack>[];
      }

      final decoded = jsonDecode(saved);

      if (decoded is! List) {
        return <MusicTrack>[];
      }

      final songs = <MusicTrack>[];

      for (final item in decoded) {
        if (item is Map) {
          final track = MusicTrack.fromJson(
            Map<String, dynamic>.from(item),
          );

          if (track.id.isNotEmpty) {
            songs.add(track);
          }
        }
      }

      return songs;
    } catch (e, stackTrace) {
      // Keep the provider usable if stored data is invalid.
      return <MusicTrack>[];
    }
  }

  /// Add a song if it is not liked, otherwise remove it.
  Future<void> toggleLike(MusicTrack track) async {
    if (track.id.isEmpty) return;

    // Wait for the initial storage loading to finish.
    final List<MusicTrack> current = await future;

    final List<MusicTrack> updated = List<MusicTrack>.from(current);

    final index = updated.indexWhere(
      (MusicTrack song) => song.id == track.id,
    );

    if (index >= 0) {
      updated.removeAt(index);
    } else {
      updated.insert(0, track);
    }

    await _updateSongs(updated);
  }

  /// Alias for existing toggle(track) calls.
  Future<void> toggle(MusicTrack track) {
    return toggleLike(track);
  }

  /// Remove a song using its ID.
  Future<void> remove(String trackId) async {
    final List<MusicTrack> current = await future;

    final List<MusicTrack> updated = current
        .where((MusicTrack song) => song.id != trackId)
        .toList();

    await _updateSongs(updated);
  }

  /// Remove all liked songs.
  Future<void> clearAll() async {
    await _updateSongs(<MusicTrack>[]);
  }

  /// Check whether a song is liked.
  bool isLiked(String trackId) {
    final songs = state.asData?.value ?? <MusicTrack>[];

    return songs.any(
      (MusicTrack song) => song.id == trackId,
    );
  }

  /// Save changes to secure local storage.
  Future<void> _updateSongs(List<MusicTrack> songs) async {
    try {
      await _storage.write(
        key: _storageKey,
        value: jsonEncode(
          songs.map(_trackToJson).toList(),
        ),
      );

      state = AsyncData<List<MusicTrack>>(songs);
    } catch (e, stackTrace) {
      state = AsyncError<List<MusicTrack>>(e, stackTrace);
      rethrow;
    }
  }

  /// Convert MusicTrack into JSON.
  Map<String, dynamic> _trackToJson(MusicTrack track) {
    return {
      'id': track.id,
      'name': track.name,
      'artist_name': track.artistName,
      'album_name': track.albumName,
      'audio': track.audioUrl,
      'image': track.imageUrl,
      'duration': track.duration,
    };
  }
}
