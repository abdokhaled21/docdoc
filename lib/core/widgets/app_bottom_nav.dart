import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

class CenterSearchButton extends StatelessWidget {
  const CenterSearchButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.onHome,
    required this.onChat,
    required this.onCalendar,
    required this.onProfile,
    required this.onSearch,
    this.selectedIndex = 0,
  });

  final VoidCallback onHome;
  final VoidCallback onChat;
  final VoidCallback onCalendar;
  final VoidCallback onProfile;
  final VoidCallback onSearch;
  final int selectedIndex;

  Color _itemColor(BuildContext context, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? Colors.white : const Color(0xFF1D1E20);
    final selected = AppColors.primary;
    return (selectedIndex == index) ? selected : base;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = isDark ? const Color(0xFF151820) : Colors.white;
    return BottomAppBar(
      color: barColor,
      elevation: 10,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 80,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  SizedBox(
                    width: 48,
                    child: Center(
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                        onPressed: onHome,
                        icon: SvgPicture.asset(
                          'assets/icons/home-2.svg',
                          width: 26,
                          height: 26,
                          colorFilter: ColorFilter.mode(_itemColor(context, 0), BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    child: Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                            onPressed: onChat,
                            icon: SvgPicture.asset(
                              'assets/icons/message-text.svg',
                              width: 26,
                              height: 26,
                              colorFilter: ColorFilter.mode(_itemColor(context, 1), BlendMode.srcIn),
                            ),
                          ),
                          const Positioned(
                            right: 11,
                            top: 10,
                            child: SizedBox(
                              width: 8,
                              height: 8,
                              child: DecoratedBox(
                                decoration: BoxDecoration(color: Color(0xFFFF4C5E), shape: BoxShape.circle),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 78),
                  SizedBox(
                    width: 48,
                    child: Center(
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                        onPressed: onCalendar,
                        icon: SvgPicture.asset(
                          'assets/icons/calendar-2.svg',
                          width: 26,
                          height: 26,
                          colorFilter: ColorFilter.mode(_itemColor(context, 2), BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    child: Center(
                      child: InkWell(
                        onTap: onProfile,
                        borderRadius: BorderRadius.circular(16),
                        child: const CircleAvatar(
                          radius: 14,
                          backgroundImage: AssetImage('assets/images/logo.png'),
                        ),
                      ),
                    ),
                  ),
                  ],
                ),
              ),
              Positioned(
                top: -40,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: onSearch,
                  child: Container(
                    height: 83,
                    width: 83,
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      height: 72,
                      width: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        'assets/icons/search-normal.svg',
                        width: 28,
                        height: 28,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
