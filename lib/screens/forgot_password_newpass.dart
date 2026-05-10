// screens/forgot_password_newpass.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/common_widgets.dart';
import '../theme/design_tokens.dart';
import '../features/auth/auth_providers.dart';

class ForgotPasswordNewPassScreen extends ConsumerWidget {
  final String email;
  final String code;
  const ForgotPasswordNewPassScreen({super.key, required this.email, required this.code});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(forgotNewPassVMProvider);

    ref.listen<ForgotPasswordNewPassViewModel>(forgotNewPassVMProvider, (_, next) {
      if (next.status == ResetPassStatus.success) {
        next.resetStatus();
        Navigator.pushNamedAndRemoveUntil(context, '/forgot-success', (_) => false);
      } else if (next.status == ResetPassStatus.error && next.errorMessage != null) {
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
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.55, 1.0],
                colors: [Color(0xFFFDFAF4), Color(0xFFF5EBD6), Color(0xFFECDCBF)])),
        child: Stack(children: [
          AppDecorOrb(top: -70, right: -70, size: 260, color: AppColors.gold.withOpacity(0.12)),
          SafeArea(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const AppScreenTopBar(title: 'Reset Password'),
              const AuthStepBar(steps: 3, filled: 3),
              StepLabel('Step 3 of 3 — Create Password'),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(30, 26, 30, 0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      const Text('Create a new\npassword',
                          style: TextStyle(
                              fontFamily: 'Syne',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cocoaDeep,
                              letterSpacing: -0.55,
                              height: 1.2)),
                      const SizedBox(height: 6),
                      const Text("Choose a strong password you haven't used before.",
                          style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 13,
                              color: AppColors.muted,
                              fontWeight: FontWeight.w300,
                              height: 1.6)),
                      const SizedBox(height: 20),
                      AppInputField(
                        label: 'New Password',
                        hint: '••••••••••••',
                        controller: vm.newPassCtrl,
                        obscureText: vm.obscureNew,
                        onToggleObscure: vm.toggleObscureNew,
                        onChanged: (_) {},
                      ),
                      const SizedBox(height: 6),
                      _StrengthBars(strength: vm.strength),
                      const SizedBox(height: 10),
                      _Req('At least 8 characters', vm.newPassCtrl.text.length >= 8),
                      const SizedBox(height: 5),
                      _Req('One uppercase letter', vm.newPassCtrl.text.contains(RegExp(r'[A-Z]'))),
                      const SizedBox(height: 5),
                      _Req('One number', vm.newPassCtrl.text.contains(RegExp(r'[0-9]'))),
                      const SizedBox(height: 5),
                      _Req('One special character',
                          vm.newPassCtrl.text.contains(RegExp(r'[!@#\$%^&*]'))),
                      const SizedBox(height: 12),
                      AppInputField(
                        label: 'Confirm Password',
                        hint: '••••••••••••',
                        controller: vm.confPassCtrl,
                        obscureText: vm.obscureConf,
                        onToggleObscure: vm.toggleObscureConf,
                      ),
                      const SizedBox(height: 14),
                      AppButton(
                        label: 'Set New Password ✦',
                        isLoading: vm.isLoading,
                        gradient: AppGradients.ctaButtonFinal,
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          vm.submit(email: email, code: code);
                        },
                      ),
                    ]),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _StrengthBars extends StatelessWidget {
  final int strength;
  const _StrengthBars({required this.strength});

  Color _c(int i) {
    if (i >= strength) return AppColors.cocoa.withOpacity(0.13);
    if (strength == 1) return const Color(0xFFE05252);
    if (strength <= 3) return AppColors.gold;
    return AppColors.cocoa;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
          4,
          (i) => [
                Expanded(
                  child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 3,
                      decoration:
                          BoxDecoration(color: _c(i), borderRadius: BorderRadius.circular(2))),
                ),
                if (i < 3) const SizedBox(width: 4),
              ]).expand((e) => e).toList(),
    );
  }
}

class _Req extends StatelessWidget {
  final String label;
  final bool met;
  const _Req(this.label, this.met);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: met ? const Color(0xFF5C7A3A) : AppColors.cocoa.withOpacity(0.2))),
      const SizedBox(width: 7),
      Text(label,
          style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 11.5,
              fontWeight: FontWeight.w300,
              color: met ? const Color(0xFF5C7A3A) : AppColors.muted)),
    ]);
  }
}
