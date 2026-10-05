import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/application.dart';
import '../../domain/repositories/applications_repository.dart';
import '../../data/repositories/firebase_applications_repository_impl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/data/repositories/firebase_auth_repository_impl.dart';

final applicationsRepositoryProvider = Provider<ApplicationsRepository>((ref) {
  return FirebaseApplicationsRepositoryImpl(
    ref.watch(firestoreProvider),
    ref.watch(firebaseAuthProvider),
  );
});

final candidateApplicationsProvider = StreamProvider.family<List<Application>, String>((ref, candidateId) {
  return ref.watch(applicationsRepositoryProvider).getCandidateApplications(candidateId);
});

final companyApplicationsProvider = FutureProvider.family<List<Application>, String>((ref, companyId) {
  return ref.watch(applicationsRepositoryProvider).getCompanyApplications(companyId);
});
