import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/validators.dart';
import '../application/auth_controller.dart';
import 'widgets/auth_widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  /// Returns an error message, or null when everything is valid.
  /// (Limits match the backend: name <= 50, password 8-72 characters.)
  String? _validate(
    String name,
    String email,
    String password,
    String confirm,
  ) {
    if (name.isEmpty) return 'Please enter your full name.';
    if (name.length > 50) return 'Full name must be 50 characters or fewer.';
    if (!Validators.isEmail(email)) return 'Please enter a valid email address.';
    if (password.length < 8 || password.length > 72) {
      return 'Password must be 8-72 characters.';
    }
    if (password != confirm) return 'Passwords do not match.';
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final name = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirm = confirmPasswordController.text;

    final problem = _validate(name, email, password, confirm);
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(authControllerProvider.notifier).register(
            fullName: name,
            email: email,
            password: password,
          );
      // Success: the user is now logged in; SoundSphereApp closes this
      // screen and AuthGate shows the home screen.
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

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      children: [
        const SizedBox(height: 20),
        const AuthLogo(),
        const SizedBox(height: 45),

        const AuthTitle('Create Your Account'),
        const SizedBox(height: 20),

        // FULL NAME
        const AuthFieldLabel('Full Name'),
        const SizedBox(height: 6),
        AuthTextField(
          controller: fullNameController,
          hintText: 'Your Name',
          prefixIcon: Icons.person,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          enabled: !_isLoading,
        ),
        const SizedBox(height: 18),

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
          textInputAction: TextInputAction.next,
          enabled: !_isLoading,
          suffixIcon: AuthVisibilityToggle(
            isObscured: obscurePassword,
            onPressed: () => setState(() => obscurePassword = !obscurePassword),
          ),
        ),
        const SizedBox(height: 18),

        // CONFIRM PASSWORD
        const AuthFieldLabel('Confirm Password'),
        const SizedBox(height: 6),
        AuthTextField(
          controller: confirmPasswordController,
          hintText: '••••••••••••••',
          prefixIcon: Icons.lock_outline,
          obscureText: obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          enabled: !_isLoading,
          suffixIcon: AuthVisibilityToggle(
            isObscured: obscureConfirmPassword,
            onPressed: () => setState(
              () => obscureConfirmPassword = !obscureConfirmPassword,
            ),
          ),
        ),

        if (_error != null) ...[
          const SizedBox(height: 12),
          AuthErrorText(_error!),
        ],
        const SizedBox(height: 22),

        // CREATE ACCOUNT
        AuthPrimaryButton(
          label: 'Create Account',
          isLoading: _isLoading,
          onPressed: _submit,
        ),
        const SizedBox(height: 70),

        // LOG IN LINK
        AuthBottomLink(
          prompt: 'Already have an account?',
          action: 'Log in',
          onTap: () => Navigator.pop(context),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
