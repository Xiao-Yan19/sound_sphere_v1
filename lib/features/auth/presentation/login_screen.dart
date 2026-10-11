import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/validators.dart';
import '../application/auth_controller.dart';
import 'register_screen.dart';
import 'widgets/auth_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter your email and password.');
      return;
    }
    if (!Validators.isEmail(email)) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref
          .read(authControllerProvider.notifier)
          .login(email: email, password: password);
      // Success: AuthGate swaps this screen for the home screen.
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _comingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature is coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      children: [
        const SizedBox(height: 20),
        const AuthLogo(),
        const SizedBox(height: 55),

        const AuthTitle('Welcome Back'),
        const SizedBox(height: 20),

        // EMAIL
        const AuthFieldLabel('Email address'),
        const SizedBox(height: 6),
        AuthTextField(
          controller: emailController,
          hintText: 'you@example.com',
          prefixIcon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          enabled: !_isLoading,
        ),
        const SizedBox(height: 18),

        // PASSWORD
        const AuthFieldLabel('Password'),
        const SizedBox(height: 6),
        AuthTextField(
          controller: passwordController,
          hintText: '••••••••••••••',
          prefixIcon: Icons.lock_outline,
          obscureText: obscurePassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          enabled: !_isLoading,
          suffixIcon: AuthVisibilityToggle(
            isObscured: obscurePassword,
            onPressed: () => setState(() => obscurePassword = !obscurePassword),
          ),
        ),
        const SizedBox(height: 8),

        // FORGOT PASSWORD
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => _comingSoon('Password reset'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Forgot Password ?',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),

        if (_error != null) ...[
          const SizedBox(height: 6),
          AuthErrorText(_error!),
        ],
        const SizedBox(height: 22),

        // LOGIN BUTTON
        AuthPrimaryButton(
          label: 'Log in',
          isLoading: _isLoading,
          onPressed: _submit,
        ),
        const SizedBox(height: 42),

        // OR DIVIDER
        const _OrDivider(),
        const SizedBox(height: 27),

        // GOOGLE BUTTON (decorative until Google sign-in is built)
        SizedBox(
          width: double.infinity,
          height: 40,
          child: OutlinedButton(
            onPressed: () => _comingSoon('Google sign-in'),
            style: OutlinedButton.styleFrom(
              backgroundColor: AuthColors.googleButton,
              side: const BorderSide(color: AuthColors.googleButton),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'G',
                  style: GoogleFonts.inter(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF00AFFF),
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  'Continue with Google',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),

        // SIGN UP LINK
        AuthBottomLink(
          prompt: "Don't have an account?",
          action: 'Sign Up',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            );
          },
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AuthColors.icon, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'or continue with',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AuthColors.icon, thickness: 1)),
      ],
    );
  }
}
