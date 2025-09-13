import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/routes/app_router.dart';
import '../../../login/presentation/widgets/primary_button.dart';
import '../../../login/presentation/widgets/social_section.dart';
import '../controllers/signup_controller.dart';
import '../widgets/signup_fields.dart';
import '../../../../../core/storage/local_storage.dart';
import '../../../data/auth_repository.dart';
import '../../../../../core/network/api_error.dart';
import '../../../../../core/widgets/app_flushbar.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (_) => SignupController(),
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
                          'Create Account',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Sign up now and start exploring all that our app has to offer. We're excited to welcome you to our community!",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white.withValues(alpha: 0.85) : Colors.black.withValues(alpha: 0.70),
                            fontSize: 16,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 36),
                        const SignupFields(),
                        const SizedBox(height: 24),
                        Consumer<SignupController>(
                          builder: (context, c, _) {
                            final emailValid = RegExp(r'^\S+@\S+\.\S+$').hasMatch(c.email);
                            final passValid = c.password.length >= 6;
                            final enabled = emailValid && passValid && c.phoneValid;
                            return PrimaryButton(
                              text: 'Create Account',
                              enabled: enabled,
                              loading: c.submitting,
                              onDisabledPressed: () async {
                                final missing = <String>[];
                                if (!emailValid) missing.add('Valid email');
                                if (!passValid) missing.add('Password (min 6 chars)');
                                if (!c.phoneValid) missing.add('Valid phone number');
                                if (context.mounted && missing.isNotEmpty) {
                                  await showTopFlushbar(context, 'Please fill: ${missing.join(', ')}');
                                }
                              },
                              onPressed: () async {
                                final result = await showModalBottomSheet<({String name, String gender, String confirm})>(
                                  context: context,
                                  isScrollControlled: true,
                                  useSafeArea: true,
                                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                  ),
                                  builder: (ctx) => _NameGenderSheet(password: c.password, controller: c),
                                );
                                if (result == null) return;
                                c.setName(result.name);
                                c.setGender(result.gender);
                                c.setConfirmPassword(result.confirm);
                                await c.submit(onSignup: (name, email, password, phone, code, gender) async {
                                  try {
                                    final (token, user) = await AuthRepository.instance.register(
                                      name: name,
                                      email: email,
                                      phone: '$code$phone',
                                      gender: gender,
                                      password: password,
                                      passwordConfirmation: c.confirmPassword,
                                    );
                                    await LocalStorage.instance.setToken(token);
                                    if (context.mounted) {
                                      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
                                    }
                                  } catch (e) {
                                    final msg = (e is ApiError) ? e.message : 'Registration failed';
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
                                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                              ),
                              child: Text(
                                'Sign In',
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

class _NameGenderSheet extends StatefulWidget {
  const _NameGenderSheet({required this.password, required this.controller});
  final String password;
  final SignupController controller;

  @override
  State<_NameGenderSheet> createState() => _NameGenderSheetState();
}

class _NameGenderSheetState extends State<_NameGenderSheet> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();
  String _gender = '';
  bool _obscureConfirm = true;

  OutlineInputBorder _border(BuildContext context, Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: 1),
      );

  @override
  void dispose() {
    _nameCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0x1A000000);
    final focusColor = AppColors.primary;
    final hintColor = isDark ? Colors.white.withValues(alpha: 0.55) : const Color(0x99000000);
    final nameError = c.errorFor('name');
    final genderError = c.errorFor('gender');
    final confirmError = c.errorFor('password_confirmation');
    final confirmMismatch = _confirmCtrl.text.isNotEmpty && _confirmCtrl.text != widget.password;

    Widget chip(String value, String label) {
      final selected = _gender == value;
      final showError = genderError != null && !selected;
      return Expanded(
        child: OutlinedButton(
          onPressed: () => setState(() => _gender = value),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: selected ? AppColors.primary : (showError ? Colors.red : borderColor), width: 1),
            backgroundColor: selected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
            foregroundColor: selected ? AppColors.primary : (isDark ? Colors.white : Colors.black),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      );
    }

    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Text(
                'Complete your profile',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 56,
                child: TextFormField(
                  controller: _nameCtrl,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'Full name',
                    hintStyle: TextStyle(color: hintColor),
                    filled: true,
                    fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    enabledBorder: _border(context, nameError != null ? Colors.red : borderColor),
                    focusedBorder: _border(context, nameError != null ? Colors.red : focusColor),
                    errorText: nameError,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  chip('male', 'Male'),
                  const SizedBox(width: 12),
                  chip('female', 'Female'),
                ],
              ),
              if (genderError != null) ...[
                const SizedBox(height: 6),
                Text(genderError, style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
              ],
              const SizedBox(height: 20),
              SizedBox(
                height: 56,
                child: TextFormField(
                  controller: _confirmCtrl,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: 'Confirm password',
                    hintStyle: TextStyle(color: hintColor),
                    filled: true,
                    fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    enabledBorder: _border(context, (confirmError != null || confirmMismatch) ? Colors.red : borderColor),
                    focusedBorder: _border(context, (confirmError != null || confirmMismatch) ? Colors.red : focusColor),
                    errorText: confirmError,
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              if (confirmError == null && confirmMismatch) ...[
                const SizedBox(height: 6),
                Text('Passwords do not match', style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
              ],
              const SizedBox(height: 20),
              PrimaryButton(
                text: 'Continue',
                enabled: _nameCtrl.text.trim().isNotEmpty && _gender.isNotEmpty && _confirmCtrl.text == widget.password && widget.password.length >= 6,
                onDisabledPressed: () async {
                  final missing = <String>[];
                  if (_nameCtrl.text.trim().isEmpty) missing.add('Full name');
                  if (_gender.isEmpty) missing.add('Gender');
                  if (!(_confirmCtrl.text == widget.password && widget.password.length >= 6)) missing.add('Confirm password');
                  if (context.mounted && missing.isNotEmpty) {
                    await showTopFlushbar(context, 'Please fill: ${missing.join(', ')}');
                  }
                },
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  final name = _nameCtrl.text.trim();
                  if (name.isEmpty || _gender.isEmpty) return;
                  if (!(_confirmCtrl.text == widget.password && widget.password.length >= 6)) return;
                  Navigator.of(context).pop((name: name, gender: _gender, confirm: _confirmCtrl.text));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
