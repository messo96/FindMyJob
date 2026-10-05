import 'package:equatable/equatable.dart';

// ── Enums ─────────────────────────────────────────────────────────────────

enum ApplicationStatus {
  sent,
  viewed,
  evaluating,
  interview,
  accepted,
  rejected;

  String get displayName => switch (this) {
        ApplicationStatus.sent => 'Inviata',
        ApplicationStatus.viewed => 'Visualizzata',
        ApplicationStatus.evaluating => 'In valutazione',
        ApplicationStatus.interview => 'Colloquio',
        ApplicationStatus.accepted => 'Accettata',
        ApplicationStatus.rejected => 'Rifiutata',
      };

  static ApplicationStatus fromString(String v) => switch (v) {
        'viewed' => ApplicationStatus.viewed,
        'evaluating' => ApplicationStatus.evaluating,
        'interview' => ApplicationStatus.interview,
        'accepted' => ApplicationStatus.accepted,
        'rejected' => ApplicationStatus.rejected,
        _ => ApplicationStatus.sent,
      };

  bool get isFinal =>
      this == ApplicationStatus.accepted || this == ApplicationStatus.rejected;
}

// ── Snapshot entities ──────────────────────────────────────────────────────

/// Minimal job info denormalised into SavedJob and shown in lists.
class JobMini extends Equatable {
  const JobMini({
    required this.id,
    required this.title,
    required this.companyName,
    required this.location,
    required this.contractType,
    this.companyLogoUrl,
    this.salaryFormatted,
  });

  final String id;
  final String title;
  final String companyName;
  final String? companyLogoUrl;
  final String location;
  final String contractType;
  final String? salaryFormatted;

  @override
  List<Object?> get props => [id];
}

/// Snapshot of candidate profile captured at application time.
/// Persisted inside each Application document.
class CandidateSnapshot extends Equatable {
  const CandidateSnapshot({
    required this.uid,
    required this.name,
    required this.skills,
    required this.experiences,
    this.photoUrl,
    this.bio,
    this.cvStoragePath,
  });

  final String uid;
  final String name;
  final String? photoUrl;
  final String? bio;
  final List<String> skills;
  final List<String> experiences; // human-readable strings for quick display
  final String? cvStoragePath;   // signed URL generated server-side on demand

  @override
  List<Object?> get props => [uid];
}

// ── Application entity ─────────────────────────────────────────────────────

class Application extends Equatable {
  const Application({
    required this.id,
    required this.candidateId,
    required this.jobId,
    required this.companyId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.candidateSnapshot,
    this.jobMini,
    this.coverLetter,
  });

  final String id;
  final String candidateId;
  final String jobId;
  final String companyId;
  final ApplicationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CandidateSnapshot candidateSnapshot;
  final JobMini? jobMini;      // denormalised — populated by repository
  final String? coverLetter;

  @override
  List<Object?> get props => [id, candidateId, jobId, status];

  Application copyWith({ApplicationStatus? status, DateTime? updatedAt}) {
    return Application(
      id: id,
      candidateId: candidateId,
      jobId: jobId,
      companyId: companyId,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      candidateSnapshot: candidateSnapshot,
      jobMini: jobMini,
      coverLetter: coverLetter,
    );
  }
}

// ── SavedJob entity ────────────────────────────────────────────────────────

class SavedJob extends Equatable {
  const SavedJob({
    required this.jobId,
    required this.savedAt,
    required this.jobSnapshot,
  });

  final String jobId;
  final DateTime savedAt;
  final JobMini jobSnapshot;

  @override
  List<Object?> get props => [jobId];
}
