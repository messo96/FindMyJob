import 'package:equatable/equatable.dart';
import '../../../jobs/domain/entities/job.dart';

// ── Enums ─────────────────────────────────────────────────────────────────

enum Availability {
  immediate,
  oneMonth,
  flexible;

  String get displayName => switch (this) {
        Availability.immediate => 'Subito disponibile',
        Availability.oneMonth => 'Disponibile entro un mese',
        Availability.flexible => 'Flessibile',
      };
}

enum CompanySize {
  startup,
  small,
  medium,
  large,
  enterprise;

  String get displayName => switch (this) {
        CompanySize.startup => 'Startup (1-10)',
        CompanySize.small => 'Piccola (11-50)',
        CompanySize.medium => 'Media (51-250)',
        CompanySize.large => 'Grande (251-1000)',
        CompanySize.enterprise => 'Enterprise (1000+)',
      };
}

// ── Sub-entities ───────────────────────────────────────────────────────────

class Experience extends Equatable {
  const Experience({
    required this.id,
    required this.company,
    required this.title,
    required this.startDate,
    this.endDate,
    this.description,
    this.isCurrent = false,
  });

  final String id;
  final String company;
  final String title;
  final DateTime startDate;
  final DateTime? endDate;
  final String? description;
  final bool isCurrent;

  String get durationLabel {
    final end = isCurrent ? DateTime.now() : (endDate ?? DateTime.now());
    final months = (end.difference(startDate).inDays / 30).round();
    if (months < 12) return '$months mesi';
    final years = months ~/ 12;
    final rem = months % 12;
    if (rem == 0) return '$years ${years == 1 ? 'anno' : 'anni'}';
    return '$years ${years == 1 ? 'anno' : 'anni'} e $rem mesi';
  }

  @override
  List<Object?> get props => [id];
}

class Education extends Equatable {
  const Education({
    required this.id,
    required this.institution,
    required this.degree,
    required this.field,
    required this.startYear,
    this.endYear,
    this.isCurrent = false,
  });

  final String id;
  final String institution;
  final String degree;
  final String field;
  final int startYear;
  final int? endYear;
  final bool isCurrent;

  @override
  List<Object?> get props => [id];
}

// ── Profile entities ───────────────────────────────────────────────────────

class CandidateProfile extends Equatable {
  const CandidateProfile({
    required this.uid,
    required this.skills,
    required this.experiences,
    required this.education,
    required this.preferredCategories,
    required this.preferredContractTypes,
    required this.updatedAt,
    this.bio,
    this.location,
    this.latitude,
    this.longitude,
    this.cvStoragePath,
    this.cvFileName,
    this.availability = Availability.flexible,
    this.preferredSalaryMin,
    this.searchRadiusKm = 25.0,
  });

  final String uid;
  final String? bio;
  final String? location;
  final double? latitude;
  final double? longitude;
  final List<String> skills;
  final List<Experience> experiences;
  final List<Education> education;
  final String? cvStoragePath;
  final String? cvFileName;
  final Availability availability;
  final List<String> preferredCategories;
  final List<ContractType> preferredContractTypes;
  final double? preferredSalaryMin;
  final double searchRadiusKm;
  final DateTime updatedAt;

  bool get hasCv => cvStoragePath != null && cvStoragePath!.isNotEmpty;

  /// Returns a value between 0.0 and 1.0 representing profile completeness.
  double get completeness {
    double score = 0;
    if (bio != null && bio!.isNotEmpty) score += 0.15;
    if (location != null) score += 0.10;
    if (skills.isNotEmpty) score += 0.20;
    if (experiences.isNotEmpty) score += 0.20;
    if (education.isNotEmpty) score += 0.15;
    if (hasCv) score += 0.20;
    return score.clamp(0.0, 1.0);
  }

  int get completenessPercent => (completeness * 100).round();

  @override
  List<Object?> get props => [uid, updatedAt];

  CandidateProfile copyWith({
    String? bio,
    String? location,
    double? latitude,
    double? longitude,
    List<String>? skills,
    List<Experience>? experiences,
    List<Education>? education,
    String? cvStoragePath,
    String? cvFileName,
    Availability? availability,
    List<String>? preferredCategories,
    List<ContractType>? preferredContractTypes,
    double? preferredSalaryMin,
    double? searchRadiusKm,
    DateTime? updatedAt,
  }) {
    return CandidateProfile(
      uid: uid,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      skills: skills ?? this.skills,
      experiences: experiences ?? this.experiences,
      education: education ?? this.education,
      cvStoragePath: cvStoragePath ?? this.cvStoragePath,
      cvFileName: cvFileName ?? this.cvFileName,
      availability: availability ?? this.availability,
      preferredCategories: preferredCategories ?? this.preferredCategories,
      preferredContractTypes: preferredContractTypes ?? this.preferredContractTypes,
      preferredSalaryMin: preferredSalaryMin ?? this.preferredSalaryMin,
      searchRadiusKm: searchRadiusKm ?? this.searchRadiusKm,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CompanyProfile extends Equatable {
  const CompanyProfile({
    required this.uid,
    required this.name,
    required this.updatedAt,
    this.description,
    this.logoStoragePath,
    this.website,
    this.sector,
    this.size,
    this.location,
    this.latitude,
    this.longitude,
    this.contactEmail,
    this.contactPhone,
  });

  final String uid;
  final String name;
  final String? description;
  final String? logoStoragePath;
  final String? website;
  final String? sector;
  final CompanySize? size;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? contactEmail;
  final String? contactPhone;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [uid, updatedAt];
}
