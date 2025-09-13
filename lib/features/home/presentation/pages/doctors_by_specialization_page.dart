import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../controllers/doctors_controller.dart';
import '../widgets/general_filter_bottom_sheet.dart';
import '../../domain/doctor.dart';
import '../../../../core/routes/app_router.dart';

class DoctorsBySpecializationPage extends StatefulWidget {
  const DoctorsBySpecializationPage({super.key});

  @override
  State<DoctorsBySpecializationPage> createState() => _DoctorsBySpecializationPageState();
}

class _DoctorsBySpecializationPageState extends State<DoctorsBySpecializationPage> {
  final ScrollController _scroll = ScrollController();
  int? _specIdForPaging;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final title = (args != null ? (args['title'] as String?) : null) ?? 'Doctors';

    return ChangeNotifierProvider(
      create: (_) {
        final c = DoctorsController();
        final specId = args != null ? args['specId'] as int? : null;
        if (specId == null) {
          c.setGeneralMode(true);
          c.loadAll();
        } else {
          c.loadBySpecialization(specId);
        }
        _specIdForPaging = specId;
        return c;
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              _Header(isDark: isDark, title: title),
              const SizedBox(height: 24),
              _SearchRow(
                showFilter: (args == null || args['specId'] == null),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Consumer<DoctorsController>(
                  builder: (context, c, _) {
                    if (c.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final doctors = c.doctors;
                    if (doctors.isEmpty) {
                      return const Center(child: Text('No doctors'));
                    }
                    return NotificationListener<ScrollNotification>(
                      onNotification: (notif) {
                        if (notif.metrics.pixels + 200 >= notif.metrics.maxScrollExtent && c.hasMore && !c.loadingMore) {
                          c.loadMore(specId: _specIdForPaging, cityId: c.selectedCityId);
                        }
                        return false;
                      },
                      child: ListView.separated(
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                        itemBuilder: (_, i) {
                          if (i == doctors.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: c.loadingMore
                                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                                    : (!c.hasMore
                                        ? Text(
                                            'End of results',
                                            style: TextStyle(
                                              color: Theme.of(context).brightness == Brightness.dark
                                                  ? Colors.white.withValues(alpha: 0.7)
                                                  : const Color(0xFF6C7278),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          )
                                        : const SizedBox.shrink()),
                              ),
                            );
                          }
                          final d = doctors[i];
                          return InkWell(
                            onTap: () => Navigator.of(context).pushNamed(
                              AppRoutes.doctorDetails,
                              arguments: d,
                            ),
                            child: _DoctorContainer(doctor: d, index: i),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 18),
                        itemCount: doctors.length + 1,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.isDark, required this.title});
  final bool isDark;
  final String title;
  @override
  Widget build(BuildContext context) {
    final border = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFEAECEF);
    final bg = isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white;
    final iconColor = isDark ? Colors.white : const Color(0xFF1D1E20);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _SquareIconButton(
            bg: bg,
            border: border,
            child: SvgPicture.asset('assets/icons/Chevron-left2.svg', width: 18, height: 18,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn)),
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const Spacer(),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: iconColor,
                ),
          ),
          const Spacer(),
          const SizedBox(width: 42),
        ],
      ),
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({required this.bg, required this.border, required this.child, required this.onTap});
  final Color bg;
  final Color border;
  final Widget child;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({this.showFilter = false});
  final bool showFilter;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hintColor = isDark ? Colors.white.withValues(alpha: 0.55) : const Color(0xFFBFC4CA);
    final iconColor = isDark ? Colors.white.withValues(alpha: 0.70) : const Color(0xFFBFC4CA);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F3F5),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  SvgPicture.asset('assets/icons/search-normal.svg', width: 22, height: 22,
                      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (v) => context.read<DoctorsController>().setSearchQuery(v),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: 'Search',
                        hintStyle: TextStyle(color: hintColor, fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showFilter) ...[
            const SizedBox(width: 12),
            InkResponse(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) {
                    final ctrl = context.read<DoctorsController>();
                    return ChangeNotifierProvider<DoctorsController>.value(
                      value: ctrl,
                      child: const GeneralFilterBottomSheet(),
                    );
                  },
                );
              },
              radius: 28,
              child: SvgPicture.asset(
                'assets/icons/sort.svg',
                width: 28,
                height: 28,
                colorFilter: ColorFilter.mode(
                  isDark ? Colors.white : const Color(0xFF1D1E20),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DoctorContainer extends StatelessWidget {
  const _DoctorContainer({required this.doctor, required this.index});
  final Doctor doctor;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white;
    final border = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06);
    final shadow = isDark ? Colors.black.withValues(alpha: 0.0) : Colors.black.withValues(alpha: 0.06);

    final fallbackIx = ((doctor.id) % 5) + 1;
    final fallbackAsset = fallbackIx == 5 ? 'assets/images/doctor5.jpg' : 'assets/images/doctor$fallbackIx.png';

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(color: shadow, blurRadius: 24, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 120,
              height: 120,
              child: () {
                final url = doctor.photoUrl?.trim() ?? '';
                final looksHttp = url.startsWith('http://') || url.startsWith('https://');
                final isPlaceholder = url.contains('via.placeholder.com');
                if (looksHttp && !isPlaceholder) {
                  return Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) {
                      return Image.asset(fallbackAsset, fit: BoxFit.cover, filterQuality: FilterQuality.medium);
                    },
                  );
                }
                return Image.asset(fallbackAsset, fit: BoxFit.cover, filterQuality: FilterQuality.medium);
              }(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _displayName(doctor.name),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    height: 1.35,
                    color: isDark ? Colors.white : const Color(0xFF1D1E20),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${doctor.specializationName ?? 'General'}  |  ${doctor.hospitalName ?? doctor.cityName ?? 'Hospital'}',
                  style: TextStyle(
                    color: isDark ? Colors.white.withValues(alpha: 0.75) : const Color(0xFF6C7278),
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    height: 1.50,
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
                      doctor.phone ?? '-',
                      style: const TextStyle(
                        color: Color(0xFF6C7278),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.40,
                      ),
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

  String _displayName(String raw) {
    final name = raw.trim();
    final hasTitle = RegExp(r'^(dr|mr|mrs|ms|prof|professor)\.??\s', caseSensitive: false)
        .hasMatch(name.toLowerCase());
    return hasTitle ? name : 'Dr. $name';
  }
}
