import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../controllers/home_controller.dart';
import '../widgets/header_greeting.dart';
import 'search_page.dart';
import '../../../appointments/presentation/pages/my_appointments_page.dart';
import 'profile_page.dart';
import '../../../appointments/presentation/controllers/appointments_controller.dart';
import '../controllers/profile_controller.dart';
import '../widgets/promo_card.dart';
import '../widgets/speciality_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tabIndex = 0;
  bool _handledInitialArg = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_handledInitialArg) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        setState(() => _tabIndex = args);
      }
      _handledInitialArg = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeController()..load(),
      child: Consumer<HomeController>(
        builder: (context, c, _) {
          final theme = Theme.of(context);
          if (_tabIndex == 4) {
            SystemChrome.setSystemUIOverlayStyle(
              SystemUiOverlayStyle.light.copyWith(
                statusBarColor: const Color(0xFF247CFF),
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark,
              ),
            );
          } else {
            final isDark = theme.brightness == Brightness.dark;
            SystemChrome.setSystemUIOverlayStyle(
              (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
                statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
              ),
            );
          }
          final bottomReserve = MediaQuery.of(context).padding.bottom + 56;
          Widget buildHomeContent() => SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: c.loading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: () => c.load(),
                          child: CustomScrollView(
                            slivers: [
                              SliverToBoxAdapter(
                                child: HeaderGreeting(
                                  name: c.displayName,
                                  onNotifications: () {},
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 18),
                                  child: PromoCard(
                                    onFindNearby: () {},
                                  ),
                                ),
                              ),
                              const SliverToBoxAdapter(child: SpecialitySection()),
                              SliverToBoxAdapter(
                                child: _RecommendationSection(),
                              ),
                              SliverToBoxAdapter(child: SizedBox(height: bottomReserve)),
                            ],
                          ),
                        ),
                ),
              );

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: PopScope(
              canPop: _tabIndex == 0,
              onPopInvokedWithResult: (didPop, result) {
                if (_tabIndex != 0) {
                  setState(() => _tabIndex = 0);
                }
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final slide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
                      .animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: slide, child: child),
                  );
                },
                child: () {
                  switch (_tabIndex) {
                    case 1:
                      return const KeyedSubtree(key: ValueKey('search'), child: SearchBody());
                    case 2:
                      return KeyedSubtree(
                        key: const ValueKey('appointments'),
                        child: ChangeNotifierProvider(
                          create: (_) => AppointmentsController()..load(),
                          child: const MyAppointmentsBody(),
                        ),
                      );
                    case 4:
                      return KeyedSubtree(
                        key: const ValueKey('profile'),
                        child: ChangeNotifierProvider(
                          create: (_) => ProfileController()..load(),
                          child: ProfileBody(
                            onGoAppointments: () {
                              if (_tabIndex != 2) setState(() => _tabIndex = 2);
                            },
                          ),
                        ),
                      );
                    case 0:
                    default:
                      return KeyedSubtree(key: const ValueKey('home'), child: buildHomeContent());
                  }
                }(),
              ),
            ),
            bottomNavigationBar: AppBottomNav(
              selectedIndex: _tabIndex == 1 ? -1 : (_tabIndex == 0 ? 0 : _tabIndex),
              onHome: () {
                if (_tabIndex != 0) setState(() => _tabIndex = 0);
              },
              onChat: () {},
              onCalendar: () {
                if (_tabIndex != 2) setState(() => _tabIndex = 2);
              },
              onProfile: () {
                if (_tabIndex != 4) setState(() => _tabIndex = 4);
              },
              onSearch: () {
                if (_tabIndex != 1) setState(() => _tabIndex = 1);
              },
            ),
          );
        },
      ),
    );
  }
}

class _RecommendationSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  'Recommendation Doctor',
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pushNamed(AppRoutes.recommendationDoctor),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF247CFF)),
                  child: const Text(
                    'See All',
                    style: TextStyle(color: Color(0xFF247CFF)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (context.watch<HomeController>().doctors.isEmpty)
            const SizedBox.shrink()
          else
            ListView.separated(
              padding: const EdgeInsets.only(left: 36, right: 24, top: 10, bottom: 8),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (_, i) => _DoctorCard(index: i),
              separatorBuilder: (_, __) => const SizedBox(height: 18),
              itemCount: (context.watch<HomeController>().doctors.length > 3
                  ? 3
                  : context.watch<HomeController>().doctors.length),
            ),
        ],
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.index});
  final int index;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final doctors = context.watch<HomeController>().doctors;
    final d = doctors[index];
    final rawName = d.name.trim();
    final hasTitle = RegExp(r'^(dr|mr|mrs|ms|prof|professor)\.?\s', caseSensitive: false)
        .hasMatch(rawName.toLowerCase());
    final displayName = hasTitle ? rawName : 'Dr. $rawName';

    return InkWell(
      onTap: () {
        FocusScope.of(context).unfocus();
        Navigator.of(context).pushNamed(AppRoutes.doctorDetails, arguments: d);
      },
      borderRadius: BorderRadius.circular(12),
      splashColor: const Color(0xFF247CFF).withValues(alpha: 0.10),
      highlightColor: Colors.transparent,
      child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 112,
            height: 112,
            child: () {
              final url = d.photoUrl?.trim() ?? '';
              final looksHttp = url.startsWith('http://') || url.startsWith('https://');
              final isBlockedPlaceholder = url.contains('via.placeholder.com');
              final canLoadNetwork = looksHttp && !isBlockedPlaceholder;
              final fallbackIx = ((d.id) % 5) + 1;
              final fallbackAsset = fallbackIx == 5
                  ? 'assets/images/doctor5.jpg'
                  : 'assets/images/doctor$fallbackIx.png';
              if (canLoadNetwork) {
                return Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) {
                    return Image.asset(
                      fallbackAsset,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.medium,
                    );
                  },
                );
              }
              return Image.asset(
                fallbackAsset,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
              );
            }(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayName,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: isDark ? Colors.white : const Color(0xFF1D1E20),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${d.specializationName ?? 'General'}  |  ${d.cityName ?? 'Hospital'}',
                style: TextStyle(
                  color: isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF6C7278),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/send-2.svg',
                    width: 18,
                    height: 18,
                    colorFilter: const ColorFilter.mode(Color(0xFF6C7278), BlendMode.srcIn),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    d.phone ?? '-',
                    style: const TextStyle(color: Color(0xFF6C7278), fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
    );
  }
}
