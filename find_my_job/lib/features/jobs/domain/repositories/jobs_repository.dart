import '../entities/job.dart';

/// Filter parameters for job queries.
class JobFilters {
  const JobFilters({
    this.categories = const [],
    this.contractTypes = const [],
    this.experienceLevels = const [],
    this.skills = const [],
    this.salaryMin,
    this.radiusKm = 25.0,
    this.sortBy = JobSortOrder.relevance,
  });

  final List<String> categories;
  final List<ContractType> contractTypes;
  final List<ExperienceLevel> experienceLevels;
  final List<String> skills;
  final double? salaryMin;
  final double radiusKm;
  final JobSortOrder sortBy;

  JobFilters copyWith({
    List<String>? categories,
    List<ContractType>? contractTypes,
    List<ExperienceLevel>? experienceLevels,
    List<String>? skills,
    double? salaryMin,
    double? radiusKm,
    JobSortOrder? sortBy,
  }) =>
      JobFilters(
        categories: categories ?? this.categories,
        contractTypes: contractTypes ?? this.contractTypes,
        experienceLevels: experienceLevels ?? this.experienceLevels,
        skills: skills ?? this.skills,
        salaryMin: salaryMin ?? this.salaryMin,
        radiusKm: radiusKm ?? this.radiusKm,
        sortBy: sortBy ?? this.sortBy,
      );

  bool get isEmpty =>
      categories.isEmpty &&
      contractTypes.isEmpty &&
      experienceLevels.isEmpty &&
      skills.isEmpty &&
      salaryMin == null;
}

enum JobSortOrder { relevance, newest, nearest }

/// Abstract repository for job operations.
abstract class JobsRepository {
  /// Fetch jobs ranked by relevance for the given candidate.
  /// The actual ranking algorithm lives server-side (Cloud Function).
  Future<List<Job>> getRecommendedJobs(String candidateId);

  /// Fetch jobs near a location, optionally filtered.
  Future<List<Job>> getJobsNearLocation({
    required double latitude,
    required double longitude,
    required double radiusKm,
    JobFilters filters = const JobFilters(),
    int limit = 100,
  });

  /// Fetch recently published active jobs.
  Future<List<Job>> getRecentJobs({
    int limit = 20,
    JobFilters filters = const JobFilters(),
  });

  /// Fetch a single job by ID.
  Future<Job> getJobById(String jobId);

  /// Fetch all jobs belonging to a company.
  Future<List<Job>> getCompanyJobs(String companyId);

  /// Create a new job (company only).
  Future<Job> createJob(Job job);

  /// Update an existing job (company only, must own the job).
  Future<Job> updateJob(Job job);

  /// Delete a job (company only, must own the job).
  Future<void> deleteJob(String jobId);

  /// Change job status.
  Future<void> updateJobStatus(String jobId, JobStatus status);

  /// Search jobs by text query.
  Future<List<Job>> searchJobs(String query, {JobFilters filters = const JobFilters()});
}
