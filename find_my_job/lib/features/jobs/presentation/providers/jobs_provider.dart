import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/job.dart';
import '../../domain/repositories/jobs_repository.dart';
import '../../data/repositories/firebase_jobs_repository_impl.dart';
import '../../../auth/data/repositories/firebase_auth_repository_impl.dart';

/// Provides the [JobsRepository] implementation.
final jobsRepositoryProvider = Provider<JobsRepository>((ref) {
  return FirebaseJobsRepositoryImpl(ref.watch(firestoreProvider));
});

/// Jobs recommended for the given candidate (server-side ranked).
final recommendedJobsProvider =
    FutureProvider.family<List<Job>, String>((ref, candidateId) {
  return ref.watch(jobsRepositoryProvider).getRecommendedJobs(candidateId);
});

/// Most recently published active jobs.
final recentJobsProvider = FutureProvider<List<Job>>((ref) {
  return ref.watch(jobsRepositoryProvider).getRecentJobs();
});

/// Single job detail.
final jobDetailProvider = FutureProvider.family<Job, String>((ref, jobId) {
  return ref.watch(jobsRepositoryProvider).getJobById(jobId);
});

/// Jobs belonging to a company.
final companyJobsProvider =
    FutureProvider.family<List<Job>, String>((ref, companyId) {
  return ref.watch(jobsRepositoryProvider).getCompanyJobs(companyId);
});

/// Job search results.
final jobSearchProvider =
    FutureProvider.family<List<Job>, String>((ref, query) {
  return ref.watch(jobsRepositoryProvider).searchJobs(query);
});

// ── Near-location query params ─────────────────────────────────────────────

class NearLocationParams {
  const NearLocationParams({
    required this.latitude,
    required this.longitude,
    this.radiusKm = 25.0,
  });

  final double latitude;
  final double longitude;
  final double radiusKm;

  @override
  bool operator ==(Object other) =>
      other is NearLocationParams &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.radiusKm == radiusKm;

  @override
  int get hashCode => Object.hash(latitude, longitude, radiusKm);
}

/// Jobs near a location.
final jobsNearLocationProvider =
    FutureProvider.family<List<Job>, NearLocationParams>((ref, params) {
  return ref.watch(jobsRepositoryProvider).getJobsNearLocation(
        latitude: params.latitude,
        longitude: params.longitude,
        radiusKm: params.radiusKm,
      );
});

// ── Filter state ───────────────────────────────────────────────────────────

final jobFiltersProvider = StateProvider<JobFilters>((ref) => const JobFilters());
