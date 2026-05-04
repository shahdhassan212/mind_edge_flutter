// screens/sign_up.dart
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
        _showError(context, vm.errorMessage!);
        vm.resetError();
      }
    });

    final vm = ref.watch(signUpVMProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFCF7EE),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ── Gradient background ──────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(gradient: AppGradients.signUp),
            ),
          ),

          // ── Decorative orbs ──────────────────────────────────
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.gold.withOpacity(0.11), Colors.transparent],
                  radius: 0.68,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.cocoa.withOpacity(0.07), Colors.transparent],
                  radius: 0.68,
                ),
              ),
            ),
          ),

          // ── Main content ─────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress bar
                SizedBox(
                  height: 3,
                  child: Row(children: [
                    Expanded(
                      flex: 50,
                      child: Container(
                        decoration: const BoxDecoration(gradient: AppGradients.progress),
                      ),
                    ),
                    Expanded(
                      flex: 50,
                      child: Container(color: AppColors.cocoa.withOpacity(0.10)),
                    ),
                  ]),
                ),

                // Scrollable area
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                    ),
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
                              letterSpacing: 0.09 * 11,
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
                              letterSpacing: -0.025 * 26,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 22),

                          // First + Last name row
                          Row(children: [
                            Expanded(
                              child: _SignUpField(
                                label: 'First Name',
                                hint: 'Alex',
                                controller: vm.firstNameCtrl,
                                textCapitalization: TextCapitalization.words,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _SignUpField(
                                label: 'Last Name',
                                hint: 'Jordan',
                                controller: vm.lastNameCtrl,
                                textCapitalization: TextCapitalization.words,
                              ),
                            ),
                          ]),
                          const SizedBox(height: 12),

                          _SignUpField(
                            label: 'Email Address',
                            hint: 'you@university.edu',
                            controller: vm.emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 12),

                          _SignUpField(
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

                          TermsRow(
                            checked: vm.termsAccepted,
                            onTap: vm.toggleTerms,
                          ),
                          const SizedBox(height: 20),

                          vm.isLoading
                              ? const _LoadingBtn()
                              : GestureDetector(
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    vm.signUp();
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
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Create Account →',
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
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),

                // Footer
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

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.cocoaDeep,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ));
  }
}

// ── Input field ───────────────────────────────────────────────────
class _SignUpField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final VoidCallback? onToggleObscure;
  final ValueChanged<String>? onChanged;

  const _SignUpField({
    required this.label,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.onToggleObscure,
    this.onChanged,
  });

  @override
  State<_SignUpField> createState() => _SignUpFieldState();
}

class _SignUpFieldState extends State<_SignUpField> {
  final _focus = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() => setState(() => _isFocused = _focus.hasFocus);

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
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
            color: _isFocused ? AppColors.cocoa : const Color(0xFF6B4C3B),
            letterSpacing: 0.1 * 10.5,
          ),
        ),
        const SizedBox(height: 5),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: _isFocused
                ? Colors.white.withValues(alpha: 0.92)
                : Colors.white.withValues(alpha: 0.80),
            border: Border.all(
              color: _isFocused
                  ? AppColors.cocoa
                  : const Color(0xFFB48C50).withValues(alpha: 0.28),
              width: _isFocused ? 1.5 : 1.0,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppColors.cocoa.withValues(alpha: 0.12),
                      blurRadius: 0,
                      spreadRadius: 3,
                    ),
                    BoxShadow(
                      color: AppColors.shadowWarm1.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppColors.shadowWarm1.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: TextField(
            focusNode: _focus,
            controller: widget.controller,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            textCapitalization: widget.textCapitalization,
            onChanged: widget.onChanged,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              color: AppColors.cocoaDeep,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                color: AppColors.muted.withValues(alpha: 0.50),
                fontWeight: FontWeight.w300,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: InputBorder.none,
              suffixIcon: widget.onToggleObscure != null
                  ? GestureDetector(
                      onTap: widget.onToggleObscure,
                      child: Icon(
                        widget.obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                        color: AppColors.muted.withValues(alpha: 0.55),
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

// ── Loading button ────────────────────────────────────────────────
class _LoadingBtn extends StatelessWidget {
  const _LoadingBtn();

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFC9A96E), Color(0xFF7C5642)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withOpacity(0.32),
              blurRadius: 28,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Creating account…',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
}
