import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/design_tokens.dart';
import '../features/library/models/folder_model.dart';
import '../features/library/providers/library_folder_providers.dart';
import '../widgets/scan_widgets.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});
  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  bool _flashOn = false;
  String? _camError;

  // ── Camera state ──────────────────────────────────────────
  CameraController? _camCtrl;
  List<CameraDescription> _cameras = [];
  int _camIndex = 0;
  bool _camReady = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  // ── Camera helpers ────────────────────────────────────────
  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!mounted) return;

    if (!status.isGranted) {
      setState(() => _camError = 'Camera permission denied.\nTap to open settings.');
      return;
    }

    try {
      _cameras = await availableCameras();
    } catch (e) {
      if (mounted) setState(() => _camError = 'No cameras found: $e');
      return;
    }

    if (_cameras.isEmpty) {
      if (mounted) setState(() => _camError = 'No cameras available on this device.');
      return;
    }

    await _startCamera(_camIndex);
  }

  Future<void> _startCamera(int index) async {
    await _camCtrl?.dispose();
    setState(() {
      _camReady = false;
      _camError = null;
    });

    final cam = _cameras[index.clamp(0, _cameras.length - 1)];
    final ctrl = CameraController(
      cam,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await ctrl.initialize();
      if (!mounted) {
        await ctrl.dispose();
        return;
      }
      _camCtrl = ctrl;
      setState(() {
        _camReady = true;
        _camIndex = index;
      });
    } on CameraException catch (e) {
      await ctrl.dispose();
      if (mounted) setState(() => _camError = '${e.code}: ${e.description}');
    }
  }

  Future<void> _toggleFlash() async {
    if (_camCtrl == null || !_camReady) return;
    _flashOn = !_flashOn;
    await _camCtrl!.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
    setState(() {});
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2) return;
    await _startCamera((_camIndex + 1) % _cameras.length);
  }

  Future<void> _capture() async {
    if (_camCtrl == null || !_camReady) return;
    try {
      final xFile = await _camCtrl!.takePicture();
      if (!mounted) return;

      // ── 1. Move image from cache to permanent app directory ──
      final appDir = await getApplicationDocumentsDirectory();
      final destDir = Directory('${appDir.path}/camera_shots');
      await destDir.create(recursive: true);
      final fileName = 'CAM_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final permanentPath = '${destDir.path}/$fileName';
      await File(xFile.path).copy(permanentPath);

      if (!mounted) return;

      // ── 2. Show folder picker bottom sheet ──
      await _showFolderPicker(permanentPath, fileName);
    } on CameraException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Capture failed: ${e.description}')),
        );
      }
    }
  }

  Future<void> _showFolderPicker(String filePath, String fileName) async {
    final folders = ref.read(folderProvider);

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => FolderPickerSheet(
        folders: folders,
        onFolderSelected: (folder) {
          final file = LibFolderFile(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: fileName,
            localPath: filePath,
            ext: 'jpg',
            addedAt: DateTime.now(),
          );
          ref.read(folderProvider.notifier).addFile(folder.id, file);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                '✓  Saved to "${folder.name}"',
                style: const TextStyle(fontFamily: 'DM Sans', fontSize: 12.5),
              ),
              backgroundColor: const Color(0xFF2A1A0E),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 3),
            ));
          }
        },
        onCreateFolder: (name) {
          ref.read(folderProvider.notifier).createFolder(name);
          final updatedFolders = ref.read(folderProvider);
          final newFolder = updatedFolders.lastWhere((f) => f.name == name.trim());
          final file = LibFolderFile(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: fileName,
            localPath: filePath,
            ext: 'jpg',
            addedAt: DateTime.now(),
          );
          ref.read(folderProvider.notifier).addFile(newFolder.id, file);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                '✓  Saved to "$name"',
                style: const TextStyle(fontFamily: 'DM Sans', fontSize: 12.5),
              ),
              backgroundColor: const Color(0xFF2A1A0E),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 3),
            ));
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _camCtrl?.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0905),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0E0905), Color(0xFF1A1008), Color(0xFF0E0905)],
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            // ── Nav ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 10, 26, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: ScanDarkNavBtn(
                    child:
                        const Text('←', style: TextStyle(fontSize: 16, color: AppColors.goldLight)),
                  ),
                ),
                const Spacer(),
                const Text('Scan Document',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFD9CCB5),
                    )),
                const Spacer(),
                GestureDetector(
                  onTap: _toggleFlash,
                  child: ScanDarkNavBtn(
                    child: Text('⚡',
                        style: TextStyle(
                          fontSize: 12,
                          color: _flashOn ? AppColors.gold : AppColors.gold.withOpacity(0.35),
                        )),
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 12),

            // ── Camera zone ───────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0704),
                      border: Border.all(color: AppColors.gold.withOpacity(0.18), width: 1.5),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Stack(children: [
                      Positioned.fill(child: _buildCameraPreview()),

                      // Corner brackets
                      Positioned(
                          top: 14,
                          left: 14,
                          child: ScanCorner(
                              tl: true, color: const Color(0xFFB48C50).withOpacity(0.7))),
                      Positioned(
                          top: 14,
                          right: 14,
                          child: ScanCorner(
                              tr: true, color: const Color(0xFFB48C50).withOpacity(0.7))),
                      Positioned(
                          bottom: 14,
                          left: 14,
                          child: ScanCorner(
                              bl: true, color: const Color(0xFFB48C50).withOpacity(0.7))),
                      Positioned(
                          bottom: 14,
                          right: 14,
                          child: ScanCorner(
                              br: true, color: const Color(0xFFB48C50).withOpacity(0.7))),

                      // OCR badge
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.cocoaDeep.withOpacity(0.75),
                            border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const ScanPulsingDot(),
                            const SizedBox(width: 5),
                            Text(
                              _camReady ? 'OCR Active' : 'Initializing…',
                              style: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.goldLight,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ]),
                        ),
                      ),

                      // Bottom bar
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(14, 18, 14, 10),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Color(0xD90A0704), Colors.transparent],
                            ),
                          ),
                          child: Row(children: [
                            Text('Detection confidence',
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 11,
                                  color: AppColors.white.withOpacity(0.7),
                                  fontWeight: FontWeight.w300,
                                )),
                            const Spacer(),
                            const Text('98.4%',
                                style: TextStyle(
                                  fontFamily: 'Syne',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.goldLight,
                                )),
                          ]),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            const SizedBox(height: 18),

            // ── Shutter row ───────────────────────────────
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ScanCamControl(icon: '🔦', label: 'Flash', active: _flashOn, onTap: _toggleFlash),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: _camReady ? _capture : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _camReady ? Colors.white.withOpacity(0.9) : Colors.white.withOpacity(0.25),
                    border: Border.all(color: AppColors.gold.withOpacity(0.5), width: 4),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 32),
                      BoxShadow(
                          color: Colors.white.withOpacity(0.06), blurRadius: 0, spreadRadius: 8),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _camReady
                            ? Colors.white.withOpacity(0.95)
                            : Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              ScanCamControl(icon: '⇄', label: 'Flip', active: false, onTap: _flipCamera),
            ]),

            const SizedBox(height: 14),
            Text('Hold camera steady · Multi-page supported',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 11,
                  color: AppColors.white.withOpacity(0.3),
                  fontWeight: FontWeight.w300,
                )),
          ]),
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_camError != null) {
      return GestureDetector(
        onTap: () => _camError!.contains('denied') ? openAppSettings() : _initCamera(),
        child: Container(
          color: const Color(0xFF0A0704),
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.camera_alt_outlined, size: 36, color: AppColors.gold.withOpacity(0.4)),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(_camError!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11.5,
                      color: AppColors.white.withOpacity(0.45),
                      height: 1.5,
                    )),
              ),
              const SizedBox(height: 8),
              Text('Tap to retry',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 10.5,
                    color: AppColors.gold.withOpacity(0.6),
                  )),
            ]),
          ),
        ),
      );
    }

    if (!_camReady || _camCtrl == null) {
      return Container(
        color: const Color(0xFF0A0704),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
              width: 22,
              height: 22,
              child:
                  CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold.withOpacity(0.6)),
            ),
            const SizedBox(height: 10),
            Text('Starting camera…',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 11,
                  color: AppColors.white.withOpacity(0.35),
                )),
          ]),
        ),
      );
    }

    final controller = _camCtrl!;
    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * controller.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;

    return Transform.scale(
      scale: scale,
      child: Center(child: CameraPreview(controller)),
    );
  }
}
