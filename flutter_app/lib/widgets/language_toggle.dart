import 'package:flutter/material.dart';

import '../localisation/app_language.dart';
import '../theme/dyfala_theme.dart';

class LanguageToggle extends StatelessWidget {
  const LanguageToggle({
    super.key,
    required this.language,
    required this.onChanged,
    this.compact = false,
  });

  final UiLanguage language;
  final ValueChanged<UiLanguage> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final height = compact ? 40.0 : 44.0;
    return Semantics(
      label: language == UiLanguage.english
          ? 'Switch language. English selected.'
          : 'Newid iaith. Cymraeg wedi’i ddewis.',
      button: true,
      child: Container(
        height: height,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.88),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: DyfalaPalette.tileBorder.withOpacity(.7)),
          boxShadow: const [
            BoxShadow(color: Color(0x10071A27), blurRadius: 12, offset: Offset(0, 5)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Choice(
              label: 'EN',
              selected: language == UiLanguage.english,
              selectedColour: DyfalaPalette.red,
              onTap: () => onChanged(UiLanguage.english),
            ),
            _Choice(
              label: 'CY',
              selected: language == UiLanguage.welsh,
              selectedColour: DyfalaPalette.green,
              onTap: () => onChanged(UiLanguage.welsh),
            ),
          ],
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.selectedColour,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color selectedColour;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 39,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? selectedColour : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : DyfalaPalette.navy,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: .5,
          ),
        ),
      ),
    );
  }
}
