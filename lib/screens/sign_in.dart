import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/design_tokens.dart';
import '../widgets/animation_helpers.dart';
import '../widgets/common_widgets.dart';
import '../widgets/kochalo_animation_widget.dart';
import '../features/auth/auth_providers.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<SignInViewModel>(signInVMProvider, (_, vm) {
      if (vm.status == SignInStatus.success) {
        Future.delayed(const Duration(milliseconds: 700), () {
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (_) => false);
          }
        });
      } else if (vm.status == SignInStatus.error && vm.errorMessage != null) {
        AppErrorSnackBar.show(context, vm.errorMessage!);
        vm.resetError();
      }
    });
    final vm = ref.watch(signInVMProvider);
    final screenH = MediaQuery.of(context).size.height;
    final animH = screenH < 650
        ? 130.0
        : screenH < 750
            ? 160.0
            : 200.0;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.signIn),
        child: Stack(
          children: [
            _DecorOrb(top: -100, right: -100, size: 300, color: AppColors.gold.withOpacity(0.10)),
            _DecorOrb(bottom: -80, left: -80, size: 260, color: AppColors.cocoa.withOpacity(0.06)),
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      const AppBackButton(),
                      const SizedBox(height: 4),
                      KochaloLoginAnimationWidget(key: vm.animKey, height: animH),
                      FadeUpEntrance(
                        delay: const Duration(milliseconds: 150),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome\nback.',
                              style: TextStyle(
                                fontFamily: 'Syne',
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: AppColors.cocoaDeep,
                                letterSpacing: -0.7,
                                height: 1.15,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Sign in to continue learning.',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 13,
                                color: AppColors.muted,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      FadeUpEntrance(
                        delay: const Duration(milliseconds: 300),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppInputField(
                              label: 'Email Address',
                              hint: 'you@example.com',
                              controller: vm.emailCtrl,
                              focusNode: vm.emailFocus,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 13),
                            AppInputField(
                              label: 'Password',
                              hint: '••••••••',
                              controller: vm.passwordCtrl,
                              focusNode: vm.passwordFocus,
                              obscureText: vm.obscurePassword,
                              onToggleObscure: vm.toggleObscure,
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () => Navigator.pushNamed(context, '/forgot-email'),
                                child: const Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: 11.5,
                                    color: AppColors.cocoa,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            AppButton(
                              label: 'Sign In →',
                              isLoading: vm.isLoading,
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                vm.animKey.currentState?.onIdle();
                                vm.signIn();
                              },
                            ),
                            const SizedBox(height: 28),
                          ],
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text.rich(TextSpan(
                            text: "Don't have an account? ",
                            style: const TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 13,
                              color: AppColors.muted,
                              fontWeight: FontWeight.w300,
                            ),
                            children: [
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () => Navigator.pushNamed(context, '/signup'),
                                  child: const Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 13,
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
              ),
            ),
          ],
        ),
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
