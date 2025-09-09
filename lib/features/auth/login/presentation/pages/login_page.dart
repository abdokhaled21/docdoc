import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/routes/app_router.dart';
import '../controllers/login_controller.dart';
import '../widgets/login_fields.dart';
import '../widgets/remember_forgot_row.dart';
import '../widgets/primary_button.dart';
import '../widgets/social_section.dart';
import '../../../../../core/storage/local_storage.dart';
import '../../../data/auth_repository.dart';
import '../../../../../core/network/api_error.dart';
import '../../../../../core/widgets/app_flushbar.dart';

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
              const side = 24.0;
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(side, 72, side, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 96),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        Text(
                          "We're excited to have you back, can't wait to see what you've been up to since you last logged in.",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white.withValues(alpha: 0.85) : Colors.black.withValues(alpha: 0.70),
                            fontSize: 16,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 36),
                        const LoginFields(),
                        const SizedBox(height: 16),
                        const RememberForgotRow(),
                        const SizedBox(height: 24),
                        Consumer<LoginController>(
                          builder: (context, c, _) {
                            final emailValid = RegExp(r'^\S+@\S+\.\S+$').hasMatch(c.email);
                            final passValid = c.password.length >= 6;
                            final enabled = emailValid && passValid;
                            return PrimaryButton(
                              text: 'Login',
                              enabled: enabled,
                              loading: c.submitting,
                              onDisabledPressed: () async {
                                final missing = <String>[];
                                if (!emailValid) missing.add('Valid email');
                                if (!passValid) missing.add('Password (min 6 chars)');
                                if (context.mounted && missing.isNotEmpty) {
                                  await showTopFlushbar(context, 'Please fill: ${missing.join(', ')}');
                                }
                              },
                              onPressed: () async {
                                await c.submit(onLogin: (email, password, remember) async {
                                  try {
                                    final (token, user) = await AuthRepository.instance.login(
                                      email: email,
                                      password: password,
                                    );
                                    await LocalStorage.instance.setToken(token, remember: c.remember);
                                    if (context.mounted) {
                                      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
                                    }
                                  } catch (e) {
                                    final msg = (e is ApiError) ? e.message : 'Login failed';
                                    if (e is ApiError) {
                                      c.setFieldErrors(e.fieldErrors);
                                    }
                                    if (context.mounted) {
                                      await showTopFlushbar(context, msg);
                                    }
                                  }
                                });
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 24),

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
                        const SocialSection(),
                        const SizedBox(height: 24),
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
                              onPressed: () {
                                Navigator.of(context).pushReplacementNamed(AppRoutes.signup);
                              },
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
