
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class SoundSphereAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  SoundSphereAudioHandler() {
    _player.playbackEventStream.listen(_broadcastState);

    _player.durationStream.listen((duration) {
      if (duration != null) {
        mediaItem.add(
          mediaItem.value?.copyWith(duration: duration),
        );
      }
    });
  }

  AudioPlayer get player => _player;

  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;

    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: switch (_player.processingState) {
          ProcessingState.idle => AudioProcessingState.idle,
          ProcessingState.loading => AudioProcessingState.loading,
          ProcessingState.buffering => AudioProcessingState.buffering,
          ProcessingState.ready => AudioProcessingState.ready,
          ProcessingState.completed => AudioProcessingState.completed,
        },
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ),
    );
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) {
    return _player.seek(position);
  }

  @override
  Future<void> skipToPrevious() async {
    await _player.seekToPrevious();
  }

  @override
  Future<void> skipToNext() async {
    await _player.seekToNext();
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    await _player.seek(Duration.zero, index: index);
    await play();
  }

  Future<void> playUrl({
    required String url,
    required String title,
    required String artist,
    String? album,
    String? artworkUrl,
  }) async {
    final item = MediaItem(
      id: url,
      title: title,
      artist: artist,
      album: album ?? 'SoundSphere',
      artUri: artworkUrl != null
          ? Uri.tryParse(artworkUrl)
          : null,
    );

    mediaItem.add(item);

    await _player.setAudioSource(
      AudioSource.uri(
        Uri.parse(url),
        tag: item,
      ),
    );

    await play();
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
