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
        _showSnack(context, msg);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFAF4E8),
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
            const AuthStepBar(steps: 3, filled: 3),
            const Padding(
                padding: EdgeInsets.fromLTRB(26, 5, 26, 0),
                child: Text('Step 3 of 3 — Create Password',
                    style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 10,
                        color: AppColors.muted,
                        letterSpacing: 0.08 * 10))),
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
                          letterSpacing: -0.025 * 22,
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

                  _PassField(
                      label: 'NEW PASSWORD',
                      placeholder: '••••••••••••',
                      controller: vm.newPassCtrl,
                      obscure: vm.obscureNew,
                      onToggle: vm.toggleObscureNew),
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

                  _PassField(
                      label: 'CONFIRM PASSWORD',
                      placeholder: '••••••••••••',
                      controller: vm.confPassCtrl,
                      obscure: vm.obscureConf,
                      onToggle: vm.toggleObscureConf),
                  const SizedBox(height: 14),

                  vm.isLoading
                      ? const AuthLoadingBtn(label: 'Saving password…')
                      : PrimaryButton(
                          label: 'Set New Password ✦',
                          gradient: AppGradients.ctaButtonFinal,
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            vm.submit(email: email, code: code);
                          }),
                ]),
              ),
            )),
          ])),
        ]),
      ),
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg,
            style: const TextStyle(fontFamily: 'DM Sans', fontSize: 13, color: Colors.white)),
        backgroundColor: AppColors.cocoaDeep,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
  }
}

class _PassField extends StatelessWidget {
  final String label, placeholder;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  const _PassField(
      {required this.label,
      required this.placeholder,
      required this.controller,
      required this.obscure,
      required this.onToggle});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B4C3B),
                letterSpacing: 1.0)),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.72),
              border: Border.all(color: const Color(0xFFB48C50).withOpacity(0.2), width: 1.5),
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppShadows.sm),
          child: TextField(
              controller: controller,
              obscureText: obscure,
              style:
                  const TextStyle(fontFamily: 'DM Sans', fontSize: 14, color: AppColors.cocoaDeep),
              decoration: InputDecoration(
                  hintText: placeholder,
                  hintStyle: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      color: AppColors.muted.withOpacity(0.45),
                      fontWeight: FontWeight.w300),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: InputBorder.none,
                  suffixIcon: GestureDetector(
                      onTap: onToggle,
                      child: Icon(
                          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 18,
                          color: AppColors.muted.withOpacity(0.55))))),
        )
      ]);
}

class _StrengthBars extends StatelessWidget {
  final int strength;
  const _StrengthBars({required this.strength});
  Color _c(int i) {
    if (i >= strength) return AppColors.cocoa.withOpacity(0.13);
    if (strength == 1) return const Color(0xFFE05252);
    if (strength == 2) return AppColors.gold;
    if (strength == 3) return AppColors.gold;
    return AppColors.cocoa;
  }

  @override
  Widget build(BuildContext context) => Row(
      children: List.generate(
          4,
          (i) => [
                Expanded(
                    child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 3,
                        decoration:
                            BoxDecoration(color: _c(i), borderRadius: BorderRadius.circular(2)))),
                if (i < 3) const SizedBox(width: 4),
              ]).expand((e) => e).toList());
}

class _Req extends StatelessWidget {
  final String label;
  final bool met;
  const _Req(this.label, this.met);
  @override
  Widget build(BuildContext context) => Row(children: [
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
