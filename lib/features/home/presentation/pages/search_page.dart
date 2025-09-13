import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/storage/local_storage.dart';
import '../controllers/doctors_controller.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../widgets/general_filter_bottom_sheet.dart';
import '../../domain/doctor.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SearchBody(),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: -1,
        onHome: () {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
        },
        onChat: () {},
        onCalendar: () {},
        onProfile: () {},
        onSearch: () {},
      ),
    );
  }
}

class SearchBody extends StatefulWidget {
  const SearchBody({super.key, this.onBack});
  final VoidCallback? onBack;

  @override
  State<SearchBody> createState() => _SearchBodyState();
}

class _SearchBodyState extends State<SearchBody> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (_) => DoctorsController()
        ..setGeneralMode(true)
        ..loadAll(),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            _Header(isDark: isDark, title: 'Search', onBack: widget.onBack),
            const SizedBox(height: 24),
            _SearchRow(
              controller: _controller,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer<DoctorsController>(
                builder: (context, c, _) {
                  final queryEmpty = _controller.text.trim().isEmpty;
                  if (c.loading && c.doctors.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (queryEmpty) {
                    return _RecentSearchList(controller: _controller);
                  }
                  final doctors = c.doctors;
                  return _ResultsList(
                    doctors: doctors,
                    loadingMore: c.loadingMore,
                    hasMore: c.hasMore,
                    currentQuery: _controller.text.trim(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.isDark, required this.title, this.onBack});
  final bool isDark;
  final String title;
  final VoidCallback? onBack;
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
            onTap: onBack ?? () => Navigator.of(context).maybePop(),
            child: SvgPicture.asset('assets/icons/Chevron-left2.svg', width: 18, height: 18,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn)),
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

class _SearchRow extends StatefulWidget {
  const _SearchRow({required this.controller});
  final TextEditingController controller;
  @override
  State<_SearchRow> createState() => _SearchRowState();
}

class _SearchRowState extends State<_SearchRow> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      context.read<DoctorsController>().setSearchQuery(widget.controller.text);
      setState(() {});
    });
  }

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
              height: 56,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F3F5),
                borderRadius: BorderRadius.circular(28),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  SvgPicture.asset('assets/icons/search-normal.svg', width: 22, height: 22,
                      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (v) => LocalStorage.instance.addRecentSearch(v),
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
              width: 30,
              height: 30,
              colorFilter: ColorFilter.mode(
                isDark ? Colors.white : const Color(0xFF1D1E20),
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentSearchList extends StatefulWidget {
  const _RecentSearchList({required this.controller});
  final TextEditingController controller;
  @override
  State<_RecentSearchList> createState() => _RecentSearchListState();
}

class _RecentSearchListState extends State<_RecentSearchList> {
  List<String> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await LocalStorage.instance.getRecentSearches();
    if (!mounted) return;
    setState(() => _items = list);
  }

  Future<void> _remove(String q) async {
    await LocalStorage.instance.removeRecentSearch(q);
    await _load();
  }

  Future<void> _clearAll() async {
    await LocalStorage.instance.clearRecentSearches();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF1D1E20);
    final subtitleColor = isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF6C7278);
    final historyColor = subtitleColor.withValues(alpha: isDark ? 0.45 : 0.55);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Row(
            children: [
              Text(
                'Recent Search',
                style: theme.textTheme.titleMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w700, color: titleColor),
              ),
              const Spacer(),
              if (_items.isNotEmpty)
                TextButton(
                  onPressed: _clearAll,
                  child: const Text('Clear All History', style: TextStyle(color: Color(0xFF247CFF))),
                ),
            ],
          ),
          const SizedBox(height: 0),
          for (int i = 0; i < _items.length; i++) ...[
            GestureDetector(
              onTap: () {
                final ctrl = context.read<DoctorsController>();
                final q = _items[i];
                widget.controller.text = q;
                widget.controller.selection = TextSelection.fromPosition(TextPosition(offset: q.length));
                ctrl.setSearchQuery(q);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 0),
                child: Row(
                  children: [
                    SvgPicture.asset('assets/icons/clock.svg', width: 18, height: 18,
                        colorFilter: ColorFilter.mode(historyColor, BlendMode.srcIn)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _items[i],
                        style: TextStyle(color: historyColor, fontSize: 18, fontWeight: FontWeight.w600, height: 1.15),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _remove(_items[i]),
                      icon: Icon(Icons.close, size: 16, color: historyColor.withValues(alpha: 0.6)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(width: 24, height: 24),
                      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                    ),
                  ],
                ),
              ),
            ),
            if (i < _items.length - 1) const SizedBox(height: 0),
          ],
          if (_items.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 64),
              child: Center(
                child: Text('No recent search', style: TextStyle(color: subtitleColor, fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({required this.doctors, required this.loadingMore, required this.hasMore, required this.currentQuery});
  final List<Doctor> doctors;
  final bool loadingMore;
  final bool hasMore;
  final String currentQuery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        final c = context.read<DoctorsController>();
        if (n.metrics.pixels + 200 >= n.metrics.maxScrollExtent && hasMore && !loadingMore) {
          c.loadMore(cityId: c.selectedCityId);
        }
        return false;
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
        children: [
          const SizedBox(height: 12),
          _SpecChips(),
          const SizedBox(height: 16),
          Text(
            '${doctors.length} founds',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white.withValues(alpha: 0.8) : const Color(0xFF6C7278),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (doctors.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 48),
              child: Center(child: Text('No doctors')),
            )
          else
            ...[
              for (int i = 0; i < doctors.length; i++) ...[
                InkWell(
                  onTap: () async {
                    final q = currentQuery.trim();
                    if (q.isNotEmpty) {
                      await LocalStorage.instance.addRecentSearch(q);
                    }
                    if (context.mounted) {
                      Navigator.of(context).pushNamed(
                        AppRoutes.doctorDetails,
                        arguments: doctors[i],
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  splashColor: const Color(0xFF247CFF).withValues(alpha: 0.10),
                  highlightColor: Colors.transparent,
                  child: _DoctorContainer(doctor: doctors[i], index: i),
                ),
                const SizedBox(height: 18),
              ],
              if (loadingMore)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
                ),
              if (!hasMore)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      'End of results',
                      style: TextStyle(
                        color: isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF6C7278),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
        ],
      ),
    );
  }
}

class _SpecChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.watch<DoctorsController>();
    final specs = c.getSpecializations();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          const SizedBox(width: 4),
          for (int i = 0; i < specs.length; i++) ...[
            _AppChoiceChip(
              label: specs[i],
              selected: (c.selectedSpec ?? 'All').toLowerCase() == specs[i].toLowerCase(),
              onTap: () => c.setSpecializationFilter(specs[i]),
            ),
            if (i < specs.length - 1) const SizedBox(width: 12),
          ],
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _AppChoiceChip extends StatelessWidget {
  const _AppChoiceChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bg = selected
        ? const Color(0xFF247CFF)
        : (isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8F9FA));
    final Color border = selected
        ? const Color(0xFF247CFF)
        : (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE9ECEF));
    final Color fg = selected
        ? Colors.white
        : (isDark ? Colors.white.withValues(alpha: 0.4) : const Color(0xFFADB5BD));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w600,
          ),
        ),
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
    final hasTitle = RegExp(r'^(dr|mr|mrs|ms|prof|professor)\.?\s', caseSensitive: false)
        .hasMatch(name.toLowerCase());
    return hasTitle ? name : 'Dr. $name';
  }
}
