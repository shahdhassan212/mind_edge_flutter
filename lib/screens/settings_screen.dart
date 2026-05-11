// screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/design_tokens.dart';
import '../widgets/common_widgets.dart';
import '../widgets/robot_widget.dart';
import '../features/auth/auth_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(signOutProvider, (_, next) {
      if (next is SignOutSuccess) {
        Navigator.pushNamedAndRemoveUntil(context, '/signin', (_) => false);
      }
    });

    final isLoggingOut = ref.watch(signOutProvider) is AuthLoading;

    final userAsync = ref.watch(currentUserProvider);
    final displayName = userAsync.when(
      data: (u) => u?.fullName.isNotEmpty == true ? u!.fullName : 'User',
      loading: () => '…',
      error: (_, __) => 'User',
    );
    final displayEmail = userAsync.when(
      data: (u) => u?.email ?? '',
      loading: () => '…',
      error: (_, __) => '',
    );
    final avatarLetter = userAsync.when(
      data: (u) => u?.firstName.isNotEmpty == true ? u!.firstName[0].toUpperCase() : 'U',
      loading: () => '…',
      error: (_, __) => 'U',
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.45, 1.0],
            colors: [
              Color(0xFFFDFAF4),
              Color(0xFFF5EBDA),
              Color(0xFFECDCBF),
            ],
          ),
        ),
        child: Stack(children: [
          // Top-right glow
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.gold.withOpacity(0.12),
                    Colors.transparent,
                  ],
                  radius: 0.68,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(children: [
              // ── Nav bar
              Padding(
                padding: const EdgeInsets.fromLTRB(26, 10, 26, 0),
                child: Row(children: [
                  const AppBackButton(),
                  const Spacer(),
                  const Text('Settings',
                      style: TextStyle(
                          fontFamily: 'Syne',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.cocoaDeep)),
                  const Spacer(),
                  const SizedBox(width: 36),
                ]),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),

                      // ── Robot + greeting
                      const SizedBox(
                        width: 110,
                        height: 120,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: MainRobot(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Hello, $displayName',
                        style: const TextStyle(
                          fontFamily: 'Syne',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.cocoaDeep,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        displayEmail,
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          color: AppColors.muted,
                          fontWeight: FontWeight.w300,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Profile card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 26),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.62),
                            border: Border.all(color: const Color(0xFFB48C50).withOpacity(0.15)),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: AppShadows.md,
                          ),
                          child: Row(children: [
                            // Avatar circle
                            Container(
                              width: 52,
                              height: 52,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle, gradient: AppGradients.ctaButton),
                              child: Center(
                                child: Text(
                                  avatarLetter,
                                  style: const TextStyle(
                                      fontFamily: 'Syne',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: const TextStyle(
                                        fontFamily: 'Syne',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.cocoaDeep),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    displayEmail,
                                    style: const TextStyle(
                                        fontFamily: 'DM Sans',
                                        fontSize: 11.5,
                                        color: AppColors.muted,
                                        fontWeight: FontWeight.w300),
                                  ),
                                ],
                              ),
                            ),
                          ]),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Account section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 26),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 4, bottom: 8),
                              child: Text(
                                'ACCOUNT',
                                style: TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.0,
                                    color: AppColors.muted),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.62),
                                border:
                                    Border.all(color: const Color(0xFFB48C50).withOpacity(0.14)),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: AppShadows.sm,
                              ),
                              child: Column(children: [
                                // Change Password
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(context, '/forgot-email'),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                                    child: Row(children: [
                                      Container(
                                        width: 34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color: AppColors.cocoa.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(10),
                                          border:
                                              Border.all(color: AppColors.cocoa.withOpacity(0.12)),
                                        ),
                                        child: const Center(
                                          child: Icon(Icons.lock_outline_rounded,
                                              size: 16, color: AppColors.cocoa),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Text(
                                          'Change Password',
                                          style: TextStyle(
                                              fontFamily: 'DM Sans',
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.cocoaDeep),
                                        ),
                                      ),
                                      const Icon(Icons.arrow_forward_ios_rounded,
                                          size: 13, color: AppColors.muted),
                                    ]),
                                  ),
                                ),
                              ]),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Sign out button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 26),
                        child: GestureDetector(
                          onTap: isLoggingOut
                              ? null
                              : () => ref.read(signOutProvider.notifier).signOut(),
                          child: AnimatedOpacity(
                            opacity: isLoggingOut ? 0.6 : 1,
                            duration: const Duration(milliseconds: 150),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.55),
                                border:
                                    Border.all(color: const Color(0xFFC0392B).withOpacity(0.25)),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: AppShadows.sm,
                              ),
                              child: isLoggingOut
                                  ? const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2, color: Color(0xFF9C2A1E)),
                                      ),
                                    )
                                  : const Center(
                                      child: Text(
                                        'Sign Out',
                                        style: TextStyle(
                                            fontFamily: 'DM Sans',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF9C2A1E)),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Version
                      const Text(
                        'MindEdge v1.0.0',
                        style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 11,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w300),
                      ),
                    ],
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
