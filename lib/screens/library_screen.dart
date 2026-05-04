// screens/library_screen.dart
// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../features/files/models/file_model.dart';
import '../features/files/providers/files_provider.dart';

// ─────────────────────────────────────────────────────────────
// COLOR TOKENS
// ─────────────────────────────────────────────────────────────
class _C {
  static const cardBg = Color(0xFFFEFCF7);
  static const textDark = Color(0xFF2A1A0E);
  static const textMuted = Color(0xFF9E8A72);
  static const goldDark = Color(0xFFC9943A);
  static const border = Color(0xFFE8D9C0);
  static const chipBg = Color(0xFFF0E8D8);
  static const chipBdr = Color(0xFFDDD0B8);
  static const errBg = Color(0xFFFCEBEB);
  static const errClr = Color(0xFFA32D2D);
  static const uploadBtn = Color(0xFF2A1A0E);
  static const uploadIcon = Colors.white;
}

// ─────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  bool _ascending = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Filter + Sort ─────────────────────────────────────────
  List<LibFile> _filter(List<LibFile> all) {
    final q = _query.toLowerCase();
    final list = q.isEmpty
        ? List<LibFile>.from(all)
        : all.where((f) => f.name.toLowerCase().contains(q)).toList();
    list.sort((a, b) => _ascending ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
    return list;
  }

  // ── Upload flow ───────────────────────────────────────────
  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;

    final picked = result.files.first;
    if (picked.path == null) return;

    final ok = await ref.read(uploadProvider.notifier).upload(picked.path!, picked.name);

    if (!mounted) return;
    _showSnack(
      ok ? '✓  "${picked.name}" uploaded successfully' : 'Upload failed — please try again',
      success: ok,
    );
  }

  void _showSnack(String msg, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'DM Sans', fontSize: 12.5)),
      backgroundColor: success ? const Color(0xFF2A1A0E) : _C.errClr,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 3),
    ));
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final filesAsync = ref.watch(filesProvider);
    final uploadAsync = ref.watch(uploadProvider);
    final uploading = uploadAsync.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF7EDD8),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7EDD8), Color(0xFFEDD9B8), Color(0xFFE8D0A8)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            // ── Top bar ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(children: [
                _IcoBtn(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Center(
                    child: Text('My Library',
                        style: TextStyle(
                          fontFamily: 'Syne',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _C.textDark,
                        )),
                  ),
                ),

                // Upload button
                GestureDetector(
                  onTap: uploading ? null : _pickAndUpload,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _C.uploadBtn,
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: [
                        BoxShadow(
                          color: _C.uploadBtn.withValues(alpha: 0.45),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: uploading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.add, size: 18, color: _C.uploadIcon),
                    ),
                  ),
                ),
              ]),
            ),

            // ── Search bar ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                decoration: BoxDecoration(
                  color: _C.cardBg,
                  border: Border.all(color: _C.border),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: _C.textDark.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(children: [
                  const Icon(Icons.search_rounded, size: 16, color: _C.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _query = v),
                      style:
                          const TextStyle(fontFamily: 'DM Sans', fontSize: 13, color: _C.textDark),
                      decoration: const InputDecoration.collapsed(
                        hintText: 'Search files…',
                        hintStyle: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 13,
                          color: _C.textMuted,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                  if (_query.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchCtrl.clear();
                        setState(() => _query = '');
                      },
                      child: const Icon(Icons.close_rounded, size: 15, color: _C.textMuted),
                    ),
                ]),
              ),
            ),

            // ── Upload progress banner ────────────────────
            if (uploading)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _C.goldDark.withValues(alpha: 0.12),
                  border: Border.all(color: _C.goldDark.withValues(alpha: 0.30)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: _C.goldDark),
                  ),
                  SizedBox(width: 10),
                  Text('Uploading file…',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _C.goldDark,
                      )),
                ]),
              ),

            // ── File list ─────────────────────────────────
            Expanded(
              child: filesAsync.when(
                loading: () => _buildSkeleton(),
                error: (e, __) => _ErrorState(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(filesProvider),
                ),
                data: (files) {
                  final filtered = _filter(files);
                  return Column(children: [
                    // Stats + sort
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      child: Row(children: [
                        _Chip(label: '${files.length} Files'),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => setState(() => _ascending = !_ascending),
                          child: Row(children: [
                            Text(
                              _ascending ? 'A → Z' : 'Z → A',
                              style: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 10.5,
                                color: _C.goldDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Icon(
                              _ascending
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                              size: 12,
                              color: _C.goldDark,
                            ),
                          ]),
                        ),
                      ]),
                    ),

                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Row(children: [
                        Text('UPLOADED DOCUMENTS',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                              color: _C.textMuted,
                            )),
                      ]),
                    ),

                    Expanded(
                      child: filtered.isEmpty
                          ? const _EmptyState()
                          : RefreshIndicator(
                              color: _C.goldDark,
                              backgroundColor: _C.cardBg,
                              onRefresh: () async => ref.invalidate(filesProvider),
                              child: ListView.separated(
                                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 8),
                                itemBuilder: (ctx, i) => _FileCard(
                                  file: filtered[i],
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    '/ai-analysis',
                                    arguments: filtered[i],
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ]);
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildSkeleton() => ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, __) => Container(
          height: 70,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: _C.cardBg,
            border: Border.all(color: _C.border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: _C.border, borderRadius: BorderRadius.circular(11)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      height: 11,
                      decoration:
                          BoxDecoration(color: _C.border, borderRadius: BorderRadius.circular(6))),
                  const SizedBox(height: 7),
                  Container(
                      height: 9,
                      width: 90,
                      decoration: BoxDecoration(
                          color: _C.border.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(6))),
                ],
              ),
            ),
          ]),
        ),
      );
}

// ─────────────────────────────────────────────────────────────
// FILE CARD
// ─────────────────────────────────────────────────────────────
class _FileCard extends StatelessWidget {
  final LibFile file;
  final VoidCallback onTap;
  const _FileCard({required this.file, required this.onTap});

  IconData get _icon {
    switch (file.ext) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'png':
      case 'jpg':
      case 'jpeg':
        return Icons.image_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color get _iconColor {
    switch (file.ext) {
      case 'pdf':
        return const Color(0xFFC05A32);
      case 'doc':
      case 'docx':
        return const Color(0xFF2B5FC2);
      case 'png':
      case 'jpg':
      case 'jpeg':
        return const Color(0xFF2A9D6A);
      default:
        return _C.goldDark;
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          decoration: BoxDecoration(
            color: _C.cardBg,
            border: Border.all(color: _C.border, width: 1.2),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _C.textDark.withValues(alpha: 0.05),
                blurRadius: 7,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _iconColor.withValues(alpha: 0.10),
                border: Border.all(color: _iconColor.withValues(alpha: 0.20)),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Center(child: Icon(_icon, size: 20, color: _iconColor)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(file.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: _C.textDark,
                    )),
                const SizedBox(height: 4),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _iconColor.withValues(alpha: 0.10),
                      border: Border.all(color: _iconColor.withValues(alpha: 0.22)),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(file.ext.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          color: _iconColor,
                        )),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(file.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 10,
                          color: _C.textMuted,
                          fontWeight: FontWeight.w300,
                        )),
                  ),
                ]),
              ]),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _C.goldDark.withValues(alpha: 0.12),
                  border: Border.all(color: _C.goldDark.withValues(alpha: 0.28)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(Icons.auto_awesome_rounded, size: 15, color: _C.goldDark),
                ),
              ),
            ),
          ]),
        ),
      );
}

// ─────────────────────────────────────────────────────────────
// STATES
// ─────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: _C.errBg, borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.wifi_off_rounded, size: 26, color: _C.errClr),
            ),
            const SizedBox(height: 14),
            const Text('Could not load files',
                style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _C.textDark)),
            const SizedBox(height: 6),
            Text(
              message.length > 80 ? '${message.substring(0, 80)}…' : message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'DM Sans', fontSize: 11.5, color: _C.textMuted, height: 1.5),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                decoration:
                    BoxDecoration(color: _C.textDark, borderRadius: BorderRadius.circular(12)),
                child: const Text('Retry',
                    style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
          ]),
        ),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _C.chipBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _C.chipBdr),
            ),
            child: const Icon(Icons.folder_open_rounded, size: 26, color: _C.textMuted),
          ),
          const SizedBox(height: 14),
          const Text('No files found',
              style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _C.textDark)),
          const SizedBox(height: 4),
          const Text('Upload a document to get started',
              style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 12,
                  color: _C.textMuted,
                  fontWeight: FontWeight.w300)),
        ]),
      );
}

// ─────────────────────────────────────────────────────────────
// MICRO WIDGETS
// ─────────────────────────────────────────────────────────────
class _IcoBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IcoBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _C.cardBg.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: _C.border),
            boxShadow: [
              BoxShadow(
                  color: _C.textDark.withValues(alpha: 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Icon(icon, size: 14, color: _C.textDark),
        ),
      );
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: _C.chipBg,
          border: Border.all(color: _C.chipBdr),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(label,
            style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: _C.textDark)),
      );
}
