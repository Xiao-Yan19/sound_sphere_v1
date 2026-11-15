
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class SoundSphereAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  List<MediaItem> _queueItems = [];

  SoundSphereAudioHandler() {
    _player.playbackEventStream.listen(_broadcastState);

    _player.durationStream.listen((duration) {
      if (duration != null && mediaItem.value != null) {
        mediaItem.add(
          mediaItem.value!.copyWith(duration: duration),
        );
      }
    });

    _player.currentIndexStream.listen((index) {
      if (index != null &&
          index >= 0 &&
          index < _queueItems.length) {
        mediaItem.add(_queueItems[index]);
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
        shuffleMode: _player.shuffleModeEnabled
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
        repeatMode: switch (_player.loopMode) {
          LoopMode.off => AudioServiceRepeatMode.none,
          LoopMode.one => AudioServiceRepeatMode.one,
          LoopMode.all => AudioServiceRepeatMode.all,
        },
      ),
    );
  }

  // PLAY
  @override
  Future<void> play() => _player.play();

  // PAUSE
  @override
  Future<void> pause() => _player.pause();

  // STOP
  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  // SEEK
  @override
  Future<void> seek(Duration position) {
    return _player.seek(position);
  }

  // PREVIOUS SONG
  @override
  Future<void> skipToPrevious() async {
    if (_player.hasPrevious) {
      await _player.seekToPrevious();
    } else {
      await _player.seek(Duration.zero);
    }
  }

  // NEXT SONG
  @override
  Future<void> skipToNext() async {
    if (_player.hasNext) {
      await _player.seekToNext();
    }
  }

  // PLAY A PARTICULAR SONG FROM THE QUEUE
  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= _queueItems.length) return;

    await _player.seek(
      Duration.zero,
      index: index,
    );

    await play();
  }

  // LOAD AND PLAY A QUEUE OF SONGS
  Future<void> playQueue({
    required List<MediaItem> items,
    int initialIndex = 0,
  }) async {
    if (items.isEmpty) return;

    if (initialIndex < 0 || initialIndex >= items.length) {
      initialIndex = 0;
    }

    _queueItems = List<MediaItem>.from(items);

    queue.add(_queueItems);
    mediaItem.add(_queueItems[initialIndex]);

    final sources = _queueItems.map((item) {
      return AudioSource.uri(
        Uri.parse(item.id),
        tag: item,
      );
    }).toList();

    await _player.setAudioSources(
      sources,
      initialIndex: initialIndex,
      initialPosition: Duration.zero,
    );

    await play();
  }

  // SHUFFLE
  Future<void> setShuffle(bool enabled) async {
    await _player.setShuffleModeEnabled(enabled);

    if (enabled) {
      await _player.shuffle();
    }
  }

  bool get isShuffleEnabled => _player.shuffleModeEnabled;

  // REPEAT ONE / OFF
  Future<void> toggleRepeatOne() async {
    await _player.setLoopMode(
      _player.loopMode == LoopMode.one
          ? LoopMode.off
          : LoopMode.one,
    );
  }

  bool get isRepeatOneEnabled => _player.loopMode == LoopMode.one;

  // BACKWARD COMPATIBILITY WITH YOUR EXISTING HOMESCREEN
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

    await playQueue(items: [item]);
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
