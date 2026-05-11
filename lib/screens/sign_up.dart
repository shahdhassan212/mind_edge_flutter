import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/design_tokens.dart';
import '../widgets/common_widgets.dart';
import '../features/auth/auth_providers.dart';

class SignUpScreen extends ConsumerWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<SignUpViewModel>(signUpVMProvider, (_, vm) {
      if (vm.status == SignUpStatus.success) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/verify-email',
          (_) => false,
          arguments: vm.successEmail,
        );
      } else if (vm.status == SignUpStatus.error && vm.errorMessage != null) {
        AppErrorSnackBar.show(context, vm.errorMessage!, icon: Icons.error_outline_rounded);
        vm.resetError();
      }
    });
    final vm = ref.watch(signUpVMProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(decoration: const BoxDecoration(gradient: AppGradients.signUp)),
          ),
          _DecorOrb(top: -80, right: -80, size: 280, color: AppColors.gold.withOpacity(0.11)),
          _DecorOrb(bottom: -60, left: -60, size: 220, color: AppColors.cocoa.withOpacity(0.07)),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 3,
                  child: Row(children: [
                    Expanded(
                      child: Container(
                          decoration: const BoxDecoration(gradient: AppGradients.progress)),
                    ),
                    Expanded(
                      child: Container(color: AppColors.cocoa.withOpacity(0.10)),
                    ),
                  ]),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 18),
                          const AppBackButton(),
                          const SizedBox(height: 18),
                          const Text(
                            'STEP 1 OF 2 — ACCOUNT DETAILS',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 11,
                              color: AppColors.muted,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.99,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Create your\naccount',
                            style: TextStyle(
                              fontFamily: 'Syne',
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cocoaDeep,
                              letterSpacing: -0.65,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Row(children: [
                            Expanded(
                              child: AppInputField(
                                label: 'First Name',
                                hint: 'Alex',
                                controller: vm.firstNameCtrl,
                                textCapitalization: TextCapitalization.words,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AppInputField(
                                label: 'Last Name',
                                hint: 'Jordan',
                                controller: vm.lastNameCtrl,
                                textCapitalization: TextCapitalization.words,
                              ),
                            ),
                          ]),
                          const SizedBox(height: 12),
                          AppInputField(
                            label: 'Email Address',
                            hint: 'you@university.edu',
                            controller: vm.emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 12),
                          AppInputField(
                            label: 'Password',
                            hint: '••••••••',
                            controller: vm.passwordCtrl,
                            obscureText: vm.obscurePassword,
                            onToggleObscure: vm.toggleObscure,
                            onChanged: vm.updatePasswordStrength,
                          ),
                          const SizedBox(height: 6),
                          PasswordStrengthBars(strength: vm.passwordStrength),
                          const SizedBox(height: 14),
                          TermsRow(checked: vm.termsAccepted, onTap: vm.toggleTerms),
                          const SizedBox(height: 20),
                          AppButton(
                            label: 'Create Account →',
                            isLoading: vm.isLoading,
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              vm.signUp();
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 8, 30, 24),
                  child: Center(
                    child: Text.rich(TextSpan(
                      text: 'Already have an account? ',
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w300,
                      ),
                      children: [
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/signin'),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 12,
                                color: AppColors.cocoa,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorOrb extends StatelessWidget {
  final double? top, bottom, left, right, size;
  final Color color;
  const _DecorOrb(
      {this.top, this.bottom, this.left, this.right, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, Colors.transparent], radius: 0.68),
        ),
      ),
    );
  }
}
