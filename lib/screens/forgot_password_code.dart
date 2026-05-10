// screens/forgot_password_code.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/common_widgets.dart';
import '../theme/design_tokens.dart';
import '../widgets/animation_helpers.dart';
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
        AppSnackBar.show(context, msg, isError: false);
      } else if (next.status == ForgotCodeStatus.error && next.errorMessage != null) {
        final msg = next.errorMessage!;
        next.resetStatus();
        AppSnackBar.show(context, msg);
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.signIn),
        child: Stack(children: [
          AppDecorOrb(top: -70, right: -70, size: 260, color: AppColors.gold.withOpacity(0.12)),
          SafeArea(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const AppScreenTopBar(title: 'Reset Password'),
              const AuthStepBar(steps: 3, filled: 2),
              StepLabel('Step 2 of 3 — Enter Code'),
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
                                  letterSpacing: -0.55,
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
                    OtpRow(
                      controllers: vm.otpCtrls,
                      focusNodes: vm.focusNodes,
                      onChanged: (i) => vm.onOtpChanged(i, vm.otpCtrls[i].text),
                    ),
                    _TimerResend(
                      timerLabel: vm.timerLabel,
                      onResend: vm.isLoading ? null : vm.resend,
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: AppButton(
                        label: 'Verify Code',
                        isLoading: vm.isLoading,
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
                  style: const TextStyle(color: AppColors.cocoa, fontWeight: FontWeight.w600))
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
