// features/files/models/file_model.dart

class LibFile {
  final String name;
  final String ext;
  final String displayName;
  final String fileUrl;

  const LibFile({
    required this.name,
    required this.ext,
    required this.displayName,
    required this.fileUrl,
  });

  factory LibFile.fromJson(Map<String, dynamic> json) {
    final rawName = json['fileName']?.toString() ?? '';
    final url = json['fileUrl']?.toString() ?? '';
    final parts = rawName.split('.');
    final ext = parts.length > 1 ? parts.last.toLowerCase() : 'file';
    final displayName =
        parts.length > 1 ? parts.sublist(0, parts.length - 1).join('.').trim() : rawName.trim();
    return LibFile(
      name: rawName,
      ext: ext,
      displayName: displayName,
      fileUrl: url,
    );
  }
}
