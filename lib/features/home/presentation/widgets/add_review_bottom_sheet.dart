import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../controllers/reviews_controller.dart';

class AddReviewBottomSheet extends StatefulWidget {
  const AddReviewBottomSheet({super.key, required this.doctorId});
  final int doctorId;

  @override
  State<AddReviewBottomSheet> createState() => _AddReviewBottomSheetState();
}

class _AddReviewBottomSheetState extends State<AddReviewBottomSheet> {
  int _rating = 0;
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      setState(() {});
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    final text = _controller.text.trim();
    final reviews = context.read<ReviewsController>();
    await reviews.initForDoctor(widget.doctorId);
    await reviews.submit(rating: _rating, content: text);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF111315) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF1D1E20);
    final border = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFEAECEF);

    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 44, height: 5, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(3))),
                const SizedBox(height: 16),
                Text('Give Rate', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: titleColor)),
                const SizedBox(height: 12),
                Divider(color: border, height: 1),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final ix = i + 1;
                    final filled = ix <= _rating;
                    return InkResponse(
                      onTap: () => setState(() => _rating = ix),
                      radius: 24,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: SvgPicture.asset(
                          filled ? 'assets/icons/starY.svg' : 'assets/icons/Star.svg',
                          width: 28,
                          height: 28,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 18),
                Text('Share your feedback about the doctor',
                    style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF6C7278))),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _controller,
                    minLines: 3,
                    maxLines: 5,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: 'Your review',
                      filled: true,
                      fillColor: isDark ? const Color(0xFF0D0F10) : const Color(0xFFF5F7FA),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: border),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: border),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF247CFF), width: 1.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    validator: (v) {
                      if ((v ?? '').trim().isEmpty) return 'Please write a short review';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _rating == 0 ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF247CFF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
