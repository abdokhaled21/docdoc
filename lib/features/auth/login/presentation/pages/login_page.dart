import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_theme.dart';
import '../controllers/login_controller.dart';
import '../widgets/login_fields.dart';
import '../widgets/remember_forgot_row.dart';
import '../widgets/primary_button.dart';
import '../widgets/social_section.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return ChangeNotifierProvider(
      create: (_) => LoginController(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Layout paddings tuned to match the mock
              const side = 24.0;
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(side, 72, side, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 96),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          'Welcome Back',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Subtitle
                        Text(
                          "We're excited to have you back, can't wait to see what you've been up to since you last logged in.",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white.withValues(alpha: 0.85) : Colors.black.withValues(alpha: 0.70),
                            fontSize: 16,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Fields block
                        const LoginFields(),
                        const SizedBox(height: 16),

                        // Remember / Forgot
                        const RememberForgotRow(),
                        const SizedBox(height: 24),

                        // Login button
                        Consumer<LoginController>(
                          builder: (context, c, _) {
                            final emailValid = RegExp(r'^\S+@\S+\.\S+$').hasMatch(c.email);
                            final passValid = c.password.length >= 6;
                            final enabled = emailValid && passValid;
                            return PrimaryButton(
                              text: 'Login',
                              enabled: enabled,
                              loading: c.submitting,
                              onPressed: () async {
                                await c.submit(onLogin: (email, password, remember) async {
                                  // TODO: integrate real auth API
                                  await Future.delayed(const Duration(seconds: 1));
                                  if (context.mounted) {
                                    Navigator.of(context).pushReplacementNamed('/home');
                                  }
                                });
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        // Divider with text
                        Row(
                          children: [
                            Expanded(child: Divider(color: isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE9ECEF)) ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text('Or sign in with', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                            ),
                            Expanded(child: Divider(color: isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE9ECEF)) ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Social section
                        const SocialSection(),
                        const SizedBox(height: 24),

                        // Legal
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? Colors.white.withValues(alpha: 0.65) : Colors.black.withValues(alpha: 0.55),
                                height: 1.5,
                              ),
                              children: [
                                const TextSpan(text: 'By logging, you agree to our '),
                                TextSpan(
                                  text: 'Terms & Conditions',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                const TextSpan(text: '.'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Signup prompt
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account yet?',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                              ),
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
