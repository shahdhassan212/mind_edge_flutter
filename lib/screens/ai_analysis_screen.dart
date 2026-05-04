// ============================================================
// AI Analysis Screen — with Formula Sheet tab
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';

// ─────────────────────────────────────────────────────────────
// COLOR TOKENS
// ─────────────────────────────────────────────────────────────
class _C {
  static const pageBg = Color(0xFFF4EDE0);
  static const cardBg = Color(0xFFFEFCF7);
  static const heroCard = Color(0xFF201410);
  static const textDark = Color(0xFF2A1A0E);
  static const textBody = Color(0xFF3A2410);
  static const textMuted = Color(0xFF9E8A72);
  static const textHint = Color(0xFFB8A88A);
  static const goldDark = Color(0xFFC9943A);
  static const goldLight = Color(0xFFE8B84B);
  static const border = Color(0xFFE8D9C0);
  static const borderDash = Color(0xFFE0C898);
  static const chipBg = Color(0xFFF0E8D8);
  static const chipBdr = Color(0xFFDDD0B8);
  static const heroDeco1 = Color(0x2EC9943A);
  static const heroDeco2 = Color(0x18C9943A);
  static const quizBtn = Color(0xFF2A1A0E);
  static const planBtn = Color(0xFF2E2840);
  static const audioBtnA = Color(0xFFC9943A);
  static const audioBtnB = Color(0xFFE8B84B);
  static const bubbleUser = Color(0xFF2A1A0E);
  static const bubbleAI = Color(0xFFFEFCF7);
  static const inputBg = Color(0xFFF4EDE0);

  // Formula-specific
  static const formulaCardBg = Color(0xFFFAF6EE);
  static const formulaTagBg = Color(0xFF2A1A0E);
  static const formulaTagText = Color(0xFFE8B84B);
  static const formulaCopyBg = Color(0xFFF0E8D8);
  static const skeletonBg = Color(0xFFEDE0C8);
}

// ─────────────────────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────────────────────
class FormulaItem {
  final String id;
  final String label; // e.g. "Rate Law"
  final String expression; // e.g. "rate = k[A]^m[B]^n"
  final String description; // short explanation
  final String category; // e.g. "Kinetics", "Thermodynamics"
  final List<String> variables; // e.g. ["k = rate constant", "m,n = orders"]

  const FormulaItem({
    required this.id,
    required this.label,
    required this.expression,
    required this.description,
    required this.category,
    required this.variables,
  });

  factory FormulaItem.fromJson(Map<String, dynamic> j) => FormulaItem(
        id: j['id']?.toString() ?? '',
        label: j['label']?.toString() ?? '',
        expression: j['expression']?.toString() ?? '',
        description: j['description']?.toString() ?? '',
        category: j['category']?.toString() ?? 'General',
        variables: (j['variables'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      );

  // Placeholder data — swap out when AI endpoint is ready
  static List<FormulaItem> placeholders() => const [
        FormulaItem(
          id: '1',
          label: 'Rate Law',
          expression: 'rate = k[A]ᵐ[B]ⁿ',
          description: 'Relates reaction rate to reactant concentrations and orders.',
          category: 'Kinetics',
          variables: ['k = rate constant', 'm = order w.r.t. A', 'n = order w.r.t. B'],
        ),
        FormulaItem(
          id: '2',
          label: 'Arrhenius Equation',
          expression: 'k = Ae^(−Ea/RT)',
          description: 'Describes dependence of rate constant on temperature.',
          category: 'Kinetics',
          variables: [
            'A = frequency factor',
            'Eₐ = activation energy',
            'R = 8.314 J/mol·K',
            'T = temperature (K)'
          ],
        ),
        FormulaItem(
          id: '3',
          label: 'Gibbs Free Energy',
          expression: 'ΔG = ΔH − TΔS',
          description: 'Determines spontaneity of a reaction at constant T & P.',
          category: 'Thermodynamics',
          variables: ['ΔH = enthalpy change', 'T = temperature (K)', 'ΔS = entropy change'],
        ),
        FormulaItem(
          id: '4',
          label: 'Henderson–Hasselbalch',
          expression: 'pH = pKₐ + log([A⁻]/[HA])',
          description: 'Calculates pH of a buffer solution.',
          category: 'Acid–Base',
          variables: ['pKₐ = −log(Kₐ)', '[A⁻] = conjugate base', '[HA] = weak acid'],
        ),
        FormulaItem(
          id: '5',
          label: 'Beer–Lambert Law',
          expression: 'A = εlc',
          description: 'Relates absorbance to concentration in spectroscopy.',
          category: 'Spectroscopy',
          variables: [
            'ε = molar absorptivity',
            'l = path length (cm)',
            'c = concentration (mol/L)'
          ],
        ),
      ];
}

// ─────────────────────────────────────────────────────────────
// REPOSITORY
// ─────────────────────────────────────────────────────────────
class _AnalysisRepo {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://midedge.runasp.net',
    headers: {'accept': '*/*'},
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
  ));

  // ── Fetch extracted formulas ──────────────────────────────
  // TODO: uncomment + map response when AI team delivers endpoint
  // Expected response: { "formulas": [ { id, label, expression,
  //   description, category, variables: [...] } ] }
  Future<List<FormulaItem>> fetchFormulas(String fileId) async {
    // final resp = await _dio.post<Map<String, dynamic>>(
    //   '/api/AI/ExtractFormulas',
    //   data: {'fileId': fileId},
    // );
    // final list = resp.data!['formulas'] as List<dynamic>;
    // return list.map((e) => FormulaItem.fromJson(e)).toList();
    await Future.delayed(const Duration(milliseconds: 600));
    return FormulaItem.placeholders();
  }

  // ── Reuse existing endpoints ──────────────────────────────
  Future<List<String>> listFiles() async {
    final resp = await _dio.post<Map<String, dynamic>>('/api/File/ListFiles');
    return (resp.data!['files'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
  }
}

// ─────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────
class AIAnalysisScreen extends StatefulWidget {
  const AIAnalysisScreen({super.key});
  @override
  State<AIAnalysisScreen> createState() => _AIAnalysisScreenState();
}

class _AIAnalysisScreenState extends State<AIAnalysisScreen> {
  int _tab = 0;
  bool _chatOpen = false;
  bool _aiTyping = false;

  final List<_Msg> _msgs = [];
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final _repo = _AnalysisRepo();

  // Formulas state
  List<FormulaItem> _formulas = [];
  bool _formulasLoading = true;
  String? _formulaFilter; // active category filter

  static const _replies = [
    'SN1 proceeds through a carbocation intermediate and follows first-order kinetics — only substrate concentration affects the rate.',
    'Polar protic solvents like water and alcohols stabilise the carbocation, favouring SN1.',
    'Tertiary substrates strongly prefer SN1; primary substrates favour SN2 because backside attack is less hindered.',
    'SN2 is a one-step concerted mechanism — the nucleophile attacks as the leaving group departs, causing Walden inversion.',
    'SN1 typically gives a racemic mixture because attack can occur from either face of the planar carbocation.',
  ];
  int _replyIdx = 0;

  @override
  void initState() {
    super.initState();
    _loadFormulas();
  }

  Future<void> _loadFormulas() async {
    setState(() => _formulasLoading = true);
    try {
      final items = await _repo.fetchFormulas('current');
      if (mounted)
        setState(() {
          _formulas = items;
          _formulasLoading = false;
        });
    } catch (_) {
      if (mounted)
        setState(() {
          _formulas = FormulaItem.placeholders();
          _formulasLoading = false;
        });
    }
  }

  List<FormulaItem> get _filteredFormulas => _formulaFilter == null
      ? _formulas
      : _formulas.where((f) => f.category == _formulaFilter).toList();

  List<String> get _categories => _formulas.map((f) => f.category).toSet().toList();

  // ── Chat ──────────────────────────────────────────────────
  void _send() {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _msgs.add(_Msg(text: t, isUser: true));
      _ctrl.clear();
      _aiTyping = true;
    });
    _scrollDown();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _aiTyping = false;
        _msgs.add(_Msg(text: _replies[_replyIdx % _replies.length], isUser: false));
        _replyIdx++;
      });
      _scrollDown();
    });
  }

  void _scrollDown() => Future.delayed(const Duration(milliseconds: 80), () {
        if (_scroll.hasClients) {
          _scroll.animateTo(_scroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
        }
      });

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 150, 98, 3),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7EDD8), Color(0xFFEDD9B8), Color(0xFFE8D0A8)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            _TopBar(onBack: () {
              if (_chatOpen)
                setState(() => _chatOpen = false);
              else
                Navigator.pop(context);
            }),
            Expanded(child: _chatOpen ? _buildChat() : _buildAnalysis()),
            _buildBottomBar(context),
          ]),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // ANALYSIS VIEW
  // ─────────────────────────────────────────────────────────
  Widget _buildAnalysis() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: _HeroCard(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(children: const [
            _StatTile(value: '12', label: 'Topics'),
            SizedBox(width: 8),
            _StatTile(value: '5', label: 'Concepts'),
            SizedBox(width: 8),
            _StatTile(value: '3', label: 'Formulas'),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: _TabBar(
            active: _tab,
            labels: const ['Summary', 'Formulas', 'Key Terms'],
            onTap: (i) => setState(() => _tab = i),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: _tab == 1 ? _buildFormulaSheet() : _ContentCard(tab: _tab),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: _SectionLabel('Topics Identified'),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              'SN1 Mechanism',
              'SN2 Mechanism',
              'Carbocations',
              'Stereochemistry',
              'Reaction Rates',
              'Solvent Effects'
            ].map((t) => _Chip(label: t)).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: _AskAIStrip(onTap: () {
            setState(() {
              _chatOpen = true;
              if (_msgs.isEmpty) {
                _msgs.add(
                    const _Msg(text: 'مرحباً! اسألني أي سؤال عن محتوى الملف 🧪', isUser: false));
              }
            });
          }),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────
  // FORMULA SHEET
  // ─────────────────────────────────────────────────────────
  Widget _buildFormulaSheet() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Header row
      Row(children: [
        const _SectionLabel('Formula Sheet'),
        const Spacer(),
        // Refresh button
        GestureDetector(
          onTap: _loadFormulas,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _C.chipBg,
              border: Border.all(color: _C.chipBdr),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.refresh_rounded, size: 11, color: _C.textMuted),
              const SizedBox(width: 4),
              const Text('Refresh',
                  style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 10,
                      color: _C.textMuted,
                      fontWeight: FontWeight.w500)),
            ]),
          ),
        ),
      ]),

      const SizedBox(height: 10),

      // Category filter pills
      if (_categories.isNotEmpty && !_formulasLoading) ...[
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _FilterPill(
              label: 'All',
              active: _formulaFilter == null,
              onTap: () => setState(() => _formulaFilter = null),
            ),
            const SizedBox(width: 6),
            ..._categories.map((cat) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _FilterPill(
                    label: cat,
                    active: _formulaFilter == cat,
                    onTap: () =>
                        setState(() => _formulaFilter = _formulaFilter == cat ? null : cat),
                  ),
                )),
          ]),
        ),
        const SizedBox(height: 12),
      ],

      // Loading skeleton
      if (_formulasLoading)
        Column(children: List.generate(3, (_) => const _FormulaSkeleton()))

      // Empty state
      else if (_filteredFormulas.isEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(children: [
            Icon(Icons.functions_rounded, size: 28, color: _C.textMuted.withOpacity(0.5)),
            const SizedBox(height: 10),
            const Text('No formulas found',
                style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    color: _C.textMuted,
                    fontWeight: FontWeight.w400)),
            const SizedBox(height: 4),
            Text('Waiting for AI extraction…',
                style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11,
                    color: _C.textMuted.withOpacity(0.6),
                    fontWeight: FontWeight.w300)),
          ]),
        )

      // Formula cards
      else
        Column(
          children: _filteredFormulas
              .map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _FormulaCard(
                      item: f,
                      onAskAI: () {
                        setState(() {
                          _chatOpen = true;
                          _msgs.add(_Msg(
                              text: 'Explain the formula: ${f.label} — ${f.expression}',
                              isUser: true));
                          _aiTyping = true;
                        });
                        Future.delayed(const Duration(milliseconds: 1200), () {
                          if (!mounted) return;
                          setState(() {
                            _aiTyping = false;
                            _msgs.add(_Msg(
                                text: '${f.label}: ${f.description} — ${f.variables.join(", ")}.',
                                isUser: false));
                          });
                          _scrollDown();
                        });
                      },
                    ),
                  ))
              .toList(),
        ),
    ]);
  }

  // ─────────────────────────────────────────────────────────
  // CHAT VIEW
  // ─────────────────────────────────────────────────────────
  Widget _buildChat() {
    return Column(children: [
      Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          color: _C.cardBg,
          border: Border(bottom: BorderSide(color: _C.border)),
        ),
        child: Row(children: [
          GestureDetector(
            onTap: () => setState(() => _chatOpen = false),
            child: const Row(children: [
              Icon(Icons.arrow_back_ios_new_rounded, size: 13, color: _C.textMuted),
              SizedBox(width: 4),
              Text('Back',
                  style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      color: _C.textMuted,
                      fontWeight: FontWeight.w500)),
            ]),
          ),
          const SizedBox(width: 12),
          const Text('Ask AI',
              style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _C.textDark)),
        ]),
      ),
      Expanded(
        child: ListView.builder(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          itemCount: _msgs.length + (_aiTyping ? 1 : 0),
          itemBuilder: (ctx, i) {
            if (_aiTyping && i == _msgs.length) return const _TypingBubble();
            return _ChatBubble(msg: _msgs[i]);
          },
        ),
      ),
      Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: BoxDecoration(
          color: _C.cardBg,
          border: Border(top: BorderSide(color: _C.border)),
        ),
        child: Row(children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _C.inputBg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: _C.border),
              ),
              child: TextField(
                controller: _ctrl,
                style: const TextStyle(fontFamily: 'DM Sans', fontSize: 13, color: _C.textDark),
                decoration: const InputDecoration.collapsed(
                  hintText: 'Ask about this document...',
                  hintStyle: TextStyle(fontFamily: 'DM Sans', fontSize: 13, color: _C.textHint),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(color: _C.bubbleUser, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, size: 16, color: Colors.white),
            ),
          ),
        ]),
      ),
    ]);
  }

  // ─────────────────────────────────────────────────────────
  // BOTTOM BAR
  // ─────────────────────────────────────────────────────────
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
      decoration: BoxDecoration(
        color: _C.cardBg,
        border: Border(top: BorderSide(color: _C.border)),
        boxShadow: [
          BoxShadow(
              color: _C.textDark.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -3))
        ],
      ),
      child: Row(children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/quiz_screen'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: _C.quizBtn,
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                      color: _C.quizBtn.withOpacity(0.30),
                      blurRadius: 14,
                      offset: const Offset(0, 4))
                ],
              ),
              child: const Column(mainAxisSize: MainAxisSize.min, children: [
                Text('Generate Quiz',
                    style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                Text('✦', style: TextStyle(fontSize: 9, color: Color(0x88FFFFFF))),
              ]),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/study_plan_screen'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: _C.planBtn,
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                      color: _C.planBtn.withOpacity(0.40),
                      blurRadius: 18,
                      offset: const Offset(0, 6))
                ],
              ),
              child: const Column(mainAxisSize: MainAxisSize.min, children: [
                Text('Add to Study Plan',
                    style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                Text('✦', style: TextStyle(fontSize: 9, color: Color(0x88FFFFFF))),
              ]),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/audio_screen'),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [_C.audioBtnA, _C.audioBtnB],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                    color: _C.goldDark.withOpacity(0.40),
                    blurRadius: 14,
                    offset: const Offset(0, 4))
              ],
            ),
            child:
                const Center(child: Icon(Icons.headphones_rounded, size: 20, color: Colors.white)),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// FORMULA CARD
// ─────────────────────────────────────────────────────────────
class _FormulaCard extends StatefulWidget {
  final FormulaItem item;
  final VoidCallback onAskAI;
  const _FormulaCard({required this.item, required this.onAskAI});
  @override
  State<_FormulaCard> createState() => _FormulaCardState();
}

class _FormulaCardState extends State<_FormulaCard> {
  bool _expanded = false;
  bool _copied = false;

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.item.expression));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.item;
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _C.formulaCardBg,
          border: Border.all(color: _C.border, width: 1.2),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: _C.textDark.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Top row ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 0),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Category tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _C.formulaTagBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(f.category,
                    style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: _C.formulaTagText,
                        letterSpacing: 0.4)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(f.label,
                    style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: _C.textDark)),
              ),
              // Expand chevron
              AnimatedRotation(
                duration: const Duration(milliseconds: 200),
                turns: _expanded ? 0.5 : 0,
                child: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: _C.textMuted),
              ),
            ]),
          ),

          // ── Expression box ───────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _C.textDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                Expanded(
                  child: Text(f.expression,
                      style: const TextStyle(
                          fontFamily: 'DM Mono',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: _C.goldLight,
                          letterSpacing: 0.5,
                          height: 1.3)),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _copy,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color:
                          _copied ? _C.goldDark.withOpacity(0.3) : Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                          color: _copied
                              ? _C.goldDark.withOpacity(0.5)
                              : Colors.white.withOpacity(0.12)),
                    ),
                    child: Text(
                      _copied ? 'Copied!' : 'Copy',
                      style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: _copied ? _C.goldLight : Colors.white54),
                    ),
                  ),
                ),
              ]),
            ),
          ),

          // ── Description ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
            child: Text(f.description,
                style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11.5,
                    color: _C.textMuted,
                    fontWeight: FontWeight.w300,
                    height: 1.5)),
          ),

          // ── Expanded: variables + Ask AI ─────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionLabel('Variables'),
                        const SizedBox(height: 6),
                        ...f.variables.map((v) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Container(
                                    margin: const EdgeInsets.only(top: 6),
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(
                                        color: _C.goldDark, shape: BoxShape.circle)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(v,
                                      style: const TextStyle(
                                          fontFamily: 'DM Sans',
                                          fontSize: 11.5,
                                          color: _C.textBody,
                                          fontWeight: FontWeight.w300,
                                          height: 1.5)),
                                ),
                              ]),
                            )),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // ── Bottom actions ────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 13),
            child: Row(children: [
              // Ask AI button
              GestureDetector(
                onTap: widget.onAskAI,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _C.goldDark.withOpacity(0.10),
                    border: Border.all(color: _C.goldDark.withOpacity(0.25)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.auto_awesome_rounded, size: 11, color: _C.goldDark),
                    const SizedBox(width: 5),
                    const Text('Ask AI',
                        style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: _C.goldDark)),
                  ]),
                ),
              ),
              const Spacer(),
              // Expand toggle text
              Text(
                _expanded ? 'Hide details' : 'Show variables',
                style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 10,
                    color: _C.textMuted.withOpacity(0.7),
                    fontWeight: FontWeight.w400),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// FORMULA SKELETON
// ─────────────────────────────────────────────────────────────
class _FormulaSkeleton extends StatefulWidget {
  const _FormulaSkeleton();
  @override
  State<_FormulaSkeleton> createState() => _FormulaSkeletonState();
}

class _FormulaSkeletonState extends State<_FormulaSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _c;
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
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _C.formulaCardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _C.border),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                    width: 60,
                    height: 16,
                    decoration: BoxDecoration(
                        color: _C.skeletonBg, borderRadius: BorderRadius.circular(4))),
                const SizedBox(width: 8),
                Container(
                    width: 100,
                    height: 12,
                    decoration: BoxDecoration(
                        color: _C.skeletonBg, borderRadius: BorderRadius.circular(4))),
              ]),
              const SizedBox(height: 10),
              Container(
                  width: double.infinity,
                  height: 44,
                  decoration:
                      BoxDecoration(color: _C.skeletonBg, borderRadius: BorderRadius.circular(12))),
              const SizedBox(height: 8),
              Container(
                  width: 200,
                  height: 10,
                  decoration: BoxDecoration(
                      color: _C.skeletonBg.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4))),
            ]),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────
// FILTER PILL
// ─────────────────────────────────────────────────────────────
class _FilterPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _FilterPill({required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: active ? _C.textDark : _C.chipBg,
            border: Border.all(color: active ? _C.textDark : _C.chipBdr),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(label,
              style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: active ? Colors.white : _C.textDark)),
        ),
      );
}

// ─────────────────────────────────────────────────────────────
// SHARED WIDGETS (unchanged from original)
// ─────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  const _TopBar({required this.onBack});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(children: [
          _IcoBtn(icon: Icons.arrow_back_ios_new_rounded, onTap: onBack),
          const Expanded(
            child: Center(
              child: Text('AI Analysis',
                  style: TextStyle(
                      fontFamily: 'Syne',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _C.textDark)),
            ),
          ),
          _IcoBtn(icon: Icons.upload_rounded, onTap: () {}),
        ]),
      );
}

class _IcoBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IcoBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _C.cardBg.withOpacity(0.85),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: _C.border),
            boxShadow: [
              BoxShadow(
                  color: _C.textDark.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))
            ],
          ),
          child: Icon(icon, size: 14, color: _C.textDark),
        ),
      );
}

class _HeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: _C.heroCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: _C.heroCard.withOpacity(0.50), blurRadius: 36, offset: const Offset(0, 12))
          ],
        ),
        child: Stack(clipBehavior: Clip.hardEdge, children: [
          Positioned(
              top: -30,
              right: -30,
              child: Container(
                  width: 110,
                  height: 110,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: _C.heroDeco1))),
          Positioned(
              bottom: -20,
              right: 20,
              child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: _C.heroDeco2))),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration:
                      BoxDecoration(color: _C.goldDark, borderRadius: BorderRadius.circular(5)),
                  child: const Icon(Icons.insert_drive_file_rounded, size: 11, color: Colors.white),
                ),
                const SizedBox(width: 7),
                const Text('Organic Chemistry Notes.pdf',
                    style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 9.5,
                        color: _C.textMuted,
                        letterSpacing: 0.4,
                        fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 10),
              const Text('Analysis Complete',
                  style: TextStyle(
                      fontFamily: 'Syne',
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.4,
                      height: 1.2)),
              const SizedBox(height: 12),
              Row(children: const [
                _HeroBadge(label: '✦ 98.4% accuracy', filled: true),
                SizedBox(width: 8),
                _HeroBadge(label: '847 words', filled: false),
              ]),
            ]),
          ),
        ]),
      );
}

class _HeroBadge extends StatelessWidget {
  final String label;
  final bool filled;
  const _HeroBadge({required this.label, required this.filled});
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
                color: filled ? _C.goldLight : Colors.white70)),
      );
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  const _StatTile({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: _C.cardBg,
            border: Border.all(color: _C.border),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: _C.textDark.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))
            ],
          ),
          child: Column(children: [
            Text(value,
                style: const TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: _C.textDark,
                    letterSpacing: -0.5)),
            const SizedBox(height: 2),
            Text(label.toUpperCase(),
                style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 8.5,
                    color: _C.textMuted,
                    letterSpacing: 0.7,
                    fontWeight: FontWeight.w500)),
          ]),
        ),
      );
}

class _TabBar extends StatelessWidget {
  final int active;
  final List<String> labels;
  final void Function(int) onTap;
  const _TabBar({required this.active, required this.labels, required this.onTap});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.55),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _C.border),
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
                          color: active == i ? _C.textDark : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Center(
                          child: Text(labels[i],
                              style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: active == i ? Colors.white : _C.textMuted)),
                        ),
                      ),
                    ),
                  )),
        ),
      );
}

class _ContentCard extends StatelessWidget {
  final int tab;
  const _ContentCard({required this.tab});
  @override
  Widget build(BuildContext context) {
    const labels = ['AI Summary', 'Formulas', 'Key Terms'];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(color: _C.textDark.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _SectionLabel(labels[tab]),
        const SizedBox(height: 10),
        if (tab == 0) _buildSummary(),
        if (tab == 2) _buildTerms(),
      ]),
    );
  }

  Widget _buildSummary() => const Text.rich(TextSpan(
        style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13.5,
            color: _C.textBody,
            height: 1.7,
            fontWeight: FontWeight.w300),
        children: [
          TextSpan(text: 'This document covers '),
          TextSpan(
              text: 'nucleophilic substitution reactions',
              style: TextStyle(fontWeight: FontWeight.w600)),
          TextSpan(
              text:
                  ', including SN1 and SN2 mechanisms. Key topics include carbocation stability, stereochemical outcomes, and the role of solvent polarity in determining the reaction pathway.'),
        ],
      ));

  Widget _buildTerms() {
    const terms = [
      ('Nucleophile', 'Donates an electron pair to form a new bond'),
      ('Carbocation', 'Positive carbon; stabilised by substitution'),
      ('Inversion', 'Backside attack flips the configuration'),
      ('Racemization', 'Equal R and S enantiomers from SN1'),
    ];
    return Column(
      children: terms
          .map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _C.goldDark.withOpacity(0.13),
                      border: Border.all(color: _C.goldDark.withOpacity(0.28)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(e.$1,
                        style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: _C.goldDark)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(e.$2,
                        style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 11.5,
                            color: _C.textMuted,
                            height: 1.5,
                            fontWeight: FontWeight.w300)),
                  ),
                ]),
              ))
          .toList(),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(),
      style: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: _C.textMuted,
          letterSpacing: 1.1));
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: _C.chipBg,
          border: Border.all(color: _C.chipBdr),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11.5,
                color: _C.textDark,
                fontWeight: FontWeight.w400)),
      );
}

class _AskAIStrip extends StatelessWidget {
  final VoidCallback onTap;
  const _AskAIStrip({required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: _C.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _C.borderDash.withOpacity(0.80), width: 1.5),
          ),
          child: Row(children: [
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(color: _C.textDark, shape: BoxShape.circle),
              child: const Center(
                  child: Icon(Icons.auto_awesome_rounded, size: 16, color: _C.goldLight)),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Ask AI about this document',
                    style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _C.textDark)),
                SizedBox(height: 1),
                Text('Tap to start a conversation',
                    style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 10.5,
                        color: _C.textMuted,
                        fontWeight: FontWeight.w300)),
              ]),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: _C.goldDark),
          ]),
        ),
      );
}

class _Msg {
  final String text;
  final bool isUser;
  const _Msg({required this.text, required this.isUser});
}

class _ChatBubble extends StatelessWidget {
  final _Msg msg;
  const _ChatBubble({required this.msg});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!msg.isUser) ...[
              Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(right: 7),
                decoration: const BoxDecoration(color: _C.textDark, shape: BoxShape.circle),
                child: const Center(
                    child: Icon(Icons.auto_awesome_rounded, size: 13, color: _C.goldLight)),
              ),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                decoration: BoxDecoration(
                  color: msg.isUser ? _C.bubbleUser : _C.bubbleAI,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
                    bottomRight: Radius.circular(msg.isUser ? 4 : 16),
                  ),
                  border: msg.isUser ? null : Border.all(color: _C.border),
                  boxShadow: [
                    BoxShadow(
                        color: _C.textDark.withOpacity(0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Text(msg.text,
                    style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        color: msg.isUser ? Colors.white : _C.textDark,
                        height: 1.55,
                        fontWeight: FontWeight.w300)),
              ),
            ),
            if (msg.isUser) const SizedBox(width: 4),
          ],
        ),
      );
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 7),
            decoration: const BoxDecoration(color: _C.textDark, shape: BoxShape.circle),
            child: const Center(
                child: Icon(Icons.auto_awesome_rounded, size: 13, color: _C.goldLight)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              color: _C.bubbleAI,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: _C.border),
            ),
            child: const Text('typing...',
                style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    color: _C.textMuted,
                    fontStyle: FontStyle.italic)),
          ),
        ]),
      );
}
