
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../data/models/music_playlist.dart';
import '../data/models/music_track.dart';

final playlistsProvider =
    AsyncNotifierProvider<PlaylistsNotifier, List<MusicPlaylist>>(
  PlaylistsNotifier.new,
);

class PlaylistsNotifier extends AsyncNotifier<List<MusicPlaylist>> {
  static const String _storageKey = 'sound_sphere_playlists';

  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  @override
  Future<List<MusicPlaylist>> build() async {
    try {
      final saved = await _storage.read(key: _storageKey);

      if (saved == null || saved.isEmpty) {
        return [];
      }

      final decoded = jsonDecode(saved);

      if (decoded is! List) {
        return [];
      }

      final playlists = <MusicPlaylist>[];

      for (final item in decoded) {
        if (item is Map) {
          final playlist = MusicPlaylist.fromJson(
            Map<String, dynamic>.from(item),
          );

          if (playlist.id.isNotEmpty) {
            playlists.add(playlist);
          }
        }
      }

      return playlists;
    } catch (_) {
      return [];
    }
  }

  Future<List<MusicPlaylist>> _currentPlaylists() async {
    return state.asData?.value ?? await future;
  }

  // CREATE PLAYLIST
  Future<void> createPlaylist(String name) async {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) return;

    final current = await _currentPlaylists();

    final playlist = MusicPlaylist(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: trimmedName,
      tracks: [],
      createdAt: DateTime.now(),
    );

    final updated = [
      playlist,
      ...current,
    ];

    await _savePlaylists(updated);
  }

  // RENAME PLAYLIST
  Future<void> renamePlaylist(
    String playlistId,
    String newName,
  ) async {
    final trimmedName = newName.trim();

    if (trimmedName.isEmpty) return;

    final current = await _currentPlaylists();

    final updated = current.map((playlist) {
      if (playlist.id == playlistId) {
        return playlist.copyWith(name: trimmedName);
      }

      return playlist;
    }).toList();

    await _savePlaylists(updated);
  }

  // DELETE PLAYLIST
  Future<void> deletePlaylist(String playlistId) async {
    final current = await _currentPlaylists();

    final updated = current
        .where((playlist) => playlist.id != playlistId)
        .toList();

    await _savePlaylists(updated);
  }

  // ADD SONG TO PLAYLIST
  Future<void> addTrack(
    String playlistId,
    MusicTrack track,
  ) async {
    if (track.id.isEmpty) return;

    final current = await _currentPlaylists();

    final updated = current.map((playlist) {
      if (playlist.id != playlistId) {
        return playlist;
      }

      final alreadyExists = playlist.tracks.any(
        (song) => song.id == track.id,
      );

      if (alreadyExists) {
        return playlist;
      }

      return playlist.copyWith(
        tracks: [
          ...playlist.tracks,
          track,
        ],
      );
    }).toList();

    await _savePlaylists(updated);
  }

  // REMOVE SONG FROM PLAYLIST
  Future<void> removeTrack(
    String playlistId,
    String trackId,
  ) async {
    final current = await _currentPlaylists();

    final updated = current.map((playlist) {
      if (playlist.id != playlistId) {
        return playlist;
      }

      return playlist.copyWith(
        tracks: playlist.tracks
            .where((track) => track.id != trackId)
            .toList(),
      );
    }).toList();

    await _savePlaylists(updated);
  }

  // CLEAR ALL SONGS FROM A PLAYLIST
  Future<void> clearPlaylist(String playlistId) async {
    final current = await _currentPlaylists();

    final updated = current.map((playlist) {
      if (playlist.id == playlistId) {
        return playlist.copyWith(tracks: []);
      }

      return playlist;
    }).toList();

    await _savePlaylists(updated);
  }

  // SAVE PLAYLISTS TO LOCAL STORAGE
  Future<void> _savePlaylists(
    List<MusicPlaylist> playlists,
  ) async {
    try {
      await _storage.write(
        key: _storageKey,
        value: jsonEncode(
          playlists.map((playlist) => playlist.toJson()).toList(),
        ),
      );

      state = AsyncData(playlists);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
