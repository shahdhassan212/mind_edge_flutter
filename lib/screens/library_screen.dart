// screens/library_screen.dart
// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import '../features/files/models/file_model.dart';
import '../features/files/providers/files_provider.dart';
import '../features/files/repositories/files_repository.dart';
import '../features/library/models/folder_model.dart';
import '../features/library/providers/library_folder_providers.dart';

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

  List<LibFile> _filter(List<LibFile> all) {
    final q = _query.toLowerCase();
    final list = q.isEmpty
        ? List<LibFile>.from(all)
        : all.where((f) => f.name.toLowerCase().contains(q)).toList();
    list.sort((a, b) => _ascending ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
    return list;
  }

  // ── Upload server file ────────────────────────────────────
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

  // ── Open file locally ─────────────────────────────────────
  // ── Delete server file ────────────────────────────────────
  Future<void> _deleteServerFile(LibFile file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFFFEFCF7),
        title: const Text('Delete File',
            style: TextStyle(fontFamily: 'Syne', fontSize: 15, fontWeight: FontWeight.w700)),
        content: Text(
          'Are you sure you want to delete "${file.displayName}"? This cannot be undone.',
          style: const TextStyle(fontFamily: 'DM Sans', fontSize: 13, color: Color(0xFF9E8A72)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel',
                style: TextStyle(fontFamily: 'DM Sans', color: Color(0xFF9E8A72))),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete',
                style: TextStyle(
                    fontFamily: 'DM Sans', fontWeight: FontWeight.w700, color: Color(0xFFA32D2D))),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final ok = await ref.read(deleteFileProvider.notifier).delete(file.name);
    if (!mounted) return;
    _showSnack(
      ok ? '✓  "${file.displayName}" deleted' : 'Delete failed — please try again',
      success: ok,
    );
  }

  // ── Rename server file ────────────────────────────────────
  Future<void> _renameServerFile(LibFile file) async {
    final newName = await _promptFileName(context, title: 'Rename File', initial: file.displayName);
    if (newName == null || newName.trim().isEmpty || !mounted) return;
    final ok = await ref.read(renameFileProvider.notifier).rename(file.name, newName.trim());
    if (!mounted) return;
    _showSnack(
      ok ? '✓  Renamed to "$newName"' : 'Rename failed — please try again',
      success: ok,
    );
  }

  Future<void> _openServerFile(LibFile file) async {
    try {
      // Download to temp then open
      final localFile = await ref.read(filesRepositoryProvider).downloadFile(file);
      await OpenFilex.open(localFile.path);
    } catch (e) {
      if (!mounted) return;
      _showSnack('Could not open file — please try again', success: false);
    }
  }

  Future<void> _analyzeServerFile(LibFile file) async {
    _showSnack('Preparing "${file.displayName}"…', success: true);
    try {
      final localFile = await ref.read(filesRepositoryProvider).downloadFile(file);
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/ai-analysis',
        arguments: <String, String>{
          'filePath': localFile.path,
          'fileName': file.displayName,
        },
      );
    } catch (e) {
      if (!mounted) return;
      _showSnack('Failed to load file — please try again', success: false);
    }
  }

  // ── Analyze a folder file ─────────────────────────────────
  void _analyzeFolderFile(LibFolderFile file) {
    Navigator.pushReplacementNamed(
      context,
      '/ai-analysis',
      arguments: <String, String>{'filePath': file.localPath, 'fileName': file.name},
    );
  }

  // ── Add file to folder ────────────────────────────────────
  Future<void> _addFileToFolder(LibFolder folder) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;
    final picked = result.files.first;
    if (picked.path == null) return;

    final ext = picked.name.split('.').last.toLowerCase();
    final f = LibFolderFile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: picked.name,
      localPath: picked.path!,
      ext: ext,
      addedAt: DateTime.now(),
    );
    ref.read(folderProvider.notifier).addFile(folder.id, f);
    if (!mounted) return;
    _showSnack('✓  Added "${picked.name}" to "${folder.name}"', success: true);
  }

  // ── Create folder ─────────────────────────────────────────
  Future<void> _createFolder() async {
    final name = await _promptFolderName(context, title: 'New Folder');
    if (name == null || name.isEmpty || !mounted) return;
    ref.read(folderProvider.notifier).createFolder(name);
  }

  // ── Rename folder ─────────────────────────────────────────
  Future<void> _renameFolder(LibFolder folder) async {
    final name = await _promptFolderName(context, title: 'Rename Folder', initial: folder.name);
    if (name == null || name.isEmpty || !mounted) return;
    ref.read(folderProvider.notifier).renameFolder(folder.id, name);
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

  @override
  Widget build(BuildContext context) {
    final filesAsync = ref.watch(filesProvider);
    final uploadAsync = ref.watch(uploadProvider);
    final uploading = uploadAsync.isLoading;
    final folders = ref.watch(folderProvider);

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
                _IcoBtn(
                  icon: Icons.create_new_folder_outlined,
                  onTap: _createFolder,
                ),
                const SizedBox(width: 8),
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

            // ── Content list ──────────────────────────────
            Expanded(
              child: RefreshIndicator(
                color: _C.goldDark,
                backgroundColor: _C.cardBg,
                onRefresh: () async => ref.invalidate(filesProvider),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                  children: [
                    // ── Folders section ───────────────────
                    if (folders.isNotEmpty) ...[
                      const _SectionLabel(label: 'MY FOLDERS'),
                      const SizedBox(height: 8),
                      ...folders.map((folder) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _FolderTile(
                              folder: folder,
                              onRename: () => _renameFolder(folder),
                              onDelete: () =>
                                  ref.read(folderProvider.notifier).deleteFolder(folder.id),
                              onAddFile: () => _addFileToFolder(folder),
                              onAnalyzeFile: _analyzeFolderFile,
                              onRemoveFile: (fileId) =>
                                  ref.read(folderProvider.notifier).removeFile(folder.id, fileId),
                            ),
                          )),
                      const SizedBox(height: 6),
                    ],

                    // ── Server files section ──────────────
                    filesAsync.when(
                      loading: () => Column(children: [
                        const _SectionLabel(label: 'UPLOADED DOCUMENTS'),
                        const SizedBox(height: 8),
                        ..._skeletonItems(),
                      ]),
                      error: (e, __) => _ErrorState(
                        message: e.toString(),
                        onRetry: () => ref.invalidate(filesProvider),
                      ),
                      data: (files) {
                        final filtered = _filter(files);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const _SectionLabel(label: 'UPLOADED DOCUMENTS'),
                              const Spacer(),
                              _Chip(label: '${files.length} Files'),
                              const SizedBox(width: 8),
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
                            const SizedBox(height: 8),
                            if (filtered.isEmpty)
                              const _EmptyState()
                            else
                              ...filtered.map((file) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: _FileCard(
                                      file: file,
                                      onTap: () => _openServerFile(file),
                                      onAnalyze: () => _analyzeServerFile(file),
                                      onDelete: () => _deleteServerFile(file),
                                      onRename: () => _renameServerFile(file),
                                    ),
                                  )),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  List<Widget> _skeletonItems() => List.generate(
        3,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
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
                decoration:
                    BoxDecoration(color: _C.border, borderRadius: BorderRadius.circular(11)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        height: 11,
                        decoration: BoxDecoration(
                            color: _C.border, borderRadius: BorderRadius.circular(6))),
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
        ),
      );
}

// ─────────────────────────────────────────────────────────────
// FOLDER TILE
// ─────────────────────────────────────────────────────────────
class _FolderTile extends StatefulWidget {
  final LibFolder folder;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final VoidCallback onAddFile;
  final void Function(LibFolderFile) onAnalyzeFile;
  final void Function(String fileId) onRemoveFile;

  const _FolderTile({
    required this.folder,
    required this.onRename,
    required this.onDelete,
    required this.onAddFile,
    required this.onAnalyzeFile,
    required this.onRemoveFile,
  });

  @override
  State<_FolderTile> createState() => _FolderTileState();
}

class _FolderTileState extends State<_FolderTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final folder = widget.folder;
    return Container(
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
      child: Column(children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            child: Row(children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _C.goldDark.withValues(alpha: 0.10),
                  border: Border.all(color: _C.goldDark.withValues(alpha: 0.20)),
                  borderRadius: BorderRadius.circular(11),
                ),
                child:
                    const Center(child: Icon(Icons.folder_rounded, size: 22, color: _C.goldDark)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(folder.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: _C.textDark,
                      )),
                  const SizedBox(height: 3),
                  Text(
                    '${folder.files.length} ${folder.files.length == 1 ? 'file' : 'files'}',
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 10,
                      color: _C.textMuted,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ]),
              ),
              GestureDetector(
                onTap: widget.onAddFile,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _C.goldDark.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, size: 16, color: _C.goldDark),
                ),
              ),
              const SizedBox(width: 6),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'rename') widget.onRename();
                  if (v == 'delete') widget.onDelete();
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'rename', child: Text('Rename')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
                child: const Icon(Icons.more_vert_rounded, size: 18, color: _C.textMuted),
              ),
              const SizedBox(width: 4),
              Icon(
                _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: _C.textMuted,
              ),
            ]),
          ),
        ),
        if (_expanded) ...[
          const Divider(height: 1, color: _C.border),
          if (folder.files.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.inbox_rounded, size: 14, color: _C.textMuted),
                SizedBox(width: 6),
                Text('No files yet — tap + to add',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      color: _C.textMuted,
                    )),
              ]),
            )
          else
            ...folder.files.map((f) => _FolderFileRow(
                  file: f,
                  onAnalyze: () => widget.onAnalyzeFile(f),
                  onRemove: () => widget.onRemoveFile(f.id),
                )),
        ],
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// FOLDER FILE ROW
// ─────────────────────────────────────────────────────────────
class _FolderFileRow extends StatelessWidget {
  final LibFolderFile file;
  final VoidCallback onAnalyze;
  final VoidCallback onRemove;
  const _FolderFileRow({required this.file, required this.onAnalyze, required this.onRemove});

  Color get _color {
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

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: _C.border.withValues(alpha: 0.5))),
        ),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Center(child: Icon(_icon, size: 16, color: _color)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: _C.textDark,
                  )),
              Text(file.ext.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 9,
                    color: _color,
                    fontWeight: FontWeight.w700,
                  )),
            ]),
          ),
          GestureDetector(
            onTap: onAnalyze,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: _C.goldDark.withValues(alpha: 0.12),
                border: Border.all(color: _C.goldDark.withValues(alpha: 0.28)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                  child: Icon(Icons.auto_awesome_rounded, size: 13, color: _C.goldDark)),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: _C.errBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Icon(Icons.close_rounded, size: 13, color: _C.errClr)),
            ),
          ),
        ]),
      );
}

// ─────────────────────────────────────────────────────────────
// SERVER FILE CARD
// ─────────────────────────────────────────────────────────────
class _FileCard extends StatelessWidget {
  final LibFile file;
  final VoidCallback onTap;
  final VoidCallback onAnalyze;
  final VoidCallback onDelete;
  final VoidCallback onRename;

  const _FileCard({
    required this.file,
    required this.onTap,
    required this.onAnalyze,
    required this.onDelete,
    required this.onRename,
  });

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
              onTap: onAnalyze,
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
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'rename') onRename();
                if (v == 'delete') onDelete();
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'rename', child: Text('Rename')),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete', style: TextStyle(color: Color(0xFFA32D2D))),
                ),
              ],
              child: const Icon(Icons.more_vert_rounded, size: 18, color: _C.textMuted),
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

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 9.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: _C.textMuted,
      ));
}

// ─────────────────────────────────────────────────────────────
// FOLDER NAME DIALOG  ★ FIX — StatefulWidget owns the controller
// ─────────────────────────────────────────────────────────────
//
// WHY THE OLD CODE CRASHED:
//
//   final ctrl = TextEditingController(text: initial);   // created here
//   final result = await showDialog(
//     builder: (_) => AlertDialog(                        // _ = wrong context!
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context,       // parent context ← bug
//                               ctrl.text.trim()),
//         ),
//       ],
//     ),
//   );
//   ctrl.dispose();   // ← disposed here, but TextField may still hold a ref
//
// PROBLEMS:
//   1. `Navigator.pop(context, ...)` used the PARENT context instead of the
//      dialog's context — causing routing inconsistencies.
//   2. `ctrl.dispose()` was called immediately after `showDialog` returns,
//      but the dialog's TextField can still reference the controller during
//      the same frame's layout/paint pass → crash.
//   3. If the user triggers rapid open/close, the timing race worsens.
//
// FIX: Move the controller into a StatefulWidget.
//   Flutter's framework calls dispose() on the State only after the route
//   is fully removed and no widget in the tree references the controller.
//   There is zero chance of accessing a disposed controller.

class _FolderNameDialog extends StatefulWidget {
  final String title;
  final String initial;
  const _FolderNameDialog({required this.title, this.initial = ''});

  @override
  State<_FolderNameDialog> createState() => _FolderNameDialogState();
}

class _FolderNameDialogState extends State<_FolderNameDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    // Called by Flutter after the dialog route is fully gone.
    // The TextField is already unmounted at this point — safe.
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    // ✅ Synchronous read — no await, no risk.
    final name = _ctrl.text.trim();
    // ✅ Uses the dialog's own BuildContext via Navigator.of(context).
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: const Color(0xFFFEFCF7),
      title: Text(widget.title,
          style: const TextStyle(fontFamily: 'Syne', fontSize: 15, fontWeight: FontWeight.w700)),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(), // keyboard "Done" also submits
        decoration: InputDecoration(
          hintText: 'Folder name',
          hintStyle: const TextStyle(fontFamily: 'DM Sans', fontSize: 13, color: Color(0xFF9E8A72)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        style: const TextStyle(fontFamily: 'DM Sans', fontSize: 13),
      ),
      actions: [
        TextButton(
          // ✅ dialog's own context
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel',
              style: TextStyle(fontFamily: 'DM Sans', color: Color(0xFF9E8A72))),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text('Save',
              style: TextStyle(
                  fontFamily: 'DM Sans', fontWeight: FontWeight.w700, color: Color(0xFF2A1A0E))),
        ),
      ],
    );
  }
}

/// Shows a folder-name prompt and returns the trimmed name, or null if cancelled.
Future<String?> _promptFolderName(
  BuildContext context, {
  required String title,
  String initial = '',
}) {
  // ✅ No controller here — it lives inside _FolderNameDialogState.
  // ✅ No dispose() call needed — Flutter handles it automatically.
  return showDialog<String>(
    context: context,
    builder: (_) => _FolderNameDialog(title: title, initial: initial),
  );
}

/// Shows a file-name prompt and returns the trimmed name, or null if cancelled.
Future<String?> _promptFileName(
  BuildContext context, {
  required String title,
  String initial = '',
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _FolderNameDialog(title: title, initial: initial),
  );
}
