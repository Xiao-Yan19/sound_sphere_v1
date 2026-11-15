
import 'music_track.dart';

class MusicPlaylist {
  final String id;
  final String name;
  final List<MusicTrack> tracks;
  final DateTime createdAt;

  const MusicPlaylist({
    required this.id,
    required this.name,
    required this.tracks,
    required this.createdAt,
  });

  MusicPlaylist copyWith({
    String? name,
    List<MusicTrack>? tracks,
  }) {
    return MusicPlaylist(
      id: id,
      name: name ?? this.name,
      tracks: tracks ?? this.tracks,
      createdAt: createdAt,
    );
  }

  factory MusicPlaylist.fromJson(Map<String, dynamic> json) {
    final rawTracks = json['tracks'];

    final tracks = <MusicTrack>[];

    if (rawTracks is List) {
      for (final item in rawTracks) {
        if (item is Map) {
          final track = MusicTrack.fromJson(
            Map<String, dynamic>.from(item),
          );

          if (track.id.isNotEmpty) {
            tracks.add(track);
          }
        }
      }
    }

    return MusicPlaylist(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Untitled Playlist',
      tracks: tracks,
      createdAt: DateTime.tryParse(
            json['createdAt']?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'tracks': tracks.map((track) {
        return {
          'id': track.id,
          'name': track.name,
          'artist_name': track.artistName,
          'album_name': track.albumName,
          'audio': track.audioUrl,
          'image': track.imageUrl,
          'duration': track.duration,
        };
      }).toList(),
    };
  }
}
