import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'models/music_track.dart';

class MusicRepository {
  final Dio _dio;

  MusicRepository(this._dio);

  Future<List<MusicTrack>> getTracksByMood(String mood) async {
    try {
      final response = await _dio.get(
        '/api/music/mood/$mood',
        options: Options(extra: {kSkipAuth: true}),
      );

      final data = response.data as Map<String, dynamic>;
      final tracks = data['tracks'] as List<dynamic>? ?? [];

      return tracks
          .map((track) => MusicTrack.fromJson(track as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<MusicTrack>> getTrendingTracks() async {
    try {
      final response = await _dio.get(
        '/api/music/trending',
        options: Options(extra: {kSkipAuth: true}),
      );

      final data = response.data as Map<String, dynamic>;
      final tracks = data['tracks'] as List<dynamic>? ?? [];

      return tracks
          .map((track) => MusicTrack.fromJson(track as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<MusicTrack>> searchTracks(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final response = await _dio.get(
        '/api/music/search',
        queryParameters: {'q': query.trim()},
        options: Options(extra: {kSkipAuth: true}),
      );

      final data = response.data as Map<String, dynamic>;
      final tracks = data['tracks'] as List<dynamic>? ?? [];

      return tracks
          .map((track) => MusicTrack.fromJson(track as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<MusicTrack?> getTrackById(String id) async {
    try {
      final response = await _dio.get(
        '/api/music/$id',
        options: Options(extra: {kSkipAuth: true}),
      );

      final data = response.data as Map<String, dynamic>;
      final track = data['track'];

      if (track == null) return null;

      return MusicTrack.fromJson(track as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
