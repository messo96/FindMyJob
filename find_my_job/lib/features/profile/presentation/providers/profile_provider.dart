import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../data/repositories/firebase_profile_repository_impl.dart';
import '../../../auth/data/repositories/firebase_auth_repository_impl.dart';

final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final storage = ref.watch(firebaseStorageProvider);
  return FirebaseProfileRepositoryImpl(firestore, storage);
});

// Candidate profile stream provider for a given uid
final candidateProfileStreamProvider = StreamProvider.family((ref, String uid) {
  return ref.watch(profileRepositoryProvider).watchCandidateProfile(uid);
});

// Company profile stream provider for a given uid
final companyProfileStreamProvider = StreamProvider.family((ref, String uid) {
  return ref.watch(profileRepositoryProvider).watchCompanyProfile(uid);
});
