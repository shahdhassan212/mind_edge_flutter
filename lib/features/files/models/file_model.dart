// features/files/models/file_model.dart

class LibFile {
  final String name;
  final String ext;
  final String displayName;

  const LibFile({
    required this.name,
    required this.ext,
    required this.displayName,
  });

  factory LibFile.fromString(String rawName) {
    final parts = rawName.split('.');
    final ext = parts.length > 1 ? parts.last.toLowerCase() : 'file';
    final displayName = parts.length > 1
        ? parts.sublist(0, parts.length - 1).join('.').trim()
        : rawName.trim();
    return LibFile(name: rawName, ext: ext, displayName: displayName);
  }
}