// features/files/repositories/files_repository.dart

import 'package:dio/dio.dart';
import '../models/file_model.dart';

class FilesRepository {
  final Dio _dio;

  FilesRepository({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://midedge.runasp.net',
              headers: {'accept': '*/*'},
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
            ));

  // ── GET /api/File/ListFiles ──────────────────────────────
  Future<List<LibFile>> fetchFiles() async {
    final resp = await _dio.get<Map<String, dynamic>>('/api/File/ListFiles');

    if (resp.statusCode != 200) {
      throw Exception('Server returned ${resp.statusCode}');
    }

    final raw = (resp.data!['files'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

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

    final resp = await _dio.post<dynamic>(
      '/api/File/Upload',
      data: formData,
      options: Options(
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
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