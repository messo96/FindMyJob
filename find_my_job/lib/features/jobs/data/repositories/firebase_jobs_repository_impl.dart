import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/job.dart';
import '../../domain/repositories/jobs_repository.dart';

class FirebaseJobsRepositoryImpl implements JobsRepository {
  FirebaseJobsRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<List<Job>> getRecommendedJobs(String candidateId) async {
    // Real logic would be server-side or complex client logic.
    // For now, we fallback to recent jobs.
    return getRecentJobs(limit: 20);
  }

  @override
  Future<List<Job>> getJobsNearLocation({
    required double latitude,
    required double longitude,
    required double radiusKm,
    JobFilters filters = const JobFilters(),
    int limit = 100,
  }) async {
    // True spatial search requires GeoFlutterFire or server-side.
    // Fallback to basic fetch.
    return getRecentJobs(limit: limit, filters: filters);
  }

  @override
  Future<List<Job>> getRecentJobs({
    int limit = 20,
    JobFilters filters = const JobFilters(),
  }) async {
    try {
      var query = _firestore
          .collection('jobs')
          .where('status', isEqualTo: JobStatus.active.name)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      final snap = await query.get();
      return snap.docs.map((doc) => _jobFromFirestore(doc)).toList();
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<Job> getJobById(String jobId) async {
    try {
      final doc = await _firestore.collection('jobs').doc(jobId).get();
      if (!doc.exists) {
        throw NotFoundFailure('Offerta di lavoro');
      }
      return _jobFromFirestore(doc);
    } catch (e) {
      if (e is Failure) rethrow;
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<List<Job>> getCompanyJobs(String companyId) async {
    try {
      final snap = await _firestore
          .collection('jobs')
          .where('companyId', isEqualTo: companyId)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs.map((doc) => _jobFromFirestore(doc)).toList();
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<Job> createJob(Job job) async {
    try {
      final docRef = _firestore.collection('jobs').doc(); // Auto ID if job.id is empty
      final id = job.id.isEmpty ? docRef.id : job.id;
      
      final data = _jobToFirestore(job);
      if (job.id.isEmpty) {
        data['id'] = docRef.id;
        await docRef.set(data);
        return _jobFromFirestore(await docRef.get());
      } else {
        await _firestore.collection('jobs').doc(job.id).set(data);
        return job;
      }
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<Job> updateJob(Job job) async {
    try {
      await _firestore.collection('jobs').doc(job.id).update(_jobToFirestore(job));
      return job;
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<void> deleteJob(String jobId) async {
    try {
      await _firestore.collection('jobs').doc(jobId).delete();
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<void> updateJobStatus(String jobId, JobStatus status) async {
    try {
      await _firestore.collection('jobs').doc(jobId).update({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<List<Job>> searchJobs(String queryText, {JobFilters filters = const JobFilters()}) async {
    // Algolia or Meilisearch is recommended for full-text search.
    // Fallback for basic demo.
    return getRecentJobs();
  }

  // --- Converters ---

  Job _jobFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    SalaryRange? salary;
    if (data['salary'] != null) {
      final s = data['salary'] as Map<String, dynamic>;
      salary = SalaryRange(
        min: (s['min'] as num?)?.toDouble(),
        max: (s['max'] as num?)?.toDouble(),
        currency: s['currency'] as String? ?? 'EUR',
        period: SalaryPeriod.values.firstWhere((e) => e.name == s['period'], orElse: () => SalaryPeriod.monthly),
      );
    }

    return Job(
      id: doc.id,
      companyId: data['companyId'] as String,
      companyName: data['companyName'] as String,
      companyLogoUrl: data['companyLogoUrl'] as String?,
      title: data['title'] as String,
      description: data['description'] as String,
      category: data['category'] as String,
      contractType: ContractType.fromString(data['contractType'] as String? ?? 'full_time'),
      experienceLevel: ExperienceLevel.fromString(data['experienceLevel'] as String? ?? 'any'),
      skills: List<String>.from(data['skills'] ?? []),
      benefits: List<String>.from(data['benefits'] ?? []),
      salary: salary,
      workingHours: data['workingHours'] as String?,
      location: data['location'] as String,
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      geohash: data['geohash'] as String? ?? '',
      status: JobStatus.fromString(data['status'] as String? ?? 'active'),
      applicationsCount: data['applicationsCount'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expirationDate: (data['expirationDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> _jobToFirestore(Job job) {
    return {
      'id': job.id,
      'companyId': job.companyId,
      'companyName': job.companyName,
      'companyLogoUrl': job.companyLogoUrl,
      'title': job.title,
      'description': job.description,
      'category': job.category,
      'contractType': job.contractType.firestoreValue,
      'experienceLevel': job.experienceLevel.name,
      'skills': job.skills,
      'benefits': job.benefits,
      'salary': job.salary != null ? {
        'min': job.salary!.min,
        'max': job.salary!.max,
        'currency': job.salary!.currency,
        'period': job.salary!.period.name,
      } : null,
      'workingHours': job.workingHours,
      'location': job.location,
      'latitude': job.latitude,
      'longitude': job.longitude,
      'geohash': job.geohash,
      'status': job.status.name,
      'applicationsCount': job.applicationsCount,
      'createdAt': job.createdAt,
      'updatedAt': FieldValue.serverTimestamp(),
      'expirationDate': job.expirationDate,
    };
  }
}
