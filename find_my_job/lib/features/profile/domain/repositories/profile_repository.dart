import '../../../profile/domain/entities/profile.dart';

/// Abstract repository for candidate and company profile operations.
abstract class ProfileRepository {
  // ── Candidate ────────────────────────────────────────────────────────────

  /// Fetch candidate profile by UID.
  Future<CandidateProfile?> getCandidateProfile(String uid);

  /// Stream of current user's candidate profile.
  Stream<CandidateProfile?> watchCandidateProfile(String uid);

  /// Create or update candidate profile.
  Future<CandidateProfile> saveCandidateProfile(CandidateProfile profile);

  /// Upload CV file and update profile with storage path.
  /// Returns the storage path (never a public URL).
  Future<String> uploadCv({
    required String uid,
    required List<int> fileBytes,
    required String fileName,
  });

  /// Delete the CV file and clear the path on the profile.
  Future<void> deleteCv(String uid);

  /// Generate a temporary signed URL for CV access (server-side).
  /// Used by companies who received an application.
  Future<String> getCvSignedUrl(String applicationId);

  // ── Company ──────────────────────────────────────────────────────────────

  /// Fetch company profile by UID.
  Future<CompanyProfile?> getCompanyProfile(String uid);

  /// Stream of current user's company profile.
  Stream<CompanyProfile?> watchCompanyProfile(String uid);

  /// Create or update company profile.
  Future<CompanyProfile> saveCompanyProfile(CompanyProfile profile);

  /// Upload company logo and return storage path.
  Future<String> uploadCompanyLogo({
    required String uid,
    required List<int> fileBytes,
    required String fileName,
  });
}
