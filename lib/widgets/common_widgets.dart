// ============================================================
// MindEdge Shared UI Components
// ============================================================

import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../theme/theme.dart';
import '../animations/animation_helpers.dart';

// ─── Primary CTA Button ───────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Gradient gradient;
  final Duration shimmerDelay;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.gradient = AppGradients.ctaButton,
    this.shimmerDelay = const Duration(milliseconds: 1500),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppRadius.button),
          boxShadow: [
            ...AppShadows.btn,
            BoxShadow(
              color: Colors.white.withOpacity(0.08),
              blurRadius: 0,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.button),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Center(
                  child: Text(
                    label,
                    style: AppTheme.dmSans(
                      size: AppTextSize.button,
                      weight: FontWeight.w600,
                      color: AppColors.white,
                      letterSpacing: 0.03 * AppTextSize.button,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: ShimmerOverlay(
                  delay: shimmerDelay,
                  duration: AppDuration.shimmerBtn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Custom Primary Button ───────────────────────────────────
class CustomPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const CustomPrimaryButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFC9A96E), Color(0xFF7C5642)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2A1A0E).withValues(alpha: 0.32),
              blurRadius: 28,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Social Auth Button ───────────────────────────────────────
class SocialButton extends StatelessWidget {
  final String label;
  final String icon;
  final VoidCallback? onTap;

  const SocialButton({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.62),
            border: Border.all(color: const Color(0xFFB48C50).withOpacity(0.18), width: 1.5),
            borderRadius: BorderRadius.circular(AppRadius.socialBtn),
            boxShadow: AppShadows.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: TextStyle(fontSize: AppTextSize.icon)),
              const SizedBox(width: 7),
              Text(
                label,
                style: AppTheme.dmSans(
                  size: AppTextSize.social,
                  weight: FontWeight.w500,
                  color: AppColors.cocoaDeep,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Auth Input Field ─────────────────────────────────────────
class AuthInputField extends StatelessWidget {
  final String label;
  final String placeholder;
  final bool isFocused;
  final String? trailingIcon;
  final bool obscure;

  const AuthInputField({
    super.key,
    required this.label,
    required this.placeholder,
    this.isFocused = false,
    this.trailingIcon,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.dmSans(
            size: AppTextSize.labelSm,
            weight: FontWeight.w600,
            color: const Color(0xFF6B4C3B),
            letterSpacing: 0.1 * 10.5,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.72),
            border: Border.all(
              color: isFocused ? AppColors.cocoa : const Color(0xFFB48C50).withOpacity(0.20),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(AppRadius.input),
            boxShadow: isFocused
                ? AppShadows.inputFocus
                : [
                    ...AppShadows.sm,
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 0,
                      offset: const Offset(0, -1),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  placeholder,
                  style: AppTheme.dmSans(
                    size: AppTextSize.input,
                    weight: FontWeight.w300,
                    color: AppColors.muted,
                  ),
                ),
              ),
              if (trailingIcon != null)
                Text(
                  trailingIcon!,
                  style: TextStyle(
                    fontSize: AppTextSize.iconSm,
                    color: AppColors.muted.withOpacity(0.4),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Auth Divider ─────────────────────────────────────────────
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.cocoa.withOpacity(0.12),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or sign up with',
            style: AppTheme.dmSans(
              size: 11,
              color: AppColors.muted,
              letterSpacing: 0.06 * 11,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.cocoa.withOpacity(0.12),
          ),
        ),
      ],
    );
  }
}

// ─── Password Strength Bars ───────────────────────────────────
class PasswordStrengthBars extends StatelessWidget {
  final int strength; // 0..4

  const PasswordStrengthBars({super.key, this.strength = 2});

  Color _barColor(int index) {
    if (index >= strength) return AppColors.cocoa.withOpacity(0.13);
    if (index == 0) return AppColors.cocoa;
    if (index == 1) return AppColors.gold;
    if (index == 2) return AppColors.tan;
    return AppColors.goldLight;
  }

  String get _label {
    switch (strength) {
      case 1:
        return 'Too short.';
      case 2:
        return 'Add symbols and numbers.';
      case 3:
        return 'Good password.';
      case 4:
        return 'Excellent. You\'re secure. ✓';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(
              4,
              (i) => [
                    Expanded(
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: _barColor(i),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    if (i < 3) const SizedBox(width: 4),
                  ]).expand((e) => e).toList(),
        ),
        const SizedBox(height: 4),
        Text(
          _label,
          style: AppTheme.dmSans(
            size: 10,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}



// ─── Terms Checkbox Row ───────────────────────────────────────
class TermsRow extends StatelessWidget {
  final bool checked;
  final VoidCallback? onTap;
  const TermsRow({super.key, this.checked = true, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18,
          height: 18,
          margin: const EdgeInsets.only(top: 1),
          decoration: BoxDecoration(
            color: AppColors.cocoa.withOpacity(0.10),
            border: Border.all(color: AppColors.cocoa, width: 1.5),
            borderRadius: BorderRadius.circular(AppRadius.checkbox),
          ),
          child: checked
              ? Center(
                  child: Text(
                    '✓',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.cocoa,
                      height: 1,
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: 'I agree to the ',
              style: AppTheme.dmSans(
                size: 11,
                color: AppColors.muted,
                height: 1.55,
                weight: FontWeight.w300,
              ),
              children: [
                TextSpan(
                  text: 'Terms of Service',
                  style: AppTheme.dmSans(
                    size: 11,
                    color: AppColors.cocoa,
                    weight: FontWeight.w500,
                  ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: AppTheme.dmSans(
                    size: 11,
                    color: AppColors.cocoa,
                    weight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      ),
    );
  }
}

// ─── Back Button ─────────────────────────────────────────────
class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  const AppBackButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.pop(context),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          border: Border.all(color: const Color(0xFFB48C50).withOpacity(0.16), width: 1),
          borderRadius: BorderRadius.circular(AppRadius.smallBtn),
          boxShadow: AppShadows.sm,
        ),
        child: Center(
          child: Text(
            '←',
            style: TextStyle(fontSize: 16, color: AppColors.cocoa),
          ),
        ),
      ),
    );
  }
}

// ─── Onboarding Progress Dots ─────────────────────────────────
class OnboardingDots extends StatelessWidget {
  final int total;
  final int active;

  const OnboardingDots({super.key, required this.total, required this.active});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final isActive = i == active;
        final dot = Container(
          height: 4,
          width: isActive ? 20 : 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.cocoa : AppColors.cocoa.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2),
          ),
        );
        if (isActive) {
          return Padding(
            padding: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
            child: DotBreath(child: dot),
          );
        }
        return Padding(
          padding: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
          child: dot,
        );
      }),
    );
  }
}

// ─── Floating Badge ───────────────────────────────────────────
class FloatingBadge extends StatelessWidget {
  final String label;
  final bool showLiveDot;

  const FloatingBadge({
    super.key,
    required this.label,
    this.showLiveDot = false,
    required BoxDecoration decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        // التدرج اللوني المرجعي (البيج للبني)
        gradient: const LinearGradient(
          colors: [Color(0xFFC9A96E), Color(0xFF7C5642)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.badge),
        boxShadow: [
          BoxShadow(
            // الظل الموحد
            color: const Color(0xFF000000).withOpacity(0.32),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLiveDot) ...[
            const AntennaPulse(size: 6),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: AppTheme.dmSans(
              size: AppTextSize.labelSm,
              weight: FontWeight.w500,
              color: AppColors.white,
              letterSpacing: 0.02 * 10.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step progress bar ─────────────────────────────────────────
class AuthStepBar extends StatelessWidget {
  final int steps;
  final int filled;
  const AuthStepBar({super.key, required this.steps, required this.filled});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 14, 26, 0),
      child: Row(
        children: List.generate(steps, (i) {
          final on = i < filled;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < steps - 1 ? 6 : 0),
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: on ? Colors.transparent : AppColors.cocoa.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: on
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: Stack(children: [
                          Container(
                              decoration: const BoxDecoration(gradient: AppGradients.progress)),
                          ShimmerOverlay(
                            duration: const Duration(milliseconds: 2000),
                            delay: const Duration(milliseconds: 500),
                            shimmerOpacity: 0.4,
                          ),
                        ]),
                      )
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Loading button ────────────────────────────────────────────
class AuthLoadingBtn extends StatelessWidget {
  final String label;
  const AuthLoadingBtn({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: AppGradients.ctaButton,
        borderRadius: BorderRadius.circular(AppRadius.button),
        boxShadow: AppShadows.btn,
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.white)),
      ]),
    );
  }
}

