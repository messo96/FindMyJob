import 'package:flutter_test/flutter_test.dart';
import 'package:find_my_job/features/jobs/domain/entities/job.dart';

void main() {
  group('Job Entity', () {
    final baseJob = Job(
      id: 'job_1',
      title: 'Flutter Developer',
      companyId: 'comp_1',
      companyName: 'Tech Co',
      description: 'A great job',
      skills: const ['Flutter', 'Dart'],
      category: 'IT',
      location: 'Milan, Italy',
      latitude: 45.4642,
      longitude: 9.1900,
      geohash: 'u0nd',
      contractType: ContractType.fullTime,
      salary: const SalaryRange(min: 30000, max: 50000),
      status: JobStatus.active,
      applicationsCount: 5,
      createdAt: DateTime(2023, 10, 1),
      updatedAt: DateTime(2023, 10, 1),
    );

    test('should format salary range correctly when both min and max are provided', () {
      expect(baseJob.salary?.formatted, '€30000–50000/mese');
    });

    test('should return isApplicable true when status is active and no expiration', () {
      expect(baseJob.isApplicable, true);
    });

    test('should return isApplicable false when status is closed', () {
      final job = baseJob.copyWith(status: JobStatus.closed);
      expect(job.isApplicable, false);
    });
  });
}
