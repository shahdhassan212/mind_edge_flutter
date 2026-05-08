// features/library/repositories/library_folder_repository.dart

import 'package:hive_flutter/hive_flutter.dart';
import '../models/folder_model.dart';

const String kFoldersBoxName = 'folders';

class LibraryFolderRepository {
  Box<String> get _box => Hive.box<String>(kFoldersBoxName);

  List<LibFolder> getFolders() {
    return _box.values
        .map((s) => LibFolder.fromJsonString(s))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  LibFolder? getFolder(String id) {
    final s = _box.get(id);
    return s == null ? null : LibFolder.fromJsonString(s);
  }

  void save(LibFolder folder) => _box.put(folder.id, folder.toJsonString());

  void delete(String id) => _box.delete(id);
}
