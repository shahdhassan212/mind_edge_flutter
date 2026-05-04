import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/common_widgets.dart';
import '../theme/design_tokens.dart';
import '../animations/animation_helpers.dart';
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
              top: -80,
              right: -80,
              child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                          colors: [AppColors.gold.withOpacity(0.12), Colors.transparent],
                          radius: 0.68)))),
          Positioned(
              bottom: -60,
              left: -60,
              child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                          colors: [AppColors.cocoa.withOpacity(0.08), Colors.transparent],
                          radius: 0.68)))),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24),
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
                const AuthStepBar(steps: 3, filled: 1),
                const Padding(
                    padding: EdgeInsets.fromLTRB(26, 5, 26, 0),
                    child: Text('Step 1 of 3 — Verify Email',
                        style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 10,
                            color: AppColors.muted,
                            letterSpacing: 0.08 * 10))),
                FadeUpEntrance(
                  delay: const Duration(milliseconds: 200),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(30, 28, 30, 0),
                    child: Column(children: [
                      Stack(alignment: Alignment.center, children: [
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
                                ]),
                            child: const Center(child: Text('✉', style: TextStyle(fontSize: 26)))),
                        Container(
                            width: 82,
                            height: 82,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.gold.withOpacity(0.16)))),
                      ]),
                      const SizedBox(height: 16),
                      const Text('Forgot your\npassword?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'Syne',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cocoaDeep,
                              letterSpacing: -0.025 * 22,
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
                      const Text('EMAIL ADDRESS',
                          style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B4C3B),
                              letterSpacing: 1.0)),
                      const SizedBox(height: 5),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(vm.emailFocused ? 0.9 : 0.72),
                            border: Border.all(
                                color: vm.emailFocused
                                    ? AppColors.cocoa
                                    : const Color(0xFFB48C50).withOpacity(0.2),
                                width: 1.5),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: vm.emailFocused ? AppShadows.inputFocus : AppShadows.sm),
                        child: TextField(
                          focusNode: vm.emailFocus,
                          controller: vm.emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 14,
                              color: AppColors.cocoaDeep,
                              fontWeight: FontWeight.w400),
                          decoration: InputDecoration(
                              hintText: 'you@example.com',
                              hintStyle: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 14,
                                  color: AppColors.muted.withOpacity(0.45),
                                  fontWeight: FontWeight.w300),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              border: InputBorder.none,
                              suffixIcon: const Padding(
                                  padding: EdgeInsets.only(right: 12),
                                  child: Align(
                                      widthFactor: 1,
                                      heightFactor: 1,
                                      child: Text('✉', style: TextStyle(fontSize: 14))))),
                        ),
                      ),
                      const SizedBox(height: 13),
                      vm.isLoading
                          ? const AuthLoadingBtn(label: 'Sending code…')
                          : GestureDetector(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                vm.send();
                              },
                              child: Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFC9A96E), Color(0xFF7C5642)],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF000000).withOpacity(0.32),
                                      blurRadius: 28,
                                      offset: const Offset(0, 8),
                                    )
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    'Send Verification Code',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'DM Sans',
                                    ),
                                  ),
                                ),
                              ),
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

  void _showSnack(BuildContext context, String msg, {bool isError = false}) {
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
