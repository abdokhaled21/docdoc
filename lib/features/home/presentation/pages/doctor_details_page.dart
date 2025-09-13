import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../domain/doctor.dart';
import '../../../../core/routes/app_router.dart';
import '../controllers/reviews_controller.dart';
import '../widgets/add_review_bottom_sheet.dart';

class DoctorDetailsPage extends StatelessWidget {
  const DoctorDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final args = ModalRoute.of(context)?.settings.arguments;
    final doctor = args is Doctor ? args : null;

    return ChangeNotifierProvider(
      create: (_) => ReviewsController()..initForDoctor(doctor?.id ?? 0),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              _Header(title: doctor?.name ?? 'Doctor Details'),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _DoctorHeroCard(doctor: doctor),
              ),
              const SizedBox(height: 24),
              Expanded(child: _TabsContent(doctor: doctor)),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  Navigator.of(context).pushNamed(AppRoutes.bookAppointment, arguments: doctor);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF247CFF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'Make An Appointment',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          Expanded(
            child: Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 3,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: iconColor,
                    ),
              ),
            ),
          ),
          _SquareIconButton(
            bg: bg,
            border: border,
            child: SvgPicture.asset('assets/icons/dots.svg', width: 18, height: 18,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn)),
            onTap: () {},
          ),
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

class _DoctorHeroCard extends StatelessWidget {
  const _DoctorHeroCard({required this.doctor});
  final Doctor? doctor;
  @override
  Widget build(BuildContext context) {

    final docId = doctor?.id ?? 0;
    final fallbackIx = ((docId) % 5) + 1;
    final fallbackAsset = fallbackIx == 5 ? 'assets/images/doctor5.jpg' : 'assets/images/doctor$fallbackIx.png';
    final avatar = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 100,
        height: 100,
        child: () {
          final url = doctor?.photoUrl?.trim() ?? '';
          final looksHttp = url.startsWith('http://') || url.startsWith('https://');
          final isPlaceholder = url.contains('via.placeholder.com');
          if (looksHttp && !isPlaceholder) {
            return Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) =>
                  Image.asset(fallbackAsset, fit: BoxFit.cover, filterQuality: FilterQuality.medium),
            );
          }
          return Image.asset(fallbackAsset, fit: BoxFit.cover, filterQuality: FilterQuality.medium);
        }(),
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 4),
        avatar,
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _displayName(doctor?.name ?? 'Doctor'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      '${doctor?.specializationName ?? '-'}  |  ${doctor?.cityName ?? (doctor?.hospitalName ?? '-')}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF6C7278), fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
        const SizedBox(width: 4),
        InkResponse(
          onTap: () {},
          radius: 22,
          child: SvgPicture.asset(
            'assets/icons/message-text2.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(Color(0xFF247CFF), BlendMode.srcIn),
          ),
        ),
      ],
    );
  }

  String _displayName(String raw) {
    final name = raw.trim();
    final hasTitle = RegExp(r'^(dr|mr|mrs|ms|prof|professor)\.?\s', caseSensitive: false)
        .hasMatch(name.toLowerCase());
    return hasTitle ? name : 'Dr. $name';
  }

}

class _TabsContent extends StatefulWidget {
  const _TabsContent({required this.doctor});
  final Doctor? doctor;
  @override
  State<_TabsContent> createState() => _TabsContentState();
}

class _TabsContentState extends State<_TabsContent> with SingleTickerProviderStateMixin {
  late final TabController _controller;
  bool _sheetOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);
    _controller.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_controller.indexIsChanging) return;
    if (_controller.index == 2) {
      _openAddReviewSheet();
    }
  }

  Future<void> _openAddReviewSheet() async {
    if (_sheetOpen) return;
    _sheetOpen = true;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final reviews = context.read<ReviewsController>();
        return ChangeNotifierProvider.value(
          value: reviews,
          child: AddReviewBottomSheet(doctorId: widget.doctor?.id ?? 0),
        );
      },
    );
    _sheetOpen = false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final divider = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFEAECEF);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(height: 2, color: divider),
              TabBar(
                controller: _controller,
                isScrollable: false,
                labelColor: const Color(0xFF247CFF),
                unselectedLabelColor: isDark ? Colors.white.withValues(alpha: 0.5) : const Color(0xFFADB5BD),
                labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(color: Color(0xFF247CFF), width: 2.2),
                ),
                onTap: (ix) {
                  if (ix == 2) _openAddReviewSheet();
                },
                tabs: const [
                  Tab(text: 'About'),
                  Tab(text: 'Location'),
                  Tab(text: 'Reviews'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _controller,
              children: [
                _AboutTab(doctor: widget.doctor),
                _LocationTab(doctor: widget.doctor),
                _ReviewsTab(doctor: widget.doctor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onTabChanged);
    _controller.dispose();
    super.dispose();
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.doctor});
  final Doctor? doctor;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleStyle = theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 16,
        color: isDark ? Colors.white : const Color(0xFF1D1E20));
    final bodyStyle = const TextStyle(color: Color(0xFF6C7278), height: 1.5);

    List<Widget> items = [];
    if ((doctor?.description ?? '').trim().isNotEmpty) {
      items.addAll([
        Text('About me', style: titleStyle),
        const SizedBox(height: 8),
        Text(doctor!.description!, style: bodyStyle),
        const SizedBox(height: 20),
      ]);
    }

    final st = (doctor?.startTime ?? '').trim();
    final et = (doctor?.endTime ?? '').trim();
    if (st.isNotEmpty || et.isNotEmpty) {
      items.addAll([
        Text('Working Time', style: titleStyle),
        const SizedBox(height: 8),
        Text(
          st.isNotEmpty && et.isNotEmpty ? '$st - $et' : (st + et),
          style: bodyStyle,
        ),
        const SizedBox(height: 20),
      ]);
    }

    if (doctor?.appointPrice != null) {
      items.addAll([
        Text('Appointment Price', style: titleStyle),
        const SizedBox(height: 8),
        Text('${doctor!.appointPrice} EGP', style: bodyStyle),
        const SizedBox(height: 20),
      ]);
    }

    final phone = (doctor?.phone ?? '').trim();
    if (phone.isNotEmpty) {
      items.addAll([
        Text('Phone', style: titleStyle),
        const SizedBox(height: 8),
        Text(phone, style: bodyStyle),
        const SizedBox(height: 20),
      ]);
    }

    final place = (doctor?.hospitalName ?? doctor?.cityName ?? '').trim();
    if (place.isNotEmpty) {
      items.addAll([
        Text('Location', style: titleStyle),
        const SizedBox(height: 8),
        Text(place, style: bodyStyle),
      ]);
    }

    if (items.isEmpty) {
      items = [Text('No additional information', style: bodyStyle)];
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: items),
    );
  }
}

class _LocationTab extends StatelessWidget {
  const _LocationTab({required this.doctor});
  final Doctor? doctor;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFEAECEF);
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Clinic Location', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            Text(doctor?.address ?? '—', style: const TextStyle(color: Color(0xFF6C7278))),
            const SizedBox(height: 28),
            const Text('Map', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.33,
                child: Image.asset(
                  'assets/images/Map.png',
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab({required this.doctor});
  final Doctor? doctor;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFEAECEF);
    return Consumer<ReviewsController>(
      builder: (context, c, _) {
        if (c.loading && c.reviews.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = c.reviews;
        if (items.isEmpty) {
          return const Text('No reviews yet. Be the first to review!', style: TextStyle(color: Color(0xFF6C7278)));
        }
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 16),
          itemBuilder: (context, index) {
            final r = items[index];
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFE9F1FF),
                  child: Text(
                    r.authorName.isNotEmpty ? r.authorName.trim().characters.first.toUpperCase() : 'U',
                    style: TextStyle(color: const Color(0xFF247CFF), fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: border)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(r.authorName, style: const TextStyle(fontWeight: FontWeight.w700)),
                            ),
                            Text(_formatDay(r.createdAt), style: const TextStyle(color: Color(0xFF6C7278))),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _StarsRow(rating: r.rating),
                        if (r.content.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(r.content, style: const TextStyle(color: Color(0xFF6C7278), height: 1.4)),
                        ]
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemCount: items.length,
        );
      },
    );
  }

  String _formatDay(DateTime dt) {
    final now = DateTime.now();
    final a = DateTime(dt.year, dt.month, dt.day);
    final b = DateTime(now.year, now.month, now.day);
    final diff = b.difference(a).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _StarsRow extends StatelessWidget {
  const _StarsRow({required this.rating});
  final int rating;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final filled = i < rating;
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: SvgPicture.asset(
            filled ? 'assets/icons/starY.svg' : 'assets/icons/Star.svg',
            width: 18,
            height: 18,
          ),
        );
      }),
    );
  }
}
