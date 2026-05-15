import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../features/analysis/model/analysis_models.dart';
import '../theme/design_tokens.dart';

// ─── LaTeX segment parsing ─────────────────────────────────────
sealed class AnalysisSegment {}

class TextSegment extends AnalysisSegment {
  final String text;
  TextSegment(this.text);
}

class LatexSegment extends AnalysisSegment {
  final String latex;
  final bool isDisplay;
  LatexSegment(this.latex, {this.isDisplay = false});
}

List<AnalysisSegment> parseSegments(String raw) {
  final s = raw
      .replaceAll(r'\\(', r'\(')
      .replaceAll(r'\\)', r'\)')
      .replaceAll(r'\\[', r'\[')
      .replaceAll(r'\\]', r'\]');

  final segments = <AnalysisSegment>[];
  final re = RegExp(r'\\\((.+?)\\\)|\\\[(.+?)\\\]', dotAll: true);
  int cursor = 0;

  for (final m in re.allMatches(s)) {
    if (m.start > cursor) segments.add(TextSegment(s.substring(cursor, m.start)));
    final isDisplay = m.group(2) != null;
    segments.add(LatexSegment((m.group(1) ?? m.group(2))!.trim(), isDisplay: isDisplay));
    cursor = m.end;
  }
  if (cursor < s.length) segments.add(TextSegment(s.substring(cursor)));
  return segments;
}

// ─── Top bar ───────────────────────────────────────────────────
class AiTopBar extends StatefulWidget {
  final VoidCallback onBack;
  final Future<void> Function() onDownload;
  const AiTopBar({super.key, required this.onBack, required this.onDownload});

  @override
  State<AiTopBar> createState() => _AiTopBarState();
}

class _AiTopBarState extends State<AiTopBar> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(children: [
          AiIcoBtn(icon: Icons.arrow_back_ios_new_rounded, onTap: widget.onBack),
          const Expanded(
            child: Center(
              child: Text('AI Analysis',
                  style: TextStyle(
                      fontFamily: 'Syne',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.aiTextDark)),
            ),
          ),
          GestureDetector(
            onTap: _loading
                ? null
                : () async {
                    setState(() => _loading = true);
                    await widget.onDownload();
                    if (mounted) setState(() => _loading = false);
                  },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.aiCardBg.withOpacity(0.85),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: AppColors.aiBorder),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.aiTextDark.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Center(
                child: _loading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child:
                            CircularProgressIndicator(strokeWidth: 2, color: AppColors.aiGoldDark),
                      )
                    : const Icon(Icons.download_rounded, size: 16, color: AppColors.aiTextDark),
              ),
            ),
          ),
        ]),
      );
}

// ─── Icon button ───────────────────────────────────────────────
class AiIcoBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const AiIcoBtn({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.aiCardBg.withOpacity(0.85),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: AppColors.aiBorder),
            boxShadow: [
              BoxShadow(
                  color: AppColors.aiTextDark.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Icon(icon, size: 14, color: AppColors.aiTextDark),
        ),
      );
}

// ─── Hero card ─────────────────────────────────────────────────
class AiHeroCard extends StatelessWidget {
  final String displayName;
  final LoadStatus visualStatus;
  final LoadStatus summaryStatus;
  const AiHeroCard({
    super.key,
    required this.displayName,
    required this.visualStatus,
    required this.summaryStatus,
  });

  String get _statusLabel {
    if (visualStatus == LoadStatus.loading || summaryStatus == LoadStatus.loading)
      return 'Analysing…';
    if (visualStatus == LoadStatus.failure || summaryStatus == LoadStatus.failure)
      return 'Partial Results';
    if (visualStatus == LoadStatus.success && summaryStatus == LoadStatus.success)
      return 'Analysis Complete';
    return 'Processing…';
  }

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.aiHeroCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: AppColors.aiHeroCard.withOpacity(0.50),
                blurRadius: 36,
                offset: const Offset(0, 12))
          ],
        ),
        child: Stack(clipBehavior: Clip.hardEdge, children: [
          Positioned(
              top: -30,
              right: -30,
              child: Container(
                  width: 110,
                  height: 110,
                  decoration:
                      const BoxDecoration(shape: BoxShape.circle, color: AppColors.aiHeroDeco1))),
          Positioned(
              bottom: -20,
              right: 20,
              child: Container(
                  width: 60,
                  height: 60,
                  decoration:
                      const BoxDecoration(shape: BoxShape.circle, color: AppColors.aiHeroDeco2))),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                        color: AppColors.aiGoldDark, borderRadius: BorderRadius.circular(5)),
                    child:
                        const Icon(Icons.insert_drive_file_rounded, size: 11, color: Colors.white),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(displayName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 9.5,
                            color: AppColors.aiTextMuted,
                            letterSpacing: 0.4,
                            fontWeight: FontWeight.w600)),
                  ),
                ]),
                const SizedBox(height: 10),
                Text(_statusLabel,
                    style: const TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.4,
                        height: 1.2)),
                const SizedBox(height: 12),
                Row(children: [
                  AiHeroBadge(
                    label: visualStatus == LoadStatus.loading
                        ? '⟳ Analyzing visuals'
                        : visualStatus == LoadStatus.success
                            ? '✦ Visuals ready'
                            : '✕ Visual error',
                    filled: visualStatus == LoadStatus.success,
                  ),
                  const SizedBox(width: 8),
                  AiHeroBadge(
                    label: summaryStatus == LoadStatus.loading
                        ? '⟳ Summarizing'
                        : summaryStatus == LoadStatus.success
                            ? '✦ Summary ready'
                            : '✕ Summary error',
                    filled: summaryStatus == LoadStatus.success,
                  ),
                ]),
              ],
            ),
          ),
        ]),
      );
}

class AiHeroBadge extends StatelessWidget {
  final String label;
  final bool filled;
  const AiHeroBadge({super.key, required this.label, required this.filled});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(filled ? 0.14 : 0.08),
          border: Border.all(color: Colors.white.withOpacity(0.22)),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(label,
            style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 10.5,
                fontWeight: filled ? FontWeight.w700 : FontWeight.w400,
                color: filled ? AppColors.aiGoldLight : Colors.white70)),
      );
}

// ─── Stat tile ─────────────────────────────────────────────────
class AiStatTile extends StatelessWidget {
  final String value;
  final String label;
  const AiStatTile({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: AppColors.aiCardBg,
            border: Border.all(color: AppColors.aiBorder),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: AppColors.aiTextDark.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Column(children: [
            Text(value,
                style: const TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppColors.aiTextDark,
                    letterSpacing: -0.5)),
            const SizedBox(height: 2),
            Text(label.toUpperCase(),
                style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 8.5,
                    color: AppColors.aiTextMuted,
                    letterSpacing: 0.7,
                    fontWeight: FontWeight.w500)),
          ]),
        ),
      );
}

// ─── Tab bar ───────────────────────────────────────────────────
class AiTabBar extends StatelessWidget {
  final int active;
  final List<String> labels;
  final List<IconData> icons;
  final void Function(int) onTap;
  const AiTabBar({
    super.key,
    required this.active,
    required this.labels,
    required this.icons,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.55),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.aiBorder),
        ),
        child: Row(
          children: List.generate(
              labels.length,
              (i) => Expanded(
                    child: GestureDetector(
                      onTap: () => onTap(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color: active == i ? AppColors.aiTextDark : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(icons[i],
                              size: 13,
                              color: active == i ? AppColors.aiGoldLight : AppColors.aiTextMuted),
                          const SizedBox(height: 2),
                          Text(labels[i],
                              style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: active == i ? Colors.white : AppColors.aiTextMuted)),
                        ]),
                      ),
                    ),
                  )),
        ),
      );
}

// ─── Rule card ─────────────────────────────────────────────────
class AiRuleCard extends StatelessWidget {
  final int index;
  final String content;
  const AiRuleCard({super.key, required this.index, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.aiFormulaCardBg,
        border: Border.all(color: AppColors.aiBorder, width: 1.2),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: AppColors.aiTextDark.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.only(top: 2),
          decoration: const BoxDecoration(color: AppColors.aiFormulaTagBg, shape: BoxShape.circle),
          child: Center(
            child: Text('$index',
                style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.aiFormulaTagText)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: AiMarkdownText(text: content)),
      ]),
    );
  }
}

// ─── Graph card ────────────────────────────────────────────────
class AiGraphCard extends StatefulWidget {
  final int index;
  final GraphAnalysis graph;
  const AiGraphCard({super.key, required this.index, required this.graph});

  @override
  State<AiGraphCard> createState() => _AiGraphCardState();
}

class _AiGraphCardState extends State<AiGraphCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.aiCardBg,
            border: Border.all(color: AppColors.aiBorder),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: AppColors.aiTextDark.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: AppColors.aiFormulaTagBg, borderRadius: BorderRadius.circular(6)),
                    child: Text('Graph ${widget.index}',
                        style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.aiFormulaTagText,
                            letterSpacing: 0.4)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(widget.graph.image,
                        style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 10,
                            color: AppColors.aiTextMuted,
                            overflow: TextOverflow.ellipsis)),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: _expanded ? 0.5 : 0,
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 18, color: AppColors.aiTextMuted),
                  ),
                ]),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: _expanded
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(widget.graph.analysis,
                            style: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 12,
                                color: AppColors.aiTextBody,
                                height: 1.6,
                                fontWeight: FontWeight.w300)),
                      )
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                        child: Text(widget.graph.analysis,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 12,
                                color: AppColors.aiTextMuted,
                                height: 1.5,
                                fontWeight: FontWeight.w300)),
                      ),
              ),
            ],
          ),
        ),
      );
}

// ─── Parsed rule card (like the screenshot) ────────────────────
class AiParsedRuleCard extends StatefulWidget {
  final ParsedRule rule;
  final int index;
  const AiParsedRuleCard({
    super.key,
    required this.rule,
    required this.index,
  });

  @override
  State<AiParsedRuleCard> createState() => _AiParsedRuleCardState();
}

class _AiParsedRuleCardState extends State<AiParsedRuleCard> {
  bool _expanded = false;

  void _copyFormula() {
    Clipboard.setData(ClipboardData(text: widget.rule.formula));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            const Text('Formula copied', style: TextStyle(fontFamily: 'DM Sans', fontSize: 12)),
        backgroundColor: AppColors.aiTextDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rule = widget.rule;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.aiCardBg,
        border: Border.all(color: AppColors.aiBorder, width: 1.2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppColors.aiTextDark.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.aiFormulaTagBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('Rule ${widget.index}',
                  style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.aiFormulaTagText,
                      letterSpacing: 0.3)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(rule.title,
                  style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.aiTextDark)),
            ),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: AnimatedRotation(
                duration: const Duration(milliseconds: 200),
                turns: _expanded ? 0.5 : 0,
                child: const Icon(Icons.keyboard_arrow_down_rounded,
                    size: 20, color: AppColors.aiTextMuted),
              ),
            ),
          ]),
        ),

        // ── Formula box
        if (rule.formula.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.aiTextDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                Expanded(
                  child: Text(rule.formula,
                      style: const TextStyle(
                          fontFamily: 'DM Mono',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.aiGoldLight,
                          letterSpacing: 0.5)),
                ),
                GestureDetector(
                  onTap: _copyFormula,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Text('Copy',
                        style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 10.5,
                            color: Colors.white,
                            fontWeight: FontWeight.w500)),
                  ),
                ),
              ]),
            ),
          ),

        // ── Description
        if (rule.description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
            child: Text(rule.description,
                style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    color: AppColors.aiTextMuted,
                    height: 1.5,
                    fontWeight: FontWeight.w300)),
          ),

        // ── Variables (expandable)
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: _expanded && rule.variables.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('VARIABLES',
                          style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.aiTextMuted,
                              letterSpacing: 1.1)),
                      const SizedBox(height: 6),
                      ...rule.variables.map((v) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Container(
                                margin: const EdgeInsets.only(top: 5),
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle, color: AppColors.aiGoldDark),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(v,
                                    style: const TextStyle(
                                        fontFamily: 'DM Sans',
                                        fontSize: 12,
                                        color: AppColors.aiTextBody,
                                        height: 1.5,
                                        fontWeight: FontWeight.w300)),
                              ),
                            ]),
                          )),
                    ],
                  ),
                )
              : const SizedBox(height: 14),
        ),
      ]),
    );
  }
}

// ─── Parsed definition row ──────────────────────────────────────
class AiDefinitionRow extends StatelessWidget {
  final ParsedDefinition def;
  final int index;
  const AiDefinitionRow({super.key, required this.def, required this.index});

  static const _termColors = [
    Color(0xFFC9943A),
    Color(0xFF8B5E3C),
    Color(0xFF5E8B3C),
    Color(0xFF3C5E8B),
    Color(0xFF8B3C5E),
    Color(0xFF5E3C8B),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _termColors[index % _termColors.length];
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Term chip — constrained width
        Container(
          constraints: const BoxConstraints(maxWidth: 220),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            border: Border.all(color: color.withOpacity(0.30)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            def.term,
            style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: color),
          ),
        ),
        const SizedBox(height: 5),
        // Definition below — full width
        Text(
          def.definition,
          style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12.5,
              color: AppColors.aiTextBody,
              height: 1.55,
              fontWeight: FontWeight.w300),
        ),
      ]),
    );
  }
}

// ─── Markdown text ─────────────────────────────────────────────
class AiMarkdownText extends StatelessWidget {
  final String text;
  const AiMarkdownText({super.key, required this.text});

  String _normalize(String raw) => raw
      .replaceAll(r'\n', '\n')
      .replaceAll(r'\r', '')
      .replaceAll('\r\n', '\n');

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: _normalize(text),
      shrinkWrap: true,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        // Headings
        h1: const TextStyle(
          fontFamily: 'Syne',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.aiTextDark,
          height: 1.3,
        ),
        h2: const TextStyle(
          fontFamily: 'Syne',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.aiTextDark,
          height: 1.3,
        ),
        h3: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.aiTextDark,
          height: 1.4,
        ),
        h4: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: AppColors.aiTextBody,
          height: 1.4,
        ),
        // Body
        p: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 13,
          color: AppColors.aiTextBody,
          height: 1.65,
          fontWeight: FontWeight.w300,
        ),
        // Bold
        strong: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.aiTextDark,
        ),
        // Italic
        em: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 13,
          fontStyle: FontStyle.italic,
          color: AppColors.aiTextBody,
        ),
        // Bullet list
        listBullet: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 13,
          color: AppColors.aiGoldDark,
          fontWeight: FontWeight.w700,
        ),
        // Inline code
        code: TextStyle(
          fontFamily: 'DM Mono',
          fontSize: 12,
          color: AppColors.aiGoldDark,
          backgroundColor: AppColors.aiFormulaTagBg,
        ),
        // Code block
        codeblockDecoration: BoxDecoration(
          color: AppColors.aiFormulaCardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.aiBorder),
        ),
        codeblockPadding: const EdgeInsets.all(12),
        // Blockquote
        blockquote: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 12.5,
          color: AppColors.aiTextMuted,
          fontStyle: FontStyle.italic,
          height: 1.6,
        ),
        blockquoteDecoration: BoxDecoration(
          color: AppColors.aiChipBg,
          border: Border(
            left: BorderSide(color: AppColors.aiGoldDark, width: 3),
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        blockquotePadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        // Spacing
        h1Padding: const EdgeInsets.only(top: 14, bottom: 4),
        h2Padding: const EdgeInsets.only(top: 12, bottom: 4),
        h3Padding: const EdgeInsets.only(top: 8, bottom: 2),
        pPadding: const EdgeInsets.only(bottom: 6),
        listIndent: 20,
        blockSpacing: 8,
        // Horizontal rule
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.aiBorder, width: 1),
          ),
        ),
      ),
    );
  }
}

// ─── Content shell ─────────────────────────────────────────────
class AiContentShell extends StatelessWidget {
  final String label;
  final Widget child;
  const AiContentShell({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.aiCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.aiBorder),
          boxShadow: [
            BoxShadow(
                color: AppColors.aiTextDark.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label.isNotEmpty) ...[
              AiSectionLabel(label),
              const SizedBox(height: 10),
            ],
            child,
          ],
        ),
      );
}

// ─── Error retry ───────────────────────────────────────────────
class AiErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const AiErrorRetry({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.aiErrorBg,
          border: Border.all(color: AppColors.aiErrorBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [
              Icon(Icons.error_outline_rounded, size: 14, color: AppColors.aiErrorText),
              SizedBox(width: 6),
              Text('Failed to load',
                  style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.aiErrorText)),
            ]),
            const SizedBox(height: 4),
            Text(message,
                style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 10.5,
                    color: AppColors.aiErrorText,
                    fontWeight: FontWeight.w300)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                    color: AppColors.aiTextDark, borderRadius: BorderRadius.circular(8)),
                child: const Text('Retry',
                    style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      );
}

// ─── Skeleton widgets ──────────────────────────────────────────
class AiTextSkeleton extends StatefulWidget {
  final int lines;
  const AiTextSkeleton({super.key, required this.lines});

  @override
  State<AiTextSkeleton> createState() => _AiTextSkeletonState();
}

class _AiTextSkeletonState extends State<AiTextSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
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
          opacity: 0.4 + _c.value * 0.4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(widget.lines, (i) {
              const widths = [0.9, 0.75, 0.88, 0.6, 0.82, 0.7];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                height: 11,
                width: MediaQuery.of(context).size.width * widths[i % widths.length],
                decoration: BoxDecoration(
                    color: AppColors.aiSkeletonBg, borderRadius: BorderRadius.circular(4)),
              );
            }),
          ),
        ),
      );
}

class AiRuleSkeleton extends StatefulWidget {
  const AiRuleSkeleton({super.key});

  @override
  State<AiRuleSkeleton> createState() => _AiRuleSkeletonState();
}

class _AiRuleSkeletonState extends State<AiRuleSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
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
          opacity: 0.4 + _c.value * 0.4,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: AppColors.aiFormulaCardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.aiBorder),
            ),
            child: Row(children: [
              Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(color: AppColors.aiSkeletonBg, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        width: double.infinity,
                        height: 11,
                        decoration: BoxDecoration(
                            color: AppColors.aiSkeletonBg, borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 6),
                    Container(
                        width: MediaQuery.of(context).size.width * 0.55,
                        height: 11,
                        decoration: BoxDecoration(
                            color: AppColors.aiSkeletonBg.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(4))),
                  ],
                ),
              ),
            ]),
          ),
        ),
      );
}

// ─── Empty state ───────────────────────────────────────────────
class AiEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const AiEmptyState({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(children: [
          Icon(icon, size: 28, color: AppColors.aiTextMuted.withOpacity(0.5)),
          const SizedBox(height: 10),
          Text(message,
              style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  color: AppColors.aiTextMuted,
                  fontWeight: FontWeight.w400)),
        ]),
      );
}

// ─── Section label ─────────────────────────────────────────────
class AiSectionLabel extends StatelessWidget {
  final String text;
  const AiSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(),
      style: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: AppColors.aiTextMuted,
          letterSpacing: 1.1));
}

// ─── Topic chip ────────────────────────────────────────────────
class AiChip extends StatelessWidget {
  final String label;
  const AiChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.aiChipBg,
          border: Border.all(color: AppColors.aiChipBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11.5,
                color: AppColors.aiTextDark,
                fontWeight: FontWeight.w400)),
      );
}

// ─── Ask AI strip ──────────────────────────────────────────────
class AiAskStrip extends StatelessWidget {
  final VoidCallback onTap;
  const AiAskStrip({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.aiCardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.aiBorderDash.withOpacity(0.80), width: 1.5),
          ),
          child: Row(children: [
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(color: AppColors.aiTextDark, shape: BoxShape.circle),
              child: const Center(
                child: Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.aiGoldLight),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ask AI about this document',
                      style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.aiTextDark)),
                  SizedBox(height: 1),
                  Text('Tap to start a conversation',
                      style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 10.5,
                          color: AppColors.aiTextMuted,
                          fontWeight: FontWeight.w300)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.aiGoldDark),
          ]),
        ),
      );
}

// ─── Refresh button (Rules + Definitions tabs) ─────────────────
class AiRefreshBtn extends StatelessWidget {
  final VoidCallback onTap;
  const AiRefreshBtn({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.aiChipBg,
            border: Border.all(color: AppColors.aiChipBorder),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.refresh_rounded, size: 11, color: AppColors.aiTextMuted),
            const SizedBox(width: 4),
            const Text('Refresh',
                style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 10,
                    color: AppColors.aiTextMuted,
                    fontWeight: FontWeight.w500)),
          ]),
        ),
      );
}