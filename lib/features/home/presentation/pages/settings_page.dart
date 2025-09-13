import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../../../../core/routes/app_router.dart';
import '../controllers/settings_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (_) => SettingsController(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFEAECEF)),
                        ),
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          'assets/icons/Chevron-left2.svg',
                          width: 18,
                          height: 18,
                          colorFilter: ColorFilter.mode(isDark ? Colors.white : const Color(0xFF1D1E20), BlendMode.srcIn),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Setting',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1D1E20),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 42),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const _SettingsList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsList extends StatelessWidget {
  const _SettingsList();
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: const [
          _SettingsItem(
            iconAsset: 'assets/icons/notification.svg',
            title: 'Notification',
          ),
          _FullDivider(),
          _SettingsItem(
            iconAsset: 'assets/icons/message-question.svg',
            title: 'FAQ',
          ),
          _FullDivider(),
          _SettingsItem(
            iconAsset: 'assets/icons/lock.svg',
            title: 'Security',
          ),
          _FullDivider(),
          _SettingsItem(
            iconAsset: 'assets/icons/language-square.svg',
            title: 'Language',
          ),
          _FullDivider(),
          _LogoutItem(),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({required this.iconAsset, required this.title});
  final String iconAsset;
  final String title;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            SvgPicture.asset(
              iconAsset,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(isDark ? Colors.white : const Color(0xFF1D1E20), BlendMode.srcIn),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1D1E20),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF6C7278)),
          ],
        ),
      ),
    );
  }
}

class _LogoutItem extends StatelessWidget {
  const _LogoutItem();
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ctrl = context.watch<SettingsController>();
    final red = const Color(0xFFFF4C5E);
    return InkWell(
      onTap: ctrl.loading
          ? null
          : () async {
              await showDialog(
                context: context,
                barrierDismissible: true,
                builder: (ctx) {
                  final isDark = Theme.of(ctx).brightness == Brightness.dark;
                  return AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    backgroundColor: Theme.of(ctx).scaffoldBackgroundColor,
                    title: const Text(
                      'Logout',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    content: const Text(
                      "You'll need to enter your username and password next time you want to login",
                      textAlign: TextAlign.center,
                      style: TextStyle(height: 1.4),
                    ),
                    actionsAlignment: MainAxisAlignment.spaceBetween,
                    actionsPadding: EdgeInsets.zero,
                    actions: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 1,
                            color: isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE0E3E7),
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF247CFF), fontWeight: FontWeight.w700))),
                                ),
                                Container(width: 1, height: double.infinity, color: isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE0E3E7)),
                                Expanded(
                                  child: TextButton(
                                    onPressed: () async {
                                      Navigator.of(ctx).pop();
                                      await ctrl.logout();
                                      if (context.mounted) {
                                        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
                                        if (ctrl.error != null) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Logged out locally. Server says: ${ctrl.error}')),
                                          );
                                        }
                                      }
                                    },
                                    child: const Text('Logout', style: TextStyle(color: Color(0xFFFF4C5E), fontWeight: FontWeight.w700))),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/logout.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(red, BlendMode.srcIn),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Logout',
                style: const TextStyle(
                  color: Color(0xFFFF4C5E),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            if (ctrl.loading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(Icons.chevron_right, size: 20, color: isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF6C7278)),
          ],
        ),
      ),
    );
  }
}

class _FullDivider extends StatelessWidget {
  const _FullDivider();
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Divider(
        height: 1,
        thickness: 1,
        color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFEAECEF),
      ),
    );
  }
}
