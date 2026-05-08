// features/library/models/folder_model.dart

import 'dart:convert';

class LibFolder {
  final String id;
  final String name;
  final List<LibFolderFile> files;
  final DateTime createdAt;

  const LibFolder({
    required this.id,
    required this.name,
    required this.files,
    required this.createdAt,
  });

  LibFolder copyWith({String? name, List<LibFolderFile>? files}) => LibFolder(
        id: id,
        name: name ?? this.name,
        files: files ?? this.files,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'files': files.map((f) => f.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory LibFolder.fromJson(Map<String, dynamic> json) => LibFolder(
        id: json['id'] as String,
        name: json['name'] as String,
        files: (json['files'] as List<dynamic>)
            .map((e) => LibFolderFile.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  String toJsonString() => jsonEncode(toJson());

  factory LibFolder.fromJsonString(String s) =>
      LibFolder.fromJson(jsonDecode(s) as Map<String, dynamic>);
}

class LibFolderFile {
  final String id;
  final String name;
  final String localPath;
  final String ext;
  final DateTime addedAt;

  const LibFolderFile({
    required this.id,
    required this.name,
    required this.localPath,
    required this.ext,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'localPath': localPath,
        'ext': ext,
        'addedAt': addedAt.toIso8601String(),
      };

  factory LibFolderFile.fromJson(Map<String, dynamic> json) => LibFolderFile(
        id: json['id'] as String,
        name: json['name'] as String,
        localPath: json['localPath'] as String,
        ext: json['ext'] as String,
        addedAt: DateTime.parse(json['addedAt'] as String),
      );
}
