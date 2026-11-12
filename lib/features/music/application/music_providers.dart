import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../data/music_repository.dart';
import '../data/models/music_track.dart';

final musicRepositoryProvider = Provider<MusicRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  return MusicRepository(apiClient.dio);
});

final trendingTracksProvider = FutureProvider<List<MusicTrack>>((ref) async {
  final repository = ref.watch(musicRepositoryProvider);

  return repository.getTrendingTracks();
});

final musicSearchProvider = FutureProvider.family<List<MusicTrack>, String>((
  ref,
  query,
) async {
  final repository = ref.watch(musicRepositoryProvider);

  return repository.searchTracks(query);
});

final moodTracksProvider =
    FutureProvider.family<List<MusicTrack>, String>((ref, mood) async {
  final repository = ref.watch(musicRepositoryProvider);

  const moodSlugs = <String, String>{
    'Relax': 'relax',
    'Romance': 'romance',
    'Workout': 'workout',
    'Feel Good': 'feel-good',
    'Sleep': 'sleep',
  };

  final slug = moodSlugs[mood] ?? mood.toLowerCase();

  return repository.getTracksByMood(slug);
});

