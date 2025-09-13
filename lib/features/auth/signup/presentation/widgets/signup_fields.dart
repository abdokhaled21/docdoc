import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_theme.dart';
import '../controllers/signup_controller.dart';
import '../../../../../core/widgets/phone_number_field.dart';

class SignupFields extends StatelessWidget {
  const SignupFields({super.key});

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
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

    return Consumer<SignupController>(
      builder: (context, c, _) {
        final emailError = c.errorFor('email');
        final passError = c.errorFor('password');
        final phoneError = c.errorFor('phone');
        return Column(
          children: [
            SizedBox(
              height: 56,
              child: TextFormField(
                controller: c.emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(color: hintColor),
                  filled: true,
                  fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  enabledBorder: _border(emailError != null ? Colors.red : borderColor),
                  focusedBorder: _border(emailError != null ? Colors.red : focusColor),
                ),
                onChanged: c.setEmail,
              ),
            ),
            if (emailError != null) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  emailError,
                  style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              height: 56,
              child: TextFormField(
                controller: c.passwordController,
                obscureText: c.obscure,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(color: hintColor),
                  filled: true,
                  fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  enabledBorder: _border(passError != null ? Colors.red : borderColor),
                  focusedBorder: _border(passError != null ? Colors.red : focusColor),
                  errorText: passError,
                  suffixIcon: IconButton(
                    onPressed: c.toggleObscure,
                    icon: Icon(c.obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                  ),
                ),
                onChanged: c.setPassword,
              ),
            ),
            const SizedBox(height: 16),
            PhoneNumberField(
              hintText: 'Your number',
              initialIsoCode: c.countryIso,
              controller: c.phoneController,
              isError: phoneError != null,
              onChanged: (number) {
                c.setPhone(number);
              },
              onCountryChanged: (dial, iso) {
                c.setCountryCode(dial);
                c.setCountryIso(iso);
              },
              onInfoChanged: ({required int digits, required int min, required int max, required bool valid}) {
                c.setPhoneInfo(digits: digits, min: min, max: max, valid: valid);
              },
            ),
            if (phoneError != null) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  phoneError,
                  style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
