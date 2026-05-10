// screens/forgot_password_email.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/common_widgets.dart';
import '../theme/design_tokens.dart';
import '../widgets/animation_helpers.dart';
import '../features/auth/auth_providers.dart';

class ForgotPasswordEmailScreen extends ConsumerWidget {
  const ForgotPasswordEmailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(forgotEmailVMProvider);

    ref.listen<ForgotPasswordEmailViewModel>(forgotEmailVMProvider, (_, next) {
      if (next.status == ForgotEmailStatus.success && next.sentEmail != null) {
        final email = next.sentEmail!;
        next.resetStatus();
        Navigator.pushNamed(context, '/forgot-code', arguments: email);
      } else if (next.status == ForgotEmailStatus.error && next.errorMessage != null) {
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
          AppDecorOrb(top: -80, right: -80, size: 280, color: AppColors.gold.withOpacity(0.12)),
          AppDecorOrb(bottom: -60, left: -60, size: 220, color: AppColors.cocoa.withOpacity(0.08)),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const AppScreenTopBar(title: 'Reset Password'),
                const AuthStepBar(steps: 3, filled: 1),
                StepLabel('Step 1 of 3 — Verify Email'),
                FadeUpEntrance(
                  delay: const Duration(milliseconds: 200),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(30, 28, 30, 0),
                    child: Column(children: [
                      const _EmailIcon(),
                      const SizedBox(height: 16),
                      const Text('Forgot your\npassword?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'Syne',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cocoaDeep,
                              letterSpacing: -0.55,
                              height: 1.2)),
                      const SizedBox(height: 8),
                      const Text(
                          "Enter your email and we'll send a verification code to confirm it's you.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 13,
                              color: AppColors.muted,
                              fontWeight: FontWeight.w300,
                              height: 1.6)),
                    ]),
                  ),
                ),
                FadeUpEntrance(
                  delay: const Duration(milliseconds: 350),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(30, 24, 30, 0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      AppInputField(
                        label: 'Email Address',
                        hint: 'you@example.com',
                        controller: vm.emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 13),
                      AppButton(
                        label: 'Send Verification Code',
                        isLoading: vm.isLoading,
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          vm.send();
                        },
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text.rich(TextSpan(
                            text: 'Remember it? ',
                            style: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 13,
                                color: AppColors.muted,
                                fontWeight: FontWeight.w300),
                            children: [
                              WidgetSpan(
                                  child: GestureDetector(
                                      onTap: () => Navigator.pushNamed(context, '/signin'),
                                      child: const Text('Sign In',
                                          style: TextStyle(
                                              fontFamily: 'DM Sans',
                                              fontSize: 13,
                                              color: AppColors.cocoa,
                                              fontWeight: FontWeight.w600))))
                            ])),
                      ),
                    ]),
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────

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
          border: Border.all(color: const Color(0xFFB48C50).withOpacity(0.2), width: 1.5),
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
