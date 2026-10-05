import '../entities/application.dart';

/// Abstract repository for application (candidatura) operations.
abstract class ApplicationsRepository {
  /// Apply to a job. Server-side validation via Cloud Function.
  /// Throws if: already applied, job expired, not authenticated.
  Future<Application> applyToJob({
    required String jobId,
    String? coverLetter,
  });

  /// Stream of applications for the current candidate.
  Stream<List<Application>> getCandidateApplications(String candidateId);

  /// Fetch applications received by a company, optionally filtered by job.
  Future<List<Application>> getCompanyApplications(
    String companyId, {
    String? jobId,
  });

  /// Update the status of an application (company action).
  Future<void> updateApplicationStatus(
    String applicationId,
    ApplicationStatus status,
  );

  /// Check if the current candidate has already applied to a job.
  Future<bool> hasApplied(String jobId);
}
