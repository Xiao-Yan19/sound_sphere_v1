import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ================================================================
// COLORS  (estimated from the Canva design - tweak with the
// eyedropper in Canva if you want them pixel-exact)
// ================================================================

class AuthColors {
  static const background = Color(0xFF203F40);
  static const fieldFill = Color(0xFF0C2222);
  static const fieldBorder = Color(0xFF4E9F93);
  static const fieldBorderFocused = Color(0xFF8CEBDD);
  static const hint = Color(0xFF5E8D88);
  static const inputText = Color(0xFFD9E6E4);
  static const icon = Color(0xFFB8C8C8);
  static const mint = Color(0xFF8DEFD3);
  static const onMint = Color(0xFF173536);
  static const googleButton = Color(0xFF459A8C);
  static const error = Color(0xFFFF9C94);
}

// ================================================================
// PAGE SHELL (solid background, scrollable)
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
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// TITLE + LABEL
// ================================================================

class AuthTitle extends StatelessWidget {
  const AuthTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.white,
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
// TEXT FIELD  (dark fill + mint border, same on both screens)
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
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
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
// BUTTON (shows a spinner while loading)
// ================================================================

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
      height: 40,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AuthColors.mint,
          foregroundColor: AuthColors.onMint,
          disabledBackgroundColor: AuthColors.mint.withValues(alpha: 0.7),
          disabledForegroundColor: AuthColors.onMint,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
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
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}

// ================================================================
// ERROR TEXT (keeps the Canva layout; appears only when needed)
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
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
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
