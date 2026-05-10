// widgets/dashboard_widgets.dart
// Sub-widgets used only by DashboardScreen
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

// ── Bell button ────────────────────────────────────────────────
class DashBellBtn extends StatelessWidget {
  const DashBellBtn({super.key});

  @override
  Widget build(BuildContext context) => Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.dashBorder),
          boxShadow: [
            BoxShadow(
                color: AppColors.dashTextDark.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: const Center(child: Text('🔔', style: TextStyle(fontSize: 17))),
      );
}

// ── Stat tile ──────────────────────────────────────────────────
class DashStatTile extends StatelessWidget {
  final String value;
  final String label;
  final double valueFontSize;
  final Color? valueColor;

  const DashStatTile({
    super.key,
    required this.value,
    required this.label,
    this.valueFontSize = 20,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.dashSurface,
            border: Border.all(color: AppColors.dashBorder, width: 1.2),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: AppColors.dashTextDark.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Column(children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Syne',
                fontSize: valueFontSize,
                fontWeight: FontWeight.w700,
                color: valueColor ?? AppColors.dashTextDark,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 9,
                color: AppColors.dashTextMuted,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ]),
        ),
      );
}

// ── Task card (no priority badges) ────────────────────────────
class DashTaskCard extends StatelessWidget {
  final bool done;
  final String name;
  final String meta;

  const DashTaskCard({
    super.key,
    required this.done,
    required this.name,
    required this.meta,
  });

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: done ? 0.60 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.dashSurface,
            border: Border.all(color: AppColors.dashBorder, width: 1.2),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: AppColors.dashTextDark.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Row(children: [
            // Checkbox circle
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: done
                    ? const LinearGradient(
                        colors: [AppColors.dashTextDark, AppColors.dashGoldDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                border: done
                    ? null
                    : Border.all(
                        color: AppColors.dashTextMuted.withValues(alpha: 0.50), width: 1.8),
                color: done ? null : Colors.white,
              ),
              child: done
                  ? const Center(
                      child: Text('✓',
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              height: 1,
                              fontWeight: FontWeight.w700)))
                  : null,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: done ? AppColors.dashTextMuted : AppColors.dashTextDark,
                    height: 1.3,
                    decoration: done ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.dashTextMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  meta,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 10,
                    color: AppColors.dashTextMuted,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ]),
            ),
          ]),
        ),
      );
}

// ── AI recommendation strip ────────────────────────────────────
class DashAIStrip extends StatelessWidget {
  final TextSpan text;
  const DashAIStrip({super.key, required this.text});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.70),
          border: Border(
            top: BorderSide(color: AppColors.dashGoldDark.withValues(alpha: 0.25)),
            right: BorderSide(color: AppColors.dashGoldDark.withValues(alpha: 0.25)),
            bottom: BorderSide(color: AppColors.dashGoldDark.withValues(alpha: 0.25)),
            left: BorderSide(color: AppColors.dashTextDark.withValues(alpha: 0.75), width: 3),
          ),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(14),
            bottomRight: Radius.circular(14),
          ),
          boxShadow: [
            BoxShadow(
                color: AppColors.dashTextDark.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('✦', style: TextStyle(fontSize: 15, color: AppColors.dashGoldDark)),
          const SizedBox(width: 9),
          Expanded(
            child: Text.rich(
              text,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                color: AppColors.dashTextDark.withValues(alpha: 0.75),
                fontWeight: FontWeight.w300,
                height: 1.55,
              ),
            ),
          ),
        ]),
      );
}

// ── Bottom nav ─────────────────────────────────────────────────
class DashBottomNav extends StatelessWidget {
  final int active;
  final void Function(int) onTap;
  const DashBottomNav({super.key, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.dashSurface,
        border: Border(top: BorderSide(color: AppColors.dashNavBorder, width: 1)),
        boxShadow: [
          BoxShadow(
              color: AppColors.dashTextDark.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -3))
        ],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _NavItem(emoji: '🏠', label: 'Plans', on: active == 0, onTap: () => onTap(0)),
        _NavItem(emoji: '📚', label: 'Library', on: active == 1, onTap: () => onTap(1)),

        // FAB
        GestureDetector(
          onTap: () => onTap(2),
          child: Container(
            width: 46,
            height: 46,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.ctaButton,
              boxShadow: [
                BoxShadow(
                    color: AppColors.dashTextDark.withValues(alpha: 0.32),
                    blurRadius: 28,
                    offset: const Offset(0, 8))
              ],
            ),
            child: const Center(
              child: Text('＋',
                  style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ),

        _NavItem(emoji: '🤖', label: 'AI', on: active == 3, onTap: () => onTap(3)),
        _NavItem(emoji: '⚙', label: 'Settings', on: active == 4, onTap: () => onTap(4)),
      ]),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String emoji;
  final String label;
  final bool on;
  final VoidCallback onTap;
  const _NavItem({required this.emoji, required this.label, required this.on, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              color: on ? AppColors.dashTextDark : AppColors.dashTextMuted,
              letterSpacing: 0.2,
            ),
          ),
        ]),
      );
}
