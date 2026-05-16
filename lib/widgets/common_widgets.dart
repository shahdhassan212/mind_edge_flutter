// ============================================================
// MindEdge Shared UI Components — v4.0
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/design_tokens.dart';
import '../theme/theme.dart';
import '../widgets/animation_helpers.dart';

// ─── Gradient Button (replaces PrimaryButton, CustomPrimaryButton,
//     AuthLoadingBtn, _LoadingButton, _LoadingBtn) ──────────────
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final Gradient gradient;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.gradient = AppGradients.ctaButton,
  });

  static const _shadow = BoxShadow(
    color: Color(0x52000000),
    blurRadius: 28,
    offset: Offset(0, 8),
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppRadius.button),
          boxShadow: const [_shadow],
        ),
        child: Center(
          child: isLoading
              ? const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                    SizedBox(width: 10),
                  ],
                )
              : Text(
                  label,
                  style: AppTheme.dmSans(
                    size: AppTextSize.button,
                    weight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}

// ─── Input Field (replaces _SignInField + _SignUpField) ───────
class AppInputField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final VoidCallback? onToggleObscure;
  final ValueChanged<String>? onChanged;

  const AppInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.focusNode,
    this.obscureText = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.onToggleObscure,
    this.onChanged,
  });

  @override
  State<AppInputField> createState() => _AppInputFieldState();
}

class _AppInputFieldState extends State<AppInputField> {
  late final FocusNode _focus;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focus = widget.focusNode ?? FocusNode();
    _focus.addListener(_onFocus);
  }

  void _onFocus() => setState(() => _isFocused = _focus.hasFocus);

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: _isFocused ? AppColors.cocoa : const Color(0xFF6B4C3B),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: _isFocused ? 0.92 : 0.80),
            border: Border.all(
              color: _isFocused ? AppColors.cocoa : const Color(0xFFB48C50).withValues(alpha: 0.25),
              width: _isFocused ? 1.5 : 1.0,
            ),
            borderRadius: BorderRadius.circular(AppRadius.input),
            boxShadow: _isFocused ? AppShadows.inputFocus : AppShadows.sm,
          ),
          child: TextField(
            focusNode: _focus,
            controller: widget.controller,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            textCapitalization: widget.textCapitalization,
            onChanged: widget.onChanged,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              color: AppColors.cocoaDeep,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                color: AppColors.muted.withValues(alpha: 0.45),
                fontWeight: FontWeight.w300,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: InputBorder.none,
              suffixIcon: widget.onToggleObscure != null
                  ? GestureDetector(
                      onTap: widget.onToggleObscure,
                      child: Icon(
                        widget.obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                        color: AppColors.muted.withValues(alpha: 0.55),
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── App Logo (Mind + Edge) ────────────────────────────────────
class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 15});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(children: [
        TextSpan(
          text: 'Mind',
          style: TextStyle(
            fontFamily: 'Syne',
            fontSize: size,
            fontWeight: FontWeight.w700,
            color: AppColors.cocoaDeep,
            letterSpacing: -0.2,
          ),
        ),
        TextSpan(
          text: 'Edge',
          style: TextStyle(
            fontFamily: 'Syne',
            fontSize: size,
            fontWeight: FontWeight.w700,
            color: AppColors.cocoa,
            letterSpacing: -0.2,
          ),
        ),
      ]),
    );
  }
}

// ─── Onboarding Top Bar (Logo only) ───────────────────────────
class ObTopBar extends StatelessWidget {
  final bool isSmall;
  const ObTopBar({super.key, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(28, isSmall ? 6 : 10, 28, 0),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [AppLogo()],
      ),
    );
  }
}

// ─── Snack Bar (error + success) ──────────────────────────────
class AppSnackBar {
  static const _successBg = Color(0xFF3D5226);

  static void show(
    BuildContext context,
    String message, {
    bool isError = true,
    IconData? icon,
  }) {
    final bg = isError ? AppColors.cocoaDeep : _successBg;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Row(children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ]),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ));
  }
}

// Keep old name as alias so existing callers don't break
class AppErrorSnackBar {
  static void show(BuildContext context, String message, {IconData? icon}) =>
      AppSnackBar.show(context, message, isError: true, icon: icon);
}

// ─── Decorative Radial Orb ─────────────────────────────────────
class AppDecorOrb extends StatelessWidget {
  final double? top, bottom, left, right;
  final double size;
  final Color color;
  const AppDecorOrb({
    super.key,
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, Colors.transparent], radius: 0.68),
        ),
      ),
    );
  }
}

// ─── Screen Top Bar (Back + centered title) ────────────────────
class AppScreenTopBar extends StatelessWidget {
  final String title;
  const AppScreenTopBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 10, 26, 0),
      child: Row(children: [
        const AppBackButton(),
        const Spacer(),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Syne',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.cocoaDeep,
          ),
        ),
        const Spacer(),
        const SizedBox(width: 36),
      ]),
    );
  }
}

// ─── Blink Cursor (OTP boxes) ──────────────────────────────────
class BlinkCursor extends StatefulWidget {
  const BlinkCursor({super.key});

  @override
  State<BlinkCursor> createState() => _BlinkCursorState();
}

class _BlinkCursorState extends State<BlinkCursor> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: _ctrl.value > 0.5 ? 1 : 0,
        child: Container(
          width: 2,
          height: 26,
          decoration: BoxDecoration(color: AppColors.cocoa, borderRadius: BorderRadius.circular(1)),
        ),
      ),
    );
  }
}

// ─── OTP Input Row (6 boxes) ───────────────────────────────────
class OtpRow extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final ValueChanged<int>? onChanged;

  const OtpRow({
    super.key,
    required this.controllers,
    required this.focusNodes,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 28, 26, 0),
      child: Row(
        children: List.generate(6, (i) {
          final isFilled = controllers[i].text.isNotEmpty;
          final isActive = focusNodes[i].hasFocus;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < 5 ? 10 : 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(isFilled ? 0.88 : 0.72),
                  border: Border.all(
                    color: isFilled || isActive
                        ? AppColors.cocoa
                        : const Color(0xFFB48C50).withOpacity(0.22),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isFilled || isActive
                      ? [
                          BoxShadow(
                              color: AppColors.cocoa.withOpacity(0.09),
                              blurRadius: 0,
                              spreadRadius: 3),
                          ...AppShadows.sm,
                        ]
                      : AppShadows.sm,
                ),
                child: Stack(alignment: Alignment.center, children: [
                  TextField(
                    controller: controllers[i],
                    focusNode: focusNodes[i],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: const TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cocoaDeep),
                    decoration: const InputDecoration(
                        border: InputBorder.none, contentPadding: EdgeInsets.zero),
                    onChanged: (_) => onChanged?.call(i),
                  ),
                  if (isActive && controllers[i].text.isEmpty) const BlinkCursor(),
                ]),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Social Auth Button ────────────────────────────────────────
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

// ─── Auth Divider ──────────────────────────────────────────────
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.cocoa.withOpacity(0.12))),
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
        Expanded(child: Container(height: 1, color: AppColors.cocoa.withOpacity(0.12))),
      ],
    );
  }
}

// ─── Password Strength Bars ────────────────────────────────────
class PasswordStrengthBars extends StatelessWidget {
  final int strength; // 0..4
  const PasswordStrengthBars({super.key, this.strength = 0});

  Color _barColor(int i) {
    if (i >= strength) return AppColors.cocoa.withOpacity(0.13);
    const colors = [AppColors.cocoa, AppColors.gold, AppColors.tan, AppColors.goldLight];
    return colors[i];
  }

  String get _label => switch (strength) {
        1 => 'Too short.',
        2 => 'Add symbols and numbers.',
        3 => 'Good password.',
        4 => 'Excellent. You\'re secure. ✓',
        _ => '',
      };

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
        Text(_label, style: AppTheme.dmSans(size: 10, color: AppColors.muted)),
      ],
    );
  }
}

// ─── Terms Checkbox Row ────────────────────────────────────────
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
                ? const Center(
                    child: Text('✓',
                        style: TextStyle(fontSize: 10, color: AppColors.cocoa, height: 1)),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'I agree to the ',
                style: AppTheme.dmSans(
                    size: 11, color: AppColors.muted, height: 1.55, weight: FontWeight.w300),
                children: [
                  TextSpan(
                    text: 'Terms of Service',
                    style:
                        AppTheme.dmSans(size: 11, color: AppColors.cocoa, weight: FontWeight.w500),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style:
                        AppTheme.dmSans(size: 11, color: AppColors.cocoa, weight: FontWeight.w500),
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

// ─── Back Button ──────────────────────────────────────────────
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
          child: Text('←', style: TextStyle(fontSize: 16, color: AppColors.cocoa)),
        ),
      ),
    );
  }
}

// ─── Onboarding Progress Dots ──────────────────────────────────
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
        return Padding(
          padding: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
          child: isActive ? DotBreath(child: dot) : dot,
        );
      }),
    );
  }
}

// ─── Floating Badge ────────────────────────────────────────────
class FloatingBadge extends StatelessWidget {
  final String label;
  final bool showLiveDot;
  const FloatingBadge({super.key, required this.label, this.showLiveDot = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        gradient: AppGradients.badge,
        borderRadius: BorderRadius.circular(AppRadius.badge),
        boxShadow: const [
          BoxShadow(color: Color(0x52000000), blurRadius: 24, offset: Offset(0, 8)),
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

// ─── Step Label ────────────────────────────────────────────────
class StepLabel extends StatelessWidget {
  final String text;
  const StepLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 5, 26, 0),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 10,
          color: AppColors.muted,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ─── Auth Step Bar ─────────────────────────────────────────────
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
