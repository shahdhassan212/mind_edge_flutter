// screens/verify_email_screen.dart — Email verification after sign-up
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/common_widgets.dart';
import '../theme/design_tokens.dart';
import '../animations/animation_helpers.dart';
import '../features/auth/auth_providers.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String email;
  const VerifyEmailScreen({super.key, required this.email});
  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final List<TextEditingController> _ctrls = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());

  int _seconds = 8 * 60 + 34;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    for (final n in _nodes) {
      n.addListener(() => setState(() {}));
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_seconds > 0)
        setState(() => _seconds--);
      else
        _timer?.cancel();
    });
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  String get _token => _ctrls.map((c) => c.text).join();
  String get _timerLabel {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(verifyEmailProvider, (_, next) {
      if (next is EmailVerified) {
        Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (_) => false);
      } else if (next is OtpResent) {
        _showSnack(next.message, isError: false);
        setState(() => _seconds = 8 * 60 + 34);
        _timer?.cancel();
        _startTimer();
      } else if (next is AuthError) {
        _showSnack(next.message, isError: true);
      }
    });

    final isLoading = ref.watch(verifyEmailProvider) is AuthLoading;
    final filled = _ctrls.where((c) => c.text.isNotEmpty).length;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF4E8),
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.signIn),
        child: Stack(children: [
          Positioned(
              top: -70,
              right: -70,
              child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                          colors: [AppColors.gold.withOpacity(0.12), Colors.transparent],
                          radius: 0.68)))),
          Positioned(
              bottom: -80,
              left: -80,
              child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                          colors: [AppColors.cocoa.withOpacity(0.08), Colors.transparent],
                          radius: 0.68)))),
          SafeArea(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(26, 10, 26, 0),
                child: Row(children: [
                  AppBackButton(),
                  Spacer(),
                  Text('Verify Email',
                      style: TextStyle(
                          fontFamily: 'Syne',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.cocoaDeep)),
                  Spacer(),
                  SizedBox(width: 36),
                ]),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 24),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    FadeUpEntrance(
                      delay: const Duration(milliseconds: 150),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(30, 32, 30, 0),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          // Icon
                          Stack(alignment: Alignment.center, children: [
                            Container(
                                width: 66,
                                height: 66,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.65),
                                    border: Border.all(
                                        color: const Color(0xFFB48C50).withOpacity(0.2),
                                        width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                          color: const Color(0xFF643C14).withOpacity(0.1),
                                          blurRadius: 28,
                                          offset: const Offset(0, 8))
                                    ]),
                                child: const Center(
                                    child: Text('✉', style: TextStyle(fontSize: 26)))),
                            Container(
                                width: 82,
                                height: 82,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: AppColors.gold.withOpacity(0.16)))),
                          ]),
                          const SizedBox(height: 20),
                          const Text('Check your\nemail',
                              style: TextStyle(
                                  fontFamily: 'Syne',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.cocoaDeep,
                                  letterSpacing: -0.025 * 22,
                                  height: 1.2)),
                          const SizedBox(height: 8),
                          Text.rich(TextSpan(
                              text: 'We sent a 6-digit verification code to ',
                              style: const TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 13,
                                  color: AppColors.muted,
                                  fontWeight: FontWeight.w300,
                                  height: 1.6),
                              children: [
                                TextSpan(
                                    text: widget.email,
                                    style: const TextStyle(
                                        color: AppColors.cocoa,
                                        fontWeight: FontWeight.w600))
                              ])),
                        ]),
                      ),
                    ),

                    // OTP boxes
                    Padding(
                      padding: const EdgeInsets.fromLTRB(26, 28, 26, 0),
                      child: Row(
                        children: List.generate(6, (i) {
                          final isFilled = _ctrls[i].text.isNotEmpty;
                          final isActive = _nodes[i].hasFocus;
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
                                      width: 1.5),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: isFilled || isActive
                                      ? [
                                          BoxShadow(
                                              color: AppColors.cocoa.withOpacity(0.09),
                                              blurRadius: 0,
                                              spreadRadius: 3),
                                          ...AppShadows.sm
                                        ]
                                      : AppShadows.sm),
                              child: Stack(alignment: Alignment.center, children: [
                                TextField(
                                  controller: _ctrls[i],
                                  focusNode: _nodes[i],
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
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero),
                                  onChanged: (v) {
                                    setState(() {});
                                    if (v.length == 1 && i < 5) {
                                      _nodes[i + 1].requestFocus();
                                    } else if (v.isEmpty && i > 0) {
                                      _nodes[i - 1].requestFocus();
                                    }
                                  },
                                ),
                                if (isActive && _ctrls[i].text.isEmpty) _BlinkCursor(),
                              ]),
                            ),
                          ));
                        }),
                      ),
                    ),

                    // Timer + resend
                    Padding(
                      padding: const EdgeInsets.fromLTRB(30, 16, 30, 0),
                      child: Column(children: [
                        Text.rich(TextSpan(
                            text: 'Code expires in ',
                            style: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 12,
                                color: AppColors.muted,
                                fontWeight: FontWeight.w300),
                            children: [
                              TextSpan(
                                  text: _timerLabel,
                                  style: const TextStyle(
                                      color: AppColors.cocoa, fontWeight: FontWeight.w600))
                            ])),
                        const SizedBox(height: 8),
                        Text.rich(TextSpan(
                            text: "Didn't receive it? ",
                            style: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 13,
                                color: AppColors.muted,
                                fontWeight: FontWeight.w300),
                            children: [
                              WidgetSpan(
                                  child: GestureDetector(
                                      onTap: isLoading
                                          ? null
                                          : () => ref
                                              .read(verifyEmailProvider.notifier)
                                              .resend(email: widget.email),
                                      child: const Text('Resend code',
                                          style: TextStyle(
                                              fontFamily: 'DM Sans',
                                              fontSize: 13,
                                              color: AppColors.cocoa,
                                              fontWeight: FontWeight.w600))))
                            ])),
                      ]),
                    ),

                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: isLoading
                          ? _LoadingBtn()
                          : PrimaryButton(
                              label: 'Verify Email',
                              onTap: filled == 6 ? _verify : null,
                              gradient: filled == 6
                                  ? AppGradients.ctaButton
                                  : LinearGradient(colors: [
                                      AppColors.cocoa.withOpacity(0.35),
                                      AppColors.muted.withOpacity(0.35),
                                    ]),
                            ),
                    ),
                  ]),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Future<void> _verify() async {
    FocusScope.of(context).unfocus();
    await ref.read(verifyEmailProvider.notifier).verify(
          email: widget.email,
          otp: _token,
        );
  }

  void _showSnack(String msg, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg,
            style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white)),
        backgroundColor: isError ? AppColors.cocoaDeep : const Color(0xFF3D5226),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ));
  }
}

class _LoadingBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
          gradient: AppGradients.ctaButton,
          borderRadius: BorderRadius.circular(AppRadius.button),
          boxShadow: AppShadows.btn),
      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
        SizedBox(width: 10),
        Text('Verifying…',
            style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.white)),
      ]));
}

class _BlinkCursor extends StatefulWidget {
  @override
  State<_BlinkCursor> createState() => _BlinkCursorState();
}

class _BlinkCursorState extends State<_BlinkCursor> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
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
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
          opacity: _ctrl.value > 0.5 ? 1 : 0,
          child: Container(
              width: 2,
              height: 26,
              decoration: BoxDecoration(
                  color: AppColors.cocoa, borderRadius: BorderRadius.circular(1)))));
}
