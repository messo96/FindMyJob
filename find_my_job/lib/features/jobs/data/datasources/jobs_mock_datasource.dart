import '../../domain/entities/job.dart';
import '../../domain/repositories/jobs_repository.dart';
import '../../../../core/utils/geo_utils.dart';

/// Mock implementation of [JobsRepository].
/// Returns realistic fake data so the app is fully navigable in phase 2
/// without a backend connection.
///
/// Replace this with [FirebaseJobsRepository] in phase 3 by overriding
/// the provider in ProviderScope.
class MockJobsRepository implements JobsRepository {
  static final _now = DateTime.now();

  static final List<Job> _allJobs = [
    Job(
      id: 'job-001',
      companyId: 'company-001',
      companyName: 'Spotify Italy',
      companyLogoUrl: null,
      title: 'Senior Flutter Developer',
      description:
          'Unisciti al team di Spotify per costruire la prossima generazione dell\'esperienza mobile. Lavorerai su funzionalità ascoltate da milioni di utenti ogni giorno.',
      category: 'Software',
      contractType: ContractType.fullTime,
      experienceLevel: ExperienceLevel.senior,
      skills: ['Flutter', 'Dart', 'Firebase', 'REST APIs', 'Git'],
      benefits: ['Smart working', 'Stock options', 'Ticket restaurant', 'Formazione continua'],
      salary: const SalaryRange(min: 50000, max: 75000),
      workingHours: 'Full-time (40h/sett)',
      location: 'Milano, Italia',
      latitude: 45.4654219,
      longitude: 9.1859243,
      geohash: GeoUtils.encode(45.4654219, 9.1859243),
      status: JobStatus.active,
      applicationsCount: 23,
      createdAt: _now.subtract(const Duration(days: 2)),
      updatedAt: _now.subtract(const Duration(days: 2)),
    ),
    Job(
      id: 'job-002',
      companyId: 'company-002',
      companyName: 'Satispay',
      companyLogoUrl: null,
      title: 'Product Designer',
      description:
          'Cerchiamo un Product Designer appassionato di UX e fintech per lavorare su Satispay, l\'app di pagamento più amata in Italia.',
      category: 'Design',
      contractType: ContractType.fullTime,
      experienceLevel: ExperienceLevel.mid,
      skills: ['Figma', 'Design System', 'Prototipazione', 'User Research'],
      benefits: ['Remote friendly', 'Buoni pasto', 'Assicurazione sanitaria'],
      salary: const SalaryRange(min: 35000, max: 50000),
      workingHours: 'Full-time',
      location: 'Milano, Italia',
      latitude: 45.4773,
      longitude: 9.1815,
      geohash: GeoUtils.encode(45.4773, 9.1815),
      status: JobStatus.active,
      applicationsCount: 41,
      createdAt: _now.subtract(const Duration(days: 5)),
      updatedAt: _now.subtract(const Duration(days: 5)),
    ),
    Job(
      id: 'job-003',
      companyId: 'company-003',
      companyName: 'Bending Spoons',
      companyLogoUrl: null,
      title: 'iOS Developer',
      description:
          'Bending Spoons, una delle app company più di successo in Europa, cerca un iOS Developer per rafforzare il team.',
      category: 'Software',
      contractType: ContractType.fullTime,
      experienceLevel: ExperienceLevel.mid,
      skills: ['Swift', 'SwiftUI', 'UIKit', 'Xcode', 'REST APIs'],
      benefits: ['Top of market salary', 'Work from anywhere', 'Retreats'],
      salary: const SalaryRange(min: 60000, max: 90000),
      workingHours: 'Full-time',
      location: 'Milano, Italia',
      latitude: 45.4641,
      longitude: 9.1919,
      geohash: GeoUtils.encode(45.4641, 9.1919),
      status: JobStatus.active,
      applicationsCount: 67,
      createdAt: _now.subtract(const Duration(hours: 18)),
      updatedAt: _now.subtract(const Duration(hours: 18)),
    ),
    Job(
      id: 'job-004',
      companyId: 'company-004',
      companyName: 'Prima.it',
      companyLogoUrl: null,
      title: 'Backend Engineer (Python)',
      description:
          'Prima.it, insurtech leader in Italia, cerca un Backend Engineer per scalare la nostra piattaforma assicurativa.',
      category: 'Software',
      contractType: ContractType.fullTime,
      experienceLevel: ExperienceLevel.senior,
      skills: ['Python', 'FastAPI', 'PostgreSQL', 'AWS', 'Docker'],
      benefits: ['Equity', 'Flessibilità oraria', 'Budget formazione'],
      salary: const SalaryRange(min: 55000, max: 80000),
      workingHours: 'Full-time flessibile',
      location: 'Milano, Italia',
      latitude: 45.4720,
      longitude: 9.2102,
      geohash: GeoUtils.encode(45.4720, 9.2102),
      status: JobStatus.active,
      applicationsCount: 12,
      createdAt: _now.subtract(const Duration(days: 1)),
      updatedAt: _now.subtract(const Duration(days: 1)),
    ),
    Job(
      id: 'job-005',
      companyId: 'company-005',
      companyName: 'Subito.it',
      companyLogoUrl: null,
      title: 'Data Analyst',
      description:
          'Subito.it cerca un Data Analyst per trasformare i dati di milioni di annunci in insight azionabili.',
      category: 'Data & Analytics',
      contractType: ContractType.fullTime,
      experienceLevel: ExperienceLevel.junior,
      skills: ['SQL', 'Python', 'Tableau', 'Google Analytics'],
      benefits: ['Smart working 3gg', 'Piano di crescita', 'Assicurazione'],
      salary: const SalaryRange(min: 28000, max: 38000),
      workingHours: 'Full-time',
      location: 'Milano, Italia',
      latitude: 45.4875,
      longitude: 9.2062,
      geohash: GeoUtils.encode(45.4875, 9.2062),
      status: JobStatus.active,
      applicationsCount: 30,
      createdAt: _now.subtract(const Duration(days: 7)),
      updatedAt: _now.subtract(const Duration(days: 7)),
    ),
    Job(
      id: 'job-006',
      companyId: 'company-006',
      companyName: 'Talent Garden',
      companyLogoUrl: null,
      title: 'Marketing Manager',
      description:
          'Talent Garden cerca un Marketing Manager per guidare le campagne di crescita del network europeo di campus tech.',
      category: 'Marketing',
      contractType: ContractType.fullTime,
      experienceLevel: ExperienceLevel.mid,
      skills: ['Digital Marketing', 'SEO/SEM', 'Google Ads', 'Analytics'],
      benefits: ['Accesso campus gratuito', 'Team internazionale', 'Bonus'],
      salary: const SalaryRange(min: 32000, max: 45000),
      workingHours: 'Full-time',
      location: 'Milano, Italia',
      latitude: 45.5100,
      longitude: 9.2000,
      geohash: GeoUtils.encode(45.5100, 9.2000),
      status: JobStatus.active,
      applicationsCount: 19,
      createdAt: _now.subtract(const Duration(days: 3)),
      updatedAt: _now.subtract(const Duration(days: 3)),
    ),
    Job(
      id: 'job-007',
      companyId: 'company-007',
      companyName: 'Jakala',
      companyLogoUrl: null,
      title: 'UX Researcher',
      description:
          'Jakala cerca un UX Researcher per guidare la ricerca qualitativa e quantitativa su prodotti digitali per brand internazionali.',
      category: 'Design',
      contractType: ContractType.fullTime,
      experienceLevel: ExperienceLevel.mid,
      skills: ['User Research', 'Usability Testing', 'Figma', 'Interviste utenti'],
      benefits: ['Hybrid work', 'Formazione', 'Welfare aziendale'],
      salary: const SalaryRange(min: 33000, max: 48000),
      workingHours: 'Full-time',
      location: 'Roma, Italia',
      latitude: 41.9028,
      longitude: 12.4964,
      geohash: GeoUtils.encode(41.9028, 12.4964),
      status: JobStatus.active,
      applicationsCount: 8,
      createdAt: _now.subtract(const Duration(hours: 6)),
      updatedAt: _now.subtract(const Duration(hours: 6)),
    ),
    Job(
      id: 'job-008',
      companyId: 'company-008',
      companyName: 'Velasca',
      companyLogoUrl: null,
      title: 'Sviluppatore Web (React)',
      description:
          'Velasca, brand italiano di calzature artigianali in forte crescita, cerca un Frontend Developer React per il proprio e-commerce.',
      category: 'Software',
      contractType: ContractType.partTime,
      experienceLevel: ExperienceLevel.junior,
      skills: ['React', 'TypeScript', 'CSS', 'REST APIs'],
      benefits: ['Flessibilità oraria', 'Sconto prodotti', 'Team giovane'],
      salary: const SalaryRange(min: 20000, max: 28000),
      workingHours: 'Part-time (25h/sett)',
      location: 'Milano, Italia',
      latitude: 45.4600,
      longitude: 9.2080,
      geohash: GeoUtils.encode(45.4600, 9.2080),
      status: JobStatus.active,
      applicationsCount: 5,
      createdAt: _now.subtract(const Duration(days: 10)),
      updatedAt: _now.subtract(const Duration(days: 10)),
    ),
  ];

  @override
  Future<List<Job>> getRecommendedJobs(String candidateId) async {
    await _delay();
    // Mock: return all active jobs sorted by recency (backend will do real matching)
    final jobs = _allJobs.where((j) => j.status == JobStatus.active).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return jobs.map((j) => j.copyWith(distanceKm: _fakeDist(j))).toList();
  }

  @override
  Future<List<Job>> getJobsNearLocation({
    required double latitude,
    required double longitude,
    required double radiusKm,
    JobFilters filters = const JobFilters(),
    int limit = 100,
  }) async {
    await _delay();
    var jobs = _allJobs
        .where((j) => j.status == JobStatus.active)
        .map((j) {
          final dist = GeoUtils.distanceKm(latitude, longitude, j.latitude, j.longitude);
          return j.copyWith(distanceKm: dist);
        })
        .where((j) => j.distanceKm! <= radiusKm)
        .toList()
      ..sort((a, b) => a.distanceKm!.compareTo(b.distanceKm!));

    if (filters.categories.isNotEmpty) {
      jobs = jobs.where((j) => filters.categories.contains(j.category)).toList();
    }
    if (filters.contractTypes.isNotEmpty) {
      jobs = jobs.where((j) => filters.contractTypes.contains(j.contractType)).toList();
    }
    return jobs.take(limit).toList();
  }

  @override
  Future<List<Job>> getRecentJobs({
    int limit = 20,
    JobFilters filters = const JobFilters(),
  }) async {
    await _delay();
    final jobs = _allJobs
        .where((j) => j.status == JobStatus.active)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return jobs.take(limit).map((j) => j.copyWith(distanceKm: _fakeDist(j))).toList();
  }

  @override
  Future<Job> getJobById(String jobId) async {
    await _delay();
    return _allJobs.firstWhere(
      (j) => j.id == jobId,
      orElse: () => throw Exception('Job not found: $jobId'),
    );
  }

  @override
  Future<List<Job>> getCompanyJobs(String companyId) async {
    await _delay();
    return _allJobs.where((j) => j.companyId == companyId).toList();
  }

  @override
  Future<Job> createJob(Job job) async {
    await _delay();
    _allJobs.add(job);
    return job;
  }

  @override
  Future<Job> updateJob(Job job) async {
    await _delay();
    final index = _allJobs.indexWhere((j) => j.id == job.id);
    if (index >= 0) _allJobs[index] = job;
    return job;
  }

  @override
  Future<void> deleteJob(String jobId) async {
    await _delay();
    _allJobs.removeWhere((j) => j.id == jobId);
  }

  @override
  Future<void> updateJobStatus(String jobId, JobStatus status) async {
    await _delay();
    final index = _allJobs.indexWhere((j) => j.id == jobId);
    if (index >= 0) {
      _allJobs[index] = _allJobs[index].copyWith(status: status);
    }
  }

  @override
  Future<List<Job>> searchJobs(String query, {JobFilters filters = const JobFilters()}) async {
    await _delay();
    final q = query.toLowerCase();
    return _allJobs
        .where(
          (j) =>
              j.title.toLowerCase().contains(q) ||
              j.companyName.toLowerCase().contains(q) ||
              j.location.toLowerCase().contains(q) ||
              j.skills.any((s) => s.toLowerCase().contains(q)),
        )
        .toList();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static Future<void> _delay([Duration d = const Duration(milliseconds: 600)]) =>
      Future.delayed(d);

  double _fakeDist(Job j) =>
      GeoUtils.distanceKm(45.4654219, 9.1859243, j.latitude, j.longitude);
}
