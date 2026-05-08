// features/library/providers/library_folder_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/folder_model.dart';
import '../repositories/library_folder_repository.dart';

final libraryFolderRepositoryProvider = Provider<LibraryFolderRepository>(
  (_) => LibraryFolderRepository(),
);

class FolderNotifier extends Notifier<List<LibFolder>> {
  LibraryFolderRepository get _repo => ref.read(libraryFolderRepositoryProvider);

  @override
  List<LibFolder> build() => _repo.getFolders();

  void _refresh() => state = _repo.getFolders();

  void createFolder(String name) {
    final folder = LibFolder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      files: const [],
      createdAt: DateTime.now(),
    );
    _repo.save(folder);
    _refresh();
  }

  void renameFolder(String folderId, String newName) {
    final folder = _repo.getFolder(folderId);
    if (folder == null) return;
    _repo.save(folder.copyWith(name: newName.trim()));
    _refresh();
  }

  void deleteFolder(String folderId) {
    _repo.delete(folderId);
    _refresh();
  }

  void addFile(String folderId, LibFolderFile file) {
    final folder = _repo.getFolder(folderId);
    if (folder == null) return;
    _repo.save(folder.copyWith(files: [...folder.files, file]));
    _refresh();
  }

  void removeFile(String folderId, String fileId) {
    final folder = _repo.getFolder(folderId);
    if (folder == null) return;
    _repo.save(folder.copyWith(
      files: folder.files.where((f) => f.id != fileId).toList(),
    ));
    _refresh();
  }
}

final folderProvider =
    NotifierProvider<FolderNotifier, List<LibFolder>>(FolderNotifier.new);
