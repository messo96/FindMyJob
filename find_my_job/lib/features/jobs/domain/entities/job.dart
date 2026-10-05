import 'package:equatable/equatable.dart';

// ── Enums ─────────────────────────────────────────────────────────────────

enum ContractType {
  fullTime,
  partTime,
  freelance,
  internship,
  temporary;

  String get displayName => switch (this) {
        ContractType.fullTime => 'Tempo pieno',
        ContractType.partTime => 'Part-time',
        ContractType.freelance => 'Freelance',
        ContractType.internship => 'Stage',
        ContractType.temporary => 'Tempo determinato',
      };

  static ContractType fromString(String v) => switch (v) {
        'full_time' => ContractType.fullTime,
        'part_time' => ContractType.partTime,
        'freelance' => ContractType.freelance,
        'internship' => ContractType.internship,
        'temporary' => ContractType.temporary,
        _ => ContractType.fullTime,
      };

  String get firestoreValue => switch (this) {
        ContractType.fullTime => 'full_time',
        ContractType.partTime => 'part_time',
        ContractType.freelance => 'freelance',
        ContractType.internship => 'internship',
        ContractType.temporary => 'temporary',
      };
}

enum ExperienceLevel {
  any,
  junior,
  mid,
  senior,
  lead;

  String get displayName => switch (this) {
        ExperienceLevel.any => 'Qualsiasi livello',
        ExperienceLevel.junior => 'Junior (0-2 anni)',
        ExperienceLevel.mid => 'Mid (2-5 anni)',
        ExperienceLevel.senior => 'Senior (5-10 anni)',
        ExperienceLevel.lead => 'Lead (10+ anni)',
      };

  static ExperienceLevel fromString(String v) => switch (v) {
        'junior' => ExperienceLevel.junior,
        'mid' => ExperienceLevel.mid,
        'senior' => ExperienceLevel.senior,
        'lead' => ExperienceLevel.lead,
        _ => ExperienceLevel.any,
      };
}

enum JobStatus {
  draft,
  active,
  closed,
  expired;

  bool get isApplicable => this == JobStatus.active;

  String get displayName => switch (this) {
        JobStatus.draft => 'Bozza',
        JobStatus.active => 'Attiva',
        JobStatus.closed => 'Chiusa',
        JobStatus.expired => 'Scaduta',
      };

  static JobStatus fromString(String v) => switch (v) {
        'draft' => JobStatus.draft,
        'active' => JobStatus.active,
        'closed' => JobStatus.closed,
        'expired' => JobStatus.expired,
        _ => JobStatus.draft,
      };
}

enum SalaryPeriod {
  hourly,
  monthly,
  yearly;

  String get displayName => switch (this) {
        SalaryPeriod.hourly => '/ora',
        SalaryPeriod.monthly => '/mese',
        SalaryPeriod.yearly => '/anno',
      };
}

// ── Value objects ──────────────────────────────────────────────────────────

class SalaryRange extends Equatable {
  const SalaryRange({
    this.min,
    this.max,
    this.currency = 'EUR',
    this.period = SalaryPeriod.monthly,
  });

  final double? min;
  final double? max;
  final String currency;
  final SalaryPeriod period;

  String get formatted {
    if (min == null && max == null) return 'Non specificato';
    final symbol = currency == 'EUR' ? '€' : currency;
    final suffix = period.displayName;
    if (min != null && max != null) {
      return '$symbol${min!.toStringAsFixed(0)}–${max!.toStringAsFixed(0)}$suffix';
    }
    if (min != null) return 'Da $symbol${min!.toStringAsFixed(0)}$suffix';
    return 'Fino a $symbol${max!.toStringAsFixed(0)}$suffix';
  }

  @override
  List<Object?> get props => [min, max, currency, period];
}

// ── Job entity ─────────────────────────────────────────────────────────────

class Job extends Equatable {
  const Job({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.title,
    required this.description,
    required this.category,
    required this.contractType,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.geohash,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.applicationsCount,
    this.companyLogoUrl,
    this.skills = const [],
    this.benefits = const [],
    this.salary,
    this.workingHours,
    this.experienceLevel = ExperienceLevel.any,
    this.expirationDate,
    // Computed fields (filled by repository)
    this.distanceKm,
    this.relevanceScore,
  });

  final String id;
  final String companyId;
  final String companyName;
  final String? companyLogoUrl;
  final String title;
  final String description;
  final String category;
  final ContractType contractType;
  final ExperienceLevel experienceLevel;
  final List<String> skills;
  final List<String> benefits;
  final SalaryRange? salary;
  final String? workingHours;
  final String location;
  final double latitude;
  final double longitude;
  final String geohash;
  final JobStatus status;
  final int applicationsCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? expirationDate;

  // Computed at query time
  final double? distanceKm;
  final double? relevanceScore;

  bool get isApplicable =>
      status.isApplicable &&
      (expirationDate == null || expirationDate!.isAfter(DateTime.now()));

  @override
  List<Object?> get props => [id, companyId, title, status, createdAt];

  Job copyWith({
    JobStatus? status,
    int? applicationsCount,
    double? distanceKm,
    double? relevanceScore,
  }) {
    return Job(
      id: id,
      companyId: companyId,
      companyName: companyName,
      companyLogoUrl: companyLogoUrl,
      title: title,
      description: description,
      category: category,
      contractType: contractType,
      experienceLevel: experienceLevel,
      skills: skills,
      benefits: benefits,
      salary: salary,
      workingHours: workingHours,
      location: location,
      latitude: latitude,
      longitude: longitude,
      geohash: geohash,
      status: status ?? this.status,
      applicationsCount: applicationsCount ?? this.applicationsCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      expirationDate: expirationDate,
      distanceKm: distanceKm ?? this.distanceKm,
      relevanceScore: relevanceScore ?? this.relevanceScore,
    );
  }
}
