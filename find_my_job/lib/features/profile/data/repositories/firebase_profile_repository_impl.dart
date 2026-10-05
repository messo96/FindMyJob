import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../jobs/domain/entities/job.dart';

class FirebaseProfileRepositoryImpl implements ProfileRepository {
  FirebaseProfileRepositoryImpl(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  @override
  Future<CandidateProfile?> getCandidateProfile(String uid) async {
    try {
      final doc = await _firestore.collection('candidateProfiles').doc(uid).get();
      if (!doc.exists) return null;
      return _candidateProfileFromFirestore(doc);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Stream<CandidateProfile?> watchCandidateProfile(String uid) {
    return _firestore.collection('candidateProfiles').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return _candidateProfileFromFirestore(doc);
    });
  }

  @override
  Future<CandidateProfile> saveCandidateProfile(CandidateProfile profile) async {
    try {
      await _firestore.collection('candidateProfiles').doc(profile.uid).set(_candidateProfileToFirestore(profile), SetOptions(merge: true));
      return profile;
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<String> uploadCv({
    required String uid,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    try {
      final ref = _storage.ref().child('cvs/$uid/$fileName');
      await ref.putData(Uint8List.fromList(fileBytes));
      final path = ref.fullPath;
      
      // Update profile with new CV path
      await _firestore.collection('candidateProfiles').doc(uid).set({
        'cvStoragePath': path,
        'cvFileName': fileName,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return path;
    } catch (e) {
      throw StorageFailure(e.toString());
    }
  }

  @override
  Future<void> deleteCv(String uid) async {
    try {
      final doc = await _firestore.collection('candidateProfiles').doc(uid).get();
      final path = doc.data()?['cvStoragePath'] as String?;
      if (path != null) {
        await _storage.ref(path).delete();
      }
      await _firestore.collection('candidateProfiles').doc(uid).update({
        'cvStoragePath': FieldValue.delete(),
        'cvFileName': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw StorageFailure(e.toString());
    }
  }

  @override
  Future<String> getCvSignedUrl(String applicationId) async {
    // Should be implemented via Cloud Functions for security
    // Here we'll just mock it or fetch download URL if rules allow
    try {
      final appDoc = await _firestore.collection('applications').doc(applicationId).get();
      final path = (appDoc.data()?['candidateSnapshot'] as Map?)?['cvStoragePath'] as String?;
      if (path == null) throw const NotFoundFailure('CV non trovato');
      
      return await _storage.ref(path).getDownloadURL();
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<CompanyProfile?> getCompanyProfile(String uid) async {
    try {
      final doc = await _firestore.collection('companyProfiles').doc(uid).get();
      if (!doc.exists) return null;
      return _companyProfileFromFirestore(doc);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Stream<CompanyProfile?> watchCompanyProfile(String uid) {
    return _firestore.collection('companyProfiles').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return _companyProfileFromFirestore(doc);
    });
  }

  @override
  Future<CompanyProfile> saveCompanyProfile(CompanyProfile profile) async {
    try {
      await _firestore.collection('companyProfiles').doc(profile.uid).set(_companyProfileToFirestore(profile), SetOptions(merge: true));
      return profile;
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<String> uploadCompanyLogo({
    required String uid,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    try {
      final ref = _storage.ref().child('logos/$uid/$fileName');
      await ref.putData(Uint8List.fromList(fileBytes));
      final url = await ref.getDownloadURL(); // public URL for logos
      
      await _firestore.collection('companyProfiles').doc(uid).set({
        'logoStoragePath': url,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      // Also update user's profile
      await _firestore.collection('users').doc(uid).update({
        'photoUrl': url,
      });

      return url;
    } catch (e) {
      throw StorageFailure(e.toString());
    }
  }

  // --- Converters ---

  CandidateProfile _candidateProfileFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CandidateProfile(
      uid: doc.id,
      bio: data['bio'] as String?,
      location: data['location'] as String?,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      skills: List<String>.from(data['skills'] as Iterable? ?? []),
      experiences: (data['experiences'] as Iterable? ?? []).map((dynamic e) {
        final ex = e as Map<String, dynamic>;
        return Experience(
          id: ex['id'] as String? ?? '',
          company: ex['company'] as String,
          title: ex['title'] as String,
          description: ex['description'] as String?,
          startDate: (ex['startDate'] as Timestamp).toDate(),
          endDate: (ex['endDate'] as Timestamp?)?.toDate(),
          isCurrent: ex['isCurrent'] as bool? ?? false,
        );
      }).toList(),
      education: (data['education'] as Iterable? ?? []).map((dynamic e) {
        final ed = e as Map<String, dynamic>;
        return Education(
          id: ed['id'] as String? ?? '',
          institution: ed['institution'] as String,
          degree: ed['degree'] as String,
          field: ed['field'] as String,
          startYear: ed['startYear'] as int,
          endYear: ed['endYear'] as int?,
          isCurrent: ed['isCurrent'] as bool? ?? false,
        );
      }).toList(),
      cvStoragePath: data['cvStoragePath'] as String?,
      cvFileName: data['cvFileName'] as String?,
      availability: Availability.values.firstWhere(
        (v) => v.name == data['availability'],
        orElse: () => Availability.flexible,
      ),
      preferredCategories: List<String>.from(data['preferredCategories'] as Iterable? ?? []),
      preferredContractTypes: (data['preferredContractTypes'] as Iterable? ?? []).map((e) {
        return ContractType.values.firstWhere((v) => v.name == e, orElse: () => ContractType.fullTime);
      }).toList(),
      preferredSalaryMin: (data['preferredSalaryMin'] as num?)?.toDouble(),
      searchRadiusKm: (data['searchRadiusKm'] as num?)?.toDouble() ?? 25.0,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> _candidateProfileToFirestore(CandidateProfile p) {
    return {
      'uid': p.uid,
      'bio': p.bio,
      'location': p.location,
      'latitude': p.latitude,
      'longitude': p.longitude,
      'skills': p.skills,
      'experiences': p.experiences.map((e) => {
        'company': e.company,
        'title': e.title,
        'description': e.description,
        'startDate': Timestamp.fromDate(e.startDate),
        'endDate': e.endDate != null ? Timestamp.fromDate(e.endDate!) : null,
        'isCurrent': e.isCurrent,
      }).toList(),
      'education': p.education.map((e) => {
        'institution': e.institution,
        'degree': e.degree,
        'field': e.field,
        'startYear': e.startYear,
        'endYear': e.endYear,
        'isCurrent': e.isCurrent,
      }).toList(),
      'availability': p.availability.name,
      'preferredCategories': p.preferredCategories,
      'preferredContractTypes': p.preferredContractTypes.map((e) => e.name).toList(), // Assuming e.name or e.firestoreValue
      'preferredSalaryMin': p.preferredSalaryMin,
      'searchRadiusKm': p.searchRadiusKm,
      'profileCompleteness': p.completeness,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  CompanyProfile _companyProfileFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CompanyProfile(
      uid: doc.id,
      name: data['name'] as String,
      description: data['description'] as String?,
      logoStoragePath: data['logoStoragePath'] as String?,
      website: data['website'] as String?,
      sector: data['sector'] as String?,
      size: CompanySize.values.firstWhere(
        (v) => v.name == data['size'],
        orElse: () => CompanySize.small,
      ),
      location: data['location'] as String?,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      contactEmail: data['contactEmail'] as String?,
      contactPhone: data['contactPhone'] as String?,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> _companyProfileToFirestore(CompanyProfile p) {
    return {
      'uid': p.uid,
      'name': p.name,
      'description': p.description,
      'logoStoragePath': p.logoStoragePath,
      'website': p.website,
      'sector': p.sector,
      'size': p.size?.name,
      'location': p.location,
      'latitude': p.latitude,
      'longitude': p.longitude,
      'contactEmail': p.contactEmail,
      'contactPhone': p.contactPhone,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
