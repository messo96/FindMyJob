import 'package:equatable/equatable.dart';

/// User roles.
enum UserRole {
  candidate,
  company;

  bool get isCandidate => this == UserRole.candidate;
  bool get isCompany => this == UserRole.company;

  String get displayName => switch (this) {
        UserRole.candidate => 'Candidato',
        UserRole.company => 'Azienda',
      };

  static UserRole fromString(String value) => switch (value) {
        'candidate' => UserRole.candidate,
        'company' => UserRole.company,
        _ => throw ArgumentError('Unknown role: $value'),
      };
}

/// Core user entity, minimal data stored at auth level.
/// Full profile is in [CandidateProfile] or [CompanyProfile].
class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.displayName,
    this.photoUrl,
    this.fcmTokens = const [],
  });

  final String uid;
  final String email;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? displayName;
  final String? photoUrl;
  final List<String> fcmTokens;

  @override
  List<Object?> get props => [uid, email, role, createdAt, updatedAt];

  AppUser copyWith({
    UserRole? role,
    String? displayName,
    String? photoUrl,
    List<String>? fcmTokens,
    DateTime? updatedAt,
  }) {
    return AppUser(
      uid: uid,
      email: email,
      role: role ?? this.role,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      fcmTokens: fcmTokens ?? this.fcmTokens,
    );
  }
}
