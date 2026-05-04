// screens/settings_screen.dart — Real API logout + dynamic profile
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/design_tokens.dart';
import '../widgets/common_widgets.dart';
import '../features/auth/auth_providers.dart';


class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _audioOn = true;
  bool _captionsOn = true;

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
      data: (u) => (u?.firstName.isNotEmpty == true) ? u!.firstName[0].toUpperCase() : 'U',
      loading: () => '…',
      error: (_, __) => 'U',
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFAF4E8),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.45, 1.0],
                colors: [Color(0xFFFDFAF4), Color(0xFFF5EBDA), Color(0xFFECDCBF)])),
        child: Stack(children: [
          Positioned(
              top: -60,
              right: -60,
              child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                          colors: [AppColors.gold.withOpacity(0.12), Colors.transparent],
                          radius: 0.68)))),
          SafeArea(
              child: Column(children: [
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
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Profile card
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 16, 26, 0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.62),
                        border: Border.all(color: const Color(0xFFB48C50).withOpacity(0.15)),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppShadows.md),
                    child: Row(children: [
                      Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, gradient: AppGradients.ctaButton),
                          child: Center(
                              child: Text(avatarLetter,
                                  style: const TextStyle(
                                      fontFamily: 'Syne',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.white)))),
                      const SizedBox(width: 14),
                      Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(displayName,
                            style: const TextStyle(
                                fontFamily: 'Syne',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.cocoaDeep)),
                        Text(displayEmail,
                            style: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 12,
                                color: AppColors.muted,
                                fontWeight: FontWeight.w300)),
                      ])),
                      const Text('Edit',
                          style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.cocoa)),
                    ]),
                  ),
                ),

                _Section(label: 'AI PREFERENCES', children: [
                  _RowToggle(
                      icon: '🤖',
                      title: 'AI Audio Explanations',
                      sub: 'Auto-generate for new content',
                      on: _audioOn,
                      onTap: () => setState(() => _audioOn = !_audioOn)),
                  _RowToggle(
                      icon: '📝',
                      title: 'Auto Captions',
                      sub: 'Show transcript while listening',
                      on: _captionsOn,
                      onTap: () => setState(() => _captionsOn = !_captionsOn)),
                  _RowValue(
                      icon: '✦',
                      title: 'Summary Mode',
                      sub: 'Default output format',
                      value: 'Bullets ›',
                      onTap: () {}),
                ]),

                _Section(label: 'STUDY SETTINGS', children: [
                  _RowValue(icon: '🔔', title: 'Daily Reminders', value: '9:00 AM ›', onTap: () {}),
                  _RowValue(icon: '🎯', title: 'Daily Goal', value: '2 hours ›', onTap: () {}),
                  _RowValue(icon: '🌐', title: 'Language', value: 'English ›', onTap: () {}),
                ]),

                _Section(label: 'ACCOUNT', children: [
                  _RowValue(
                      icon: '🔒',
                      title: 'Change Password',
                      value: '›',
                      onTap: () => Navigator.pushNamed(context, '/forgot-email')),
                  _RowValue(icon: '📤', title: 'Export Data', value: '›', onTap: () {}),
                  _RowValue(
                      icon: '🗑️',
                      title: 'Delete Account',
                      value: '›',
                      valueColor: const Color(0xFF9C2A1E),
                      onTap: () {}),
                ]),

                // Sign out button — real API call
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 12, 26, 0),
                  child: GestureDetector(
                    onTap: isLoggingOut ? null : () => ref.read(signOutProvider.notifier).signOut(),
                    child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.55),
                            border: Border.all(color: const Color(0xFFC0392B).withOpacity(0.25)),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppShadows.sm),
                        child: isLoggingOut
                            ? const Center(
                                child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Color(0xFF9C2A1E))))
                            : const Center(
                                child: Text('Sign Out',
                                    style: TextStyle(
                                        fontFamily: 'DM Sans',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF9C2A1E))))),
                  ),
                ),

                const SizedBox(height: 16),
                const Center(
                    child: Text('MindEdge v1.0.0',
                        style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 11,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w300))),
              ]),
            )),
          ])),
        ]),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String label;
  final List<Widget> children;
  const _Section({required this.label, required this.children});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.fromLTRB(26, 16, 26, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.12 * 10.5,
                color: AppColors.muted)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.62),
              border: Border.all(color: const Color(0xFFB48C50).withOpacity(0.14)),
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppShadows.sm),
          child: Column(
              children: children
                  .asMap()
                  .map((i, child) => MapEntry(
                      i,
                      Column(children: [
                        child,
                        if (i < children.length - 1)
                          Divider(height: 1, color: const Color(0xFFB48C50).withOpacity(0.1)),
                      ])))
                  .values
                  .toList()),
        ),
      ]));
}

class _RowToggle extends StatelessWidget {
  final String icon, title, sub;
  final bool on;
  final VoidCallback onTap;
  const _RowToggle(
      {required this.icon,
      required this.title,
      required this.sub,
      required this.on,
      required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.cocoaDeep)),
              Text(sub,
                  style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 10.5,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w300)),
            ])),
            _Toggle(on: on),
          ])));
}

class _RowValue extends StatelessWidget {
  final String icon, title, value;
  final String? sub;
  final Color? valueColor;
  final VoidCallback onTap;
  const _RowValue(
      {required this.icon,
      required this.title,
      required this.value,
      this.sub,
      this.valueColor,
      required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Expanded(
                child: sub != null
                    ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(title,
                            style: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.cocoaDeep)),
                        Text(sub!,
                            style: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 10.5,
                                color: AppColors.muted,
                                fontWeight: FontWeight.w300)),
                      ])
                    : Text(title,
                        style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.cocoaDeep))),
            Text(value,
                style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? AppColors.cocoa)),
          ])));
}

class _Toggle extends StatelessWidget {
  final bool on;
  const _Toggle({required this.on});
  @override
  Widget build(BuildContext context) => AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 34,
      height: 19,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: on ? const LinearGradient(colors: [AppColors.cocoa, AppColors.gold]) : null,
          color: on ? null : AppColors.cocoa.withOpacity(0.15),
          boxShadow: on
              ? [
                  BoxShadow(
                      color: AppColors.cocoa.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ]
              : null),
      child: Align(
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
              margin: const EdgeInsets.all(3),
              width: 13,
              height: 13,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1))
                  ]))));
}
