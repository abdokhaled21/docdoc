import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';

import 'package:intl_phone_field/countries.dart' as intl_countries;
import '../theme/app_theme.dart';

class PhoneNumberField extends StatefulWidget {
  const PhoneNumberField({
    super.key,
    this.initialIsoCode = 'GB',
    required this.hintText,
    required this.onChanged,
    required this.onCountryChanged,
    this.onInfoChanged,
    this.isError = false,
    this.controller,
  });

  final String initialIsoCode;
  final String hintText;
  final void Function(String fullE164WithoutPlus) onChanged;
  final void Function(String dialCode, String isoCode) onCountryChanged;
  final void Function({required int digits, required int min, required int max, required bool valid})? onInfoChanged;
  final bool isError;
  final TextEditingController? controller;

  @override
  State<PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> {
  late Country _country;
  late final TextEditingController _controller;
  late final bool _ownsController;
  final FocusNode _focusNode = FocusNode();
  int _min = 0;
  int _max = 0;
  int _digits = 0;
  bool _valid = false;
  bool _hover = false;

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: 1),
      );

  @override
  void initState() {
    super.initState();
    _country = Country.parse(widget.initialIsoCode);
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _refreshLengths();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PhoneNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIsoCode.toUpperCase() != widget.initialIsoCode.toUpperCase()) {
      setState(() {
        _country = Country.parse(widget.initialIsoCode);
      });
      _refreshLengths();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseBorder = isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0x1A000000);
    final borderColor = widget.isError ? Colors.red : baseBorder;
    final focusColor = widget.isError ? Colors.red : AppColors.primary;
    final hintColor = isDark ? Colors.white.withValues(alpha: 0.55) : const Color(0x99000000);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
      height: 56,
      child: Focus(
        onFocusChange: (_) => setState(() {}),
        child: TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(color: hintColor),
            filled: true,
            fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: _border(borderColor),
            focusedBorder: _border(focusColor),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: InkWell(
                onTap: () => showCountryPicker(
                  context: context,
                  showPhoneCode: true,
                  useSafeArea: true,
                  countryListTheme: CountryListThemeData(
                    backgroundColor: theme.dialogTheme.backgroundColor ?? theme.colorScheme.surface,
                    textStyle: TextStyle(color: theme.colorScheme.onSurface),
                    bottomSheetHeight: 500,
                    flagSize: 20,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    inputDecoration: InputDecoration(
                      hintText: 'Search country',
                      hintStyle: TextStyle(
                        color: theme.hintColor,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.dividerColor, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary, width: 1),
                      ),
                    ),
                  ),
                  onSelect: (Country c) {
                    setState(() => _country = c);
                    widget.onCountryChanged('+${c.phoneCode}', c.countryCode);
                    _refreshLengths();
                  },
                ),
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_country.flagEmoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                    const SizedBox(width: 12),
                    Container(width: 1, height: 24, color: borderColor),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          ),
          onChanged: (v) {
            final onlyDigits = v.replaceAll(RegExp(r'\D'), '');
            final trunkStripped = (onlyDigits.startsWith('0')) ? onlyDigits.substring(1) : onlyDigits;
            _digits = trunkStripped.length;
            _valid = _digits >= _min && _digits <= _max;
            widget.onChanged(trunkStripped);
            widget.onInfoChanged?.call(digits: _digits, min: _min, max: _max, valid: _valid);
            setState(() {});
          },
        ),
      ),
    ),
          const SizedBox(height: 6),
          Builder(
            builder: (_) {
              final theme = Theme.of(context);
              final isDark = theme.brightness == Brightness.dark;
              final show = _hover || _focusNode.hasFocus;
              if (!show) return const SizedBox.shrink();
              final color = _valid
                  ? Colors.green
                  : isDark ? Colors.white.withValues(alpha: 0.65) : Colors.black.withValues(alpha: 0.55);
              return Row(
                children: [
                  const Spacer(),
                  Text(
                    _min == 0 && _max == 0 ? '' : 'Digits: $_digits / ${_min == _max ? _min : '$_min-$_max'}',
                    style: theme.textTheme.bodySmall?.copyWith(color: color),
                  ),
                ],
              );
            },
          )
        ],
      ),
    );
  }

  void _refreshLengths() {
    try {
      final data = intl_countries.countries.firstWhere(
        (e) => e.code.toUpperCase() == _country.countryCode.toUpperCase(),
        orElse: () => intl_countries.countries.firstWhere((e) => e.code == 'GB'),
      );
      _min = data.minLength;
      _max = data.maxLength;
    } catch (_) {
      _min = 7;
      _max = 12;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final onlyDigits = _controller.text.replaceAll(RegExp(r'\D'), '');
      _digits = onlyDigits.length;
      _valid = _digits >= _min && _digits <= _max;
      widget.onInfoChanged?.call(digits: _digits, min: _min, max: _max, valid: _valid);
      setState(() {});
    });
  }
}
