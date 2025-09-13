import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../login/presentation/widgets/primary_button.dart';
import '../controllers/forgot_controller.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  OutlineInputBorder _border(BuildContext context, Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: 1),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0x1A000000);
    final focusColor = AppColors.primary;
    final hintColor = isDark ? Colors.white.withValues(alpha: 0.55) : const Color(0x99000000);

    return ChangeNotifierProvider(
      create: (_) => ForgotController(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 72, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Forgot Password',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'At our app, we take the security of your\ninformation seriously.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white.withValues(alpha: 0.85) : Colors.black.withValues(alpha: 0.70),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                Consumer<ForgotController>(
                  builder: (context, c, _) => SizedBox(
                    height: 56,
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: 'Email or Phone Number',
                        hintStyle: TextStyle(color: hintColor),
                        filled: true,
                        fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        enabledBorder: _border(context, borderColor),
                        focusedBorder: _border(context, focusColor),
                      ),
                      onChanged: c.setInput,
                      onFieldSubmitted: (_) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                    ),
                  ),
                ),
                const Spacer(),
                Consumer<ForgotController>(
                  builder: (context, c, _) => PrimaryButton(
                    text: 'Reset Password',
                    enabled: c.isValid && !c.submitting,
                    loading: c.submitting,
                    onPressed: () async {
                      await c.submit(onSubmit: (value) async {
                        await Future.delayed(const Duration(seconds: 1));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('If the account exists, instructions were sent.')),
                          );
                          Navigator.of(context).pop();
                        }
                      });
                    },
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
