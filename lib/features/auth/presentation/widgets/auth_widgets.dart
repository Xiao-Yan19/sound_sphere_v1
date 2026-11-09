import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme.dart';

// ================================================================
// COLORS - everything now comes from AppColors, so the auth screens
// always match the Home screen. Change colors in theme.dart.
// ================================================================

class AuthColors {
  static const background = AppColors.background;
  static const fieldFill = AppColors.cardBackground;
  static const fieldBorder = AppColors.primaryDark;
  static const fieldBorderFocused = AppColors.primary;
  static const hint = Color(0xFF8A8A8A);
  static const inputText = AppColors.textPrimary;
  static const icon = AppColors.textSecondary;
  static const mint = AppColors.primary;
  static const onMint = AppColors.background;
  static const divider = AppColors.divider;
  static const googleButton = AppColors.card;
  static const error = Color(0xFFFF9C94);
}

// ================================================================
// PAGE SHELL (flat Home background, scrollable)
// ================================================================

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthColors.background,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// LOGO  (SOUND in white, SPHERE in mint)
// ================================================================

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final base = GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    );

    return Center(
      child: Column(
        children: [
          Image.asset(
            'assets/images/Logo.png',
            width: 110,
            height: 110,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              style: base,
              children: const [
                TextSpan(
                  text: 'SOUND ',
                  style: TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: 'SPHERE',
                  style: TextStyle(color: AuthColors.mint),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Music Connect Us',
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// TITLE (same bold mint style as Home's section titles) + LABEL
// ================================================================

class AuthTitle extends StatelessWidget {
  const AuthTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
            color: AuthColors.mint,
          ),
        ),
      ),
    );
  }
}

class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    );
  }
}

// ================================================================
// TEXT FIELD  (Home card color, teal border, mint when focused)
// ================================================================

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.onSubmitted,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: TextField(
        controller: controller,
        enabled: enabled,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        textCapitalization: textCapitalization,
        onSubmitted: onSubmitted,
        autocorrect: false,
        enableSuggestions: !obscureText,
        textAlignVertical: TextAlignVertical.center,
        style: GoogleFonts.inter(fontSize: 12, color: AuthColors.inputText),
        cursorColor: AuthColors.fieldBorderFocused,
        decoration: InputDecoration(
          filled: true,
          fillColor: AuthColors.fieldFill,
          hintText: hintText,
          hintStyle: GoogleFonts.inter(fontSize: 9, color: AuthColors.hint),
          prefixIcon: Icon(prefixIcon, size: 17, color: AuthColors.icon),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          border: _border(AuthColors.fieldBorder, 1),
          enabledBorder: _border(AuthColors.fieldBorder, 1),
          disabledBorder: _border(AuthColors.fieldBorder, 1),
          focusedBorder: _border(AuthColors.fieldBorderFocused, 1.5),
        ),
      ),
    );
  }
}

class AuthVisibilityToggle extends StatelessWidget {
  const AuthVisibilityToggle({
    super.key,
    required this.isObscured,
    required this.onPressed,
  });

  final bool isObscured;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        isObscured
            ? Icons.visibility_outlined
            : Icons.visibility_off_outlined,
        size: 19,
        color: AuthColors.icon,
      ),
    );
  }
}

// ================================================================
// BUTTONS
// ================================================================

/// Mint button with dark text (shows a spinner while loading).
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AuthColors.mint,
          foregroundColor: AuthColors.onMint,
          disabledBackgroundColor: AuthColors.mint.withValues(alpha: 0.7),
          disabledForegroundColor: AuthColors.onMint,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AuthColors.onMint,
                ),
              )
            : Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

/// Grey gradient button, same look as Home's song rows
/// (used for "Continue with Google").
class AuthSecondaryButton extends StatelessWidget {
  const AuthSecondaryButton({
    super.key,
    required this.label,
    required this.leading,
    required this.onPressed,
  });

  final String label;
  final Widget leading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(10);

    return SizedBox(
      width: double.infinity,
      height: 44,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppGradients.card,
            borderRadius: radius,
            border: Border.all(color: AuthColors.divider),
          ),
          child: InkWell(
            borderRadius: radius,
            onTap: onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                leading,
                const SizedBox(width: 8),
                Text(
                  label,
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
      ),
    );
  }
}

// ================================================================
// ERROR TEXT (keeps the layout; appears only when needed)
// ================================================================

class AuthErrorText extends StatelessWidget {
  const AuthErrorText(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AuthColors.error,
      ),
    );
  }
}

// ================================================================
// BOTTOM LINK  ("Don't have an account?  Sign Up")
// ================================================================

class AuthBottomLink extends StatelessWidget {
  const AuthBottomLink({
    super.key,
    required this.prompt,
    required this.action,
    required this.onTap,
  });

  final String prompt;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            '$prompt  ',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                action,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AuthColors.mint,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}