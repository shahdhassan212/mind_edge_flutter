// widgets/scan_widgets.dart
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../widgets/animation_helpers.dart';
import '../features/library/models/folder_model.dart';

// ─────────────────────────────────────────────────────────────
// CORNER BRACKET
// ─────────────────────────────────────────────────────────────
class ScanCorner extends StatelessWidget {
  final bool tl, tr, bl, br;
  final Color color;
  const ScanCorner({
    super.key,
    this.tl = false,
    this.tr = false,
    this.bl = false,
    this.br = false,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 22,
        height: 22,
        child: CustomPaint(
          painter: _CornerPainter(tl: tl, tr: tr, bl: bl, br: br, color: color),
        ),
      );
}

class _CornerPainter extends CustomPainter {
  final bool tl, tr, bl, br;
  final Color color;
  const _CornerPainter({
    required this.tl,
    required this.tr,
    required this.bl,
    required this.br,
    required this.color,
  });

  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;
    if (tl) {
      c.drawLine(Offset(0, s.height * .5), const Offset(0, 4), p);
      c.drawArc(const Rect.fromLTWH(0, 0, 8, 8), -3.14 / 2, 3.14 / 2, false, p);
      c.drawLine(const Offset(4, 0), Offset(s.width * .5, 0), p);
    }
    if (tr) {
      c.drawLine(Offset(s.width * .5, 0), Offset(s.width - 4, 0), p);
      c.drawArc(Rect.fromLTWH(s.width - 8, 0, 8, 8), 0, -3.14 / 2, false, p);
      c.drawLine(Offset(s.width, 4), Offset(s.width, s.height * .5), p);
    }
    if (bl) {
      c.drawLine(Offset(0, s.height * .5), Offset(0, s.height - 4), p);
      c.drawArc(Rect.fromLTWH(0, s.height - 8, 8, 8), 3.14 / 2, 3.14 / 2, false, p);
      c.drawLine(Offset(4, s.height), Offset(s.width * .5, s.height), p);
    }
    if (br) {
      c.drawLine(Offset(s.width * .5, s.height), Offset(s.width - 4, s.height), p);
      c.drawArc(Rect.fromLTWH(s.width - 8, s.height - 8, 8, 8), 0, 3.14 / 2, false, p);
      c.drawLine(Offset(s.width, s.height - 4), Offset(s.width, s.height * .5), p);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────────
// CAMERA CONTROL BUTTON (Flash / Flip)
// ─────────────────────────────────────────────────────────────
class ScanCamControl extends StatelessWidget {
  final String icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const ScanCamControl({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Column(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? AppColors.gold.withOpacity(0.18) : Colors.white.withOpacity(0.07),
              border: Border.all(
                color: active ? AppColors.gold.withOpacity(0.5) : AppColors.gold.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 10.5,
              color: AppColors.white.withOpacity(0.5),
            ),
          ),
        ]),
      );
}

// ─────────────────────────────────────────────────────────────
// PROGRESS BAR
// ─────────────────────────────────────────────────────────────
class ScanProgressBar extends StatelessWidget {
  final double value;
  const ScanProgressBar({super.key, required this.value});

  @override
  Widget build(BuildContext context) => Container(
        height: 3,
        decoration: BoxDecoration(
          color: AppColors.gold.withOpacity(0.12),
          borderRadius: BorderRadius.circular(2),
        ),
        child: FractionallySizedBox(
          widthFactor: value,
          alignment: Alignment.centerLeft,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Stack(children: [
              Container(decoration: const BoxDecoration(gradient: AppGradients.progress)),
              ShimmerOverlay(
                duration: const Duration(milliseconds: 1600),
                delay: Duration.zero,
                shimmerOpacity: 0.4,
              ),
            ]),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────
// DARK NAV BUTTON
// ─────────────────────────────────────────────────────────────
class ScanDarkNavBtn extends StatelessWidget {
  final Widget child;
  const ScanDarkNavBtn({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          border: Border.all(color: AppColors.gold.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: child),
      );
}

// ─────────────────────────────────────────────────────────────
// PULSING DOT
// ─────────────────────────────────────────────────────────────
class ScanPulsingDot extends StatefulWidget {
  const ScanPulsingDot({super.key});

  @override
  State<ScanPulsingDot> createState() => _ScanPulsingDotState();
}

class _ScanPulsingDotState extends State<ScanPulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, __) => Opacity(
          opacity: 0.6 + _c.value * 0.4,
          child: Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold,
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────
// FOLDER PICKER BOTTOM SHEET
// ─────────────────────────────────────────────────────────────
class FolderPickerSheet extends StatefulWidget {
  final List<LibFolder> folders;
  final void Function(LibFolder) onFolderSelected;
  final void Function(String name) onCreateFolder;

  const FolderPickerSheet({
    super.key,
    required this.folders,
    required this.onFolderSelected,
    required this.onCreateFolder,
  });

  @override
  State<FolderPickerSheet> createState() => _FolderPickerSheetState();
}

class _FolderPickerSheetState extends State<FolderPickerSheet> {
  final _newFolderCtrl = TextEditingController();
  bool _showCreate = false;

  @override
  void dispose() {
    _newFolderCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _newFolderCtrl.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop();
    widget.onCreateFolder(name);
  }

  @override
  Widget build(BuildContext context) {
    const cardBg = Color(0xFF1C1108);
    const border = Color(0xFF3A2A14);
    const gold = Color(0xFFC9943A);
    const textLight = Color(0xFFD9CCB5);
    const textMuted = Color(0xFF7A6A52);

    return Container(
      decoration: const BoxDecoration(
        color: cardBg,
        border: Border(top: BorderSide(color: border, width: 1.2)),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Save to Folder',
            style: TextStyle(
              fontFamily: 'Syne',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: textLight,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Choose where to save the captured image',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 11.5,
              color: textMuted,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 16),

          // Folder list
          if (widget.folders.isEmpty && !_showCreate)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'No folders yet — create one below',
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    color: textMuted,
                  ),
                ),
              ),
            )
          else
            ...widget.folders.map((folder) => GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    widget.onFolderSelected(folder);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      border: Border.all(color: border),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: gold.withOpacity(0.10),
                          border: Border.all(color: gold.withOpacity(0.20)),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Center(
                          child: Icon(Icons.folder_rounded, size: 18, color: gold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              folder.name,
                              style: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: textLight,
                              ),
                            ),
                            Text(
                              '${folder.files.length} ${folder.files.length == 1 ? 'file' : 'files'}',
                              style: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 10,
                                color: textMuted,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, size: 18, color: textMuted),
                    ]),
                  ),
                )),

          const SizedBox(height: 4),

          // Create new folder
          if (_showCreate) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                border: Border.all(color: gold.withOpacity(0.35)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _newFolderCtrl,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      color: textLight,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Folder name…',
                      hintStyle: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        color: textMuted,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _submit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: gold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: gold,
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ] else
            GestureDetector(
              onTap: () => setState(() => _showCreate = true),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: gold.withOpacity(0.25), width: 1.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.create_new_folder_outlined, size: 16, color: gold.withOpacity(0.8)),
                  const SizedBox(width: 8),
                  Text(
                    'Create New Folder',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: gold.withOpacity(0.8),
                    ),
                  ),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}
