import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class PromoCard extends StatelessWidget {
  const PromoCard({super.key, required this.onFindNearby});
  final VoidCallback onFindNearby;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SizedBox(
        height: 192,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: CustomPaint(
                painter: _BgBandsPainter(),
                child: Container(
                  padding: const EdgeInsetsDirectional.only(start: 19, top: 20, bottom: 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8, bottom: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  'Book and\nschedule with\nnearest doctor',
                                  maxLines: 3,
                                  softWrap: true,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 19,
                                    height: 1.60,
                                    letterSpacing: 0.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 38,
                                width: 109,
                                child: TextButton(
                                  onPressed: onFindNearby,
                                  style: TextButton.styleFrom(
                                    backgroundColor:
                                        isDark ? AppColors.bgDark.withValues(alpha: 0.75) : Colors.white,
                                    foregroundColor: isDark ? Colors.white : AppColors.primary,
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                    overlayColor: isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : AppColors.primary.withValues(alpha: 0.08),
                                    shadowColor: Colors.transparent,
                                    disabledBackgroundColor:
                                        isDark ? AppColors.bgDark.withValues(alpha: 0.60) : Colors.white,
                                    disabledForegroundColor: (isDark
                                            ? Colors.white
                                            : AppColors.primary)
                                        .withValues(alpha: 0.40),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(48),
                                    ),
                                  ),
                                  child: Text(
                                    'Find Nearby',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      height: 1.50,
                                      letterSpacing: 0.0,
                                      color: isDark ? Colors.white : AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Expanded(flex: 7, child: SizedBox()),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -6,
              bottom: 0,
              child: Transform.translate(
                offset: const Offset(-18, 0),
                child: Image.asset(
                  'assets/images/home.png',
                  height: 230,
                  fit: BoxFit.fitHeight,
                  errorBuilder: (context, error, stack) {
                    return SvgPicture.asset(
                      'assets/images/home.svg',
                      height: 240,
                      fit: BoxFit.fitHeight,
                      alignment: Alignment.bottomRight,
                      allowDrawingOutsideViewBox: true,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BgBandsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final gradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF2F80ED), Color(0xFF247CFF)],
    );
    final paintGrad = Paint()..shader = gradient.createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(24)),
      paintGrad,
    );
    const angleDeg = 27.6;
    final angle = angleDeg * 3.141592653589793 / 180.0;
    final bandWidth = size.height * 0.60;
    final gap = bandWidth;
    final bandColor = Colors.white.withValues(alpha: 0.04);
    final drawHeight = size.longestSide * 2.2;
    canvas.save();
    final center = Offset(size.width / 2, size.height / 2);
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    final totalWidth = size.width * 2.2;
    final extraOffset = size.width * 0.45;
    final startX = -totalWidth / 2 + bandWidth + extraOffset;
    final bandStride = bandWidth + gap;
    int count = (totalWidth / bandStride).ceil() + 4;

    for (int i = 0; i < count; i++) {
      final x = startX + i * bandStride;
      final bandRect = Rect.fromLTWH(x, -drawHeight / 2, bandWidth, drawHeight);
      final paint = Paint()..color = bandColor;
      canvas.drawRect(bandRect, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
