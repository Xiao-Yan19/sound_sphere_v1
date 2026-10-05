import 'package:flutter/material.dart';

import '../features/auth/presentation/login_screen.dart';
import 'theme.dart';

class SoundSphereApp extends StatelessWidget {
  const SoundSphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'SoundSphere',

      theme: AppTheme.darkTheme,

      home: const LoginScreen(),
    );
  }
}