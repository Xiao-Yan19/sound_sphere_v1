
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'features/player/application/audio_handler.dart';
import 'features/player/application/audio_handler_provider.dart';

late final SoundSphereAudioHandler audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  audioHandler = await AudioService.init(
    builder: () => SoundSphereAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.soundsphere.audio',
      androidNotificationChannelName: 'SoundSphere Playback',
      androidNotificationOngoing: true,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        audioHandlerProvider.overrideWithValue(audioHandler),
      ],
      child: const SoundSphereApp(),
    ),
  );
}
