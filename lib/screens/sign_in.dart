// screens/sign_in.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/design_tokens.dart';
import '../animations/animation_helpers.dart';
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
        _showError(context, vm.errorMessage!);
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
      backgroundColor: const Color(0xFFFAF4E8),
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.signIn),
        child: Stack(
          children: [
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AppColors.gold.withOpacity(0.10), Colors.transparent],
                    radius: 0.68,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AppColors.cocoa.withOpacity(0.06), Colors.transparent],
                    radius: 0.68,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      const AppBackButton(),
                      const SizedBox(height: 4),
                      KochaloLoginAnimationWidget(
                        key: vm.animKey,
                        height: animH,
                      ),
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
                            _SignInField(
                              label: 'Email Address',
                              placeholder: 'you@example.com',
                              controller: vm.emailCtrl,
                              focusNode: vm.emailFocus,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 13),
                            _SignInField(
                              label: 'Password',
                              placeholder: '••••••••',
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
                            vm.isLoading
                                ? const _LoadingButton(label: 'Signing in…')
                                : GestureDetector(
                                    onTap: () {
                                      FocusScope.of(context).unfocus();
                                      vm.animKey.currentState?.onIdle();
                                      vm.signIn();
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFC9A96E),
                                            Color(0xFF7C5642),
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF000000).withOpacity(0.32),
                                            blurRadius: 28,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Sign In →',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'DM Sans',
                                          ),
                                        ),
                                      ),
                                    ),
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

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ]),
        backgroundColor: AppColors.cocoaDeep,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ));
  }
}

// ─── Input field ──────────────────────────────────────────────
class _SignInField extends StatefulWidget {
  final String label, placeholder;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool obscureText;
  final TextInputType? keyboardType;
  final VoidCallback? onToggleObscure;

  const _SignInField({
    required this.label,
    required this.placeholder,
    required this.controller,
    required this.focusNode,
    this.obscureText = false,
    this.keyboardType,
    this.onToggleObscure,
  });

  @override
  State<_SignInField> createState() => _SignInFieldState();
}

class _SignInFieldState extends State<_SignInField> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocus);
  }

  void _onFocus() => setState(() => _focused = widget.focusNode.hasFocus);

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: _focused ? AppColors.cocoa : AppColors.muted,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(_focused ? 0.90 : 0.75),
            border: Border.all(
              color: _focused ? AppColors.cocoa : const Color(0xFFB48C50).withOpacity(0.22),
              width: _focused ? 1.5 : 1.0,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: _focused ? AppShadows.inputFocus : AppShadows.sm,
          ),
          child: TextField(
            focusNode: widget.focusNode,
            controller: widget.controller,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              color: AppColors.cocoaDeep,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                color: AppColors.muted.withOpacity(0.45),
                fontWeight: FontWeight.w300,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: InputBorder.none,
              suffixIcon: widget.onToggleObscure != null
                  ? GestureDetector(
                      onTap: widget.onToggleObscure,
                      child: Icon(
                        widget.obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                        color: AppColors.muted.withOpacity(0.55),
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Loading button ───────────────────────────────────────────
class _LoadingButton extends StatelessWidget {
  final String label;
  const _LoadingButton({required this.label});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppGradients.ctaButton,
          borderRadius: BorderRadius.circular(AppRadius.button),
          boxShadow: AppShadows.btn,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      );
}
