// screens/verify_email_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/common_widgets.dart';
import '../theme/design_tokens.dart';
import '../features/auth/auth_providers.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String email;
  const VerifyEmailScreen({super.key, required this.email});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final List<TextEditingController> _ctrls =
      List.generate(6, (_) => TextEditingController());
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
    for (final c in _ctrls) c.dispose();
    for (final n in _nodes) n.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String get _token => _ctrls.map((c) => c.text).join();
  String get _timerLabel {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _verify() async {
    FocusScope.of(context).unfocus();
    await ref.read(verifyEmailProvider.notifier).verify(
          email: widget.email,
          otp: _token,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(verifyEmailProvider, (_, next) {
      if (next is EmailVerified) {
        Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (_) => false);
      } else if (next is OtpResent) {
        AppSnackBar.show(context, next.message, isError: false);
        setState(() => _seconds = 8 * 60 + 34);
        _timer?.cancel();
        _startTimer();
      } else if (next is AuthError) {
        AppSnackBar.show(context, next.message);
      }
    });

    final isLoading = ref.watch(verifyEmailProvider) is AuthLoading;
    final filled = _ctrls.where((c) => c.text.isNotEmpty).length;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.signIn),
        child: Stack(children: [
          AppDecorOrb(top: -70, right: -70, size: 260,
              color: AppColors.gold.withOpacity(0.12)),
          AppDecorOrb(bottom: -80, left: -80, size: 260,
              color: AppColors.cocoa.withOpacity(0.08)),
          SafeArea(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const AppScreenTopBar(title: 'Verify Email'),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 24),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    // ── Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(30, 32, 30, 0),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const _EmailIcon(),
                        const SizedBox(height: 20),
                        const Text('Check your\nemail',
                            style: TextStyle(
                                fontFamily: 'Syne',
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.cocoaDeep,
                                letterSpacing: -0.55,
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

                    // ── OTP boxes
                    OtpRow(
                      controllers: _ctrls,
                      focusNodes: _nodes,
                      onChanged: (i) {
                        setState(() {});
                        if (_ctrls[i].text.length == 1 && i < 5)
                          _nodes[i + 1].requestFocus();
                        else if (_ctrls[i].text.isEmpty && i > 0)
                          _nodes[i - 1].requestFocus();
                      },
                    ),

                    // ── Timer + resend
                    _TimerResend(
                      timerLabel: _timerLabel,
                      onResend: isLoading
                          ? null
                          : () => ref
                              .read(verifyEmailProvider.notifier)
                              .resend(email: widget.email),
                    ),

                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: AppButton(
                        label: 'Verify Email',
                        isLoading: isLoading,
                        onTap: filled == 6 ? _verify : null,
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
}

// ── Shared across verify + forgot_code ────────────────────────
class _EmailIcon extends StatelessWidget {
  const _EmailIcon();

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Container(
        width: 66,
        height: 66,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.65),
          border: Border.all(
              color: const Color(0xFFB48C50).withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF643C14).withOpacity(0.1),
                blurRadius: 28,
                offset: const Offset(0, 8))
          ],
        ),
        child: const Center(child: Text('✉', style: TextStyle(fontSize: 26))),
      ),
      Container(
        width: 82,
        height: 82,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.gold.withOpacity(0.16)),
        ),
      ),
    ]);
  }
}

class _TimerResend extends StatelessWidget {
  final String timerLabel;
  final VoidCallback? onResend;
  const _TimerResend({required this.timerLabel, this.onResend});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                  text: timerLabel,
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
                      onTap: onResend,
                      child: const Text('Resend code',
                          style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 13,
                              color: AppColors.cocoa,
                              fontWeight: FontWeight.w600))))
            ])),
      ]),
    );
  }
}