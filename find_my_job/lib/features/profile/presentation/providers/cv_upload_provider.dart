import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'profile_provider.dart';

final cvUploadProvider = StateNotifierProvider<CvUploadNotifier, AsyncValue<String?>>((ref) {
  return CvUploadNotifier(ref);
});

class CvUploadNotifier extends StateNotifier<AsyncValue<String?>> {
  CvUploadNotifier(this.ref) : super(const AsyncValue.data(null));
  
  final Ref ref;

  Future<void> pickAndUploadCv() async {
    final user = ref.read(authNotifierProvider).value;
    if (user == null) return;

    state = const AsyncValue.loading();
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        final bytes = await file.readAsBytes();
        
        final repo = ref.read(profileRepositoryProvider);
        final path = await repo.uploadCv(
          uid: user.uid,
          fileBytes: bytes,
          fileName: result.files.single.name,
        );
        state = AsyncValue.data(path);
      } else {
        state = const AsyncValue.data(null); // User canceled
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteCv() async {
    final user = ref.read(authNotifierProvider).value;
    if (user == null) return;

    state = const AsyncValue.loading();
    try {
      final repo = ref.read(profileRepositoryProvider);
      await repo.deleteCv(user.uid);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
