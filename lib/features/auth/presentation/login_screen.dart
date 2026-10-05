import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF173F3E), Color(0xFF48676D)],
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // LOGO
                  // ==================================================

                  const SizedBox(height: 20),

                  const Center(child: _LogoPlaceholder()),

                  const SizedBox(height: 55),

                  // ==================================================
                  // WELCOME
                  // ==================================================
                  Text(
                    'Welcome Back',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // EMAIL
                  // ==================================================
                  _FieldLabel(text: 'Email address'),

                  const SizedBox(height: 6),

                  _LoginTextField(
                    controller: emailController,
                    hintText: 'you@example.com',
                    prefixIcon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // PASSWORD
                  // ==================================================
                  _FieldLabel(text: 'Password'),

                  const SizedBox(height: 6),

                  _LoginTextField(
                    controller: passwordController,
                    hintText: '••••••••••••••',
                    prefixIcon: Icons.lock_outline,
                    obscureText: obscurePassword,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 19,
                        color: const Color(0xFF315958),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ==================================================
                  // FORGOT PASSWORD
                  // ==================================================
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Forgot password will be implemented later.
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: 4,
                        ),
                        minimumSize: const Size(0, 0),
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

                  const SizedBox(height: 22),

                  // ==================================================
                  // LOGIN BUTTON
                  // ==================================================
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        // Login API will be connected later.
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7DE5D0),
                        foregroundColor: const Color(0xFF173F3E),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        'Log in',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 42),

                  // ==================================================
                  // OR DIVIDER
                  // ==================================================
                  const _OrDivider(),

                  const SizedBox(height: 27),

                  // ==================================================
                  // GOOGLE BUTTON
                  // ==================================================
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: OutlinedButton(
                      onPressed: () {
                        // Google authentication later.
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFF4BA293),
                        side: BorderSide.none,
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

                  // ==================================================
                  // SIGN UP
                  // ==================================================
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?  ",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),

                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(0),
                            child: Text(
                              'Sign Up',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// FIELD LABEL
// ================================================================

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel({required this.text});

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
// TEXT FIELD
// ================================================================

class _LoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;

  final bool obscureText;
  final Widget? suffixIcon;

  final TextInputType? keyboardType;

  const _LoginTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,

        style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF173F3E)),

        cursorColor: const Color(0xFF173F3E),

        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFF72B7AA),

          hintText: hintText,

          hintStyle: GoogleFonts.inter(
            fontSize: 9,
            color: const Color(0xFF547F79),
          ),

          prefixIcon: Icon(
            prefixIcon,
            size: 17,
            color: const Color(0xFF315958),
          ),

          suffixIcon: suffixIcon,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 0,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide.none,
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Color(0xFF7DE5D0), width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// OR DIVIDER
// ================================================================

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.white, thickness: 2)),

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

        const Expanded(child: Divider(color: Colors.white, thickness: 2)),
      ],
    );
  }
}

// ================================================================
// LOGO PLACEHOLDER
// ================================================================

class _LogoPlaceholder extends StatelessWidget {
  const _LogoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ----------------------------------------------------------
        // YOUR LOGO GOES HERE
        // ----------------------------------------------------------

        Image.asset(
          'assets/images/Logo.png',
          width: 110,
          height: 110,
          fit: BoxFit.contain,
        ),

        const SizedBox(height: 10),

        Text(
          'SOUND SPHERE',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
            color: Colors.white,
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
    );
  }
}
