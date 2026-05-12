// features/files/providers/files_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/file_model.dart';
import '../repositories/files_repository.dart';
import '../../../features/auth/auth_view_model.dart'; // imports dioClientProvider

// ── Repository provider ──────────────────────────────────────
final filesRepositoryProvider = Provider<FilesRepository>(
  (ref) => FilesRepository(client: ref.watch(dioClientProvider)),
);

// ── List files — GET /api/File/ListFiles ─────────────────────
final filesProvider = FutureProvider.autoDispose<List<LibFile>>((ref) {
  return ref.read(filesRepositoryProvider).fetchFiles();
});

// ── Upload state notifier ─────────────────────────────────────
class UploadNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> upload(String filePath, String fileName) async {
    state = const AsyncValue.loading();
    try {
      final ok = await ref.read(filesRepositoryProvider).uploadFile(filePath, fileName);

      state = const AsyncValue.data(null);

      if (ok) {
        ref.invalidate(filesProvider);
      }
      return ok;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final uploadProvider = AsyncNotifierProvider<UploadNotifier, void>(UploadNotifier.new);
