import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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

                  const Center(child: _Logo()),

                  const SizedBox(height: 45),

                  // ==================================================
                  // TITLE
                  // ==================================================
                  Text(
                    'Create Your Account',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // FULL NAME
                  // ==================================================
                  const _FieldLabel(text: 'Full Name'),

                  const SizedBox(height: 6),

                  _RegisterTextField(
                    controller: fullNameController,
                    hintText: 'Your Name',
                    prefixIcon: Icons.person,
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // EMAIL
                  // ==================================================
                  const _FieldLabel(text: 'Email address'),

                  const SizedBox(height: 6),

                  _RegisterTextField(
                    controller: emailController,
                    hintText: 'you@example.com',
                    prefixIcon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // PASSWORD
                  // ==================================================
                  const _FieldLabel(text: 'Password'),

                  const SizedBox(height: 6),

                  _RegisterTextField(
                    controller: passwordController,
                    hintText: '••••••••••••••',
                    prefixIcon: Icons.lock_outline,
                    obscureText: obscurePassword,
                    textInputAction: TextInputAction.next,
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

                  const SizedBox(height: 18),

                  // ==================================================
                  // CONFIRM PASSWORD
                  // ==================================================
                  const _FieldLabel(text: 'Confirm Password'),

                  const SizedBox(height: 6),

                  _RegisterTextField(
                    controller: confirmPasswordController,
                    hintText: '••••••••••••••',
                    prefixIcon: Icons.lock_outline,
                    obscureText: obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        });
                      },
                      icon: Icon(
                        obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 19,
                        color: const Color(0xFF315958),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ==================================================
                  // CREATE ACCOUNT
                  // ==================================================
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        // Backend connection later
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
                        'Create Account',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 45),

                  // ==================================================
                  // LOGIN
                  // ==================================================
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text(
                          'Already have an account?  ',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),

                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(0),
                            child: Text(
                              'Log in',
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
// REGISTER TEXT FIELD
// ================================================================

class _RegisterTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;

  final bool obscureText;
  final Widget? suffixIcon;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  const _RegisterTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,

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
// LOGO
// ================================================================

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
