import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../../../../core/errors/failure.dart';
import '../../domain/entities/application.dart';
import '../../domain/repositories/applications_repository.dart';

class FirebaseApplicationsRepositoryImpl implements ApplicationsRepository {
  FirebaseApplicationsRepositoryImpl(this._firestore, this._firebaseAuth);

  final FirebaseFirestore _firestore;
  final auth.FirebaseAuth _firebaseAuth;

  @override
  Future<Application> applyToJob({
    required String jobId,
    String? coverLetter,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const UnauthorizedFailure();
    }
    
    try {
      // Very basic client-side implementation. Real app should use Cloud Functions.
      // 1. Fetch Job
      final jobDoc = await _firestore.collection('jobs').doc(jobId).get();
      if (!jobDoc.exists) throw const NotFoundFailure('Offerta di lavoro');
      
      final jobData = jobDoc.data()!;
      if (jobData['status'] != 'active') throw const JobExpiredFailure();

      // 2. Fetch User Profile
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() ?? {};

      final docRef = _firestore.collection('applications').doc();
      final now = FieldValue.serverTimestamp();

      await docRef.set({
        'candidateId': user.uid,
        'jobId': jobId,
        'companyId': jobData['companyId'],
        'status': ApplicationStatus.sent.name,
        'coverLetter': coverLetter,
        'createdAt': now,
        'updatedAt': now,
        'candidateSnapshot': {
          'uid': user.uid,
          'name': userData['displayName'] ?? 'Candidato',
          'skills': List<String>.from((userData['skills'] as Iterable<dynamic>?) ?? []),
          'experiences': List<String>.from((userData['experiences'] as Iterable<dynamic>?) ?? []),
        },
        'jobSnapshot': {
          'id': jobId,
          'title': jobData['title'],
          'companyName': jobData['companyName'],
          'location': jobData['location'],
          'contractType': jobData['contractType'],
        }
      });

      // Also increment applicationsCount in jobs collection
      await jobDoc.reference.update({
        'applicationsCount': FieldValue.increment(1),
      });

      final savedDoc = await docRef.get();
      return _applicationFromFirestore(savedDoc);
    } catch (e) {
      if (e is Failure) rethrow;
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Stream<List<Application>> getCandidateApplications(String candidateId) {
    return _firestore
        .collection('applications')
        .where('candidateId', isEqualTo: candidateId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => _applicationFromFirestore(doc)).toList());
  }

  @override
  Future<List<Application>> getCompanyApplications(
    String companyId, {
    String? jobId,
  }) async {
    try {
      var query = _firestore
          .collection('applications')
          .where('companyId', isEqualTo: companyId);
      
      if (jobId != null) {
        query = query.where('jobId', isEqualTo: jobId);
      }

      final snap = await query.orderBy('createdAt', descending: true).get();
      return snap.docs.map((doc) => _applicationFromFirestore(doc)).toList();
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<void> updateApplicationStatus(String applicationId, ApplicationStatus status) async {
    try {
      await _firestore.collection('applications').doc(applicationId).update({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<bool> hasApplied(String jobId) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return false;

    try {
      final snap = await _firestore
          .collection('applications')
          .where('candidateId', isEqualTo: user.uid)
          .where('jobId', isEqualTo: jobId)
          .limit(1)
          .get();
      return snap.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // --- Converters ---

  Application _applicationFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse JobMini
    JobMini? jobMini;
    if (data['jobSnapshot'] != null) {
      final j = data['jobSnapshot'] as Map<String, dynamic>;
      jobMini = JobMini(
        id: j['id'] as String,
        title: j['title'] as String,
        companyName: j['companyName'] as String,
        location: j['location'] as String,
        contractType: j['contractType'] as String,
        companyLogoUrl: j['companyLogoUrl'] as String?,
        salaryFormatted: j['salaryFormatted'] as String?,
      );
    }

    // Parse CandidateSnapshot
    final c = data['candidateSnapshot'] as Map<String, dynamic>;
    final candidateSnapshot = CandidateSnapshot(
      uid: c['uid'] as String,
      name: c['name'] as String,
      skills: List<String>.from(c['skills'] as Iterable<dynamic>? ?? []),
      experiences: List<String>.from(c['experiences'] as Iterable<dynamic>? ?? []),
      photoUrl: c['photoUrl'] as String?,
      bio: c['bio'] as String?,
      cvStoragePath: c['cvStoragePath'] as String?,
    );

    return Application(
      id: doc.id,
      candidateId: data['candidateId'] as String,
      jobId: data['jobId'] as String,
      companyId: data['companyId'] as String,
      status: ApplicationStatus.fromString(data['status'] as String? ?? 'sent'),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      candidateSnapshot: candidateSnapshot,
      jobMini: jobMini,
      coverLetter: data['coverLetter'] as String?,
    );
  }
}
