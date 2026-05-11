import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  bool _picking = false;

  Future<void> _pickFile() async {
    if (_picking) return;
    setState(() => _picking = true);

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
      allowMultiple: false,
    );

    if (!mounted) return;
    setState(() => _picking = false);

    if (result == null || result.files.isEmpty) return;
    final picked = result.files.first;
    if (picked.path == null) return;

    Navigator.pushReplacementNamed(
      context,
      '/ai-analysis',
      arguments: {
        'filePath': picked.path,
        'fileName': picked.name,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.55, 1.0],
            colors: [
              Color(0xFFF7EDD8),
              Color(0xFFEDD9B8),
              Color(0xFFE8D0A8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            // ── Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.aiCardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.aiBorder),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 16, color: AppColors.aiTextDark),
                  ),
                ),
                const Spacer(),
                const Text('AI Analysis',
                    style: TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.aiTextDark)),
                const Spacer(),
                const SizedBox(width: 36),
              ]),
            ),

            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    // Icon
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: AppColors.aiChipBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.aiBorderDash, width: 1.5),
                      ),
                      child: const Icon(Icons.upload_file_rounded,
                          size: 40, color: AppColors.aiGoldDark),
                    ),
                    const SizedBox(height: 20),

                    const Text('Upload a document to analyze',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Syne',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.aiTextDark)),
                    const SizedBox(height: 8),

                    const Text('PDF, DOC, DOCX, PNG, or JPG',
                        style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 13,
                            color: AppColors.aiTextMuted,
                            fontWeight: FontWeight.w400)),
                    const SizedBox(height: 10),

                    const Text(
                      'Our AI will extract text, identify topics,\ngenerate summaries and more.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          color: AppColors.aiTextMuted,
                          fontWeight: FontWeight.w300,
                          height: 1.5),
                    ),
                    const SizedBox(height: 28),

                    GestureDetector(
                      onTap: _picking ? null : _pickFile,
                      child: AnimatedOpacity(
                        opacity: _picking ? 0.6 : 1,
                        duration: const Duration(milliseconds: 150),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.aiTextDark,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                  color: AppColors.aiTextDark.withOpacity(0.30),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4))
                            ],
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            _picking
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              _picking ? 'Opening…' : 'Pick a file',
                              style: const TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                          ]),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: ['PDF', 'DOC', 'DOCX', 'PNG', 'JPG'].map((ext) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.aiChipBg,
                            border: Border.all(color: AppColors.aiBorderDash),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(ext,
                              style: const TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.aiGoldDark)),
                        );
                      }).toList(),
                    ),
                  ]),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
