import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/routes/app_router.dart';
import 'settings_page.dart';
import '../controllers/profile_controller.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class ProfileBody extends StatefulWidget {
  const ProfileBody({super.key, this.onGoAppointments});
  final VoidCallback? onGoAppointments;
  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  @override
  void initState() {
    super.initState();
    _forceBlueStatusBar();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _forceBlueStatusBar();
  }

  void _forceBlueStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarColor: const Color(0xFF247CFF),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _forceBlueStatusBar();
    return _ProfileBody(onGoAppointments: widget.onGoAppointments);
  }
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarColor: const Color(0xFF247CFF),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ChangeNotifierProvider(
        create: (_) => ProfileController()..load(),
        child: const _ProfileBody(),
      ),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: 4,
        onHome: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
        onChat: () {},
        onCalendar: () => Navigator.of(context).pushNamed(AppRoutes.myAppointments),
        onProfile: () {},
        onSearch: () => Navigator.of(context).pushNamed(AppRoutes.search),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({this.onGoAppointments});
  final VoidCallback? onGoAppointments;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF1D1E20);
    final c = context.watch<ProfileController>();

    final paddingTop = MediaQuery.of(context).padding.top;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _HeaderShape(isDark: isDark),
              Positioned(
                top: paddingTop + 22,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: SvgPicture.asset(
                        'assets/icons/Chevron-left2.svg',
                        width: 22,
                        height: 22,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Profile',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const SettingsPage(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ));
                      },
                      icon: SvgPicture.asset(
                        'assets/icons/setting-2.svg',
                        width: 22,
                        height: 22,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: paddingTop + 180,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(36),
                      topRight: Radius.circular(36),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: -70,
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark ? Theme.of(context).scaffoldBackgroundColor : Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 53,
                            backgroundColor: const Color(0xFFE9E2FF),
                            backgroundImage: const AssetImage('assets/images/profile.png'),
                          ),
                        ),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: InkWell(
                            onTap: () async {
                              final result = await Navigator.of(context).pushNamed(AppRoutes.editProfile);
                              if (result == true && context.mounted) {
                                await context.read<ProfileController>().load();
                              }
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      c.profile?.name.isNotEmpty == true ? c.profile!.name : '—',
                      style: TextStyle(color: titleColor, fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      c.profile?.email.isNotEmpty == true ? c.profile!.email : '—',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.60)
                            : const Color(0xFFADB5BD),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
                width: double.infinity,
                height: 59,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                        onTap: () {
                          if (onGoAppointments != null) {
                            onGoAppointments!();
                          } else {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRoutes.home,
                              (route) => false,
                              arguments: 2,
                            );
                          }
                        },
                        child: Center(
                          child: Text(
                            'My Appointment',
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF1D1E20),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 1,
                        height: 32,
                        color: isDark ? Colors.white.withValues(alpha: 0.18) : const Color(0xFFDADDE1),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
                        onTap: () {},
                        child: Center(
                          child: Text(
                            'Medical records',
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF1D1E20),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverList(
          delegate: SliverChildListDelegate([
            _ProfileMenuItem(
              icon: 'assets/icons/personalcard.svg',
              title: 'Personal Information',
              bgColorLight: Color(0xFFEAF2FF),
              bgColorDark: Color(0x33FFFFFF),
              iconColor: Color(0xFF247CFF),
              onTap: () async {
                final result = await Navigator.of(context).pushNamed(AppRoutes.editProfile);
                if (result == true && context.mounted) {
                  await context.read<ProfileController>().load();
                }
              },
            ),
            const _FullDivider(),
            _ProfileMenuItem(
              icon: 'assets/icons/directbox-notif.svg',
              title: 'My Test & Diagnostic',
              bgColorLight: Color(0xFFE9FAEF),
              bgColorDark: Color(0x3322C55E),
              iconColor: Color(0xFF22C55E),
              onTap: () {},
            ),
            const _FullDivider(),
            _ProfileMenuItem(
              icon: 'assets/icons/wallet-1.svg',
              title: 'Payment',
              bgColorLight: Color(0xFFFFEEEF),
              bgColorDark: Color(0x33FF4C5E),
              iconColor: Color(0xFFFF4C5E),
              onTap: () {},
            ),
            const SizedBox(height: 24),
          ]),
        ),
      ],
    );
  }
}

class _HeaderShape extends StatelessWidget {
  const _HeaderShape({required this.isDark});
  final bool isDark;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: const BoxDecoration(
        color: Color(0xFF247CFF),
      ),
    );
  }
}
class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.bgColorLight,
    required this.bgColorDark,
    required this.iconColor,
    required this.onTap,
  });
  final String icon;
  final String title;
  final Color bgColorLight;
  final Color bgColorDark;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color containerColor = isDark
        ? iconColor.withValues(alpha: 0.16)
        : bgColorLight;
    final Color effectiveIconColor = isDark
        ? iconColor.withValues(alpha: 0.95)
        : iconColor;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(16),
                border: isDark
                    ? Border.all(color: Colors.white.withValues(alpha: 0.06))
                    : null,
              ),
              padding: const EdgeInsets.all(8),
              child: SvgPicture.asset(
                icon,
                width: 26,
                height: 26,
                colorFilter: ColorFilter.mode(effectiveIconColor, BlendMode.srcIn),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1D1E20),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Divider(
        height: 1,
        thickness: 1,
        color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFEAECEF),
      ),
    );
  }
}
