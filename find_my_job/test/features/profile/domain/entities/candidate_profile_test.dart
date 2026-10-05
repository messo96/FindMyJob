import 'package:flutter_test/flutter_test.dart';
import 'package:find_my_job/features/profile/domain/entities/profile.dart';

void main() {
  group('CandidateProfile', () {
    final baseProfile = CandidateProfile(
      uid: 'user123',
      skills: const [],
      experiences: const [],
      education: const [],
      preferredCategories: const [],
      preferredContractTypes: const [],
      updatedAt: DateTime.now(),
    );

    test('completeness should be 0.0 for empty profile', () {
      expect(baseProfile.completeness, 0.0);
      expect(baseProfile.completenessPercent, 0);
    });

    test('completeness should increase when bio is added', () {
      final p = baseProfile.copyWith(bio: 'Hello world');
      expect(p.completeness, 0.15);
      expect(p.completenessPercent, 15);
    });

    test('completeness should increase when skills are added', () {
      final p = baseProfile.copyWith(skills: ['Flutter', 'Dart']);
      expect(p.completeness, 0.20);
      expect(p.completenessPercent, 20);
    });

    test('completeness should be 1.0 (100%) for full profile', () {
      final p = baseProfile.copyWith(
        bio: 'Hello',
        location: 'Milan',
        skills: ['Dart'],
        experiences: [Experience(id: '1', company: 'Google', title: 'Dev', startDate: DateTime.now())],
        education: [Education(id: '1', institution: 'Polimi', degree: 'BSc', field: 'CS', startYear: 2020)],
        cvStoragePath: 'path/to/cv.pdf',
      );

      // bio 0.15 + location 0.10 + skills 0.20 + exp 0.20 + edu 0.15 + cv 0.20 = 1.0
      expect(p.completeness, 1.0);
      expect(p.completenessPercent, 100);
    });
  });
}
