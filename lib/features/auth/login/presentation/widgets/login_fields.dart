import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../controllers/login_controller.dart';

class LoginFields extends StatelessWidget {
  const LoginFields({super.key});

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: 1),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0x1A000000); // ~6% black
    final focusColor = AppColors.primary;
    final hintColor = isDark ? Colors.white.withValues(alpha: 0.55) : const Color(0x99000000); // ~60% black

    return Consumer<LoginController>(
      builder: (context, c, _) {
        return Column(
          children: [
            SizedBox(
              height: 56,
              child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(color: hintColor),
                  filled: true,
                  fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  enabledBorder: _border(borderColor),
                  focusedBorder: _border(focusColor),
                ),
                onChanged: c.setEmail,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 56,
              child: TextFormField(
                obscureText: c.obscure,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(color: hintColor),
                  filled: true,
                  fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  enabledBorder: _border(borderColor),
                  focusedBorder: _border(focusColor),
                  suffixIcon: IconButton(
                    onPressed: c.toggleObscure,
                    icon: Icon(c.obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                  ),
                ),
                onChanged: c.setPassword,
                onFieldSubmitted: (_) {},
              ),
            ),
          ],
        );
      },
    );
  }
}
