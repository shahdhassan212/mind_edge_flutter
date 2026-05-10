// widgets/onboarding_helpers.dart
// Shared widgets used across onboarding screens
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

// ─── Onboarding Title (RichText dark/accent parts) ────────────
/// parts: list of (text, isDark) — isDark=true → cocoaDeep, false → cocoa
class ObTitle extends StatelessWidget {
  final List<(String, bool)> parts;
  const ObTitle({super.key, required this.parts});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: parts
            .map((p) => TextSpan(
                  text: p.$1,
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: p.$2 ? AppColors.cocoaDeep : AppColors.cocoa,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// ─── Onboarding Body Text ──────────────────────────────────────
class ObBody extends StatelessWidget {
  final String text;
  const ObBody(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 12.5,
        color: Color(0xFF6B4C3B),
        fontWeight: FontWeight.w300,
        height: 1.6,
      ),
    );
  }
}
