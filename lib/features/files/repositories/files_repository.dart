// features/files/repositories/files_repository.dart

import 'package:dio/dio.dart';
import '../models/file_model.dart';
import '../../../core/network/dio_client.dart';

class FilesRepository {
  final DioClient _client;

  FilesRepository({DioClient? client}) : _client = client ?? DioClient();

  // ── GET /api/File/ListFiles ──────────────────────────────
  Future<List<LibFile>> fetchFiles() async {
    final resp = await _client.get<Map<String, dynamic>>('/api/File/ListFiles');

    final raw = (resp.data!['files'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();

    return raw.map(LibFile.fromString).toList();
  }

  // ── POST /api/File/Upload  (multipart) ──────────────────
  Future<bool> uploadFile(String filePath, String fileName) async {
    final ext = fileName.split('.').last.toLowerCase();

    final formData = FormData.fromMap({
      'File': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
        contentType: DioMediaType.parse(_mimeOf(ext)),
      ),
    });

    final resp = await _client.post<dynamic>(
      '/api/File/Upload',
      data: formData,
    );

    return resp.statusCode == 200 || resp.statusCode == 201;
  }

  String _mimeOf(String ext) {
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      default:
        return 'application/octet-stream';
    }
  }
}
