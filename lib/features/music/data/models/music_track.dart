class MusicTrack {
  final String id;
  final String name;
  final String artistName;
  final String? albumName;
  final String? audioUrl;
  final String? imageUrl;
  final String? duration;

  const MusicTrack({
    required this.id,
    required this.name,
    required this.artistName,
    this.albumName,
    this.audioUrl,
    this.imageUrl,
    this.duration,
  });

  factory MusicTrack.fromJson(Map<String, dynamic> json) {
    return MusicTrack(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Track',
      artistName: json['artist_name']?.toString() ?? 'Unknown Artist',
      albumName: json['album_name']?.toString(),
      audioUrl: json['audio']?.toString(),
      imageUrl: json['image']?.toString(),
      duration: json['duration']?.toString(),
    );
  }
}