import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/theme.dart';
import '../../../../shared/animations/fade_slide_in.dart';
import '../../../../shared/widgets/fitstrike_button.dart';
import '../../../../shared/widgets/fitstrike_loader.dart';
import '../../../../shared/widgets/fitstrike_text_field.dart';
import '../controllers/auth_controller.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: 'striker@fitstrike.gg');
    _passwordController = TextEditingController(text: 'fitstrike123');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            // Background Gradients
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0x33C8FF00),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -60,
              child: Container(
                width: 240,
                height: 240,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0x2600E5FF),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: width > 480 ? 400 : width * 0.92),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1117),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Wordmark & Tagline
                        Center(
                          child: Column(
                            children: [
                              FadeSlideIn(
                                child: Image.asset(
                                  'assets/images/FitStrike.png',
                                  width: 180,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const FadeSlideIn(
                                delay: Duration(milliseconds: 100),
                                child: Text(
                                  'CONQUER YOUR TURF',
                                  style: TextStyle(
                                    fontFamily: 'Barlow Condensed',
                                    fontSize: 11,
                                    letterSpacing: 3.0,
                                    color: Color(0xFF378ADD),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 200),
                          child: FitStrikeTextField(
                            label: 'Email',
                            hintText: 'striker@fitstrike.gg',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 300),
                          child: FitStrikeTextField(
                            label: 'Password',
                            hintText: '********',
                            controller: _passwordController,
                            obscureText: true,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 400),
                          child: FitStrikeButton(
                            label: 'Initialize Protocol',
                            isLoading: authState.isLoading,
                            onPressed: () async {
                              await ref
                                  .read(authControllerProvider.notifier)
                                  .signIn(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text,
                                  );
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Loading Error / Info
                        Center(
                          child: Text(
                            authState.errorMessage ??
                                'Use the seeded account to enter the app.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        const SizedBox(height: 22),
                        
                        // Divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'OR CONTINUE WITH',
                                style: TextStyle(
                                  fontSize: 11,
                                  letterSpacing: 1.5,
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
                          ],
                        ),
                        
                        const SizedBox(height: 18),
                        
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 700),
                          child: Row(
                            children: [
                              Expanded(
                                child: FitStrikeButton(
                                  label: 'Google',
                                  variant: FitStrikeButtonVariant.secondary,
                                  icon: Icons.g_mobiledata_rounded,
                                  onPressed: () {},
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FitStrikeButton(
                                  label: 'Apple',
                                  variant: FitStrikeButtonVariant.secondary,
                                  icon: Icons.apple_rounded,
                                  onPressed: () {},
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FitStrikeButton(
                                  label: 'Meta',
                                  variant: FitStrikeButtonVariant.secondary,
                                  icon: Icons.facebook_rounded,
                                  onPressed: () {},
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 22),
                        
                        // Footer Links
                        Center(
                          child: Text(
                            'Forgot Password?  |  Create Account',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Interactive Loader
            if (authState.isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: FitStrikeLoader(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
