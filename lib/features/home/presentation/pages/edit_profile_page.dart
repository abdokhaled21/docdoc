import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/phone_number_field.dart';
import '../../../../features/auth/login/presentation/widgets/primary_button.dart';
import '../controllers/edit_profile_controller.dart';
import '../../../../core/widgets/app_flushbar.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      SystemChrome.setSystemUIOverlayStyle(
        (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
          statusBarColor: theme.scaffoldBackgroundColor,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
      );
    });
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarColor: const Color(0xFF247CFF),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
    super.dispose();
  }

  OutlineInputBorder _border(BuildContext context, {required bool error}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0x1A000000);
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: error ? Colors.red : borderColor, width: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hintColor = isDark ? Colors.white.withValues(alpha: 0.55) : const Color(0x99000000);

    return ChangeNotifierProvider(
      create: (_) => EditProfileController()..load(),
      child: Builder(builder: (context) {
        final c = context.watch<EditProfileController>();
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light.copyWith(
              statusBarColor: theme.scaffoldBackgroundColor,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: SvgPicture.asset(
                            'assets/icons/Chevron-left2.svg',
                            width: 22,
                            height: 22,
                            colorFilter: ColorFilter.mode(
                              isDark ? Colors.white : const Color(0xFF1D1E20),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Personal information',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: isDark ? Colors.white : const Color(0xFF1D1E20),
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 10),
                          Center(
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: isDark ? theme.scaffoldBackgroundColor : Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const CircleAvatar(
                                    radius: 53,
                                    backgroundColor: Color(0xFFE9E2FF),
                                    backgroundImage: AssetImage('assets/images/profile.png'),
                                  ),
                                ),
                                Positioned(
                                  right: -2,
                                  bottom: -2,
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: theme.scaffoldBackgroundColor,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: SvgPicture.asset(
                                      'assets/icons/edit-2.svg',
                                      width: 16,
                                      height: 16,
                                      colorFilter: const ColorFilter.mode(Color(0xFF247CFF), BlendMode.srcIn),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 56,
                            child: TextFormField(
                              controller: c.nameController,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                hintText: 'Omar Ahmed',
                                hintStyle: TextStyle(color: hintColor),
                                filled: true,
                                fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                enabledBorder: _border(context, error: c.errorFor('name') != null),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: c.errorFor('name') != null ? Colors.red : AppColors.primary, width: 1),
                                ),
                              ),
                            ),
                          ),
                          if (c.errorFor('name') != null) ...[
                            const SizedBox(height: 6),
                            Text(c.errorFor('name')!, style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
                          ],
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 56,
                            child: TextFormField(
                              controller: c.emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                hintText: 'omarahmed14@gmail.com',
                                hintStyle: TextStyle(color: hintColor),
                                filled: true,
                                fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                enabledBorder: _border(context, error: c.errorFor('email') != null),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: c.errorFor('email') != null ? Colors.red : AppColors.primary, width: 1),
                                ),
                              ),
                            ),
                          ),
                          if (c.errorFor('email') != null) ...[
                            const SizedBox(height: 6),
                            Text(c.errorFor('email')!, style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
                          ],
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 56,
                            child: TextFormField(
                              controller: c.passwordController,
                              obscureText: true,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                hintText: 'Password',
                                hintStyle: TextStyle(color: hintColor),
                                filled: true,
                                fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                enabledBorder: _border(context, error: c.errorFor('password') != null),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: c.errorFor('password') != null ? Colors.red : AppColors.primary, width: 1),
                                ),
                              ),
                            ),
                          ),
                          if (c.errorFor('password') != null) ...[
                            const SizedBox(height: 6),
                            Text(c.errorFor('password')!, style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
                          ],
                          const SizedBox(height: 16),
                          PhoneNumberField(
                            hintText: '+1 938756 878',
                            initialIsoCode: c.countryIso,
                            controller: c.phoneController,
                            isError: c.errorFor('phone') != null,
                            onChanged: (digits) => c.onPhoneChanged(digits),
                            onCountryChanged: (dial, iso) => c.onCountryChanged(dial, iso),
                          ),
                          if (c.errorFor('phone') != null) ...[
                            const SizedBox(height: 6),
                            Text(c.errorFor('phone')!, style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
                          ],
                          const SizedBox(height: 16),
                          Text(
                            'When you set up your personal information settings, you should take care to provide accurate information.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.white.withValues(alpha: 0.55) : const Color(0x99000000),
                            ),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: PrimaryButton(
                text: 'Save',
                enabled: c.canSubmit && !c.saving,
                loading: c.saving,
                onPressed: () async {
                  final ok = await c.submit();
                  if (!context.mounted) return;
                  if (ok) {
                    await showTopFlushbar(context, 'Saved successfully', type: AppFlushType.success);
                    if (!context.mounted) return;
                    Navigator.of(context).pop(true);
                  } else {
                    await showTopFlushbar(context, c.error ?? 'Something went wrong', type: AppFlushType.error);
                  }
                },
              ),
            ),
          ),
        );
      }),
    );
  }
}
