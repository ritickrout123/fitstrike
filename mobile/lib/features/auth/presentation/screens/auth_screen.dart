import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/theme.dart';
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
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
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF151B2A),
                              Color(0xFF0C1018),
                            ],
                          ),
                          border: Border.all(color: AppColors.borderStrong),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 74,
                                  height: 74,
                                  decoration: BoxDecoration(
                                    color: AppColors.limeDim,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: AppColors.lime.withOpacity(0.22),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.bolt_rounded,
                                    color: AppColors.lime,
                                    size: 34,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            RichText(
                              text: TextSpan(
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.3,
                                ),
                                children: const [
                                  TextSpan(text: 'FIT'),
                                  TextSpan(
                                    text: 'STRIKE',
                                    style: TextStyle(color: AppColors.lime),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'CONQUER YOUR TURF',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: AppColors.textSecondary,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _AuthFieldLabel(label: 'Email'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                hintText: 'striker@fitstrike.gg',
                              ),
                            ),
                            const SizedBox(height: 16),
                            _AuthFieldLabel(label: 'Password'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                hintText: '********',
                              ),
                            ),
                            const SizedBox(height: 22),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: authState.isLoading
                                    ? null
                                    : () async {
                                        await ref
                                            .read(
                                                authControllerProvider.notifier)
                                            .signIn(
                                              email:
                                                  _emailController.text.trim(),
                                              password:
                                                  _passwordController.text,
                                            );
                                      },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(
                                    authState.isLoading
                                        ? 'AUTHENTICATING...'
                                        : 'INITIALIZE PROTOCOL',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Center(
                              child: Text(
                                authState.errorMessage ??
                                    'Use the seeded account to enter the app.',
                                style: theme.textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 22),
                            Row(
                              children: [
                                const Expanded(
                                    child:
                                        Divider(color: AppColors.borderStrong)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Text(
                                    'OR CONTINUE WITH',
                                    style: theme.textTheme.labelMedium,
                                  ),
                                ),
                                const Expanded(
                                    child:
                                        Divider(color: AppColors.borderStrong)),
                              ],
                            ),
                            const SizedBox(height: 18),
                            const Row(
                              children: [
                                Expanded(
                                  child: _SocialButton(
                                    icon: Icons.g_mobiledata_rounded,
                                    iconColor: Color(0xFF34A853),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: _SocialButton(
                                    icon: Icons.apple_rounded,
                                    iconColor: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: _SocialButton(
                                    icon: Icons.facebook_rounded,
                                    iconColor: Color(0xFF1877F2),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Center(
                              child: Text(
                                'Forgot Password?  |  Create Account',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthFieldLabel extends StatelessWidget {
  const _AuthFieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium,
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.iconColor,
  });

  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderStrong),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: iconColor, size: 28),
    );
  }
}
