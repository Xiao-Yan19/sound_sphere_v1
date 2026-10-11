import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/application/auth_controller.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/widgets/auth_widgets.dart';
import '../features/home/presentation/home_screen.dart';
import 'theme.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

class SoundSphereApp extends ConsumerWidget {
  const SoundSphereApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Whenever the login state changes (login, register, logout, expired
    // session), close any screens pushed on top (e.g. RegisterScreen) so
    // AuthGate's choice is the one the user sees.
    ref.listen<AuthStatus>(
      authControllerProvider.select((s) => s.status),
      (previous, next) {
        if (next != AuthStatus.unknown) {
          _navigatorKey.currentState?.popUntil((route) => route.isFirst);
        }
      },
    );

    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'SoundSphere',
      theme: AppTheme.darkTheme,
      home: const AuthGate(),
    );
  }
}

/// Chooses the first screen:
///   checking saved session -> splash
///   valid session          -> home (auto-login)
///   no session             -> login
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(authControllerProvider.select((s) => s.status));

    switch (status) {
      case AuthStatus.unknown:
        return const _SplashScreen();
      case AuthStatus.authenticated:
        return const HomeScreen();
      case AuthStatus.unauthenticated:
        return const LoginScreen();
    }
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AuthColors.background,
      body: Center(child: CircularProgressIndicator(color: AuthColors.mint)),
    );
  }
}
