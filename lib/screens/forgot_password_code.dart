import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/common_widgets.dart';
import '../theme/design_tokens.dart';
import '../animations/animation_helpers.dart';
import '../features/auth/auth_providers.dart';

class ForgotPasswordCodeScreen extends ConsumerWidget {
  final String email;
  const ForgotPasswordCodeScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(forgotCodeVMProvider(email));
    final filled = vm.otpCtrls.where((c) => c.text.isNotEmpty).length;

    ref.listen<ForgotPasswordCodeViewModel>(forgotCodeVMProvider(email), (_, next) {
      if (next.status == ForgotCodeStatus.otpResent && next.successMessage != null) {
        final msg = next.successMessage!;
        next.resetStatus();
        _showSnack(context, msg, isError: false);
      } else if (next.status == ForgotCodeStatus.error && next.errorMessage != null) {
        final msg = next.errorMessage!;
        next.resetStatus();
        _showSnack(context, msg, isError: true);
      }
    });

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
          SafeArea(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(26, 10, 26, 0),
                child: Row(children: [
                  const AppBackButton(),
                  const Spacer(),
                  const Text('Reset Password',
                      style: TextStyle(
                          fontFamily: 'Syne',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.cocoaDeep)),
                  const Spacer(),
                  const SizedBox(width: 36),
                ]),
              ),
              const AuthStepBar(steps: 3, filled: 2),
              const Padding(
                  padding: EdgeInsets.fromLTRB(26, 5, 26, 0),
                  child: Text('Step 2 of 3 — Enter Code',
                      style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 10,
                          color: AppColors.muted,
                          letterSpacing: 0.08 * 10))),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    FadeUpEntrance(
                      delay: const Duration(milliseconds: 150),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(30, 28, 30, 0),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                              text: 'We sent a 6-digit code to ',
                              style: const TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 13,
                                  color: AppColors.muted,
                                  fontWeight: FontWeight.w300,
                                  height: 1.6),
                              children: [
                                TextSpan(
                                    text: email,
                                    style: const TextStyle(
                                        color: AppColors.cocoa, fontWeight: FontWeight.w600))
                              ])),
                        ]),
                      ),
                    ),

                    // OTP boxes
                    Padding(
                      padding: const EdgeInsets.fromLTRB(26, 28, 26, 0),
                      child: Row(
                        children: List.generate(6, (i) {
                          final isFilled = vm.otpCtrls[i].text.isNotEmpty;
                          final isActive = vm.focusNodes[i].hasFocus;
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
                                  controller: vm.otpCtrls[i],
                                  focusNode: vm.focusNodes[i],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(1),
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  style: const TextStyle(
                                      fontFamily: 'Syne',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.cocoaDeep),
                                  decoration: const InputDecoration(
                                      border: InputBorder.none, contentPadding: EdgeInsets.zero),
                                  onChanged: (v) => vm.onOtpChanged(i, v),
                                ),
                                if (isActive && vm.otpCtrls[i].text.isEmpty) _BlinkCursor(),
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
                                  text: vm.timerLabel,
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
                                      onTap: vm.isLoading ? null : vm.resend,
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
                      child: vm.isLoading
                          ? const AuthLoadingBtn(label: 'Verifying…')
                          : PrimaryButton(
                              label: 'Verify Code',
                              onTap: filled == 6
                                  ? () {
                                      FocusScope.of(context).unfocus();
                                      Navigator.pushNamed(
                                        context,
                                        '/forgot-newpass',
                                        arguments: {'email': email, 'code': vm.otp},
                                      );
                                    }
                                  : null,
                              gradient: filled == 6
                                  ? AppGradients.ctaButton
                                  : LinearGradient(colors: [
                                      AppColors.cocoa.withOpacity(0.35),
                                      AppColors.muted.withOpacity(0.35)
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

  void _showSnack(BuildContext context, String msg, {bool isError = true}) {
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
              decoration:
                  BoxDecoration(color: AppColors.cocoa, borderRadius: BorderRadius.circular(1)))));
}
