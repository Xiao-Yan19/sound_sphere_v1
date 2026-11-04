import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/audio_handler_provider.dart';
import 'player_screen.dart';

class TestAudioButton extends ConsumerStatefulWidget {
  const TestAudioButton({super.key});

  @override
  ConsumerState<TestAudioButton> createState() => _TestAudioButtonState();
}

class _TestAudioButtonState extends ConsumerState<TestAudioButton> {
  bool _loading = false;

  Future<void> _playTestTrack() async {
    setState(() => _loading = true);

    try {
      final handler = ref.read(audioHandlerProvider);

      await handler.playUrl(
        url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        title: 'SoundHelix Song 1',
        artist: 'SoundHelix',
        album: 'Test Audio',
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PlayerScreen()),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to play test audio: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _loading ? null : _playTestTrack,
      icon: _loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.play_arrow_rounded),
      label: const Text('Play Test Track'),
    );
  }
}
