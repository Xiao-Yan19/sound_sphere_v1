import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../auth/application/auth_controller.dart';
import '../../auth/presentation/widgets/auth_widgets.dart';

/// Temporary landing screen after login - replace with the real home later.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      backgroundColor: AuthColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Welcome, ${user?.shownName ?? ''}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '@${user?.username ?? ''}  •  ${user?.email ?? ''}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AuthColors.icon,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 160,
                  child: AuthPrimaryButton(
                    label: 'Log out',
                    onPressed: () =>
                        ref.read(authControllerProvider.notifier).logout(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
